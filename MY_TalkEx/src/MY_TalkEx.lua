--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : 喊话辅助
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@derzh.com)
-- @copyright: Copyright (c) 2013 EMZ Kingsoft Co., Ltd.
--------------------------------------------------------
-------------------------------------------------------------------------------------------------------
-- these global functions are accessed all the time by the event handler
-- so caching them is worth the effort
-------------------------------------------------------------------------------------------------------
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
local wsub, wlen, wfind, wgsub = wstring.sub, wstring.len, StringFindW, StringReplaceW
local GetTime, GetLogicFrameCount, GetCurrentTime = GetTime, GetLogicFrameCount, GetCurrentTime
local GetClientTeam, UI_GetClientPlayerID = GetClientTeam, UI_GetClientPlayerID
local GetClientPlayer, GetPlayer, GetNpc, IsPlayer = GetClientPlayer, GetPlayer, GetNpc, IsPlayer
local LIB = MY
local UI, DEBUG_LEVEL, PATH_TYPE, PACKET_INFO = LIB.UI, LIB.DEBUG_LEVEL, LIB.PATH_TYPE, LIB.PACKET_INFO
local spairs, spairs_r, sipairs, sipairs_r = LIB.spairs, LIB.spairs_r, LIB.sipairs, LIB.sipairs_r
local ipairs_r, count_c, pairs_c, ipairs_c = LIB.ipairs_r, LIB.count_c, LIB.pairs_c, LIB.ipairs_c
local IsNil, IsEmpty, IsEquals, IsString = LIB.IsNil, LIB.IsEmpty, LIB.IsEquals, LIB.IsString
local IsBoolean, IsNumber, IsHugeNumber = LIB.IsBoolean, LIB.IsNumber, LIB.IsHugeNumber
local IsTable, IsArray, IsDictionary = LIB.IsTable, LIB.IsArray, LIB.IsDictionary
local IsFunction, IsUserdata, IsElement = LIB.IsFunction, LIB.IsUserdata, LIB.IsElement
local Call, XpCall, GetTraceback, RandomChild = LIB.Call, LIB.XpCall, LIB.GetTraceback, LIB.RandomChild
local Get, Set, Clone, GetPatch, ApplyPatch = LIB.Get, LIB.Set, LIB.Clone, LIB.GetPatch, LIB.ApplyPatch
local EncodeLUAData, DecodeLUAData, CONSTANT = LIB.EncodeLUAData, LIB.DecodeLUAData, LIB.CONSTANT
-------------------------------------------------------------------------------------------------------
local PLUGIN_NAME = 'MY_TalkEx'
local PLUGIN_ROOT = PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_TalkEx'
local _L = LIB.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not LIB.AssertVersion(MODULE_NAME, _L[MODULE_NAME], 0x2013900) then
	return
end
--------------------------------------------------------------------------
MY_TalkEx = MY_TalkEx or {}
local _C = {}
MY_TalkEx.tTalkChannels     = {}
MY_TalkEx.szTalk            = ''
MY_TalkEx.szTrickFilter     = 'RAID'
MY_TalkEx.nTrickForce       = 4
MY_TalkEx.nTrickChannel     = PLAYER_TALK_CHANNEL.RAID
MY_TalkEx.szTrickTextBegin  = _L['$zj look around and have a little thought.']
MY_TalkEx.szTrickText       = _L['$zj epilate $mb\'s feather clearly.']
MY_TalkEx.szTrickTextEnd    = _L['$zj collected the feather epilated just now and wanted it sold well.']
RegisterCustomData('MY_TalkEx.tTalkChannels')
RegisterCustomData('MY_TalkEx.szTalk')
RegisterCustomData('MY_TalkEx.nTrickChannel')
RegisterCustomData('MY_TalkEx.szTrickFilter')
RegisterCustomData('MY_TalkEx.nTrickForce')
RegisterCustomData('MY_TalkEx.szTrickTextBegin')
RegisterCustomData('MY_TalkEx.szTrickText')
RegisterCustomData('MY_TalkEx.szTrickTextEnd')

_C.tTalkChannels = {
	{ nChannel = PLAYER_TALK_CHANNEL.NEARBY       , szID = 'MSG_NORMAL'         },
	{ nChannel = PLAYER_TALK_CHANNEL.TEAM         , szID = 'MSG_PARTY'          },
	{ nChannel = PLAYER_TALK_CHANNEL.RAID         , szID = 'MSG_TEAM'           },
	{ nChannel = PLAYER_TALK_CHANNEL.TONG         , szID = 'MSG_GUILD'          },
	{ nChannel = PLAYER_TALK_CHANNEL.TONG_ALLIANCE, szID = 'MSG_GUILD_ALLIANCE' },
}
_C.tForceTitle = { [-1] = _L['all force'] }
for i, v in pairs(g_tStrings.tForceTitle) do
	_C.tForceTitle[i] = v -- GetForceTitle(i)
end
_C.tTrickFilter = { ['NEARBY'] = _L['nearby players where'], ['RAID'] = _L['teammates where'], }
_C.tTrickChannels = {
	[PLAYER_TALK_CHANNEL.TEAM         ] = { szName = _L['team channel'         ], tCol = GetMsgFontColor('MSG_TEAM'          , true) },
	[PLAYER_TALK_CHANNEL.RAID         ] = { szName = _L['raid channel'         ], tCol = GetMsgFontColor('MSG_TEAM'          , true) },
	[PLAYER_TALK_CHANNEL.TONG         ] = { szName = _L['tong channel'         ], tCol = GetMsgFontColor('MSG_GUILD'         , true) },
	[PLAYER_TALK_CHANNEL.TONG_ALLIANCE] = { szName = _L['tong alliance channel'], tCol = GetMsgFontColor('MSG_GUILD_ALLIANCE', true) },
}

local _dwTalkTick = 0
_C.Talk = function()
	if #MY_TalkEx.szTalk == 0 then
		return LIB.Sysmsg(_L['please input something.'], CONSTANT.MSG_THEME.ERROR)
	end

	if not LIB.IsShieldedVersion('DEVELOP') and LIB.ProcessCommand
	and MY_TalkEx.szTalk:sub(1, 8) == '/script ' then
		LIB.ProcessCommand(MY_TalkEx.szTalk:sub(9))
	else
		-- 防止刷屏
		if GetTime() - _dwTalkTick < 1000 then
			return OutputMessage('MSG_ANNOUNCE_YELLOW', _L['You are talking too quick!'])
		end
		_dwTalkTick = GetTime()
		-- 近聊不放在第一个会导致发不出去
		if MY_TalkEx.tTalkChannels[PLAYER_TALK_CHANNEL.NEARBY] then
			LIB.Talk(PLAYER_TALK_CHANNEL.NEARBY, MY_TalkEx.szTalk)
		end
		-- 遍历发送队列
		for nChannel, _ in pairs(MY_TalkEx.tTalkChannels) do
			if nChannel ~= PLAYER_TALK_CHANNEL.NEARBY then
				LIB.Talk(nChannel, MY_TalkEx.szTalk)
			end
		end
	end
end
LIB.RegisterHotKey('MY_TalkEx_Talk', _L['TalkEx Talk'], _C.Talk, nil)

_C.Trick = function()
	if #MY_TalkEx.szTrickText == 0 then
		return LIB.Sysmsg(_L['please input something.'], CONSTANT.MSG_THEME.ERROR)
	end
	local t = {}
	if MY_TalkEx.szTrickFilter == 'RAID' then
		local team = GetClientTeam()
		local me = GetClientPlayer()
		if team and me and (me.IsInParty() or me.IsInRaid()) then
			for _, dwID in ipairs(team.GetTeamMemberList()) do
				local info = team.GetMemberInfo(dwID)
				if info and (MY_TalkEx.nTrickForce == -1 or MY_TalkEx.nTrickForce == info.dwForceID) then
					table.insert(t, info.szName)
				end
			end
		end
	elseif MY_TalkEx.szTrickFilter == 'NEARBY' then
		for _, p in ipairs(LIB.GetNearPlayer()) do
			if MY_TalkEx.nTrickForce == -1 or MY_TalkEx.nTrickForce == p.dwForceID then
				table.insert(t, p.szName)
			end
		end
	end
	-- 去掉自己 _(:з」∠)_调侃自己是闹哪样
	for i = #t, 1, -1 do
		if t[i] == GetClientPlayer().szName then
			table.remove(t, i)
		end
	end
	-- none target
	if #t == 0 then
		return LIB.Sysmsg(_L['no trick target found.'], CONSTANT.MSG_THEME.ERROR)
	end
	-- start tricking
	if #MY_TalkEx.szTrickTextBegin > 0 then
		LIB.Talk(MY_TalkEx.nTrickChannel, MY_TalkEx.szTrickTextBegin)
	end
	for _, szName in ipairs(t) do
		LIB.Talk(MY_TalkEx.nTrickChannel, (MY_TalkEx.szTrickText:gsub('%$mb', '[' .. szName .. ']')))
	end
	if #MY_TalkEx.szTrickTextEnd > 0 then
		LIB.Talk(MY_TalkEx.nTrickChannel, MY_TalkEx.szTrickTextEnd)
	end
end

LIB.RegisterPanel('TalkEx', _L['talk ex'], _L['Chat'], 'UI/Image/UICommon/ScienceTreeNode.UITex|123', { OnPanelActive = function(wnd)
	local ui = UI(wnd)
	local w, h = ui:Size()
	-------------------------------------
	-- 喊话部分
	-------------------------------------
	-- 喊话输入框
	ui:Append('WndEditBox', 'WndEdit_Talk'):Pos(25,15)
	  :Size(w-136,208):Multiline(true)
	  :Text(MY_TalkEx.szTalk)
	  :Change(function(text) MY_TalkEx.szTalk = text end)
	-- 喊话频道
	local y = 12
	local nChannelCount = #_C.tTalkChannels
	for i, p in ipairs(_C.tTalkChannels) do
		ui:Append('WndCheckBox', 'WndCheckBox_TalkEx_' .. p.nChannel)
		  :Pos(w - 110, y + (i - 1) * 180 / nChannelCount)
		  :Text(g_tStrings.tChannelName[p.szID])
		  :Color(GetMsgFontColor(p.szID, true))
		  :Check(
		  	function() MY_TalkEx.tTalkChannels[p.nChannel] = true end,
		  	function() MY_TalkEx.tTalkChannels[p.nChannel] = nil  end)
		  :Check(MY_TalkEx.tTalkChannels[p.nChannel] or false)
	end
	-- 喊话按钮
	ui:Append('WndButton', 'WndButton_Talk')
	  :Pos(w-110,200):Width(90)
	  :Text(_L['send'],{255,255,255})
	  :Click(function()
	  	if IsAltKeyDown() and IsShiftKeyDown() and LIB.ProcessCommand
	  	and MY_TalkEx.szTalk:sub(1, 8) == '/script ' then
	  		LIB.ProcessCommand(MY_TalkEx.szTalk:sub(9))
	  	else
	  		_C.Talk()
	  		local ui = UI(this)
			ui:Enable(false)
			LIB.DelayCall(1000, function()
				ui:Enable(true)
			end)
	  	end
	  end, function()
	  	LIB.Talk(nil, MY_TalkEx.szTalk, nil, nil, nil, true)
	  end)
	-------------------------------------
	-- 调侃部分
	-------------------------------------
	-- <hr />
	ui:Append('Image', 'Image_TalkEx_Spliter')
	  :Pos(5, 235):Size(w-10, 1):Image('UI/Image/UICommon/ScienceTreeNode.UITex',62)
	-- 文本标题
	ui:Append('Text', 'Text_Trick_With')
	  :Pos(27, 240):Text(_L['have a trick with'])
	-- 调侃对象范围过滤器
	ui:Append('WndComboBox', 'WndComboBox_Trick_Filter')
	  :Pos(95, 241):Size(80,25):Menu(function()
	  	local t = {}
	  	for szFilterId,szTitle in pairs(_C.tTrickFilter) do
	  		table.insert(t,{
	  			szOption = szTitle,
	  			fnAction = function()
	  				ui:Find('#WndComboBox_Trick_Filter'):Text(szTitle)
	  				MY_TalkEx.szTrickFilter = szFilterId
	  			end,
	  		})
	  	end
	  	return t
	  end)
	  :Text(_C.tTrickFilter[MY_TalkEx.szTrickFilter] or '')
	-- 调侃门派过滤器
	ui:Append('WndComboBox', 'WndComboBox_Trick_Force')
	  :Pos(175, 241):Size(80,25)
	  :Text(_C.tForceTitle[MY_TalkEx.nTrickForce])
	  :Menu(function()
	  	local t = {}
	  	for szFilterId,szTitle in pairs(_C.tForceTitle) do
	  		table.insert(t,{
	  			szOption = szTitle,
	  			fnAction = function()
	  				ui:Find('#WndComboBox_Trick_Force'):Text(szTitle)
	  				MY_TalkEx.nTrickForce = szFilterId
	  			end,
	  		})
	  	end
	  	return t
	  end)
	-- 调侃内容输入框：第一句
	ui:Append('WndEditBox', 'WndEdit_TrickBegin')
	  :Pos(25, 269):Size(w-136, 25):Text(MY_TalkEx.szTrickTextBegin)
	  :Change(function() MY_TalkEx.szTrickTextBegin = this:GetText() end)
	-- 调侃内容输入框：调侃内容
	ui:Append('WndEditBox', 'WndEdit_Trick')
	  :Pos(25, 294):Size(w-136, 55)
	  :Multiline(true):Text(MY_TalkEx.szTrickText)
	  :Change(function() MY_TalkEx.szTrickText = this:GetText() end)
	-- 调侃内容输入框：最后一句
	ui:Append('WndEditBox', 'WndEdit_TrickEnd')
	  :Pos(25, 349):Size(w-136, 25)
	  :Text(MY_TalkEx.szTrickTextEnd)
	  :Change(function() MY_TalkEx.szTrickTextEnd = this:GetText() end)
	-- 调侃发送频道提示框
	ui:Append('Text', 'Text_Trick_Sendto')
	  :Pos(27, 379):Size(100, 26):Text(_L['send to'])
	-- 调侃发送频道
	ui:Append('WndComboBox', 'WndComboBox_Trick_Sendto_Filter')
	  :Pos(80, 379):Size(100, 25)
	  :Menu(function()
	  	local t = {}
	  	for nTrickChannel, tChannel in pairs(_C.tTrickChannels) do
	  		table.insert(t,{
	  			rgb = tChannel.tCol,
	  			szOption = tChannel.szName,
	  			fnAction = function()
	  				MY_TalkEx.nTrickChannel = nTrickChannel
	  				ui:Find('#WndComboBox_Trick_Sendto_Filter'):Text(tChannel.szName):Color(tChannel.tCol)
	  			end,
	  		})
	  	end
	  	return t
	  end)
	  :Text(_C.tTrickChannels[MY_TalkEx.nTrickChannel].szName or '')
	  :Color(_C.tTrickChannels[MY_TalkEx.nTrickChannel].tCol)
	-- 调侃按钮
	ui:Append('WndButton', 'WndButton_Trick')
	  :Pos(435, 379):Color({255,255,255})
	  :Text(_L['have a trick with'])
	  :Click(_C.Trick)
end})
