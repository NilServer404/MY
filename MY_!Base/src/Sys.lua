--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : ϵͳ������
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
local _L = LIB.LoadLangPack(PACKET_INFO.FRAMEWORK_ROOT .. 'lang/libs/')
---------------------------------------------------------------------------------------------------

-- #######################################################################################################
--       #       #               #         #           #           #
--       #       #               #     # # # # # #     # #       # # # #
--       #   # # # # # #         #         #         #     # #     #   #
--   #   # #     #     #     # # # #   # # # # #             # # # # # # #
--   #   #       #     #         #         #   #     # # #   #     #   #
--   #   #       #     #         #     # # # # # #     #   #     # # # #
--   #   # # # # # # # # #       # #       #   #       #   # #     #
--       #       #           # # #     # # # # #     # # #   # # # # # #
--       #     #   #             #         #           #     #     #
--       #     #   #             #     #   # # # #     #   # # # # # # # #
--       #   #       #           #     #   #           # #   #     #
--       # #           # #     # #   #   # # # # #     #   #   # # # # # #
-- #######################################################################################################
do local HOTKEY_CACHE = {}
-- ����ϵͳ��ݼ�
-- (void) LIB.RegisterHotKey(string szName, string szTitle, func fnDown, func fnUp)   -- ����ϵͳ��ݼ�
function LIB.RegisterHotKey(szName, szTitle, fnDown, fnUp)
	insert(HOTKEY_CACHE, { szName = szName, szTitle = szTitle, fnDown = fnDown, fnUp = fnUp })
end

-- ��ȡ��ݼ�����
-- (string) LIB.GetHotKeyDisplay(string szName, boolean bBracket, boolean bShort)      -- ȡ�ÿ�ݼ�����
function LIB.GetHotKeyDisplay(szName, bBracket, bShort)
	local nKey, bShift, bCtrl, bAlt = Hotkey.Get(szName)
	local szDisplay = GetKeyShow(nKey, bShift, bCtrl, bAlt, bShort == true)
	if szDisplay ~= '' and bBracket then
		szDisplay = '(' .. szDisplay .. ')'
	end
	return szDisplay
end

-- ��ȡ��ݼ�
-- (table) LIB.GetHotKey(string szName, true , true )       -- ȡ�ÿ�ݼ�
-- (number nKey, boolean bShift, boolean bCtrl, boolean bAlt) LIB.GetHotKey(string szName, true , fasle)        -- ȡ�ÿ�ݼ�
function LIB.GetHotKey(szName, bBracket, bShort)
	local nKey, bShift, bCtrl, bAlt = Hotkey.Get(szName)
	if nKey==0 then return nil end
	if bBracket then
		return { nKey = nKey, bShift = bShift, bCtrl = bCtrl, bAlt = bAlt }
	else
		return nKey, bShift, bCtrl, bAlt
	end
end

-- ���ÿ�ݼ�/�򿪿�ݼ��������    -- HM����ٳ�����
-- (void) LIB.SetHotKey()                               -- �򿪿�ݼ��������
-- (void) LIB.SetHotKey(string szGroup)     -- �򿪿�ݼ�������岢��λ�� szGroup ���飨�����ã�
-- (void) LIB.SetHotKey(string szCommand, number nKey )     -- ���ÿ�ݼ�
-- (void) LIB.SetHotKey(string szCommand, number nIndex, number nKey [, boolean bShift [, boolean bCtrl [, boolean bAlt] ] ])       -- ���ÿ�ݼ�
function LIB.SetHotKey(szCommand, nIndex, nKey, bShift, bCtrl, bAlt)
	if nIndex then
		if not nKey then
			nIndex, nKey = 1, nIndex
		end
		Hotkey.Set(szCommand, nIndex, nKey, bShift == true, bCtrl == true, bAlt == true)
	else
		local szGroup = szCommand or PACKET_INFO.NAME

		local frame = Station.Lookup('Topmost/HotkeyPanel')
		if not frame then
			frame = Wnd.OpenWindow('HotkeyPanel')
		elseif not frame:IsVisible() then
			frame:Show()
		end
		if not szGroup then return end
		-- load aKey
		local aKey, nI, bindings = nil, 0, Hotkey.GetBinding(false)
		for k, v in pairs(bindings) do
			if v.szHeader ~= '' then
				if aKey then
					break
				elseif v.szHeader == szGroup then
					aKey = {}
				else
					nI = nI + 1
				end
			end
			if aKey then
				if not v.Hotkey1 then
					v.Hotkey1 = {nKey = 0, bShift = false, bCtrl = false, bAlt = false}
				end
				if not v.Hotkey2 then
					v.Hotkey2 = {nKey = 0, bShift = false, bCtrl = false, bAlt = false}
				end
				insert(aKey, v)
			end
		end
		if not aKey then return end
		local hP = frame:Lookup('', 'Handle_List')
		local hI = hP:Lookup(nI)
		if hI.bSel then return end
		-- update list effect
		for i = 0, hP:GetItemCount() - 1 do
			local hB = hP:Lookup(i)
			if hB.bSel then
				hB.bSel = false
				if hB.IsOver then
					hB:Lookup('Image_Sel'):SetAlpha(128)
					hB:Lookup('Image_Sel'):Show()
				else
					hB:Lookup('Image_Sel'):Hide()
				end
			end
		end
		hI.bSel = true
		hI:Lookup('Image_Sel'):SetAlpha(255)
		hI:Lookup('Image_Sel'):Show()
		-- update content keys [hI.nGroupIndex]
		local hK = frame:Lookup('', 'Handle_Hotkey')
		local szIniFile = 'UI/Config/default/HotkeyPanel.ini'
		Hotkey.SetCapture(false)
		hK:Clear()
		hK.nGroupIndex = hI.nGroupIndex
		hK:AppendItemFromIni(szIniFile, 'Text_GroupName')
		hK:Lookup(0):SetText(szGroup)
		hK:Lookup(0).bGroup = true
		for k, v in ipairs(aKey) do
			hK:AppendItemFromIni(szIniFile, 'Handle_Binding')
			local hI = hK:Lookup(k)
			hI.bBinding = true
			hI.nIndex = k
			hI.szTip = v.szTip
			hI:Lookup('Text_Name'):SetText(v.szDesc)
			for i = 1, 2, 1 do
				local hK = hI:Lookup('Handle_Key'..i)
				hK.bKey = true
				hK.nIndex = i
				local hotkey = v['Hotkey'..i]
				hotkey.bUnchangeable = v.bUnchangeable
				hK.bUnchangeable = v.bUnchangeable
				local text = hK:Lookup('Text_Key'..i)
				text:SetText(GetKeyShow(hotkey.nKey, hotkey.bShift, hotkey.bCtrl, hotkey.bAlt))
				-- update btn
				if hK.bUnchangeable then
					hK:Lookup('Image_Key'..hK.nIndex):SetFrame(56)
				elseif hK.bDown then
					hK:Lookup('Image_Key'..hK.nIndex):SetFrame(55)
				elseif hK.bRDown then
					hK:Lookup('Image_Key'..hK.nIndex):SetFrame(55)
				elseif hK.bSel then
					hK:Lookup('Image_Key'..hK.nIndex):SetFrame(55)
				elseif hK.bOver then
					hK:Lookup('Image_Key'..hK.nIndex):SetFrame(54)
				elseif hotkey.bChange then
					hK:Lookup('Image_Key'..hK.nIndex):SetFrame(56)
				elseif hotkey.bConflict then
					hK:Lookup('Image_Key'..hK.nIndex):SetFrame(54)
				else
					hK:Lookup('Image_Key'..hK.nIndex):SetFrame(53)
				end
			end
		end
		-- update content scroll
		hK:FormatAllItemPos()
		local wAll, hAll = hK:GetAllItemSize()
		local w, h = hK:GetSize()
		local scroll = frame:Lookup('Scroll_Key')
		local nCountStep = ceil((hAll - h) / 10)
		scroll:SetStepCount(nCountStep)
		scroll:SetScrollPos(0)
		if nCountStep > 0 then
			scroll:Show()
			scroll:GetParent():Lookup('Btn_Up'):Show()
			scroll:GetParent():Lookup('Btn_Down'):Show()
		else
			scroll:Hide()
			scroll:GetParent():Lookup('Btn_Up'):Hide()
			scroll:GetParent():Lookup('Btn_Down'):Hide()
		end
		-- update list scroll
		local scroll = frame:Lookup('Scroll_List')
		if scroll:GetStepCount() > 0 then
			local _, nH = hI:GetSize()
			local nStep = ceil((nI * nH) / 10)
			if nStep > scroll:GetStepCount() then
				nStep = scroll:GetStepCount()
			end
			scroll:SetScrollPos(nStep)
		end
	end
end

LIB.RegisterInit(NSFormatString('{$NS}#BIND_HOTKEY'), function()
	-- hotkey
	Hotkey.AddBinding(NSFormatString('{$NS}_Total'), _L['Toggle main panel'], PACKET_INFO.NAME, LIB.TogglePanel, nil)
	for _, v in ipairs(HOTKEY_CACHE) do
		Hotkey.AddBinding(v.szName, v.szTitle, '', v.fnDown, v.fnUp)
	end
	for i = 1, 5 do
		Hotkey.AddBinding(NSFormatString('{$NS}_HotKey_Null_')..i, _L['None-function hotkey'], '', function() end, nil)
	end
end)
if PACKET_INFO.DEBUG_LEVEL <= DEBUG_LEVEL.DEBUG then
	local aFrame = {
		'Lowest2/ChatPanel1',
		'Lowest2/ChatPanel2',
		'Lowest2/ChatPanel3',
		'Lowest2/ChatPanel4',
		'Lowest2/ChatPanel5',
		'Lowest2/ChatPanel6',
		'Lowest2/ChatPanel7',
		'Lowest2/ChatPanel8',
		'Lowest2/ChatPanel9',
		'Lowest2/EditBox',
		'Normal1/ChatPanel1',
		'Normal1/ChatPanel2',
		'Normal1/ChatPanel3',
		'Normal1/ChatPanel4',
		'Normal1/ChatPanel5',
		'Normal1/ChatPanel6',
		'Normal1/ChatPanel7',
		'Normal1/ChatPanel8',
		'Normal1/ChatPanel9',
		'Normal1/EditBox',
		'Normal/' .. PACKET_INFO.NAME_SPACE,
	}
	LIB.RegisterHotKey(NSFormatString('{$NS}_STAGE_CHAT'), _L['Display only chat panel'], function()
		if Station.IsVisible() then
			for _, v in ipairs(aFrame) do
				local frame = Station.Lookup(v)
				if frame then
					frame:ShowWhenUIHide()
				end
			end
			Station.Hide()
		else
			for _, v in ipairs(aFrame) do
				local frame = Station.Lookup(v)
				if frame then
					frame:HideWhenUIHide()
				end
			end
			Station.Show()
		end
	end)
end
LIB.RegisterHotKey(NSFormatString('{$NS}_STOP_CASTING'), _L['Stop cast skill'], function() GetClientPlayer().StopCurrentAction() end)
end

-- Save & Load Lua Data
-- ##################################################################################################
--         #       #             #                           #
--     #   #   #   #             #     # # # # # #           #               # # # # # #
--         #       #             #     #         #   # # # # # # # # # # #     #     #   # # # #
--   # # # # # #   # # # #   # # # #   # # # # # #         #                   #     #     #   #
--       # #     #     #         #     #     #           #     # # # # #       # # # #     #   #
--     #   # #     #   #         #     # # # # # #       #           #         #     #     #   #
--   #     #   #   #   #         # #   #     #         # #         #           # # # #     #   #
--       #         #   #     # # #     # # # # # #   #   #   # # # # # # #     #     #     #   #
--   # # # # #     #   #         #     # #       #       #         #           #     # #     #
--     #     #       #           #   #   #       #       #         #         # # # # #       #
--       # #       #   #         #   #   # # # # #       #         #                 #     #   #
--   # #     #   #       #     # # #     #       #       #       # #                 #   #       #
-- ##################################################################################################
if IsLocalFileExist(PACKET_INFO.ROOT .. '@DATA/') then
	CPath.Move(PACKET_INFO.ROOT .. '@DATA/', PACKET_INFO.DATA_ROOT)
end

-- ��ʽ�������ļ�·�����滻{$uid}��{$lang}��{$server}�Լ���ȫ���·����
-- (string) LIB.GetLUADataPath(oFilePath)
--   ��·��Ϊ����·��ʱ(��б�ܿ�ͷ)��������
--   ��·��Ϊ���·��ʱ ����ڲ��`{NS}#DATA`Ŀ¼
--   ���Դ����{szPath, ePathType}
function LIB.FormatPath(oFilePath, tParams)
	if not tParams then
		tParams = {}
	end
	local szFilePath, ePathType
	if type(oFilePath) == 'table' then
		szFilePath, ePathType = unpack(oFilePath)
	else
		szFilePath, ePathType = oFilePath, PATH_TYPE.NORMAL
	end
	-- Unified the directory separator
	szFilePath = gsub(szFilePath, '\\', '/')
	-- if it's relative path then complete path with '/{NS}#DATA/'
	if szFilePath:sub(2, 3) ~= ':/' then
		if ePathType == PATH_TYPE.DATA then
			szFilePath = PACKET_INFO.DATA_ROOT .. szFilePath
		elseif ePathType == PATH_TYPE.GLOBAL then
			szFilePath = PACKET_INFO.DATA_ROOT .. '!all-users@{$edition}/' .. szFilePath
		elseif ePathType == PATH_TYPE.ROLE then
			szFilePath = PACKET_INFO.DATA_ROOT .. '{$uid}@{$edition}/' .. szFilePath
		elseif ePathType == PATH_TYPE.SERVER then
			szFilePath = PACKET_INFO.DATA_ROOT .. '#{$relserver}@{$edition}/' .. szFilePath
		end
	end
	-- if exist {$uid} then add user role identity
	if find(szFilePath, '{$uid}', nil, true) then
		szFilePath = szFilePath:gsub('{%$uid}', tParams['uid'] or LIB.GetClientUUID())
	end
	-- if exist {$name} then add user role identity
	if find(szFilePath, '{$name}', nil, true) then
		szFilePath = szFilePath:gsub('{%$name}', tParams['name'] or LIB.GetClientInfo().szName or LIB.GetClientUUID())
	end
	-- if exist {$lang} then add language identity
	if find(szFilePath, '{$lang}', nil, true) then
		szFilePath = szFilePath:gsub('{%$lang}', tParams['lang'] or lower(LIB.GetGameLanguage()))
	end
	-- if exist {$edition} then add edition identity
	if find(szFilePath, '{$edition}', nil, true) then
		szFilePath = szFilePath:gsub('{%$edition}', tParams['edition'] or lower(LIB.GetGameEdition()))
	end
	-- if exist {$version} then add version identity
	if find(szFilePath, '{$version}', nil, true) then
		szFilePath = szFilePath:gsub('{%$version}', tParams['version'] or lower(LIB.GetGameVersion()))
	end
	-- if exist {$date} then add date identity
	if find(szFilePath, '{$date}', nil, true) then
		szFilePath = szFilePath:gsub('{%$date}', tParams['date'] or LIB.FormatTime(GetCurrentTime(), '%yyyy%MM%dd'))
	end
	-- if exist {$server} then add server identity
	if find(szFilePath, '{$server}', nil, true) then
		szFilePath = szFilePath:gsub('{%$server}', tParams['server'] or ((LIB.GetServer()):gsub('[/\\|:%*%?"<>]', '')))
	end
	-- if exist {$relserver} then add relserver identity
	if find(szFilePath, '{$relserver}', nil, true) then
		szFilePath = szFilePath:gsub('{%$relserver}', tParams['relserver'] or ((LIB.GetRealServer()):gsub('[/\\|:%*%?"<>]', '')))
	end
	local rootPath = GetRootPath():gsub('\\', '/')
	if szFilePath:find(rootPath) == 1 then
		szFilePath = szFilePath:gsub(rootPath, '.')
	end
	return szFilePath
end

function LIB.GetRelativePath(oPath, oRoot)
	local szPath = LIB.FormatPath(oPath):gsub('^%./', '')
	local szRoot = LIB.FormatPath(oRoot):gsub('^%./', '')
	local szRootPath = GetRootPath():gsub('\\', '/')
	if szPath:sub(2, 2) ~= ':' then
		szPath = LIB.ConcatPath(szRootPath, szPath)
	end
	if szRoot:sub(2, 2) ~= ':' then
		szRoot = LIB.ConcatPath(szRootPath, szRoot)
	end
	szRoot = szRoot:gsub('/$', '') .. '/'
	if wfind(szPath:lower(), szRoot:lower()) ~= 1 then
		return
	end
	return szPath:sub(#szRoot + 1)
end

function LIB.GetAbsolutePath(oPath)
	local szPath = LIB.FormatPath(oPath)
	if szPath:sub(2, 2) == ':' then
		return szPath
	end
	return GetRootPath():gsub('\\', '/') .. '/' .. LIB.GetRelativePath(szPath, {'', PATH_TYPE.NORMAL}):gsub('^[./\\]*', '')
end

function LIB.GetLUADataPath(oFilePath)
	local szFilePath = LIB.FormatPath(oFilePath)
	-- ensure has file name
	if sub(szFilePath, -1) == '/' then
		szFilePath = szFilePath .. 'data'
	end
	-- ensure file ext name
	if sub(szFilePath, -7):lower() ~= '.jx3dat' then
		szFilePath = szFilePath .. '.jx3dat'
	end
	return szFilePath
end

function LIB.ConcatPath(...)
	local aPath = {...}
	local szPath = ''
	for _, s in ipairs(aPath) do
		s = tostring(s):gsub('^[\\/]+', '')
		if s ~= '' then
			szPath = szPath:gsub('[\\/]+$', '')
			if szPath ~= '' then
				szPath = szPath .. '/'
			end
			szPath = szPath .. s
		end
	end
	return szPath
end

-- ɾ��Ŀ¼�е�./��../
function LIB.NormalizePath(szPath)
	szPath = szPath:gsub('/%./', '/')
	local nPos1, nPos2
	while true do
		nPos1, nPos2 = szPath:find('[^/]*/%.%./')
		if not nPos1 then
			break
		end
		szPath = szPath:sub(1, nPos1 - 1) .. szPath:sub(nPos2 + 1)
	end
	return szPath
end

-- ��ȡ����Ŀ¼ ע���ļ����ļ��л�ȡ���������
function LIB.GetParentPath(szPath)
	return LIB.NormalizePath(szPath):gsub('/[^/]*$', '')
end

function LIB.OpenFolder(szPath)
	if _G.OpenFolder then
		_G.OpenFolder(szPath)
	end
end

function LIB.IsURL(szURL)
	return szURL:sub(1, 8):lower() == 'https://' or szURL:gsub(1, 7):lower() == 'http://'
end

-- ������ݴ洢Ĭ����Կ
local GetLUADataPathPassphrase
do
local function GetPassphrase(nSeed, nLen)
	local a = {}
	local b, c = 0x20, 0x7e - 0x20 + 1
	for i = 1, nLen do
		insert(a, ((i + nSeed) % 256 * (2 * i + nSeed) % 32) % c + b)
	end
	return char(unpack(a))
end
local szDataRoot = StringLowerW(LIB.FormatPath({'', PATH_TYPE.DATA}))
local szPassphrase = GetPassphrase(666, 233)
local CACHE = {}
function GetLUADataPathPassphrase(szPath)
	-- ���Դ�Сд
	szPath = StringLowerW(szPath)
	-- ȥ��Ŀ¼ǰ׺
	if szPath:sub(1, szDataRoot:len()) ~= szDataRoot then
		return
	end
	szPath = szPath:sub(#szDataRoot + 1)
	-- ������ݷ����ַ
	local nPos = wfind(szPath, '/')
	if not nPos or nPos == 1 then
		return
	end
	local szDomain = szPath:sub(1, nPos)
	szPath = szPath:sub(nPos + 1)
	-- ���˲���Ҫ���ܵĵ�ַ
	local nPos = wfind(szPath, '/')
	if nPos then
		if szPath:sub(1, nPos - 1) == 'export' then
			return
		end
	end
	-- ��ȡ�򴴽���Կ
	local bNew = false
	if not CACHE[szDomain] or not CACHE[szDomain][szPath] then
		local szFilePath = szDataRoot .. szDomain .. '/manifest.jx3dat'
		local tManifest = LoadLUAData(szFilePath, { passphrase = szPassphrase }) or {}
		-- ��ʱ��Сд�����߼�
		CACHE[szDomain] = {}
		for szPath, v in pairs(tManifest) do
			CACHE[szDomain][StringLowerW(szPath)] = v
		end
		if not CACHE[szDomain][szPath] then
			bNew = true
			CACHE[szDomain][szPath] = LIB.GetUUID():gsub('-', '')
			SaveLUAData(szFilePath, CACHE[szDomain], { passphrase = szPassphrase })
		end
	end
	return CACHE[szDomain][szPath], bNew
end
end

-- ��ȡ�����Ψһ��ʾ��
do
local GUID
function LIB.GetClientGUID()
	if not GUID then
		local szRandom = GetLUADataPathPassphrase(LIB.GetLUADataPath({'GUIDv2', PATH_TYPE.GLOBAL}))
		local szPrefix = MD5(szRandom):sub(1, 4)
		local nCSW, nCSH = GetSystemCScreen()
		local szCS = MD5(nCSW .. ',' .. nCSH):sub(1, 4)
		GUID = ('%s%X%s'):format(szPrefix, GetStringCRC(szRandom), szCS)
	end
	return GUID
end
end

-- ���������ļ�
function LIB.SaveLUAData(oFilePath, oData, tConfig)
	--[[#DEBUG BEGIN]]
	local nStartTick = GetTickCount()
	--[[#DEBUG END]]
	local config, szPassphrase, bNew = Clone(tConfig) or {}
	local szFilePath = LIB.GetLUADataPath(oFilePath)
	if IsNil(config.passphrase) then
		config.passphrase = GetLUADataPathPassphrase(szFilePath)
	end
	local data = SaveLUAData(szFilePath, oData, config)
	--[[#DEBUG BEGIN]]
	LIB.Debug('PMTool', _L('%s saved during %dms.', szFilePath, GetTickCount() - nStartTick), DEBUG_LEVEL.PMLOG)
	--[[#DEBUG END]]
	return data
end

-- ���������ļ�
function LIB.LoadLUAData(oFilePath, tConfig)
	--[[#DEBUG BEGIN]]
	local nStartTick = GetTickCount()
	--[[#DEBUG END]]
	local config, szPassphrase, bNew = Clone(tConfig) or {}
	local szFilePath = LIB.GetLUADataPath(oFilePath)
	if IsNil(config.passphrase) then
		szPassphrase, bNew = GetLUADataPathPassphrase(szFilePath)
		if not bNew then
			config.passphrase = szPassphrase
		end
	end
	local data = LoadLUAData(szFilePath, config)
	if bNew and data then
		config.passphrase = szPassphrase
		SaveLUAData(szFilePath, data, config)
	end
	--[[#DEBUG BEGIN]]
	LIB.Debug('PMTool', _L('%s loaded during %dms.', szFilePath, GetTickCount() - nStartTick), DEBUG_LEVEL.PMLOG)
	--[[#DEBUG END]]
	return data
end


-- ע���û��������ݣ�֧��ȫ�ֱ����������
-- (void) LIB.RegisterCustomData(string szVarPath[, number nVersion])
function LIB.RegisterCustomData(szVarPath, nVersion, szDomain)
	szDomain = szDomain or 'Role'
	local oVar = Get(_G, szVarPath)
	if IsTable(oVar) then
		for k, _ in pairs(oVar) do
			RegisterCustomData(szDomain .. '/' .. szVarPath .. '.' .. k, nVersion)
		end
	else
		RegisterCustomData(szDomain .. '/' .. szVarPath, nVersion)
	end
end

--szName [, szDataFile]
function LIB.RegisterUserData(szName, szFileName, onLoad)

end

do local USER_DB
function LIB.LoadDataBase()
	if USER_DB then
		return
	end
	USER_DB = UnQLite_Open(LIB.FormatPath({'userdata/base.udb', PATH_TYPE.ROLE}))
end

function LIB.ReleaseDataBase()
	if not USER_DB then
		return
	end
	USER_DB:Release()
	USER_DB = nil
end

function LIB.GetUserData(szKey)
	return USER_DB:Get(szKey)
end

function LIB.SetUserData(szKey, oValue)
	return USER_DB:Set(szKey, oValue)
end
end

-- Format data's structure as struct descripted.
do
local defaultParams = { keepNewChild = false }
local function FormatDataStructure(data, struct, assign, metaSymbol)
	if metaSymbol == nil then
		metaSymbol = '__META__'
	end
	-- ��׼������
	local params = setmetatable({}, defaultParams)
	local structTypes, defaultData, defaultDataType
	local keyTemplate, childTemplate, arrayTemplate, dictionaryTemplate
	if type(struct) == 'table' and struct[1] == metaSymbol then
		-- ������META��ǵ�������
		-- �������ͺ�Ĭ��ֵ
		structTypes = struct[2] or { type(struct.__VALUE__) }
		defaultData = struct[3] or struct.__VALUE__
		defaultDataType = type(defaultData)
		-- ��ģ����ز���
		if defaultDataType == 'table' then
			keyTemplate = struct.__KEY_TEMPLATE__
			childTemplate = struct.__CHILD_TEMPLATE__
			arrayTemplate = struct.__ARRAY_TEMPLATE__
			dictionaryTemplate = struct.__DICTIONARY_TEMPLATE__
		end
		-- ���Ӳ���
		if struct.__PARAMS__ then
			for k, v in pairs(struct.__PARAMS__) do
				params[k] = v
			end
		end
	else
		-- ������ͨ������
		structTypes = { type(struct) }
		defaultData = struct
		defaultDataType = type(defaultData)
	end
	-- ����ṹ�����ݵ�����
	local dataType = type(data)
	local dataTypeExists = false
	if not dataTypeExists then
		for _, v in ipairs(structTypes) do
			if dataType == v then
				dataTypeExists = true
				break
			end
		end
	end
	-- �ֱ�������ƥ���벻ƥ������
	if dataTypeExists then
		if not assign then
			data = Clone(data, true)
		end
		local keys, skipKeys = {}, {}
		-- ���������Ǳ���Ĭ������Ҳ�Ǳ� ��ݹ�����Ԫ����Ĭ����Ԫ��
		if dataType == 'table' and defaultDataType == 'table' then
			for k, v in pairs(defaultData) do
				keys[k], skipKeys[k] = true, true
				data[k] = FormatDataStructure(data[k], defaultData[k], true, metaSymbol)
			end
		end
		-- ���������Ǳ���META��Ϣ�ж�������Ԫ��KEYģ�� ��ݹ�����Ԫ��KEY����Ԫ��KEYģ��
		if dataType == 'table' and keyTemplate then
			for k, v in pairs(data) do
				if not skipKeys[k] then
					local k1 = FormatDataStructure(k, keyTemplate, true, metaSymbol)
					if k1 ~= k then
						if k1 ~= nil then
							data[k1] = data[k]
						end
						data[k] = nil
					end
				end
			end
		end
		-- ���������Ǳ���META��Ϣ�ж�������Ԫ��ģ�� ��ݹ�����Ԫ������Ԫ��ģ��
		if dataType == 'table' and childTemplate then
			for k, v in pairs(data) do
				if not skipKeys[k] then
					keys[k] = true
					data[k] = FormatDataStructure(data[k], childTemplate, true, metaSymbol)
				end
			end
		end
		-- ���������Ǳ���META��Ϣ�ж������б���Ԫ��ģ�� ��ݹ�����Ԫ�����б���Ԫ��ģ��
		if dataType == 'table' and arrayTemplate then
			for i, v in pairs(data) do
				if type(i) == 'number' then
					if not skipKeys[i] then
						keys[i] = true
						data[i] = FormatDataStructure(data[i], arrayTemplate, true, metaSymbol)
					end
				end
			end
		end
		-- ���������Ǳ���META��Ϣ�ж����˹�ϣ��Ԫ��ģ�� ��ݹ�����Ԫ�����ϣ��Ԫ��ģ��
		if dataType == 'table' and dictionaryTemplate then
			for k, v in pairs(data) do
				if type(k) ~= 'number' then
					if not skipKeys[k] then
						keys[k] = true
						data[k] = FormatDataStructure(data[k], dictionaryTemplate, true, metaSymbol)
					end
				end
			end
		end
		-- ���������Ǳ���Ĭ������Ҳ�Ǳ� ��ݹ�����Ԫ���Ƿ���Ҫ����
		if dataType == 'table' and defaultDataType == 'table' then
			if not params.keepNewChild then
				for k, v in pairs(data) do
					if defaultData[k] == nil and not keys[k] then -- Ĭ����û����û��ͨ����������������ɾ��
						data[k] = nil
					end
				end
			end
		end
	else -- ���Ͳ�ƥ������
		if type(defaultData) == 'table' then
			-- Ĭ��ֵΪ�� ��Ҫ�ݹ�����Ԫ��
			data = {}
			for k, v in pairs(defaultData) do
				data[k] = FormatDataStructure(nil, v, true, metaSymbol)
			end
		else -- Ĭ��ֵ���Ǳ� ֱ�ӿ�¡����
			data = Clone(defaultData, true)
		end
	end
	return data
end
LIB.FormatDataStructure = FormatDataStructure
end

function LIB.SetGlobalValue(szVarPath, Val)
	local t = LIB.SplitString(szVarPath, '.')
	local tab = _G
	for k, v in ipairs(t) do
		if not IsTable(tab) then
			return false
		end
		if type(tab[v]) == 'nil' then
			tab[v] = {}
		end
		if k == #t then
			tab[v] = Val
		end
		tab = tab[v]
	end
	return true
end

function LIB.GetGlobalValue(szVarPath)
	local tVariable = _G
	for szIndex in gmatch(szVarPath, '[^%.]+') do
		if tVariable and type(tVariable) == 'table' then
			tVariable = tVariable[szIndex]
		else
			tVariable = nil
			break
		end
	end
	return tVariable
end

do local CREATED = {}
function LIB.CreateDataRoot(ePathType)
	if CREATED[ePathType] then
		return
	end
	CREATED[ePathType] = true
	-- ����Ŀ¼
	if ePathType == PATH_TYPE.ROLE then
		CPath.MakeDir(LIB.FormatPath({'{$name}/', PATH_TYPE.ROLE}))
	end
	-- �汾����ʱɾ���ɵ���ʱĿ¼
	if IsLocalFileExist(LIB.FormatPath({'temporary/', ePathType}))
	and not IsLocalFileExist(LIB.FormatPath({'temporary/{$version}', ePathType})) then
		CPath.DelDir(LIB.FormatPath({'temporary/', ePathType}))
	end
	CPath.MakeDir(LIB.FormatPath({'temporary/{$version}/', ePathType}))
	CPath.MakeDir(LIB.FormatPath({'audio/', ePathType}))
	CPath.MakeDir(LIB.FormatPath({'cache/', ePathType}))
	CPath.MakeDir(LIB.FormatPath({'config/', ePathType}))
	CPath.MakeDir(LIB.FormatPath({'export/', ePathType}))
	CPath.MakeDir(LIB.FormatPath({'font/', ePathType}))
	CPath.MakeDir(LIB.FormatPath({'userdata/', ePathType}))
end
end

do
local SOUND_ROOT = PACKET_INFO.FRAMEWORK_ROOT .. 'audio/'
local SOUNDS, CACHE = {
	{
		szType = _L['Default'],
		{ dwID = 1, szName = _L['Bing.ogg'], szPath = SOUND_ROOT .. 'Bing.ogg' },
		{ dwID = 88001, szName = _L['Notify.ogg'], szPath = SOUND_ROOT .. 'Notify.ogg' },
	},
}
local function GetSoundList()
	local a = { szOption = _L['Sound'] }
	for _, v in ipairs(SOUNDS) do
		insert(a, v)
	end
	if MY_Resource then
		for _, v in ipairs(MY_Resource.GetSoundList()) do
			insert(a, v)
		end
	end
	return a
end
local function GetSoundMenu(tSound, fnAction, tCheck, bMultiple)
	local t = {}
	if tSound.szType then
		t.szOption = tSound.szType
	elseif tSound.dwID then
		t.szOption = tSound.szName
		t.bCheck = true
		t.bChecked = tCheck[tSound.dwID]
		t.bMCheck = not bMultiple
		t.UserData = tSound
		t.fnAction = fnAction
		t.fnMouseEnter = function()
			if IsCtrlKeyDown() then
				LIB.PlaySound(SOUND.UI_SOUND, tSound.szPath, '')
			else
				local szXml = GetFormatText(_L['Hold ctrl when move in to preview.'], nil, 255, 255, 0)
				OutputTip(szXml, 600, {this:GetAbsX(), this:GetAbsY(), this:GetW(), this:GetH()}, ALW.RIGHT_LEFT)
			end
		end
	end
	for _, v in ipairs(tSound) do
		local t1 = GetSoundMenu(v, fnAction, tCheck, bMultiple)
		if t1 then
			insert(t, t1)
		end
	end
	if t.dwID and not IsLocalFileExist(t.szPath) then
		return
	end
	return t
end

function LIB.GetSoundMenu(fnAction, tCheck, bMultiple)
	local function fnMenuAction(tSound, bCheck)
		fnAction(tSound.dwID, bCheck)
	end
	return GetSoundMenu(GetSoundList(), fnMenuAction, tCheck, bMultiple)
end

local function Cache(tSound)
	if not IsTable(tSound) then
		return
	end
	if tSound.dwID then
		CACHE[tSound.dwID] = {
			dwID = tSound.dwID,
			szName = tSound.szName,
			szPath = tSound.szPath,
		}
	end
	for _, t in ipairs(tSound) do
		Cache(t)
	end
end

local function GeneCache()
	if not CACHE then
		CACHE = {}
		if MY_Resource then
			local tSound = MY_Resource.GetSoundList()
			if tSound then
				Cache(tSound)
			end
		end
		Cache(SOUNDS)
	end
	return true
end

function LIB.GetSoundName(dwID)
	if not GeneCache() then
		return
	end
	local tSound = CACHE[dwID]
	if not tSound then
		return
	end
	return tSound.szName
end

function LIB.GetSoundPath(dwID)
	if not GeneCache() then
		return
	end
	local tSound = CACHE[dwID]
	if not tSound then
		return
	end
	return tSound.szPath
end
end

-- ��������
-- LIB.PlaySound([nType, ]szFilePath[, szCustomPath])
--   nType        ��������
--     SOUND.BG_MUSIC = 0,    // ��������
--     SOUND.UI_SOUND,        // ������Ч    -- Ĭ��ֵ
--     SOUND.UI_ERROR_SOUND,  // ������ʾ��
--     SOUND.SCENE_SOUND,     // ������Ч
--     SOUND.CHARACTER_SOUND, // ��ɫ��Ч,�����������Ч����Ч
--     SOUND.CHARACTER_SPEAK, // ��ɫ�Ի�
--     SOUND.FRESHER_TIP,     // ������ʾ��
--     SOUND.SYSTEM_TIP,      // ϵͳ��ʾ��
--     SOUND.TREATYANI_SOUND, // Э�鶯������
--   szFilePath   ��Ƶ�ļ���ַ
--   szCustomPath ���Ի���Ƶ�ļ���ַ
-- ע�����Ȳ���szCustomPath, szCustomPath�����ڲŻᲥ��szFilePath
function LIB.PlaySound(nType, szFilePath, szCustomPath)
	if not IsNumber(nType) then
		nType, szFilePath, szCustomPath = SOUND.UI_SOUND, nType, szFilePath
	end
	if not szCustomPath then
		szCustomPath = szFilePath
	end
	-- �����Զ�������
	if szCustomPath ~= '' then
		for _, ePathType in ipairs({
			PATH_TYPE.ROLE,
			PATH_TYPE.GLOBAL,
		}) do
			local szPath = LIB.FormatPath({ 'audio/' .. szCustomPath, ePathType })
			if IsFileExist(szPath) then
				return PlaySound(nType, szPath)
			end
		end
	end
	-- ����Ĭ������
	local szPath = wgsub(szFilePath, '\\', '/')
	if not wfind(szPath, '/') then
		szPath = PACKET_INFO.FRAMEWORK_ROOT .. 'audio/' .. szPath
	end
	if not IsFileExist(szPath) then
		return
	end
	PlaySound(nType, szPath)
end

function LIB.GetFontList()
	local aList, tExist = {}, {}
	-- ��������
	if MY_FontResource then
		for _, p in ipairs(MY_FontResource.GetList()) do
			local szFile = p.szFile:gsub('/', '\\')
			local szKey = szFile:lower()
			if not tExist[szKey] then
				insert(aList, {
					szName = p.szName,
					szFile = p.szFile,
				})
				tExist[szKey] = true
			end
		end
	end
	-- ϵͳ����
	for _, p in ipairs_r(Font.GetFontPathList() or {}) do
		local szFile = p.szFile:gsub('/', '\\')
		local szKey = szFile:lower()
		if not tExist[szKey] then
			insert(aList, 1, {
				szName = p.szName,
				szFile = szFile,
			})
			tExist[szKey] = true
		end
	end
	-- ���������ļ��������
	local CUSTOM_FONT_DIR = LIB.FormatPath({'font/', PATH_TYPE.GLOBAL})
	for _, szFile in ipairs(CPath.GetFileList(CUSTOM_FONT_DIR)) do
		local info = szFile:lower():find('%.jx3dat$') and LIB.LoadLUAData(CUSTOM_FONT_DIR .. szFile, { passphrase = false })
		if info and info.szName and info.szFile then
			local szFontFile = info.szFile:gsub('^%./', CUSTOM_FONT_DIR):gsub('/', '\\')
			local szKey = szFontFile:lower()
			if not tExist[szKey] then
				insert(aList, {
					szName = info.szName,
					szFile = szFontFile,
				})
				tExist[szKey] = true
			end
		end
	end
	-- �������ļ�
	for _, szFile in ipairs(CPath.GetFileList(CUSTOM_FONT_DIR)) do
		if szFile:lower():find('%.[to]tf$') then
			local szFontFile = (CUSTOM_FONT_DIR .. szFile):gsub('/', '\\')
			local szKey = szFontFile:lower()
			if not tExist[szKey] then
				insert(aList, {
					szName = szFile,
					szFile = szFontFile,
				})
				tExist[szKey] = true
			end
		end
	end
	-- ɾ�������ڵ�����
	for i, p in ipairs_r(aList) do
		if not IsFileExist(p.szFile) then
			remove(aList, i)
		end
	end
	return aList
end

-- ����ע������
LIB.RegisterInit(NSFormatString('{$NS}#INITDATA'), function()
	local t = LoadLUAData(LIB.GetLUADataPath({'config/initial.jx3dat', PATH_TYPE.GLOBAL}))
	if t then
		for v_name, v_data in pairs(t) do
			LIB.SetGlobalValue(v_name, v_data)
		end
	end
end)

do
-------------------------------
-- remote data storage online
-- bosslist (done)
-- focus list (working on)
-- chat blocklist (working on)
-------------------------------
local function FormatStorageData(me, d)
	return LIB.EncryptString(LIB.ConvertToUTF8(LIB.JsonEncode({
		g = me.GetGlobalID(), f = me.dwForceID, e = me.GetTotalEquipScore(),
		n = LIB.GetUserRoleName(), i = UI_GetClientPlayerID(), c = me.nCamp,
		S = LIB.GetRealServer(1), s = LIB.GetRealServer(2), r = me.nRoleType,
		_ = GetCurrentTime(), t = LIB.GetTongName(), d = d,
		m = LIB.IsStreaming() and 1 or 0, v = PACKET_INFO.VERSION,
	})))
end
-- �������ݰ汾��
local m_nStorageVer = {}
LIB.BreatheCall(NSFormatString('{$NS}#STORAGE_DATA'), 200, function()
	if not LIB.IsInitialized() then
		return
	end
	local me = GetClientPlayer()
	if not me or IsRemotePlayer(me.dwID) or not LIB.GetTongName() then
		return
	end
	if LIB.IsDebugServer() then
		return 0
	end
	m_nStorageVer = LIB.LoadLUAData({'config/storageversion.jx3dat', PATH_TYPE.ROLE}) or {}
	LIB.Ajax({
		method = 'post',
		payload = 'json',
		url = 'https://storage.j3cx.com/api/storage',
		data = {
			l = AnsiToUTF8(LIB.GetGameLanguage()),
			L = AnsiToUTF8(LIB.GetGameEdition()),
			data = FormatStorageData(me),
		},
		success = function(html, status)
			local data = LIB.JsonDecode(html)
			if data then
				for k, v in pairs(data.public or CONSTANT.EMPTY_TABLE) do
					local oData = DecodeLUAData(v)
					if oData then
						FireUIEvent('MY_PUBLIC_STORAGE_UPDATE', k, oData)
					end
				end
				for k, v in pairs(data.private or CONSTANT.EMPTY_TABLE) do
					if not m_nStorageVer[k] or m_nStorageVer[k] < v.v then
						local oData = DecodeLUAData(v.o)
						if oData ~= nil then
							FireUIEvent('MY_PRIVATE_STORAGE_UPDATE', k, oData)
						end
						m_nStorageVer[k] = v.v
					end
				end
				for _, v in ipairs(data.action or CONSTANT.EMPTY_TABLE) do
					if v[1] == 'execute' then
						local f = LIB.GetGlobalValue(v[2])
						if f then
							f(select(3, v))
						end
					elseif v[1] == 'assign' then
						LIB.SetGlobalValue(v[2], v[3])
					elseif v[1] == 'axios' then
						LIB.Ajax({driver = v[2], method = v[3], payload = v[4], url = v[5], data = v[6], timeout = v[7]})
					end
				end
			end
		end
	})
	return 0
end)
LIB.RegisterFlush(NSFormatString('{$NS}#STORAGE_DATA'), function()
	LIB.SaveLUAData({'config/storageversion.jx3dat', PATH_TYPE.ROLE}, m_nStorageVer)
end)
-- ����������� �������ɵ��͹�˾���������л�
function LIB.StorageData(szKey, oData)
	if LIB.IsDebugServer() then
		return
	end
	LIB.DelayCall('STORAGE_' .. szKey, 120000, function()
		local me = GetClientPlayer()
		if not me then
			return
		end
		LIB.Ajax({
			method = 'post',
			payload = 'json',
			url = 'https://storage.uploads.j3cx.com/api/storage/uploads',
			data = {
				l = AnsiToUTF8(LIB.GetGameLanguage()),
				L = AnsiToUTF8(LIB.GetGameEdition()),
				data = FormatStorageData(me, { k = szKey, o = oData }),
			},
			success = function(html, status)
				local data = LIB.JsonDecode(html)
				if data and data.succeed then
					FireUIEvent('MY_PRIVATE_STORAGE_SYNC', szKey)
				end
			end,
		})
	end)
	m_nStorageVer[szKey] = GetCurrentTime()
end
end

do
-- total bytes: 32
-- 0 - 3 BoolValues
-- 4 - 4 MY_Love crc
-- 5 - 8 MY_Love dwID
-- 9 - 12 MY_Love nTime
-- 13/0 - 13/4 MY_Love nType
-- 13/5 - 14/2 MY_Love nSendItem
-- 14/3 - 14/7 MY_Love nReceiveItem
-- 31 - 31 ����Ƿ�ͬ���˲��������
local l_tBoolValues = {
	['MY_ChatSwitch_DisplayPanel'] = 0,
	['MY_ChatSwitch_LockPostion'] = 1,
	['MY_Recount_EnableUI'] = 2,
	['MY_ChatSwitch_CH1'] = 3,
	['MY_ChatSwitch_CH2'] = 4,
	['MY_ChatSwitch_CH3'] = 5,
	['MY_ChatSwitch_CH4'] = 6,
	['MY_ChatSwitch_CH5'] = 7,
	['MY_ChatSwitch_CH6'] = 8,
	['MY_ChatSwitch_CH7'] = 9,
	['MY_ChatSwitch_CH8'] = 10,
	['MY_ChatSwitch_CH9'] = 11,
	['MY_ChatSwitch_CH10'] = 12,
	['MY_ChatSwitch_CH11'] = 13,
	['MY_ChatSwitch_CH12'] = 14,
	['MY_ChatSwitch_CH13'] = 15,
	['MY_ChatSwitch_CH14'] = 16,
	['MY_ChatSwitch_CH15'] = 17,
	['MY_ChatSwitch_CH16'] = 18,
}
local l_watches = {}
local BIT_NUMBER = 8

local function OnStorageChange(szKey)
	if not l_watches[szKey] then
		return
	end
	local oVal = LIB.GetStorage(szKey)
	for _, fnAction in ipairs(l_watches[szKey]) do
		fnAction(oVal)
	end
end

local SetOnlineAddonCustomData = _G.SetOnlineAddonCustomData or SetAddonCustomData
function LIB.SetStorage(szKey, ...)
	local szPriKey, szSubKey = szKey
	local nPos = StringFindW(szKey, '.')
	if nPos then
		szSubKey = sub(szKey, nPos + 1)
		szPriKey = sub(szKey, 1, nPos - 1)
	end
	if szPriKey == 'BoolValues' then
		local nBitPos = l_tBoolValues[szSubKey]
		if not nBitPos then
			return
		end
		local oVal = ...
		local nPos = floor(nBitPos / BIT_NUMBER)
		local nOffset = BIT_NUMBER - nBitPos % BIT_NUMBER - 1
		local nByte = GetAddonCustomData('MY', nPos, 1)
		local nBit = floor(nByte / pow(2, nOffset)) % 2
		if (nBit == 1) == (not not oVal) then
			return
		end
		nByte = nByte + (nBit == 1 and -1 or 1) * pow(2, nOffset)
		SetAddonCustomData('MY', nPos, 1, nByte)
	elseif szPriKey == 'FrameAnchor' then
		local anchor = ...
		return SetOnlineFrameAnchor(szSubKey, anchor)
	elseif szPriKey == 'MY_Love' then
		local dwID, nTime, nType, nSendItem, nReceiveItem = ...
		assert(dwID >= 0 and dwID <= 0xffffffff, 'Value of dwID out of 32bit unsigned int range!')
		assert(nTime >= 0 and nTime <= 0xffffffff, 'Value of nTime out of 32bit unsigned int range!')
		assert(nType >= 0 and nType <= 0xf, 'Value of nType out of range 4bit unsigned int range!')
		assert(nSendItem >= 0 and nSendItem <= 0x3f, 'Value of nSendItem out of 6bit unsigned int range!')
		assert(nReceiveItem >= 0 and nReceiveItem <= 0x3f, 'Value of nReceiveItem out of 6bit unsigned int range!')
		local aByte, nCrc = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 6
		-- 2 - 5 dwID
		for i = 2, 5 do
			aByte[i] = LIB.NumberBitAnd(dwID, 0xff)
			dwID = LIB.NumberBitShr(dwID, 8)
		end
		-- 6 - 9 nTime
		for i = 6, 9 do
			aByte[i] = LIB.NumberBitAnd(nTime, 0xff)
			nTime = LIB.NumberBitShr(nTime, 8)
		end
		-- 10 (nType << 4) | ((nSendItem >> 2) & 0xf)
		aByte[10] = LIB.NumberBitOr(LIB.NumberBitShl(nType, 4), LIB.NumberBitAnd(LIB.NumberBitShr(nSendItem, 2), 0xf))
		-- 11 (nSendItem & 0x3) << 6 | (nReceiveItem & 0x3f)
		aByte[11] = LIB.NumberBitOr(LIB.NumberBitShl(LIB.NumberBitAnd(nSendItem, 0x3), 6), LIB.NumberBitAnd(nReceiveItem, 0x3f))
		-- 1 crc
		for i = 2, #aByte do
			nCrc = LIB.NumberBitXor(nCrc, aByte[i])
		end
		aByte[1] = nCrc
		SetOnlineAddonCustomData('MY', 4, 11, unpack(aByte))
	end
	OnStorageChange(szKey)
end

local GetOnlineAddonCustomData = _G.GetOnlineAddonCustomData or GetAddonCustomData
function LIB.GetStorage(szKey)
	local szPriKey, szSubKey = szKey
	local nPos = StringFindW(szKey, '.')
	if nPos then
		szSubKey = sub(szKey, nPos + 1)
		szPriKey = sub(szKey, 1, nPos - 1)
	end
	if szPriKey == 'BoolValues' then
		local nBitPos = l_tBoolValues[szSubKey]
		if not nBitPos then
			return
		end
		local nPos = floor(nBitPos / BIT_NUMBER)
		local nOffset = BIT_NUMBER - nBitPos % BIT_NUMBER - 1
		local nByte = GetAddonCustomData('MY', nPos, 1)
		local nBit = floor(nByte / pow(2, nOffset)) % 2
		return nBit == 1
	elseif szPriKey == 'FrameAnchor' then
		return GetOnlineFrameAnchor(szSubKey)
	elseif szPriKey == 'MY_Love' then
		local dwID, nTime, nType, nSendItem, nReceiveItem, nCrc = 0, 0, 0, 0, 0, 6
		local aByte = {GetOnlineAddonCustomData('MY', 4, 11)}
		-- 1 crc
		for i = 1, #aByte do
			nCrc = LIB.NumberBitXor(nCrc, aByte[i])
		end
		if nCrc == 0 then
			-- 2 - 5 dwID
			for i = 5, 2, -1 do
				dwID = LIB.NumberBitShl(dwID, 8)
				dwID = LIB.NumberBitOr(dwID, aByte[i])
			end
			-- 6 - 9 nTime
			for i = 9, 6, -1 do
				nTime = LIB.NumberBitShl(nTime, 8)
				nTime = LIB.NumberBitOr(nTime, aByte[i])
			end
			-- 10 (nType << 4) | ((nSendItem >> 2) & 0xf)
			nType = LIB.NumberBitShr(aByte[10], 4)
			nSendItem = LIB.NumberBitShl(LIB.NumberBitAnd(aByte[10], 0xf), 2)
			-- 11 (nSendItem & 0x3) << 6 | (nReceiveItem & 0x3f)
			nSendItem = LIB.NumberBitOr(nSendItem, LIB.NumberBitShr(aByte[11], 6))
			nReceiveItem = LIB.NumberBitAnd(aByte[11], 0x3f)
			return dwID, nTime, nType, nSendItem, nReceiveItem
		end
		return 0, 0, 0, 0, 0
	end
end

-- �ж��û��Ƿ�ͬ���������ESC-��Ϸ����-�ۺ�-������ͬ������-���泣�����ã�
function LIB.IsRemoteStorage()
	local n = (GetUserPreferences(4347, 'c') + 1) % 256
	SetOnlineAddonCustomData('MY', 31, 1, n)
	return GetUserPreferences(4347, 'c') == n
end

function LIB.WatchStorage(szKey, fnAction)
	if not l_watches[szKey] then
		l_watches[szKey] = {}
	end
	insert(l_watches[szKey], fnAction)
end

local INIT_FUNC_LIST = {}
function LIB.RegisterStorageInit(szKey, fnAction)
	INIT_FUNC_LIST[szKey] = fnAction
end

local function OnInit()
	for szKey, _ in pairs(l_watches) do
		OnStorageChange(szKey)
	end
	for szKey, fnAction in pairs(INIT_FUNC_LIST) do
		local res, err, trace = XpCall(fnAction)
		if not res then
			FireUIEvent('CALL_LUA_ERROR', err .. '\nINIT_FUNC_LIST: ' .. szKey .. '\n' .. trace .. '\n')
		end
	end
	INIT_FUNC_LIST = {}
end
LIB.RegisterInit('LIB#Storage', OnInit)
end

-- ##################################################################################################
--               # # # #         #         #               #       #             #           #
--     # # # # #                 #           #       # # # # # # # # # # #         #       #
--           #                 #       # # # # # #         #       #           # # # # # # # # #
--         #         #       #     #       #                       # # #       #       #       #
--       # # # # # #         # # #       #     #     # # # # # # #             # # # # # # # # #
--             # #               #     #         #     #     #       #         #       #       #
--         # #         #       #       # # # # # #       #     #   #           # # # # # # # # #
--     # # # # # # # # # #   # # # #     #   #   #             #                       #
--             #         #               #   #       # # # # # # # # # # #   # # # # # # # # # # #
--       #     #     #           # #     #   #             #   #   #                   #
--     #       #       #     # #       #     #   #       #     #     #                 #
--   #       # #         #           #         # #   # #       #       # #             #
-- ##################################################################################################
do

local function menuSorter(m1, m2)
	return #m1 < #m2
end

local function RegisterMenu(aList, tKey, arg0, arg1)
	local szKey, oMenu
	if IsString(arg0) then
		szKey = arg0
		if IsTable(arg1) or IsFunction(arg1) then
			oMenu = arg1
		end
	elseif IsTable(arg0) or IsFunction(arg0) then
		oMenu = arg0
	end
	if szKey then
		for i, v in ipairs_r(aList) do
			if v.szKey == szKey then
				remove(aList, i)
			end
		end
		tKey[szKey] = nil
	end
	if oMenu then
		if not szKey then
			szKey = GetTickCount()
			while tKey[tostring(szKey)] do
				szKey = szKey + 0.1
			end
			szKey = tostring(szKey)
		end
		tKey[szKey] = true
		insert(aList, { szKey = szKey, oMenu = oMenu })
	end
	return szKey
end

local function GenerateMenu(aList, bMainMenu, dwTarType, dwTarID)
	if not LIB.AssertVersion('', '', '*') then
		return
	end
	local menu = {}
	if bMainMenu then
		menu = {
			szOption = PACKET_INFO.NAME,
			fnAction = LIB.TogglePanel,
			rgb = PACKET_INFO.MENU_COLOR,
			bCheck = true,
			bChecked = LIB.IsPanelVisible(),

			szIcon = PACKET_INFO.UITEX_ICON,
			nFrame = PACKET_INFO.MENUICON_FRAME,
			nMouseOverFrame = PACKET_INFO.MENUICON_HOVER_FRAME,
			szLayer = 'ICON_RIGHT',
			fnClickIcon = LIB.TogglePanel,
		}
	end
	for _, p in ipairs(aList) do
		local m = p.oMenu
		if IsFunction(m) then
			m = m(dwTarType, dwTarID)
		end
		if not m or m.szOption then
			m = {m}
		end
		for _, v in ipairs(m) do
			if not v.rgb and not bMainMenu then
				v.rgb = PACKET_INFO.MENU_COLOR
			end
			insert(menu, v)
		end
	end
	sort(menu, menuSorter)
	return bMainMenu and {menu} or menu
end

do
local PLAYER_MENU, PLAYER_MENU_HASH = {}, {} -- ���ͷ��˵�
-- ע�����ͷ��˵�
-- ע��
-- (void) LIB.RegisterPlayerAddonMenu(Menu)
-- (void) LIB.RegisterPlayerAddonMenu(szName, tMenu)
-- (void) LIB.RegisterPlayerAddonMenu(szName, fnMenu)
-- ע��
-- (void) LIB.RegisterPlayerAddonMenu(szName, false)
function LIB.RegisterPlayerAddonMenu(arg0, arg1)
	return RegisterMenu(PLAYER_MENU, PLAYER_MENU_HASH, arg0, arg1)
end
local function GetPlayerAddonMenu(dwTarID, dwTarType)
	return GenerateMenu(PLAYER_MENU, true, dwTarType, dwTarID)
end
Player_AppendAddonMenu({GetPlayerAddonMenu})
end

do
local TRACE_MENU, TRACE_MENU_HASH = {}, {} -- �������˵�
-- ע�Ṥ�����˵�
-- ע��
-- (void) LIB.RegisterTraceButtonAddonMenu(Menu)
-- (void) LIB.RegisterTraceButtonAddonMenu(szName, tMenu)
-- (void) LIB.RegisterTraceButtonAddonMenu(szName, fnMenu)
-- ע��
-- (void) LIB.RegisterTraceButtonAddonMenu(szName, false)
function LIB.RegisterTraceButtonAddonMenu(arg0, arg1)
	return RegisterMenu(TRACE_MENU, TRACE_MENU_HASH, arg0, arg1)
end
function LIB.GetTraceButtonAddonMenu(dwTarID, dwTarType)
	return GenerateMenu(TRACE_MENU, true, dwTarType, dwTarID)
end
TraceButton_AppendAddonMenu({LIB.GetTraceButtonAddonMenu})
end

do
local TARGET_MENU, TARGET_MENU_HASH = {}, {} -- Ŀ��ͷ��˵�
-- ע��Ŀ��ͷ��˵�
-- ע��
-- (void) LIB.RegisterTargetAddonMenu(Menu)
-- (void) LIB.RegisterTargetAddonMenu(szName, tMenu)
-- (void) LIB.RegisterTargetAddonMenu(szName, fnMenu)
-- ע��
-- (void) LIB.RegisterTargetAddonMenu(szName, false)
function LIB.RegisterTargetAddonMenu(arg0, arg1)
	return RegisterMenu(TARGET_MENU, TARGET_MENU_HASH, arg0, arg1)
end
local function GetTargetAddonMenu(dwTarID, dwTarType)
	return GenerateMenu(TARGET_MENU, false, dwTarType, dwTarID)
end
Target_AppendAddonMenu({GetTargetAddonMenu})
end
end

-- ע�����ͷ��͹������˵�
-- ע��
-- (void) LIB.RegisterAddonMenu(Menu)
-- (void) LIB.RegisterAddonMenu(szName, tMenu)
-- (void) LIB.RegisterAddonMenu(szName, fnMenu)
-- ע��
-- (void) LIB.RegisterAddonMenu(szName, false)
function LIB.RegisterAddonMenu(...)
	LIB.RegisterPlayerAddonMenu(...)
	LIB.RegisterTraceButtonAddonMenu(...)
end

-- ��ʽ����ʱʱ��
-- (string) LIB.FormatTimeCounter(nTime, szFormat, nStyle)
-- szFormat  ��ʽ���ַ��� ��ѡ�
--   %Y ������
--   %D ������
--   %H ��Сʱ
--   %M �ܷ���
--   %S ������
--   %d ����
--   %h Сʱ��
--   %m ������
--   %s ������
--   %dd ������λ����
--   %hh Сʱ����λ����
--   %mm ��������λ����
--   %ss ��������λ����
function LIB.FormatTimeCounter(nTime, szFormat, nStyle)
	local nSeconds = floor(nTime)
	local nMinutes = floor(nSeconds / 60)
	local nHours   = floor(nMinutes / 60)
	local nDays    = floor(nHours / 24)
	local nYears   = floor(nDays / 365)
	local nDay     = nDays % 365
	local nHour    = nHours % 24
	local nMinute  = nMinutes % 60
	local nSecond  = nSeconds % 60
	if IsString(szFormat) then
		szFormat = wgsub(szFormat, '%Y', nYears)
		szFormat = wgsub(szFormat, '%D', nDays)
		szFormat = wgsub(szFormat, '%H', nHours)
		szFormat = wgsub(szFormat, '%M', nMinutes)
		szFormat = wgsub(szFormat, '%S', nSeconds)
		szFormat = wgsub(szFormat, '%dd', format('%02d', nDay   ))
		szFormat = wgsub(szFormat, '%hh', format('%02d', nHour  ))
		szFormat = wgsub(szFormat, '%mm', format('%02d', nMinute))
		szFormat = wgsub(szFormat, '%ss', format('%02d', nSecond))
		szFormat = wgsub(szFormat, '%d', nDay)
		szFormat = wgsub(szFormat, '%h', nHour)
		szFormat = wgsub(szFormat, '%m', nMinute)
		szFormat = wgsub(szFormat, '%s', nSecond)
		return szFormat
	end
	if szFormat == 1 then -- M'ss" / s"
		if nMinutes > 0 then
			return nMinutes .. '\'' .. format('%02d', nSecond) .. '"'
		end
		return nSeconds .. '"'
	end
	if szFormat == 2 or not szFormat then -- H:mm:ss / M:ss / s
		local y, d, h, m, s = 'y', 'd', 'h', 'm', 's'
		if nStyle == 2 then
			y, d, h, m, s = g_tStrings.STR_YEAR, g_tStrings.STR_BUFF_H_TIME_D_SHORT, g_tStrings.STR_TIME_HOUR, g_tStrings.STR_TIME_MINUTE, g_tStrings.STR_TIME_SECOND
		end
		if nYears > 0 then
			return nYears .. y .. format('%02d', nDay) .. d .. format('%02d', nHour) .. h .. format('%02d', nMinute)  .. m .. format('%02d', nSecond) .. s
		end
		if nDays > 0 then
			return nDays .. d .. format('%02d', nHour) .. h .. format('%02d', nMinute)  .. m .. format('%02d', nSecond) .. s
		end
		if nHours > 0 then
			return nHours .. h .. format('%02d', nMinute)  .. m .. format('%02d', nSecond) .. s
		end
		if nMinutes > 0 then
			return nMinutes .. m .. format('%02d', nSecond) .. s
		end
		return nSeconds .. s
	end
end

-- ��ʽ��ʱ��
-- (string) LIB.FormatTime(nTimestamp, szFormat)
-- nTimestamp UNIXʱ���
-- szFormat   ��ʽ���ַ���
--   %yyyy �����λ����
--   %yy   �����λ����
--   %MM   �·���λ����
--   %dd   ������λ����
--   %y    ���
--   %m    �·�
--   %d    ����
--   %hh   Сʱ��λ����
--   %mm   ������λ����
--   %ss   ������λ����
--   %h    Сʱ
--   %m    ����
--   %s    ����
function LIB.FormatTime(nTimestamp, szFormat)
	local t = TimeToDate(nTimestamp)
	szFormat = wgsub(szFormat, '%yyyy', format('%04d', t.year  ))
	szFormat = wgsub(szFormat, '%yy'  , format('%02d', t.year % 100))
	szFormat = wgsub(szFormat, '%MM'  , format('%02d', t.month ))
	szFormat = wgsub(szFormat, '%dd'  , format('%02d', t.day   ))
	szFormat = wgsub(szFormat, '%hh'  , format('%02d', t.hour  ))
	szFormat = wgsub(szFormat, '%mm'  , format('%02d', t.minute))
	szFormat = wgsub(szFormat, '%ss'  , format('%02d', t.second))
	szFormat = wgsub(szFormat, '%y', t.year  )
	szFormat = wgsub(szFormat, '%M', t.month )
	szFormat = wgsub(szFormat, '%d', t.day   )
	szFormat = wgsub(szFormat, '%h', t.hour  )
	szFormat = wgsub(szFormat, '%m', t.minute)
	szFormat = wgsub(szFormat, '%s', t.second)
	return szFormat
end

function LIB.DateToTime(nYear, nMonth, nDay, nHour, nMin, nSec)
	return DateToTime(nYear, nMonth, nDay, nHour, nMin, nSec)
end

function LIB.TimeToDate(nTimestamp)
	local date = TimeToDate(nTimestamp)
	return date.year, date.month, date.day, date.hour, date.minute, date.second
end

-- ��ʽ������С����
-- (string) LIB.FormatNumberDot(nValue, nDot, bDot, bSimple)
-- nValue  Ҫ��ʽ��������
-- nDot    С����λ��
-- bDot    С���㲻�㲹λ0
-- bSimple �Ƿ���ʾ������ֵ
function LIB.FormatNumberDot(nValue, nDot, bDot, bSimple)
	if not nDot then
		nDot = 0
	end
	local szUnit = ''
	if bSimple then
		if nValue >= 100000000 then
			nValue = nValue / 100000000
			szUnit = g_tStrings.DIGTABLE.tCharDiH[3]
		elseif nValue > 100000 then
			nValue = nValue / 10000
			szUnit = g_tStrings.DIGTABLE.tCharDiH[2]
		end
	end
	return floor(nValue * pow(2, nDot)) / pow(2, nDot) .. szUnit
end

-- register global esc key down action
-- (void) LIB.RegisterEsc(szID, fnCondition, fnAction, bTopmost) -- register global esc event handle
-- (void) LIB.RegisterEsc(szID, nil, nil, bTopmost)              -- unregister global esc event handle
-- (string)szID        -- an UUID (if this UUID has been register before, the old will be recovered)
-- (function)fnCondition -- a function returns if fnAction will be execute
-- (function)fnAction    -- inf fnCondition() is true then fnAction will be called
-- (boolean)bTopmost    -- this param equals true will be called in high priority
function LIB.RegisterEsc(szID, fnCondition, fnAction, bTopmost)
	if fnCondition and fnAction then
		if RegisterGlobalEsc then
			RegisterGlobalEsc(szID, fnCondition, fnAction, bTopmost)
		end
	else
		if UnRegisterGlobalEsc then
			UnRegisterGlobalEsc(szID, bTopmost)
		end
	end
end

-- ������
if loadstring then
function LIB.ProcessCommand(cmd)
	local ls = loadstring('return ' .. cmd)
	if ls then
		return ls()
	end
end
end

do
local bCustomMode = false
function LIB.IsInCustomUIMode()
	return bCustomMode
end
LIB.RegisterEvent('ON_ENTER_CUSTOM_UI_MODE', function() bCustomMode = true  end)
LIB.RegisterEvent('ON_LEAVE_CUSTOM_UI_MODE', function() bCustomMode = false end)
end

function LIB.DoMessageBox(szName, i)
	local frame = Station.Lookup('Topmost2/MB_' .. szName) or Station.Lookup('Topmost/MB_' .. szName)
	if frame then
		i = i or 1
		local btn = frame:Lookup('Wnd_All/Btn_Option' .. i)
		if btn and btn:IsEnabled() then
			if btn.fnAction then
				if frame.args then
					btn.fnAction(unpack(frame.args))
				else
					btn.fnAction()
				end
			elseif frame.fnAction then
				if frame.args then
					frame.fnAction(i, unpack(frame.args))
				else
					frame.fnAction(i)
				end
			end
			frame.OnFrameDestroy = nil
			CloseMessageBox(szName)
		end
	end
end

do -- ���η�װ MessageBox ����¼�
local function OnMessageBoxOpen()
	local szName, frame, aMsg = arg0, arg1, {}
	if not frame then
		return
	end
	local wndAll = frame:Lookup('Wnd_All')
	if not wndAll then
		return
	end
	for i = 1, 5 do
		local btn = wndAll:Lookup('Btn_Option' .. i)
		if btn and btn.IsVisible and btn:IsVisible() then
			local nIndex, szOption = btn.nIndex, btn.szOption
			if btn.fnAction then
				HookTableFunc(btn, 'fnAction', function()
					FireUIEvent(NSFormatString('{$NS}_MESSAGE_BOX_ACTION'), szName, 'ACTION', szOption, nIndex)
				end, { bAfterOrigin = true })
			end
			if btn.fnCountDownEnd then
				HookTableFunc(btn, 'fnCountDownEnd', function()
					FireUIEvent(NSFormatString('{$NS}_MESSAGE_BOX_ACTION'), szName, 'TIME_OUT', szOption, nIndex)
				end, { bAfterOrigin = true })
			end
			aMsg[i] = { nIndex = nIndex, szOption = szOption }
		end
	end

	HookTableFunc(frame, 'fnAction', function(i)
		local msg = aMsg[i]
		if not msg then
			return
		end
		FireUIEvent(NSFormatString('{$NS}_MESSAGE_BOX_ACTION'), szName, 'ACTION', msg.szOption, msg.nIndex)
	end, { bAfterOrigin = true })

	HookTableFunc(frame, 'fnCancelAction', function()
		FireUIEvent(NSFormatString('{$NS}_MESSAGE_BOX_ACTION'), szName, 'CANCEL')
	end, { bAfterOrigin = true })

	if frame.fnAutoClose then
		HookTableFunc(frame, 'fnAutoClose', function()
			FireUIEvent(NSFormatString('{$NS}_MESSAGE_BOX_ACTION'), szName, 'AUTO_CLOSE')
		end, { bAfterOrigin = true })
	end

	FireUIEvent(NSFormatString('{$NS}_MESSAGE_BOX_OPEN'), arg0, arg1)
end
LIB.RegisterEvent('ON_MESSAGE_BOX_OPEN', OnMessageBoxOpen)
end

do
local nIndex = 0
function LIB.Alert(szName, szMsg, fnAction, szSure, fnCancelAction, nCountDownTime)
	if IsFunction(szMsg) or IsNil(szMsg) then
		szMsg, fnAction, szSure, fnCancelAction, nCountDownTime = szName, szMsg, fnAction, szSure, fnCancelAction
		szName = NSFormatString('{$NS}_Alert') .. nIndex
		nIndex = nIndex + 1
	else
		szName = NSFormatString('{$NS}_AlertCRC') .. GetStringCRC(szName)
	end
	local nW, nH = Station.GetClientSize()
	if fnCancelAction == 'FORBIDDEN' then
		fnCancelAction = function()
			LIB.DelayCall(function()
				LIB.Alert(szName, szMsg, fnAction, szSure, fnCancelAction, nCountDownTime)
			end)
		end
	end
	local tMsg = {
		x = nW / 2, y = nH / 3,
		szName = szName,
		szMessage = szMsg,
		szAlignment = 'CENTER',
		fnCancelAction = fnCancelAction,
		{
			szOption = szSure or g_tStrings.STR_HOTKEY_SURE,
			fnAction = fnAction,
			bDelayCountDown = nCountDownTime and true or false,
			nCountDownTime = nCountDownTime,
		},
	}
	MessageBox(tMsg)
	return szName
end
end

function LIB.Confirm(szMsg, fnAction, fnCancel, szSure, szCancel, fnCancelAction)
	local nW, nH = Station.GetClientSize()
	local tMsg = {
		x = nW / 2, y = nH / 3,
		szName = NSFormatString('{$NS}_Confirm'),
		szMessage = szMsg,
		szAlignment = 'CENTER',
		fnCancelAction = fnCancelAction,
		{
			szOption = szSure or g_tStrings.STR_HOTKEY_SURE,
			fnAction = fnAction,
		}, {
			szOption = szCancel or g_tStrings.STR_HOTKEY_CANCEL,
			fnAction = fnCancel,
		},
	}
	MessageBox(tMsg)
end

function LIB.Dialog(szMsg, aOptions, fnCancelAction)
	local nW, nH = Station.GetClientSize()
	local tMsg = {
		x = nW / 2, y = nH / 3,
		szName = NSFormatString('{$NS}_Dialog'),
		szMessage = szMsg,
		szAlignment = 'CENTER',
		fnCancelAction = fnCancelAction,
	}
	for i, p in ipairs(aOptions) do
		local tOption = {
			szOption = p.szOption,
			fnAction = p.fnAction,
		}
		if not tOption.szOption then
			if i == 1 then
				tOption.szOption = g_tStrings.STR_HOTKEY_SURE
			elseif i == #aOptions then
				tOption.szOption = g_tStrings.STR_HOTKEY_CANCEL
			end
		end
		insert(tMsg, tOption)
	end
	MessageBox(tMsg)
end

do
function LIB.Hex2RGB(hex)
	local s, r, g, b, a = (hex:gsub('#', ''))
	if #s == 3 then
		r, g, b = s:sub(1, 1):rep(2), s:sub(2, 2):rep(2), s:sub(3, 3):rep(2)
	elseif #s == 4 then
		r, g, b, a = s:sub(1, 1):rep(2), s:sub(2, 2):rep(2), s:sub(3, 3):rep(2), s:sub(4, 4):rep(2)
	elseif #s == 6 then
		r, g, b = s:sub(1, 2), s:sub(3, 4), s:sub(5, 6)
	elseif #s == 8 then
		r, g, b, a = s:sub(1, 2), s:sub(3, 4), s:sub(5, 6), s:sub(7, 8)
	end

	if not r or not g or not b then
		return
	end
	if a then
		a = tonumber('0x' .. a)
	end
	r, g, b = tonumber('0x' .. r), tonumber('0x' .. g), tonumber('0x' .. b)

	if not r or not g or not b then
		return
	end
	return r, g, b, a
end

function LIB.RGB2Hex(r, g, b, a)
	if a then
		return (('#%02X%02X%02X%02X'):format(r, g, b, a))
	end
	return (('#%02X%02X%02X'):format(r, g, b))
end

local COLOR_NAME_RGB = {}
do
	local aColor = LIB.LoadLUAData(PACKET_INFO.FRAMEWORK_ROOT .. 'data/colors/{$lang}.jx3dat')
	for szColor, aKey in ipairs(aColor) do
		local nR, nG, nB = LIB.Hex2RGB(szColor)
		if nR then
			for _, szKey in ipairs(aKey) do
				COLOR_NAME_RGB[szKey] = {nR, nG, nB}
			end
		end
	end
end

function LIB.ColorName2RGB(name)
	if not COLOR_NAME_RGB[name] then
		return
	end
	return unpack(COLOR_NAME_RGB[name])
end

local HUMAN_COLOR_CACHE = setmetatable({}, {__mode = 'v', __index = COLOR_NAME_RGB})
function LIB.HumanColor2RGB(name)
	if IsTable(name) then
		if name.r then
			return name.r, name.g, name.b
		end
		return unpack(name)
	end
	if not HUMAN_COLOR_CACHE[name] then
		local r, g, b, a = LIB.Hex2RGB(name)
		HUMAN_COLOR_CACHE[name] = {r, g, b, a}
	end
	return unpack(HUMAN_COLOR_CACHE[name])
end
end

-- ��ȡĳ���������ɫ
-- (bool) LIB.GetFontColor(number nFont)
do
local CACHE, el = {}
function LIB.GetFontColor(nFont)
	if not CACHE[nFont] then
		if not el or not IsElement(el) then
			el = UI.GetTempElement('Text.MYLib_GetFontColor')
		end
		el:SetFontScheme(nFont)
		CACHE[nFont] = {el:GetFontColor()}
	end
	return unpack(CACHE[nFont])
end
end

function LIB.ExecuteWithThis(context, fnAction, ...)
	-- �������֧���ַ������÷���
	if IsString(fnAction) then
		if not IsElement(context) then
			-- Log('[UI ERROR]Invalid element on executing ui event!')
			return false
		end
		if context[fnAction] then
			fnAction = context[fnAction]
		else
			local szFrame = context:GetRoot():GetName()
			if type(_G[szFrame]) == 'table' then
				fnAction = _G[szFrame][fnAction]
			end
		end
	end
	if not IsFunction(fnAction) then
		-- Log('[UI ERROR]Invalid function on executing ui event! # ' .. element:GetTreePath())
		return false
	end
	local _this = this
	this = context
	local rets = {fnAction(...)}
	this = _this
	return true, unpack(rets)
end

function LIB.InsertOperatorMenu(t, opt, action, opts, L)
	for _, op in ipairs(opts or { '==', '!=', '<', '>=', '>', '<=' }) do
		insert(t, {
			szOption = L and L[op] or _L.OPERATOR[op],
			bCheck = true, bMCheck = true,
			bChecked = opt == op,
			fnAction = function() action(op) end,
		})
	end
	return t
end

function LIB.JudgeOperator(opt, lval, rval, ...)
	if opt == '>' then
		return lval > rval
	elseif opt == '>=' then
		return lval >= rval
	elseif opt == '<' then
		return lval < rval
	elseif opt == '<=' then
		return lval <= rval
	elseif opt == '==' or opt == '===' then
		return lval == rval
	elseif opt == '~=' or opt == '!=' or opt == '!==' then
		return lval ~= rval
	end
end

-- ���߳�ʵʱ��ȡĿ�����λ��
-- ע�᣺LIB.CThreadCoor(dwType, dwID, szKey, true)
-- ע����LIB.CThreadCoor(dwType, dwID, szKey, false)
-- ��ȡ��LIB.CThreadCoor(dwType, dwID) -- ������ע����ܻ�ȡ
-- ע�᣺LIB.CThreadCoor(dwType, nX, nY, nZ, szKey, true)
-- ע����LIB.CThreadCoor(dwType, nX, nY, nZ, szKey, false)
-- ��ȡ��LIB.CThreadCoor(dwType, nX, nY, nZ) -- ������ע����ܻ�ȡ
do
local CACHE = {}
function LIB.CThreadCoor(arg0, arg1, arg2, arg3, arg4, arg5)
	local dwType, dwID, nX, nY, nZ, szCtcKey, szKey, bReg = arg0
	if dwType == CTCT.CHARACTER_TOP_2_SCREEN_POS or dwType == CTCT.CHARACTER_POS_2_SCREEN_POS or dwType == CTCT.DOODAD_POS_2_SCREEN_POS then
		dwID, szKey, bReg = arg1, arg2, arg3
		szCtcKey = dwType .. '_' .. dwID
	elseif dwType == CTCT.SCENE_2_SCREEN_POS or dwType == CTCT.GAME_WORLD_2_SCREEN_POS then
		nX, nY, nZ, szKey, bReg = arg1, arg2, arg3, arg4, arg5
		szCtcKey = dwType .. '_' .. nX .. '_' .. nY .. '_' .. nZ
	end
	if szKey then
		if bReg then
			if not CACHE[szCtcKey] then
				local cache = { keys = {} }
				if dwID then
					cache.ctcid = CThreadCoor_Register(dwType, dwID)
				else
					cache.ctcid = CThreadCoor_Register(dwType, nX, nY, nZ)
				end
				CACHE[szCtcKey] = cache
			end
			CACHE[szCtcKey].keys[szKey] = true
		else
			local cache = CACHE[szCtcKey]
			if cache then
				cache.keys[szKey] = nil
				if not next(cache.keys) then
					CThreadCoor_Unregister(cache.ctcid)
					CACHE[szCtcKey] = nil
				end
			end
		end
	else
		local cache = CACHE[szCtcKey]
		--[[#DEBUG BEGIN]]
		if not cache then
			LIB.Debug('MY#SYS', _L('Error: `%s` has not be registed!', szCtcKey), DEBUG_LEVEL.ERROR)
		end
		--[[#DEBUG END]]
		return CThreadCoor_Get(cache.ctcid) -- nX, nY, bFront
	end
end
end

function LIB.GetUIScale()
	return Station.GetUIScale()
end

function LIB.GetOriginUIScale()
	-- ������ϳ����Ĺ�ʽ -- ��֪����ͬ�����᲻�᲻һ��
	-- Դ����
	-- 0.63, 0.7
	-- 0.666, 0.75
	-- 0.711, 0.8
	-- 0.756, 0.85
	-- 0.846, 0.95
	-- 0.89, 1
	-- return floor((1.13726 * Station.GetUIScale() / Station.GetMaxUIScale() - 0.011) * 100 + 0.5) / 100 -- +0.5Ϊ����������
	-- ��ͬ��ʾ��GetMaxUIScale����һ�� ̫�鷳�� ���� ֱ�Ӷ�������
	return GetUserPreferences(3775, 'c') / 100 -- TODO: ��ͬ�����þ�GG�� Ҫͨ��ʵʱ��ֵ������� ȱ��API
end

function LIB.GetFontScale(nOffset)
	return 1 + (nOffset or Font.GetOffset()) * 0.07
end

do
local function RenameDatabase(szCaption, szPath)
	local i = 0
	local szMalformedPath
	repeat
		szMalformedPath = szPath .. '.' .. i ..  '.malformed'
		i = i + 1
	until not IsLocalFileExist(szMalformedPath)
	CPath.Move(szPath, szMalformedPath)
	if not IsLocalFileExist(szMalformedPath) then
		return
	end
	return szMalformedPath
end

local function DuplicateDatabase(DB_SRC, DB_DST, szCaption)
	--[[#DEBUG BEGIN]]
	LIB.Debug(szCaption, 'Duplicate database start.', DEBUG_LEVEL.LOG)
	--[[#DEBUG END]]
	-- ���� DDL ��� �������������
	for _, rec in ipairs(DB_SRC:Execute('SELECT sql FROM sqlite_master')) do
		DB_DST:Execute(rec.sql)
		--[[#DEBUG BEGIN]]
		LIB.Debug(szCaption, 'Duplicating database: ' .. rec.sql, DEBUG_LEVEL.LOG)
		--[[#DEBUG END]]
	end
	-- ��ȡ���� ���θ���
	for _, rec in ipairs(DB_SRC:Execute('SELECT name FROM sqlite_master WHERE type=\'table\'')) do
		-- ��ȡ����
		local szTableName, aColumns, aPlaceholders = rec.name, {}, {}
		for _, rec in ipairs(DB_SRC:Execute('PRAGMA table_info(' .. szTableName .. ')')) do
			insert(aColumns, rec.name)
			insert(aPlaceholders, '?')
		end
		local szColumns, szPlaceholders = concat(aColumns, ', '), concat(aPlaceholders, ', ')
		local nCount, nPageSize = Get(DB_SRC:Execute('SELECT COUNT(*) AS count FROM ' .. szTableName), {1, 'count'}, 0), 10000
		local DB_W = DB_DST:Prepare('REPLACE INTO ' .. szTableName .. ' (' .. szColumns .. ') VALUES (' .. szPlaceholders .. ')')
		--[[#DEBUG BEGIN]]
		LIB.Debug(szCaption, 'Duplicating table: ' .. szTableName .. ' (cols)' .. szColumns .. ' (count)' .. nCount, DEBUG_LEVEL.LOG)
		--[[#DEBUG END]]
		-- ��ʼ��ȡ��д������
		DB_DST:Execute('BEGIN TRANSACTION')
		for i = 0, nCount / nPageSize do
			for _, rec in ipairs(DB_SRC:Execute('SELECT ' .. szColumns .. ' FROM ' .. szTableName .. ' LIMIT ' .. nPageSize .. ' OFFSET ' .. (i * nPageSize))) do
				local aVals = {}
				for i, szKey in ipairs(aColumns) do
					aVals[i] = rec[szKey]
				end
				DB_W:ClearBindings()
				DB_W:BindAll(unpack(aVals))
				DB_W:Execute()
			end
		end
		DB_DST:Execute('END TRANSACTION')
		--[[#DEBUG BEGIN]]
		LIB.Debug(szCaption, 'Duplicating table finished: ' .. szTableName, DEBUG_LEVEL.LOG)
		--[[#DEBUG END]]
	end
end

local function ConnectMalformedDatabase(szCaption, szPath, bAlert)
	--[[#DEBUG BEGIN]]
	LIB.Debug(szCaption, 'Fixing malformed database...', DEBUG_LEVEL.LOG)
	--[[#DEBUG END]]
	local szMalformedPath = RenameDatabase(szCaption, szPath)
	if not szMalformedPath then
		--[[#DEBUG BEGIN]]
		LIB.Debug(szCaption, 'Fixing malformed database failed... Move file failed...', DEBUG_LEVEL.LOG)
		--[[#DEBUG END]]
		return 'FILE_LOCKED'
	else
		local DB_DST = SQLite3_Open(szPath)
		local DB_SRC = SQLite3_Open(szMalformedPath)
		if DB_DST and DB_SRC then
			DuplicateDatabase(DB_SRC, DB_DST, szCaption)
			DB_SRC:Release()
			CPath.DelFile(szMalformedPath)
			--[[#DEBUG BEGIN]]
			LIB.Debug(szCaption, 'Fixing malformed database finished...', DEBUG_LEVEL.LOG)
			--[[#DEBUG END]]
			return 'SUCCESS', DB_DST
		elseif not DB_SRC then
			--[[#DEBUG BEGIN]]
			LIB.Debug(szCaption, 'Connect malformed database failed...', DEBUG_LEVEL.LOG)
			--[[#DEBUG END]]
			return 'TRANSFER_FAILED', DB_DST
		end
	end
end

function LIB.ConnectDatabase(szCaption, oPath, fnAction)
	-- �����������ݿ�
	local szPath = LIB.FormatPath(oPath)
	--[[#DEBUG BEGIN]]
	LIB.Debug(szCaption, 'Connect database: ' .. szPath, DEBUG_LEVEL.LOG)
	--[[#DEBUG END]]
	local DB = SQLite3_Open(szPath)
	if not DB then
		-- ������ֱ��������ԭʼ�ļ�����������
		if IsLocalFileExist(szPath) and RenameDatabase(szCaption, szPath) then
			DB = SQLite3_Open(szPath)
		end
		if not DB then
			LIB.Debug(szCaption, 'Cannot connect to database!!!', DEBUG_LEVEL.ERROR)
			if fnAction then
				fnAction()
			end
			return
		end
	end

	-- �������ݿ�������
	local aRes = DB:Execute('PRAGMA QUICK_CHECK')
	if Get(aRes, {1, 'integrity_check'}) == 'ok' then
		if fnAction then
			fnAction(DB)
		end
		return DB
	else
		-- ��¼������־
		LIB.Debug(szCaption, 'Malformed database detected...', DEBUG_LEVEL.ERROR)
		for _, rec in ipairs(aRes or {}) do
			LIB.Debug(szCaption, EncodeLUAData(rec), DEBUG_LEVEL.ERROR)
		end
		DB:Release()
		-- ׼�������޸�
		if fnAction then
			LIB.Confirm(_L('%s Database is malformed, do you want to repair database now? Repair database may take a long time and cause a disconnection.', szCaption), function()
				LIB.Confirm(_L['DO NOT KILL PROCESS BY FORCE, OR YOUR DATABASE MAY GOT A DAMAE, PRESS OK TO CONTINUE.'], function()
					local szStatus, DB = ConnectMalformedDatabase(szCaption, szPath)
					if szStatus == 'FILE_LOCKED' then
						LIB.Alert(_L('Database file locked, repair database failed! : %s', szPath))
					else
						LIB.Alert(_L('%s Database repair finished!', szCaption))
					end
					fnAction(DB)
				end)
			end)
		else
			return select(2, ConnectMalformedDatabase(szCaption, szPath))
		end
	end
end
end

function LIB.GetAccount()
	if Login_GetAccount then
		return Login_GetAccount()
	end
	if GetUserAccount then
		return GetUserAccount()
	end
	local szAccount
	local hFrame = Wnd.OpenWindow('LoginPassword')
	if hFrame then
		local hEdit = hFrame:Lookup('WndPassword/Edit_Account')
		if hEdit then
			szAccount = hEdit:GetText()
		end
		Wnd.CloseWindow(hFrame)
	end
	return szAccount
end

function LIB.OpenBrowser(szAddr)
	OpenBrowser(szAddr)
end

function LIB.ArrayToObject(arr)
	if not arr then
		return
	end
    local t = {}
	for k, v in pairs(arr) do
		if IsTable(v) and v[1] then
			t[v[1]] = v[2]
		else
			t[v] = true
		end
    end
    return t
end

function LIB.FlipObjectKV(obj)
	local t = {}
	for k, v in pairs(obj) do
		t[v] = k
	end
	return t
end

-- Global exports
do
local PRESETS = {
	UIEvent = LIB.ArrayToObject({
		'OnFrameCreate',
		'OnFrameDestroy',
		'OnFrameBreathe',
		'OnFrameRender',
		'OnFrameDragEnd',
		'OnFrameDragSetPosEnd',
		'OnEvent',
		'OnSetFocus',
		'OnKillFocus',
		'OnItemLButtonDown',
		'OnItemMButtonDown',
		'OnItemRButtonDown',
		'OnItemLButtonUp',
		'OnItemMButtonUp',
		'OnItemRButtonUp',
		'OnItemLButtonClick',
		'OnItemMButtonClick',
		'OnItemRButtonClick',
		'OnItemMouseEnter',
		'OnItemMouseLeave',
		'OnItemRefreshTip',
		'OnItemMouseWheel',
		'OnItemLButtonDrag',
		'OnItemLButtonDragEnd',
		'OnLButtonDown',
		'OnLButtonUp',
		'OnLButtonClick',
		'OnLButtonHold',
		'OnMButtonDown',
		'OnMButtonUp',
		'OnMButtonClick',
		'OnMButtonHold',
		'OnRButtonDown',
		'OnRButtonUp',
		'OnRButtonClick',
		'OnRButtonHold',
		'OnMouseEnter',
		'OnMouseLeave',
		'OnScrollBarPosChanged',
		'OnEditChanged',
		'OnEditSpecialKeyDown',
		'OnCheckBoxCheck',
		'OnCheckBoxUncheck',
		'OnDragButton',
		'OnDragButtonBegin',
		'OnDragButtonEnd',
		'OnActivePage',
	}),
}
function LIB.GeneGlobalNS(options)
	local exports = Get(options, 'exports', {})
	for _, export in ipairs(exports) do
		if not export.presets then
			export.presets = {}
		end
		if export.preset then
			insert(export.presets, export.preset)
			export.preset = nil
		end
		for i, s in ipairs_r(export.presets) do
			if not PRESETS[s] then
				remove(export.presets, i)
			end
		end
	end
	local function getter(_, k)
		local found, v, trigger, getter = false
		for _, export in ipairs(exports) do
			trigger = Get(export, {'triggers', k})
			if trigger then
				trigger(k)
			end
			if not found then
				getter, found = Get(export, {'getters', k})
				if getter then
					v = getter(k)
				end
			end
			if not found then
				v, found = Get(export, {'fields', k})
				if found then
					if export.root and not IsNil(v) then
						v = export.root[k]
					end
				else -- if not found
					for _, presetName in ipairs(export.presets) do
						local presetKeys = PRESETS[presetName]
						if presetKeys and presetKeys[k] then
							if IsFunction(export.root[k]) then
								v = export.root[k]
								found = true
								break
							end
						end
					end
				end
			end
			if found then
				return v
			end
		end
	end

	local imports = Get(options, 'imports', {})
	local function setter(_, k, v)
		local found, trigger, setter, res = false
		for _, import in ipairs(imports) do
			trigger = Get(import, {'triggers', k})
			if IsTable(trigger) and IsFunction(trigger[1]) then
				trigger[1](k, v)
			end
			if not found then
				setter, found = Get(import, {'setters', k})
				if setter then
					setter(k, v)
					found = true
				end
			end
			if not found then
				res, found = Get(import, {'fields', k})
				if res and import.root then
					import.root[k] = v
				end
			end
			if IsTable(trigger) and IsFunction(trigger[2]) then
				trigger[2](k, v)
			elseif IsFunction(trigger) then
				trigger(k, v)
			end
			if found then
				return
			end
		end
	end
	return setmetatable({}, { __index = getter, __newindex = setter })
end
end

function LIB.EditBox_AppendLinkPlayer(szName)
	local edit = LIB.GetChatInput()
	edit:InsertObj('['.. szName ..']', { type = 'name', text = '['.. szName ..']', name = szName })
	Station.SetFocusWindow(edit)
	return true
end

function LIB.EditBox_AppendLinkItem(dwID)
	local item = GetItem(dwID)
	if not item then
		return false
	end
	local szName = '[' .. LIB.GetItemNameByItem(item) ..']'
	local edit = LIB.GetChatInput()
	edit:InsertObj(szName, { type = 'item', text = szName, item = item.dwID })
	Station.SetFocusWindow(edit)
	return true
end

-------------------------------------------
-- ������� API
-------------------------------------------

function LIB.GVoiceBase_IsOpen(...)
	if IsFunction(_G.GVoiceBase_IsOpen) then
		return _G.GVoiceBase_IsOpen(...)
	end
	return false
end

function LIB.GVoiceBase_GetMicState(...)
	if IsFunction(_G.GVoiceBase_GetMicState) then
		return _G.GVoiceBase_GetMicState(...)
	end
	return MIC_STATE.CLOSE_NOT_IN_ROOM
end

function LIB.GVoiceBase_SwitchMicState(...)
	if IsFunction(_G.GVoiceBase_SwitchMicState) then
		return _G.GVoiceBase_SwitchMicState(...)
	end
end

function LIB.GVoiceBase_CheckMicState(...)
	if IsFunction(_G.GVoiceBase_CheckMicState) then
		return _G.GVoiceBase_CheckMicState(...)
	end
end

function LIB.GVoiceBase_GetSpeakerState(...)
	if IsFunction(_G.GVoiceBase_GetSpeakerState) then
		return _G.GVoiceBase_GetSpeakerState(...)
	end
	return CONSTANT.SPEAKER_STATE.CLOSE
end

function LIB.GVoiceBase_SwitchSpeakerState(...)
	if IsFunction(_G.GVoiceBase_SwitchSpeakerState) then
		return _G.GVoiceBase_SwitchSpeakerState(...)
	end
end

function LIB.GVoiceBase_GetSaying(...)
	if IsFunction(_G.GVoiceBase_GetSaying) then
		return _G.GVoiceBase_GetSaying(...)
	end
	return {}
end

function LIB.GVoiceBase_IsMemberSaying(...)
	if IsFunction(_G.GVoiceBase_IsMemberSaying) then
		return _G.GVoiceBase_IsMemberSaying(...)
	end
	return false
end

function LIB.GVoiceBase_IsMemberForbid(...)
	if IsFunction(_G.GVoiceBase_IsMemberForbid) then
		return _G.GVoiceBase_IsMemberForbid(...)
	end
	return false
end

function LIB.GVoiceBase_ForbidMember(...)
	if IsFunction(_G.GVoiceBase_ForbidMember) then
		return _G.GVoiceBase_ForbidMember(...)
	end
end

if _G.Login_GetTimeOfFee then
	function LIB.GetTimeOfFee()
		-- [���ͻ���ʹ��]�����ʺ��¿���ֹʱ�䣬�Ƶ�ʣ������������ʣ���������ܽ�ֹʱ��
		local dwMonthEndTime, nPointLeftTime, nDayLeftTime, dwEndTime = _G.Login_GetTimeOfFee()
		if dwMonthEndTime <= 1229904000 then
			dwMonthEndTime = 0
		end
		return dwEndTime, dwMonthEndTime, nPointLeftTime, nDayLeftTime
	end
else
	local bInit, dwMonthEndTime, dwPointEndTime, dwDayEndTime = false, 0, 0, 0
	local frame = Station.Lookup('Lowest/Scene')
	local data = frame and frame[NSFormatString('{$NS}_TimeOfFee')]
	if data then
		bInit, dwMonthEndTime, dwPointEndTime, dwDayEndTime = true, unpack(data)
	else
		LIB.RegisterMsgMonitor('MSG_SYS.LIB#GetTimeOfFee', function(szChannel, szMsg)
			-- �㿨ʣ��ʱ��Ϊ��558Сʱ41��33��
			local szHour, szMinute, szSecond = szMsg:match(_L['Point left time: (%d+)h(%d+)m(%d+)s'])
			if szHour and szMinute and szSecond then
				local dwTime = GetCurrentTime()
				bInit = true
				dwPointEndTime = dwTime + tonumber(szHour) * 3600 + tonumber(szMinute) * 60 + tonumber(szSecond)
			end
			-- ����ʱ���ֹ����xxxx/xx/xx xx:xx
			local szYear, szMonth, szDay, szHour, szMinute = szMsg:match(_L['Month time to: (%d+)y(%d+)m(%d+)d (%d+)h(%d+)m'])
			if szYear and szMonth and szDay and szHour and szMinute then
				bInit = true
				dwMonthEndTime = LIB.DateToTime(szYear, szMonth, szDay, szHour, szMinute, 0)
			end
			if bInit then
				local dwTime = GetCurrentTime()
				if dwMonthEndTime > dwTime then -- ���������¿� ���㿨����ʱ����Ҫ�����¿�ʱ��
					dwPointEndTime = dwPointEndTime + dwMonthEndTime - dwTime
				end
				local frame = Station.Lookup('Lowest/Scene')
				if frame then
					frame[NSFormatString('{$NS}_TimeOfFee')] = {dwMonthEndTime, dwPointEndTime, dwDayEndTime}
				end
				LIB.RegisterMsgMonitor('MSG_SYS.LIB#GetTimeOfFee', false)
			end
		end)
	end
	function LIB.GetTimeOfFee()
		local dwTime = GetCurrentTime()
		local dwEndTime = max(dwMonthEndTime, dwPointEndTime, dwDayEndTime)
		return dwEndTime, dwMonthEndTime, max(dwPointEndTime - dwTime, 0), max(dwDayEndTime - dwTime, 0)
	end
end

do
local KEY = wgsub(PACKET_INFO.ROOT, '\\', '/'):lower()
local FILE_PATH = {'temporary/lua_error.jx3dat', PATH_TYPE.GLOBAL}
local LAST_ERROR_MSG = LIB.LoadLUAData(FILE_PATH, { passphrase = false }) or {}
local ERROR_MSG = {}
local function SaveErrorMessage()
	LIB.SaveLUAData(FILE_PATH, ERROR_MSG, { passphrase = false, crc = false, indent = '\t' })
end
RegisterEvent('CALL_LUA_ERROR', function()
	local szMsg = arg0
	local szMsgL = wgsub(arg0:lower(), '\\', '/')
	if wfind(szMsgL, KEY) then
		insert(ERROR_MSG, szMsg)
	end
	SaveErrorMessage()
end)
function LIB.GetAddonErrorMessage()
	local szMsg = concat(LAST_ERROR_MSG, '\n\n')
	if not IsEmpty(szMsg) then
		szMsg = szMsg .. '\n\n'
	end
	return szMsg .. concat(ERROR_MSG, '\n\n')
end
LIB.RegisterInit('LIB#AddonErrorMessage', SaveErrorMessage)
end

-----------------------------------------------
-- �¼������Զ����յĻ������
-----------------------------------------------
function LIB.CreateCache(szNameMode, aEvent)
	-- �������
	local szName, szMode
	if IsString(szNameMode) then
		local nPos = StringFindW(szNameMode, '.')
		if nPos then
			szName = sub(szNameMode, 1, nPos - 1)
			szMode = sub(szNameMode, nPos + 1)
		else
			szName = szNameMode
		end
	end
	if IsString(aEvent) then
		aEvent = {aEvent}
	elseif IsArray(aEvent) then
		aEvent = Clone(aEvent)
	else
		aEvent = {'LOADING_ENDING'}
	end
	local szKey = 'LIB#CACHE#' .. tostring(aEvent):sub(8)
	if szName then
		szKey = szKey .. '#' .. szName
	end
	-- ���������Լ��¼�����
	local t = {}
	local mt = { __mode = szMode }
	local function Flush()
		for k, _ in pairs(t) do
			t[k] = nil
		end
	end
	local function Register()
		for _, szEvent in ipairs(aEvent) do
			LIB.RegisterEvent(szEvent .. '.' .. szKey, Flush)
		end
	end
	local function Unregister()
		for _, szEvent in ipairs(aEvent) do
			LIB.RegisterEvent(szEvent .. '.' .. szKey, false)
		end
	end
	function mt.__call(_, k)
		if k == 'flush' then
			Flush()
		elseif k == 'register' then
			Register()
		elseif k == 'unregister' then
			Unregister()
		end
	end
	Register()
	return setmetatable(t, mt)
end

-----------------------------------------------
-- ����תƴ��
-----------------------------------------------
do local PINYIN, PINYIN_CONSONANT
function LIB.Han2Pinyin(szText)
	if not IsString(szText) then
		return
	end
	if not PINYIN then
		PINYIN = LIB.LoadLUAData(PACKET_INFO.FRAMEWORK_ROOT .. 'data/pinyin/{$lang}.jx3dat', { passphrase = false })
		local tPinyinConsonant = {}
		for c, v in pairs(PINYIN) do
			local a, t = {}, {}
			for _, s in ipairs(v) do
				s = s:sub(1, 1)
				if not t[s] then
					t[s] = true
					insert(a, s)
				end
			end
			tPinyinConsonant[c] = a
		end
		PINYIN_CONSONANT = tPinyinConsonant
	end
	local aText = LIB.SplitString(szText, '')
	local aFull, nFullCount = {''}, 1
	local aConsonant, nConsonantCount = {''}, 1
	for _, szChar in ipairs(aText) do
		local aCharPinyin = PINYIN[szChar]
		if aCharPinyin and #aCharPinyin > 0 then
			for i = 2, #aCharPinyin do
				for j = 1, nFullCount do
					insert(aFull, aFull[j] .. aCharPinyin[i])
				end
			end
			for j = 1, nFullCount do
				aFull[j] = aFull[j] .. aCharPinyin[1]
			end
			nFullCount = nFullCount * #aCharPinyin
		else
			for j = 1, nFullCount do
				aFull[j] = aFull[j] .. szChar
			end
		end
		local aCharPinyinConsonant = PINYIN_CONSONANT[szChar]
		if aCharPinyinConsonant and #aCharPinyinConsonant > 0 then
			for i = 2, #aCharPinyinConsonant do
				for j = 1, nConsonantCount do
					insert(aConsonant, aConsonant[j] .. aCharPinyinConsonant[i])
				end
			end
			for j = 1, nConsonantCount do
				aConsonant[j] = aConsonant[j] .. aCharPinyinConsonant[1]
			end
			nConsonantCount = nConsonantCount * #aCharPinyinConsonant
		else
			for j = 1, nConsonantCount do
				aConsonant[j] = aConsonant[j] .. szChar
			end
		end
	end
	return aFull, aConsonant
end
end
