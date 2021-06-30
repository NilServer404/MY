--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : ����������һ������
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
local mod, modf, pow, sqrt = math['mod'] or math['fmod'], math.modf, math.pow, math.sqrt
local sin, cos, tan, atan, atan2 = math.sin, math.cos, math.tan, math.atan, math.atan2
local insert, remove, concat = table.insert, table.remove, table.concat
local pack, unpack = table['pack'] or function(...) return {...} end, table['unpack'] or unpack
local sort, getn = table.sort, table['getn'] or function(t) return #t end
-- jx3 apis caching
local wlen, wfind, wgsub, wlower = wstring.len, StringFindW, StringReplaceW, StringLowerW
local GetTime, GetLogicFrameCount, GetCurrentTime = GetTime, GetLogicFrameCount, GetCurrentTime
local GetClientTeam, UI_GetClientPlayerID = GetClientTeam, UI_GetClientPlayerID
local GetClientPlayer, GetPlayer, GetNpc, IsPlayer = GetClientPlayer, GetPlayer, GetNpc, IsPlayer
-- lib apis caching
local LIB = MY
local UI, GLOBAL, CONSTANT = LIB.UI, LIB.GLOBAL, LIB.CONSTANT
local PACKET_INFO, DEBUG_LEVEL, PATH_TYPE = LIB.PACKET_INFO, LIB.DEBUG_LEVEL, LIB.PATH_TYPE
local wsub, count_c, lodash = LIB.wsub, LIB.count_c, LIB.lodash
local pairs_c, ipairs_c, ipairs_r = LIB.pairs_c, LIB.ipairs_c, LIB.ipairs_r
local spairs, spairs_r, sipairs, sipairs_r = LIB.spairs, LIB.spairs_r, LIB.sipairs, LIB.sipairs_r
local IsNil, IsEmpty, IsEquals, IsString = LIB.IsNil, LIB.IsEmpty, LIB.IsEquals, LIB.IsString
local IsBoolean, IsNumber, IsHugeNumber = LIB.IsBoolean, LIB.IsNumber, LIB.IsHugeNumber
local IsTable, IsArray, IsDictionary = LIB.IsTable, LIB.IsArray, LIB.IsDictionary
local IsFunction, IsUserdata, IsElement = LIB.IsFunction, LIB.IsUserdata, LIB.IsElement
local EncodeLUAData, DecodeLUAData, Schema = LIB.EncodeLUAData, LIB.DecodeLUAData, LIB.Schema
local GetTraceback, RandomChild, GetGameAPI = LIB.GetTraceback, LIB.RandomChild, LIB.GetGameAPI
local Get, Set, Clone, GetPatch, ApplyPatch = LIB.Get, LIB.Set, LIB.Clone, LIB.GetPatch, LIB.ApplyPatch
local IIf, CallWithThis, SafeCallWithThis = LIB.IIf, LIB.CallWithThis, LIB.SafeCallWithThis
local Call, XpCall, SafeCall, NSFormatString = LIB.Call, LIB.XpCall, LIB.SafeCall, LIB.NSFormatString
-------------------------------------------------------------------------------------------------------
local PLUGIN_NAME = 'MY_Chat'
local PLUGIN_ROOT = PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_ChatMosaics'
local _L = LIB.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not LIB.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^5.0.0') then
	return
end
--------------------------------------------------------------------------
local O = LIB.CreateUserSettingsModule(MODULE_NAME, _L['Chat'], {
	tIgnoreNames = { -- ��������
		ePathType = PATH_TYPE.ROLE,
		szLabel = _L['MY_ChatMosaics'],
		xSchema = Schema.Map(Schema.String, Schema.Boolean),
		xDefaultValue = {},
	},
	nMosaicsMode = { -- �ֲ�����ģʽ
		ePathType = PATH_TYPE.ROLE,
		szLabel = _L['MY_ChatMosaics'],
		xSchema = Schema.Number,
		xDefaultValue = 1,
	},
	bIgnoreOwnName = { -- �������Լ�������
		ePathType = PATH_TYPE.ROLE,
		szLabel = _L['MY_ChatMosaics'],
		xSchema = Schema.Boolean,
		xDefaultValue = false,
	},
})
local D = {
	bEnabled = false,            -- ����״̬
	szMosaics = _L.MOSAICS_CHAR, -- �������ַ�
}

function D.ResetMosaics()
	-- re mosaics
	D.bForceUpdate = true
	for i = 1, 10 do
		D.Mosaics(Station.Lookup('Lowest2/ChatPanel' .. i .. '/Wnd_Message', 'Handle_Message'))
	end
	D.bForceUpdate = nil
	-- hook chat panel
	if D.bEnabled then
		LIB.HookChatPanel('AFTER.MY_ChatMosaics', function(h, nIndex)
			D.Mosaics(h, nIndex)
		end)
	else
		LIB.HookChatPanel('AFTER.MY_ChatMosaics', false)
	end
	FireUIEvent('ON_MY_MOSAICS_RESET')
end

function D.NameLink_GetText(h, ...)
	return h.__MY_ChatMosaics_szText or h.__MY_ChatMosaics_GetText(h, ...)
end

function D.MosaicsString(szText)
	if not D.bEnabled then
		return szText
	end
	local bQuote = szText:sub(1, 1) == '[' and szText:sub(-1, -1) == ']'
	if bQuote then
		szText = szText:sub(2, -2) -- ȥ��[]����
	end
	if (not O.bIgnoreOwnName or szText ~= GetClientPlayer().szName) and not O.tIgnoreNames[szText] then
		local nLen = wlen(szText)
		if O.nMosaicsMode == 3 and nLen > 2 then
			szText = wsub(szText, 1, 1) .. rep(D.szMosaics, nLen - 2) .. wsub(szText, nLen, nLen)
		elseif O.nMosaicsMode == 1 and nLen > 1 then
			szText = wsub(szText, 1, 1) .. rep(D.szMosaics, nLen - 1)
		elseif O.nMosaicsMode == 2 and nLen > 1 then
			szText = rep(D.szMosaics, nLen - 1) .. wsub(szText, nLen, nLen)
		elseif O.nMosaicsMode == 4 or nLen <= 1 then
			szText = rep(D.szMosaics, nLen)
		else
			szText = wsub(szText, 1, 1) .. rep(D.szMosaics, nLen - 1)
		end
	end
	if bQuote then
		szText = '[' .. szText .. ']' -- �ӻ�[]����
	end
	return szText
end

function D.Mosaics(h, nPos, nLen)
	if not h then
		return
	end
	if h:GetType() == 'Text' then
		if D.bEnabled then
			if not h.__MY_ChatMosaics_szText or D.bForceUpdate then
				h.__MY_ChatMosaics_szText = h.__MY_ChatMosaics_szText or h:GetText()
				if not h.__MY_ChatMosaics_GetText then
					h.__MY_ChatMosaics_GetText = h.GetText
					h.GetText = D.NameLink_GetText
				end
				h:SetText(D.MosaicsString(h.__MY_ChatMosaics_szText))
				h:AutoSize()
			end
		else
			if h.__MY_ChatMosaics_GetText then
				h.GetText = h.__MY_ChatMosaics_GetText
				h.__MY_ChatMosaics_GetText = nil
			end
			if h.__MY_ChatMosaics_szText then
				h:SetText(h.__MY_ChatMosaics_szText)
				h.__MY_ChatMosaics_szText = nil
				h:AutoSize()
			end
		end
	elseif h:GetType() == 'Handle' then
		local nEndPos = (nLen and (nPos + nLen)) or (h:GetItemCount() - 1)
		for i = nPos or 0, nEndPos do
			local hItem = h:Lookup(i)
			if hItem and (hItem:GetName():sub(0, 9)) == 'namelink_' then
				D.Mosaics(hItem)
			end
		end
		h:FormatAllItemPos()
	end
end

-- Global exports
do
local settings = {
	name = 'MY_ChatMosaics',
	exports = {
		{
			preset = 'UIEvent',
			fields = {
				'Mosaics',
				'MosaicsString',
				'bEnabled',
			},
			root = D,
		},
	},
	imports = {
		{
			fields = {
				'bEnabled',
			},
			triggers = {
				bEnabled = function ()
					D.ResetMosaics()
				end,
			},
			root = D,
		},
	},
}
MY_ChatMosaics = LIB.CreateModule(settings)
end

local PS = {}

function PS.OnPanelActive(wnd)
	local ui = UI(wnd)
	local w, h = ui:Size()
	local x, y = 20, 30

	ui:Append('WndCheckBox', {
		text = _L['chat mosaics (mosaics names in chat panel)'],
		x = x, y = y, w = 400,
		checked = MY_ChatMosaics.bEnabled,
		oncheck = function(bCheck)
			MY_ChatMosaics.bEnabled = bCheck
			D.ResetMosaics()
		end,
	})
	y = y + 30

	ui:Append('WndCheckBox', {
		text = _L['no mosaics on my own name'],
		x = x, y = y, w = 400,
		checked = O.bIgnoreOwnName,
		oncheck = function(bCheck)
			O.bIgnoreOwnName = bCheck
			D.ResetMosaics()
		end,
	})
	y = y + 30

	ui:Append('WndRadioBox', {
		text = _L['part mosaics A (mosaics except 1st and last character)'],
		x = x, y = y, w = 400,
		group = 'PART_MOSAICS',
		checked = O.nMosaicsMode == 1,
		oncheck = function(bCheck)
			if bCheck then
				O.nMosaicsMode = 1
				D.ResetMosaics()
			end
		end,
	})
	y = y + 30

	ui:Append('WndRadioBox', {
		text = _L['part mosaics B (mosaics except 1st character)'],
		x = x, y = y, w = 400,
		group = 'PART_MOSAICS',
		checked = O.nMosaicsMode == 2,
		oncheck = function(bCheck)
			if bCheck then
				O.nMosaicsMode = 2
				D.ResetMosaics()
			end
		end,
	})
	y = y + 30

	ui:Append('WndRadioBox', {
		text = _L['part mosaics C (mosaics except last character)'],
		x = x, y = y, w = 400,
		group = 'PART_MOSAICS',
		checked = O.nMosaicsMode == 3,
		oncheck = function(bCheck)
			if bCheck then
				O.nMosaicsMode = 3
				D.ResetMosaics()
			end
		end,
	})
	y = y + 30

	ui:Append('WndRadioBox', {
		text = _L['part mosaics D (mosaics all character)'],
		x = x, y = y, w = 400,
		group = 'PART_MOSAICS',
		checked = O.nMosaicsMode == 4,
		oncheck = function(bCheck)
			if bCheck then
				O.nMosaicsMode = 4
				D.ResetMosaics()
			end
		end,
	})
	y = y + 30

	ui:Append('WndEditBox', {
		placeholder = _L['mosaics character'],
		x = x, y = y, w = w - 2 * x, h = 25,
		text = D.szMosaics,
		onchange = function(szText)
			if szText == '' then
				D.szMosaics = _L.MOSAICS_CHAR
			else
				D.szMosaics = szText
			end
			D.ResetMosaics()
		end,
	})
	y = y + 30

	ui:Append('WndEditBox', {
		placeholder = _L['unmosaics names (split by comma)'],
		x = x, y = y, w = w - 2 * x, h = h - y - 50,
		text = (function()
			local t = {}
			for szName, _ in pairs(O.tIgnoreNames) do
				insert(t, szName)
			end
			concat(t, ',')
		end)(),
		onchange = function(szText)
			local tIgnoreNames = {}
			for _, szName in ipairs(LIB.SplitString(szText, ',')) do
				tIgnoreNames[szName] = true
			end
			O.tIgnoreNames = tIgnoreNames
			D.ResetMosaics()
		end,
	})
	y = y + 30
end

LIB.RegisterPanel(_L['Chat'], 'MY_Chat_ChatMosaics', _L['chat mosaics'], 'ui/Image/UICommon/yirong3.UITex|50', PS)
