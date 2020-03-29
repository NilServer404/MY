--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : 副本CD统计
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
local wsub, wlen, wfind, wgsub = wstring.sub, wstring.len, wstring.find, StringReplaceW
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
local PLUGIN_NAME = 'MY_RoleStatistics'
local PLUGIN_ROOT = PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_RoleStatistics_DungeonStat'
local _L = LIB.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not LIB.AssertVersion(MODULE_NAME, _L[MODULE_NAME], 0x2013900) then
	return
end
--------------------------------------------------------------------------

CPath.MakeDir(LIB.FormatPath({'userdata/role_statistics', PATH_TYPE.GLOBAL}))

local DB = LIB.ConnectDatabase(_L['MY_RoleStatistics_DungeonStat'], {'userdata/role_statistics/dungeon_stat.db', PATH_TYPE.GLOBAL})
if not DB then
	return LIB.Sysmsg(_L['MY_RoleStatistics_DungeonStat'], _L['Cannot connect to database!!!'], CONSTANT.MSG_THEME.ERROR)
end
local SZ_INI = PACKET_INFO.ROOT .. 'MY_RoleStatistics/ui/MY_RoleStatistics_DungeonStat.ini'

DB:Execute('CREATE TABLE IF NOT EXISTS DungeonInfo (guid NVARCHAR(20), account NVARCHAR(255), region NVARCHAR(20), server NVARCHAR(20), name NVARCHAR(20), force INTEGER, level INTEGER, equip_score INTEGER, copy_info NVARCHAR(65535), progress_info NVARCHAR(65535), time INTEGER, PRIMARY KEY(guid))')
local DB_DungeonInfoW = DB:Prepare('REPLACE INTO DungeonInfo (guid, account, region, server, name, force, level, equip_score, copy_info, progress_info, time) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)')
local DB_DungeonInfoG = DB:Prepare('SELECT * FROM DungeonInfo WHERE guid = ?')
local DB_DungeonInfoR = DB:Prepare('SELECT * FROM DungeonInfo WHERE account LIKE ? OR name LIKE ? OR region LIKE ? OR server LIKE ? ORDER BY time DESC')
local DB_DungeonInfoD = DB:Prepare('DELETE FROM DungeonInfo WHERE guid = ?')

local D = {}
local O = {
	aColumn = {
		'name',
		'force',
		'week_team_dungeon',
		'week_raid_dungeon',
		'dungeon_427',
		'dungeon_428',
		'time_days',
	},
	szSort = 'time_days',
	szSortOrder = 'desc',
	tMapSaveCopy = {}, -- 单副本 CD
	tMapProgress = {}, -- 单BOSS CD
	bMapProgressApplied = false, -- 是否请求过副本进度
	bFloatEntry = false,
}
RegisterCustomData('Global/MY_RoleStatistics_DungeonStat.aColumn')
RegisterCustomData('Global/MY_RoleStatistics_DungeonStat.szSort')
RegisterCustomData('Global/MY_RoleStatistics_DungeonStat.szSortOrder')
RegisterCustomData('MY_RoleStatistics_DungeonStat.bFloatEntry')

local EXCEL_WIDTH = 960
local DUNGEON_WIDTH = 80
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
local COLUMN_LIST = {
	-- guid,
	-- account,
	{ -- 大区
		id = 'region',
		bHideInFloat = true,
		szTitle = _L['Region'],
		nWidth = 100,
		GetFormatText = GeneCommonFormatText('region'),
		Compare = GeneCommonCompare('region'),
	},
	{ -- 服务器
		id = 'server',
		bHideInFloat = true,
		szTitle = _L['Server'],
		nWidth = 100,
		GetFormatText = GeneCommonFormatText('server'),
		Compare = GeneCommonCompare('server'),
	},
	{ -- 名字
		id = 'name',
		bHideInFloat = true,
		szTitle = _L['Name'],
		nWidth = 130,
		GetFormatText = function(rec)
			local name = rec.name
			if MY_ChatMosaics and MY_ChatMosaics.MosaicsString then
				name = MY_ChatMosaics.MosaicsString(name)
			end
			return GetFormatText(name, 162, LIB.GetForceColor(rec.force, 'foreground'))
		end,
	},
	{ -- 门派
		id = 'force',
		bHideInFloat = true,
		szTitle = _L['Force'],
		nWidth = 50,
		GetFormatText = function(rec)
			return GetFormatText(g_tStrings.tForceTitle[rec.force], 162, 255, 255, 255)
		end,
		Compare = GeneCommonCompare('force'),
	},
	{ -- 等级
		id = 'level',
		bHideInFloat = true,
		szTitle = _L['Level'],
		nWidth = 50,
		GetFormatText = GeneCommonFormatText('level'),
		Compare = GeneCommonCompare('level'),
	},
	{ -- 装分
		id = 'equip_score',
		bHideInFloat = true,
		szTitle = _L['EquSC'],
		nWidth = 60,
		GetFormatText = GeneCommonFormatText('equip_score'),
		Compare = GeneCommonCompare('equip_score'),
	},
	{
		-- 时间
		id = 'time',
		bHideInFloat = true,
		szTitle = _L['Cache time'],
		nWidth = 165,
		GetFormatText = function(rec)
			return GetFormatText(LIB.FormatTime(rec.time, '%yyyy/%MM/%dd %hh:%mm:%ss'), 162, 255, 255, 255)
		end,
		Compare = GeneCommonCompare('time'),
	},
	{
		-- 时间计时
		id = 'time_days',
		bHideInFloat = true,
		szTitle = _L['Cache time days'],
		nWidth = 120,
		GetFormatText = function(rec)
			local nTime = GetCurrentTime() - rec.time
			local nSeconds = floor(nTime)
			local nMinutes = floor(nSeconds / 60)
			local nHours   = floor(nMinutes / 60)
			local nDays    = floor(nHours / 24)
			local nYears   = floor(nDays / 365)
			local nDay     = nDays % 365
			local nHour    = nHours % 24
			local nMinute  = nMinutes % 60
			local nSecond  = nSeconds % 60
			if nYears > 0 then
				return GetFormatText(_L('%d years %d days before', nYears, nDay), 162, 255, 255, 255)
			end
			if nDays > 0 then
				return GetFormatText(_L('%d days %d hours before', nDays, nHour), 162, 255, 255, 255)
			end
			if nHours > 0 then
				return GetFormatText(_L('%d hours %d mins before', nHours, nMinute), 162, 255, 255, 255)
			end
			if nMinutes > 0 then
				return GetFormatText(_L('%d mins %d secs before', nMinutes, nSecond), 162, 255, 255, 255)
			end
			if nSecond > 10 then
				return GetFormatText(_L('%d secs before', nSecond), 162, 255, 255, 255)
			end
			return GetFormatText(_L['Just now'], 162, 255, 255, 255)
		end,
		Compare = GeneCommonCompare('time'),
	},
}
local COLUMN_DICT = setmetatable({}, { __index = function(t, id)
	if id == 'week_team_dungeon' then
		return {
			id = id,
			szTitle = _L['Week routine: '] .. _L.ACTIVITY_MAP_TYPE.WEEK_TEAM_DUNGEON,
			nWidth = DUNGEON_WIDTH * #LIB.GetActivityMap('WEEK_TEAM_DUNGEON'),
		}
	elseif id == 'week_raid_dungeon' then
		return {
			id = id,
			szTitle = _L['Week routine: '] .. _L.ACTIVITY_MAP_TYPE.WEEK_RAID_DUNGEON,
			nWidth = DUNGEON_WIDTH * #LIB.GetActivityMap('WEEK_RAID_DUNGEON'),
		}
	elseif wfind(id, 'dungeon_') then
		local id, via = wgsub(id, 'dungeon_', ''), ''
		if wfind(id, '@') then
			local ids = LIB.SplitString(id, '@')
			id, via = tonumber(ids[1]), ids[2]
		else
			id = tonumber(id)
		end
		local map = id and LIB.GetMapInfo(id)
		if map then
			local col = { -- 副本CD
				id = 'dungeon_' .. id,
				szTitle = map.szName,
				nWidth = DUNGEON_WIDTH,
			}
			if via then
				local colVia = t[via]
				if colVia then
					col.szTitleTip = col.szTitle .. ' (' .. colVia.szTitle .. ')'
				end
			end
			if LIB.IsDungeonRoleProgressMap(map.dwID) then
				col.GetFormatText = function(rec)
					local aBossKill = rec.progress_info[map.dwID]
					local nNextTime, nCircle = LIB.GetDungeonRefreshTime(map.dwID)
					if not aBossKill or nNextTime - nCircle > rec.time then
						return GetFormatText(_L['--'], 162, 255, 255, 255)
					end
					local aXml = {}
					for _, bKill in ipairs(aBossKill) do
						insert(aXml, '<image>path="ui/Image/UITga/FBcdPanel01.UITex" name="Image_ProgressBoss" eventid=786 frame='
							.. (bKill and 20 or 21) .. ' w=12 h=12 script="this.mapid=' .. map.dwID .. '"</image>')
					end
					return concat(aXml)
				end
				col.Compare = function(r1, r2)
					local k1 = r1.progress_info[map.dwID]
					local k2 = r2.progress_info[map.dwID]
					if k1 and not k2 then
						return 1
					end
					if k2 and not k1 then
						return -1
					end
					if not k1 and not k2 then
						return 0
					end
					local s1, s2 = 0, 0
					for _, p in ipairs(k1) do
						if p then
							s1 = s1 + 1
						end
					end
					for _, p in ipairs(k2) do
						if p then
							s2 = s2 + 1
						end
					end
					return s1 > s2 and 1 or -1
				end
			else
				col.GetFormatText = function(rec)
					local aCopyID = rec.copy_info[map.dwID]
					local nNextTime, nCircle = LIB.GetDungeonRefreshTime(map.dwID)
					local szText = nNextTime - nCircle < rec.time
						and (aCopyID and aCopyID[1] or _L['None'])
						or (_L['--'])
					return GetFormatText(szText, 162, 255, 255, 255, 786, 'this.mapid=' .. map.dwID, 'Text_CD')
				end
				col.Compare = function(r1, r2)
					local k1 = r1.copy_info[map.dwID] and r1.copy_info[map.dwID][1]
					local k2 = r2.copy_info[map.dwID] and r2.copy_info[map.dwID][1]
					if k1 and not k2 then
						return 1
					end
					if k2 and not k1 then
						return -1
					end
					if not k1 and not k2 then
						return 0
					end
					return k1 > k2 and 1 or -1
				end
			end
			return col
		end
	end
end })
for _, p in ipairs(COLUMN_LIST) do
	if not p.Compare then
		p.Compare = function(r1, r2)
			if r1[p.szKey] == r2[p.szKey] then
				return 0
			end
			return r1[p.szKey] > r2[p.szKey] and 1 or -1
		end
	end
	COLUMN_DICT[p.id] = p
end
local TIP_COLUMN = {
	'region',
	'server',
	'name',
	'force',
	'level',
	'equip_score',
	'DUNGEON',
	'time',
	'time_days',
}

do
local REC_CACHE
function D.GetClientPlayerRec(bForceUpdate)
	local me = GetClientPlayer()
	if not me then
		return
	end
	local rec = REC_CACHE
	local guid = me.GetGlobalID() ~= '0' and me.GetGlobalID() or me.szName
	if not rec then
		rec = {}
		REC_CACHE = rec
	end
	D.UpdateMapProgress(bForceUpdate)

	-- 基础信息
	rec.guid = guid
	rec.account = LIB.GetAccount() or ''
	rec.region = LIB.GetRealServer(1)
	rec.server = LIB.GetRealServer(2)
	rec.name = me.szName
	rec.force = me.dwForceID
	rec.level = me.nLevel
	rec.equip_score = me.GetBaseEquipScore() + me.GetStrengthEquipScore() + me.GetMountsEquipScore()
	rec.time = GetCurrentTime()
	rec.copy_info = O.tMapSaveCopy
	rec.progress_info = O.tMapProgress
	return rec
end
end

function D.FlushDB(bForceUpdate)
	--[[#DEBUG BEGIN]]
	LIB.Debug('MY_RoleStatistics_DungeonStat', 'Flushing to database...', DEBUG_LEVEL.LOG)
	--[[#DEBUG END]]

	local rec = Clone(D.GetClientPlayerRec(bForceUpdate))
	D.EncodeRow(rec)

	DB:Execute('BEGIN TRANSACTION')
	DB_DungeonInfoW:ClearBindings()
	DB_DungeonInfoW:BindAll(
		rec.guid, rec.account, rec.region, rec.server,
		rec.name, rec.force, rec.level, rec.equip_score,
		rec.copy_info, rec.progress_info, rec.time)
	DB_DungeonInfoW:Execute()
	DB:Execute('END TRANSACTION')

	--[[#DEBUG BEGIN]]
	LIB.Debug('MY_RoleStatistics_DungeonStat', 'Flushing to database finished...', DEBUG_LEVEL.LOG)
	--[[#DEBUG END]]
end
LIB.RegisterFlush('MY_RoleStatistics_DungeonStat', function() D.FlushDB() end)

function D.GetColumns()
	local aCol = {}
	for _, id in ipairs(O.aColumn) do
		if id == 'week_team_dungeon' then
			for _, map in ipairs(LIB.GetActivityMap('WEEK_TEAM_DUNGEON')) do
				local col = COLUMN_DICT['dungeon_' .. map.dwID .. '@' .. id]
				if col then
					insert(aCol, col)
				end
			end
		elseif id == 'week_raid_dungeon' then
			for _, map in ipairs(LIB.GetActivityMap('WEEK_RAID_DUNGEON')) do
				local col = COLUMN_DICT['dungeon_' .. map.dwID .. '@' .. id]
				if col then
					insert(aCol, col)
				end
			end
		else
			local col = COLUMN_DICT[id]
			if col then
				insert(aCol, col)
			end
		end
	end
	return aCol
end

function D.UpdateUI(page)
	local hCols = page:Lookup('Wnd_Total/WndScroll_DungeonStat', 'Handle_DungeonStatColumns')
	hCols:Clear()

	local aCol, nX, Sorter = D.GetColumns(), 0, nil
	for i, col in ipairs(aCol) do
		local hCol = hCols:AppendItemFromIni(SZ_INI, 'Handle_DungeonStatColumn')
		local txt = hCol:Lookup('Text_DungeonStat_Title')
		local imgAsc = hCol:Lookup('Image_DungeonStat_Asc')
		local imgDesc = hCol:Lookup('Image_DungeonStat_Desc')
		local nWidth = i == #aCol and (EXCEL_WIDTH - nX) or col.nWidth
		local nSortDelta = nWidth > 70 and 25 or 15
		if i == 0 then
			hCol:Lookup('Image_DungeonStat_Break'):Hide()
		end
		hCol.szSort = col.id
		hCol.szTip = col.szTitleTip
		hCol:SetRelX(nX)
		hCol:SetW(nWidth)
		txt:SetW(nWidth)
		txt:SetText(col.szTitle)
		imgAsc:SetRelX(nWidth - nSortDelta)
		imgDesc:SetRelX(nWidth - nSortDelta)
		if O.szSort == col.id then
			Sorter = function(r1, r2)
				if O.szSortOrder == 'asc' then
					return col.Compare(r1, r2) < 0
				end
				return col.Compare(r1, r2) > 0
			end
		end
		imgAsc:SetVisible(O.szSort == col.id and O.szSortOrder == 'asc')
		imgDesc:SetVisible(O.szSort == col.id and O.szSortOrder == 'desc')
		hCol:FormatAllItemPos()
		nX = nX + nWidth
	end
	hCols:FormatAllItemPos()

	local szSearch = page:Lookup('Wnd_Total/Wnd_Search/Edit_Search'):GetText()
	local szUSearch = AnsiToUTF8('%' .. szSearch .. '%')
	DB_DungeonInfoR:ClearBindings()
	DB_DungeonInfoR:BindAll(szUSearch, szUSearch, szUSearch, szUSearch)
	local result = DB_DungeonInfoR:GetAll()

	for _, rec in ipairs(result) do
		D.DecodeRow(rec)
	end

	if Sorter then
		sort(result, Sorter)
	end

	local aCol = D.GetColumns()
	local hList = page:Lookup('Wnd_Total/WndScroll_DungeonStat', 'Handle_List')
	hList:Clear()
	for i, rec in ipairs(result) do
		local hRow = hList:AppendItemFromIni(SZ_INI, 'Handle_Row')
		hRow.rec = rec
		hRow:Lookup('Image_RowBg'):SetVisible(i % 2 == 1)
		local nX = 0
		for j, col in ipairs(aCol) do
			local hItem = hRow:AppendItemFromIni(SZ_INI, 'Handle_Item') -- 外部居中层
			local hItemContent = hItem:Lookup('Handle_ItemContent') -- 内部文本布局层
			hItemContent:AppendItemFromString(col.GetFormatText(rec))
			hItemContent:SetW(99999)
			hItemContent:FormatAllItemPos()
			hItemContent:SetSizeByAllItemSize()
			local nWidth = col.nWidth
			if j == #aCol then
				nWidth = EXCEL_WIDTH - nX
			end
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

function D.OnGetMapSaveCopyResopnse(tMapCopy)
	O.tMapSaveCopy = tMapCopy
end

function D.UpdateMapProgress(bForceUpdate)
	-- 如果不是强制刷新副本进度并且已经请求过，则不再重复发起
	if not bForceUpdate and O.bMapProgressApplied then
		return
	end
	local me = GetClientPlayer()
	if not me then -- 确保不可能在切换GS时请求
		return
	end
	for _, col in ipairs(D.GetColumns()) do
		local szID = wfind(col.id, 'dungeon_') and wgsub(col.id, 'dungeon_', '')
		local dwID = szID and tonumber(szID)
		local aProgressBoss = dwID and LIB.IsDungeonRoleProgressMap(dwID) and Table_GetCDProcessBoss(dwID)
		if aProgressBoss then
			ApplyDungeonRoleProgress(dwID, UI_GetClientPlayerID())
			local aProgress = {}
			for i, boss in ipairs(aProgressBoss) do
				aProgress[i] = GetDungeonRoleProgress(dwID, UI_GetClientPlayerID(), boss.dwProgressID)
			end
			O.tMapProgress[dwID] = aProgress
		end
	end
	O.bMapProgressApplied = true
	LIB.GetMapSaveCopy(D.OnGetMapSaveCopyResopnse)
end

-- BOSS倒了刷新CD
LIB.RegisterEvent('SYNC_LOOT_LIST.MY_RoleStatistics_DungeonStat__UpdateMapCopy', function()
	if not LIB.IsInDungeon() then
		return
	end
	LIB.DelayCall('MY_RoleStatistics_DungeonStat__UpdateMapCopy', 300, function() D.UpdateMapProgress() end)
end)

function D.EncodeRow(rec)
	rec.guid   = AnsiToUTF8(rec.guid)
	rec.name   = AnsiToUTF8(rec.name)
	rec.region = AnsiToUTF8(rec.region)
	rec.server = AnsiToUTF8(rec.server)
	rec.copy_info = EncodeLUAData(rec.copy_info)
	rec.progress_info = EncodeLUAData(rec.progress_info)
end

function D.DecodeRow(rec)
	rec.guid   = UTF8ToAnsi(rec.guid)
	rec.name   = UTF8ToAnsi(rec.name)
	rec.region = UTF8ToAnsi(rec.region)
	rec.server = UTF8ToAnsi(rec.server)
	rec.copy_info = DecodeLUAData(rec.copy_info or '') or {}
	rec.progress_info = DecodeLUAData(rec.progress_info or '') or {}
end

function D.OutputRowTip(this, rec)
	local aXml = {}
	local bFloat = this:GetRoot():GetName() ~= 'MY_RoleStatistics'
	for _, id in ipairs(TIP_COLUMN) do
		if id == 'DUNGEON' then
			local tDungeon = {}
			for _, col in ipairs(D.GetColumns()) do
				if wfind(col.id, 'dungeon_') then
					insert(aXml, GetFormatText(col.szTitle, 162, 255, 255, 0))
					insert(aXml, GetFormatText(':  ', 162, 255, 255, 0))
					insert(aXml, col.GetFormatText(rec))
					insert(aXml, GetFormatText('\n', 162, 255, 255, 255))
					tDungeon[tonumber(col.id:sub(#'dungeon_' + 1))] = true
				end
			end
			for dwMapID, aCopyID in pairs(rec.copy_info) do
				if not tDungeon[dwMapID] then
					local map = LIB.GetMapInfo(dwMapID)
					if map then
						insert(aXml, GetFormatText(map.szName, 162, 255, 255, 0))
						insert(aXml, GetFormatText(':  ', 162, 255, 255, 0))
						insert(aXml, GetFormatText(concat(aCopyID, ',')))
						insert(aXml, GetFormatText('\n', 162, 255, 255, 255))
					end
					tDungeon[dwMapID] = true
				end
			end
		else
			local col = COLUMN_DICT[id]
			if col and (not bFloat or not col.bHideInFloat) then
				insert(aXml, GetFormatText(col.szTitle, 162, 255, 255, 0))
				insert(aXml, GetFormatText(':  ', 162, 255, 255, 0))
				insert(aXml, col.GetFormatText(rec))
				insert(aXml, GetFormatText('\n', 162, 255, 255, 255))
			end
		end
	end
	local x, y = this:GetAbsPos()
	local w, h = this:GetSize()
	local nPosType = bFloat and UI.TIP_POSITION.TOP_BOTTOM or UI.TIP_POSITION.RIGHT_LEFT
	OutputTip(concat(aXml), 450, {x, y, w, h}, nPosType)
end

function D.CloseRowTip()
	HideTip()
end

function D.OnInitPage()
	local page = this
	local frameTemp = Wnd.OpenWindow(SZ_INI, 'MY_RoleStatistics_DungeonStat')
	local wnd = frameTemp:Lookup('Wnd_Total')
	wnd:ChangeRelation(page, true, true)
	Wnd.CloseWindow(frameTemp)

	UI(wnd):Append('WndCheckBox', {
		x = 670, y = 21, w = 180,
		text = _L['Float panel'],
		checked = MY_RoleStatistics_DungeonStat.bFloatEntry,
		oncheck = function()
			MY_RoleStatistics_DungeonStat.bFloatEntry = not MY_RoleStatistics_DungeonStat.bFloatEntry
		end,
	})

	UI(wnd):Append('WndComboBox', {
		x = 800, y = 20, w = 180,
		text = _L['Columns'],
		menu = function()
			local t, aColumn, tChecked, nW = {}, O.aColumn, {}, 0
			-- 已添加的
			for i, id in ipairs(aColumn) do
				local col = COLUMN_DICT[id]
				if col then
					insert(t, {
						szOption = col.szTitle,
						{
							szOption = _L['Move up'],
							fnAction = function()
								if i > 1 then
									aColumn[i], aColumn[i - 1] = aColumn[i - 1], aColumn[i]
									D.UpdateUI(page)
								end
								UI.ClosePopupMenu()
							end,
						},
						{
							szOption = _L['Move down'],
							fnAction = function()
								if i < #aColumn then
									aColumn[i], aColumn[i + 1] = aColumn[i + 1], aColumn[i]
									D.UpdateUI(page)
								end
								UI.ClosePopupMenu()
							end,
						},
						{
							szOption = _L['Delete'],
							fnAction = function()
								remove(aColumn, i)
								D.UpdateUI(page)
								UI.ClosePopupMenu()
							end,
						},
					})
					nW = nW + col.nWidth
				end
				tChecked[id] = true
			end
			-- 未添加的
			local function fnAction(id, nWidth)
				local bExist = false
				for i, v in ipairs(aColumn) do
					if v == id then
						remove(aColumn, i)
						bExist = true
						break
					end
				end
				if not bExist then
					if nW + nWidth > EXCEL_WIDTH then
						LIB.Alert(_L['Too many column selected, width overflow, please delete some!'])
					else
						insert(aColumn, id)
					end
				end
				D.FlushDB(true)
				D.UpdateUI(page)
				UI.ClosePopupMenu()
			end
			-- 普通选项
			for _, col in ipairs(COLUMN_LIST) do
				if not tChecked[col.id] then
					insert(t, {
						szOption = col.szTitle,
						fnAction = function()
							fnAction(col.id, col.nWidth)
						end,
					})
				end
			end
			-- 副本选项
			local tDungeonChecked = {}
			for _, id in ipairs(aColumn) do
				local szID = wfind(id, 'dungeon_') and wgsub(id, 'dungeon_', '')
				local dwID = szID and tonumber(szID)
				if dwID then
					tDungeonChecked[dwID] = true
				end
			end
			local tDungeonMenu = LIB.GetDungeonMenu(function(info)
				fnAction('dungeon_' .. info.dwID, DUNGEON_WIDTH)
			end, nil, tDungeonChecked)
			-- 动态活动副本选项
			for _, szType in ipairs({
				'week_team_dungeon',
				'week_raid_dungeon',
			}) do
				local col = COLUMN_DICT[szType]
				if col then
					insert(tDungeonMenu, {
						szOption = col.szTitle,
						bCheck = true, bChecked = tChecked[col.id],
						fnAction = function()
							fnAction(col.id, col.nWidth)
						end,
					})
				end
			end
			-- 子菜单标题
			tDungeonMenu.szOption = _L['Dungeon copy']
			insert(t, tDungeonMenu)
			return t
		end,
	})

	local frame = page:GetRoot()
	frame:RegisterEvent('ON_MY_MOSAICS_RESET')
	frame:RegisterEvent('UPDATE_DUNGEON_ROLE_PROGRESS')
	frame:RegisterEvent('ON_APPLY_PLAYER_SAVED_COPY_RESPOND')
end

function D.OnActivePage()
	D.FlushDB(true)
	D.UpdateUI(this)
end

function D.OnEvent(event)
	if event == 'ON_MY_MOSAICS_RESET' then
		D.UpdateUI(this)
	elseif event == 'UPDATE_DUNGEON_ROLE_PROGRESS' or event == 'ON_APPLY_PLAYER_SAVED_COPY_RESPOND' then
		D.FlushDB()
		D.UpdateUI(this)
	end
end

function D.OnLButtonClick()
	local name = this:GetName()
	if name == 'Btn_Delete' then
		local wnd = this:GetParent()
		local page = this:GetParent():GetParent():GetParent():GetParent():GetParent()
		LIB.Confirm(_L('Are you sure to delete item record of %s?', wnd.name), function()
			DB_DungeonInfoD:ClearBindings()
			DB_DungeonInfoD:BindAll(wnd.guid)
			DB_DungeonInfoD:Execute()
			D.UpdateUI(page)
		end)
	end
end

function D.OnItemLButtonClick()
	local name = this:GetName()
	if name == 'Handle_DungeonStatColumn' then
		if this.szSort then
			local page = this:GetParent():GetParent():GetParent():GetParent():GetParent()
			if O.szSort == this.szSort then
				O.szSortOrder = O.szSortOrder == 'asc' and 'desc' or 'asc'
			else
				O.szSort = this.szSort
			end
			D.UpdateUI(page)
		end
	end
end

function D.OnItemRButtonClick()
	local name = this:GetName()
	if name == 'Handle_Row' then
		local rec = this.rec
		local page = this:GetParent():GetParent():GetParent():GetParent():GetParent()
		local menu = {
			{
				szOption = _L['Delete'],
				fnAction = function()
					DB_DungeonInfoD:ClearBindings()
					DB_DungeonInfoD:BindAll(rec.guid)
					DB_DungeonInfoD:Execute()
					D.UpdateUI(page)
				end,
			},
		}
		PopupMenu(menu)
	end
end

function D.OnEditSpecialKeyDown()
	local name = this:GetName()
	local szKey = GetKeyName(Station.GetMessageKey())
	if szKey == 'Enter' then
		if name == 'Edit_Search' then
			local page = this:GetParent():GetParent():GetParent()
			D.UpdateUI(page)
		end
		return 1
	end
end

function D.OnItemMouseEnter()
	local name = this:GetName()
	if name == 'Handle_Row' then
		D.OutputRowTip(this, this.rec)
	elseif name == 'Image_ProgressBoss' or name == 'Text_CD' then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		local aText = {}
		local map = LIB.GetMapInfo(this.mapid)
		if map then
			insert(aText, map.szName)
		end
		if name == 'Image_ProgressBoss' then
			insert(aText, '')
			local rec = this:GetParent():GetParent():GetParent().rec
			for i, boss in ipairs(Table_GetCDProcessBoss(this.mapid)) do
				insert(aText, boss.szName .. '\t' .. _L[rec.progress_info[this.mapid][i] and 'x' or 'r'])
			end
		end
		insert(aText, '')
		local nTime = LIB.GetDungeonRefreshTime(this.mapid) - GetCurrentTime()
		insert(aText, _L('Refresh: %s', LIB.FormatTimeCounter(nTime, 2, 2)))
		OutputTip(GetFormatText(concat(aText, '\n'), 162, 255, 255, 255), 400, { x, y, w, h })
	elseif name == 'Handle_DungeonStatColumn' then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		local szXml = GetFormatText(this.szTip or this:Lookup('Text_DungeonStat_Title'):GetText(), 162, 255, 255, 255)
		OutputTip(szXml, 450, {x, y, w, h}, UI.TIP_POSITION.TOP_BOTTOM)
	elseif this.tip then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputTip(this.tip, 400, {x, y, w, h, false}, nil, false)
	end
end
D.OnItemRefreshTip = D.OnItemMouseEnter

function D.OnItemMouseLeave()
	HideTip()
end

-- 浮动框
function D.ApplyFloatEntry(bFloatEntry)
	local frame = Station.Lookup('Normal/SprintPower')
	if not frame then
		return
	end
	local btn = frame:Lookup('Btn_MY_RoleStatistics_DungeonEntry')
	if bFloatEntry then
		if btn then
			return
		end
		local frameTemp = Wnd.OpenWindow(PLUGIN_ROOT .. '/ui/MY_RoleStatistics_DungeonEntry.ini', 'MY_RoleStatistics_DungeonEntry')
		btn = frameTemp:Lookup('Btn_MY_RoleStatistics_DungeonEntry')
		btn:ChangeRelation(frame, true, true)
		btn:SetRelPos(72, 13)
		Wnd.CloseWindow(frameTemp)
		btn.OnMouseEnter = function()
			local rec = D.GetClientPlayerRec(true)
			if not rec then
				return
			end
			D.OutputRowTip(this, rec)
		end
		btn.OnMouseLeave = function()
			D.CloseRowTip()
		end
		btn.OnLButtonClick = function()
			MY_RoleStatistics.Open('DungeonStat')
		end
	else
		if not btn then
			return
		end
		btn:Destroy()
	end
end
function D.UpdateFloatEntry()
	D.ApplyFloatEntry(O.bFloatEntry)
end
LIB.RegisterInit('MY_RoleStatistics_DungeonEntry', D.UpdateFloatEntry)
LIB.RegisterReload('MY_RoleStatistics_DungeonEntry', function() D.ApplyFloatEntry(false) end)
LIB.RegisterFrameCreate('SprintPower.MY_RoleStatistics_DungeonEntry', D.UpdateFloatEntry)

-- Module exports
do
local settings = {
	exports = {
		{
			fields = {
				OnInitPage = D.OnInitPage,
			},
		},
		{
			root = D,
			preset = 'UIEvent'
		},
	},
}
MY_RoleStatistics.RegisterModule('DungeonStat', _L['MY_RoleStatistics_DungeonStat'], LIB.GeneGlobalNS(settings))
end

-- Global exports
do
local settings = {
	exports = {
		{
			fields = {
				aColumn = true,
				szSort = true,
				szSortOrder = true,
				bFloatEntry = true,
			},
			root = O,
		},
	},
	imports = {
		{
			fields = {
				aColumn = true,
				szSort = true,
				szSortOrder = true,
				bFloatEntry = true,
			},
			triggers = {
				bFloatEntry = D.UpdateFloatEntry,
			},
			root = O,
		},
	},
}
MY_RoleStatistics_DungeonStat = LIB.GeneGlobalNS(settings)
end
