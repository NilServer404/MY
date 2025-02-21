--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : 战斗日志 流式保存原始事件数据
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@derzh.com)
-- @copyright: Copyright (c) 2013 EMZ Kingsoft Co., Ltd.
--------------------------------------------------------
-------------------------------------------------------------------------------------------------------
-- these global functions are accessed all the time by the event handler
-- so caching them is worth the effort
-------------------------------------------------------------------------------------------------------
local ipairs, pairs, next, pcall, select = ipairs, pairs, next, pcall, select
local string, math, table = string, math, table
-- lib apis caching
local X = MY
local UI, GLOBAL, CONSTANT, wstring, lodash = X.UI, X.GLOBAL, X.CONSTANT, X.wstring, X.lodash
-------------------------------------------------------------------------------------------------------
local PLUGIN_NAME = 'MY_TeamTools'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_TeamTools'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^9.0.0') then
	return
end
--------------------------------------------------------------------------

local O = X.CreateUserSettingsModule('MY_CombatLogs', _L['Raid'], {
	bEnable = { -- 数据记录总开关
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_TeamTools'],
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	nMaxHistory = { -- 最大历史数据数量
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_TeamTools'],
		xSchema = X.Schema.Number,
		xDefaultValue = 300,
	},
	nMinFightTime = { -- 最小战斗时间
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_TeamTools'],
		xSchema = X.Schema.Number,
		xDefaultValue = 30,
	},
	bOnlyDungeon = { -- 仅在秘境中启用
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_TeamTools'],
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
	bOnlySelf = { -- 仅记录和自己有关的
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_TeamTools'],
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
})
local D = {}
local DS_ROOT = {'userdata/combat_logs/', X.PATH_TYPE.ROLE}

local LOG_ENABLE = false -- 计算出来的总开关，按条件随时重算
local LOG_TIME = 0
local LOG_FILE -- 当前日志文件，处于存盘模式，即处于逻辑战斗状态时不为空
local LOG_CACHE = {} -- 尚未存盘的数据（降低磁盘压力）
local LOG_CACHE_LIMIT = 20 -- 缓存数据达到数量触发存盘
local LOG_CRC = 0
local LOG_TARGET_INFO_TIME = {} -- 目标信息记录时间
local LOG_TARGET_INFO_TIME_LIMIT = 10000 -- 目标信息再次记录最小时间间隔
local LOG_DOODAD_INFO_TIME = {} -- 交互物件信息记录时间
local LOG_DOODAD_INFO_TIME_LIMIT = 10000 -- 交互物件信息再次记录最小时间间隔
local LOG_NAMING_COUNT = {} -- 记录中NPC被提及的数量统计，用于命名记录文件

local LOG_REPLAY = {} -- 最近的数据 （进战时候将最近的数据压进来）
local LOG_REPLAY_FRAME = GLOBAL.GAME_FPS * 1 -- 进战时候将多久的数据压进来（逻辑帧）

local LOG_TYPE = {
	FIGHT_TIME                            = 1,  -- 战斗时间
	PLAYER_ENTER_SCENE                    = 2,  -- 玩家进入场景
	PLAYER_LEAVE_SCENE                    = 3,  -- 玩家离开场景
	PLAYER_INFO                           = 4,  -- 玩家信息数据
	PLAYER_FIGHT_HINT                     = 5,  -- 玩家战斗状态改变
	NPC_ENTER_SCENE                       = 6,  -- NPC 进入场景
	NPC_LEAVE_SCENE                       = 7,  -- NPC 离开场景
	NPC_INFO                              = 8,  -- NPC 信息数据
	NPC_FIGHT_HINT                        = 9,  -- NPC 战斗状态改变
	DOODAD_ENTER_SCENE                    = 10, -- 交互物件进入场景
	DOODAD_LEAVE_SCENE                    = 11, -- 交互物件离开场景
	DOODAD_INFO                           = 12, -- 交互物件信息数据
	BUFF_UPDATE                           = 13, -- BUFF 刷新
	PLAYER_SAY                            = 14, -- 角色喊话（仅记录NPC）
	ON_WARNING_MESSAGE                    = 15, -- 显示警告框
	PARTY_ADD_MEMBER                      = 16, -- 团队添加成员
	PARTY_SET_MEMBER_ONLINE_FLAG          = 17, -- 团队成员在线状态改变
	MSG_SYS                               = 18, -- 系统消息
	SYS_MSG_UI_OME_SKILL_CAST_LOG         = 19, -- 技能施放日志
	SYS_MSG_UI_OME_SKILL_CAST_RESPOND_LOG = 20, -- 技能施放结果日志
	SYS_MSG_UI_OME_SKILL_EFFECT_LOG       = 21, -- 技能最终产生的效果（生命值的变化）
	SYS_MSG_UI_OME_SKILL_BLOCK_LOG        = 22, -- 格挡日志
	SYS_MSG_UI_OME_SKILL_SHIELD_LOG       = 23, -- 技能被屏蔽日志
	SYS_MSG_UI_OME_SKILL_MISS_LOG         = 24, -- 技能未命中目标日志
	SYS_MSG_UI_OME_SKILL_HIT_LOG          = 25, -- 技能命中目标日志
	SYS_MSG_UI_OME_SKILL_DODGE_LOG        = 26, -- 技能被闪避日志
	SYS_MSG_UI_OME_COMMON_HEALTH_LOG      = 27, -- 普通治疗日志
	SYS_MSG_UI_OME_DEATH_NOTIFY           = 28, -- 死亡日志
}

-- 更新启用状态
function D.UpdateEnable()
	local bEnable = D.bReady and O.bEnable and (not O.bOnlyDungeon or X.IsInDungeon())
	if not bEnable and LOG_ENABLE then
		D.CloseCombatLogs()
	elseif bEnable and not LOG_ENABLE and X.IsFighting() then
		D.OpenCombatLogs()
	end
	LOG_ENABLE = bEnable
end
X.RegisterEvent('LOADING_ENDING', D.UpdateEnable)

-- 加载历史数据列表
function D.GetHistoryFiles()
	local aFiles = {}
	local szRoot = X.FormatPath(DS_ROOT)
	for _, v in ipairs(CPath.GetFileList(szRoot)) do
		if v:find('.jcl.tsv$') then
			table.insert(aFiles, v)
		end
	end
	table.sort(aFiles, function(a, b) return a > b end)
	for k, v in ipairs(aFiles) do
		aFiles[k] = szRoot .. v
	end
	return aFiles
end

-- 限制历史数据数量
function D.LimitHistoryFile()
	local aFiles = D.GetHistoryFiles()
	for i = O.nMaxHistory + 1, #aFiles do
		CPath.DelFile(aFiles[i])
	end
end

-- 连接到新的日志文件
function D.OpenCombatLogs()
	D.CloseCombatLogs()
	local szRoot = X.FormatPath(DS_ROOT)
	CPath.MakeDir(szRoot)
	local szTime = X.FormatTime(GetCurrentTime(), '%yyyy-%MM-%dd-%hh-%mm-%ss')
	local szMapName = ''
	local me = GetClientPlayer()
	if me then
		local map = X.GetMapInfo(me.GetMapID())
		if map then
			szMapName = '-' .. map.szName
		end
	end
	LOG_FILE = szRoot .. szTime .. szMapName .. '.jcl.log'
	LOG_TIME = GetCurrentTime()
	LOG_CACHE = {}
	LOG_TARGET_INFO_TIME = {}
	LOG_DOODAD_INFO_TIME = {}
	LOG_NAMING_COUNT = {}
	LOG_CRC = 0
	Log(LOG_FILE, '', 'clear')
end

-- 关闭到日志文件的连接
function D.CloseCombatLogs()
	if not LOG_FILE then
		return
	end
	D.FlushLogs(true)
	Log(LOG_FILE, '', 'close')
	if GetCurrentTime() - LOG_TIME < O.nMinFightTime then
		CPath.DelFile(LOG_FILE)
	else
		local szName, nCount = '', 0
		for _, p in pairs(LOG_NAMING_COUNT) do
			if p.nCount > nCount then
				nCount = p.nCount
				szName = '-' .. p.szName
			end
		end
		CPath.Move(LOG_FILE, wstring.sub(LOG_FILE, 1, -9) .. szName .. '.jcl')
	end
	LOG_FILE = nil
end
X.RegisterReload('MY_CombatLogs', D.CloseCombatLogs)

-- 将缓存数据写入磁盘
function D.FlushLogs(bForce)
	if not LOG_FILE then
		return
	end
	if not bForce and #LOG_CACHE < LOG_CACHE_LIMIT then
		return
	end
	for _, v in ipairs(LOG_CACHE) do
		Log(LOG_FILE, v)
	end
	LOG_CACHE = {}
end

-- 插入事件数据
function D.InsertLog(szEvent, oData, bReplay)
	if not LOG_ENABLE then
		return
	end
	assert(szEvent, 'error: missing event id')
	-- 生成日志行
	local nLFC = GetLogicFrameCount()
	local szLog = nLFC
		.. '\t' .. GetCurrentTime()
		.. '\t' .. GetTime()
		.. '\t' .. szEvent
		.. '\t' .. wstring.gsub(wstring.gsub(X.EncodeLUAData(oData), '\\\n', '\\n'), '\t', '\\t')
	local nCRC = GetStringCRC(LOG_CRC .. szLog .. 'c910e9b9-8359-4531-85e0-6897d8c129f7')
	-- 插入缓存
	table.insert(LOG_CACHE, nCRC .. '\t' .. szLog .. '\n')
	-- 插入最近事件表
	if bReplay ~= false then
		while LOG_REPLAY[1] and nLFC - LOG_REPLAY[1].nLFC > LOG_REPLAY_FRAME do
			table.remove(LOG_REPLAY, 1)
		end
		table.insert(LOG_REPLAY, { nLFC = nLFC, szLog = szLog })
	end
	-- 更新流式校验码
	LOG_CRC = nCRC
	-- 检查数据存盘
	D.FlushLogs()
end

-- 重放最近事件
function D.ImportRecentLogs()
	-- 检查最近事件表插入缓存
	local nLFC, nCRC = GetLogicFrameCount(), LOG_CRC
	for _, v in ipairs(LOG_REPLAY) do
		if nLFC - v.nLFC <= LOG_REPLAY_FRAME then
			nCRC = GetStringCRC(nCRC .. v.szLog .. 'c910e9b9-8359-4531-85e0-6897d8c129f7')
			table.insert(LOG_CACHE, nCRC .. '\t' .. v.szLog .. '\n')
		end
	end
	-- 更新流式校验码
	LOG_CRC = nCRC
	-- 检查数据存盘
	D.FlushLogs()
end

-- 过图清除当前战斗数据
X.RegisterEvent({ 'LOADING_ENDING', 'RELOAD_UI_ADDON_END', 'BATTLE_FIELD_END', 'ARENA_END', 'MY_CLIENT_PLAYER_LEAVE_SCENE' }, function()
	D.FlushLogs(true)
end)

-- 退出战斗 保存数据
X.RegisterEvent('MY_FIGHT_HINT', function()
	if not LOG_ENABLE then
		return
	end
	local bFighting, szUUID, nDuring = arg0, arg1, arg2
	if not bFighting then
		D.InsertLog(LOG_TYPE.FIGHT_TIME, { bFighting, szUUID, nDuring })
	end
	if bFighting then -- 进入新的战斗
		D.OpenCombatLogs()
		D.ImportRecentLogs()
	else
		D.CloseCombatLogs()
	end
	if bFighting then
		D.InsertLog(LOG_TYPE.FIGHT_TIME, { bFighting, szUUID, nDuring })
	end
end)

function D.WillRecID(dwID)
	if O.bOnlySelf then
		if not IsPlayer(dwID) then
			local npc = GetNpc(dwID)
			if npc then
				dwID = npc.dwEmployer
			end
		end
		return dwID == UI_GetClientPlayerID()
	end
	return true
end

-- 保存目标信息
function D.OnTargetUpdate(dwID, bForce)
	if not X.IsNumber(dwID) then
		return
	end
	local bIsPlayer = IsPlayer(dwID)
	if not bIsPlayer then
		if not LOG_NAMING_COUNT[dwID] then
			LOG_NAMING_COUNT[dwID] = {
				nCount = 0,
				szName = '',
			}
		end
		LOG_NAMING_COUNT[dwID].nCount = LOG_NAMING_COUNT[dwID].nCount + 1
	end
	if not bForce and LOG_TARGET_INFO_TIME[dwID] and LOG_TARGET_INFO_TIME[dwID] - GetTime() < LOG_TARGET_INFO_TIME_LIMIT then
		return
	end
	if bIsPlayer then
		local player = GetPlayer(dwID)
		if not player then
			return
		end
		local szName = player.szName
		local dwForceID = player.dwForceID
		local dwMountKungfuID = -1
		if dwID == UI_GetClientPlayerID() then
			dwMountKungfuID = UI_GetPlayerMountKungfuID()
		else
			local info = GetClientTeam().GetMemberInfo(dwID)
			if info and not X.IsEmpty(info.dwMountKungfuID) then
				dwMountKungfuID = info.dwMountKungfuID
			else
				local kungfu = player.GetKungfuMount()
				if kungfu then
					dwMountKungfuID = kungfu.dwSkillID
				end
			end
		end
		local aEquip, nEquipScore = {}, player.GetTotalEquipScore()
		for nEquipIndex, tEquipInfo in pairs(X.GetPlayerEquipInfo(player)) do
			table.insert(aEquip, {
				nEquipIndex,
				tEquipInfo.dwTabType,
				tEquipInfo.dwTabIndex,
				tEquipInfo.nStrengthLevel,
				tEquipInfo.aSlotItem,
				tEquipInfo.dwPermanentEnchantID,
				tEquipInfo.dwTemporaryEnchantID,
				tEquipInfo.dwTemporaryEnchantLeftSeconds,
			})
		end
		local szGUID = X.GetPlayerGUID(dwID) or ''
		local aTalent = X.GetPlayerTalentInfo(player)
		if aTalent then
			for i, p in ipairs(aTalent) do
				aTalent[i] = {
					p.nIndex,
					p.dwSkillID,
					p.dwSkillLevel,
				}
			end
		end
		D.InsertLog(LOG_TYPE.PLAYER_INFO, { dwID, szName, dwForceID, dwMountKungfuID, nEquipScore, aEquip, aTalent, szGUID })
	else
		local npc = GetNpc(dwID)
		if not npc then
			return
		end
		local szName = X.GetObjectName(npc, 'never') or ''
		LOG_NAMING_COUNT[dwID].szName = szName
		D.InsertLog(LOG_TYPE.NPC_INFO, { dwID, szName, npc.dwTemplateID, npc.dwEmployer, npc.nX, npc.nY, npc.nZ })
	end
	LOG_TARGET_INFO_TIME[dwID] = GetTime()
end

-- 保存交互物件信息
function D.OnDoodadUpdate(dwID, bForce)
	if not bForce and LOG_DOODAD_INFO_TIME[dwID] and LOG_DOODAD_INFO_TIME[dwID] - GetTime() < LOG_DOODAD_INFO_TIME_LIMIT then
		return
	end
	local doodad = GetDoodad(dwID)
	if not doodad then
		return
	end
	D.InsertLog(LOG_TYPE.DOODAD_INFO, { dwID, doodad.dwTemplateID, doodad.nX, doodad.nY, doodad.nZ })
	LOG_DOODAD_INFO_TIME[dwID] = GetTime()
end

-- 系统日志监控（数据源）
X.RegisterEvent('SYS_MSG', function()
	if not LOG_ENABLE then
		return
	end
	if arg0 == 'UI_OME_SKILL_CAST_LOG' then
		-- 技能施放日志；
		-- (arg1)dwCaster：技能施放者 (arg2)dwSkillID：技能ID (arg3)dwLevel：技能等级
		-- D.OnSkillCast(arg1, arg2, arg3)
		if D.WillRecID(arg1) then
			D.OnTargetUpdate(arg1)
			D.InsertLog(LOG_TYPE.SYS_MSG_UI_OME_SKILL_CAST_LOG, { arg1, arg2, arg3 })
		end
	elseif arg0 == 'UI_OME_SKILL_CAST_RESPOND_LOG' then
		-- 技能施放结果日志；
		-- (arg1)dwCaster：技能施放者 (arg2)dwSkillID：技能ID
		-- (arg3)dwLevel：技能等级 (arg4)nRespond：见枚举型[[SKILL_RESULT_CODE]]
		-- D.OnSkillCastRespond(arg1, arg2, arg3, arg4)
		if D.WillRecID(arg1) then
			D.OnTargetUpdate(arg1)
			D.InsertLog(LOG_TYPE.SYS_MSG_UI_OME_SKILL_CAST_RESPOND_LOG, { arg1, arg2, arg3, arg4 })
		end
	elseif arg0 == 'UI_OME_SKILL_EFFECT_LOG' then
		-- if not X.IsInArena() then
		-- 技能最终产生的效果（生命值的变化）；
		-- (arg1)dwCaster：施放者 (arg2)dwTarget：目标 (arg3)bReact：是否为反击 (arg4)nType：Effect类型 (arg5)dwID:Effect的ID
		-- (arg6)dwLevel：Effect的等级 (arg7)bCriticalStrike：是否会心 (arg8)nCount：tResultCount数据表中元素个数 (arg9)tResultCount：数值集合
		if D.WillRecID(arg1) or D.WillRecID(arg2) then
			D.OnTargetUpdate(arg1)
			D.OnTargetUpdate(arg2)
			D.InsertLog(LOG_TYPE.SYS_MSG_UI_OME_SKILL_EFFECT_LOG, { arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9 })
		end
	elseif arg0 == 'UI_OME_SKILL_BLOCK_LOG' then
		-- 格挡日志；
		-- (arg1)dwCaster：施放者 (arg2)dwTarget：目标 (arg3)nType：Effect的类型
		-- (arg4)dwID：Effect的ID (arg5)dwLevel：Effect的等级 (arg6)nDamageType：伤害类型，见枚举型[[SKILL_RESULT_TYPE]]
		if D.WillRecID(arg1) or D.WillRecID(arg2) then
			D.OnTargetUpdate(arg1)
			D.OnTargetUpdate(arg2)
			D.InsertLog(LOG_TYPE.SYS_MSG_UI_OME_SKILL_BLOCK_LOG, { arg1, arg2, arg3, arg4, arg5, arg6 })
		end
	elseif arg0 == 'UI_OME_SKILL_SHIELD_LOG' then
		-- 技能被屏蔽日志；
		-- (arg1)dwCaster：施放者 (arg2)dwTarget：目标
		-- (arg3)nType：Effect的类型 (arg4)dwID：Effect的ID (arg5)dwLevel：Effect的等级
		if D.WillRecID(arg1) or D.WillRecID(arg2) then
			D.OnTargetUpdate(arg1)
			D.OnTargetUpdate(arg2)
			D.InsertLog(LOG_TYPE.SYS_MSG_UI_OME_SKILL_SHIELD_LOG, { arg1, arg2, arg3, arg4, arg5 })
		end
	elseif arg0 == 'UI_OME_SKILL_MISS_LOG' then
		-- 技能未命中目标日志；
		-- (arg1)dwCaster：施放者 (arg2)dwTarget：目标
		-- (arg3)nType：Effect的类型 (arg4)dwID：Effect的ID (arg5)dwLevel：Effect的等级
		if D.WillRecID(arg1) or D.WillRecID(arg2) then
			D.OnTargetUpdate(arg1)
			D.OnTargetUpdate(arg2)
			D.InsertLog(LOG_TYPE.SYS_MSG_UI_OME_SKILL_MISS_LOG, { arg1, arg2, arg3, arg4, arg5 })
		end
	elseif arg0 == 'UI_OME_SKILL_HIT_LOG' then
		-- 技能命中目标日志；
		-- (arg1)dwCaster：施放者 (arg2)dwTarget：目标
		-- (arg3)nType：Effect的类型 (arg4)dwID：Effect的ID (arg5)dwLevel：Effect的等级
		if D.WillRecID(arg1) or D.WillRecID(arg2) then
			D.OnTargetUpdate(arg1)
			D.OnTargetUpdate(arg2)
			D.InsertLog(LOG_TYPE.SYS_MSG_UI_OME_SKILL_HIT_LOG, { arg1, arg2, arg3, arg4, arg5 })
		end
	elseif arg0 == 'UI_OME_SKILL_DODGE_LOG' then
		-- 技能被闪避日志；
		-- (arg1)dwCaster：施放者 (arg2)dwTarget：目标
		-- (arg3)nType：Effect的类型 (arg4)dwID：Effect的ID (arg5)dwLevel：Effect的等级
		if D.WillRecID(arg1) or D.WillRecID(arg2) then
			D.OnTargetUpdate(arg1)
			D.OnTargetUpdate(arg2)
			D.InsertLog(LOG_TYPE.SYS_MSG_UI_OME_SKILL_DODGE_LOG, { arg1, arg2, arg3, arg4, arg5 })
		end
	elseif arg0 == 'UI_OME_COMMON_HEALTH_LOG' then
		-- 普通治疗日志；
		-- (arg1)dwCharacterID：承疗玩家ID (arg2)nDeltaLife：增加血量值
		-- D.OnCommonHealth(arg1, arg2)
		if D.WillRecID(arg1) then
			D.OnTargetUpdate(arg1)
			D.InsertLog(LOG_TYPE.SYS_MSG_UI_OME_COMMON_HEALTH_LOG, { arg1, arg2 })
		end
	elseif arg0 == 'UI_OME_DEATH_NOTIFY' then
		-- 死亡日志；
		-- (arg1)dwCharacterID：死亡目标ID (arg2)dwKiller：击杀者ID
		if D.WillRecID(arg1) or D.WillRecID(arg2) then
			D.OnTargetUpdate(arg1)
			D.OnTargetUpdate(arg2)
			D.InsertLog(LOG_TYPE.SYS_MSG_UI_OME_DEATH_NOTIFY, { arg1, arg2 })
		end
	end
end)

-- 系统BUFF监控（数据源）
X.RegisterEvent('BUFF_UPDATE', function()
	-- local owner, bdelete, index, cancancel, id  , stacknum, endframe, binit, level, srcid, isvalid, leftframe
	--     = arg0 , arg1   , arg2 , arg3     , arg4, arg5    , arg6    , arg7 , arg8 , arg9 , arg10  , arg11
	if not LOG_ENABLE then
		return
	end
	-- buff update：
	-- arg0：dwPlayerID，arg1：bDelete，arg2：nIndex，arg3：bCanCancel
	-- arg4：dwBuffID，arg5：nStackNum，arg6：nEndFrame，arg7：？update all?
	-- arg8：nLevel，arg9：dwSkillSrcID
	if D.WillRecID(arg0) then
		D.OnTargetUpdate(arg0)
		D.InsertLog(LOG_TYPE.BUFF_UPDATE, { arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11 })
	end
end)

X.RegisterEvent('PLAYER_ENTER_SCENE', function()
	if not LOG_ENABLE then
		return
	end
	if D.WillRecID(arg0) then
		D.OnTargetUpdate(arg0)
		D.InsertLog(LOG_TYPE.PLAYER_ENTER_SCENE, { arg0 })
	end
end)

X.RegisterEvent('PLAYER_LEAVE_SCENE', function()
	if not LOG_ENABLE then
		return
	end
	if D.WillRecID(arg0) then
		D.OnTargetUpdate(arg0)
		D.InsertLog(LOG_TYPE.PLAYER_LEAVE_SCENE, { arg0 })
	end
end)

X.RegisterEvent('NPC_ENTER_SCENE', function()
	if not LOG_ENABLE then
		return
	end
	if D.WillRecID(arg0) then
		D.OnTargetUpdate(arg0)
		D.InsertLog(LOG_TYPE.NPC_ENTER_SCENE, { arg0 })
	end
end)

X.RegisterEvent('NPC_LEAVE_SCENE', function()
	if not LOG_ENABLE then
		return
	end
	if D.WillRecID(arg0) then
		D.OnTargetUpdate(arg0)
		D.InsertLog(LOG_TYPE.NPC_LEAVE_SCENE, { arg0 })
	end
end)

X.RegisterEvent('DOODAD_ENTER_SCENE', function()
	if not LOG_ENABLE then
		return
	end
	D.OnDoodadUpdate(arg0)
	D.InsertLog(LOG_TYPE.DOODAD_ENTER_SCENE, { arg0 })
end)

X.RegisterEvent('DOODAD_LEAVE_SCENE', function()
	if not LOG_ENABLE then
		return
	end
	D.OnDoodadUpdate(arg0)
	D.InsertLog(LOG_TYPE.DOODAD_LEAVE_SCENE, { arg0 })
end)

-- 系统消息日志
X.RegisterMsgMonitor('MSG_SYS', 'MY_Recount_DS_Everything', function(szChannel, szMsg, nFont, bRich)
	if not LOG_ENABLE then
		return
	end
	local szText = szMsg
	if bRich then
		if X.ContainsEchoMsgHeader(szMsg) then
			return
		end
		szText = X.GetPureText(szMsg)
	end
	szText = szText:gsub('\r', '')
	D.InsertLog(LOG_TYPE.MSG_SYS, { szText, szChannel })
end)

-- 角色喊话日志
X.RegisterEvent('PLAYER_SAY', function()
	if not LOG_ENABLE then
		return
	end
	-- arg0: szContent, arg1: dwTalkerID, arg2: nChannel, arg3: szName, arg4: bOnlyShowBallon
	-- arg5: bSecurity, arg6: bGMAccount, arg7: bCheater, arg8: dwTitleID, arg9: szMsg
	if not IsPlayer(arg1) and D.WillRecID(arg1) then
		local szText = X.GetPureText(arg0)
		if szText and szText ~= '' then
			D.OnTargetUpdate(arg1)
			D.InsertLog(LOG_TYPE.PLAYER_SAY, { szText, arg1, arg2, arg3 })
		end
	end
end)

-- 系统警告框日志
X.RegisterEvent('ON_WARNING_MESSAGE', function()
	if not LOG_ENABLE then
		return
	end
	-- arg0: szWarningType, arg1: szText
	D.InsertLog(LOG_TYPE.ON_WARNING_MESSAGE, { arg0, arg1 })
end)

-- 玩家进入退出战斗日志
X.RegisterEvent('MY_PLAYER_FIGHT_HINT', function()
	if not LOG_ENABLE then
		return
	end
	local dwID, bFight = arg0, arg1
	if not D.WillRecID(dwID) then
		return
	end
	local KObject = X.GetObject(TARGET.PLAYER, dwID)
	local fCurrentLife, fMaxLife, nCurrentMana, nMaxMana = -1, -1, -1, -1
	if KObject then
		fCurrentLife, fMaxLife = X.GetObjectLife(KObject)
		nCurrentMana, nMaxMana = KObject.nCurrentMana, KObject.nMaxMana
	end
	D.OnTargetUpdate(dwID, true)
	D.InsertLog(LOG_TYPE.PLAYER_FIGHT_HINT, { dwID, bFight, fCurrentLife, fMaxLife, nCurrentMana, nMaxMana })
end)

-- NPC 进入退出战斗日志
X.RegisterEvent('MY_NPC_FIGHT_HINT', function()
	if not LOG_ENABLE then
		return
	end
	local dwID, bFight = arg0, arg1
	if not D.WillRecID(dwID) then
		return
	end
	local KObject = X.GetObject(TARGET.NPC, dwID)
	local fCurrentLife, fMaxLife, nCurrentMana, nMaxMana = -1, -1, -1, -1
	if KObject then
		fCurrentLife, fMaxLife = X.GetObjectLife(KObject)
		nCurrentMana, nMaxMana = KObject.nCurrentMana, KObject.nMaxMana
	end
	D.OnTargetUpdate(dwID, true)
	D.InsertLog(LOG_TYPE.NPC_FIGHT_HINT, { dwID, bFight, fCurrentLife, fMaxLife, nCurrentMana, nMaxMana })
end)

-- 上线下线日志
X.RegisterEvent('PARTY_SET_MEMBER_ONLINE_FLAG', function()
	if not LOG_ENABLE then
		return
	end
	-- arg0: dwTeamID, arg1: dwMemberID, arg2: nOnlineFlag
	if not D.WillRecID(arg1) then
		return
	end
	D.OnTargetUpdate(arg1)
	D.InsertLog(LOG_TYPE.PARTY_SET_MEMBER_ONLINE_FLAG, { arg0, arg1, arg2 })
end)

-- 进出战斗暂离记录
X.RegisterEvent('MY_RECOUNT_NEW_FIGHT', function() -- 开战扫描队友 记录开战就死掉/掉线的人
	if not LOG_ENABLE then
		return
	end
	local team = GetClientTeam()
	local me = GetClientPlayer()
	if not team or not me or (not me.IsInParty() and not me.IsInRaid()) then
		return
	end
	for _, dwID in ipairs(team.GetTeamMemberList()) do
		local info = team.GetMemberInfo(dwID)
		if info and D.WillRecID(dwID) then
			D.OnTargetUpdate(dwID)
			if not info.bIsOnLine then
				D.InsertLog(LOG_TYPE.PARTY_SET_MEMBER_ONLINE_FLAG, { team.dwTeamID, dwID, 0 })
			elseif info.bDeathFlag then
				D.InsertLog(LOG_TYPE.SYS_MSG_UI_OME_DEATH_NOTIFY, { dwID, nil })
			end
		end
	end
end)

-- 中途有人进队 补上暂离记录
X.RegisterEvent('PARTY_ADD_MEMBER', function()
	if not LOG_ENABLE then
		return
	end
	-- arg0: dwTeamID, arg1: dwMemberID, arg2: nGroupIndex
	if D.WillRecID(arg1) then
		D.OnTargetUpdate(arg1)
		D.InsertLog(LOG_TYPE.PARTY_ADD_MEMBER, { arg0, arg1, arg2 })
	end
end)

X.RegisterUserSettingsUpdate('@@INIT@@', 'MY_CombatLogs', function()
	D.bReady = true
	D.UpdateEnable()
end)

function D.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nLH, nX, nY, nLFY)
	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 200,
		text = _L['MY_CombatLogs'],
		checked = MY_CombatLogs.bEnable,
		oncheck = function(bChecked)
			MY_CombatLogs.bEnable = bChecked
		end,
	}):AutoWidth():Width() + 5

	nX = nX + ui:Append('WndButton', {
		x = nX, y = nY, w = 25, h = 25,
		buttonstyle = 'OPTION',
		autoenable = function() return MY_CombatLogs.bEnable end,
		menu = function()
			local menu = {}
			table.insert(menu, {
				szOption = _L['Only in dungeon'],
				bCheck = true,
				bChecked = MY_CombatLogs.bOnlyDungeon,
				fnAction = function()
					MY_CombatLogs.bOnlyDungeon = not MY_CombatLogs.bOnlyDungeon
				end,
			})
			table.insert(menu, {
				szOption = _L['Only self related'],
				bCheck = true,
				bChecked = MY_CombatLogs.bOnlySelf,
				fnAction = function()
					MY_CombatLogs.bOnlySelf = not MY_CombatLogs.bOnlySelf
				end,
			})
			local m0 = { szOption = _L['Max history'] }
			for _, i in ipairs({10, 20, 30, 50, 100, 200, 300, 500, 1000, 2000, 5000}) do
				table.insert(m0, {
					szOption = tostring(i),
					fnAction = function()
						MY_CombatLogs.nMaxHistory = i
					end,
					bCheck = true,
					bMCheck = true,
					bChecked = MY_CombatLogs.nMaxHistory == i,
				})
			end
			table.insert(menu, m0)
			local m0 = { szOption = _L['Min fight time'] }
			for _, i in ipairs({10, 20, 30, 60, 90, 120, 180, 240}) do
				table.insert(m0, {
					szOption = _L('%s second(s)', i),
					fnAction = function()
						MY_CombatLogs.nMinFightTime = i
					end,
					bCheck = true,
					bMCheck = true,
					bChecked = MY_CombatLogs.nMinFightTime == i,
				})
			end
			table.insert(menu, m0)
			table.insert(menu, {
				szOption = _L['Show data files'],
				fnAction = function()
					local szRoot = X.GetAbsolutePath(DS_ROOT)
					X.OpenFolder(szRoot)
					UI.OpenTextEditor(szRoot)
				end,
			})
			return menu
		end,
	}):AutoWidth():Width() + 5

	nLFY = nY + nLH
	return nX, nY, nLFY
end


-- Global exports
do
local settings = {
	name = 'MY_CombatLogs',
	exports = {
		{
			fields = {
				'OnPanelActivePartial',
			},
			root = D,
		},
		{
			fields = {
				'bEnable',
				'nMaxHistory',
				'nMinFightTime',
				'bOnlyDungeon',
				'bOnlySelf',
			},
			root = O,
		},
	},
	imports = {
		{
			fields = {
				'bEnable',
				'nMaxHistory',
				'nMinFightTime',
				'bOnlyDungeon',
				'bOnlySelf',
			},
			triggers = {
				bEnable      = D.UpdateEnable,
				bOnlyDungeon = D.UpdateEnable,
				bOnlySelf    = D.UpdateEnable,
			},
			root = O,
		},
	},
}
MY_CombatLogs = X.CreateModule(settings)
end
