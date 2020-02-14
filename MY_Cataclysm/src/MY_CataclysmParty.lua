--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : 团队面板小队界面
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@derzh.com)
-- @copyright: Copyright (c) 2013 EMZ Kingsoft Co., Ltd.
--------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-- these global functions are accessed all the time by the event handler
-- so caching them is worth the effort
-----------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local ipairs, pairs, next, pcall, select = ipairs, pairs, next, pcall, select
local sub, len, format, rep = string.sub, string.len, string.format, string.rep
local find, byte, char, gsub = string.find, string.byte, string.char, string.gsub
local type, tonumber, tostring = type, tonumber, tostring
local HUGE, PI, random, abs = math.huge, math.pi, math.random, math.abs
local min, max, floor, ceil = math.min, math.max, math.floor, math.ceil
local pow, sqrt, sin, cos, tan, atan = math.pow, math.sqrt, math.sin, math.cos, math.tan, math.atan
local insert, remove, concat, sort = table.insert, table.remove, table.concat, table.sort
local pack, unpack = table.pack or function(...) return {...} end, table.unpack or unpack
-- jx3 apis caching
local wsub, wlen, wfind, wgsub = wstring.sub, wstring.len, wstring.find, StringReplaceW
local GetTime, GetLogicFrameCount, GetCurrentTime = GetTime, GetLogicFrameCount, GetCurrentTime
local GetClientTeam, UI_GetClientPlayerID = GetClientTeam, UI_GetClientPlayerID
local GetClientPlayer, GetPlayer, GetNpc, IsPlayer = GetClientPlayer, GetPlayer, GetNpc, IsPlayer
local LIB = MY
local UI, DEBUG_LEVEL, PATH_TYPE, PACKET_INFO = LIB.UI, LIB.DEBUG_LEVEL, LIB.PATH_TYPE, LIB.PACKET_INFO
local spairs, spairs_r, sipairs, sipairs_r = LIB.spairs, LIB.spairs_r, LIB.sipairs, LIB.sipairs_r
local ipairs_r, count_c, pairs_c, ipairs_c = LIB.ipairs_r, LIB.count_c, LIB.pairs_c, LIB.ipairs_c
local IsNil, IsBoolean, IsUserdata, IsFunction = LIB.IsNil, LIB.IsBoolean, LIB.IsUserdata, LIB.IsFunction
local IsString, IsTable, IsArray, IsDictionary = LIB.IsString, LIB.IsTable, LIB.IsArray, LIB.IsDictionary
local IsNumber, IsHugeNumber, IsEmpty, IsEquals = LIB.IsNumber, LIB.IsHugeNumber, LIB.IsEmpty, LIB.IsEquals
local Call, XpCall, GetTraceback, RandomChild = LIB.Call, LIB.XpCall, LIB.GetTraceback, LIB.RandomChild
local Get, Set, Clone, GetPatch, ApplyPatch = LIB.Get, LIB.Set, LIB.Clone, LIB.GetPatch, LIB.ApplyPatch
local EncodeLUAData, DecodeLUAData, CONSTANT = LIB.EncodeLUAData, LIB.DecodeLUAData, LIB.CONSTANT
-----------------------------------------------------------------------------------------------------------
local PLUGIN_NAME = 'MY_Cataclysm'
local PLUGIN_ROOT = PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_Cataclysm'
local _L = LIB.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not LIB.AssertVersion(MODULE_NAME, _L[MODULE_NAME], 0x2013900) then
	return
end
--------------------------------------------------------------------------
local D = {}
-----------------------------------------------
-- 重构 @ 2015 赶时间 很多东西写的很粗略
-----------------------------------------------
local Station, SetTarget = Station, SetTarget
local Target_GetTargetData, Table_BuffIsVisible = Target_GetTargetData, Table_BuffIsVisible
local MY_GetDistance, MY_GetBuff, MY_GetEndTime, MY_GetObject = LIB.GetDistance, LIB.GetBuff, LIB.GetEndTime, LIB.GetObject
local CFG                    = MY_Cataclysm.CFG
local CTM_BG_COLOR_MODE      = MY_Cataclysm.BG_COLOR_MODE
-- global STR cache
local COINSHOP_SOURCE_NULL   = g_tStrings.COINSHOP_SOURCE_NULL
local STR_FRIEND_NOT_ON_LINE = g_tStrings.STR_FRIEND_NOT_ON_LINE
local FIGHT_DEATH            = g_tStrings.FIGHT_DEATH
-- STATE cache
local MOVE_STATE_ON_STAND    = MOVE_STATE.ON_STAND
local MOVE_STATE_ON_DEATH    = MOVE_STATE.ON_DEATH
-- local value
local CTM_ALPHA_STEP         = 15    -- 240 / CTM_ALPHA_STEP
local CTM_GROUP_COUNT        = 5 - 1 -- 防止以后开个什么40人本 估计不太可能 就和剑三这还得好几年
local CTM_MEMBER_COUNT       = 5
local CTM_DRAG               = false
local CTM_DRAG_ID
local CTM_CLICK_DISMISS
local CTM_TARGET  -- 注意这个是UI逻辑选中目标 不一定是真实的当前目标
local CTM_TTARGET -- 注意这个是UI逻辑目标选中的目标 不一定是真实的当前目标
local CTM_CACHE              = setmetatable({}, { __mode = 'v' })
local CTM_LIFE_CACHE         = {} -- 当前帧队友血量缓存
local CTM_BUFF_CACHE         = {} -- 附近记录到的需要显示的BUFF缓存
local CTM_BOSS_CACHE         = {} -- 附近的BOSS缓存
local CTM_BOSS_FOCUS_BUFF    = {} -- 附近记录到的BOSS点名BUFF缓存
local CTM_ATTENTION_BUFF     = {} -- 附近记录到的需要显示蒙版的BUFF缓存
local CTM_ATTENTION_STACK    = {} -- 蒙版BUFF栈（取第一个也就是最新入栈的作为显示颜色）
local CTM_CAUTION_BUFF       = {} -- 附近记录到的警告BUFF缓存
local CTM_SCREEN_HEAD        = {} -- 头顶倒计时缓存
local CTM_BOSS_TARGET        = {} -- BOSS目标缓存
local CTM_BOSS_FOCUSED_STATE = {} -- 被BOSS点名的状态缓存
local CTM_THREAT_NPC_ID, CTM_THREAT_TARGET_ID
local CTM_TEMP_TARGET_TYPE, CTM_TEMP_TARGET_ID
local CHANGGE_REAL_SHADOW_TPLID = 46140 -- 清绝歌影 的主体影子
local CHANGGE_REAL_SHADOW_CACHE = {}
do
local function onNpcEnterScene()
	local me = GetClientPlayer()
	local npc = GetNpc(arg0)
	if LIB.IsBoss(me.GetMapID(), npc.dwTemplateID) then
		CTM_BOSS_CACHE[npc.dwID] = npc
	end
	if npc.dwTemplateID == CHANGGE_REAL_SHADOW_TPLID then
		if not (IsEnemy(UI_GetClientPlayerID(), arg0) and LIB.IsShieldedVersion()) then
			local dwType, dwID = LIB.GetTarget()
			if dwType == TARGET.PLAYER and dwID == npc.dwEmployer then
				LIB.SetTarget(TARGET.NPC, arg0)
			end
		end
		CHANGGE_REAL_SHADOW_CACHE[npc.dwEmployer] = arg0
		CHANGGE_REAL_SHADOW_CACHE[arg0] = npc.dwEmployer
	end
end
LIB.RegisterEvent('NPC_ENTER_SCENE.MY_Cataclysm', onNpcEnterScene)

local function onNpcLeaveScene()
	local npc = GetNpc(arg0)
	if CHANGGE_REAL_SHADOW_CACHE[arg0] then
		if not (IsEnemy(UI_GetClientPlayerID(), arg0) and LIB.IsShieldedVersion()) then
			local dwType, dwID = LIB.GetTarget()
			if dwType == TARGET.NPC and dwID == arg0 then
				LIB.SetTarget(TARGET.PLAYER, npc.dwEmployer)
			end
		end
		CHANGGE_REAL_SHADOW_CACHE[CHANGGE_REAL_SHADOW_CACHE[arg0]] = nil
		CHANGGE_REAL_SHADOW_CACHE[arg0] = nil
	end
	CTM_BOSS_CACHE[npc.dwID] = nil
end
LIB.RegisterEvent('NPC_LEAVE_SCENE.MY_Cataclysm', onNpcLeaveScene)
end

do
local function onBossSet()
	CTM_BOSS_CACHE = {}
	local dwMapID = GetClientPlayer().GetMapID()
	for _, npc in ipairs(LIB.GetNearNpc()) do
		if LIB.IsBoss(dwMapID, npc.dwTemplateID) then
			CTM_BOSS_CACHE[npc.dwID] = npc
		end
	end
end
LIB.RegisterEvent('MY_SET_BOSS.MY_Cataclysm', onBossSet)
end

local function SetTarget(dwType, dwID)
	if CHANGGE_REAL_SHADOW_CACHE[dwID] then
		dwType, dwID = TARGET.NPC, CHANGGE_REAL_SHADOW_CACHE[dwID]
	end
	LIB.SetTarget(dwType, dwID)
end

local function CanTarget(dwID)
	if CHANGGE_REAL_SHADOW_CACHE[dwID] then
		dwID = CHANGGE_REAL_SHADOW_CACHE[dwID]
	end
	if IsPlayer(dwID) then
		return GetPlayer(dwID)
	else
		return GetNpc(dwID)
	end
end

-- Package func
local HIDE_FORCE = {
	[7]  = true,
	[8]  = true,
	[10] = true,
	[21] = true,
}
local function IsPlayerManaHide(dwForceID, dwMountType)
	if dwMountType then
		if dwMountType == CONSTANT.KUNGFU_TYPE.CANG_JIAN or           --藏剑
			dwMountType == CONSTANT.KUNGFU_TYPE.TANG_MEN or           --唐门
			dwMountType == CONSTANT.KUNGFU_TYPE.MING_JIAO or          --明教
			dwMountType == CONSTANT.KUNGFU_TYPE.CANG_YUN then         --苍云
			return true
		else
			return false
		end
	else
		return HIDE_FORCE[dwForceID]
	end
end

-- 官方这代码太垃圾到处报错 = =|| 加个pcall了只能 mmp
local _GVoiceBase_IsMemberForbid = LIB.GVoiceBase_IsMemberForbid
local function GVoiceBase_IsMemberForbid(...)
	local status, res = Call(_GVoiceBase_IsMemberForbid, ...)
	return status and res
end

local _GVoiceBase_IsMemberSaying = LIB.GVoiceBase_IsMemberSaying
local function GVoiceBase_IsMemberSaying(...)
	local status, res = Call(_GVoiceBase_IsMemberSaying, ...)
	return status and res
end

local function OpenRaidDragPanel(dwMemberID)
	local hTeam = GetClientTeam()
	local tMemberInfo = hTeam.GetMemberInfo(dwMemberID)
	if not tMemberInfo then
		return
	end
	local hFrame = Wnd.OpenWindow('RaidDragPanel')

	local nX, nY = Cursor.GetPos()
	hFrame:SetAbsPos(nX, nY)
	hFrame:StartMoving()

	hFrame.dwID = dwMemberID
	local hMember = hFrame:Lookup('', '')

	local szPath, nFrame = GetForceImage(tMemberInfo.dwForceID)
	hMember:Lookup('Image_Force'):FromUITex(szPath, nFrame)

	local txtName = hMember:Lookup('Text_Name')
	txtName:SetText(tMemberInfo.szName)

	local hImageLife = hMember:Lookup('Image_Health')
	local hImageMana = hMember:Lookup('Image_Mana')
	if tMemberInfo.bIsOnLine then
		if tMemberInfo.nMaxLife > 0 then
			hImageLife:SetPercentage(tMemberInfo.nCurrentLife / tMemberInfo.nMaxLife)
		end
		if tMemberInfo.nMaxMana > 0 and tMemberInfo.nMaxMana ~= 1 then
			hImageMana:SetPercentage(tMemberInfo.nCurrentMana / tMemberInfo.nMaxMana)
		end
	else
		hImageLife:SetPercentage(0)
		hImageMana:SetPercentage(0)
	end
	hMember:Show()
	hFrame:BringToTop()
	hFrame:Scale(CFG.fScaleX, CFG.fScaleY)
end

local function CloseRaidDragPanel()
	local hFrame = Station.Lookup('Normal/RaidDragPanel')
	if hFrame then
		hFrame:EndMoving()
		Wnd.CloseWindow(hFrame)
	end
end

local function InsertChangeGroupMenu(tMenu, dwMemberID)
	local hTeam = GetClientTeam()
	local tSubMenu = { szOption = g_tStrings.STR_RAID_MENU_CHANG_GROUP }

	local nCurGroupID = hTeam.GetMemberGroupIndex(dwMemberID)
	for i = 0, hTeam.nGroupNum - 1 do
		if i ~= nCurGroupID then
			local tGroupInfo = hTeam.GetGroupInfo(i)
			if tGroupInfo and tGroupInfo.MemberList then
				local tSubSubMenu =
				{
					szOption = g_tStrings.STR_NUMBER[i + 1],
					bDisable = (#tGroupInfo.MemberList >= CTM_MEMBER_COUNT),
					fnAction = function() GetClientTeam().ChangeMemberGroup(dwMemberID, i, 0) end,
					fnAutoClose = function() return true end,
				}
				table.insert(tSubMenu, tSubSubMenu)
			end
		end
	end
	if #tSubMenu > 0 then
		table.insert(tMenu, tSubMenu)
	end
end

-- 有各个版本之间的文本差异，所以做到翻译中
local CTM_KUNGFU_TEXT = setmetatable(Clone(_L.KUNGFU), {
	__index = function(t) return _L.KUNGFU[0] end,
	__metatable = true,
})

-- CODE --
local CTM = {}

MY_CataclysmParty_Base = class()

function MY_CataclysmParty_Base.OnFrameCreate()
	this:Lookup('', 'Handle_BG/Shadow_BG'):SetAlpha(CFG.nAlpha)
	this:RegisterEvent('CTM_SET_ALPHA')
	this:RegisterEvent('CTM_SET_FOLD')
	this:SetVisible(not MY_Cataclysm.bFold)
end

function MY_CataclysmParty_Base.OnEvent(szEvent)
	if szEvent == 'CTM_SET_ALPHA' then
		this:Lookup('', 'Handle_BG/Shadow_BG'):SetAlpha(CFG.nAlpha)
	elseif szEvent == 'CTM_SET_FOLD' then
		this:SetVisible(not MY_Cataclysm.bFold)
	end
end

function MY_CataclysmParty_Base.OnLButtonDown()
	CTM:BringToTop()
end

function MY_CataclysmParty_Base.OnRButtonDown()
	CTM:BringToTop()
end

function MY_CataclysmParty_Base.OnItemLButtonDrag()
	local dwID = (this.bBuff and this:GetParent():GetParent().dwID) or (this.bRole and this.dwID)
	if not dwID then
		return
	end
	local team = GetClientTeam()
	local me = GetClientPlayer()
	if (IsAltKeyDown() or CFG.bEditMode) and me.IsInRaid() and LIB.IsLeader() then
		CTM_DRAG = true
		CTM_DRAG_ID = dwID
		CTM_CLICK_DISMISS = true
		CTM:DrawAllParty()
		CTM:AutoLinkAllPanel()
		CTM:BringToTop()
		OpenRaidDragPanel(dwID)
	end
end

-- DragEnd bug fix
function MY_CataclysmParty_Base.OnItemLButtonUp()
	LIB.DelayCall(50, function()
		if CTM_DRAG then
			CTM_DRAG, CTM_DRAG_ID = false, nil
			CTM:CloseParty()
			CTM:ReloadParty()
			CloseRaidDragPanel()
		end
	end)
end

function MY_CataclysmParty_Base.OnItemLButtonDragEnd()
	local dwID = (this.bBuff and this:GetParent():GetParent().dwID) or (this.bRole and this.dwID)
	if CTM_DRAG and dwID ~= CTM_DRAG_ID then
		local team = GetClientTeam()
		local nGroup = (this.bBuff and this:GetParent():GetParent().nGroup) or this.nGroup
		team.ChangeMemberGroup(CTM_DRAG_ID, nGroup, dwID or 0)
		CTM_DRAG, CTM_DRAG_ID = false, nil
		CloseRaidDragPanel()
		CTM:CloseParty()
		CTM:ReloadParty()
	end
end

function D.SetTargetTeammate(dwID, info)
	if LIB.IsInPubg() and GetClientPlayer().nMoveState == MOVE_STATE.ON_DEATH then
		BattleField_MatchPlayer(dwID)
	elseif info.bIsOnLine and CanTarget(dwID) then -- 有待考证
		if CFG.bTempTargetEnable then
			LIB.DelayCall('MY_Cataclysm_TempTarget', false)
			CTM_TEMP_TARGET_TYPE, CTM_TEMP_TARGET_ID = nil
		end
		SetTarget(TARGET.PLAYER, dwID)
	end
end

function MY_CataclysmParty_Base.OnItemLButtonDown()
	local dwID = (this.bBuff and this:GetParent():GetParent().dwID) or (this.bRole and this.dwID)
	if not dwID then
		return
	end
	local info = CTM:GetMemberInfo(dwID)
	if not info then
		return
	end
	if not IsCtrlKeyDown() and not IsAltKeyDown() then
		D.SetTargetTeammate(dwID, info)
	end
	CTM_CLICK_DISMISS = false
end

function MY_CataclysmParty_Base.OnItemLButtonClick()
	if CTM_CLICK_DISMISS then
		return
	end
	local dwID = (this.bBuff and this:GetParent():GetParent().dwID) or (this.bRole and this.dwID)
	if not dwID then
		return
	end
	local info = CTM:GetMemberInfo(dwID)
	if not info then
		return
	end
	local me = GetClientPlayer()
	if not me then
		return
	end
	if IsAltKeyDown() then
		if this.bBuff and CFG.bBuffAltPublish then
			LIB.Talk(
				PLAYER_TALK_CHANNEL.RAID,
				_L(
					'[%s] got buff [%s]x%d, remaining %ds.',
					info.szName,
					LIB.GetBuffName(this.dwID, this.nLevel),
					this.nStackNum or 1,
					MY_GetEndTime(this.nEndFrame)
				)
			)
		elseif this.bRole and CFG.bAltView and (CFG.bAltViewInFight or not me.bFightState) then
			if IsCtrlKeyDown() then
				if MY_CharInfo and MY_CharInfo.ViewCharInfoToPlayer then
					MY_CharInfo.ViewCharInfoToPlayer(dwID)
				end
			else
				ViewInviteToPlayer(dwID)
			end
		else
			D.SetTargetTeammate(dwID, info)
		end
	elseif IsCtrlKeyDown() then
		LIB.EditBox_AppendLinkPlayer(info.szName)
	end
end

do

local function OnItemRefreshTip()
	local me = GetClientPlayer()
	local bTip = not CFG.bHideTipInFight or not me.bFightState
	if not bTip then
		return
	end
	local nX, nY = this:GetRoot():GetAbsPos()
	local nW, nH = this:GetRoot():GetSize()
	if this.bBuff then
		LIB.OutputBuffTip({ nX, nY + 5, nW, nH }, this.dwID, this.nLevel, MY_GetEndTime(this.nEndFrame), GetFormatText(this.szVia, 82))
	elseif this.bRole then
		LIB.OutputTeamMemberTip({ nX, nY + 5, nW, nH }, this.dwID)
	end
end
MY_CataclysmParty_Base.OnItemRefreshTip = OnItemRefreshTip

function MY_CataclysmParty_Base.OnItemMouseEnter()
	if CTM_DRAG and this:Lookup('Image_Slot') and this:Lookup('Image_Slot'):IsValid() then
		this:Lookup('Image_Slot'):Show()
	end
	OnItemRefreshTip()
	local dwID = (this.bBuff and this:GetParent():GetParent().dwID) or (this.bRole and this.dwID)
	if dwID == CTM_TEMP_TARGET_ID then
		return
	end
	local info = CTM:GetMemberInfo(dwID)
	if not info then
		return
	end
	if info.bIsOnLine and CanTarget(dwID) and CFG.bTempTargetEnable then
		LIB.DelayCall('MY_Cataclysm_TempTarget', false)
		local function fnAction()
			if not CTM_TEMP_TARGET_TYPE then
				CTM_TEMP_TARGET_TYPE, CTM_TEMP_TARGET_ID = LIB.GetTarget()
			end
			SetTarget(TARGET.PLAYER, dwID)
		end
		if CFG.nTempTargetDelay == 0 then
			fnAction()
		else
			LIB.DelayCall('MY_Cataclysm_TempTarget', CFG.nTempTargetDelay, fnAction)
		end
	end
end
end

do
local function ResumeTempTarget()
	SetTarget(CTM_TEMP_TARGET_TYPE, CTM_TEMP_TARGET_ID)
	CTM_TEMP_TARGET_TYPE, CTM_TEMP_TARGET_ID = nil
end
function MY_CataclysmParty_Base.OnItemMouseLeave(dst)
	if CTM_DRAG and this:Lookup('Image_Slot') and this:Lookup('Image_Slot'):IsValid() then
		this:Lookup('Image_Slot'):Hide()
	end
	HideTip()
	local dwID
	if this.bRole then
		dwID = this.dwID
	elseif this.bBuff then
		dwID = this:GetParent():GetParent().dwID
	end
	if dst then
		local dwDstID
		if dst.bRole then
			dwDstID = dst.dwID
		elseif dst.bBuff then
			dwDstID = dst:GetParent():GetParent().dwID
		end
		if dwDstID == dwID then
			return
		end
	end
	if not dwID then
		return
	end
	if CFG.bTempTargetEnable then
		LIB.DelayCall('MY_Cataclysm_TempTarget', false)
		if CTM_TEMP_TARGET_TYPE then
			LIB.DelayCall('MY_Cataclysm_TempTarget', ResumeTempTarget) -- 延迟到下一帧 因为可能当前帧临时选中另外一个玩家 那么不需要切回目标
		end
	end
end
end

function MY_CataclysmParty_Base.OnItemRButtonClick()
	if not this.dwID then
		return
	end
	local dwID = this.dwID
	local menu = {}
	local me = GetClientPlayer()
	local info = CTM:GetMemberInfo(dwID)
	local szPath, nFrame = GetForceImage(info.dwForceID)
	table.insert(menu, {
		szOption = info.szName,
		szLayer = 'ICON_RIGHT',
		rgb = { LIB.GetForceColor(info.dwForceID, 'foreground') },
		szIcon = szPath,
		nFrame = nFrame
	})
	if LIB.IsLeader() and me.IsInRaid() then
		table.insert(menu, { bDevide = true })
		InsertChangeGroupMenu(menu, dwID)
	end
	local info = CTM:GetMemberInfo(dwID)
	if dwID ~= me.dwID then
		if LIB.IsLeader() then
			table.insert(menu, { bDevide = true })
		end
		InsertTeammateMenu(menu, dwID)
		local t = {}
		InsertTargetMenu(t, dwID)
		for _, v in ipairs(t) do
			if v.szOption == g_tStrings.LOOKUP_INFO then
				for _, vv in ipairs(v) do
					if vv.szOption == g_tStrings.LOOKUP_NEW_TANLENT then -- 奇穴
						table.insert(menu, vv)
						break
					end
				end
			end
			if v.szOption == g_tStrings.STR_MAKE_TRADDING then -- 交易
				table.insert(menu, v)
			end
		end
		table.insert(menu, { szOption = g_tStrings.STR_LOOKUP, bDisable = not info.bIsOnLine, fnAction = function()
			ViewInviteToPlayer(dwID)
		end })
		if MY_CharInfo and MY_CharInfo.ViewCharInfoToPlayer then
			table.insert(menu, {
				szOption = g_tStrings.STR_LOOK .. g_tStrings.STR_EQUIP_ATTR, bDisable = not info.bIsOnLine, fnAction = function()
					MY_CharInfo.ViewCharInfoToPlayer(dwID)
				end
			})
		end
		local extra = {}
		if MY_Focus then
			for _, v in ipairs(MY_Focus.GetTargetMenu(TARGET.PLAYER, dwID)) do
				insert(extra, v)
			end
		end
		if #extra > 0 then
			insert(menu, CONSTANT.MENU_DIVIDER)
			for _, v in ipairs(extra) do
				insert(menu, v)
			end
		end
	else
		table.insert(menu, { bDevide = true })
		InsertPlayerMenu(menu, dwID)
		if LIB.IsLeader() then
			table.insert(menu, { bDevide = true })
			table.insert(menu, {
				szOption = _L['Take back all permissions'],
				rgb = { 255, 255, 0 },
				fnAction = function()
					local team = GetClientTeam()
					team.SetAuthorityInfo(TEAM_AUTHORITY_TYPE.MARK, UI_GetClientPlayerID())
					team.SetAuthorityInfo(TEAM_AUTHORITY_TYPE.DISTRIBUTE, UI_GetClientPlayerID())
				end,
			})
		elseif MY_Cataclysm.bDebug then
			table.insert(menu, { bDevide = true })
			table.insert(menu, {
				szOption = _L['Take back permissions'],
				rgb = { 255, 255, 0 },
				{
					szOption = _L['Take back all permissions'],
					rgb = { 255, 255, 0 },
					fnAction = function()
						LIB.SendBgMsg(PLAYER_TALK_CHANNEL.RAID, 'MY_ABOUT', 'TeamAuth')
					end,
				},
				{
					szOption = _L['Take back leader permission'],
					rgb = { 255, 255, 0 },
					fnAction = function()
						LIB.SendBgMsg(PLAYER_TALK_CHANNEL.RAID, 'MY_ABOUT', 'TeamLeader')
					end,
				},
				{
					szOption = _L['Take back mark permission'],
					rgb = { 255, 255, 0 },
					fnAction = function()
						LIB.SendBgMsg(PLAYER_TALK_CHANNEL.RAID, 'MY_ABOUT', 'TeamMark')
					end,
				},
				{
					szOption = _L['Take back distribute permission'],
					rgb = { 255, 255, 0 },
					fnAction = function()
						LIB.SendBgMsg(PLAYER_TALK_CHANNEL.RAID, 'MY_ABOUT', 'TeamDistribute')
					end,
				}
			})
		end
	end
	if #menu > 0 then
		PopupMenu(menu)
	end
end

function CTM:GetPartyFrame(nIndex) -- 获得组队面板
	return Station.Lookup('Normal/MY_CataclysmParty_' .. nIndex)
end

function CTM:BringToTop()
	MY_Cataclysm.GetFrame():BringToTop()
	for i = 0, CTM_GROUP_COUNT do
		if self:GetPartyFrame(i) then
			self:GetPartyFrame(i):BringToTop()
		end
	end
end

function CTM:GetMemberHandle(nGroup, nIndex)
	local frame = self:GetPartyFrame(nGroup)
	if frame then
		return frame:Lookup('', 'Handle_Cols/Handle_Roles'):Lookup(nIndex)
	end
end

-- 创建面板
function CTM:CreatePanel(nIndex)
	local me = GetClientPlayer()
	local frame = self:GetPartyFrame(nIndex)
	if not frame then
		frame = Wnd.OpenWindow(
			PACKET_INFO.ROOT .. 'MY_Cataclysm/ui/MY_CataclysmParty.' .. CFG.eFrameStyle .. '.ini',
			'MY_CataclysmParty_' .. nIndex
		)
		frame:Scale(CFG.fScaleX, CFG.fScaleY)
		frame:SetVisible(not MY_Cataclysm.bFold)
	end
	self:AutoLinkAllPanel()
	self:RefreshGroupText()
end

-- 刷新团队组编号
function CTM:RefreshGroupText()
	local team = GetClientTeam()
	local me = GetClientPlayer()
	for i = 0, team.nGroupNum - 1 do
		local frame = self:GetPartyFrame(i)
		if frame then
			local txtGroup, szGroup = frame:Lookup('', 'Handle_Cols/Handle_Title/Text_Title')
			if me.IsInRaid() then
				if CFG.eFrameStyle == 'CATACLYSM' then
					txtGroup:SetFontScheme(7)
				end
				local tGroup = team.GetGroupInfo(i)
				if tGroup and tGroup.MemberList then
					for k, v in ipairs(tGroup.MemberList) do
						if v == UI_GetClientPlayerID() then
							-- txtGroup:SetFontScheme(2)
							txtGroup:SetFontColor(255, 128, 0) -- 自己所在的小队 黄色
							break
						end
					end
				end
				szGroup = CFG.eFrameStyle == 'CATACLYSM' and g_tStrings.STR_NUMBER[i + 1] or tostring(i + 1)
			else
				szGroup = g_tStrings.STR_TEAM
			end
			txtGroup:SetText(szGroup)
		end
	end
end
 -- 连接所有面板
function CTM:AutoLinkAllPanel()
	local frameMain = MY_Cataclysm.GetFrame()
	local nX, nY = frameMain:GetRelPos()
	nY = nY + 24
	local nShownCount = 0
	local tPosnSize = {}
	-- { nX = nX, nY = nY, nW = 0, nH = 0 }
	for i = 0, CTM_GROUP_COUNT do
		local hPartyPanel = self:GetPartyFrame(i)
		if hPartyPanel then
			local nW, nH = hPartyPanel:GetSize()

			if nShownCount < CFG.nAutoLinkMode then
				tPosnSize[nShownCount] = { nX = nX + (128 * CFG.fScaleX * nShownCount), nY = nY, nW = nW, nH = nH }
			else
				local nUpperIndex = math.min(nShownCount - CFG.nAutoLinkMode, CFG.nAutoLinkMode - 1)
				local tPS = tPosnSize[nUpperIndex] or {nH = 235 * CFG.fScaleY}
				tPosnSize[nShownCount] = {
					nX = nX + (128 * CFG.fScaleX * (nShownCount - CFG.nAutoLinkMode)),
					nY = nY + tPosnSize[nUpperIndex].nH,
					nW = nW,
					nH = nH
				}
			end
			local _nX, _nY = hPartyPanel:GetRelPos()
			if _nX ~= tPosnSize[nShownCount].nX or _nY ~= tPosnSize[nShownCount].nY then
				hPartyPanel:SetRelPos(tPosnSize[nShownCount].nX, tPosnSize[nShownCount].nY)
			end
			nShownCount = nShownCount + 1
		end
	end
end

function CTM:GetMemberInfo(dwID)
	local team = GetClientTeam()
	if not team then
		return
	end
	return team.GetMemberInfo(dwID)
end

function CTM:GetTeamInfo()
	local team = GetClientTeam()
	return {
		[TEAM_AUTHORITY_TYPE.LEADER]     = team.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.LEADER),
		[TEAM_AUTHORITY_TYPE.MARK]       = team.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.MARK),
		[TEAM_AUTHORITY_TYPE.DISTRIBUTE] = team.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.DISTRIBUTE),
	}
end

local function HideTarget()
	if CTM_TARGET
	and CTM_CACHE[CTM_TARGET]
	and CTM_CACHE[CTM_TARGET]:IsValid()
	and CTM_CACHE[CTM_TARGET]:Lookup('Image_Selected')
	and CTM_CACHE[CTM_TARGET]:Lookup('Image_Selected'):IsValid() then
		CTM_CACHE[CTM_TARGET]:Lookup('Image_Selected'):Hide()
	end
end

function CTM:RefreshTarget(dwOldID, nOldType, dwNewID, nNewType)
	if nOldType == TARGET.NPC and CHANGGE_REAL_SHADOW_CACHE[dwOldID] then
		nOldType, dwOldID = TARGET.PLAYER, CHANGGE_REAL_SHADOW_CACHE[dwOldID]
	end
	if nNewType == TARGET.NPC and CHANGGE_REAL_SHADOW_CACHE[dwNewID] then
		nNewType, dwNewID = TARGET.PLAYER, CHANGGE_REAL_SHADOW_CACHE[dwNewID]
	end
	if dwOldID == CTM_TARGET then
		HideTarget()
	end
	if nNewType == TARGET.PLAYER
	and CTM_CACHE[dwNewID]
	and CTM_CACHE[dwNewID]:IsValid()
	and CTM_CACHE[dwNewID]:Lookup('Image_Selected')
	and CTM_CACHE[dwNewID]:Lookup('Image_Selected'):IsValid() then
		CTM_CACHE[dwNewID]:Lookup('Image_Selected'):Show()
	end
	CTM_TARGET = dwNewID
end

do
local function HideTTarget()
	if CTM_TTARGET
	and CTM_CACHE[CTM_TTARGET]
	and CTM_CACHE[CTM_TTARGET]:IsValid()
	and CTM_CACHE[CTM_TTARGET]:Lookup('Handle_TargetTarget')
	and CTM_CACHE[CTM_TTARGET]:Lookup('Handle_TargetTarget'):IsValid() then
		CTM_CACHE[CTM_TTARGET]:Lookup('Handle_TargetTarget'):Hide()
	end
end
function CTM:RefreshTTarget()
	if CFG.bShowTargetTargetAni then
		local dwType, dwID = Target_GetTargetData()
		if dwID then
			local KObject = MY_GetObject(dwID)
			if KObject then
				local dwTarType, dwTarID = KObject.GetTarget()
				if dwTarType == TARGET.NPC and CHANGGE_REAL_SHADOW_CACHE[dwTarID] then
					dwTarType, dwTarID = TARGET.PLAYER, CHANGGE_REAL_SHADOW_CACHE[dwTarID]
				end
				if dwTarID ~= CTM_TTARGET then
					HideTTarget()
				end
				if dwTarID and dwTarID ~= 0 and dwTarType == TARGET.PLAYER
				and CTM_CACHE[dwTarID]
				and CTM_CACHE[dwTarID]:IsValid()
				and CTM_CACHE[dwTarID]:Lookup('Handle_TargetTarget')
				and CTM_CACHE[dwTarID]:Lookup('Handle_TargetTarget'):IsValid() then
					CTM_CACHE[dwTarID]:Lookup('Handle_TargetTarget'):Show()
				end
				CTM_TTARGET = dwTarID
				return
			end
		end
	end
	HideTTarget()
end
end

do
local function HideBossTarget(dwTarID)
	if CTM_CACHE[dwTarID]
	and CTM_CACHE[dwTarID]:IsValid()
	and CTM_CACHE[dwTarID]:Lookup('Image_Threat')
	and CTM_CACHE[dwTarID]:Lookup('Image_Threat'):IsValid() then
		CTM_CACHE[dwTarID]:Lookup('Image_Threat'):Hide()
	end
end
function CTM:RefreshBossTarget()
	local tKeep = {}
	if CFG.bShowBossTarget then
		for dwNpcID, npc in pairs(CTM_BOSS_CACHE) do
			local dwTarID = (LIB.IsEnemy(UI_GetClientPlayerID(), dwNpcID) and npc.bFightState)
				and (CTM_THREAT_NPC_ID == dwNpcID and CTM_THREAT_TARGET_ID or select(2, npc.GetTarget()))
				or nil
			if dwTarID then
				if dwTarID ~= CTM_BOSS_TARGET[dwNpcID] then
					HideBossTarget(CTM_BOSS_TARGET[dwNpcID])
					if CTM_CACHE[dwTarID]
					and CTM_CACHE[dwTarID]:IsValid()
					and CTM_CACHE[dwTarID]:Lookup('Image_Threat')
					and CTM_CACHE[dwTarID]:Lookup('Image_Threat'):IsValid() then
						CTM_CACHE[dwTarID]:Lookup('Image_Threat'):Show()
					end
					CTM_BOSS_TARGET[dwNpcID] = dwTarID
				end
				tKeep[dwTarID] = true
			end
		end
	end
	for dwNpcID, dwTarID in pairs(CTM_BOSS_TARGET) do
		if not tKeep[dwTarID] then
			HideBossTarget(dwTarID)
			CTM_BOSS_TARGET[dwNpcID] = nil
		end
	end
end
end

function CTM:RefreshThreat(dwNpcID, dwTarID)
	CTM_THREAT_NPC_ID = dwNpcID
	CTM_THREAT_TARGET_ID = dwTarID
	self:RefreshBossTarget()
end

function CTM:RefreshAttention()
	if CFG.bShowAttention then
		local team, me = GetClientTeam(), GetClientPlayer()
		local tKeep = {}
		for _, dwTarID in ipairs(team.GetTeamMemberList()) do
			local p = GetPlayer(dwTarID)
			if CTM_CACHE[dwTarID] and CTM_CACHE[dwTarID]:IsValid() then
				if p and not IsEmpty(CTM_ATTENTION_STACK[dwTarID]) then
					local r, g, b = LIB.HumanColor2RGB(CTM_ATTENTION_STACK[dwTarID][1].col)
					CTM_CACHE[dwTarID]:Lookup('Shadow_Attention'):SetColorRGB(r, g, b)
					CTM_CACHE[dwTarID]:Lookup('Shadow_Attention'):Show()
				else
					CTM_CACHE[dwTarID]:Lookup('Shadow_Attention'):Hide()
				end
			end
			tKeep[dwTarID] = p and true or false
		end
		for dwTarID, _ in pairs(CTM_ATTENTION_BUFF) do
			if not tKeep[dwTarID] then
				CTM_ATTENTION_BUFF[dwTarID] = nil
				CTM_ATTENTION_STACK[dwTarID] = nil
			end
		end
	else
		for dwTarID, _ in pairs(CTM_ATTENTION_BUFF) do
			if CTM_CACHE[dwTarID] and CTM_CACHE[dwTarID]:IsValid() then
				CTM_CACHE[dwTarID]:Lookup('Shadow_Attention'):Hide()
			end
		end
	end
	-- Output(CTM_ATTENTION_BUFF, CTM_ATTENTION_STACK)
end

function CTM:RefreshCaution()
	if CFG.bShowCaution or CFG.bShowBossFocus then
		local team, me = GetClientTeam(), GetClientPlayer()
		local tKeep = {}
		for _, dwTarID in ipairs(team.GetTeamMemberList()) do
			local p = GetPlayer(dwTarID)
			if CTM_CACHE[dwTarID] and CTM_CACHE[dwTarID]:IsValid() then
				CTM_CACHE[dwTarID]:Lookup('Handle_Caution'):SetVisible(
					p and (
						(CFG.bShowCaution and not IsEmpty(CTM_CAUTION_BUFF[dwTarID]))
						or (CFG.bShowBossFocus and CTM_BOSS_FOCUSED_STATE[dwTarID])
					)
				)
			end
			tKeep[dwTarID] = p and true or false
		end
		if CFG.bShowCaution then
			for dwTarID, _ in pairs(CTM_CAUTION_BUFF) do
				if not tKeep[dwTarID] then
					CTM_CAUTION_BUFF[dwTarID] = nil
				end
			end
		end
		if CFG.bShowBossFocus then
			for dwTarID, _ in pairs(CTM_BOSS_FOCUSED_STATE) do
				if not tKeep[dwTarID] then
					CTM_BOSS_FOCUSED_STATE[dwTarID] = nil
				end
			end
		end
	else
		for dwTarID, _ in pairs(CTM_CAUTION_BUFF) do
			if CTM_CACHE[dwTarID] and CTM_CACHE[dwTarID]:IsValid() then
				CTM_CACHE[dwTarID]:Lookup('Handle_Caution'):Hide()
			end
		end
		for dwTarID, _ in pairs(CTM_BOSS_FOCUSED_STATE) do
			if CTM_CACHE[dwTarID] and CTM_CACHE[dwTarID]:IsValid() then
				CTM_CACHE[dwTarID]:Lookup('Handle_Caution'):Hide()
			end
		end
	end
	-- Output(CTM_CAUTION_BUFF, CTM_BOSS_FOCUSED_STATE)
end

function CTM:RefreshMark()
	local team = GetClientTeam()
	local tPartyMark = team.GetTeamMark()
	if not tPartyMark then return end
	for k, v in pairs(CTM_CACHE) do
		if v:IsValid() then
			if tPartyMark[k] then
				local nMarkID, nIconFrame = tPartyMark[k], 0
				if nMarkID and PARTY_MARK_ICON_FRAME_LIST[nMarkID] then
					-- assert(nMarkID > 0 and nMarkID <= #PARTY_MARK_ICON_FRAME_LIST)
					nIconFrame = PARTY_MARK_ICON_FRAME_LIST[nMarkID]
				end
				v:Lookup('Image_MarkImage'):FromUITex(PARTY_MARK_ICON_PATH, nIconFrame)
				v:Lookup('Image_MarkImage'):Show()
				local fScale = (CFG.fScaleY + CFG.fScaleX) / 2
				v:Lookup('Image_MarkImage'):SetSize(24 * fScale, 24 * fScale)
			else
				v:Lookup('Image_MarkImage'):Hide()
			end
		end
	end
end

-- 由于SFX的缩放独立于UI缩放 所以需要单独计算
-- 我们准备三个Handle 一个允许缩放 一个禁止缩放 SFX初始为1倍缩放 结构为 允许缩放Handle/禁止缩放Handle/SFX
--    允许缩放的那个Handle初始大小是你想要得到的最终显示大小 初始位置亦为你想要显示的最终位置
--    禁止缩放的那个Handle初始大小应该等于SFX模型缩放比为1时在屏幕上的矩形区域大小 初始位置为刚好覆盖SFX
--    SFX初始中心应当为最终想要的中心点
-- 计算方法是 每次计算允许缩放的Handle与禁止缩放的Handle的比例差即可得知SFX当前理应当缩放和平移数值
function CTM:RefreshSFX()
	local hDest, hScale, hFixed
	local fSFXX, fSFXY -- SFX当前状态下对比初始时正确的缩放比
	local fUIX, fUIY -- UI当前状态下对应1.0的缩放比
	for dwID, h in pairs(CTM_CACHE) do
		if h:IsValid() then
			for _, szID in ipairs({ 'TargetTarget', 'Caution' }) do
				hDest = h:Lookup('Handle_' .. szID)
				hScale = hDest:Lookup('Handle_' .. szID .. '_Scale')
				hFixed = hDest:Lookup('Handle_' .. szID .. '_Fixed')
				fUIX, fUIY = hScale:GetW() / hFixed:GetW(), hScale:GetH() / hFixed:GetH()
				fSFXX, fSFXY = hDest:GetW() / hFixed:GetW(), hDest:GetH() / hFixed:GetH()
				hDest:Lookup('SFX_' .. szID):Get3DModel():SetScaling(fSFXX, fSFXY, fSFXX)
			end
		end
	end
end

function CTM:RefreshGVoice()
	local team = GetClientTeam()
	local sayingInfo = LIB.GVoiceBase_GetSaying()
	local bInRoom = LIB.GVoiceBase_GetMicState() ~= CONSTANT.MIC_STATE.CLOSE_NOT_IN_ROOM
	for dwID, h in pairs(CTM_CACHE) do
		if h:IsValid() then
			local fScale = min(CFG.fScaleY, CFG.fScaleX)
			local hSpeaker = h:Lookup('Handle_Speaker')
			if bInRoom and GVoiceBase_IsMemberForbid(dwID) then
				hSpeaker:Show()
				hSpeaker:SetRelX(h:GetW() - hSpeaker:GetW())
				hSpeaker:SetAbsX(h:GetAbsX() + h:GetW() - 30 * fScale)
				hSpeaker:Lookup('Shadow_SpeakerBg'):SetSize(30 * fScale, 22 * fScale)
				hSpeaker:Lookup('Handle_ForbidSpeaker'):Show()
				hSpeaker:Lookup('Animate_SpeakerEffect'):Hide()
				hSpeaker:Lookup('Handle_ForbidSpeaker/Image_Speaker'):SetSize(11 * fScale, 16 * fScale)
				hSpeaker:Lookup('Handle_ForbidSpeaker/Image_ForbidSpeaker'):SetSize(16 * fScale, 16 * fScale)
			elseif bInRoom and GVoiceBase_IsMemberSaying(dwID, sayingInfo) then
				hSpeaker:Show()
				hSpeaker:SetRelX(h:GetW() - hSpeaker:GetW())
				hSpeaker:SetAbsX(h:GetAbsX() + h:GetW() - 30 * fScale)
				hSpeaker:Lookup('Shadow_SpeakerBg'):SetSize(30 * fScale, 22 * fScale)
				hSpeaker:Lookup('Handle_ForbidSpeaker'):Hide()
				hSpeaker:Lookup('Animate_SpeakerEffect'):Show()
				hSpeaker:Lookup('Animate_SpeakerEffect'):SetSize(32 * fScale, 24 * fScale)
			else
				hSpeaker:Hide()
			end
		end
	end
end

function CTM:CallRefreshImages(dwID, ...)
	if type(dwID) == 'number' then
		local info = self:GetMemberInfo(dwID)
		if info and CTM_CACHE[dwID] and CTM_CACHE[dwID]:IsValid() then
			self:RefreshImages(CTM_CACHE[dwID], dwID, info, ...)
		end
	else
		for k, v in pairs(CTM_CACHE) do
			if v:IsValid() then
				local info = self:GetMemberInfo(k)
				self:RefreshImages(v, k, info, ...)
			end
		end
	end
end

function CTM:KungFuSwitch(dwID)
	local handle = CTM_CACHE[dwID]
	if handle and handle:IsValid() then
		if GetPlayer(dwID) then
			local key = 'CTM_KUNFU_' .. dwID
			local img = handle:Lookup('Image_Icon')
			LIB.BreatheCall(key, function()
				local player = GetPlayer(dwID)
				if player and img and img:IsValid() then
					local nType, dwSkillID, dwSkillLevel, fCastPercent = player.GetSkillOTActionState()
					if nType == CHARACTER_OTACTION_TYPE.ACTION_SKILL_PREPARE then
						local alpha = 255 * (math.abs(math.mod(fCastPercent * 300, 32) - 7) + 4) / 12
						if alpha <= 255 then
							img:SetAlpha(alpha)
						end
						return
					else
						img:SetAlpha(255)
					end
				end
				LIB.BreatheCall(key, false)
			end)
		end
	end
end

-- 刷新图标和名字之类的信息
function CTM:RefreshImages(h, dwID, info, tSetting, bIcon, bFormationLeader, bLayout)
	-- assert(info)
	if not info then return end
	-- 刷新团队权限标记
	if type(tSetting) ~= 'nil' then
		local fnAction = function(t)
			local hTotal = {
				[TEAM_AUTHORITY_TYPE.LEADER]     = h:Lookup('Handle_Icons/Image_Leader'),
				[TEAM_AUTHORITY_TYPE.MARK]       = h:Lookup('Handle_Icons/Image_Marker'),
				[TEAM_AUTHORITY_TYPE.DISTRIBUTE] = h:Lookup('Handle_Icons/Image_Looter'),
			}
			for k, v in pairs(hTotal) do
				if t[k] == dwID then
					v:Show()
					local fScale = (CFG.fScaleY + CFG.fScaleX) / 2
					v:SetSize(14 * fScale, 14 * fScale)
				else
					v:Hide()
				end
			end
		end

		if type(tSetting) == 'table' then -- 根据表的内容刷新标记队长等信息
			fnAction(tSetting)
		elseif type(tSetting) == 'boolean' and tSetting then
			fnAction(self:GetTeamInfo())
		end
	end
	-- 刷新阵眼
	if type(bFormationLeader) == 'boolean' then
		if bFormationLeader then
			local fScale = (CFG.fScaleY + CFG.fScaleX) / 2
			h:Lookup('Handle_Icons/Image_Matrix'):SetSize(14 * fScale, 14 * fScale)
			h:Lookup('Handle_Icons/Image_Matrix'):Show()
		else
			h:Lookup('Handle_Icons/Image_Matrix'):Hide()
		end
	end
	-- 刷新内功
	if bIcon then -- 刷新icon
		local img, bVisible = h:Lookup('Image_Icon'), true
		if CFG.nShowIcon ~= 4 then
			if CFG.nShowIcon == 2 and info.dwMountKungfuID == 0 then
				img:FromUITex('ui/image/TargetPanel/Target.UITex', 21)
			elseif CFG.nShowIcon == 2 then
				local _, nIconID = LIB.GetSkillName(info.dwMountKungfuID, 1)
				if nIconID == 1435 then nIconID = 889 end
				img:FromIconID(nIconID)
			elseif CFG.nShowIcon == 1 then
				img:FromUITex(GetForceImage(info.dwForceID))
			elseif CFG.nShowIcon == 3 then
				local szCampImg, nCampFrame = LIB.GetCampImage(info.nCamp, false)
				if szCampImg then
					img:FromUITex(szCampImg, nCampFrame)
				else
					bVisible = false
				end
			end
			local fScale = (CFG.fScaleY + CFG.fScaleX) / 2
			if fScale * 0.9 > 1 then
				fScale = fScale * 0.9
			end
			img:SetSize(28 * fScale, 28 * fScale)
		else -- 不再由icon控制 转交给textname
			bVisible = false
		end
		img:SetVisible(bVisible)
		bLayout = true
	end
	-- 刷新名字
	if bLayout then
		local txtName = h:Lookup('Text_Name')
		local txtLife = h:Lookup('Text_Life')
		local txtDeath = h:Lookup('Text_Death')
		local txtOffLine = h:Lookup('Text_OffLine')
		local txtSchool = h:Lookup('Text_School_Name')
		local r, g, b = 255, 255, 255
		if CFG.nColoredName == 1 then
			r, g, b = LIB.GetForceColor(info.dwForceID, 'foreground')
		elseif CFG.nColoredName == 0 then
			r, b, b = 255, 255, 255
		elseif CFG.nColoredName == 2 then
			r, g, b = LIB.GetCampColor(info.nCamp, 'foreground')
		end
		local szName = info.szName
		if MY_ChatMosaics and MY_ChatMosaics.MosaicsString then
			szName = MY_ChatMosaics.MosaicsString(szName)
		end
		txtName:SetText(szName)
		txtName:SetVAlign(CFG.nNameVAlignment)
		txtName:SetHAlign(CFG.nNameHAlignment)
		txtName:SetFontScheme(CFG.nNameFont)
		txtName:SetFontColor(r, g, b)
		txtName:SetFontScale(CFG.fNameFontScale)
		txtLife:SetVAlign(CFG.nHPVAlignment)
		txtLife:SetHAlign(CFG.nHPHAlignment)
		txtDeath:SetVAlign(CFG.nHPVAlignment)
		txtDeath:SetHAlign(CFG.nHPHAlignment)
		txtOffLine:SetVAlign(CFG.nHPVAlignment)
		txtOffLine:SetHAlign(CFG.nHPHAlignment)
		local fScale, nRelX = (CFG.fScaleY + CFG.fScaleX) / 2
		if fScale * 0.9 > 1 then
			fScale = fScale * 0.9
		end
		if CFG.nShowIcon == 4 then
			local r, g, b = LIB.GetForceColor(info.dwForceID, 'foreground')
			txtSchool:SetText(CTM_KUNGFU_TEXT[info.dwMountKungfuID])
			txtSchool:SetFontScheme(CFG.nNameFont)
			txtSchool:SetFontColor(r, g, b)
			txtSchool:SetFontScale(fScale)
			txtSchool:AutoSize()
			txtSchool:Show()
			nRelX = txtSchool:GetRelX() + txtSchool:GetW() + 5
		else
			local img = h:Lookup('Image_Icon')
			txtSchool:Hide()
			nRelX = img:GetRelX() + img:GetW()
		end
		-- 刷新名字血量位置
		local nMargin = CFG.eFrameStyle == 'OFFICIAL' and 7 or 5
		for _, szItemName in ipairs({'Text_Name', 'Text_Life', 'Text_Death', 'Text_OffLine'}) do
			local txt = h:Lookup(szItemName)
			local nVAlign = txt:GetVAlign()
			local nHAlign = txt:GetHAlign()
			if nVAlign == ALIGNMENT.TOP
			and (nHAlign == ALIGNMENT.LEFT or nHAlign == ALIGNMENT.RIGHT) then
				txt:SetRelX(nRelX)
				txt:SetAbsX(h:GetAbsX() + nRelX)
				txt:SetW(h:GetW() - nRelX - nMargin)
			else
				txt:SetRelX(nMargin)
				txt:SetAbsX(h:GetAbsX() + nMargin)
				txt:SetW(h:GetW() - nMargin * 2)
			end
		end
		-- 刷新BUFF位置
		if CFG.bBuffAboveMana then
			local hMana = h:Lookup('Handle_Mana')
			local hBoxes = h:Lookup('Handle_Buff_Boxes')
			hBoxes:SetRelPos(hMana:GetRelX() - 1, hMana:GetRelY() - hBoxes:GetH() + hMana:GetH() / 2)
			hBoxes:SetAbsPos(hMana:GetAbsX() - 1, hMana:GetAbsY() - hBoxes:GetH() + hMana:GetH() / 2)
		end
	end
end

function CTM:DrawAllParty()
	for i = 0, CTM_GROUP_COUNT do
		if not self:GetPartyFrame(i) then
			self:CreatePanel(i)
			self:DrawParty(i)
		else
			self:FormatFrame(self:GetPartyFrame(i), CTM_MEMBER_COUNT)
		end
	end
end

function CTM:CloseParty(nIndex)
	if nIndex then
		if self:GetPartyFrame(nIndex) then
			Wnd.CloseWindow(self:GetPartyFrame(nIndex))
		end
	else
		for i = 0, CTM_GROUP_COUNT do
			if self:GetPartyFrame(i) then
				Wnd.CloseWindow(self:GetPartyFrame(i))
			end
		end
	end
end

function CTM:ReloadParty()
	local team = GetClientTeam()
	for i = 0, team.nGroupNum - 1 do
		local tGroup = team.GetGroupInfo(i)
		if tGroup then
			if #tGroup.MemberList == 0 then
				self:CloseParty(i)
			else
				self:CreatePanel(i)
				self:DrawParty(i)
			end
		end
	end
	self:AutoLinkAllPanel()
	self:RefreshMark()
	self:RefreshDistance()
	self:RefreshFormation()
	CTM_LIFE_CACHE = {}
end

-- 哎 事件太蛋疼 就这样吧
function CTM:RefreshFormation()
	local team = GetClientTeam()
	for i = 0, team.nGroupNum - 1 do
		local tGroup = team.GetGroupInfo(i)
		if tGroup and tGroup.dwFormationLeader and #tGroup.MemberList > 0 then
			local dwFormationLeader = tGroup.dwFormationLeader
			for k, v in ipairs(tGroup.MemberList) do
				local info = self:GetMemberInfo(v)
				if CTM_CACHE[v] and CTM_CACHE[v]:IsValid() then
					self:RefreshImages(CTM_CACHE[v], v, info, false, false, dwFormationLeader == v)
				end
			end
		end
	end
end

-- 绘制面板
function CTM:DrawParty(nIndex)
	local team = GetClientTeam()
	local tGroup = team.GetGroupInfo(nIndex)
	local frame = self:GetPartyFrame(nIndex)
	local handle = frame:Lookup('', 'Handle_Cols/Handle_Roles')
	local tSetting = self:GetTeamInfo()
	local hMember = MY_Cataclysm.GetFrame().hMember
	handle:Clear()
	for i = 1, CTM_MEMBER_COUNT do
		local dwID = tGroup.MemberList[i]
		local h = handle:AppendItemFromData(hMember, i)
		if dwID then
			h.bRole = true
			h.dwID = dwID
			CTM_CACHE[dwID] = h
			local info = self:GetMemberInfo(dwID)
			h:Lookup('Image_MemberBg'):Show()
			self:RefreshImages(h, dwID, info, tSetting, true, dwID == tGroup.dwFormationLeader, true)
		end
		h.nGroup = nIndex
		self:Scale(CFG.fScaleX, CFG.fScaleY, h)
	end
	handle:FormatAllItemPos()
	frame.nMemberCount = #tGroup.MemberList
	-- 先缩放后画
	self:FormatFrame(frame, #tGroup.MemberList)
	self:RefreshDistance() -- 立即刷新一次
	for k, v in pairs(CTM_CACHE) do
		if v:IsValid() and v.nGroup == nIndex then
			self:CallDrawHPMP(k, true)
		end
	end
	CTM_LIFE_CACHE = {}
	-- 刷新
	CTM_TARGET = nil
	CTM_TTARGET = nil
	local dwType, dwID = Target_GetTargetData()
	self:RefreshTarget(dwID, dwType, dwID, dwType)
	self:RefreshTTarget()
end

function CTM:Scale(fX, fY, frame)
	if frame then
		frame:Scale(fX, fY)
	else
		for i = 0, CTM_GROUP_COUNT do
			if self:GetPartyFrame(i) then
				self:GetPartyFrame(i):Scale(fX, fY)
				self:FormatFrame(self:GetPartyFrame(i))
			end
		end
	end
	self:AutoLinkAllPanel()
	self:CallRefreshImages(true, true, true, nil, true) -- 缩放其他图标
	self:RefreshSFX() -- 缩放特效
	self:RefreshFormation() -- 缩放阵眼
	self:RefreshMark() -- 缩放标记
	self:RefreshGVoice() -- 缩放语音
end

function CTM:FormatFrame(frame, nMemberCount)
	local fX, fY = CFG.fScaleX, CFG.fScaleY
	local height, nGroupHeight = (CFG.fScaleY - 1) * 18, 0
	local h = frame:Lookup('', '')
	local nRolesH = 0
	if CTM_DRAG or CFG.bShowAllGrid then
		nMemberCount = CTM_MEMBER_COUNT
		local handle = h:Lookup('Handle_Cols/Handle_Roles')
		for i = 0, handle:GetItemCount() - 1 do
			local h = handle:Lookup(i)
			if not h.dwID then
				if CTM_DRAG then
					h:Lookup('Image_SlotBg'):Show()
				end
				h:Lookup('Image_MemberBg'):Show()
			end
			nRolesH = nRolesH + h:GetH()
		end
		handle:SetH(nRolesH)
	else
		nMemberCount = frame.nMemberCount or CTM_MEMBER_COUNT
		local handle = h:Lookup('Handle_Cols/Handle_Roles')
		for i = 0, handle:GetItemCount() - 1 do
			local h = handle:Lookup(i)
			if h.dwID then
				nRolesH = nRolesH + h:GetH()
			end
			h:Lookup('Image_SlotBg'):Hide()
			h:Lookup('Image_MemberBg'):SetVisible(not not h.dwID)
		end
		handle:SetH(nRolesH)
	end
	if not CFG.bShowGroupNumber then
		nGroupHeight = 23
	end
	frame:SetSize(128 * fX, 25 * fY + nRolesH - height - nGroupHeight)
	h:Lookup('Handle_BG/Shadow_BG'):SetSize(120 * fX, nRolesH + 20 * fY - height - nGroupHeight)
	h:Lookup('Handle_BG/Image_BG_L'):SetSize(18 * fX, nRolesH + nMemberCount * 3 * fY - height - nGroupHeight)
	h:Lookup('Handle_BG/Image_BG_R'):SetSize(18 * fX, nRolesH + nMemberCount * 3 * fY - height - nGroupHeight)
	h:Lookup('Handle_BG/Image_BG_BL'):SetRelPos(0, nRolesH + 11 * fY - height - nGroupHeight)
	h:Lookup('Handle_BG/Image_BG_T'):SetSize(110 * fX, 18 * fY)
	h:Lookup('Handle_BG/Image_BG_B'):SetSize(110 * fX, 18 * fY)
	h:Lookup('Handle_BG/Image_BG_B'):SetRelPos(14 * fX, nRolesH + 11 * fY - height - nGroupHeight)
	h:Lookup('Handle_BG/Image_BG_BR'):SetRelPos(112 * fX, nRolesH + 11 * fY - height - nGroupHeight)
	h:Lookup('Handle_BG'):FormatAllItemPos()
	h:Lookup('Handle_Cols/Handle_Title'):SetVisible(CFG.bShowGroupNumber)
	h:Lookup('Handle_Cols/Handle_Title'):SetH(23)
	h:Lookup('Handle_Cols/Handle_Title/Text_Title'):SetH(23)
	h:Lookup('Handle_Cols/Handle_Title/Image_TitleBg'):SetH(23)
	h:Lookup('Handle_Cols'):FormatAllItemPos()
end

-- 注册buff
function CTM:RecBuff(dwMemberID, data)
	local szKey = ('%d,%d,%s%d'):format(
		data.dwID, data.nLevel,
		data.szStackOp or '',
		data.nStackNum or 0
	)
	CTM_BUFF_CACHE[szKey] = data
end

function CTM:ClearBuff(dwMemberID)
	local team = GetClientTeam()
	for k, v in ipairs(team.GetTeamMemberList()) do
		if CTM_CACHE[v] and CTM_CACHE[v]:IsValid() then
			CTM_CACHE[v]:Lookup('Handle_Buff_Boxes'):Clear()
		end
		if CTM_CAUTION_BUFF[v] then
			CTM_CAUTION_BUFF[v] = nil
		end
		if CTM_ATTENTION_BUFF[v] then
			for _, p in pairs(CTM_ATTENTION_BUFF[v]) do
				for i, rec in ipairs_r(CTM_ATTENTION_STACK[v]) do
					if rec == p then
						remove(CTM_ATTENTION_STACK[v], i)
						break
					end
				end
			end
			CTM_ATTENTION_BUFF[v] = nil
		end
		if CTM_CAUTION_BUFF[v] then
			CTM_CAUTION_BUFF[v] = nil
		end
		if CTM_SCREEN_HEAD[v] then
			CTM_SCREEN_HEAD[v] = nil
		end
	end
	CTM_BUFF_CACHE = {}
end

function D.UpdateCharaterBuff(p, handle, key, data, buff)
	local dwCharID = p.dwID
	local item = handle:Lookup(key)
	if buff then
		local nEndFrame, nStackNum = buff.nEndFrame, buff.nStackNum
		-- check priority
		local nPriority = data.nPriority
		if not nPriority then
			if data.bCaution then
				nPriority = 0
			elseif data.bAttention then
				nPriority = 1
			end
		end
		if nPriority and handle:GetItemCount() == CFG.nMaxShowBuff then
			local item = handle:Lookup(CFG.nMaxShowBuff - 1)
			if not item.nPriority or nPriority < item.nPriority then
				handle:RemoveItem(item)
			end
		end
		-- create
		if not item and handle:GetItemCount() <= CFG.nMaxShowBuff then
			item = handle:AppendItemFromData(MY_Cataclysm.GetFrame().hBuff, key)
			item.bBuff = true
			-- 描边
			local r, g, b, a
			if data.col then
				r, g, b, a = LIB.HumanColor2RGB(data.col)
			end
			if not data.col then
				item:Lookup('Handle_RbgBorders'):Hide()
				item:Lookup('Handle_InnerBorders'):Hide()
			else
				local hSha, sha = item:Lookup('Handle_RbgBorders')
				for i = 0, hSha:GetItemCount() - 1 do
					sha = hSha:Lookup(i)
					sha:SetAlpha(a or data.nColAlpha or 192)
					sha:SetColorRGB(r or 255, g or 255, b or 0)
				end
				item:Lookup('Handle_RbgBorders'):Show()
				item:Lookup('Handle_InnerBorders'):Show()
			end
			-- 排序
			local fromIndex, toIndex = handle:GetItemCount() - 1
			if not nPriority then
				for i = 0, fromIndex - 1 do
					local item = handle:Lookup(i)
					if item.nPriority and item.nPriority < 0 then
						toIndex = i
						break
					end
				end
			elseif nPriority >= 0 then
				for i = 0, fromIndex - 1 do
					local item = handle:Lookup(i)
					if not item.nPriority or item.nPriority < 0 or nPriority < item.nPriority then
						toIndex = i
						break
					end
				end
			else
				for i = 0, fromIndex - 1 do
					local item = handle:Lookup(i)
					if item.nPriority and item.nPriority < 0 and nPriority > item.nPriority then
						toIndex = i
						break
					end
				end
			end
			if toIndex then
				for i = fromIndex, toIndex + 1, -1 do
					handle:ExchangeItemIndex(i, i - 1)
				end
			end
			item.nPriority = nPriority
			-- 文字大小
			local szName, icon = LIB.GetBuffName(data.dwID, data.nLevelEx)
			if data.nIcon and tonumber(data.nIcon) then
				icon = data.nIcon
			end
			item.szName = szName
			local box = item:Lookup('Box')
			box:SetObject(UI_OBJECT_NOT_NEED_KNOWN, data.dwID, data.nLevelEx)
			box:SetObjectIcon(icon)
			box:SetObjectStaring(CFG.bStaring)
			local fScale = 1
			if CFG.bAutoBuffSize then
				if CFG.fScaleY > 1 then
					fScale = CFG.fScaleY
				end
				fScale = fScale * 0.8 -- INI画大了不好调 这里调整下吧
			else
				fScale = CFG.fBuffScale
			end
			item:Scale(fScale, fScale)
			local txtTime = item:Lookup('Text_Time')
			local fFontScale = fScale * 0.9 / (1 + Font.GetOffset() * 0.07)
			txtTime:SetFontScale(fFontScale * (item:GetH() / txtTime:GetH()) * 0.6)
			local txtStackNum = item:Lookup('Text_StackNum')
			txtStackNum:SetFontScale(fFontScale * (item:GetH() / txtStackNum:GetH()) * 0.55)
			txtStackNum:SetFontColor(255, 255, 255)
			local txtReminder = item:Lookup('Text_Reminder')
			txtReminder:SetText(data.szReminder)
			txtReminder:SetVisible(CFG.bShowBuffReminder)
			txtReminder:SetFontScale(fFontScale * (item:GetH() / txtReminder:GetH()) * 0.6)
			txtReminder:SetFontColor(r or 255, g or 255, b or 255)
			handle:FormatAllItemPos()
		end
		-- revise
		if item then
			-- update data
			item.dwID = buff.dwID
			item.nLevel = buff.nLevel
			item.nEndFrame = nEndFrame
			item.nStackNum = nStackNum
			item.szVia = data.szVia
			-- buff time
			local txtTime = item:Lookup('Text_Time')
			if CFG.bShowBuffTime then
				local nTime, r, g, b = MY_GetEndTime(nEndFrame)
				if nTime <= 5 then
					if nTime >= 0 then
						r, g, b = 255, 0, 0
					end
				elseif nTime <= 30 then
					r, g, b = 255, 255, 0
				end
				if r and g and b then
					txtTime:SetText(floor(nTime) .. '"')
					txtTime:SetFontColor(r, g, b)
				else
					txtTime:SetText('')
				end
			end
			txtTime:SetVisible(CFG.bShowBuffTime)
			-- buff stack number
			local txtStackNum = item:Lookup('Text_StackNum')
			if CFG.bShowBuffNum and nStackNum > 1 then
				txtStackNum:SetText(nStackNum)
			else
				txtStackNum:SetText('')
			end
			txtStackNum:SetVisible(CFG.bShowBuffNum)
		end
		-- update attention
		if data.bAttention then
			if not CTM_ATTENTION_BUFF[dwCharID] then
				CTM_ATTENTION_BUFF[dwCharID] = {}
			end
			if not CTM_ATTENTION_STACK[dwCharID] then
				CTM_ATTENTION_STACK[dwCharID] = {}
			end
			if not CTM_ATTENTION_BUFF[dwCharID][key] then
				local rec = {
					col = data.col or 'yellow',
				}
				CTM_ATTENTION_BUFF[dwCharID][key] = rec
				insert(CTM_ATTENTION_STACK[dwCharID], 1, rec)
			end
		end
		-- update caution
		if data.bCaution then
			if not CTM_CAUTION_BUFF[dwCharID] then
				CTM_CAUTION_BUFF[dwCharID] = {}
			end
			CTM_CAUTION_BUFF[dwCharID][key] = true
		end
		-- update screen head
		if data.bScreenHead then
			if not CTM_SCREEN_HEAD[dwCharID] then
				CTM_SCREEN_HEAD[dwCharID] = {}
			end
			if not CTM_SCREEN_HEAD[dwCharID][key] then
				FireUIEvent('MY_LIFEBAR_COUNTDOWN', dwCharID, 'BUFF', 'CTM_' .. item.dwID, {
					dwBuffID = item.dwID,
					szText = item.szName,
					nLogicFrame = item.nEndFrame,
					col = data.colScreenHead or data.col,
				})
				CTM_SCREEN_HEAD[dwCharID][key] = 'CTM_' .. item.dwID
			end
		end
	else
		if item then
			handle:RemoveItem(item)
			handle:FormatAllItemPos() -- 格式化buff的位置
		end
		local rec = CTM_ATTENTION_BUFF[dwCharID] and CTM_ATTENTION_BUFF[dwCharID][key]
		if rec then
			for i, vv in ipairs_r(CTM_ATTENTION_STACK[dwCharID]) do
				if vv == rec then
					remove(CTM_ATTENTION_STACK[dwCharID], i)
					break
				end
			end
			CTM_ATTENTION_BUFF[dwCharID][key] = nil
		end
		if CTM_CAUTION_BUFF[dwCharID] then
			CTM_CAUTION_BUFF[dwCharID][key] = nil
		end
		if CTM_SCREEN_HEAD[dwCharID] and CTM_SCREEN_HEAD[dwCharID][key] then
			FireUIEvent('MY_LIFEBAR_COUNTDOWN', dwCharID, 'BUFF', CTM_SCREEN_HEAD[dwCharID][key], false)
			CTM_SCREEN_HEAD[dwCharID][key] = nil
		end
	end
end

function CTM:RefreshBuff()
	local team, me = GetClientTeam(), GetClientPlayer()
	local tKeep = {}
	for k, v in ipairs(team.GetTeamMemberList()) do
		local p = GetPlayer(v)
		if CTM_CACHE[v] and CTM_CACHE[v]:IsValid() and p then
			local handle = CTM_CACHE[v]:Lookup('Handle_Buff_Boxes')
			for key, data in pairs(CTM_BUFF_CACHE) do
				local buff = (not data.bOnlyMe or p.dwID == me.dwID)
					and MY_GetBuff(p, data.dwID, data.nLevel, data.bOnlyMine and me.dwID)
					or nil
				local item = handle:Lookup(key)
				if buff then
					if buff.nStackNum and data.nStackNum
					and not LIB.JudgeOperator(data.szStackOp or '>=', buff.nStackNum, data.nStackNum) then
						buff = nil
					end
					tKeep[key] = true
				end
				D.UpdateCharaterBuff(p, handle, key, data, buff)
			end
		elseif CTM_CACHE[v] and CTM_CACHE[v]:IsValid() then
			local handle = CTM_CACHE[v]:Lookup('Handle_Buff_Boxes')
			handle:Clear()
		end
	end
	for k, v in pairs(CTM_BUFF_CACHE) do
		if not tKeep[k] then
			CTM_BUFF_CACHE[k] = nil
		end
	end
	-- print(CTM_BUFF_CACHE)
end

function CTM:RecBossFocusBuff(dwMemberID, data)
	CTM_BOSS_FOCUS_BUFF[data.dwID .. '#' .. data.nLevel] = data
end

function CTM:RefreshBossFocus()
	local team, me = GetClientTeam(), GetClientPlayer()
	for k, v in ipairs(team.GetTeamMemberList()) do
		if CTM_CACHE[v] and CTM_CACHE[v]:IsValid() then
			local p, bFocus = GetPlayer(v), nil
			if p then
				for _, data in pairs(CTM_BOSS_FOCUS_BUFF) do
					local buff = MY_GetBuff(p, data.dwID, data.nLevel)
					if buff and buff.nStackNum >= data.nStackNum then
						bFocus = true
						break
					end
				end
			end
			CTM_BOSS_FOCUSED_STATE[v] = bFocus
		end
	end
	self:RefreshCaution()
end

function CTM:RefreshDistance()
	for k, v in pairs(CTM_CACHE) do
		if v:IsValid() then
			local p = GetPlayer(k) -- info.nPoX 刷新太慢了 对于治疗来说 这个太重要了
			if p then
				local nDistance = MY_GetDistance(p) -- 只计算平面 --??
				if CFG.bEnableDistance then
					local find
					for kk, vv in ipairs(CFG.tDistanceLevel) do
						if nDistance <= vv then
							if v.nDistanceLevel ~= kk then
								v.nDistanceLevel = kk
								self:CallDrawHPMP(k, true)
							end
							find = true
							break
						end
					end
					-- 如果上面都不匹配的话 默认认为出了同步范围 feedback 桥之于水
					if not find and v.nDistanceLevel then
						v.nDistanceLevel = nil
						self:CallDrawHPMP(k, true)
					end
				else
					v.nDistance = 0
					v.nDistanceLevel = 1
				end
				if CFG.bShowDistance then
					v:Lookup('Text_Distance'):SetText(string.format('%.1f', nDistance))
					v:Lookup('Text_Distance'):SetFontColor(255, math.max(0, 255 - nDistance * 8), math.max(0, 255 - nDistance * 8))
				else
					v:Lookup('Text_Distance'):SetText('')
				end
			else
				if CFG.bShowDistance then
					v:Lookup('Text_Distance'):SetText('')
				end
				if v.nDistance or v.nDistanceLevel then
					v.nDistance = nil
					v.nDistanceLevel = nil
					self:CallDrawHPMP(k, true)
				end
			end
		end
	end
end

-- 血量 / 内力
function CTM:CallDrawHPMP(dwID, ...)
	if type(dwID) == 'number' then
		local info = self:GetMemberInfo(dwID)
		if info and CTM_CACHE[dwID] and CTM_CACHE[dwID]:IsValid() then
			self:DrawHPMP(CTM_CACHE[dwID], dwID, info, ...)
		end
	else
		for k, v in pairs(CTM_CACHE) do
			if v:IsValid() then
				local info = self:GetMemberInfo(k)
				if info then
					self:DrawHPMP(v, k, info, ...)
				end
			end
		end
	end
end

-- 缩放对动态构建的UI不会缩放 所以需要后处理
function CTM:DrawHPMP(h, dwID, info, bRefresh)
	if not info then return end
	local bSha = CFG.nBGColorMode ~= CTM_BG_COLOR_MODE.OFFICIAL
	local hLife = h:Lookup('Handle_Life')
	local hMana = h:Lookup('Handle_Mana')
	local Lsha = hLife:Lookup('Shadow_Life')
	local Limg = hLife:Lookup('Image_Life')
	local Ledg = hLife:Lookup('Image_LifeLine')
	local Msha = hMana:Lookup('Shadow_Mana')
	local Mimg = hMana:Lookup('Image_Mana')
	local player, npc, dwMountType
	if CHANGGE_REAL_SHADOW_CACHE[dwID] then
		npc = GetNpc(CHANGGE_REAL_SHADOW_CACHE[dwID])
	end
	if CFG.bFasterHP then
		player = GetPlayer(dwID)
	end
	-- 气血计算 因为sync 必须拿出来单独算
	local obj = npc or player
	local nLifePercentage, nCurrentLife, nMaxLife
	if obj and obj.nMaxLife ~= 1 and obj.nCurrentLife ~= 1 and obj.nCurrentLife ~= 255
	and obj.nMaxLife ~= 255 and obj.nCurrentLife < 1000000 and obj.nCurrentLife > - 1000 then -- obj sync err fix
		nCurrentLife = obj.nCurrentLife
		nMaxLife = obj.nMaxLife
	else
		nCurrentLife = info.nCurrentLife
		nMaxLife = info.nMaxLife
	end
	nMaxLife     = max(1, nMaxLife)
	nCurrentLife = max(0, nCurrentLife)
	nLifePercentage = nMaxLife ~= 0 and (nCurrentLife / nMaxLife)
	if not nLifePercentage or nLifePercentage < 0 or nLifePercentage > 1 then
		nLifePercentage = 1
	end
	Lsha:SetVisible(bSha)
	Msha:SetVisible(bSha)
	Limg:SetVisible(not bSha)
	Ledg:SetVisible(not bSha)
	Mimg:SetVisible(not bSha)

	local bDeathFlag = info.bDeathFlag
	-- 有待验证
	if player then
		if player.GetKungfuMount() then
			dwMountType = player.GetKungfuMount().dwMountType
		end
		if player.nMoveState == MOVE_STATE_ON_STAND then
			if info.bDeathFlag then
				bDeathFlag = true
			end
		else
			bDeathFlag = player.nMoveState == MOVE_STATE_ON_DEATH
		end
	end
	-- 透明度
	local nAlpha = 255
	if CFG.nBGColorMode ~= CTM_BG_COLOR_MODE.BY_DISTANCE then
		if h.nDistanceLevel then
			nAlpha = CFG.tDistanceAlpha[h.nDistanceLevel]
		elseif info.bIsOnLine then
			nAlpha = CFG.tOtherAlpha[3]
		else
			nAlpha = CFG.tOtherAlpha[2]
		end
	else
		nAlpha = 255
	end
	-- 内力
	if not bDeathFlag then
		local nPercentage, nManaShow = 1, 1
		local mana = h:Lookup('Text_Mana')
		if not IsPlayerManaHide(info.dwForceID, dwMountType) then -- 内力不需要那么准
			nPercentage = info.nMaxMana ~= 0 and (info.nCurrentMana / info.nMaxMana)
			nManaShow = info.nCurrentMana
			if not CFG.nShowMP then
				mana:SetText('')
			else
				mana:SetText(nManaShow)
			end
			mana:SetFontScheme(CFG.nManaFont)
			mana:SetFontScale(CFG.fManaFontScale)
		end
		if not nPercentage or nPercentage < 0 or nPercentage > 1 then
			nPercentage = 1
		end
		if bSha then
			local r, g, b = unpack(CFG.tManaColor)
			if not info.bIsOnLine then
				r, g, b = unpack(CFG.tOtherCol[2]) -- 不在线就灰色了
			end
			self:DrawShadow(Msha, hMana:GetW() * nPercentage, Msha:GetH(), r, g, b, nAlpha, CFG.bManaGradient)
			Msha:Show()
		else
			if info.bIsOnLine then
				Mimg:ToNormal()
			else
				Mimg:ToGray()
			end
			Mimg:Show()
			Mimg:SetAlpha(nAlpha)
			Mimg:SetPercentage(nPercentage)
		end
	else
		Mimg:Hide()
	end
	-- 掉血警告 必须早于血条绘制
	if CFG.bHPHitAlert then
		local lifeFade = hLife:Lookup('Shadow_Life_Fade')
		if CTM_LIFE_CACHE[dwID] and CTM_LIFE_CACHE[dwID] > nLifePercentage then
			local nAlpha, nW, nH = lifeFade:GetAlpha(), 0, 0
			if nAlpha == 0 then
				if bSha then
					nW, nH = Lsha:GetSize()
				else
					nW, nH = Limg:GetSize()
				end
				lifeFade:SetSize(nW * CTM_LIFE_CACHE[dwID], nH)
			end
			lifeFade:SetAlpha(240)
			lifeFade:Show()

			local key = 'CTM_HIT_' .. dwID
			LIB.BreatheCall(key, false)
			LIB.BreatheCall(key, function()
				if lifeFade:IsValid() then
					local nFadeAlpha = math.max(lifeFade:GetAlpha() - CTM_ALPHA_STEP, 0)
					lifeFade:SetAlpha(nFadeAlpha)
					if nFadeAlpha <= 0 then
						LIB.BreatheCall(key, false)
					end
				else
					LIB.BreatheCall(key, false)
				end
			end)
		end
	else
		hLife:Lookup('Shadow_Life_Fade'):Hide()
	end
	-- 缓存
	if not CFG.bFasterHP or bRefresh or (CFG.bFasterHP and CTM_LIFE_CACHE[dwID] ~= nLifePercentage) then
		if bSha then
			-- 颜色计算
			local nNewW = hLife:GetW() * nLifePercentage
			local r, g, b = unpack(CFG.tOtherCol[2]) -- 不在线就灰色了
			if info.bIsOnLine then
				if CFG.nBGColorMode == CTM_BG_COLOR_MODE.BY_DISTANCE then
					if player or GetPlayer(dwID) then
						if h.nDistanceLevel then
							r, g, b = unpack(CFG.tDistanceCol[h.nDistanceLevel])
						else
							r, g, b = unpack(CFG.tOtherCol[3])
						end
					else
						r, g, b = unpack(CFG.tOtherCol[3]) -- 在线使用白色
					end
				elseif CFG.nBGColorMode == CTM_BG_COLOR_MODE.SAME_COLOR then
					r, g, b = unpack(CFG.tDistanceCol[1]) -- 使用用户配色1
				elseif CFG.nBGColorMode == CTM_BG_COLOR_MODE.BY_FORCE then
					r, g, b = LIB.GetForceColor(info.dwForceID, 'background')
				end
			end
			self:DrawShadow(Lsha, nNewW, Lsha:GetH(), r, g, b, nAlpha, CFG.bLifeGradient)
			Lsha:Show()
		else
			local nRelX = Limg:GetRelX() + Limg:GetW() * nLifePercentage - Ledg:GetW()
			Ledg:Show()
			Ledg:SetAlpha(nAlpha)
			Ledg:SetRelX(nRelX)
			Ledg:SetAbsX(hLife:GetAbsX() + nRelX)
			if info.bIsOnLine then
				Limg:ToNormal()
			else
				Limg:ToGray()
			end
			Limg:Show()
			Limg:SetAlpha(nAlpha)
			Limg:SetPercentage(nLifePercentage)
		end

		if not CTM_LIFE_CACHE[dwID] then
			CTM_LIFE_CACHE[dwID] = 0
		else
			CTM_LIFE_CACHE[dwID] = nLifePercentage
		end
		-- 数值绘制
		local life = h:Lookup('Text_Life')
		local nFontAlpha = min(nAlpha * 0.4 + 255 * 0.6, 255)
		if not info.bIsOnLine then
			nFontAlpha = nFontAlpha * 0.8
		end
		life:SetAlpha(nAlpha == 0 and 0 or nFontAlpha)
		life:SetFontScheme(CFG.nLifeFont)
		life:SetFontScale(CFG.fLifeFontScale)
		h:Lookup('Text_Name'):SetAlpha(nFontAlpha)

		if not bDeathFlag and info.bIsOnLine then
			life:SetFontColor(255, 255, 255)
			if CFG.nHPShownMode2 == 0 then
				life:SetText('')
			else
				local fnAction = function(val, max)
					if CFG.nHPShownNumMode == 1 then
						if val > 9999 then
							val = (CFG.bShowHPDecimal and '%.1fw' or '%dw'):format(val / 10000)
						end
					elseif CFG.nHPShownNumMode == 2 then
						val = (CFG.bShowHPDecimal and '%.1f%%' or '%d%%'):format(val / max * 100)
					end
					return val
				end
				if CFG.nHPShownMode2 == 2 then
					life:SetText(fnAction(nCurrentLife, nMaxLife))
				elseif CFG.nHPShownMode2 == 1 then
					local nShownLife = nMaxLife - nCurrentLife
					if nShownLife > 0 then
						life:SetText('-' .. fnAction(nShownLife, nMaxLife))
					else
						life:SetText('')
					end
				end
			end
		elseif not info.bIsOnLine then
			life:SetText('')
		elseif bDeathFlag then
			life:SetText('')
		else
			life:SetFontColor(128, 128, 128)
			life:SetText(COINSHOP_SOURCE_NULL)
		end
		-- if info.dwMountKungfuID == 0 then -- 没有同步成功时显示的内容
			-- life:SetText('sync ...')
		-- end
		h:Lookup('Text_Death'):SetVisible(bDeathFlag)
		h:Lookup('Text_OffLine'):SetVisible(not info.bIsOnLine)
		h:Lookup('Text_Death'):SetFontScale(CFG.fLifeFontScale)
		h:Lookup('Text_OffLine'):SetFontScale(CFG.fLifeFontScale)
		h:Lookup('Image_PlayerBg'):SetVisible(info.bIsOnLine)
	end
end

function CTM:DrawShadow(sha, x, y, r, g, b, a, bGradient) -- 重绘三角扇
	sha:SetTriangleFan(GEOMETRY_TYPE.TRIANGLE)
	sha:ClearTriangleFanPoint()
	if bGradient then
		sha:AppendTriangleFanPoint(0, 0, 64, 64, 64, a)
		sha:AppendTriangleFanPoint(x, 0, 64, 64, 64, a)
		sha:AppendTriangleFanPoint(x, y, r, g, b, a)
		sha:AppendTriangleFanPoint(0, y, r, g, b, a)
	else
		sha:AppendTriangleFanPoint(0, 0, r, g, b, a)
		sha:AppendTriangleFanPoint(x, 0, r, g, b, a)
		sha:AppendTriangleFanPoint(x, y, r, g, b, a)
		sha:AppendTriangleFanPoint(0, y, r, g, b, a)
	end
end

do
local VOTE_OPTIONS = {
	['raid_ready'] = { awaitPath = 'Image_ReadyCover', rejectPath = 'Image_NotReady', resolvePath = 'Animate_Ready', timeoutAlert = 5000 },
	['wage_agree'] = { awaitPath = 'Handle_TeamVoteWait', rejectPath = 'Handle_TeamVoteReject', timeout = 30000 },
}
function CTM:StartTeamVote(eType)
	local opt = VOTE_OPTIONS[eType]
	if not opt then
		return
	end
	self:ClearTeamVote(eType)
	for k, v in pairs(CTM_CACHE) do
		if v:IsValid() then
			local info = self:GetMemberInfo(k)
			local bAwait = info.bIsOnLine
			if k == UI_GetClientPlayerID() then
				if eType == 'raid_ready' then
					bAwait = false
				elseif eType == 'wage_agree' then
					bAwait = not LIB.IsDistributer()
				end
			end
			if bAwait then
				v:Lookup(opt.awaitPath):Show()
			end
		end
	end
	if opt.timeoutAlert then
		LIB.DelayCall(opt.timeoutAlert, function()
			for k, v in pairs(CTM_CACHE) do
				if v:IsValid() then
					if v:Lookup(opt.awaitPath):IsVisible() or v:Lookup(opt.rejectPath):IsVisible() then
						LIB.Confirm(g_tStrings.STR_RAID_READY_CONFIRM_RESET .. '?', function()
							self:ClearTeamVote(eType)
						end)
						break
					end
				end
			end
		end)
	end
	if opt.timeout then
		LIB.DelayCall(opt.timeout, function()
			self:ClearTeamVote(eType)
		end)
	end
end

function CTM:ChangeTeamVoteState(eType, dwID, status)
	local opt = VOTE_OPTIONS[eType]
	if not opt then
		return
	end
	if CTM_CACHE[dwID] and CTM_CACHE[dwID]:IsValid() then
		local h = CTM_CACHE[dwID]
		h:Lookup(opt.awaitPath):Hide()
		if status == 'resolve' and opt.resolvePath then
			local key = 'CTM_READY_' .. eType .. '_' .. dwID
			h:Lookup(opt.resolvePath):Show()
			h:Lookup(opt.resolvePath):SetAlpha(240)
			LIB.BreatheCall(key, function()
				if h:Lookup(opt.resolvePath):IsValid() then
					local nAlpha = math.max(h:Lookup(opt.resolvePath):GetAlpha() - 15, 0)
					h:Lookup(opt.resolvePath):SetAlpha(nAlpha)
					if nAlpha <= 0 then
						LIB.BreatheCall(key, false)
					end
				end
			end)
		elseif status == 'reject' then
			h:Lookup(opt.rejectPath):Show()
		end
	end
end

function CTM:ClearTeamVote(eType)
	local opt = VOTE_OPTIONS[eType]
	if not opt then
		return
	end
	for k, v in pairs(CTM_CACHE) do
		if v:IsValid() then
			for _, k in ipairs({ 'resolvePath', 'rejectPath', 'awaitPath' }) do
				if opt[k] and v:Lookup(opt[k]) then
					v:Lookup(opt[k]):Hide()
				end
			end
		end
	end
end
end

function CTM:CallEffect(dwTargetID, nDelay)
	if CTM_CACHE[dwTargetID] and CTM_CACHE[dwTargetID]:IsValid() then
		LIB.DelayCall('MY_Cataclysm_' .. dwTargetID, nDelay, function()
			if CTM_CACHE[dwTargetID] and CTM_CACHE[dwTargetID]:IsValid() then
				CTM_CACHE[dwTargetID]:Lookup('Image_Effect'):Hide()
			end
		end)
		CTM_CACHE[dwTargetID]:Lookup('Image_Effect'):Show()
	end
end

local function GetMemberHandle(dwID)
	if CTM_CACHE[dwID] and CTM_CACHE[dwID]:IsValid() then
		return CTM_CACHE[dwID]
	end
end

local ui = {
	GetMemberHandle = GetMemberHandle,
}
MY_CataclysmParty = setmetatable(ui, { __index = CTM, __newindex = function() end, __metatable = true })
