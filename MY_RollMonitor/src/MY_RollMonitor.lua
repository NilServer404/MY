--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : ROLL����
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
local Call, XpCall, SafeCall, NSFormatString = LIB.Call, LIB.XpCall, LIB.SafeCall, LIB.NSFormatString
-------------------------------------------------------------------------------------------------------
local PLUGIN_NAME = 'MY_RollMonitor'
local PLUGIN_ROOT = PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_RollMonitor'
local _L = LIB.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not LIB.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^4.0.0') then
	return
end
--------------------------------------------------------------------------
local SORT_TYPE = {
	FIRST = 1,  -- ֻ��¼��һ��
	LAST  = 2,  -- ֻ��¼���һ��
	MAX   = 3,  -- ���ҡ��ȡ��ߵ�
	MIN   = 4,  -- ���ҡ��ȡ��͵�
	AVG   = 5,  -- ���ҡ��ȡƽ��ֵ
	AVG2  = 6,  -- ȥ��������ȡƽ��ֵ
}
local SORT_TYPE_LIST = {
	SORT_TYPE.FIRST, SORT_TYPE.LAST, SORT_TYPE.MAX,
	SORT_TYPE.MIN  , SORT_TYPE.AVG , SORT_TYPE.AVG2,
}
local SORT_TYPE_INFO = {
	[SORT_TYPE.FIRST] = { -- ֻ��¼��һ��
 		szName = _L['only first score'],
		fnCalc = function(aRecord, nIndex1, nIndex2)
			return aRecord[nIndex1].nRoll
		end
	},
	[SORT_TYPE.LAST] = { -- ֻ��¼���һ��
 		szName = _L['only last score'],
		fnCalc = function(aRecord, nIndex1, nIndex2)
			return aRecord[nIndex2].nRoll
		end
	},
	[SORT_TYPE.MAX] = { -- ���ҡ��ȡ��ߵ�
 		szName = _L['highest score'],
		fnCalc = function(aRecord, nIndex1, nIndex2)
			local nRoll = 0
			for i = nIndex1, nIndex2 do
				nRoll = max(nRoll, aRecord[i].nRoll)
			end
			return nRoll
		end
	},
	[SORT_TYPE.MIN] = { -- ���ҡ��ȡ��͵�
 		szName = _L['lowest score'],
		fnCalc = function(aRecord, nIndex1, nIndex2)
			local nRoll = 0
			for i = nIndex1, nIndex2 do
				nRoll = min(nRoll, aRecord[i].nRoll)
			end
			return nRoll
		end
	},
	[SORT_TYPE.AVG] = { -- ���ҡ��ȡƽ��ֵ
 		szName = _L['average score'],
		fnCalc = function(aRecord, nIndex1, nIndex2)
			local nRoll = 0
			for i = nIndex1, nIndex2 do
				nRoll = nRoll + aRecord[i].nRoll
			end
			return nRoll / (nIndex2 - nIndex1 + 1)
		end
	},
	[SORT_TYPE.AVG2] = { -- ȥ��������ȡƽ��ֵ
 		szName = _L['average score with out pole'],
		fnCalc = function(aRecord, nIndex1, nIndex2)
			local nTotal, nMax, nMin = 0, 0, 0
			local nCount = nIndex2 - nIndex1 + 1
			for i = nIndex1, nIndex2 do
				local nRoll = aRecord[i].nRoll
				nMin = min(nMin, nRoll)
				nMax = max(nMax, nRoll)
				nTotal = nTotal + nRoll
			end
			if nCount > 2 then
				nCount = nCount - 2
				nTotal = nTotal - nMax - nMin
			end
			return nTotal / nCount
		end
	},
}
local PUBLISH_CHANNELS = {
	{ nChannel = PLAYER_TALK_CHANNEL.TEAM, szName = _L['PTC_TEAM_CHANNEL'], rgb = GetMsgFontColor('MSG_TEAM'  , true) },
	{ nChannel = PLAYER_TALK_CHANNEL.RAID, szName = _L['PTC_RAID_CHANNEL'], rgb = GetMsgFontColor('MSG_TEAM'  , true) },
	{ nChannel = PLAYER_TALK_CHANNEL.TONG, szName = _L['PTC_TONG_CHANNEL'], rgb = GetMsgFontColor('MSG_GUILD' , true) },
}
local TIME_LIMIT = {-1, 60, 120, 180, 300, 600, 1200, 1800, 3600}
local TIME_LIMIT_TITLE = {
	 [-1  ] = _L['unlimited time'],
	 [60  ] = _L('last %d minute(s)', 1),
	 [120 ] = _L('last %d minute(s)', 2),
	 [180 ] = _L('last %d minute(s)', 3),
	 [300 ] = _L('last %d minute(s)', 5),
	 [600 ] = _L('last %d minute(s)', 10),
	 [1200] = _L('last %d minute(s)', 20),
	 [1800] = _L('last %d minute(s)', 30),
	 [3600] = _L('last %d minute(s)', 60),
}
local PS = {}
local m_uiBoard       -- ���ui�ؼ�
local m_tRecords = {} -- ��ʷROLL����ϸ��¼
local m_aRecTime = {} -- �¼�¼��ʱ����������ػ���壩
--[[
m_tRecords = {
	['����'] = {
		szName = '����',
		{nTime = 1446516554, nRoll = 100},
		{nTime = 1446516577, nRoll = 50 },
	}, ...
}
]]
local O = LIB.CreateUserSettingsModule('MY_RollMonitor', _L['MY_RollMonitor'], {
	nSortType = {
		ePathType = PATH_TYPE.ROLE,
		szLabel = _L['MY_RollMonitor'],
		xSchema = Schema.Number,
		xDefaultValue = 1,
	},
	nTimeLimit = {
		ePathType = PATH_TYPE.ROLE,
		szLabel = _L['MY_RollMonitor'],
		xSchema = Schema.Number,
		xDefaultValue = -1,
	},
	nPublish = {
		ePathType = PATH_TYPE.ROLE,
		szLabel = _L['MY_RollMonitor'],
		xSchema = Schema.Number,
		xDefaultValue = 0,
	},
	nPublishChannel = {
		ePathType = PATH_TYPE.ROLE,
		szLabel = _L['MY_RollMonitor'],
		xSchema = Schema.Number,
		xDefaultValue = PLAYER_TALK_CHANNEL.RAID,
	},
	bPublishUnroll = {
		ePathType = PATH_TYPE.ROLE,
		szLabel = _L['MY_RollMonitor'],
		xSchema = Schema.Boolean,
		xDefaultValue = true,
	},
	bPublishRestart = {
		ePathType = PATH_TYPE.ROLE,
		szLabel = _L['MY_RollMonitor'],
		xSchema = Schema.Boolean,
		xDefaultValue = true,
	},
})
local D = {}

-- �¼���Ӧ����
-- �����
-- (void) D.OpenPanel()
function D.OpenPanel()
	LIB.ShowPanel()
	LIB.FocusPanel()
	LIB.SwitchTab('RollMonitor')
end

-- ���ROLL��
-- (void) D.Clear(nChannel, bEcho)
-- (boolean) bEcho   : �Ƿ������¿�ʼ������Ϣ
-- (number)  nChannel: ����Ƶ��
function D.Clear(bEcho, nChannel)
	if bEcho == nil then
		bEcho = O.bPublishRestart
	end
	if bEcho then
		nChannel = nChannel or O.nPublishChannel
		LIB.SendChat(nChannel, _L['----------- roll restart -----------'] .. '\n')
	end
	m_tRecords = {}
	D.DrawBoard()
end

-- ��ø���ROLL����
-- D.GetPersonResult(szName, nSortType, nTimeLimit)
-- D.GetPersonResult(aRecord, nSortType, nTimeLimit)
-- (string)    szName     : Ҫ��ȡ���������
-- (table)     aRecord    : Ҫ��ȡ��ԭʼ����
-- (SORT_TYPE) nSortType  : ����ʽ ֵ�μ�ö��
-- (number)    nTimeLimit : ���ʱ������ �����5������300
function D.GetPersonResult(szName, nSortType, nTimeLimit)
	-- ��ʽ������
	nSortType = nSortType or O.nSortType
	nTimeLimit = nTimeLimit or O.nTimeLimit
	local nStartTime = 0
	if nTimeLimit > 0 then
		nStartTime = GetCurrentTime() - nTimeLimit
	end
	local aRecord
	if type(szName) == 'table' then
		aRecord = szName
	else
		aRecord = m_tRecords[szName] or CONSTANT.EMPTY_TABLE
	end
	-- ������ЧRoll�������±�
	local aTime = {}
	local nIndex1, nIndex2 = 0, #aRecord
	for i, rec in ipairs(aRecord) do
		if rec.nTime < nStartTime then
			nIndex1 = i
		else
			insert(aTime, rec.nTime)
		end
	end
	nIndex1 = nIndex1 + 1
	if nIndex1 > nIndex2 then
		return
	end
	local t = {
		szName = aRecord.szName,
		nRoll  = SORT_TYPE_INFO[nSortType].fnCalc(aRecord, nIndex1, nIndex2),
		nCount = nIndex2 - nIndex1 + 1,
		aTime  = aTime,
	}
	return t
end

-- ���ȫ��������
-- (void) D.GetResult(nSortType, nTimeLimit)
-- (SORT_TYPE) nSortType  : ����ʽ ֵ�μ�ö��
-- (number)    nTimeLimit : ���ʱ������ �����5������300(-1��ʾ����ʱ)
function D.GetResult(nSortType, nTimeLimit)
	-- ��ʽ������
	nSortType = nSortType or O.nSortType
	nTimeLimit = nTimeLimit or O.nTimeLimit
	-- ��ȡ���������
	local t = {}
	for _, aRecord in pairs(m_tRecords) do
		aRecord = D.GetPersonResult(aRecord, nSortType, nTimeLimit)
		if aRecord then
			insert(t, aRecord)
		end
	end
	sort(t, function(v1, v2) return v1.nRoll > v2.nRoll end)
	return t
end

-- ����ROLL��
-- (void) D.Echo(nSortType, nLimit, nChannel, bShowUnroll)
-- (enum)    nSortType  : ����ʽ ö��[SORT_TYPE]
-- (number)  nLimit     : �����ʾ��������
-- (number)  nChannel   : ����Ƶ��
-- (boolean) bShowUnroll: �Ƿ���ʾδROLL��
function D.Echo(nSortType, nLimit, nChannel, bShowUnroll)
	if bShowUnroll == nil then
		bShowUnroll = O.bPublishUnroll
	end
	nSortType = nSortType or O.nSortType
	nLimit    = nLimit    or O.nPublish
	nChannel  = nChannel  or O.nPublishChannel

	LIB.SendChat(nChannel, ('[%s][%s][%s]%s\n'):format(
		PACKET_INFO.SHORT_NAME, _L['roll monitor'],
		TIME_LIMIT_TITLE[O.nTimeLimit],
		SORT_TYPE_INFO[nSortType].szName
	), { parsers = { name = false } })
	LIB.SendChat(nChannel, _L['-------------------------------'] .. '\n')
	local tNames = {}
	for i, aRecord in ipairs(D.GetResult(nSortType)) do
		if nLimit <= 0 or i <= nLimit then
			LIB.SendChat(nChannel, _L('[%s] rolls for %d times, valid score is %s.', aRecord.szName, aRecord.nCount, gsub(aRecord.nRoll, '(%d+%.%d%d)%d+','%1')) .. '\n')
		end
		tNames[aRecord.szName] = true
	end
	local team = GetClientTeam()
	if team and bShowUnroll then
		local szUnrolledNames = ''
		for _, dwID in ipairs(team.GetTeamMemberList()) do
			local szName = team.GetClientTeamMemberName(dwID)
			if not tNames[szName] then
				szUnrolledNames = szUnrolledNames .. '[' .. szName .. ']'
			end
		end
		if szUnrolledNames~='' then
			LIB.SendChat(nChannel, szUnrolledNames .. _L['haven\'t roll yet.']..'\n')
		end
	end
	LIB.SendChat(nChannel, _L['-------------------------------'] .. '\n')
end

-- ���»��ƽ����ʾ����
-- (void) D.DrawBoard(ui uiBoard)
function D.DrawBoard(ui)
	if not ui then
		ui = m_uiBoard
	end
	m_aRecTime = {}
	if ui then
		local szHTML = ''
		local tNames = {}
		for _, aRecord in ipairs(D.GetResult()) do
			szHTML = szHTML ..
				LIB.GetChatCopyXML() ..
				GetFormatText('['..aRecord.szName..']', nil, nil, nil, nil, 515, nil, 'namelink_0') ..
				GetFormatText(_L( ' rolls for %d times, valid score is %s.', aRecord.nCount, (gsub(aRecord.nRoll,'(%d+%.%d%d)%d+','%1')) ) .. '\n')
			for _, nTime in ipairs(aRecord.aTime) do
				insert(m_aRecTime, nTime)
			end
			tNames[aRecord.szName] = true
		end
		sort(m_aRecTime)
		local team = GetClientTeam()
		if team then
			local szUnrolledNames = ''
			for _, dwID in ipairs(team.GetTeamMemberList()) do
				local szName = team.GetClientTeamMemberName(dwID)
				if not tNames[szName] then
					szUnrolledNames = szUnrolledNames .. GetFormatText('['..szName..']', nil, nil, nil, nil, 515, nil, 'namelink_0')
				end
			end
			if szUnrolledNames ~= '' then
				szHTML = szHTML ..
				LIB.GetChatCopyXML() ..
				szUnrolledNames .. GetFormatText(_L['haven\'t roll yet.'])
			end
		end
		szHTML = LIB.RenderChatLink(szHTML)
		if MY_Farbnamen and MY_Farbnamen.Render then
			szHTML = MY_Farbnamen.Render(szHTML)
		end
		ui:Clear():Append(szHTML)
	end
end

-- ����Ƿ���Ҫ�ػ� �����ػ������»���
local function CheckBoardRedraw()
	if m_aRecTime[1]
	and m_aRecTime[1] < GetCurrentTime() then
		D.DrawBoard()
	end
end

-- ϵͳƵ����ش�����
local function OnMsgArrive(szMsg, nFont, bRich, r, g, b)
	local isRoll = false
	for szName, nRoll in gmatch(szMsg, _L['ROLL_MONITOR_EXP'] ) do
		-- ��ʽ����ֵ
		nRoll = tonumber(nRoll)
		if not nRoll then
			return
		end
		isRoll = true
		-- �жϻ����и�����Ƿ��Ѵ��ڼ�¼
		if not m_tRecords[szName] then
			m_tRecords[szName] = { szName = szName }
		end
		local aRecord = m_tRecords[szName]
		-- ��ʽ������ ���¸���ֵ
		insert(m_aRecTime, GetCurrentTime())
		insert(aRecord, {nTime = GetCurrentTime(), nRoll = nRoll})
	end
	if not isRoll then
		return
	end
	D.DrawBoard()
end
RegisterMsgMonitor(OnMsgArrive, {'MSG_SYS'})


-- Global exports
do
local settings = {
	name = 'MY_RollMonitor',
	exports = {
		{
			fields = {
				OpenPanel = D.OpenPanel,
				Clear = D.Clear,
			},
		},
	},
}
MY_RollMonitor = LIB.CreateModule(settings)
end


-- ��ǩ������Ӧ����
function PS.OnPanelActive(wnd)
	local ui = UI(wnd)
	local w, h = ui:Size()
	-- ��¼ģʽ
	ui:Append('WndComboBox', {
		x = 20, y = 10, w = 180,
		text = SORT_TYPE_INFO[O.nSortType].szName,
		menu = function(raw)
			local t = {}
			for _, nSortType in ipairs(SORT_TYPE_LIST) do
				insert(t, {
					szOption = SORT_TYPE_INFO[nSortType].szName,
					fnAction = function()
						O.nSortType = nSortType
						D.DrawBoard()
						UI(raw):Text(SORT_TYPE_INFO[nSortType].szName)
						return 0
					end,
				})
			end
			return t
		end
	})
	-- ��Чʱ��
	ui:Append('WndComboBox', {
		x = 210, y = 10, w = 120,
		text = TIME_LIMIT_TITLE[O.nTimeLimit],
		menu = function(raw)
			local t = {}
			for _, nSec in ipairs(TIME_LIMIT) do
				insert(t, {
					szOption = TIME_LIMIT_TITLE[nSec],
					fnAction = function()
						UI(raw):Text(TIME_LIMIT_TITLE[nSec])
						O.nTimeLimit = nSec
						D.DrawBoard()
						return 0
					end,
				})
			end
			return t
		end
	})
	-- ���
	ui:Append('WndButton', {
		x = w - 176, y = 10, w = 90, text = _L['restart'],
		onlclick = function(nButton) D.Clear() end,
		rmenu = function()
			local t = {{
				szOption = _L['publish while restart'],
				bCheck = true, bMCheck = false, bChecked = O.bPublishRestart,
				fnAction = function() O.bPublishRestart = not O.bPublishRestart end,
			}, { bDevide = true }}
			for _, tChannel in ipairs(PUBLISH_CHANNELS) do
				insert(t, {
					szOption = tChannel.szName,
					rgb = tChannel.rgb,
					bCheck = true, bMCheck = true, bChecked = O.nPublishChannel == tChannel.nChannel,
					fnAction = function()
						O.nPublishChannel = tChannel.nChannel
					end
				})
			end
			return t
		end,
		tip = _L['left click to restart, right click to open setting.'],
		tippostype = UI.TIP_POSITION.TOP_BOTTOM,
	})
	-- ����
	ui:Append('WndButton', {
		x = w - 86, y = 10, w = 80, text = _L['publish'],
		onlclick = function() D.Echo() end,
		rmenu = function()
			local t = { {
				szOption = _L['publish setting'], {
					bCheck = true, bMCheck = true, bChecked = O.nPublish == 3,
					fnAction = function() O.nPublish = 3 end,
					szOption = _L('publish top %d', 3)
				}, {
					bCheck = true, bMCheck = true, bChecked = O.nPublish == 5,
					fnAction = function() O.nPublish = 5 end,
					szOption = _L('publish top %d', 5)
				}, {
					bCheck = true, bMCheck = true, bChecked = O.nPublish == 10,
					fnAction = function() O.nPublish = 10 end,
					szOption = _L('publish top %d', 10)
				}, {
					bCheck = true, bMCheck = true, bChecked = O.nPublish == 0,
					fnAction = function() O.nPublish = 0 end,
					szOption = _L['publish all']
				}, { bDevide = true }, {
					bCheck = true, bChecked = O.bPublishUnroll,
					fnAction = function() O.bPublishUnroll = not O.bPublishUnroll end,
					szOption = _L['publish unroll']
				}
			}, { bDevide = true } }
			for _, tChannel in ipairs(PUBLISH_CHANNELS) do
				insert( t, {
					szOption = tChannel.szName,
					rgb = tChannel.rgb,
					bCheck = true, bMCheck = true, bChecked = O.nPublishChannel == tChannel.nChannel,
					fnAction = function()
						O.nPublishChannel = tChannel.nChannel
					end
				} )
			end
			return t
		end,
		tip = _L['left click to publish, right click to open setting.'],
		tippostype = UI.TIP_POSITION.TOP_BOTTOM,
		tipoffset = { x = -80 },
	})
	-- �����
	m_uiBoard = ui:Append('WndScrollBox',{
		x = 20,  y = 40, w = w - 26, h = h - 60,
		handlestyle = 3, text = _L['average score with out pole']
	})
	D.DrawBoard()
	LIB.BreatheCall('MY_RollMonitorRedraw', 1000, CheckBoardRedraw)
end

function PS.OnPanelDeactive()
	m_uiBoard = nil
	LIB.BreatheCall('MY_RollMonitorRedraw', false)
end

LIB.RegisterPanel(_L['General'], 'RollMonitor', _L['roll monitor'], 'UI/Image/UICommon/LoginCommon.UITex|30', PS)
