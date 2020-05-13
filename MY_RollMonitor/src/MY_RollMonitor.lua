--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : ROLL����
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
local _L = LIB.LoadLangPack(PACKET_INFO.ROOT .. 'MY_RollMonitor/lang/')
if not LIB.AssertVersion('MY_RollMonitor', _L['MY_RollMonitor'], 0x2011800) then
	return
end
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
				nRoll = math.max(nRoll, aRecord[i].nRoll)
			end
			return nRoll
		end
	},
	[SORT_TYPE.MIN] = { -- ���ҡ��ȡ��͵�
 		szName = _L['lowest score'],
		fnCalc = function(aRecord, nIndex1, nIndex2)
			local nRoll = 0
			for i = nIndex1, nIndex2 do
				nRoll = math.min(nRoll, aRecord[i].nRoll)
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
				nMin = math.min(nMin, nRoll)
				nMax = math.max(nMax, nRoll)
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
	{ nChannel = PLAYER_TALK_CHANNEL.TEAM, szName = _L['team channel'], rgb = GetMsgFontColor('MSG_TEAM'  , true) },
	{ nChannel = PLAYER_TALK_CHANNEL.RAID, szName = _L['raid channel'], rgb = GetMsgFontColor('MSG_TEAM'  , true) },
	{ nChannel = PLAYER_TALK_CHANNEL.TONG, szName = _L['tong channel'], rgb = GetMsgFontColor('MSG_GUILD' , true) },
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
MY_RollMonitor = { nSortType = 1, nTimeLimit = -1, nPublish = 0, nPublishChannel = PLAYER_TALK_CHANNEL.RAID, bPublishRestart = true }
RegisterCustomData('MY_RollMonitor.nSortType')
RegisterCustomData('MY_RollMonitor.nTimeLimit')
RegisterCustomData('MY_RollMonitor.nPublish')
RegisterCustomData('MY_RollMonitor.bPublishRestart')
RegisterCustomData('MY_RollMonitor.nPublishChannel')
local _C = {}

-- �¼���Ӧ����
-- �����
-- (void) MY_RollMonitor.OpenPanel()
function MY_RollMonitor.OpenPanel()
	LIB.ShowPanel()
	LIB.FocusPanel()
	LIB.SwitchTab('RollMonitor')
end

-- ���ROLL��
-- (void) MY_RollMonitor.Clear(nChannel, bEcho)
-- (boolean) bEcho   : �Ƿ������¿�ʼ������Ϣ
-- (number)  nChannel: ����Ƶ��
function MY_RollMonitor.Clear(bEcho, nChannel)
	if bEcho == nil then
		bEcho = MY_RollMonitor.bPublishRestart
	end
	if bEcho then
		nChannel = nChannel or MY_RollMonitor.nPublishChannel
		LIB.Talk(nChannel, _L['----------- roll restart -----------'] .. '\n')
	end
	m_tRecords = {}
	MY_RollMonitor.DrawBoard()
end

-- ��ø���ROLL����
-- MY_RollMonitor.GetPersonResult(szName, nSortType, nTimeLimit)
-- MY_RollMonitor.GetPersonResult(aRecord, nSortType, nTimeLimit)
-- (string)    szName     : Ҫ��ȡ���������
-- (table)     aRecord    : Ҫ��ȡ��ԭʼ����
-- (SORT_TYPE) nSortType  : ����ʽ ֵ�μ�ö��
-- (number)    nTimeLimit : ���ʱ������ �����5������300
function MY_RollMonitor.GetPersonResult(szName, nSortType, nTimeLimit)
	-- ��ʽ������
	nSortType = nSortType or MY_RollMonitor.nSortType
	nTimeLimit = nTimeLimit or MY_RollMonitor.nTimeLimit
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
			table.insert(aTime, rec.nTime)
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
-- (void) MY_RollMonitor.GetResult(nSortType, nTimeLimit)
-- (SORT_TYPE) nSortType  : ����ʽ ֵ�μ�ö��
-- (number)    nTimeLimit : ���ʱ������ �����5������300(-1��ʾ����ʱ)
function MY_RollMonitor.GetResult(nSortType, nTimeLimit)
	-- ��ʽ������
	nSortType = nSortType or MY_RollMonitor.nSortType
	nTimeLimit = nTimeLimit or MY_RollMonitor.nTimeLimit
	-- ��ȡ���������
	local t = {}
	for _, aRecord in pairs(m_tRecords) do
		aRecord = MY_RollMonitor.GetPersonResult(aRecord, nSortType, nTimeLimit)
		if aRecord then
			table.insert(t, aRecord)
		end
	end
	table.sort(t, function(v1, v2) return v1.nRoll > v2.nRoll end)
	return t
end

-- ����ROLL��
-- (void) MY_RollMonitor.Echo(nSortType, nLimit, nChannel, bShowUnroll)
-- (enum)    nSortType  : ����ʽ ö��[SORT_TYPE]
-- (number)  nLimit     : �����ʾ��������
-- (number)  nChannel   : ����Ƶ��
-- (boolean) bShowUnroll: �Ƿ���ʾδROLL��
function MY_RollMonitor.Echo(nSortType, nLimit, nChannel, bShowUnroll)
	if bShowUnroll == nil then
		bShowUnroll = MY_RollMonitor.bPublishUnroll
	end
	nSortType = nSortType or MY_RollMonitor.nSortType
	nLimit    = nLimit    or MY_RollMonitor.nPublish
	nChannel  = nChannel  or MY_RollMonitor.nPublishChannel

	LIB.Talk(nChannel, ('[%s][%s][%s]%s\n'):format(
		PACKET_INFO.SHORT_NAME, _L['roll monitor'],
		TIME_LIMIT_TITLE[MY_RollMonitor.nTimeLimit],
		SORT_TYPE_INFO[nSortType].szName
	), nil, true)
	LIB.Talk(nChannel, _L['-------------------------------'] .. '\n')
	local tNames = {}
	for i, aRecord in ipairs(MY_RollMonitor.GetResult(nSortType)) do
		if nLimit <= 0 or i <= nLimit then
			LIB.Talk(nChannel, _L('[%s] rolls for %d times, valid score is %s.', aRecord.szName, aRecord.nCount, string.gsub(aRecord.nRoll, '(%d+%.%d%d)%d+','%1')) .. '\n')
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
			LIB.Talk(nChannel, szUnrolledNames .. _L['haven\'t roll yet.']..'\n')
		end
	end
	LIB.Talk(nChannel, _L['-------------------------------'] .. '\n')
end

-- ���»��ƽ����ʾ����
-- (void) MY_RollMonitor.DrawBoard(ui uiBoard)
function MY_RollMonitor.DrawBoard(ui)
	if not ui then
		ui = m_uiBoard
	end
	m_aRecTime = {}
	if ui then
		local szHTML = ''
		local tNames = {}
		for _, aRecord in ipairs(MY_RollMonitor.GetResult()) do
			szHTML = szHTML ..
				LIB.GetCopyLinkText() ..
				GetFormatText('['..aRecord.szName..']', nil, nil, nil, nil, 515, nil, 'namelink_0') ..
				GetFormatText(_L( ' rolls for %d times, valid score is %s.', aRecord.nCount, (string.gsub(aRecord.nRoll,'(%d+%.%d%d)%d+','%1')) ) .. '\n')
			for _, nTime in ipairs(aRecord.aTime) do
				table.insert(m_aRecTime, nTime)
			end
			tNames[aRecord.szName] = true
		end
		table.sort(m_aRecTime)
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
				LIB.GetCopyLinkText() ..
				szUnrolledNames .. GetFormatText(_L['haven\'t roll yet.'])
			end
		end
		szHTML = LIB.RenderChatLink(szHTML)
		if MY_Farbnamen and MY_Farbnamen.Render then
			szHTML = MY_Farbnamen.Render(szHTML)
		end
		ui:clear():append(szHTML)
	end
end

-- ����Ƿ���Ҫ�ػ� �����ػ������»���
local function CheckBoardRedraw()
	if m_aRecTime[1]
	and m_aRecTime[1] < GetCurrentTime() then
		MY_RollMonitor.DrawBoard()
	end
end

-- ϵͳƵ����ش�����
local function OnMsgArrive(szMsg, nFont, bRich, r, g, b)
	local isRoll = false
	for szName, nRoll in string.gmatch(szMsg, _L['ROLL_MONITOR_EXP'] ) do
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
		table.insert(m_aRecTime, GetCurrentTime())
		table.insert(aRecord, {nTime = GetCurrentTime(), nRoll = nRoll})
	end
	if not isRoll then
		return
	end
	MY_RollMonitor.DrawBoard()
end
RegisterMsgMonitor(OnMsgArrive, {'MSG_SYS'})

-- ��ǩ������Ӧ����
function PS.OnPanelActive(wnd)
	local ui = UI(wnd)
	local w, h = ui:size()
	-- ��¼ģʽ
	ui:append('WndComboBox', {
		x = 20, y = 10, w = 180,
		text = SORT_TYPE_INFO[MY_RollMonitor.nSortType].szName,
		menu = function(raw)
			local t = {}
			for _, nSortType in ipairs(SORT_TYPE_LIST) do
				table.insert(t, {
					szOption = SORT_TYPE_INFO[nSortType].szName,
					fnAction = function()
						MY_RollMonitor.nSortType = nSortType
						MY_RollMonitor.DrawBoard()
						UI(raw):text(SORT_TYPE_INFO[nSortType].szName)
					end,
				})
			end
			return t
		end
	})
	-- ��Чʱ��
	ui:append('WndComboBox', {
		x = 210, y = 10, w = 120,
		text = TIME_LIMIT_TITLE[MY_RollMonitor.nTimeLimit],
		menu = function(raw)
			local t = {}
			for _, nSec in ipairs(TIME_LIMIT) do
				table.insert(t, {
					szOption = TIME_LIMIT_TITLE[nSec],
					fnAction = function()
						UI(raw):text(TIME_LIMIT_TITLE[nSec])
						MY_RollMonitor.nTimeLimit = nSec
						MY_RollMonitor.DrawBoard()
					end,
				})
			end
			return t
		end
	})
	-- ���
	ui:append('WndButton', {
		x = w - 176, y = 10, w = 90, text = _L['restart'],
		onlclick = function(nButton) MY_RollMonitor.Clear() end,
		rmenu = function()
			local t = {{
				szOption = _L['publish while restart'],
				bCheck = true, bMCheck = false, bChecked = MY_RollMonitor.bPublishRestart,
				fnAction = function() MY_RollMonitor.bPublishRestart = not MY_RollMonitor.bPublishRestart end,
			}, { bDevide = true }}
			for _, tChannel in ipairs(PUBLISH_CHANNELS) do
				table.insert(t, {
					szOption = tChannel.szName,
					rgb = tChannel.rgb,
					bCheck = true, bMCheck = true, bChecked = MY_RollMonitor.nPublishChannel == tChannel.nChannel,
					fnAction = function()
						MY_RollMonitor.nPublishChannel = tChannel.nChannel
					end
				})
			end
			return t
		end,
		tip = _L['left click to restart, right click to open setting.'],
		tippostype = MY_TIP_POSTYPE.TOP_BOTTOM,
	})
	-- ����
	ui:append('WndButton', {
		x = w - 86, y = 10, w = 80, text = _L['publish'],
		onlclick = function() MY_RollMonitor.Echo() end,
		rmenu = function()
			local t = { {
				szOption = _L['publish setting'], {
					bCheck = true, bMCheck = true, bChecked = MY_RollMonitor.nPublish == 3,
					fnAction = function() MY_RollMonitor.nPublish = 3 end,
					szOption = _L('publish top %d', 3)
				}, {
					bCheck = true, bMCheck = true, bChecked = MY_RollMonitor.nPublish == 5,
					fnAction = function() MY_RollMonitor.nPublish = 5 end,
					szOption = _L('publish top %d', 5)
				}, {
					bCheck = true, bMCheck = true, bChecked = MY_RollMonitor.nPublish == 10,
					fnAction = function() MY_RollMonitor.nPublish = 10 end,
					szOption = _L('publish top %d', 10)
				}, {
					bCheck = true, bMCheck = true, bChecked = MY_RollMonitor.nPublish == 0,
					fnAction = function() MY_RollMonitor.nPublish = 0 end,
					szOption = _L['publish all']
				}, { bDevide = true }, {
					bCheck = true, bChecked = MY_RollMonitor.bPublishUnroll,
					fnAction = function() MY_RollMonitor.bPublishUnroll = not MY_RollMonitor.bPublishUnroll end,
					szOption = _L['publish unroll']
				}
			}, { bDevide = true } }
			for _, tChannel in ipairs(PUBLISH_CHANNELS) do
				table.insert( t, {
					szOption = tChannel.szName,
					rgb = tChannel.rgb,
					bCheck = true, bMCheck = true, bChecked = MY_RollMonitor.nPublishChannel == tChannel.nChannel,
					fnAction = function()
						MY_RollMonitor.nPublishChannel = tChannel.nChannel
					end
				} )
			end
			return t
		end,
		tip = _L['left click to publish, right click to open setting.'],
		tippostype = MY_TIP_POSTYPE.TOP_BOTTOM,
		tipoffset = { x = -80 },
	})
	-- �����
	m_uiBoard = ui:append('WndScrollBox',{
		x = 20,  y = 40, w = w - 26, h = h - 60,
		handlestyle = 3, text = _L['average score with out pole']
	}, true)
	MY_RollMonitor.DrawBoard()
	LIB.BreatheCall('MY_RollMonitorRedraw', 1000, CheckBoardRedraw)
end

function PS.OnPanelDeactive()
	m_uiBoard = nil
	LIB.BreatheCall('MY_RollMonitorRedraw', false)
end

LIB.RegisterPanel('RollMonitor', _L['roll monitor'], _L['General'], 'UI/Image/UICommon/LoginCommon.UITex|30', PS)
