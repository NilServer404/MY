--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : ����NPC�Ի���
-- @author   : ���� @˫���� @׷����Ӱ
-- @modifier : Emil Zhai (root@derzh.com)
-- @copyright: Copyright (c) 2013 EMZ Kingsoft Co., Ltd.
--------------------------------------------------------
-------------------------------------------------------------------------------------------------------
-- these global functions are accessed all the time by the event handler
-- so caching them is worth the effort
-------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local ipairs, pairs, next, pcall, select = ipairs, pairs, next, pcall, select
local byte, char, len, find, format = string.byte, string.char, string.len, string.find, string.format
local gmatch, gsub, dump, reverse = string.gmatch, string.gsub, string.dump, string.reverse
local match, rep, sub, upper, lower = string.match, string.rep, string.sub, string.upper, string.lower
local type, tonumber, tostring = type, tonumber, tostring
local HUGE, PI, random, randomseed = math.huge, math.pi, math.random, math.randomseed
local min, max, floor, ceil, abs = math.min, math.max, math.floor, math.ceil, math.abs
local mod, modf, pow, sqrt = math.mod or math.fmod, math.modf, math.pow, math.sqrt
local sin, cos, tan, atan, atan2 = math.sin, math.cos, math.tan, math.atan, math.atan2
local insert, remove, concat, unpack = table.insert, table.remove, table.concat, table.unpack or unpack
local pack, sort, getn = table.pack or function(...) return {...} end, table.sort, table.getn
-- jx3 apis caching
local wsub, wlen, wfind, wgsub = wstring.sub, wstring.len, StringFindW, StringReplaceW
local GetTime, GetLogicFrameCount, GetCurrentTime = GetTime, GetLogicFrameCount, GetCurrentTime
local GetClientTeam, UI_GetClientPlayerID = GetClientTeam, UI_GetClientPlayerID
local GetClientPlayer, GetPlayer, GetNpc, IsPlayer = GetClientPlayer, GetPlayer, GetNpc, IsPlayer
-- lib apis caching
local LIB = MY
local UI, DEBUG_LEVEL, PATH_TYPE, PACKET_INFO = LIB.UI, LIB.DEBUG_LEVEL, LIB.PATH_TYPE, LIB.PACKET_INFO
local wsub, count_c, lodash = LIB.wsub, LIB.count_c, LIB.lodash
local pairs_c, ipairs_c, ipairs_r = LIB.pairs_c, LIB.ipairs_c, LIB.ipairs_r
local spairs, spairs_r, sipairs, sipairs_r = LIB.spairs, LIB.spairs_r, LIB.sipairs, LIB.sipairs_r
local IsNil, IsEmpty, IsEquals, IsString = LIB.IsNil, LIB.IsEmpty, LIB.IsEquals, LIB.IsString
local IsBoolean, IsNumber, IsHugeNumber = LIB.IsBoolean, LIB.IsNumber, LIB.IsHugeNumber
local IsTable, IsArray, IsDictionary = LIB.IsTable, LIB.IsArray, LIB.IsDictionary
local IsFunction, IsUserdata, IsElement = LIB.IsFunction, LIB.IsUserdata, LIB.IsElement
local Get, Set, Clone, GetPatch, ApplyPatch = LIB.Get, LIB.Set, LIB.Clone, LIB.GetPatch, LIB.ApplyPatch
local Call, XpCall, SafeCall, NSFormatString = LIB.Call, LIB.XpCall, LIB.SafeCall, LIB.NSFormatString
local GetTraceback, RandomChild, GetGameAPI = LIB.GetTraceback, LIB.RandomChild, LIB.GetGameAPI
local EncodeLUAData, DecodeLUAData, CONSTANT = LIB.EncodeLUAData, LIB.DecodeLUAData, LIB.CONSTANT
-------------------------------------------------------------------------------------------------------
local PLUGIN_NAME = 'MY_!Base'
local PLUGIN_ROOT = PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_!Base'
local _L = LIB.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not LIB.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '*') then
	return
end
--------------------------------------------------------------------------
local SHARE_CHAT = LIB.LoadLUAData({'temporary/share-chats.jx3dat', PATH_TYPE.GLOBAL}) -- NPC�ϱ��Ի�ģ���Զ�̣�

LIB.RegisterInit('MY_ShareChat', function()
	if not SHARE_CHAT then
		LIB.Ajax({
			driver = 'auto', mode = 'auto', method = 'auto',
			url = 'https://cdn.j3cx.com/config/npc-chat.json'
				.. '?lang=' .. LIB.GetLang()
				.. '&_=' .. GetCurrentTime(),
			success = function(html, status)
				local data = LIB.JsonDecode(html)
				if IsTable(data) then
					SHARE_CHAT = {}
					for _, dwTemplateID in ipairs(data) do
						SHARE_CHAT[dwTemplateID] = true
					end
					LIB.SaveLUAData({'temporary/share-chats.jx3dat', PATH_TYPE.GLOBAL}, SHARE_CHAT)
				end
			end,
		})
	end
end)

LIB.RegisterEvent('OPEN_WINDOW.MY_ShareChat', function()
	if not MY_Serendipity.bEnable then
		return
	end
	local me = GetClientPlayer()
	if not me then
		return
	end
	local dwTargetID = arg3
	local npc = GetNpc(dwTargetID)
	local bShare = npc and SHARE_CHAT and SHARE_CHAT[npc.dwTemplateID]
	if not bShare then
		return
	end
	local szContent = arg1
	local map = LIB.GetMapInfo(me.GetMapID())
	local szDelayID
	local function fnAction(line)
		LIB.EnsureAjax({
			url = 'https://push.j3cx.com/api/npc-chat?'
				.. LIB.EncodePostData(LIB.UrlEncode(LIB.SignPostData({
					r = AnsiToUTF8(LIB.GetRealServer(1)), -- Region
					s = AnsiToUTF8(LIB.GetRealServer(2)), -- Server
					c = AnsiToUTF8(szContent), -- Content
					t = GetCurrentTime(), -- Time
					cn = line and AnsiToUTF8(line.szCenterName) or '', -- Center Name
					ci = line and line.dwCenterID or -1, -- Center ID
					li = line and line.nLineIndex or -1, -- Line Index
					mi = map and map.dwID, -- Map ID
					mn = map and AnsiToUTF8(map.szName), -- Map Name
				}, 'MY_huadfiuadfioadfios178291hsy')))
			})
		LIB.DelayCall(szDelayID, false)
	end
	szDelayID = LIB.DelayCall(5000, fnAction)
	LIB.GetHLLineInfo({ dwMapID = me.GetMapID(), nCopyIndex = me.GetScene().nCopyIndex }, fnAction)
end)
