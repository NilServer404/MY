--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : 焦点列表
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@derzh.com)
-- @copyright: Copyright (c) 2013 EMZ Kingsoft Co., Ltd.
--------------------------------------------------------
--------------------------------------------------------------------------------------------------------
-- these global functions are accessed all the time by the event handler
-- so caching them is worth the effort
--------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local ipairs, pairs, next, pcall = ipairs, pairs, next, pcall
local sub, len, format, rep = string.sub, string.len, string.format, string.rep
local find, byte, char, gsub = string.find, string.byte, string.char, string.gsub
local type, tonumber, tostring = type, tonumber, tostring
local huge, pi, random, abs = math.huge, math.pi, math.random, math.abs
local min, max, floor, ceil = math.min, math.max, math.floor, math.ceil
local pow, sqrt, sin, cos, tan = math.pow, math.sqrt, math.sin, math.cos, math.tan
local insert, remove, concat, sort = table.insert, table.remove, table.concat, table.sort
local pack, unpack = table.pack or function(...) return {...} end, table.unpack or unpack
-- jx3 apis caching
local wsub, wlen, wfind = wstring.sub, wstring.len, wstring.find
local GetTime, GetLogicFrameCount = GetTime, GetLogicFrameCount
local GetClientTeam, UI_GetClientPlayerID = GetClientTeam, UI_GetClientPlayerID
local GetClientPlayer, GetPlayer, GetNpc, IsPlayer = GetClientPlayer, GetPlayer, GetNpc, IsPlayer
local MY, UI = MY, MY.UI
local var2str, str2var, clone, empty, ipairs_r = MY.var2str, MY.str2var, MY.clone, MY.empty, MY.ipairs_r
local spairs, spairs_r, sipairs, sipairs_r = MY.spairs, MY.spairs_r, MY.sipairs, MY.sipairs_r
local GetPatch, ApplyPatch = MY.GetPatch, MY.ApplyPatch
local Get, Set, RandomChild, GetTraceback = MY.Get, MY.Set, MY.RandomChild, MY.GetTraceback
local IsArray, IsDictionary, IsEquals = MY.IsArray, MY.IsDictionary, MY.IsEquals
local IsNil, IsBoolean, IsNumber, IsFunction = MY.IsNil, MY.IsBoolean, MY.IsNumber, MY.IsFunction
local IsEmpty, IsString, IsTable, IsUserdata = MY.IsEmpty, MY.IsString, MY.IsTable, MY.IsUserdata
local MENU_DIVIDER, EMPTY_TABLE, XML_LINE_BREAKER = MY.MENU_DIVIDER, MY.EMPTY_TABLE, MY.XML_LINE_BREAKER
--------------------------------------------------------------------------------------------------------
local CHANGGE_REAL_SHADOW_TPLID = 46140 -- 清绝歌影 的主体影子
local INI_PATH = MY.GetAddonInfo().szRoot .. 'MY_Focus/ui/MY_Focus.ini'
local _L = MY.LoadLangPack(MY.GetAddonInfo().szRoot .. 'MY_Focus/lang/')
local FOCUS_LIST = {}
local l_tTempFocusList = {
	[TARGET.PLAYER] = {},   -- dwID
	[TARGET.NPC]    = {},   -- dwTemplateID
	[TARGET.DOODAD] = {},   -- dwTemplateID
}
local l_dwLockType, l_dwLockID, l_lockInDisplay
local O, D = {}, { PASSPHRASE = {111, 198, 5} }
O.bEnable            = false -- 是否启用
O.bMinimize          = false -- 是否最小化
O.bFocusINpc         = true  -- 焦点重要NPC
O.bFocusFriend       = false -- 焦点附近好友
O.bFocusTong         = false -- 焦点帮会成员
O.bOnlyPublicMap     = true  -- 仅在公共地图焦点好友帮会成员
O.bSortByDistance    = false -- 优先焦点近距离目标
O.bFocusEnemy        = false -- 焦点敌对玩家
O.bFocusAnmerkungen  = true  -- 焦点记在小本本里的玩家
O.bAutoHide          = true  -- 无焦点时隐藏
O.nMaxDisplay        = 5     -- 最大显示数量
O.bAutoFocus         = true  -- 启用默认焦点
O.bEmbeddedFocus     = true  -- 启用内嵌默认焦点
O.bHideDeath         = false -- 隐藏死亡目标
O.bDisplayKungfuIcon = false -- 显示心法图标
O.bFocusJJCParty     = false -- 焦竞技场队友
O.bFocusJJCEnemy     = true  -- 焦竞技场敌队
O.bShowTarget        = false -- 显示目标目标
O.szDistanceType     = 'global' -- 坐标距离计算方式
O.bTraversal         = false -- 遍历焦点列表
O.bHealHelper        = false -- 辅助治疗模式
O.bEnableSceneNavi   = false -- 场景追踪点
O.fScaleX            = 1     -- 缩放比例
O.fScaleY            = 1     -- 缩放比例
O.tAutoFocus = {}    -- 默认焦点
O.tFocusList = {     -- 永久焦点
	[TARGET.PLAYER] = {},   -- dwID
	[TARGET.NPC]    = {},   -- dwTemplateID
	[TARGET.DOODAD] = {},   -- dwTemplateID
}
O.anchor = { x=-300, y=220, s='TOPRIGHT', r='TOPRIGHT' } -- 默认坐标

local function FormatAutoFocusData(data)
	local ds = {
		szMethod = 'NAME',
		szPattern = '',
		szDisplay = '',
		dwMapID = -1,
		tType = {
			bAll = true,
			[TARGET.NPC] = false,
			[TARGET.PLAYER] = false,
			[TARGET.DOODAD] = false,
		},
		tRelation = {
			bAll = true,
			bEnemy = false,
			bAlly = false,
		},
		tLife = {
			bEnable = false,
			szOperator = '>',
			nValue = 0,
		},
		nMaxDistance = 0,
	}
	return MY.FormatDataStructure(data, ds)
end
function D.IsShielded() return MY.IsShieldedVersion() and MY.IsInShieldedMap() end
function D.IsEnabled() return O.bEnable and not D.IsShielded() end

function D.LoadConfig()
	local config = MY.LoadLUAData({'config/focus.jx3dat', MY_DATA_PATH.ROLE}) or {}
	for k, v in pairs(config) do
		O[k] = v
	end
end

function D.SaveConfig()
	MY.SaveLUAData({'config/focus.jx3dat', MY_DATA_PATH.ROLE}, O)
end

function D.SetScale(fScaleX, fScaleY)
	O.fScaleX = fScaleX
	O.fScaleY = fScaleY
	FireUIEvent('MY_FOCUS_SCALE_UPDATE')
end

function D.SetMaxDisplay(nMaxDisplay)
	O.nMaxDisplay = nMaxDisplay
	FireUIEvent('MY_FOCUS_MAX_DISPLAY_UPDATE')
end

function D.SetAutoHide(bAutoHide)
	O.bAutoHide = bAutoHide
	FireUIEvent('MY_FOCUS_AUTO_HIDE_UPDATE')
end

function D.GetAllFocusPattern()
	return clone(O.tAutoFocus)
end

-- 添加、修改默认焦点
function D.SetFocusPattern(szPattern, tData)
	local nIndex
	szPattern = MY.TrimString(szPattern)
	for i, v in ipairs_r(O.tAutoFocus) do
		if v.szPattern == szPattern then
			nIndex = i
			remove(O.tAutoFocus, i)
		end
	end
	-- 格式化数据
	if not IsTable(tData) then
		tData = { szPattern = szPattern }
	end
	tData = FormatAutoFocusData(tData)
	-- 更新焦点列表
	if nIndex then
		insert(O.tAutoFocus, nIndex, tData)
	else
		insert(O.tAutoFocus, tData)
	end
	D.RescanNearby()
	return tData
end

-- 删除默认焦点
function D.RemoveFocusPattern(szPattern)
	local p
	for i = #O.tAutoFocus, 1, -1 do
		if O.tAutoFocus[i].szPattern == szPattern then
			p = O.tAutoFocus[i]
			remove(O.tAutoFocus, i)
			break
		end
	end
	if not p then
		return
	end
	-- 刷新UI
	if p.szMethod == 'NAME' then
		-- 全字符匹配模式：检查是否在永久焦点中 没有则删除Handle （节约性能）
		for i = #FOCUS_LIST, 1, -1 do
			local p = FOCUS_LIST[i]
			local KObject = MY.GetObject(p.dwType, p.dwID)
			local dwTemplateID = p.dwType == TARGET.PLAYER and p.dwID or KObject.dwTemplateID
			if KObject and MY.GetObjectName(KObject, 'never') == szPattern
			and not l_tTempFocusList[p.dwType][p.dwID]
			and not O.tFocusList[p.dwType][dwTemplateID] then
				D.OnObjectLeaveScene(p.dwType, p.dwID)
			end
		end
	else
		-- 其他模式：重绘焦点列表
		D.RescanNearby()
	end
end

-- 添加ID焦点
function D.SetFocusID(dwType, dwID, bSave)
	dwType, dwID = tonumber(dwType), tonumber(dwID)
	if bSave then
		local KObject = MY.GetObject(dwType, dwID)
		local dwTemplateID = dwType == TARGET.PLAYER and dwID or KObject.dwTemplateID
		if O.tFocusList[dwType][dwTemplateID] then
			return
		end
		O.tFocusList[dwType][dwTemplateID] = true
		D.RescanNearby()
	else
		if l_tTempFocusList[dwType][dwID] then
			return
		end
		l_tTempFocusList[dwType][dwID] = true
		D.OnObjectEnterScene(dwType, dwID)
	end
end

-- 删除ID焦点
function D.RemoveFocusID(dwType, dwID)
	dwType, dwID = tonumber(dwType), tonumber(dwID)
	if l_tTempFocusList[dwType][dwID] then
		l_tTempFocusList[dwType][dwID] = nil
		D.OnObjectLeaveScene(dwType, dwID)
	end
	local KObject = MY.GetObject(dwType, dwID)
	local dwTemplateID = dwType == TARGET.PLAYER and dwID or KObject.dwTemplateID
	if O.tFocusList[dwType][dwTemplateID] then
		O.tFocusList[dwType][dwTemplateID] = nil
		D.RescanNearby()
	end
end

-- 清空焦点列表
function D.ClearFocus()
	FOCUS_LIST = {}
	FireUIEvent('MY_FOCUS_UPDATE')
end

-- 重新扫描附近对象更新焦点列表（只增不减）
function D.ScanNearby()
	for _, dwID in ipairs(MY.GetNearPlayerID()) do
		D.OnObjectEnterScene(TARGET.PLAYER, dwID)
	end
	for _, dwID in ipairs(MY.GetNearNpcID()) do
		D.OnObjectEnterScene(TARGET.NPC, dwID)
	end
	for _, dwID in ipairs(MY.GetNearDoodadID()) do
		D.OnObjectEnterScene(TARGET.DOODAD, dwID)
	end
end

-- 重新扫描附近焦点
function D.RescanNearby()
	D.ClearFocus()
	D.ScanNearby()
end

function D.GetEligibleRule(tRules, dwMapID, dwType, dwID, dwTemplateID, szName, szTong)
	for _, v in ipairs(tRules) do
		if (v.tType.bAll or v.tType[dwType])
		and (v.dwMapID == -1 or v.dwMapID == dwMapID)
		and (
			(v.szMethod == 'NAME' and v.szPattern == szName)
			or (v.szMethod == 'NAME_PATT' and szName:find(v.szPattern))
			or (v.szMethod == 'ID' and tonumber(v.szPattern) == dwID)
			or (v.szMethod == 'TEMPLATE_ID' and tonumber(v.szPattern) == dwTemplateID)
			or (v.szMethod == 'TONG_NAME' and v.szPattern == szTong)
			or (v.szMethod == 'TONG_NAME_PATT' and szTong:find(v.szPattern))
		) then
			return v
		end
	end
end

function D.LoadEmbeddedRule()
	-- auto generate embedded data
	local DAT_ROOT = 'MY_Resource/data/focus/'
	local SRC_ROOT = MY.FormatPath(MY.GetAddonInfo().szRoot .. '!src-dist/dat/' .. DAT_ROOT)
	local DST_ROOT = MY.FormatPath(MY.GetAddonInfo().szRoot .. DAT_ROOT)
	for _, szFile in ipairs(CPath.GetFileList(SRC_ROOT)) do
		MY.Sysmsg(_L['Encrypt and compressing: '] .. DAT_ROOT .. szFile)
		local data = LoadDataFromFile(SRC_ROOT .. szFile)
		if IsEncodedData(data) then
			data = DecodeData(data)
		end
		data = EncodeData(data, true, true)
		SaveDataToFile(data, DST_ROOT .. szFile, D.PASSPHRASE)
	end
	-- load embedded data
	local function LoadConfigData(szPath)
		local szPath = MY.GetAddonInfo().szRoot .. szPath
		return MY.LoadLUAData(szPath, { passphrase = D.PASSPHRASE }) or MY.LoadLUAData(szPath) or {}
	end
	-- load and format data
	local data = LoadConfigData('MY_Resource/data/focus/$lang.jx3dat') or {}
	for i, v in ipairs(data) do
		data[i] = FormatAutoFocusData(v)
	end
	D.EMBEDDED_FOCUS = data
end

-- 对象进入视野
function D.OnObjectEnterScene(dwType, dwID, nRetryCount)
	if nRetryCount and nRetryCount > 5 then
		return
	end
	if not D.EMBEDDED_FOCUS then
		return MY.DelayCall(5000, function() D.OnObjectEnterScene(dwType, dwID) end)
	end
	local me = GetClientPlayer()
	local KObject = MY.GetObject(dwType, dwID)
	if not KObject then
		return
	end

	local szName = MY.GetObjectName(KObject, 'never')
	-- 解决玩家刚进入视野时名字为空的问题
	if (dwType == TARGET.PLAYER and not szName) or not me then -- 解决自身刚进入场景的时候的问题
		MY.DelayCall(300, function()
			D.OnObjectEnterScene(dwType, dwID, (nRetryCount or 0) + 1)
		end)
	else-- if szName then -- 判断是否需要焦点
		if not szName then
			szName = MY.GetObjectName(KObject, 'auto')
		end
		local bFocus, bDeletable = false, true
		local szVia, tRule = '', nil
		local dwMapID = me.GetMapID()
		local dwTemplateID, szTong = -1, ''
		if dwType == TARGET.PLAYER then
			if KObject.dwTongID ~= 0 then
				szTong = GetTongClient().ApplyGetTongName(KObject.dwTongID, 253)
				if not szTong or szTong == '' then -- 解决目标刚进入场景的时候帮会获取不到的问题
					MY.DelayCall(300, function()
						D.OnObjectEnterScene(dwType, dwID, (nRetryCount or 0) + 1)
					end)
				end
			end
		else
			dwTemplateID = KObject.dwTemplateID
		end
		-- 判断临时焦点
		if l_tTempFocusList[dwType][dwID] then
			bFocus = true
			bDeletable = true
			szVia = _L['Temp focus']
		end
		-- 判断永久焦点
		if not bFocus then
			local dwTemplateID = dwType == TARGET.PLAYER and dwID or KObject.dwTemplateID
			if O.tFocusList[dwType][dwTemplateID]
			and not (
				dwType == TARGET.NPC
				and dwTemplateID == CHANGGE_REAL_SHADOW_TPLID
				and IsEnemy(UI_GetClientPlayerID(), dwID)
				and MY.IsShieldedVersion()
			) then
				bFocus = true
				bDeletable = true
				szVia = _L['Static focus']
			end
		end
		-- 判断默认焦点
		if not bFocus and O.bAutoFocus then
			tRule = D.GetEligibleRule(O.tAutoFocus, dwMapID, dwType, dwID, dwTemplateID, szName, szTong)
			if tRule then
				bFocus = true
				bDeletable = false
				szVia = _L['Auto focus'] .. ' ' .. tRule.szPattern
			end
		end
		-- 判断内嵌默认焦点
		if not bFocus and O.bEmbeddedFocus then
			tRule = D.GetEligibleRule(D.EMBEDDED_FOCUS, dwMapID, dwType, dwID, dwTemplateID, szName, szTong)
			if tRule then
				bFocus = true
				bDeletable = false
				szVia = _L['Embedded focus']
			end
		end

		-- 判断竞技场
		if not bFocus then
			if MY.IsInArena() or MY.IsInPubg() or MY.IsInZombieMap() then
				if dwType == TARGET.PLAYER then
					if O.bFocusJJCEnemy and O.bFocusJJCParty then
						bFocus = true
						bDeletable = false
						szVia = _L['JJC focus']
					elseif O.bFocusJJCParty then
						if not IsEnemy(UI_GetClientPlayerID(), dwID) then
							bFocus = true
							bDeletable = false
							szVia = _L['JJC focus party']
						end
					elseif O.bFocusJJCEnemy then
						if IsEnemy(UI_GetClientPlayerID(), dwID) then
							bFocus = true
							bDeletable = false
							szVia = _L['JJC focus enemy']
						end
					end
				elseif dwType == TARGET.NPC then
					if O.bFocusJJCParty
					and KObject.dwTemplateID == CHANGGE_REAL_SHADOW_TPLID
					and not (IsEnemy(UI_GetClientPlayerID(), dwID) and MY.IsShieldedVersion()) then
						D.OnRemoveFocus(TARGET.PLAYER, KObject.dwEmployer)
						bFocus = true
						bDeletable = false
						szVia = _L['JJC focus party']
					end
				end
			else
				if not O.bOnlyPublicMap or (not MY.IsInBattleField() and not MY.IsInDungeon() and not MY.IsInArena()) then
					-- 判断好友
					if dwType == TARGET.PLAYER
					and O.bFocusFriend
					and MY.GetFriend(dwID) then
						bFocus = true
						bDeletable = false
						szVia = _L['Friend focus']
					end
					-- 判断同帮会
					if dwType == TARGET.PLAYER
					and O.bFocusTong
					and dwID ~= MY.GetClientInfo().dwID
					and MY.GetTongMember(dwID) then
						bFocus = true
						bDeletable = false
						szVia = _L['Tong member focus']
					end
				end
				-- 判断敌对玩家
				if dwType == TARGET.PLAYER
				and O.bFocusEnemy
				and IsEnemy(UI_GetClientPlayerID(), dwID) then
					bFocus = true
					bDeletable = false
					szVia = _L['Enemy focus']
				end
			end
		end

		-- 判断重要NPC
		if not bFocus and O.bFocusINpc
		and dwType == TARGET.NPC
		and MY.IsImportantNpc(me.GetMapID(), KObject.dwTemplateID) then
			bFocus = true
			bDeletable = false
			szVia = _L['Important npc focus']
		end

		-- 判断小本本
		if not bFocus and O.bFocusAnmerkungen
		and dwType == TARGET.PLAYER
		and MY_Anmerkungen.GetPlayerNote(dwID) then
			bFocus = true
			bDeletable = false
			szVia = _L['Anmerkungen']
		end

		-- 判断屏蔽的NPC
		if bFocus and dwType == TARGET.NPC and MY.IsShieldedNpc(dwTemplateID) and MY.IsShieldedVersion() then
			bFocus = false
			bDeletable = false
		end

		-- 加入焦点
		if bFocus then
			D.OnSetFocus(dwType, dwID, szName, bDeletable, szVia, tRule)
		end
	end
end

-- 对象离开视野
function D.OnObjectLeaveScene(dwType, dwID)
	local KObject = MY.GetObject(dwType, dwID)
	if KObject then
		if dwType == TARGET.NPC then
			if O.bFocusJJCParty
			and KObject.dwTemplateID == CHANGGE_REAL_SHADOW_TPLID
			and MY.IsInArena() and not (IsEnemy(UI_GetClientPlayerID(), dwID) and MY.IsShieldedVersion()) then
				D.OnSetFocus(TARGET.PLAYER, KObject.dwEmployer, MY.GetObjectName(KObject, 'never'), false, _L['JJC focus party'])
			end
		end
	end
	D.OnRemoveFocus(dwType, dwID)
end

-- 目标加入焦点列表
function D.OnSetFocus(dwType, dwID, szName, bDeletable, szVia, tRule)
	local nIndex
	for i, p in ipairs(FOCUS_LIST) do
		if p.dwType == dwType and p.dwID == dwID then
			nIndex = i
			break
		end
	end
	if not nIndex then
		table.insert(FOCUS_LIST, {
			dwType = dwType,
			dwID = dwID,
			szName = szName,
			szVia = szVia,
			tRule = tRule,
			bDeletable = bDeletable,
		})
		nIndex = #FOCUS_LIST
	end
	FireUIEvent('MY_FOCUS_UPDATE')
end

-- 目标移除焦点列表
function D.OnRemoveFocus(dwType, dwID)
	-- 从列表数据中删除
	for i = #FOCUS_LIST, 1, -1 do
		local p = FOCUS_LIST[i]
		if p.dwType == dwType and p.dwID == dwID then
			table.remove(FOCUS_LIST, i)
			break
		end
	end
	FireUIEvent('MY_FOCUS_UPDATE')
end

-- 排序
function D.SortFocus(fn)
	local p = GetClientPlayer()
	fn = fn or function(p1, p2)
		p1 = MY.GetObject(p1.dwType, p1.dwID)
		p2 = MY.GetObject(p2.dwType, p2.dwID)
		if p1 and p2 then
			return pow(p.nX - p1.nX, 2) + pow(p.nY - p1.nY, 2) < pow(p.nX - p2.nX, 2) + pow(p.nY - p2.nY, 2)
		end
		return true
	end
	table.sort(FOCUS_LIST, fn)
end

-- 获取焦点列表
function D.GetFocusList()
	local t = {}
	for _, v in ipairs(FOCUS_LIST) do
		table.insert(t, v)
	end
	return t
end

-- 获取当前显示的焦点列表
function D.GetDisplayList()
	local t = {}
	local me = GetClientPlayer()
	if not D.IsShielded() and me then
		for _, p in ipairs(FOCUS_LIST) do
			if #t >= O.nMaxDisplay then
				break
			end
			local KObject, bFocus = MY.GetObject(p.dwType, p.dwID), true
			if not KObject then
				bFocus = false
			end
			if bFocus and O.bHideDeath then
				if p.dwType == TARGET.NPC or p.dwType == TARGET.PLAYER then
					bFocus = KObject.nMoveState ~= MOVE_STATE.ON_DEATH
				else--if p.dwType == TARGET.DOODAD then
					bFocus = KObject.nKind ~= DOODAD_KIND.CORPSE
				end
			end
			if bFocus and p.tRule then
				if bFocus and p.tRule.tLife.bEnable
				and not MY.JudgeOperator(p.tRule.tLife.szOperator, KObject.nCurrentLife / KObject.nMaxLife * 100, p.tRule.tLife.nValue) then
					bFocus = false
				end
				if bFocus and p.tRule.nMaxDistance ~= 0
				and MY.GetDistance(me, KObject, O.szDistanceType) > p.tRule.nMaxDistance then
					bFocus = false
				end
				if bFocus and not p.tRule.tRelation.bAll then
					if MY.IsEnemy(me.dwID, KObject.dwID) then
						bFocus = p.tRule.tRelation.bEnemy
					else
						bFocus = p.tRule.tRelation.bAlly
					end
				end
			end
			if bFocus then
				insert(t, p)
			end
		end
	end
	return t
end

function D.GetTargetMenu(dwType, dwID)
	return {{
		szOption = _L['add to temp focus list'],
		fnAction = function()
			if not O.bEnable then
				O.bEnable = true
				MY_Focus.Open()
			end
			D.SetFocusID(dwType, dwID)
		end,
	}, {
		szOption = _L['add to static focus list'],
		fnAction = function()
			if not O.bEnable then
				O.bEnable = true
				MY_Focus.Open()
			end
			D.SetFocusID(dwType, dwID, true)
		end,
	}}
end

do
local function onInit()
	-- 加载设置项数据
	D.LoadConfig()
	-- 密码生成
	local k = char(80, 65, 83, 83, 80, 72, 82, 65, 83, 69)
	if IsTable(D[k]) then
		for i = 0, 50 do
			for j, v in ipairs({ 23, 112, 234, 156 }) do
				insert(D[k], (i * j * ((31 * v) % 256)) % 256)
			end
		end
		D[k] = char(unpack(D[k]))
	end
	-- 用户自定义默认焦点
	if not O.tAutoFocus then
		O.tAutoFocus = {}
	end
	for i, v in ipairs(O.tAutoFocus) do
		if IsString(v) then
			v = { szPattern = v }
		end
		O.tAutoFocus[i] = FormatAutoFocusData(v)
	end
	-- 永久焦点
	if not O.tFocusList then
		O.tFocusList = {}
	end
	for _, dwType in ipairs({TARGET.PLAYER, TARGET.NPC, TARGET.DOODAD}) do
		if not O.tFocusList[dwType] then
			O.tFocusList[dwType] = {}
		end
	end
	-- 内嵌默认焦点
	D.LoadEmbeddedRule()
	D.RescanNearby()
end
MY.RegisterInit('MY_Focus', onInit)

local function onExit()
	D.SaveConfig()
end
MY.RegisterExit('MY_Focus', onExit)
end

do
local function onMenu()
	local dwType, dwID = GetClientPlayer().GetTarget()
	return D.GetTargetMenu(dwType, dwID)
end
MY.RegisterTargetAddonMenu('MY_Focus', onMenu)
end

do
local function onHotKey()
	local dwType, dwID = MY.GetTarget()
	local aList = D.GetDisplayList()
	local t = aList[1]
	if not t then
		return
	end
	for i, p in ipairs(aList) do
		if p.dwType == dwType and p.dwID == dwID then
			t = aList[i + 1] or t
		end
	end
	MY.SetTarget(t.dwType, t.dwID)
end
MY.RegisterHotKey('MY_Focus_LoopTarget', _L['Loop target in focus'], onHotKey)
end

MY.RegisterTutorial({
	szKey = 'MY_Focus',
	szMessage = _L['Would you like to use MY focus?'],
	fnRequire = function() return not O.bEnable end,
	{
		szOption = _L['Use'],
		bDefault = true,
		fnAction = function()
			O.bEnable = true
			MY_Focus.Open()
			MY.RedrawTab('MY_Focus')
		end,
	},
	{
		szOption = _L['Not use'],
		fnAction = function()
			O.bEnable = false
			MY_Focus.Close()
			MY.RedrawTab('MY_Focus')
		end,
	},
})

-- Global exports
do
local settings = {
	exports = {
		{
			fields = {
				bEnable = true,
				bMinimize = true,
				bFocusINpc = true,
				bFocusFriend = true,
				bFocusTong = true,
				bOnlyPublicMap = true,
				bSortByDistance = true,
				bFocusEnemy = true,
				bFocusAnmerkungen = true,
				bAutoHide = true,
				nMaxDisplay = true,
				bAutoFocus = true,
				bEmbeddedFocus = true,
				bHideDeath = true,
				bDisplayKungfuIcon = true,
				bFocusJJCParty = true,
				bFocusJJCEnemy = true,
				bShowTarget = true,
				szDistanceType = true,
				bTraversal = true,
				bHealHelper = true,
				bEnableSceneNavi = true,
				anchor = true,
				fScaleX = true,
				fScaleY = true,
			},
			root = O,
		},
		{
			fields = {
				GetTargetMenu      = D.GetTargetMenu     ,
				IsShielded         = D.IsShielded        ,
				RescanNearby       = D.RescanNearby      ,
				IsEnabled          = D.IsEnabled         ,
				GetAllFocusPattern = D.GetAllFocusPattern,
				SetFocusPattern    = D.SetFocusPattern   ,
				SetAutoHide        = D.SetAutoHide       ,
				GetDisplayList     = D.GetDisplayList    ,
				OnObjectEnterScene = D.OnObjectEnterScene,
				OnObjectLeaveScene = D.OnObjectLeaveScene,
				RemoveFocusID      = D.RemoveFocusID     ,
				SortFocus          = D.SortFocus         ,
			},
		},
	},
	imports = {
		{
			fields = {
				bEnable = true,
				bMinimize = true,
				bFocusINpc = true,
				bFocusFriend = true,
				bFocusTong = true,
				bOnlyPublicMap = true,
				bSortByDistance = true,
				bFocusEnemy = true,
				bFocusAnmerkungen = true,
				bAutoHide = true,
				nMaxDisplay = true,
				bAutoFocus = true,
				bEmbeddedFocus = true,
				bHideDeath = true,
				bDisplayKungfuIcon = true,
				bFocusJJCParty = true,
				bFocusJJCEnemy = true,
				bShowTarget = true,
				szDistanceType = true,
				bTraversal = true,
				bHealHelper = true,
				bEnableSceneNavi = true,
				anchor = true,
				fScaleX = true,
				fScaleY = true,
				tAutoFocus = true,
				tFocusList = true,
			},
			triggers = {
				bEnable = D.SaveConfig,
				bMinimize = D.SaveConfig,
				bFocusINpc = D.SaveConfig,
				bFocusFriend = D.SaveConfig,
				bFocusTong = D.SaveConfig,
				bOnlyPublicMap = D.SaveConfig,
				bSortByDistance = D.SaveConfig,
				bFocusEnemy = D.SaveConfig,
				bFocusAnmerkungen = D.SaveConfig,
				bAutoHide = D.SaveConfig,
				nMaxDisplay = D.SaveConfig,
				bAutoFocus = D.SaveConfig,
				bEmbeddedFocus = D.SaveConfig,
				bHideDeath = D.SaveConfig,
				bDisplayKungfuIcon = D.SaveConfig,
				bFocusJJCParty = D.SaveConfig,
				bFocusJJCEnemy = D.SaveConfig,
				bShowTarget = D.SaveConfig,
				szDistanceType = D.SaveConfig,
				bTraversal = D.SaveConfig,
				bHealHelper = D.SaveConfig,
				bEnableSceneNavi = D.SaveConfig,
				anchor = D.SaveConfig,
				fScaleX = D.SaveConfig,
				fScaleY = D.SaveConfig,
				tAutoFocus = D.SaveConfig,
				tFocusList = D.SaveConfig,
			},
			root = O,
		},
	},
}
MY_Focus = MY.GeneGlobalNS(settings)
end
