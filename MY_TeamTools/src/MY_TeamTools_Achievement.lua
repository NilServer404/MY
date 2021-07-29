--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : �Ŷӹ��� - �Ŷӳɾ�
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
local PLUGIN_NAME = 'MY_TeamTools'
local PLUGIN_ROOT = PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_TeamTools_Achievement'
local _L = LIB.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not LIB.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^8.0.0') then
	return
end
--------------------------------------------------------------------------
local SZ_INI = PACKET_INFO.ROOT .. 'MY_TeamTools/ui/MY_TeamTools_Achievement.ini'
local O = LIB.CreateUserSettingsModule('MY_TeamTools_Achievement', _L['Raid'], {
	bIntelligentHide = {
		ePathType = PATH_TYPE.ROLE,
		szLabel = _L['MY_TeamTools'],
		xSchema = Schema.Boolean,
		xDefaultValue = true,
	},
})
local D = {
	dwMapID = 0,
	szSearch = '',
	szSort = 'name',
	szSortOrder = 'asc',
	aAchievement = {},
	aSearchAC = {},
}

local MAX_ALL_MAP_ACHI = 40
local ACHIEVE_CACHE = {}
local COUNTER_CACHE = {}
local EXCEL_WIDTH = 1056
local ACHI_MIN_WIDTH = 15
local ACHI_MAX_WIDTH = HUGE
local STAT_SORT = setmetatable({
	['FINISH'] = 3,
	['PROGRESS'] = 2,
	['UNKNOWN'] = 1,
}, { __index = function() return 0 end })

local function GeneCommonFormatText(id)
	return function(r)
		return GetFormatText(r[id], 162, 255, 255, 255)
	end
end
local function GeneCommonCompare(id)
	return function(r1, r2)
		if r1[id] == r2[id] then
			return 0
		end
		return r1[id] > r2[id] and 1 or -1
	end
end

function D.GetColumns()
	local aCol = {
		{ -- ����
			id = 'name',
			szTitle = _L['Name'],
			nMinWidth = 110, nMaxWidth = 200,
			GetFormatText = function(rec)
				local name = rec.name
				if MY_ChatMosaics and MY_ChatMosaics.MosaicsString then
					name = MY_ChatMosaics.MosaicsString(name)
				end
				return GetFormatText(name, 162, LIB.GetForceColor(rec.force, 'foreground'))
			end,
			Compare = GeneCommonCompare('name'),
		},
	}
	for _, dwAchieveID in ipairs(D.aAchievement) do
		local achi = LIB.GetAchievement(dwAchieveID)
		if achi then
			insert(aCol, {
				id = 'achievement_' .. dwAchieveID,
				dwAchieveID = dwAchieveID,
				szTitle = achi.szName,
				nMinWidth = ACHI_MIN_WIDTH, nMaxWidth = ACHI_MAX_WIDTH,
				GetFormatText = function(rec)
					local szStat = D.GetPlayerAchievementStat(rec.id, dwAchieveID)
					local szText, nR, nG, nB
					if szStat == 'FINISH' then
						szText, nR, nG, nB = _L['r'], 128, 255, 128
					elseif szStat == 'PROGRESS' then
						szText, nR, nG, nB = _L['x'], 255, 255, 255
					else
						szText, nR, nG, nB = _L['--'], 173, 173, 173
					end
					return GetFormatText(szText, 162, nR, nG, nB, 786,
						'this.playerid=' .. rec.id .. ';this.achieveid=' .. dwAchieveID, 'Text_Achieve')
				end,
				Compare = function(r1, r2)
					local szStat1, aProgressCounter1 = D.GetPlayerAchievementStat(r1.id, dwAchieveID)
					local szStat2, aProgressCounter2 = D.GetPlayerAchievementStat(r2.id, dwAchieveID)
					if szStat1 == szStat2 then
						if szStat1 == 'PROGRESS' then
							local nCounter1, nCounter2 = 0, 0
							for _, v in ipairs(aProgressCounter1) do
								nCounter1 = nCounter1 + v.nNumber
							end
							for _, v in ipairs(aProgressCounter2) do
								nCounter2 = nCounter2 + v.nNumber
							end
							if nCounter1 == nCounter2 then
								return 0
							end
							return nCounter1 > nCounter2 and 1 or -1
						end
						return 0
					end
					return STAT_SORT[szStat1] > STAT_SORT[szStat2] and 1 or -1
				end,
			})
		end
	end
	return aCol
end

function D.GetDispColumns()
	local aCol, nW = {}, 0
	local nExtraWidth, nFlexWidth = EXCEL_WIDTH, 0
	for _, col in ipairs(D.GetColumns()) do
		if nExtraWidth < col.nMinWidth then
			break
		end
		col.nFlexWidth = (col.nMaxWidth and not IsHugeNumber(col.nMaxWidth)
			and col.nMaxWidth
			or EXCEL_WIDTH) - col.nMinWidth
		insert(aCol, col)
		nFlexWidth = nFlexWidth + col.nFlexWidth
		nExtraWidth = nExtraWidth - col.nMinWidth
	end
	for i, col in ipairs(aCol) do
		col.nWidth = i == #aCol
			and (EXCEL_WIDTH - nW)
			or min(nExtraWidth * col.nFlexWidth / nFlexWidth + col.nMinWidth, col.nMaxWidth or HUGE)
		nW = nW + col.nWidth
	end
	return aCol
end

function D.UpdateSearchAC()
	local info = g_tTable.DungeonInfo:Search(D.dwMapID)
	D.aSearchAC = info
		and LIB.SplitString(info.szBossInfo, ' ', true)
		or {}
	FireUIEvent('MY_TEAMTOOLS_ACHI_SEARCH_AC')
end

function D.AchievementSorter(a, b)
	local v1 = a.dwSub == 10
		and 0
		or 1
	local v2 = b.dwSub == 10
		and 0
		or 1
	if v1 == v2 then
		return a.dwID > b.dwID
	end
	return v1 > v2
end

function D.UpdateAchievementID()
	local aAchievement = {}
	if D.dwMapID == 0 then
		local nCount = g_tTable.Achievement:GetRowCount()
		for i = 2, nCount do
			local achi = g_tTable.Achievement:GetRow(i)
			if achi and achi.nVisible == 1 and achi.dwGeneral == 1
			and (not O.bIntelligentHide or achi.dwSub ~= 10) -- ���������ɾ�
			and (IsEmpty(D.szSearch) or wfind(achi.szName, D.szSearch) or wfind(achi.szDesc, D.szSearch)) then
				insert(aAchievement, achi)
				if #aAchievement >= MAX_ALL_MAP_ACHI then
					break
				end
			end
		end
	else
		for _, dwAchieveID in ipairs(LIB.GetMapAchievements(D.dwMapID) or CONSTANT.EMPTY_TABLE) do
			local achi = LIB.GetAchievement(dwAchieveID)
			if achi
			and (not O.bIntelligentHide or achi.dwSub ~= 10) -- ���������ɾ�
			and (IsEmpty(D.szSearch) or wfind(achi.szName, D.szSearch) or wfind(achi.szDesc, D.szSearch)) then
				insert(aAchievement, achi)
			end
		end
	end
	sort(aAchievement, D.AchievementSorter)
	for i, achi in ipairs(aAchievement) do
		aAchievement[i] = achi.dwID
	end
	D.aAchievement = aAchievement
	FireUIEvent('MY_TEAMTOOLS_ACHI')
end

LIB.RegisterEvent('LOADING_ENDING', function()
	if MY_TeamTools.IsOpened() then
		return
	end
	D.dwMapID = GetClientPlayer().GetMapID()
	D.szSearch = ''
	D.UpdateSearchAC()
	D.UpdateAchievementID()
end)

-- ��ȡ�Ŷӳ�Ա�б�
function D.GetTeamMemberList(bIsOnLine)
	local me   = GetClientPlayer()
	local team = GetClientTeam()
	if me.IsInParty() then
		if bIsOnLine then
			local tTeam = {}
			for k, v in ipairs(team.GetTeamMemberList()) do
				local info = team.GetMemberInfo(v)
				if info and info.bIsOnLine then
					insert(tTeam, v)
				end
			end
			return tTeam
		else
			return team.GetTeamMemberList()
		end
	else
		return { me.dwID }
	end
end

function D.GetPlayerAchievementStat(dwID, dwAchieveID)
	if ACHIEVE_CACHE[dwID] and IsBoolean(ACHIEVE_CACHE[dwID][dwAchieveID]) then
		if ACHIEVE_CACHE[dwID][dwAchieveID] then
			return 'FINISH'
		end
		local achi = LIB.GetAchievement(dwAchieveID)
		if achi then
			local aProgressCounter = {}
			if COUNTER_CACHE[dwID] then
				for _, s in ipairs(LIB.SplitString(achi.szCounters, '|', true)) do
					local dwCounter = tonumber(s)
					if dwCounter and COUNTER_CACHE[dwID][dwCounter] then
						insert(aProgressCounter, {
							dwCounter = dwCounter,
							nNumber = COUNTER_CACHE[dwID][dwCounter],
						})
					end
				end
			end
			return 'PROGRESS', aProgressCounter
		end
	end
	return 'UNKNOWN'
end

do local ACHIEVE_POINT_CACHE = {}
function D.GetAchievementPoint(dwAchieveID)
	if not ACHIEVE_POINT_CACHE[dwAchieveID] then
		local nAchievePoint = Get(LIB.GetAchievementInfo(dwAchieveID), {'nPoint'}, 0)
		local achi = LIB.GetAchievement(dwAchieveID)
		if achi then
			for _, s in ipairs(LIB.SplitString(achi.szCounters, '|', true)) do
				local dwCounter = tonumber(s)
				if dwCounter then
					nAchievePoint = nAchievePoint + Get(LIB.GetAchievementInfo(dwCounter), {'nPoint'}, 0)
				end
			end
		end
		ACHIEVE_POINT_CACHE[dwAchieveID] = nAchievePoint
	end
	return ACHIEVE_POINT_CACHE[dwAchieveID]
end
end

do
local function AnalysisAchievementRequest(dwAchieveID, tAchieveID, tCounterID)
	local info = LIB.GetAchievement(dwAchieveID)
	if info then
		tAchieveID[dwAchieveID] = true
		for _, s in ipairs(LIB.SplitString(info.szCounters, '|', true)) do
			local dwCounter = tonumber(s)
			if dwCounter then
				tCounterID[dwCounter] = true
			end
		end
		for _, s in ipairs(LIB.SplitString(info.szSeries, '|', true)) do
			local dwSerie = tonumber(s)
			if dwSerie and not tAchieveID[dwSerie] then
				AnalysisAchievementRequest(dwSerie, tAchieveID, tCounterID)
			end
		end
		for _, s in ipairs(LIB.SplitString(info.szSubAchievements, '|', true)) do
			local dwSubAchieve = tonumber(s)
			if dwSubAchieve and not tAchieveID[dwSubAchieve] then
				AnalysisAchievementRequest(dwSubAchieve, tAchieveID, tCounterID)
			end
		end
	end
	return tAchieveID, tCounterID
end
function D.AnalysisAchievementRequest(aAchievement)
	local tAchieveID, tCounterID = {}, {}
	for _, dwAchieveID in ipairs(aAchievement) do
		AnalysisAchievementRequest(dwAchieveID, tAchieveID, tCounterID)
	end
	local aAchieveID, aCounterID = {}, {}
	for dwAchieveID, _ in pairs(tAchieveID) do
		insert(aAchieveID, dwAchieveID)
	end
	for dwCounterID, _ in pairs(tCounterID) do
		insert(aCounterID, dwCounterID)
	end
	return aAchieveID, aCounterID
end
end

function D.UpdateSelfData()
	local aAchieveID, aCounterID = D.AnalysisAchievementRequest(D.aAchievement)
	local me = GetClientPlayer()
	if not ACHIEVE_CACHE[me.dwID] then
		ACHIEVE_CACHE[me.dwID] = {}
	end
	if not COUNTER_CACHE[me.dwID] then
		COUNTER_CACHE[me.dwID] = {}
	end
	for _, dwAchieveID in ipairs(aAchieveID) do
		ACHIEVE_CACHE[me.dwID][dwAchieveID] = me.IsAchievementAcquired(dwAchieveID)
	end
	for _, dwCounterID in ipairs(aCounterID) do
		COUNTER_CACHE[me.dwID][dwCounterID] = me.GetAchievementCount(dwCounterID)
	end
	FireUIEvent('MY_TEAMTOOLS_ACHI')
end

function D.RequestTeamData()
	-- ����ǿ�������ˢ�������б�
	local aAchieveID, aCounterID = D.AnalysisAchievementRequest(D.aAchievement)
	local aRequestID, aRefreshID, tRequestID = {}, {}, {}
	local aTeamMemberList = D.GetTeamMemberList(true)
	for _, dwID in ipairs(aTeamMemberList) do
		for _, dwAchieveID in ipairs(aAchieveID) do
			if not ACHIEVE_CACHE[dwID] or IsNil(ACHIEVE_CACHE[dwID][dwAchieveID]) then
				tRequestID[dwID] = true
			end
		end
		for _, dwCounterID in ipairs(aCounterID) do
			if not COUNTER_CACHE[dwID] or IsNil(COUNTER_CACHE[dwID][dwCounterID]) then
				tRequestID[dwID] = true
			end
		end
	end
	for _, dwID in ipairs(aTeamMemberList) do
		if dwID ~= UI_GetClientPlayerID() then
			if tRequestID[dwID] then
				insert(aRequestID, dwID)
			else
				insert(aRefreshID, dwID)
			end
		end
	end
	if (not IsEmpty(aAchieveID) or not IsEmpty(aCounterID)) and (not IsEmpty(aRequestID) or not IsEmpty(aRefreshID)) then
		if #aRequestID == #aTeamMemberList - 1 then
			aRequestID = nil
		end
		if LIB.IsSafeLocked(SAFE_LOCK_EFFECT_TYPE.TALK) then
			LIB.Systopmsg(_L['Fetch teammate\'s data failed, please unlock talk and reopen.'])
		else
			LIB.SendBgMsg(PLAYER_TALK_CHANNEL.RAID, 'MY_TEAMTOOLS_ACHI_REQ', {aAchieveID, aCounterID, aRequestID, nil})
		end
	end
	-- ˢ���Լ���
	D.UpdateSelfData()
end

function D.DelayRequestTeamData()
	LIB.DelayCall('MY_TeamTools_Achievement_DelayReq', 1000, D.RequestTeamData)
end

LIB.RegisterBgMsg('MY_TEAMTOOLS_ACHI_RES', function(_, data, nChannel, dwTalkerID, szTalkerName, bSelf)
	local aAchieveRes, aCounterRes = data[1], data[2]
	if not ACHIEVE_CACHE[dwTalkerID] then
		ACHIEVE_CACHE[dwTalkerID] = {}
	end
	if not COUNTER_CACHE[dwTalkerID] then
		COUNTER_CACHE[dwTalkerID] = {}
	end
	for _, v in ipairs(aAchieveRes) do
		ACHIEVE_CACHE[dwTalkerID][v[1]] = v[2]
	end
	for _, v in ipairs(aCounterRes) do
		COUNTER_CACHE[dwTalkerID][v[1]] = v[2]
	end
	FireUIEvent('MY_TEAMTOOLS_ACHI')
end)

function D.OutputRowTip(this, rec)
	local aXml, nAchievePoint, nAciquiePoint = {}, 0, 0
	local aCol = D.GetColumns()
	local nLen = 0
	for _, col in ipairs(aCol) do
		if col.dwAchieveID then
			nLen = max(nLen, wlen(col.szTitle))
		end
	end
	for _, col in ipairs(aCol) do
		if col.dwAchieveID then
			local nPoint = D.GetAchievementPoint(col.dwAchieveID)
			local szSpace = g_tStrings.STR_ONE_CHINESE_SPACE:rep(nLen - wlen(col.szTitle))
			if D.GetPlayerAchievementStat(rec.id, col.dwAchieveID) == 'FINISH' then
				nAciquiePoint = nAciquiePoint + nPoint
			end
			nAchievePoint = nAchievePoint + nPoint
			insert(aXml, GetFormatText('[' .. col.szTitle .. ']' .. szSpace .. '  ', 162, 255, 255, 0))
			insert(aXml, col.GetFormatText(rec))
			insert(aXml, GetFormatText(' (+' .. nPoint .. ')', 162, 255, 128, 0))
		else
			insert(aXml, GetFormatText(col.szTitle, 162, 255, 255, 0))
			insert(aXml, GetFormatText(':  ', 162, 255, 255, 0))
			insert(aXml, col.GetFormatText(rec))
		end
		if IsCtrlKeyDown() then
			insert(aXml, GetFormatText('\t' .. col.id, 162, 255, 0, 0))
		else
			insert(aXml, GetFormatText('\n', 162, 255, 255, 255))
		end
	end
	insert(aXml, 5, GetFormatText(_L('Achievement point: %d / %d', nAciquiePoint, nAchievePoint) .. '\n', 162, 255, 128, 0))
	local x, y = this:GetAbsPos()
	local w, h = this:GetSize()
	local nPosType = UI.TIP_POSITION.RIGHT_LEFT
	OutputTip(concat(aXml), 450, {x, y, w, h}, nPosType)
end

function D.OutputAchieveTip(dwAchieveID, dwID)
	local achi = LIB.GetAchievement(dwAchieveID)
	if not achi then
		return
	end
	local aXml = {}
	-- �ɾ�����
	insert(aXml, GetFormatText('[' .. achi.szName .. ']', 162, 255, 255, 0))
	-- ���״̬
	if dwID then
		insert(aXml, GetFormatText(' ', 162, 255, 255, 255))
		local szStat, aProgressCounter = D.GetPlayerAchievementStat(dwID, dwAchieveID)
		if szStat == 'FINISH' then
			insert(aXml, GetFormatText(_L['(Finished)'] .. '\n', 162, 255, 255, 255))
		elseif szStat == 'PROGRESS' then
			if IsEmpty(aProgressCounter) then
				insert(aXml, GetFormatText(_L['(Progress)'] .. '\n', 162, 173, 173, 173))
			else
				insert(aXml, GetFormatText('(', 162, 255, 255, 255))
				for i, progress in ipairs(aProgressCounter) do
					local nTriggerVal = Get(LIB.GetAchievementInfo(progress.dwCounter), {'nTriggerVal'}, 1)
					if i ~= 1 then
						insert(aXml, GetFormatText(', ', 162, 255, 255, 255))
					end
					insert(aXml, GetFormatText(progress.nNumber .. '/' .. nTriggerVal, 162, 255, 255, 255))
				end
				insert(aXml, GetFormatText(')\n', 162, 255, 255, 255))
			end
		else --if szStat == 'UNKNOWN' then
			insert(aXml, GetFormatText(_L['(Unknown)'] .. '\n', 162, 255, 255, 255))
		end
	else
		insert(aXml, GetFormatText('\n', 162, 255, 255, 255))
	end
	insert(aXml, GetFormatText(_L('Achievement point: %d', D.GetAchievementPoint(dwAchieveID)) .. '\n', 162, 255, 128, 0))
	insert(aXml, GetFormatText(achi.szDesc .. '\n', 162, 255, 255, 255))
	-- �ӳɾ�
	for _, s in ipairs(LIB.SplitString(achi.szSubAchievements, '|', true)) do
		local dwSubAchieveID = tonumber(s)
		if dwSubAchieveID then
			local achi = LIB.GetAchievement(dwSubAchieveID)
			if dwID then
				local szStat, aProgressCounter = D.GetPlayerAchievementStat(dwID, dwSubAchieveID)
				if achi then
					if szStat == 'FINISH' then
						insert(aXml, GetFormatText(_L['r'], 162, 128, 255, 128))
					elseif szStat == 'PROGRESS' then
						insert(aXml, GetFormatText(_L['x'], 162, 173, 173, 173))
					else --if szStat == 'UNKNOWN' then
						insert(aXml, GetFormatText(_L['?'], 162, 173, 173, 173))
					end
					insert(aXml, GetFormatText(' ', 162, 255, 255, 255))
				end
				insert(aXml, GetFormatText(achi.szName, 162, 255, 255, 255))
				if not IsEmpty(aProgressCounter) then
					insert(aXml, GetFormatText(' (', 162, 255, 255, 255))
					for i, progress in ipairs(aProgressCounter) do
						local nTriggerVal = Get(LIB.GetAchievementInfo(progress.dwCounter), {'nTriggerVal'}, 1)
						if i ~= 1 then
							insert(aXml, GetFormatText(', ', 162, 255, 255, 255))
						end
						insert(aXml, GetFormatText(progress.nNumber .. '/' .. nTriggerVal, 162, 255, 255, 255))
					end
					insert(aXml, GetFormatText(')', 162, 255, 255, 255))
				end
				insert(aXml, GetFormatText('\n', 162, 255, 255, 255))
			else
				insert(aXml, GetFormatText(_L[' '] .. achi.szName .. '\n', 162, 255, 255, 255))
			end
		end
	end
	local x, y = this:GetAbsPos()
	local w, h = this:GetSize()
	OutputTip(concat(aXml), 450, {x, y, w, h}, UI.TIP_POSITION.TOP_BOTTOM)
end

function D.UpdatePage(page)
	UI(page):Fetch('Wnd_Total/WndAutocomplete_Map')
		:Text(D.tMapName[D.dwMapID] or '', WNDEVENT_FIRETYPE.PREVENT)

	local hCols = page:Lookup('Wnd_Total/WndScroll_Stat', 'Handle_StatColumns')
	hCols:Clear()

	local aCol, nX, Sorter = D.GetDispColumns(), 0, nil
	for i, col in ipairs(aCol) do
		local hCol = hCols:AppendItemFromData(page.hStatColumnData, 'Handle_StatColumn')
		local hTitle = hCol:Lookup('Handle_Stat_Title')
		local txt = hTitle:Lookup('Text_Stat_Title')
		local imgAsc = hCol:Lookup('Image_Stat_Asc')
		local imgDesc = hCol:Lookup('Image_Stat_Desc')
		local nWidth, nHeight = col.nWidth, hCol:GetH()
		local nSortDelta = nWidth > 70 and 25 or 15
		if i == 0 then
			hCol:Lookup('Image_Stat_Break'):Hide()
		end
		hCol.col = col
		hCol.achieveid = col.dwAchieveID
		hCol:SetRelX(nX)
		hCol:SetW(nWidth)
		hTitle:SetRelX(3)
		hTitle:SetSize(nWidth - 5, nHeight)
		txt:SetText(col.szTitle)
		txt:AutoSize()
		if hTitle:GetW() < txt:GetW() and hTitle:GetW() > 80 then
			txt:SetW(hTitle:GetW())
		end
		txt:SetRelX(hTitle:GetW() > txt:GetW() and (hTitle:GetW() - txt:GetW()) / 2 or 0)
		txt:SetRelY((hTitle:GetH() - txt:GetH()) / 2)
		hTitle:FormatAllItemPos()
		imgAsc:SetRelX(nWidth - nSortDelta)
		imgDesc:SetRelX(nWidth - nSortDelta)
		if D.szSort == col.id then
			Sorter = function(r1, r2)
				if D.szSortOrder == 'asc' then
					return col.Compare(r1, r2) < 0
				end
				return col.Compare(r1, r2) > 0
			end
		end
		imgAsc:SetVisible(D.szSort == col.id and D.szSortOrder == 'asc')
		imgDesc:SetVisible(D.szSort == col.id and D.szSortOrder == 'desc')
		hCol:FormatAllItemPos()
		nX = nX + nWidth
	end
	hCols:FormatAllItemPos()

	local me = GetClientPlayer()
	local team = GetClientTeam()
	local bIsInParty = LIB.IsInParty()
	local aRec = {}
	local aTeamMemberList = D.GetTeamMemberList()
	for _, dwID in ipairs(aTeamMemberList) do
		local info = bIsInParty and team.GetMemberInfo(dwID)
		if info or dwID == me.dwID then
			insert(aRec, {
				id = dwID,
				name = info and info.szName or me.szName,
				force = info and info.dwForceID or me.dwForceID,
				achi = ACHIEVE_CACHE[dwID] or CONSTANT.EMPTY_TABLE,
			})
		end
	end

	if Sorter then
		sort(aRec, Sorter)
	end

	local aCol = D.GetDispColumns()
	local hList = page:Lookup('Wnd_Total/WndScroll_Stat', 'Handle_List')
	hList:Clear()
	for i, rec in ipairs(aRec) do
		local hRow = hList:AppendItemFromData(page.hRowData, 'Handle_Row')
		hRow.rec = rec
		hRow:Lookup('Image_RowBg'):SetVisible(i % 2 == 1)
		local nX = 0
		for j, col in ipairs(aCol) do
			local hItem = hRow:AppendItemFromData(page.hItemData, 'Handle_Item') -- �ⲿ���в�
			local hItemContent = hItem:Lookup('Handle_ItemContent') -- �ڲ��ı����ֲ�
			hItemContent:AppendItemFromString(col.GetFormatText(rec))
			hItemContent:SetW(99999)
			hItemContent:FormatAllItemPos()
			hItemContent:SetSizeByAllItemSize()
			local nWidth = col.nWidth
			hItem:SetRelX(nX)
			hItem:SetW(nWidth)
			hItemContent:SetRelPos((nWidth - hItemContent:GetW()) / 2, (hItem:GetH() - hItemContent:GetH()) / 2)
			hItem:FormatAllItemPos()
			nX = nX + nWidth
		end
		hRow:FormatAllItemPos()
	end
	hList:FormatAllItemPos()
end

function D.DelayUpdatePage(page)
	LIB.DelayCall('MY_TeamTools_Achievement__DelayUpdatePage', 200, function()
		if IsElement(page) then
			D.UpdatePage(page)
		end
	end)
end

function D.SetSearch(szSearch)
	D.szSearch = szSearch
	D.UpdateAchievementID()
end

function D.OnInitPage()
	if not D.tMapMenu or not D.tMapName or not D.aMapName or not D.tMapID then
		local tMapMenu, tMapName, aMapName = {}, {}, {}
		insert(tMapMenu, {
			szOption = _L['All map'],
			fnAction = function()
				D.dwMapID = 0
				D.UpdateSearchAC()
				D.UpdateAchievementID()
				D.RequestTeamData()
				UI.ClosePopupMenu()
			end,
		})
		tMapName[0] = _L['All map']
		insert(aMapName, _L['All map'])
		insert(tMapMenu, {
			szOption = _L['Current map'],
			fnAction = function()
				D.dwMapID = GetClientPlayer().GetMapID()
				D.UpdateSearchAC()
				D.UpdateAchievementID()
				D.RequestTeamData()
				UI.ClosePopupMenu()
			end,
		})
		for _, group in ipairs(LIB.GetTypeGroupMap()) do
			local tSub = { szOption = group.szGroup }
			for _, info in ipairs(group.aMapInfo) do
				insert(tSub, {
					szOption = info.szName,
					fnAction = function()
						D.dwMapID = info.dwID
						D.UpdateSearchAC()
						D.UpdateAchievementID()
						D.RequestTeamData()
						UI.ClosePopupMenu()
					end
				})
				tMapName[info.dwID] = info.szName
				insert(aMapName, info.szName)
			end
			insert(tMapMenu, tSub)
		end
		D.tMapMenu = tMapMenu
		D.aMapName = aMapName
		D.tMapName = tMapName
		D.tMapID = LIB.FlipObjectKV(tMapName)
	end
	local frameTemp = Wnd.OpenWindow(SZ_INI, 'MY_TeamTools_Achievement')
	local wnd = frameTemp:Lookup('Wnd_Total')
	wnd:ChangeRelation(this, true, true)
	Wnd.CloseWindow(frameTemp)

	local nX = 20
	nX = nX + UI(wnd):Append('WndAutocomplete', {
		x = nX, y = 20, w = 250,
		name = 'WndAutocomplete_Map',
		onchange = function(szText)
			if D.tMapID[szText] then
				D.dwMapID = D.tMapID[szText]
				D.UpdateSearchAC()
				D.UpdateAchievementID()
				D.RequestTeamData()
			end
		end,
		autocomplete = {{'option', 'source', D.aMapName}},
		menu = function() return D.tMapMenu end,
	}):Width() + 5

	nX = nX + UI(wnd):Append('WndAutocomplete', {
		x = nX, y = 20, w = 200,
		name = 'WndAutocomplete_Search',
		text = D.szSearch,
		placeholder = _L['Search'],
		onchange = function(szText)
			LIB.Debounce(
				'MY_TeamTools_Achievement_Search',
				500,
				D.SetSearch,
				szText)
			LIB.Debounce('MY_TeamTools_Achievement_RequestTeamData', 2000, D.RequestTeamData)
		end,
		autocomplete = {{'option', 'source', D.aSearchAC}},
		onclick = function() UI(this):Autocomplete('search', '') end,
		onblur = function()
			D.RequestTeamData()
			LIB.Debounce('MY_TeamTools_Achievement_RequestTeamData', false)
		end,
	}):Width() + 5

	nX = nX + UI(wnd):Append('WndCheckBox', {
		x = nX, y = 20, w = 200,
		text = _L['Intelligent hide'],
		checked = O.bIntelligentHide,
		oncheck = function(bChecked)
			O.bIntelligentHide = bChecked
			D.UpdateAchievementID()
		end,
		tip = _L['Hide unimportant achievements'],
		tippostype = UI.TIP_POSITION.TOP_BOTTOM,
	}):Width() + 5

	UI(wnd):Append('WndButton', {
		x = 960, y = 20, w = 120,
		text = _L['Refresh'],
		onclick = function()
			D.RequestTeamData()
			LIB.Systopmsg(_L['Team achievement request sent.'])
		end,
	})

	local frame = this:GetRoot()
	frame:RegisterEvent('MY_TEAMTOOLS_ACHI')
	frame:RegisterEvent('MY_TEAMTOOLS_ACHI_SEARCH_AC')
	frame:RegisterEvent('ON_MY_MOSAICS_RESET')
	frame:RegisterEvent('NEW_ACHIEVEMENT')
	frame:RegisterEvent('SYNC_ACHIEVEMENT_DATA')
	frame:RegisterEvent('UPDATE_ACHIEVEMENT_POINT')
	frame:RegisterEvent('UPDATE_ACHIEVEMENT_COUNT')
	this.hRowData = frame:CreateItemData(SZ_INI, 'Handle_Row')
	this.hItemData = frame:CreateItemData(SZ_INI, 'Handle_Item')
	this.hStatColumnData = frame:CreateItemData(SZ_INI, 'Handle_StatColumn')
end

function D.OnActivePage()
	D.RequestTeamData()
	D.UpdatePage(this)
end

function D.OnEvent(event)
	if event == 'MY_TEAMTOOLS_ACHI' then
		D.DelayUpdatePage(this)
	elseif event == 'MY_TEAMTOOLS_ACHI_SEARCH_AC' then
		UI(this):Fetch('Wnd_Total/WndAutocomplete_Search'):Autocomplete('option', 'source', D.aSearchAC)
	elseif event == 'ON_MY_MOSAICS_RESET' then
		D.UpdatePage(this)
	elseif event == 'NEW_ACHIEVEMENT' or event == 'SYNC_ACHIEVEMENT_DATA'
	or event == 'UPDATE_ACHIEVEMENT_POINT' or event == 'UPDATE_ACHIEVEMENT_COUNT'
	or event == 'PARTY_DELETE_MEMBER' or event == 'PARTY_DISBAND' then
		D.UpdateSelfData()
		D.DelayUpdatePage(this)
		D.DelayRequestTeamData()
	elseif event == 'PARTY_ADD_MEMBER' or event == 'PARTY_UPDATE_BASE_INFO' then
		D.DelayRequestTeamData()
	end
end

function D.OnLButtonClick()
	local szName = this:GetName()
	if szName == 'Btn_Clear' then
		LIB.Confirm(_L['Clear record'], D.ClearAchievementLog)
	end
end

function D.OnItemLButtonClick()
	local name = this:GetName()
	if name == 'Handle_Row' then
		local AchievementPanel = _G.AchievementPanel or GetInsideEnv().AchievementPanel
		if AchievementPanel then
			AchievementPanel.Compare(this.rec.id)
		end
	elseif name == 'Handle_StatColumn' then
		if IsCtrlKeyDown() then
			if this.achieveid then
				LIB.InsertChatInput('achievement', this.achieveid)
			end
		elseif this.col.id then
			local page = this:GetParent():GetParent():GetParent():GetParent():GetParent()
			if D.szSort == this.col.id then
				D.szSortOrder = D.szSortOrder == 'asc' and 'desc' or 'asc'
			else
				D.szSort = this.col.id
			end
			D.UpdatePage(page)
		end
	elseif name == 'Text_Achieve' then
		if not this.achieveid then
			return
		end
		if IsCtrlKeyDown() then
			if this.achieveid then
				LIB.InsertChatInput('achievement', this.achieveid)
			end
		else
			local AchievementPanel = _G.AchievementPanel or GetInsideEnv().AchievementPanel
			if AchievementPanel then
				AchievementPanel.Open(nil, this.achieveid)
			end
		end
	end
end

function D.OnItemMouseEnter()
	local name = this:GetName()
	if name == 'Handle_Row' then
		D.OutputRowTip(this, this.rec)
	elseif name == 'Handle_StatColumn' or name == 'Text_Achieve' then
		if not this.achieveid then
			return
		end
		D.OutputAchieveTip(this.achieveid, this.playerid)
	end
end

function D.OnItemMouseLeave()
	local szName = this:GetName()
	if szName == 'Handle_Achievement' then
		if this and this:Lookup('Image_Cover') and this:Lookup('Image_Cover'):IsValid() then
			this:Lookup('Image_Cover'):Hide()
		end
	end
	HideTip()
end

-- Module exports
do
local settings = {
	name = 'MY_TeamTools_Achievement_Module',
	exports = {
		{
			preset = 'UIEvent',
			fields = {
				'OnInitPage',
				'OnDeactivePage',
			},
			root = D,
		},
	},
}
MY_TeamTools.RegisterModule('Achievement', _L['MY_TeamTools_Achievement'], LIB.CreateModule(settings))
end

-- Global exports
do
local settings = {
	name = 'MY_TeamTools_Achievement',
	exports = {
		{
			fields = {
				'bIntelligentHide',
			},
			root = O,
		},
		{
			preset = 'UIEvent',
			root = D,
		},
	},
	imports = {
		{
			fields = {
				'bIntelligentHide',
			},
			root = O,
		},
	},
}
MY_TeamTools_Achievement = LIB.CreateModule(settings)
end
