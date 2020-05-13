--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : �����¼ ���ݿ⼯Ⱥ������
-- @author   : ���� @˫���� @׷����Ӱ
-- @modifier : Emil Zhai (root@derzh.com)
-- @copyright: Copyright (c) 2013 EMZ Kingsoft Co., Ltd.
--------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
-- these global functions are accessed all the time by the event handler
-- so caching them is worth the effort
-------------------------------------------------------------------------------------------------------------
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
local UI, DEBUG_LEVEL, PATH_TYPE = LIB.UI, LIB.DEBUG_LEVEL, LIB.PATH_TYPE
local var2str, str2var, ipairs_r = LIB.var2str, LIB.str2var, LIB.ipairs_r
local spairs, spairs_r, sipairs, sipairs_r = LIB.spairs, LIB.spairs_r, LIB.sipairs, LIB.sipairs_r
local GetTraceback, Call, XpCall = LIB.GetTraceback, LIB.Call, LIB.XpCall
local Get, Set, RandomChild = LIB.Get, LIB.Set, LIB.RandomChild
local GetPatch, ApplyPatch, clone, FullClone = LIB.GetPatch, LIB.ApplyPatch, LIB.clone, LIB.FullClone
local IsArray, IsDictionary, IsEquals = LIB.IsArray, LIB.IsDictionary, LIB.IsEquals
local IsNumber, IsHugeNumber = LIB.IsNumber, LIB.IsHugeNumber
local IsNil, IsBoolean, IsFunction = LIB.IsNil, LIB.IsBoolean, LIB.IsFunction
local IsEmpty, IsString, IsTable, IsUserdata = LIB.IsEmpty, LIB.IsString, LIB.IsTable, LIB.IsUserdata
local MENU_DIVIDER, EMPTY_TABLE, XML_LINE_BREAKER = LIB.MENU_DIVIDER, LIB.EMPTY_TABLE, LIB.XML_LINE_BREAKER
-------------------------------------------------------------------------------------------------------------
local XML_LINE_BREAKER = XML_LINE_BREAKER

local _L = LIB.LoadLangPack(LIB.GetAddonInfo().szRoot .. 'MY_ChatLog/lang/')
if not LIB.AssertVersion('MY_ChatLog', _L['MY_ChatLog'], 0x2013500) then
	return
end

------------------------------------------------------------------------------------------------------
-- ���ݿ������
------------------------------------------------------------------------------------------------------
local EXPORT_SLICE = 100
local SINGLE_DB_AMOUNT = 20000 -- �������ݿ�ڵ��������
-- Ƶ����Ӧ���ݿ�����ֵ ����� �����������޸�
local CHANNELS = {
	[1] = 'MSG_WHISPER',
	[2] = 'MSG_PARTY',
	[3] = 'MSG_TEAM',
	[4] = 'MSG_FRIEND',
	[5] = 'MSG_GUILD',
	[6] = 'MSG_GUILD_ALLIANCE',
	[7] = 'MSG_SELF_DEATH',
	[8] = 'MSG_SELF_KILL',
	[9] = 'MSG_PARTY_DEATH',
	[10] = 'MSG_PARTY_KILL',
	[11] = 'MSG_MONEY',
	[12] = 'MSG_EXP',
	[13] = 'MSG_ITEM',
	[14] = 'MSG_REPUTATION',
	[15] = 'MSG_CONTRIBUTE',
	[16] = 'MSG_ATTRACTION',
	[17] = 'MSG_PRESTIGE',
	[18] = 'MSG_TRAIN',
	[19] = 'MSG_MENTOR_VALUE',
	[20] = 'MSG_THEW_STAMINA',
	[21] = 'MSG_TONG_FUND',
	[22] = 'MSG_MY_MONITOR',
}
local CHANNELS_R = LIB.FlipObjectKV(CHANNELS)

local function SToNChannel(aChannel)
	local aNChannel = {}
	for _, szChannel in ipairs(aChannel) do
		insert(aNChannel, CHANNELS_R[szChannel])
	end
	return aNChannel
end

local function NewDB(szRoot, nMinTime, nMaxTime)
	local szPath
	repeat
		szPath = szRoot .. ('chatlog_%x'):format(math.random(0x100000, 0xFFFFFF)) .. '.db'
	until not IsLocalFileExist(szPath)
	local db = MY_ChatLog_DB(szPath)
	db:SetMinTime(nMinTime)
	db:SetMaxTime(nMaxTime)
	return db
end

local DS = class()
local DS_CACHE = setmetatable({}, {__mode = 'v'})

function DS:ctor(szRoot)
	self.szRoot = szRoot
	self.aInsertQueue = {}
	self.aDeleteQueue = {}
	self.aInsertQueueAnsi = {}
	return self
end

function DS:InitDB(bFixProblem)
	if not self.aDB then
		-- ��ʼ�����ݿ⼯Ⱥ�б�
		local aDB = {}
		for _, szName in ipairs(CPath.GetFileList(self.szRoot) or {}) do
			local db = szName:find('^chatlog_[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]%.db') and MY_ChatLog_DB(self.szRoot .. szName)
			if db then
				insert(aDB, db)
			end
		end
		sort(aDB, function(a, b) return a:GetMinTime() < b:GetMinTime() end)
		-- ɾ����Ⱥ�д���Ŀսڵ�
		for i, db in ipairs_r(aDB) do
			if not (i == #aDB and IsHugeNumber(db:GetMaxTime())) and db:CountMsg() == 0 then
				LIB.Debug({'Removing unexpected empty node: ' .. db:ToString()}, _L['MY_ChatLog'], DEBUG_LEVEL.WARNING)
				db:DeleteDB()
				remove(aDB, i)
			end
		end
		-- �޸��������������Ľڵ㣨�������ж����⡢�ֶγ�ͻ���⣩
		do
			local i = 1
			while i < #aDB do
				local db1, db2 = aDB[i], aDB[i + 1]
				-- ����м�ڵ����ֵ
				if IsHugeNumber(db1:GetMaxTime()) then
					LIB.Debug({'Unexpected huge MaxTime: ' .. db1:ToString()}, _L['MY_ChatLog'], DEBUG_LEVEL.WARNING)
					if not bFixProblem then
						return false
					end
					db1:SetMaxTime(db1:GetMaxRecTime())
					LIB.Debug({'Fix unexpected huge MaxTime: ' .. db1:ToString()}, _L['MY_ChatLog'], DEBUG_LEVEL.LOG)
				end
				-- �������������
				if db1:GetMaxTime() ~= db2:GetMinTime() then
					LIB.Debug({'Unexpected noncontinuously time between ' .. db1:ToString() .. ' and ' .. db2:ToString()}, _L['MY_ChatLog'], DEBUG_LEVEL.WARNING)
					if not bFixProblem then
						return false
					end
					if db1:GetMaxRecTime() <= db2:GetMinTime() then -- �������ж� �����������
						db1:SetMaxTime(db2:GetMinTime())
						LIB.Debug({'Fix noncontinuously time by modify ' .. db1:ToString()}, _L['MY_ChatLog'], DEBUG_LEVEL.LOG)
					elseif db1:GetMaxTime() <= db2:GetMinRecTime() then -- �������ж� �����Ҳ�����
						db2:SetMinTime(db1:GetMaxTime())
						LIB.Debug({'Fix noncontinuously time by modify ' .. db2:ToString()}, _L['MY_ChatLog'], DEBUG_LEVEL.LOG)
					elseif db1:GetMaxTime() >= db2:GetMaxTime() then -- ��������ͻ �Ҳ�������ȫ������������ ���Ҳ�ڵ㲢�����ڵ���
						for _, rec in ipairs(db2:SelectMsg()) do
							db1:InsertMsg(rec.nChannel, rec.szText, rec.szMsg, rec.szTalker, rec.nTime, rec.szHash)
						end
						db1:Flush()
						db2:DeleteDB()
						LIB.Debug({'Fix noncontinuously time by merge ' .. db2:ToString() .. ' to ' .. db1:ToString()}, _L['MY_ChatLog'], DEBUG_LEVEL.LOG)
						remove(aDB, i + 1)
						i = i - 1
					else -- ���������ͻ ���Ҳ�ڵ�ĳ�ͻ���������ƶ������ڵ���
						db1:SetMaxTime(db1:GetMaxRecTime())
						for _, rec in ipairs(db2:SelectMsgByTime('<=', db1:GetMaxTime())) do
							db1:InsertMsg(rec.nChannel, rec.szText, rec.szMsg, rec.szTalker, rec.nTime, rec.szHash)
						end
						db1:Flush()
						db2:DeleteMsgByTime('<=', db1:GetMaxTime())
						db2:SetMinTime(db1:GetMaxTime())
						LIB.Debug({'Fix noncontinuously time by moving data from ' .. db2:ToString() .. ' to ' .. db1:ToString()}, _L['MY_ChatLog'], DEBUG_LEVEL.LOG)
					end
				end
				i = i + 1
			end
		end
		-- ��鼯Ⱥ���»�Ծ�ڵ��Ƿ����
		local db = aDB[#aDB]
		if db and IsHugeNumber(db:GetMaxTime()) then -- ���ڣ� ��鼯Ⱥ���»�Ծ�ڵ�ѹ���Ƿ���
			if db:CountMsg() > SINGLE_DB_AMOUNT then
				db:SetMaxTime(db:GetMaxRecTime())
				local dbNew = NewDB(self.szRoot, db:GetMaxTime(), HUGE)
				insert(aDB, dbNew)
				LIB.Debug({'Create new empty active node ' .. db:ToString() .. ' after ' .. db:ToString()}, _L['MY_ChatLog'], DEBUG_LEVEL.LOG)
			end
		else -- �����ڣ� ����
			local nMinTime = 0
			if db then
				local nMaxTime = db:GetMaxRecTime()
				db:SetMaxTime(nMaxTime)
				nMinTime = nMaxTime
			end
			local dbNew = NewDB(self.szRoot, nMinTime, HUGE)
			insert(aDB, dbNew)
			LIB.Debug({'Create new empty active node ' .. db:ToString()}, _L['MY_ChatLog'], DEBUG_LEVEL.LOG)
		end
		-- ��鼯Ⱥ���Զ�ڵ㿪ʼʱ���Ƿ�Ϊ0
		local db = aDB[1]
		if db:GetMinTime() ~= 0 then
			LIB.Debug({'Unexpected MinTime for first DB: ' .. db:ToString()}, _L['MY_ChatLog'], DEBUG_LEVEL.WARNING)
			db:SetMinTime(0)
			LIB.Debug({'Fix unexpected MinTime for first DB: ' .. db:ToString()}, _L['MY_ChatLog'], DEBUG_LEVEL.LOG)
		end
		self.aDB = aDB
	end
	return self
end

function DS:OptimizeDB()
	if self:InitDB(true) then
		LIB.Debug({'OptimizeDB Start!'}, _L['MY_ChatLog'], DEBUG_LEVEL.LOG)
		local i = 1
		while i <= #self.aDB do
			local db = self.aDB[i]
			if db:CountMsg() > SINGLE_DB_AMOUNT then -- �����ڵ�ѹ������ ת�Ƴ������ֵ���һ���ڵ�
				LIB.Debug({'Node count exceed limit: ' .. db:ToString() .. ' ' .. db:CountMsg()}, _L['MY_ChatLog'], DEBUG_LEVEL.WARNING)
				local aRec = db:SelectMsg(nil, nil, SINGLE_DB_AMOUNT)
				local nTime = aRec[1].nTime
				local dbNext
				if i == #self.aDB then
					dbNext = NewDB(self.szRoot, nTime, HUGE)
				else
					dbNext = self.aDB[i + 1]
					dbNext:SetMinTime(nTime)
				end
				for _, rec in ipairs(aRec) do
					dbNext:InsertMsg(rec.nChannel, rec.szText, rec.szMsg, rec.szTalker, rec.nTime, rec.szHash)
				end
				dbNext:Flush()
				LIB.Debug({'Moving ' .. #aRec .. ' records from ' .. db:ToString() .. ' to ' .. dbNext:ToString()}, _L['MY_ChatLog'], DEBUG_LEVEL.LOG)
				for _, rec in ipairs(aRec) do
					db:DeleteMsg(rec.szHash, rec.nTime)
				end
				db:Flush()
				db:SetMaxTime(nTime)
				LIB.Debug({'Modify node property: ' .. db:ToString()}, _L['MY_ChatLog'], DEBUG_LEVEL.LOG)
			elseif db:CountMsg() < SINGLE_DB_AMOUNT then -- �����ڵ�ѹ����С ���¸��ڵ�ϲ�
				if i < #self.aDB then
					LIB.Debug({'Node count insufficient: ' .. db:ToString() .. ' ' .. db:CountMsg()}, _L['MY_ChatLog'], DEBUG_LEVEL.WARNING)
					local dbNext = self.aDB[i + 1]
					dbNext:SetMinTime(db:GetMinTime())
					for _, rec in ipairs(db:SelectMsg()) do
						dbNext:InsertMsg(rec.nChannel, rec.szText, rec.szMsg, rec.szTalker, rec.nTime, rec.szHash)
					end
					dbNext:Flush()
					LIB.Debug({'Merge node ' .. db:ToString() .. ' to ' .. dbNext:ToString()}, _L['MY_ChatLog'], DEBUG_LEVEL.LOG)
					db:DeleteDB()
					remove(self.aDB, i)
					i = i - 1
				end
			end
			i = i + 1
		end
	end
	return self
end

function DS:InsertMsg(szChannel, szText, szMsg, szTalker, nTime)
	if szMsg and szText and szTalker then
		local szuMsg    = AnsiToUTF8(szMsg)
		local szuText   = AnsiToUTF8(szText)
		local szHash    = GetStringCRC(szMsg)
		local szuTalker = AnsiToUTF8(szTalker)
		local nChannel  = CHANNELS_R[szChannel]
		if nChannel and nTime and not IsEmpty(szMsg) and szText and not IsEmpty(szHash) then
			insert(self.aInsertQueue, {szHash = szHash, nChannel = nChannel, nTime = nTime, szTalker = szuTalker, szText = szuText, szMsg = szuMsg})
			insert(self.aInsertQueueAnsi, {szHash = szHash, szChannel = szChannel, nTime = nTime, szTalker = szTalker, szText = szText, szMsg = szMsg})
		end
	end
	return self
end

function DS:CountMsg(aChannel, szSearch)
	if #aChannel == 0 then
		return 0
	end
	if not self:InitDB() then
		return 0
	end
	if not szSearch then
		szSearch = ''
	end
	local szuSearch = szSearch == '' and '' or AnsiToUTF8('%' .. szSearch .. '%')
	local aNChannel, nCount = SToNChannel(aChannel), 0
	for _, db in ipairs(self.aDB) do
		nCount = nCount + db:CountMsg(aNChannel, szuSearch)
	end
	for _, rec in ipairs(self.aInsertQueueAnsi) do
		if wfind(rec.szText, szSearch) or wfind(rec.szTalker, szSearch) then
			nCount = nCount + 1
		end
	end
	return nCount
end

function DS:SelectMsg(aChannel, szSearch, nOffset, nLimit)
	if #aChannel == 0 then
		return {}
	end
	if not self:InitDB() then
		return {}
	end
	if not szSearch then
		szSearch = ''
	end
	local szuSearch = szSearch == '' and '' or AnsiToUTF8('%' .. szSearch .. '%')
	local aNChannel, aResult = SToNChannel(aChannel), {}
	for _, db in ipairs(self.aDB) do
		if nLimit == 0 then
			break
		end
		local nCount = db:CountMsg(aNChannel, szuSearch)
		if nOffset < nCount then
			local res = db:SelectMsg(aNChannel, szuSearch, nOffset, nLimit)
			for _, p in ipairs(res) do
				p.szChannel = CHANNELS[p.nChannel]
				p.nChannel = nil
				p.szTalker = UTF8ToAnsi(p.szTalker)
				p.szText = UTF8ToAnsi(p.szText)
				p.szMsg = UTF8ToAnsi(p.szMsg)
				insert(aResult, p)
			end
			nLimit = max(nLimit - nCount + nOffset, 0)
		end
		nOffset = max(nOffset - nCount, 0)
	end
	if nLimit > 0 then
		local nCount = 0
		for _, rec in ipairs(self.aInsertQueueAnsi) do
			if wfind(rec.szText, szSearch) or wfind(rec.szTalker, szSearch) then
				insert(aResult, clone(rec))
				nCount = nCount + 1
			end
		end
		if nOffset > 0 then
			nOffset = max(nOffset - nCount, 0)
		end
		nLimit = max(nLimit - nCount, 0)
	end
	return aResult
end

function DS:DeleteMsg(szHash, nTime)
	if nTime and not IsEmpty(szHash) then
		insert(self.aDeleteQueue, {szHash = szHash, nTime = nTime})
	end
	return self
end

function DS:FlushDB()
	if (not IsEmpty(self.aInsertQueue) or not IsEmpty(self.aDeleteQueue)) and self:InitDB() then
		-- �����¼
		sort(self.aInsertQueue, function(a, b) return a.nTime < b.nTime end)
		local i, db = 1, self.aDB[1]
		for _, p in ipairs(self.aInsertQueue) do
			while db and p.nTime > db:GetMaxTime() do
				i = i + 1
				db = self.aDB[i]
			end
			assert(db, 'ChatLog db indexing error while FlushDB: [i]' .. i .. ' [time]' .. p.nTime)
			db:InsertMsg(p.nChannel, p.szText, p.szMsg, p.szTalker, p.nTime, p.szHash)
		end
		self.aInsertQueue = {}
		self.aInsertQueueAnsi = {}
		-- ɾ����¼
		sort(self.aDeleteQueue, function(a, b) return a.nTime < b.nTime end)
		local i, db = 1, self.aDB[1]
		for _, p in ipairs(self.aDeleteQueue) do
			while db and p.nTime > db:GetMaxTime() do
				i = i + 1
				db = self.aDB[i]
			end
			assert(db, 'ChatLog db indexing error while FlushDB: [i]' .. i .. ' [time]' .. p.nTime)
			db:DeleteMsg(p.szHash, p.nTime)
		end
		self.aDeleteQueue = {}
		-- ִ�����ݿ����
		for _, db in ipairs(self.aDB) do
			db:Flush()
		end
	end
	return self
end

function DS:ReleaseDB()
	if self.aDB then
		for _, db in ipairs(self.aDB) do
			db:Disconnect()
		end
		self.aDB = nil
	end
	return self
end

function MY_ChatLog_DS(szRoot)
	if not DS_CACHE[szRoot] then
		DS_CACHE[szRoot] = DS.new(szRoot)
	end
	return DS_CACHE[szRoot]
end
