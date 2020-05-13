--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : �����������ɴ���
-- @author   : ���� @˫���� @׷����Ӱ
-- @modifier : Emil Zhai (root@derzh.com)
-- @copyright: Copyright (c) 2013 EMZ Kingsoft Co., Ltd.
--------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-- these global functions are accessed all the time by the event handler
-- so caching them is worth the effort
-----------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local ipairs, pairs, next, pcall = ipairs, pairs, next, pcall
local sub, len, format, rep = string.sub, string.len, string.format, string.rep
local find, byte, char, gsub = string.find, string.byte, string.char, string.gsub
local type, tonumber, tostring = type, tonumber, tostring
local HUGE, PI, random, abs = math.huge, math.pi, math.random, math.abs
local min, max, floor, ceil = math.min, math.max, math.floor, math.ceil
local pow, sqrt, sin, cos, tan, atan = math.pow, math.sqrt, math.sin, math.cos, math.tan, math.atan
local insert, remove, concat, sort = table.insert, table.remove, table.concat, table.sort
local pack, unpack = table.pack or function(...) return {...} end, table.unpack or unpack
-- jx3 apis caching
local wsub, wlen, wfind = wstring.sub, wstring.len, wstring.find
local GetTime, GetLogicFrameCount = GetTime, GetLogicFrameCount
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
local PROXY = {}
if IsDebugClient() then
function PROXY.DebugSetVal(szKey, oVal)
	PROXY[szKey] = oVal
end
end

for k, v in pairs(LIB) do
	PROXY[k] = v
	LIB[k] = nil
end
setmetatable(LIB, {
	__metatable = true,
	__index = PROXY,
	__newindex = function() assert(false, 'DO NOT modify ' .. PACKET_INFO.NAME_SPACE .. ' after initialized!!!') end
})
FireUIEvent(PACKET_INFO.NAME_SPACE .. '_BASE_LOADING_END')

-- �޸����ĵ������ͷ��Խ��Խ������⡣����
do
local nInitWidth, nFinalWidth
LIB.RegisterFrameCreate('Player.FixJXPlayer', function(name, frame)
	nInitWidth = frame:GetW()
end)
local function RevertWidth()
	local frame = Station.Lookup('Normal/Player')
	if not frame or not nInitWidth then
		return
	end
	nFinalWidth = frame:GetW()
	frame:SetW(nInitWidth)
end
local function ApplyWidth()
	local frame = Station.Lookup('Normal/Player')
	if not frame or not nFinalWidth then
		return
	end
	frame:SetW(nFinalWidth)
end
LIB.RegisterReload('FixJXPlayer', RevertWidth)
LIB.RegisterEvent('ON_ENTER_CUSTOM_UI_MODE.FixJXPlayer', RevertWidth)
LIB.RegisterEvent('ON_LEAVE_CUSTOM_UI_MODE.FixJXPlayer', ApplyWidth)
end
