--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : ����ͨѶ����������
-- @author   : ���� @˫���� @׷����Ӱ
-- @modifier : Emil Zhai (root@derzh.com)
-- @copyright: Copyright (c) 2013 EMZ Kingsoft Co., Ltd.
--------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- these global functions are accessed all the time by the event handler
-- so caching them is worth the effort
---------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local ipairs, pairs, next, pcall = ipairs, pairs, next, pcall
local sub, len, format, rep = string.sub, string.len, string.format, string.rep
local find, byte, char, gsub = string.find, string.byte, string.char, string.gsub
local type, tonumber, tostring = type, tonumber, tostring
local huge, pi, random = math.huge, math.pi, math.random
local min, max, floor, ceil = math.min, math.max, math.floor, math.ceil
local pow, sqrt, sin, cos, tan = math.pow, math.sqrt, math.sin, math.cos, math.tan
local insert, remove, concat, sort = table.insert, table.remove, table.concat, table.sort
local pack, unpack = table.pack or function(...) return {...} end, table.unpack or unpack
-- jx3 apis caching
local wsub, wlen, wfind = wstring.sub, wstring.len, wstring.find
local GetTime, GetLogicFrameCount = GetTime, GetLogicFrameCount
local GetClientPlayer, GetPlayer, GetNpc = GetClientPlayer, GetPlayer, GetNpc
local GetClientTeam, UI_GetClientPlayerID = GetClientTeam, UI_GetClientPlayerID
local IsNil, IsBoolean, IsEmpty, RandomChild = MY.IsNil, MY.IsBoolean, MY.IsEmpty, MY.RandomChild
local IsNumber, IsString, IsTable, IsFunction = MY.IsNumber, MY.IsString, MY.IsTable, MY.IsFunction
---------------------------------------------------------------------------------------------------
-- �����ã�������λ�ã�
MY.RegisterBgMsg('ASK_CURRENT_LOC', function(_, nChannel, dwTalkerID, szTalkerName, bSelf)
	if bSelf then
		return
	end
	MessageBox({
		szName = 'ASK_CURRENT_LOC' .. dwTalkerID,
		szMessage = _L('[%s] wants to get your location, would you like to share?', szTalkerName), {
			szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function()
				local me = GetClientPlayer()
				MY.BgTalk(szTalkerName, 'REPLY_CURRENT_LOC', { me.GetMapID(), me.nX, me.nY, me.nZ })
			end
		}, { szOption = g_tStrings.STR_HOTKEY_CANCEL },
	})
end)

-- �����ã��鿴�汾��Ϣ��
MY.RegisterBgMsg('MY_VERSION_CHECK', function(_, nChannel, dwTalkerID, szTalkerName, bSelf, bSilent)
	if bSelf then
		return
	end
	if not bSilent and MY.IsInParty() then
		MY.Talk(PLAYER_TALK_CHANNEL.RAID, _L('I\'ve installed MY plugins v%s', MY.GetVersion()))
	end
	MY.BgTalk(szTalkerName, 'MY_VERSION_REPLY', MY.GetVersion())
end)

-- �鿴����
MY.RegisterBgMsg('RL', function(_, nChannel, dwID, szName, bIsSelf, ...)
	local data = {...}
	if not bIsSelf then
		if data[1] == 'ASK' then
			MY.Confirm(_L('[%s] want to see your info, OK?', szName), function()
				local me = GetClientPlayer()
				local nGongZhan = MY.GetBuff(3219) and 1 or 0
				local bEx = MY.GetAddonInfo().tAuthor[me.dwID] == me.szName and 'Author' or 'Player'
				MY.BgTalk(szName, 'RL', 'Feedback', me.dwID, UI_GetPlayerMountKungfuID(), nGongZhan, bEx)
			end)
		end
	end
end)

-- ����JH_ABOUT
MY.RegisterBgMsg('MY_ABOUT', function(_, nChannel, dwID, szName, bIsSelf, ...)
	local data = {...}
	if data[1] == 'Author' then -- �汾��� ���� ���Ի�����ϸ���
		local me, szTong = GetClientPlayer(), ''
		if me.dwTongID > 0 then
			szTong = GetTongClient().ApplyGetTongName(me.dwTongID) or 'Failed'
		end
		local szServer = select(2, GetUserServer())
		MY.BgTalk(PLAYER_TALK_CHANNEL.RAID, 'MY_ABOUT', 'info',
			me.GetTotalEquipScore(),
			me.GetMapID(),
			szTong,
			me.nRoleType,
			MY.GetAddonInfo().dwVersion,
			szServer,
			MY.GetBuff(3219)
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
	end
end)

-- �ŶӸ���CD
do local LAST_TIME = {}
MY.RegisterBgMsg('MY_MAP_COPY_ID_REQUEST', function(_, nChannel, dwID, szName, bIsSelf, dwMapID, aPlayerID)
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
		MY.BgTalk(PLAYER_TALK_CHANNEL.RAID, 'MY_MAP_COPY_ID', dwMapID, tMapID[dwMapID] or -1)
	end
	MY.GetMapSaveCopy(fnAction)
	LAST_TIME[dwMapID] = GetCurrentTime()
end)
end

-- �����ŶӸ���
do local MSG_MAP_ID, MSG_ID
local function OnSwitchMap(dwMapID, dwID, dwCopyID)
	if not MY.IsInParty() then
		return
	end
	MY.Debug({'Switch dungeon :' .. dwMapID}, 'MYLIB', MY_DEBUG.LOG)
	MY.BgTalk(PLAYER_TALK_CHANNEL.RAID, 'MY_SWITCH_MAP', dwMapID, dwID, dwCopyID)
end

local function OnCrossMapGoFB()
	local dwMapID, dwID = this.tInfo.MapID, this.tInfo.ID
	if not MY.IsDungeonResetable(dwMapID) or (MY.IsInParty() and not MY.IsLeader()) then
		OnSwitchMap(dwMapID, dwID, MY.GetMapSaveCopy(dwMapID))
	else
		MSG_MAP_ID, MSG_ID = dwMapID, dwID
	end
	return FORMAT_WMSG_RET(true, true)
end

local function OnFBAppendItemFromIni(hList)
	for i = 0, hList:GetItemCount() - 1 do
		local hItem = hList:Lookup(i)
		UnhookTableFunc(hItem, 'OnItemLButtonDBClick', OnCrossMapGoFB)
		HookTableFunc(hItem, 'OnItemLButtonDBClick', OnCrossMapGoFB, true, true, false, false, false)
	end
end

MY.RegisterEvent('ON_FRAME_CREATE.MYLIB#CD', function()
	if arg0:GetName() ~= 'CrossMap' then
		return
	end
	local hList = arg0:Lookup('Wnd_CrossFB', 'Handle_DifficultyList')
	if hList then
		OnFBAppendItemFromIni(hList)
		HookTableFunc(hList, 'AppendItemFromIni', OnFBAppendItemFromIni, true, false, false, false, false)
	end
	local btn = arg0:Lookup('Wnd_CrossFB/Btn_GoGoGo')
	if btn then
		HookTableFunc(btn, 'OnLButtonUp', OnCrossMapGoFB, true, true, false, false, false)
	end
	MY.Debug({'Cross panel hooked.'}, 'MYLIB', MY_DEBUG.LOG)
end)

MY.RegisterEvent('MY_MESSAGE_BOX_ACTION.MYLIB#CD', function()
	if arg0 ~= 'crossmap_dungeon_reset' then
		return
	end
	if arg1 == 'ACTION' and arg2 == g_tStrings.STR_HOTKEY_SURE and MSG_MAP_ID then
		OnSwitchMap(MSG_MAP_ID, MSG_ID, nil)
	end
	MSG_MAP_ID = nil
end)
end
