--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : �ַ�������
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
local huge, pi, random, abs = math.huge, math.pi, math.random, math.abs
local min, max, floor, ceil = math.min, math.max, math.floor, math.ceil
local pow, sqrt, sin, cos, tan = math.pow, math.sqrt, math.sin, math.cos, math.tan
local insert, remove, concat, sort = table.insert, table.remove, table.concat, table.sort
local pack, unpack = table.pack or function(...) return {...} end, table.unpack or unpack
-- jx3 apis caching
local wsub, wlen, wfind = wstring.sub, wstring.len, wstring.find
local GetTime, GetLogicFrameCount = GetTime, GetLogicFrameCount
local GetClientTeam, UI_GetClientPlayerID = GetClientTeam, UI_GetClientPlayerID
local GetClientPlayer, GetPlayer, GetNpc, IsPlayer = GetClientPlayer, GetPlayer, GetNpc, IsPlayer
local LIB, UI, DEBUG_LEVEL, PATH_TYPE = MY, MY.UI, MY.DEBUG_LEVEL, MY.PATH_TYPE
local var2str, str2var, clone, empty, ipairs_r = LIB.var2str, LIB.str2var, LIB.clone, LIB.empty, LIB.ipairs_r
local spairs, spairs_r, sipairs, sipairs_r = LIB.spairs, LIB.spairs_r, LIB.sipairs, LIB.sipairs_r
local GetPatch, ApplyPatch = LIB.GetPatch, LIB.ApplyPatch
local Get, Set, RandomChild, GetTraceback = LIB.Get, LIB.Set, LIB.RandomChild, LIB.GetTraceback
local IsArray, IsDictionary, IsEquals = LIB.IsArray, LIB.IsDictionary, LIB.IsEquals
local IsNil, IsBoolean, IsNumber, IsFunction = LIB.IsNil, LIB.IsBoolean, LIB.IsNumber, LIB.IsFunction
local IsEmpty, IsString, IsTable, IsUserdata = LIB.IsEmpty, LIB.IsString, LIB.IsTable, LIB.IsUserdata
local MENU_DIVIDER, EMPTY_TABLE, XML_LINE_BREAKER = LIB.MENU_DIVIDER, LIB.EMPTY_TABLE, LIB.XML_LINE_BREAKER
-------------------------------------------------------------------------------------------------------------
local AnsiToUTF8 = AnsiToUTF8 or ansi_to_utf8
local UrlEncodeString, UrlDecodeString = UrlEncode, UrlDecode
--------------------------------------------
-- ���غ����ͱ���
--------------------------------------------

-- �ָ��ַ���
-- (table) MY.SplitString(string szText, table aSpliter, bool bIgnoreEmptyPart)
-- (table) MY.SplitString(string szText, string szSpliter, bool bIgnoreEmptyPart)
-- szText           ԭʼ�ַ���
-- szSpliter        �ָ���
-- aSpliter         ����ָ���
-- bIgnoreEmptyPart �Ƿ���Կ��ַ�������'123;234;'��';'�ֳ�{'123','234'}����{'123','234',''}
function MY.SplitString(szText, aSpliter, bIgnoreEmptyPart)
	if IsString(aSpliter) then
		aSpliter = {aSpliter}
	end
	local nOff, tResult, szPart = 1, {}
	while true do
		local nEnd, szEnd
		for _, szSpliter in ipairs(aSpliter) do
			local nPos = StringFindW(szText, szSpliter, nOff)
			if nPos and (not nEnd or nPos < nEnd) then
				nEnd, szEnd = nPos, szSpliter
			end
		end
		if not nEnd then
			szPart = sub(szText, nOff, len(szText))
			if not bIgnoreEmptyPart or szPart ~= '' then
				insert(tResult, szPart)
			end
			break
		else
			szPart = sub(szText, nOff, nEnd - 1)
			if not bIgnoreEmptyPart or szPart ~= '' then
				insert(tResult, szPart)
			end
			nOff = nEnd + len(szEnd)
		end
	end
	return tResult
end

function MY.EscapeString(s)
	return (gsub(s, '([%(%)%.%%%+%-%*%?%[%^%$%]])', '%%%1'))
end

function MY.TrimString(szText)
	if not szText or szText == '' then
		return ''
	end
	return (gsub(szText, '^%s*(.-)%s*$', '%1'))
end

function MY.StringLenW(str)
	return wlen(str)
end

function MY.StringSubW(str,s,e)
	if s < 0 then
		s = wlen(str) + s
	end
	if e < 0 then
		e = wlen(str) + e
	end
	return wsub(str, s, e)
end

function MY.EncryptString(szText)
	return szText:gsub('.', function (c) return format ('%02X', (byte(c) + 13) % 256) end):gsub(' ', '+')
end

function MY.SimpleEncryptString(szText)
	local a = {szText:byte(1, #szText)}
	for i, v in ipairs(a) do
		a[i] = char((v + 13) % 256)
	end
	return (MY.Base64Encode(concat(a)):gsub('/', '-'):gsub('+', '_'):gsub('=', '.'))
end

function MY.SimpleDecryptString(szCipher)
	local szBin = MY.Base64Decode((szCipher:gsub('-', '/'):gsub('_', '+'):gsub('%.', '=')))
	if not szBin then
		return
	end
	local a = {szBin:byte(1, #szBin)}
	for i, v in ipairs(a) do
		a[i] = char((v - 13 + 256) % 256)
	end
	return concat(a)
end

local function EncodePostData(data, t, prefix)
	if type(data) == 'table' then
		local first = true
		for k, v in pairs(data) do
			if first then
				first = false
			else
				insert(t, '&')
			end
			if prefix == '' then
				EncodePostData(v, t, k)
			else
				EncodePostData(v, t, prefix .. '[' .. k .. ']')
			end
		end
	else
		if prefix ~= '' then
			insert(t, prefix)
			insert(t, '=')
		end
		insert(t, data)
	end
end

function MY.EncodePostData(data)
	local t = {}
	EncodePostData(data, t, '')
	local text = concat(t)
	return text
end

local function ConvertToUTF8(data)
	if type(data) == 'table' then
		local t = {}
		for k, v in pairs(data) do
			if type(k) == 'string' then
				t[ConvertToUTF8(k)] = ConvertToUTF8(v)
			else
				t[k] = ConvertToUTF8(v)
			end
		end
		return t
	elseif type(data) == 'string' then
		return AnsiToUTF8(data)
	else
		return data
	end
end
MY.ConvertToUTF8 = ConvertToUTF8

local function ConvertToAnsi(data)
	if type(data) == 'table' then
		local t = {}
		for k, v in pairs(data) do
			if type(k) == 'string' then
				t[ConvertToAnsi(k)] = ConvertToAnsi(v)
			else
				t[k] = ConvertToAnsi(v)
			end
		end
		return t
	elseif type(data) == 'string' then
		return UTF8ToAnsi(data)
	else
		return data
	end
end
MY.ConvertToAnsi = ConvertToAnsi

if not UrlEncodeString then
function UrlEncodeString(szText)
	return szText:gsub('([^0-9a-zA-Z ])', function (c) return format ('%%%02X', byte(c)) end):gsub(' ', '+')
end
end

if not UrlDecodeString then
function UrlDecodeString(szText)
	return szText:gsub('+', ' '):gsub('%%(%x%x)', function(h) return char(tonumber(h, 16)) end)
end
end

local function UrlEncode(data)
	if type(data) == 'table' then
		local t = {}
		for k, v in pairs(data) do
			if type(k == 'string') then
				t[UrlEncodeString(k)] = UrlEncode(v)
			else
				t[k] = UrlEncode(v)
			end
		end
		return t
	elseif type(data) == 'string' then
		return UrlEncodeString(data)
	else
		return data
	end
end
MY.UrlEncode = UrlEncode

local function UrlDecode(data)
	if type(data) == 'table' then
		local t = {}
		for k, v in pairs(data) do
			if type(k == 'string') then
				t[UrlDecodeString(k)] = UrlDecode(v)
			else
				t[k] = UrlDecode(v)
			end
		end
		return t
	elseif type(data) == 'string' then
		return UrlDecodeString(data)
	else
		return data
	end
end
MY.UrlDecode = UrlDecode

local m_simpleMatchCache = setmetatable({}, { __mode = 'v' })
function MY.StringSimpleMatch(szText, szFind, bDistinctCase, bDistinctEnEm, bIgnoreSpace)
	if not bDistinctCase then
		szFind = StringLowerW(szFind)
		szText = StringLowerW(szText)
	end
	if not bDistinctEnEm then
		szText = StringEnerW(szText)
	end
	if bIgnoreSpace then
		szFind = StringReplaceW(szFind, ' ', '')
		szFind = StringReplaceW(szFind, g_tStrings.STR_ONE_CHINESE_SPACE, '')
		szText = StringReplaceW(szText, ' ', '')
		szText = StringReplaceW(szText, g_tStrings.STR_ONE_CHINESE_SPACE, '')
	end
	local me = GetClientPlayer()
	if me then
		szFind = szFind:gsub('$zj', me.szName)
		local szTongName = ''
		local tong = GetTongClient()
		if tong and me.dwTongID ~= 0 then
			szTongName = tong.ApplyGetTongName(me.dwTongID) or ''
		end
		szFind = szFind:gsub('$bh', szTongName)
		szFind = szFind:gsub('$gh', szTongName)
	end
	local tFind = m_simpleMatchCache[szFind]
	if not tFind then
		tFind = {}
		for _, szKeywordsLine in ipairs(MY.SplitString(szFind, ';', true)) do
			local tKeyWordsLine = {}
			for _, szKeywords in ipairs(MY.SplitString(szKeywordsLine, ',', true)) do
				local tKeyWords = {}
				for _, szKeyword in ipairs(MY.SplitString(szKeywords, '|', true)) do
					local bNegative = szKeyword:sub(1, 1) == '!'
					if bNegative then
						szKeyword = szKeyword:sub(2)
					end
					if not bDistinctEnEm then
						szKeyword = StringEnerW(szKeyword)
					end
					insert(tKeyWords, { szKeyword = szKeyword, bNegative = bNegative })
				end
				insert(tKeyWordsLine, tKeyWords)
			end
			insert(tFind, tKeyWordsLine)
		end
		m_simpleMatchCache[szFind] = tFind
	end
	-- 10|ʮ��,Ѫս���|XZTC,!С��������,!�������;��ս
	local bKeyWordsLine = false
	for _, tKeyWordsLine in ipairs(tFind) do         -- ����һ������
		-- 10|ʮ��,Ѫս���|XZTC,!С��������,!�������
		local bKeyWords = true
		for _, tKeyWords in ipairs(tKeyWordsLine) do -- ����ȫ������
			-- 10|ʮ��
			local bKeyWord = false
			for _, info in ipairs(tKeyWords) do      -- ����һ������
				-- szKeyword = MY.EscapeString(szKeyword) -- ����wstring��Escape���ݱ�
				if info.bNegative then               -- !С��������
					if not wfind(szText, info.szKeyword) then
						bKeyWord = true
					end
				else                                                    -- ʮ��   -- 10
					if wfind(szText, info.szKeyword) then
						bKeyWord = true
					end
				end
				if bKeyWord then
					break
				end
			end
			bKeyWords = bKeyWords and bKeyWord
			if not bKeyWords then
				break
			end
		end
		bKeyWordsLine = bKeyWordsLine or bKeyWords
		if bKeyWordsLine then
			break
		end
	end
	return bKeyWordsLine
end
