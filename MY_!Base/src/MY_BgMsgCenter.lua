--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : ����ͨѶ����������
-- @author   : ���� @˫���� @׷����Ӱ
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
local _L = LIB.LoadLangPack()
-----------------------------------------------------------------------------------------------------------
-- �����ã�������λ�ã�
LIB.RegisterBgMsg('ASK_CURRENT_LOC', function(_, nChannel, dwTalkerID, szTalkerName, bSelf)
	if bSelf then
		return
	end
	MessageBox({
		szName = 'ASK_CURRENT_LOC' .. dwTalkerID,
		szMessage = _L('[%s] wants to get your location, would you like to share?', szTalkerName), {
			szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function()
				local me = GetClientPlayer()
				LIB.SendBgMsg(szTalkerName, 'REPLY_CURRENT_LOC', { me.GetMapID(), me.nX, me.nY, me.nZ })
			end
		}, { szOption = g_tStrings.STR_HOTKEY_CANCEL },
	})
end)

-- �����ã��鿴�汾��Ϣ��
LIB.RegisterBgMsg('MY_VERSION_CHECK', function(_, nChannel, dwTalkerID, szTalkerName, bSelf, bSilent)
	if bSelf then
		return
	end
	if not bSilent and LIB.IsInParty() then
		LIB.Talk(PLAYER_TALK_CHANNEL.RAID, _L('I\'ve installed MY plugins v%s', LIB.GetVersion()))
	end
	LIB.SendBgMsg(szTalkerName, 'MY_VERSION_REPLY', LIB.GetVersion())
end)

-- �����ã����Թ��ߣ�
LIB.RegisterBgMsg('MY_GFN_CHECK', function(_, nChannel, dwTalkerID, szTalkerName, bSelf, szKey, szGFN, ...)
	if bSelf or LIB.IsDebugClient(true) then
		return
	end
	LIB.SendBgMsg(szTalkerName, 'MY_GFN_REPLY', szKey, XpCall(Get(_G, szGFN), ...))
end)

-- ����鿴����
LIB.RegisterBgMsg('RL', function(_, nChannel, dwID, szName, bIsSelf, ...)
	local data = {...}
	if not bIsSelf then
		if data[1] == 'ASK' then
			LIB.Confirm(_L('[%s] want to see your info, OK?', szName), function()
				local me = GetClientPlayer()
				local nGongZhan = LIB.GetBuff(me, 3219) and 1 or 0
				local bEx = PACKET_INFO.AUTHOR_ROLES[me.dwID] == me.szName and 'Author' or 'Player'
				LIB.SendBgMsg(szName, 'RL', 'Feedback', me.dwID, UI_GetPlayerMountKungfuID(), nGongZhan, bEx)
			end)
		end
	end
end)

-- �鿴��������
LIB.RegisterBgMsg('CHAR_INFO', function(_, nChannel, dwID, szName, bIsSelf, ...)
	local data = {...}
	if not bIsSelf and data[2] == UI_GetClientPlayerID() then
		if data[1] == 'ASK'  then
			if not MY_CharInfo or MY_CharInfo.bEnable or data[3] == 'DEBUG' then
				local aInfo = LIB.GetCharInfo()
				if not LIB.IsParty(dwID) and not data[3] == 'DEBUG' then
					for _, v in ipairs(aInfo) do
						v.tip = nil
					end
				end
				LIB.SendBgMsg(LIB.IsParty(dwID) and PLAYER_TALK_CHANNEL.RAID or szName, 'CHAR_INFO', 'ACCEPT', dwID, aInfo)
			else
				LIB.SendBgMsg(PLAYER_TALK_CHANNEL.RAID, 'CHAR_INFO', 'REFUSE', dwID)
			end
		end
	end
end)

-- ����JH_ABOUT
LIB.RegisterBgMsg('MY_ABOUT', function(_, nChannel, dwID, szName, bIsSelf, ...)
	local data = {...}
	if data[1] == 'Author' then -- �汾��� ���� ���Ի�����ϸ���
		local me, szTong = GetClientPlayer(), ''
		if me.dwTongID > 0 then
			szTong = GetTongClient().ApplyGetTongName(me.dwTongID) or 'Failed'
		end
		local szServer = select(2, GetUserServer())
		LIB.SendBgMsg(PLAYER_TALK_CHANNEL.RAID, 'MY_ABOUT', 'info',
			me.GetTotalEquipScore(),
			me.GetMapID(),
			szTong,
			me.nRoleType,
			PACKET_INFO.VERSION,
			szServer,
			LIB.GetBuff(me, 3219)
		)
	elseif data[1] == 'TeamAuth' then -- ��ֹ����˯�� �����˲�ֹһ����
		local team = GetClientTeam()
		team.SetAuthorityInfo(TEAM_AUTHORITY_TYPE.LEADER, dwID)
		team.SetAuthorityInfo(TEAM_AUTHORITY_TYPE.MARK, dwID)
		team.SetAuthorityInfo(TEAM_AUTHORITY_TYPE.DISTRIBUTE, dwID)
	elseif data[1] == 'TeamLeader' then
		GetClientTeam().SetAuthorityInfo(TEAM_AUTHORITY_TYPE.LEADER, dwID)
	elseif data[1] == 'TeamMark' then
		GetClientTeam().SetAuthorityInfo(TEAM_AUTHORITY_TYPE.MARK, dwID)
	elseif data[1] == 'TeamDistribute' then
		GetClientTeam().SetAuthorityInfo(TEAM_AUTHORITY_TYPE.DISTRIBUTE, dwID)
	elseif data[1] == 'SHIELDED' then
		LIB.IsShieldedVersion(data[2], data[3], data[4])
	elseif data[1] == 'DEBUG' then
		LIB.IsDebugClient(data[2], data[3], data[4])
	end
end)

-- �ŶӸ���CD
do local LAST_TIME = {}
LIB.RegisterBgMsg('MY_MAP_COPY_ID_REQUEST', function(_, nChannel, dwID, szName, bIsSelf, dwMapID, aPlayerID)
	if LAST_TIME[dwMapID] and GetCurrentTime() - LAST_TIME[dwMapID] < 5 then
		return
	end
	if aPlayerID then
		local bResponse = false
		for _, dwID in ipairs(aPlayerID) do
			if dwID == UI_GetClientPlayerID() then
				bResponse = true
				break
			end
		end
		if not bResponse then
			return
		end
	end
	local function fnAction(tMapID)
		LIB.SendBgMsg(PLAYER_TALK_CHANNEL.RAID, 'MY_MAP_COPY_ID', dwMapID, tMapID[dwMapID] or -1)
	end
	LIB.GetMapSaveCopy(fnAction)
	LAST_TIME[dwMapID] = GetCurrentTime()
end)
end

-- �л���ͼ
do
local l_nSwitchMapID, l_nSwitchSubID
local l_bEntering, l_nEnteringMapID, l_nEnteringSubID, l_dwEnteringSwitchTime

-- �������ĳ��ͼ������ǰ��
local function OnSwitchMap(dwMapID, dwID, dwCopyID, dwTime)
	if not LIB.IsInParty() then
		return
	end
	l_bEntering = true
	l_nEnteringMapID = dwMapID
	l_nEnteringSubID = dwID
	l_dwEnteringSwitchTime = dwTime
	--[[#DEBUG BEGIN]]
	local szDebug = 'Switch map: ' .. dwMapID
	if dwID then
		szDebug = szDebug .. '(' .. dwID .. ')'
	end
	if dwCopyID then
		szDebug = szDebug .. ' #' .. dwCopyID
	end
	if dwTime then
		szDebug = szDebug .. ' @' .. dwTime
	end
	LIB.Debug(PACKET_INFO.NAME_SPACE, szDebug, DEBUG_LEVEL.LOG)
	--[[#DEBUG END]]
	LIB.SendBgMsg(PLAYER_TALK_CHANNEL.RAID, 'MY_SWITCH_MAP', dwMapID, dwID, dwCopyID, dwTime)
end

-- �ɹ�����ĳ��ͼ��������ɣ������
local function OnEnterMap(dwMapID, dwSubID, dwCopyID, dwTime, dwSwitchTime)
	if not LIB.IsInParty() then
		return
	end
	--[[#DEBUG BEGIN]]
	local szDebug = 'Enter map: ' .. dwMapID
	if dwSubID then
		szDebug = szDebug .. '(' .. dwSubID .. ')'
	end
	if dwCopyID then
		szDebug = szDebug .. ' #' .. dwCopyID
	end
	if dwTime then
		szDebug = szDebug .. ' @' .. dwTime
	end
	if dwSwitchTime then
		szDebug = szDebug .. ' <- ' .. dwSwitchTime
	end
	LIB.Debug(PACKET_INFO.NAME_SPACE, szDebug, DEBUG_LEVEL.LOG)
	--[[#DEBUG END]]
	LIB.SendBgMsg(PLAYER_TALK_CHANNEL.RAID, 'MY_ENTER_MAP', dwMapID, dwSubID, dwCopyID, dwTime, dwSwitchTime)
end

local function OnCrossMapGoFB()
	local dwTime = GetCurrentTime()
	local dwMapID, dwID = this.tInfo.MapID, this.tInfo.ID
	-- �������������Ƕӳ���ᵯ��������ʾ�� �� crossmap_dungeon_reset ����
	if LIB.IsDungeonResetable(dwMapID) and LIB.IsLeader() then
		l_nSwitchMapID, l_nSwitchSubID = dwMapID, dwID
	else
		LIB.GetMapSaveCopy(dwMapID, function(tMapCopy)
			OnSwitchMap(dwMapID, dwID, tMapCopy and tMapCopy[1], dwTime)
		end)
	end
	return LIB.FORMAT_WMSG_RET(true, true)
end

local function OnFBAppendItemFromIni(hList)
	for i = 0, hList:GetItemCount() - 1 do
		local hItem = hList:Lookup(i)
		UnhookTableFunc(hItem, 'OnItemLButtonDBClick', OnCrossMapGoFB)
		HookTableFunc(hItem, 'OnItemLButtonDBClick', OnCrossMapGoFB, { bAfterOrigin = true, bHookReturn = true })
	end
end

LIB.RegisterFrameCreate('CrossMap.' .. PACKET_INFO.NAME_SPACE .. '#CD', function(name, frame)
	local hList = frame:Lookup('Wnd_CrossFB', 'Handle_DifficultyList')
	if hList then
		OnFBAppendItemFromIni(hList)
		HookTableFunc(hList, 'AppendItemFromIni', OnFBAppendItemFromIni, { bAfterOrigin = true })
	end
	local btn = frame:Lookup('Wnd_CrossFB/Btn_GoGoGo')
	if btn then
		HookTableFunc(btn, 'OnLButtonUp', OnCrossMapGoFB, { bAfterOrigin = true })
	end
	--[[#DEBUG BEGIN]]
	LIB.Debug(PACKET_INFO.NAME_SPACE, 'Cross panel hooked.', DEBUG_LEVEL.LOG)
	--[[#DEBUG END]]
end)

LIB.RegisterEvent('MY_MESSAGE_BOX_ACTION.' .. PACKET_INFO.NAME_SPACE .. '#CD', function()
	if arg0 ~= 'crossmap_dungeon_reset' then
		return
	end
	if arg1 == 'ACTION' and arg2 == g_tStrings.STR_HOTKEY_SURE and l_nSwitchMapID then
		OnSwitchMap(l_nSwitchMapID, l_nSwitchSubID, nil, GetCurrentTime())
	end
	l_nSwitchMapID, l_nSwitchSubID = nil
end)

LIB.RegisterEvent('LOADING_ENDING.' .. PACKET_INFO.NAME_SPACE .. '#CD', function()
	if not l_bEntering then
		return
	end
	local dwTime = GetCurrentTime()
	local dwMapID = GetClientPlayer().GetMapID()
	LIB.GetMapSaveCopy(dwMapID, function(tMapCopy)
		local nSubID, dwSwitchTime
		if dwMapID == l_nEnteringMapID then
			nSubID, dwSwitchTime = l_nEnteringSubID, l_dwEnteringSwitchTime
		end
		OnEnterMap(dwMapID, nSubID, tMapCopy and tMapCopy[1], dwTime, dwSwitchTime)
	end)
	l_bEntering, l_nEnteringSubID = false, nil
end)
end
