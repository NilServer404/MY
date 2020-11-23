--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : ��ӭҳ
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
local _L = LIB.LoadLangPack()

local PS = { bWelcome = true, bHide = true }

local function GetMemoryText()
	return format('Memory:%.1fMB', collectgarbage('count') / 1024)
end

local function GetAdvText()
	local me = GetClientPlayer()
	if not me then
		return ''
	end
	return _L('%s, welcome to use %s!', me.szName, PACKET_INFO.NAME) .. 'v' .. LIB.GetVersion()
end

local function GetSvrText()
	local nFeeTime = LIB.GetTimeOfFee() - GetCurrentTime()
	return LIB.GetServer() .. ' (' .. LIB.GetRealServer() .. ')'
		.. g_tStrings.STR_CONNECT
		.. (nFeeTime > 0 and LIB.FormatTimeCounter(nFeeTime, _L['Fee left %H:%mm:%ss']) or _L['Fee left unknown'])
end

function PS.OnPanelActive(wnd)
	local ui = UI(wnd)
	local w, h = ui:Size()
	ui:Append('Shadow', { name = 'Shadow_Adv', x = 0, y = 0, color = { 140, 140, 140 } })
	ui:Append('Image', { name = 'Image_Adv', x = 0, y = 0, image = PACKET_INFO.UITEX_POSTER, imageframe = min(GetTime() % 3, 1) })
	ui:Append('Text', { name = 'Text_Adv', x = 10, y = 300, w = 557, font = 200, text = GetAdvText() })
	ui:Append('Text', { name = 'Text_Memory', x = 10, y = 300, w = 150, alpha = 150, font = 162, text = GetMemoryText(), halign = 2 })
	ui:Append('Text', { name = 'Text_Svr', x = 10, y = 345, w = 557, font = 204, text = GetSvrText(), alpha = 220 })
	local x = 7
	-- ��������
	x = x + ui:Append('WndCheckBox', {
		x = x, y = 375,
		name = 'WndCheckBox_SerendipityNotify',
		text = _L['Show share notify.'],
		checked = MY_Serendipity.bEnable,
		oncheck = function()
			MY_Serendipity.bEnable = not MY_Serendipity.bEnable
		end,
		tip = _L['Monitor serendipity and show share notify.'],
		tippostype = UI.TIP_POSITION.BOTTOM_TOP,
	}):AutoWidth():Width()
	local xS0 = x + ui:Append('WndCheckBox', {
		x = x, y = 375,
		name = 'WndCheckBox_SerendipityAutoShare',
		text = _L['Auto share.'],
		checked = MY_Serendipity.bAutoShare,
		oncheck = function()
			MY_Serendipity.bAutoShare = not MY_Serendipity.bAutoShare
		end,
	}):AutoWidth():Width()
	-- �Զ���������
	x = xS0
	x = x + ui:Append('WndCheckBox', {
		x = x, y = 375,
		name = 'WndCheckBox_SerendipitySilentMode',
		text = _L['Silent mode.'],
		checked = MY_Serendipity.bSilentMode,
		oncheck = function()
			MY_Serendipity.bSilentMode = not MY_Serendipity.bSilentMode
		end,
		autovisible = function() return MY_Serendipity.bAutoShare end,
	}):AutoWidth():Width()
	x = x + 5
	x = x + ui:Append('WndEditBox', {
		x = x, y = 375, w = 105, h = 25,
		name = 'WndEditBox_SerendipitySilentMode',
		placeholder = _L['Realname, leave blank for anonymous.'],
		tip = _L['Realname, leave blank for anonymous.'],
		tippostype = UI.TIP_POSITION.BOTTOM_TOP,
		limit = 6,
		text = LIB.LoadLUAData({'config/realname.jx3dat', PATH_TYPE.ROLE}) or GetClientPlayer().szName:gsub('@.-$', ''),
		onchange = function(szText)
			LIB.SaveLUAData({'config/realname.jx3dat', PATH_TYPE.ROLE}, szText)
		end,
		autovisible = function() return MY_Serendipity.bAutoShare end,
	}):Width()
	-- �ֶ���������
	x = xS0
	x = x + ui:Append('WndCheckBox', {
		x = x, y = 375,
		name = 'WndCheckBox_SerendipityNotifyTip',
		text = _L['Show notify tip.'],
		checked = MY_Serendipity.bPreview,
		oncheck = function()
			MY_Serendipity.bPreview = not MY_Serendipity.bPreview
		end,
		autovisible = function() return not MY_Serendipity.bAutoShare end,
	}):AutoWidth():Width()
	x = x + ui:Append('WndCheckBox', {
		x = x, y = 375,
		name = 'WndCheckBox_SerendipityNotifySound',
		text = _L['Play notify sound.'],
		checked = MY_Serendipity.bSound,
		oncheck = function()
			MY_Serendipity.bSound = not MY_Serendipity.bSound
		end,
		autoenable = function() return not MY_Serendipity.bAutoShare end,
		autovisible = function() return not MY_Serendipity.bAutoShare end,
	}):AutoWidth():Width()
	x = x + ui:Append('WndButton', {
		x = x, y = 375,
		name = 'WndButton_SerendipitySearch',
		text = _L['serendipity'],
		onclick = function()
			LIB.OpenBrowser('https://j3cx.com/serendipity')
		end,
	}):AutoWidth():Width() + 5
	-- ����λ��
	x = x + ui:Append('WndButton', {
		x = x, y = 405,
		name = 'WndButton_UserPreference',
		text = _L['User preference storage'],
		menu = function()
			return {
				{
					szOption = _L['User preference'],
					fnMouseEnter = function()
						local nX, nY = this:GetAbsX(), this:GetAbsY()
						local nW, nH = this:GetW(), this:GetH()
						OutputTip(GetFormatText(_L['User preference'] .. _L['Storage location'], nil, 255, 255, 0), 600, {nX, nY, nW, nH}, ALW.BOTTOM_TOP)
					end,
					fnAction = function()
						local szRoot = LIB.GetAbsolutePath({'', PATH_TYPE.ROLE}):gsub('/', '\\')
						LIB.OpenFolder(szRoot)
						UI.OpenTextEditor(szRoot)
					end,
				},
				{
					szOption = _L['Server preference'],
					fnMouseEnter = function()
						local nX, nY = this:GetAbsX(), this:GetAbsY()
						local nW, nH = this:GetW(), this:GetH()
						OutputTip(GetFormatText(_L['Server preference'] .. _L['Storage location'], nil, 255, 255, 0), 600, {nX, nY, nW, nH}, ALW.BOTTOM_TOP)
					end,
					fnAction = function()
						local szRoot = LIB.GetAbsolutePath({'', PATH_TYPE.SERVER}):gsub('/', '\\')
						LIB.OpenFolder(szRoot)
						UI.OpenTextEditor(szRoot)
					end,
				},
				{
					szOption = _L['Global preference'],
					fnMouseEnter = function()
						local nX, nY = this:GetAbsX(), this:GetAbsY()
						local nW, nH = this:GetW(), this:GetH()
						OutputTip(GetFormatText(_L['Global preference'] .. _L['Storage location'], nil, 255, 255, 0), 600, {nX, nY, nW, nH}, ALW.BOTTOM_TOP)
					end,
					fnAction = function()
						local szRoot = LIB.GetAbsolutePath({'', PATH_TYPE.GLOBAL}):gsub('/', '\\')
						LIB.OpenFolder(szRoot)
						UI.OpenTextEditor(szRoot)
					end,
				},
				{
					szOption = _L['Flush data'],
					fnMouseEnter = function()
						local nX, nY = this:GetAbsX(), this:GetAbsY()
						local nW, nH = this:GetW(), this:GetH()
						OutputTip(GetFormatText(_L['Config and data will be saved when exit game, click to save immediately'], nil, 255, 255, 0), 600, {nX, nY, nW, nH}, ALW.BOTTOM_TOP)
					end,
					fnAction = function()
						LIB.FireFlush()
					end,
				},
			}
		end,
	}):AutoWidth():Width() + 5
	x = x + ui:Append('WndButton', {
		name = 'WndButton_AddonErrorMessage',
		x = x, y = 405,
		text = _L['Error message'],
		tip = _L['Show error message'],
		tippostype = UI.TIP_POSITION.BOTTOM_TOP,
		onclick = function()
			if IsCtrlKeyDown() and IsAltKeyDown() and IsShiftKeyDown() then
				LIB.IsDebugClient('MYDev_UIEditor', true, true)
				LIB.IsDebugClient('MYDev_UIManager', true, true)
				LIB.IsDebugClient('MYDev_UIFindStation', true, true)
				LIB.Systopmsg(_L['Debug tools has been enabled...'])
				LIB.ReopenPanel()
				return
			end
			UI.OpenTextEditor(LIB.GetAddonErrorMessage())
		end,
	}):AutoWidth():Width() + 5
	PS.OnPanelResize(wnd)
end

function PS.OnPanelResize(wnd)
	local ui = UI(wnd)
	local w, h = ui:Size()
	local scaleH = w / 557 * 278
	local bottomH = 90
	if scaleH > h - bottomH then
		ui:Fetch('Shadow_Adv'):Size((h - bottomH) / 278 * 557, (h - bottomH))
		ui:Fetch('Image_Adv'):Size((h - bottomH) / 278 * 557, (h - bottomH))
		ui:Fetch('Text_Memory'):Pos(w - 150, h - bottomH + 10)
		ui:Fetch('Text_Adv'):Pos(10, h - bottomH + 10)
		ui:Fetch('Text_Svr'):Pos(10, h - bottomH + 35)
	else
		ui:Fetch('Shadow_Adv'):Size(w, scaleH)
		ui:Fetch('Image_Adv'):Size(w, scaleH)
		ui:Fetch('Text_Memory'):Pos(w - 150, scaleH + 10)
		ui:Fetch('Text_Adv'):Pos(10, scaleH + 10)
		ui:Fetch('Text_Svr'):Pos(10, scaleH + 35)
	end
	ui:Fetch('WndCheckBox_SerendipityNotify'):Top(scaleH + 65)
	ui:Fetch('WndCheckBox_SerendipityAutoShare'):Top(scaleH + 65)
	ui:Fetch('WndCheckBox_SerendipitySilentMode'):Top(scaleH + 65)
	ui:Fetch('WndEditBox_SerendipitySilentMode'):Top(scaleH + 65)
	ui:Fetch('WndCheckBox_SerendipityNotifyTip'):Top(scaleH + 65)
	ui:Fetch('WndCheckBox_SerendipityNotifySound'):Top(scaleH + 65)
	ui:Fetch('WndButton_SerendipitySearch'):Top(scaleH + 65)
	ui:Fetch('WndButton_UserPreference'):Top(scaleH + 65)
	ui:Fetch('WndButton_AddonErrorMessage'):Top(scaleH + 65)
end

function PS.OnPanelBreathe(wnd)
	local ui = UI(wnd)
	ui:Fetch('Text_Adv'):Text(GetAdvText())
	ui:Fetch('Text_Svr'):Text(GetSvrText())
	ui:Fetch('Text_Memory'):Text(GetMemoryText())
end

LIB.RegisterPanel('Welcome', _L['Welcome'], nil, '', PS)
