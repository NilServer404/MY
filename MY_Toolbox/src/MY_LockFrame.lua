--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : ����֮�ؾŹ�����
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
local wsub, count_c = LIB.wsub, LIB.count_c
local pairs_c, ipairs_c, ipairs_r = LIB.pairs_c, LIB.ipairs_c, LIB.ipairs_r
local spairs, spairs_r, sipairs, sipairs_r = LIB.spairs, LIB.spairs_r, LIB.sipairs, LIB.sipairs_r
local IsNil, IsEmpty, IsEquals, IsString = LIB.IsNil, LIB.IsEmpty, LIB.IsEquals, LIB.IsString
local IsBoolean, IsNumber, IsHugeNumber = LIB.IsBoolean, LIB.IsNumber, LIB.IsHugeNumber
local IsTable, IsArray, IsDictionary = LIB.IsTable, LIB.IsArray, LIB.IsDictionary
local IsFunction, IsUserdata, IsElement = LIB.IsFunction, LIB.IsUserdata, LIB.IsElement
local Get, Set, Clone, GetPatch, ApplyPatch = LIB.Get, LIB.Set, LIB.Clone, LIB.GetPatch, LIB.ApplyPatch
local Call, XpCall, SafeCall = LIB.Call, LIB.XpCall, LIB.SafeCall
local GetTraceback, RandomChild = LIB.GetTraceback, LIB.RandomChild
local EncodeLUAData, DecodeLUAData, CONSTANT = LIB.EncodeLUAData, LIB.DecodeLUAData, LIB.CONSTANT
-------------------------------------------------------------------------------------------------------
local PLUGIN_NAME = 'MY_Toolbox'
local PLUGIN_ROOT = PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_LockFrame'
local _L = LIB.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not LIB.AssertVersion(MODULE_NAME, _L[MODULE_NAME], 0x2013900) then
	return
end
--------------------------------------------------------------------------

local D = {}
local O = {
	-- ������
	bEnable = false,
	tEnable = {
		['JX_TargetList'] = true,
		['MY_FocusUI'] = true,
		['WhoSeeMe'] = true,
		['HatredPanel'] = true,
		['FightingStatistic'] = true,
		['MY_ThreatRank'] = true,
		['MY_Recount_UI'] = true,
		['LR_AS_FP'] = true,
		['QuestTraceList'] = true,
		['ChatPanel'] = true,
		['DynamicActionBar'] = true,
		['ExteriorAction'] = true,
		['MentorMessage'] = true,
		['JX_TeamCD'] = true,
		['JX_HeightMeter'] = true,
		['Matrix'] = true,
	},
	-- ���ر���
	bTempDisable = false,
	tLockList = {
		'WhoSeeMe',
		'HatredPanel',
		'FightingStatistic',
		'QuestTraceList',
		'ChatPanel',
		'Matrix',
		'ExteriorAction',
		'MentorMessage',
		'DynamicActionBar',
		'JX_TeamCD',
		'JX_HeightMeter',
		'JX_TargetList',
		'MY_FocusUI',
		'MY_ThreatRank',
		'MY_Recount_UI',
		'LR_AS_FP',
	},
	tLockID = {
		['JX_TargetList'] = 'JX_TargetList', -- ���ġ������б� [Normal/JX_TargetList]
		['MY_FocusUI'] = 'MY_FocusUI', -- �����������б� [Normal/MY_FocusUI]
		['WhoSeeMe'] = 'WhoSeeMe', -- ˭�ڿ��� [Normal/WhoSeeMe]
		['HatredPanel'] = 'HatredPanel', -- ����б� [Normal/HatredPanel]
		['FightingStatistic'] = 'FightingStatistic', -- �˺�ͳ�� [Normal/FightingStatistic]
		['MY_ThreatRank'] = 'MY_ThreatRank', -- ���������ͳ�� [Normal/MY_ThreatRank]
		['MY_Recount_UI'] = 'MY_Recount_UI', -- �������˺�ͳ�� [Normal/MY_Recount_UI]
		['LR_AS_FP'] = 'LR_AS_FP', -- ���ˡ��˱������� [Normal/LR_AS_FP]
		['QuestTraceList'] = 'QuestTraceList', -- ����׷�� [Normal/QuestTraceList]
		['Matrix'] = 'Matrix', -- �󷨽��� [Normal/Matrix]
		['ChatPanel1'] = 'ChatPanel', -- ������� [Lowest2/ChatPanel1]
		['ChatPanel2'] = 'ChatPanel', -- ������� [Lowest2/ChatPanel2]
		['ChatPanel3'] = 'ChatPanel', -- ������� [Lowest2/ChatPanel3]
		['ChatPanel4'] = 'ChatPanel', -- ������� [Lowest2/ChatPanel4]
		['ChatPanel5'] = 'ChatPanel', -- ������� [Lowest2/ChatPanel5]
		['ChatPanel6'] = 'ChatPanel', -- ������� [Lowest2/ChatPanel6]
		['ChatPanel7'] = 'ChatPanel', -- ������� [Lowest2/ChatPanel7]
		['ChatPanel8'] = 'ChatPanel', -- ������� [Lowest2/ChatPanel8]
		['ChatPanel9'] = 'ChatPanel', -- ������� [Lowest2/ChatPanel9]
		['ChatPanel10'] = 'ChatPanel', -- ������� [Lowest2/ChatPanel10]
		['DynamicActionBar'] = 'DynamicActionBar', -- ��̬������ [Lowest1/DynamicActionBar]
		['ExteriorAction'] = 'ExteriorAction', -- ��װ���� [Normal/ExteriorAction]
		['MentorMessage'] = 'MentorMessage', -- ʦͽ��ʾ [Normal/MentorMessage]
		['JX_TeamCD'] = 'JX_TeamCD', -- ���ġ��ŶӼ��ܼ�� [Normal/JX_TeamCD]
		['JX_HeightMeter'] = 'JX_HeightMeter', -- ���ġ��߶ȱ��� [Normal/JX_HeightMeter]
	},
}
RegisterCustomData('MY_LockFrame.bEnable')
RegisterCustomData('MY_LockFrame.tEnable')

local HOOKED_UI = setmetatable({}, { __mode = 'k' })
local UI_DRAGABLE = setmetatable({}, { __mode = 'k' })
local function EnableDrag(frame, bEnable)
	UI_DRAGABLE[frame] = bEnable
end
local function IsDragable(frame)
	return UI_DRAGABLE[frame] or false
end
function D.LockFrame(frame)
	if not HOOKED_UI[frame] then
		HOOKED_UI[frame] = true
		UI_DRAGABLE[frame] = frame:IsDragable()
		frame:EnableDrag(false)
		HookTableFunc(frame, 'EnableDrag', EnableDrag, { bDisableOrigin = true })
		HookTableFunc(frame, 'IsDragable', IsDragable, { bDisableOrigin = true, bHookReturn = true })
	end
end
function D.UnlockFrame(frame)
	if HOOKED_UI[frame] then
		UnhookTableFunc(frame, 'EnableDrag', EnableDrag)
		UnhookTableFunc(frame, 'IsDragable', IsDragable)
		frame:EnableDrag(UI_DRAGABLE[frame])
		HOOKED_UI[frame] = nil
		UI_DRAGABLE[frame] = nil
	end
end

function D.IsFrameLock(frame)
	if not O.bEnable or O.bTempDisable or not frame then
		return false
	end
	local szLock = O.tLockID[frame:GetName()]
	return szLock and O.tEnable[szLock] ~= false
end

function D.CheckFrame(frame)
	local bLock = D.IsFrameLock(frame)
	if bLock then
		D.LockFrame(frame)
	else
		D.UnlockFrame(frame)
	end
end

function D.CheckAllFrame()
	for _, szLayer in ipairs({'Lowest', 'Lowest1', 'Lowest2', 'Normal', 'Normal1', 'Normal2', 'Topmost', 'Topmost1', 'Topmost2'})do
		local frmIter = Station.Lookup(szLayer):GetFirstChild()
		while frmIter do
			local bLock = D.IsFrameLock(frmIter)
			if bLock then
				D.LockFrame(frmIter)
			else
				D.UnlockFrame(frmIter)
			end
			frmIter = frmIter:GetNext()
		end
	end
	if O.bEnable then
		LIB.RegisterEvent('ON_FRAME_CREATE.MY_LockFrame', function()
			D.CheckFrame(arg0)
		end)
		LIB.RegisterSpecialKeyEvent('*.MY_LockFrame', function()
			if IsCtrlKeyDown() and (IsShiftKeyDown() or IsAltKeyDown()) then
				if not O.bTempDisable then
					LIB.Topmsg(_L['MY_LockFrame has been temporary disabled.'])
					O.bTempDisable = true
					D.CheckAllFrame()
				end
			else
				if O.bTempDisable then
					LIB.Topmsg(_L['MY_LockFrame has been enabled.'])
					O.bTempDisable = false
					D.CheckAllFrame()
				end
			end
		end)
	else
		LIB.RegisterEvent('ON_FRAME_CREATE.MY_LockFrame', false)
		LIB.RegisterSpecialKeyEvent('*.MY_LockFrame', false)
	end
end

LIB.RegisterInit('MY_LockFrame', D.CheckAllFrame)

function D.OnPanelActivePartial(ui, X, Y, W, H, x, y)
	ui:Append('WndComboBox', {
		x = W - 140, y = 78, w = 130,
		text = _L['Lock frame position'],
		menu = function()
			local t = {
				{
					szOption = _L['Enable (press ctrl+alt to temp unlock)'],
					bCheck = true, bChecked = MY_LockFrame.bEnable,
					fnAction = function(_, b)
						MY_LockFrame.bEnable = b
						D.CheckAllFrame()
					end,
				}, CONSTANT.MENU_DIVIDER,
			}
			for _, k in ipairs(O.tLockList) do
				insert(t, {
					szOption = _L['LOCK_FRAME_' .. k],
					bCheck = true, bChecked = MY_LockFrame.tEnable[k] ~= false,
					fnAction = function(_, b)
						MY_LockFrame.tEnable[k] = b
						D.CheckAllFrame()
					end,
					fnDisable = function()
						return not MY_LockFrame.bEnable
					end,
				})
			end
			return t
		end,
	})
	return x, y
end

-- Global exports
do
local settings = {
	exports = {
		{
			fields = {
				OnPanelActivePartial = D.OnPanelActivePartial,
			},
		},
		{
			fields = {
				bEnable = true,
				tEnable = true,
			},
			root = O,
		},
	},
	imports = {
		{
			fields = {
				bEnable = true,
				tEnable = true,
			},
			triggers = {
				bEnable = D.CheckAllFrame,
				tEnable = D.CheckAllFrame,
			},
			root = O,
		},
	},
}
MY_LockFrame = LIB.GeneGlobalNS(settings)
end
