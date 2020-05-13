--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : ϵͳ������
-- @author   : ���� @˫���� @׷����Ӱ
-- @modifier : Emil Zhai (root@derzh.com)
-- @copyright: Copyright (c) 2013 EMZ Kingsoft Co., Ltd.
--------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- these global functions are accessed all the time by the event handler
-- so caching them is worth the effort
---------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local ipairs, pairs, next, pcall = ipairs, pairs, next, pcall
local sub, len, format, rep = string.sub, string.len, string.format, string.rep
local find, byte, char, gsub = string.find, string.byte, string.char, string.gsub
local type, tonumber, tostring = type, tonumber, tostring
local huge, pi, random = math.huge, math.pi, math.random
local min, max, floor, ceil = math.min, math.max, math.floor, math.ceil
local pow, sqrt, sin, cos, tan = math.pow, math.sqrt, math.sin, math.cos, math.tan
local insert, remove, concat, sort = table.insert, table.remove, table.concat, table.sort
local pack, unpack = table.pack or function(...) return {...} end, table.unpack or unpack
-- jx3 apis caching
local wsub, wlen, wfind = wstring.sub, wstring.len, wstring.find
local GetTime, GetLogicFrameCount = GetTime, GetLogicFrameCount
local GetClientPlayer, GetPlayer, GetNpc = GetClientPlayer, GetPlayer, GetNpc
local GetClientTeam, UI_GetClientPlayerID = GetClientTeam, UI_GetClientPlayerID
local Get = MY.Get
local IsNil, IsBoolean, IsEmpty, RandomChild = MY.IsNil, MY.IsBoolean, MY.IsEmpty, MY.RandomChild
local IsNumber, IsString, IsTable, IsFunction = MY.IsNumber, MY.IsString, MY.IsTable, MY.IsFunction
---------------------------------------------------------------------------------------------------
MY = MY or {}
local _L, _C = MY.LoadLangPack(), {}

-- ��ȡ��Ϸ����
function MY.GetLang()
	local _, _, lang = GetVersion()
	return lang
end

-- ��ȡ��������״̬
do
local SHIELDED_VERSION = MY.GetLang() == 'zhcn' -- ���α���з�Ĺ��ܣ��������ã�
function MY.IsShieldedVersion(bShieldedVersion)
	if bShieldedVersion == nil then
		return SHIELDED_VERSION
	else
		SHIELDED_VERSION = bShieldedVersion
		if not bShieldedVersion and MY.IsPanelOpened() then
			MY.ReopenPanel()
		end
		FireUIEvent('MY_SHIELDED_VERSION')
	end
end
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
MY_DATA_PATH = SetmetaReadonly({
	NORMAL = 0,
	ROLE   = 1,
	GLOBAL = 2,
	SERVER = 3,
})
if IsLocalFileExist(MY.GetAddonInfo().szRoot .. '@DATA/') then
	CPath.Move(MY.GetAddonInfo().szRoot .. '@DATA/', MY.GetAddonInfo().szInterfaceRoot .. 'MY#DATA/')
end

-- ��ʽ�������ļ�·�����滻$uid��$lang��$server�Լ���ȫ���·����
-- (string) MY.GetLUADataPath(oFilePath)
function MY.FormatPath(oFilePath, tParams)
	if not tParams then
		tParams = {}
	end
	local szFilePath, ePathType
	if type(oFilePath) == 'table' then
		szFilePath, ePathType = unpack(oFilePath)
	else
		szFilePath, ePathType = oFilePath, MY_DATA_PATH.NORMAL
	end
	-- Unified the directory separator
	szFilePath = string.gsub(szFilePath, '\\', '/')
	-- if it's relative path then complete path with '/MY@DATA/'
	if szFilePath:sub(1, 2) ~= './' and szFilePath:sub(2, 3) ~= ':/' then
		if ePathType == MY_DATA_PATH.GLOBAL then
			szFilePath = '!all-users@$lang/' .. szFilePath
		elseif ePathType == MY_DATA_PATH.ROLE then
			szFilePath = '$uid@$lang/' .. szFilePath
		elseif ePathType == MY_DATA_PATH.SERVER then
			szFilePath = '#$relserver@$lang/' .. szFilePath
		end
		szFilePath = MY.GetAddonInfo().szInterfaceRoot .. 'MY#DATA/' .. szFilePath
	end
	-- if exist $uid then add user role identity
	if string.find(szFilePath, '%$uid') then
		szFilePath = szFilePath:gsub('%$uid', tParams['uid'] or MY.GetClientUUID())
	end
	-- if exist $name then add user role identity
	if string.find(szFilePath, '%$name') then
		szFilePath = szFilePath:gsub('%$name', tParams['name'] or MY.GetClientInfo().szName or MY.GetClientUUID())
	end
	-- if exist $lang then add language identity
	if string.find(szFilePath, '%$lang') then
		szFilePath = szFilePath:gsub('%$lang', tParams['lang'] or string.lower(MY.GetLang()))
	end
	-- if exist $version then add version identity
	if string.find(szFilePath, '%$version') then
		szFilePath = szFilePath:gsub('%$version', tParams['version'] or select(2, GetVersion()))
	end
	-- if exist $date then add date identity
	if string.find(szFilePath, '%$date') then
		szFilePath = szFilePath:gsub('%$date', tParams['date'] or MY.FormatTime('yyyyMMdd', GetCurrentTime()))
	end
	-- if exist $server then add server identity
	if string.find(szFilePath, '%$server') then
		szFilePath = szFilePath:gsub('%$server', tParams['server'] or ((MY.GetServer()):gsub('[/\\|:%*%?"<>]', '')))
	end
	-- if exist $relserver then add relserver identity
	if string.find(szFilePath, '%$relserver') then
		szFilePath = szFilePath:gsub('%$relserver', tParams['relserver'] or ((MY.GetRealServer()):gsub('[/\\|:%*%?"<>]', '')))
	end
	local rootPath = GetRootPath():gsub('\\', '/')
	if szFilePath:find(rootPath) == 1 then
		szFilePath = szFilePath:gsub(rootPath, '.')
	end
	return szFilePath
end

function MY.GetRelativePath(oPath, oRoot)
	local szPath = MY.FormatPath(oPath)
	local szRoot = MY.FormatPath(oRoot)
	if wstring.find(szPath:lower(), szRoot:lower()) ~= 1 then
		return
	end
	return szPath:sub(#szRoot + 1)
end

function MY.GetLUADataPath(oFilePath)
	local szFilePath = MY.FormatPath(oFilePath)
	-- ensure has file name
	if string.sub(szFilePath, -1) == '/' then
		szFilePath = szFilePath .. 'data'
	end
	-- ensure file ext name
	if string.sub(szFilePath, -7):lower() ~= '.jx3dat' then
		szFilePath = szFilePath .. '.jx3dat'
	end
	return szFilePath
end

function MY.ConcatPath(...)
	local aPath = {...}
	local szPath = ''
	for _, s in ipairs(aPath) do
		s = tostring(s):gsub('^[\/]+', '')
		if s ~= '' then
			szPath = szPath:gsub('[\/]+$', '')
			if szPath ~= '' then
				szPath = szPath .. '/'
			end
			szPath = szPath .. s
		end
	end
	return szPath
end

-- ���������ļ�
-- MY.SaveLUAData(oFilePath, tData, indent, crc)
-- oFilePath           �����ļ�·��(1)
-- tData               Ҫ���������
-- indent              �����ļ�����
-- crc                 �Ƿ����CRCУ��ͷ��Ĭ��true��
-- nohashlevels        ��LIST�����ڲ㣨�Ż�����дЧ�ʣ�
-- (1)�� ��·��Ϊ����·��ʱ(��б�ܿ�ͷ)��������
--       ��·��Ϊ���·��ʱ ����ڲ��`MY@DATA`Ŀ¼
--       ���Դ����{szPath, ePathType}
function MY.SaveLUAData(oFilePath, tData, indent, crc)
	local nStartTick = GetTickCount()
	-- format uri
	local szFilePath = MY.GetLUADataPath(oFilePath)
	-- save data
	local data = SaveLUAData(szFilePath, tData, indent, crc or false)
	-- performance monitor
	MY.Debug({_L('%s saved during %dms.', szFilePath, GetTickCount() - nStartTick)}, 'PMTool', MY_DEBUG.PMLOG)
	return data
end

-- ���������ļ���
-- MY.LoadLUAData(oFilePath)
-- oFilePath           �����ļ�·��(1)
-- (1)�� ��·��Ϊ./��ͷʱ��������
--       ��·��Ϊ����ʱ ����ڲ��`MY@DATA`Ŀ¼
--       ���Դ����{szPath, ePathType}
function MY.LoadLUAData(oFilePath)
	local nStartTick = GetTickCount()
	-- format uri
	local szFilePath = MY.GetLUADataPath(oFilePath)
	-- load data
	local data = LoadLUAData(szFilePath)
	-- performance monitor
	MY.Debug({_L('%s loaded during %dms.', szFilePath, GetTickCount() - nStartTick)}, 'PMTool', MY_DEBUG.PMLOG)
	return data
end


-- ע���û��������ݣ�֧��ȫ�ֱ����������
-- (void) MY.RegisterCustomData(string szVarPath[, number nVersion])
function MY.RegisterCustomData(szVarPath, nVersion, szDomain)
	szDomain = szDomain or 'Role'
	if _G and type(_G[szVarPath]) == 'table' then
		for k, _ in pairs(_G[szVarPath]) do
			RegisterCustomData(szDomain .. '/' .. szVarPath .. '.' .. k, nVersion)
		end
	else
		RegisterCustomData(szDomain .. '/' .. szVarPath, nVersion)
	end
end

--szName [, szDataFile]
function MY.RegisterUserData(szName, szFileName, onLoad)

end

-- Format data's structure as struct descripted.
do
local function clone(var)
	if type(var) == 'table' then
		local ret = {}
		for k, v in pairs(var) do
			ret[clone(k)] = clone(v)
		end
		return ret
	else
		return var
	end
end
MY.FullClone = clone

local defaultParams = { keepNewChild = false }
local function FormatDataStructure(data, struct, assign, metaFlag)
	if metaFlag == nil then
		metaFlag = '__META__'
	end
	-- ��׼������
	local params = setmetatable({}, defaultParams)
	local structTypes, defaultData, defaultDataType
	local keyTemplate, childTemplate, arrayTemplate, dictionaryTemplate
	if type(struct) == 'table' and struct[1] == metaFlag then
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
			data = clone(data)
		end
		local keys = {}
		-- ���������Ǳ���META��Ϣ�ж�������Ԫ��KEYģ�� ��ݹ�����Ԫ��KEY����Ԫ��KEYģ��
		if dataType == 'table' and keyTemplate then
			for k, v in pairs(data) do
				local k1 = FormatDataStructure(k, keyTemplate)
				if k1 ~= k then
					if k1 ~= nil then
						data[k1] = data[k]
					end
					data[k] = nil
				end
			end
		end
		-- ���������Ǳ���META��Ϣ�ж�������Ԫ��ģ�� ��ݹ�����Ԫ������Ԫ��ģ��
		if dataType == 'table' and childTemplate then
			for i, v in pairs(data) do
				keys[i] = true
				data[i] = FormatDataStructure(data[i], childTemplate)
			end
		end
		-- ���������Ǳ���META��Ϣ�ж������б���Ԫ��ģ�� ��ݹ�����Ԫ�����б���Ԫ��ģ��
		if dataType == 'table' and arrayTemplate then
			for i, v in pairs(data) do
				if type(i) == 'number' then
					keys[i] = true
					data[i] = FormatDataStructure(data[i], arrayTemplate)
				end
			end
		end
		-- ���������Ǳ���META��Ϣ�ж����˹�ϣ��Ԫ��ģ�� ��ݹ�����Ԫ�����ϣ��Ԫ��ģ��
		if dataType == 'table' and dictionaryTemplate then
			for i, v in pairs(data) do
				if type(i) ~= 'number' then
					keys[i] = true
					data[i] = FormatDataStructure(data[i], dictionaryTemplate)
				end
			end
		end
		-- ���������Ǳ���Ĭ������Ҳ�Ǳ� ��ݹ�����Ԫ����Ĭ����Ԫ��
		if dataType == 'table' and defaultDataType == 'table' then
			for k, v in pairs(defaultData) do
				data[k] = FormatDataStructure(data[k], defaultData[k])
			end
			if not params.keepNewChild then
				for k, v in pairs(data) do
					if defaultData[k] == nil and not keys[k] then
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
				data[k] = FormatDataStructure(nil, v)
			end
		else -- Ĭ��ֵ���Ǳ� ֱ�ӿ�¡����
			data = clone(defaultData)
		end
	end
	return data
end
MY.FormatDataStructure = FormatDataStructure
end

function MY.SetGlobalValue(szVarPath, Val)
	local t = MY.SplitString(szVarPath, '.')
	local tab = _G
	for k, v in ipairs(t) do
		if type(tab[v]) == 'nil' then
			tab[v] = {}
		end
		if k == #t then
			tab[v] = Val
		end
		tab = tab[v]
	end
end

function MY.GetGlobalValue(szVarPath)
	local tVariable = _G
	for szIndex in string.gmatch(szVarPath, '[^%.]+') do
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
function MY.CreateDataRoot(ePathType)
	if CREATED[ePathType] then
		return
	end
	CREATED[ePathType] = true
	-- ����Ŀ¼
	if ePathType == MY_DATA_PATH.ROLE then
		CPath.MakeDir(MY.FormatPath({'$name/', MY_DATA_PATH.ROLE}))
	end
	-- �汾����ʱɾ���ɵ���ʱĿ¼
	if IsLocalFileExist(MY.FormatPath({'temporary/', ePathType}))
	and not IsLocalFileExist(MY.FormatPath({'temporary/$version', ePathType})) then
		CPath.DelDir(MY.FormatPath({'temporary/', ePathType}))
	end
	CPath.MakeDir(MY.FormatPath({'temporary/$version/', ePathType}))
	CPath.MakeDir(MY.FormatPath({'audio/', ePathType}))
	CPath.MakeDir(MY.FormatPath({'cache/', ePathType}))
	CPath.MakeDir(MY.FormatPath({'config/', ePathType}))
	CPath.MakeDir(MY.FormatPath({'export/', ePathType}))
	CPath.MakeDir(MY.FormatPath({'userdata/', ePathType}))
end
end

do
local SOUND_ROOT = MY.GetAddonInfo().szFrameworkRoot .. 'audio/'
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

function MY.GetSoundMenu(fnAction, tCheck, bMultiple)
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

function MY.GetSoundName(dwID)
	if not GeneCache() then
		return
	end
	local tSound = CACHE[dwID]
	if not tSound then
		return
	end
	return tSound.szName
end

function MY.GetSoundPath(dwID)
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
-- MY.PlaySound([nType, ]szFilePath[, szCustomPath])
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
function MY.PlaySound(nType, szFilePath, szCustomPath)
	if not IsNumber(nType) then
		nType, szFilePath, szCustomPath = SOUND.UI_SOUND, nType, szFilePath
	end
	if not szCustomPath then
		szCustomPath = szFilePath
	end
	-- �����Զ�������
	if szCustomPath ~= '' then
		for _, ePathType in ipairs({
			MY_DATA_PATH.ROLE,
			MY_DATA_PATH.GLOBAL,
		}) do
			local szPath = MY.FormatPath({ 'audio/' .. szCustomPath, ePathType })
			if IsFileExist(szPath) then
				return PlaySound(nType, szPath)
			end
		end
	end
	-- ����Ĭ������
	local szPath = string.gsub(szFilePath, '\\', '/')
	if string.sub(szPath, 1, 2) ~= './' then
		szPath = MY.GetAddonInfo().szFrameworkRoot .. 'audio/' .. szPath
	end
	if not IsFileExist(szPath) then
		return
	end
	PlaySound(nType, szPath)
end
-- ����ע������
MY.RegisterInit('MYLIB#INITDATA', function()
	local t = MY.LoadLUAData({'config/initial.jx3dat', MY_DATA_PATH.GLOBAL})
	if t then
		for v_name, v_data in pairs(t) do
			MY.SetGlobalValue(v_name, v_data)
		end
	end
end)

-- ##################################################################################################
--   # # # # # # # # # # #       #       #           #           #                     #     #
--   #                   #       #       # # # #       #   # # # # # # # #             #       #
--   #                   #     #       #       #                 #           # # # # # # # # # # #
--   # #       #       # #   #     # #   #   #               # # # # # #               #
--   #   #   #   #   #   #   # # #         #         # #         #             #       # #     #
--   #     #       #     #       #       #   #         #   # # # # # # # #       #     # #   #
--   #     #       #     #     #     # #       # #     #     #         #             # #   #
--   #   #   #   #   #   #   # # # #   # # # # #       #     # # # # # #           #   #   #
--   # #       #       # #             #       #       #     #         #         #     #     #
--   #                   #       # #   #       #       #     # # # # # #     # #       #       #
--   #                   #   # #       # # # # #       # #   #         #               #         #
--   #               # # #             #       #       #     #       # #             # #
-- ##################################################################################################
-- (void) MY.RemoteRequest(string szUrl, func fnAction)       -- ����Զ�� HTTP ����
-- szUrl        -- ��������� URL������ http:// �� https://��
-- fnAction     -- ������ɺ�Ļص��������ص�ԭ�ͣ�function(szTitle, szContent)]]
function MY.RemoteRequest(szUrl, fnSuccess, fnError, nTimeout)
	local settings = {
		url     = szUrl,
		success = fnSuccess,
		error   = fnError,
		timeout = nTimeout,
	}
	return MY.Ajax(settings)
end

local function pcall_this(context, fn, ...)
	local _this
	if context then
		_this, this = this, context
	end
	local rtc = {pcall(fn, ...)}
	if context then
		this = _this
	end
	return unpack(rtc)
end

do
local MY_RRWP_FREE = {}
local MY_RRWC_FREE = {}
local MY_CALL_AJAX = {}
local MY_AJAX_TAG = 'MY_AJAX#'
local l_ajaxsettingsmeta = {
	__index = {
		type = 'get',
		driver = 'curl',
		timeout = 60000,
		charset = 'utf8',
	}
}

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

local function serialize(data)
	local t = {}
	EncodePostData(data, t, '')
	local text = concat(t)
	return text
end

local CURL_HttpPost = CURL_HttpPostEx or CURL_HttpPost
function MY.Ajax(settings)
	assert(settings and settings.url)
	setmetatable(settings, l_ajaxsettingsmeta)

	local url, data = settings.url, settings.data
	if settings.charset == 'utf8' then
		url  = MY.ConvertToUTF8(url)
		data = MY.ConvertToUTF8(data)
	end

	local ssl = url:sub(1, 6) == 'https:'
	local method, payload = unpack(MY.SplitString(settings.type, '/'))
	if (method == 'get' or method == 'delete') and data then
		if not url:find('?') then
			url = url .. '?'
		elseif url:sub(-1) ~= '&' then
			url = url .. '&'
		end
		url, data = url .. serialize(data), nil
	end
	assert(method == 'post' or method == 'get' or method == 'put' or method == 'delete', '[MY_AJAX] Unknown http request type: ' .. method)

	if not settings.success then
		settings.success = function(html, status)
			MY.Debug({settings.url .. ' - SUCCESS'}, 'AJAX', MY_DEBUG.LOG)
		end
	end
	if not settings.error then
		settings.error = function(html, status, success)
			MY.Debug({settings.url .. ' - STATUS ' .. (success and status or 'failed')}, 'AJAX', MY_DEBUG.WARNING)
		end
	end

	if settings.driver == 'curl' then
		if not Curl_Create then
			return settings.error()
		end
		local curl = Curl_Create(url)
		if method == 'post' then
			curl:SetMethod('POST')
			if payload == 'json' then
				data = MY.JsonEncode(data)
				curl:AddHeader('Content-Type: application/json')
			else -- if payload == 'form' then
				data = MY.EncodePostData(data)
				curl:AddHeader('Content-Type: application/x-www-form-urlencoded')
			end
			curl:AddPostRawData(data)
		elseif method == 'get' then
			curl:AddHeader('Content-Type: application/x-www-form-urlencoded')
		end
		if settings.complete then
			curl:OnComplete(settings.complete)
		end
		curl:OnSuccess(settings.success)
		curl:OnError(settings.error)
		curl:SetConnTimeout(settings.timeout)
		curl:Perform()
	elseif settings.driver == 'webcef' then
		assert(method == 'get', '[MY_AJAX] Webcef only support get method, got ' .. method)
		local RequestID, hFrame
		local nFreeWebPages = #MY_RRWC_FREE
		if nFreeWebPages > 0 then
			RequestID = MY_RRWC_FREE[nFreeWebPages]
			hFrame = Station.Lookup('Lowest/MYRRWC_' .. RequestID)
			table.remove(MY_RRWC_FREE)
		end
		-- create page
		if not hFrame then
			RequestID = ('%X_%X'):format(GetTickCount(), math.floor(math.random() * 65536))
			hFrame = Wnd.OpenWindow(MY.GetAddonInfo().szFrameworkRoot .. 'ui/WndWebCef.ini', 'MYRRWC_' .. RequestID)
			hFrame:Hide()
		end
		local wWebCef = hFrame:Lookup('WndWebCef')

		-- bind callback function
		wWebCef.OnWebLoadEnd = function()
			-- local szUrl, szTitle, szContent = this:GetLocationURL(), this:GetLocationName(), this:GetDocument()
			-- MY.Debug({string.format('%s - %s', szTitle, szUrl)}, 'MYRRWC::OnDocumentComplete', MY_DEBUG.LOG)
			-- ע����ʱ����ʱ��
			MY.DelayCall('MYRRWC_TO_' .. RequestID, false)
			-- �ɹ��ص�����
			-- if settings.success then
			-- 	local status, err = pcall_this(settings.context, settings.success, settings, szContent)
			-- 	if not status then
			-- 		MY.Debug({err}, 'MYRRWC::OnDocumentComplete::Callback', MY_DEBUG.ERROR)
			-- 	end
			-- end
			table.insert(MY_RRWC_FREE, RequestID)
		end

		-- do with this remote request
		MY.Debug({settings.url}, 'MYRRWC', MY_DEBUG.LOG)
		-- register request timeout clock
		if settings.timeout > 0 then
			MY.DelayCall('MYRRWC_TO_' .. RequestID, settings.timeout, function()
				MY.Debug({settings.url}, 'MYRRWC::Timeout', MY_DEBUG.WARNING) -- log
				-- request timeout, call timeout function.
				if settings.error then
					local status, err = pcall_this(settings.context, settings.error, settings, 'timeout')
					if not status then
						MY.Debug({err}, 'MYRRWC::TIMEOUT', MY_DEBUG.ERROR)
					end
				end
				table.insert(MY_RRWC_FREE, RequestID)
			end)
		end

		-- start chrome navigate
		wWebCef:Navigate(url)
	elseif settings.driver == 'webbrowser' then
		assert(method == 'get', '[MY_AJAX] Webbrowser only support get method, got ' .. method)
		local RequestID, hFrame
		local nFreeWebPages = #MY_RRWP_FREE
		if nFreeWebPages > 0 then
			RequestID = MY_RRWP_FREE[nFreeWebPages]
			hFrame = Station.Lookup('Lowest/MYRRWP_' .. RequestID)
			table.remove(MY_RRWP_FREE)
		end
		-- create page
		if not hFrame then
			RequestID = ('%X_%X'):format(GetTickCount(), math.floor(math.random() * 65536))
			hFrame = Wnd.OpenWindow(MY.GetAddonInfo().szFrameworkRoot .. 'ui/WndWebPage.ini', 'MYRRWP_' .. RequestID)
			hFrame:Hide()
		end
		local wWebPage = hFrame:Lookup('WndWebPage')

		-- bind callback function
		wWebPage.OnDocumentComplete = function()
			local szUrl, szTitle, szContent = this:GetLocationURL(), this:GetLocationName(), this:GetDocument()
			if szUrl ~= szTitle or szContent ~= '' then
				MY.Debug({string.format('%s - %s', szTitle, szUrl)}, 'MYRRWP::OnDocumentComplete', MY_DEBUG.LOG)
				-- ע����ʱ����ʱ��
				MY.DelayCall('MYRRWP_TO_' .. RequestID, false)
				-- �ɹ��ص�����
				if settings.success then
					local status, err = pcall_this(settings.context, settings.success, settings, szContent)
					if not status then
						MY.Debug({err}, 'MYRRWP::OnDocumentComplete::Callback', MY_DEBUG.ERROR)
					end
				end
				table.insert(MY_RRWP_FREE, RequestID)
			end
		end

		-- do with this remote request
		MY.Debug({settings.url}, 'MYRRWP', MY_DEBUG.LOG)
		-- register request timeout clock
		if settings.timeout > 0 then
			MY.DelayCall('MYRRWP_TO_' .. RequestID, settings.timeout, function()
				MY.Debug({settings.url}, 'MYRRWP::Timeout', MY_DEBUG.WARNING) -- log
				-- request timeout, call timeout function.
				if settings.error then
					local status, err = pcall_this(settings.context, settings.error, settings, 'timeout')
					if not status then
						MY.Debug({err}, 'MYRRWP::TIMEOUT', MY_DEBUG.ERROR)
					end
				end
				table.insert(MY_RRWP_FREE, RequestID)
			end)
		end

		-- start ie navigate
		wWebPage:Navigate(url)
	else -- if settings.driver == 'origin' then
		local szKey = GetTickCount() * 100
		while MY_CALL_AJAX[MY_AJAX_TAG .. szKey] do
			szKey = szKey + 1
		end
		szKey = MY_AJAX_TAG .. szKey
		if method == 'post' then
			if not CURL_HttpPost then
				return settings.error()
			end
			CURL_HttpPost(szKey, url, data, ssl, settings.timeout)
		else
			if not CURL_HttpRqst then
				return settings.error()
			end
			CURL_HttpRqst(szKey, url, ssl, settings.timeout)
		end
		MY_CALL_AJAX['__addon_' .. szKey] = settings
	end
end

local function OnCurlRequestResult()
	local szKey        = arg0
	local bSuccess     = arg1
	local html         = arg2
	local dwBufferSize = arg3
	if MY_CALL_AJAX[szKey] then
		local settings = MY_CALL_AJAX[szKey]
		local method, payload = unpack(MY.SplitString(settings.type, '/'))
		local status = bSuccess and 200 or 500
		if settings.complete then
			local status, err = pcall(settings.complete, html, status, bSuccess or dwBufferSize > 0)
			if not status then
				MY.Debug({'CURL # ' .. settings.url .. ' - complete - PCALL ERROR - ' .. err}, MY_DEBUG.ERROR)
			end
		end
		if bSuccess then
			if settings.charset == 'utf8' and html ~= nil and CLIENT_LANG == 'zhcn' then
				html = UTF8ToAnsi(html)
			end
			-- if payload == 'json' then
			-- 	html = MY.JsonDecode(html)
			-- end
			local status, err = pcall(settings.success, html, status)
			if not status then
				MY.Debug({'CURL # ' .. settings.url .. ' - success - PCALL ERROR - ' .. err}, MY_DEBUG.ERROR)
			end
		else
			local status, err = pcall(settings.error, html, status, dwBufferSize ~= 0)
			if not status then
				MY.Debug({'CURL # ' .. settings.url .. ' - error - PCALL ERROR - ' .. err}, MY_DEBUG.ERROR)
			end
		end
		MY_CALL_AJAX[szKey] = nil
	end
end
MY.RegisterEvent('CURL_REQUEST_RESULT.AJAX', OnCurlRequestResult)
end

function MY.IsInDevMode()
	if IsDebugClient() then
		return true
	end
	local ip = select(7, GetUserServer())
	if ip:find('^192%.') or ip:find('^10%.') then
		return true
	end
	return false
end

do
-------------------------------
-- remote data storage online
-- bosslist (done)
-- focus list (working on)
-- chat blocklist (working on)
-------------------------------
-- �������ݰ汾��
local m_nStorageVer = {}
MY.BreatheCall('MYLIB#STORAGE_DATA', 200, function()
	if not MY.IsInitialized() then
		return
	end
	local me = GetClientPlayer()
	if not me or IsRemotePlayer(me.dwID) or not MY.GetTongName() then
		return
	end
	if MY.IsInDevMode() then
		return 0
	end
	m_nStorageVer = MY.LoadLUAData({'config/storageversion.jx3dat', MY_DATA_PATH.ROLE}) or {}
	MY.Ajax({
		type = 'post/json',
		url = 'http://data.jx3.derzh.com/api/storage',
		data = {
			data = MY.EncryptString(MY.ConvertToUTF8(MY.JsonEncode({
				g = me.GetGlobalID(), f = me.dwForceID, e = me.GetTotalEquipScore(),
				n = GetUserRoleName(), i = UI_GetClientPlayerID(), c = me.nCamp,
				S = MY.GetRealServer(1), s = MY.GetRealServer(2), r = me.nRoleType,
				_ = GetCurrentTime(), t = MY.GetTongName(),
			}))),
			lang = MY.GetLang(),
		},
		success = function(html, status)
			local data = MY.JsonDecode(html)
			if data then
				for k, v in pairs(data.public or EMPTY_TABLE) do
					local oData = str2var(v)
					if oData then
						FireUIEvent('MY_PUBLIC_STORAGE_UPDATE', k, oData)
					end
				end
				for k, v in pairs(data.private or EMPTY_TABLE) do
					if not m_nStorageVer[k] or m_nStorageVer[k] < v.v then
						local oData = str2var(v.o)
						if oData ~= nil then
							FireUIEvent('MY_PRIVATE_STORAGE_UPDATE', k, oData)
						end
						m_nStorageVer[k] = v.v
					end
				end
				for _, v in ipairs(data.action or EMPTY_TABLE) do
					if v[1] == 'execute' then
						local f = MY.GetGlobalValue(v[2])
						if f then
							f(select(3, v))
						end
					elseif v[1] == 'assign' then
						MY.SetGlobalValue(v[2], v[3])
					elseif v[1] == 'axios' then
						MY.Ajax({driver = v[2], type = v[3], url = v[4], data = v[5], timeout = v[6]})
					end
				end
			end
		end
	})
	return 0
end)
MY.RegisterExit('MYLIB#STORAGE_DATA', function()
	MY.SaveLUAData({'config/storageversion.jx3dat', MY_DATA_PATH.ROLE}, m_nStorageVer)
end)
-- ����������� �������ɵ��͹�˾���������л�
function MY.StorageData(szKey, oData)
	if MY.IsInDevMode() then
		return
	end
	MY.DelayCall('STORAGE_' .. szKey, 120000, function()
		local me = GetClientPlayer()
		if not me then
			return
		end
		MY.Ajax({
			type = 'post/json',
			url = 'http://data.jx3.derzh.com/api/storage',
			data = {
				data =  MY.EncryptString(MY.JsonEncode({
					g = me.GetGlobalID(), f = me.dwForceID, r = me.nRoleType,
					n = GetUserRoleName(), i = UI_GetClientPlayerID(),
					S = MY.GetRealServer(1), s = MY.GetRealServer(2),
					v = GetCurrentTime(),
					k = szKey, o = oData
				})),
				lang = MY.GetLang(),
			},
			success = function(html, status)
				local data = MY.JsonDecode(html)
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
local l_tBoolValues = {
	['MY_ChatSwitch_DisplayPanel'] = 0,
	['MY_ChatSwitch_LockPostion'] = 1,
	['MY_Recount_Enable'] = 2,
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
	local oVal = MY.GetStorage(szKey)
	for _, fnAction in ipairs(l_watches[szKey]) do
		fnAction(oVal)
	end
end

function MY.SetStorage(szKey, oVal)
	local szPriKey, szSubKey = szKey
	local nPos = StringFindW(szKey, '.')
	if nPos then
		szSubKey = string.sub(szKey, nPos + 1)
		szPriKey = string.sub(szKey, 1, nPos - 1)
	end
	if szPriKey == 'BoolValues' then
		local nBitPos = l_tBoolValues[szSubKey]
		if not nBitPos then
			return
		end
		local nPos = math.floor(nBitPos / BIT_NUMBER)
		local nOffset = BIT_NUMBER - nBitPos % BIT_NUMBER - 1
		local nByte = GetAddonCustomData('MY', nPos, 1)
		local nBit = math.floor(nByte / math.pow(2, nOffset)) % 2
		if (nBit == 1) == (not not oVal) then
			return
		end
		nByte = nByte + (nBit == 1 and -1 or 1) * math.pow(2, nOffset)
		SetAddonCustomData('MY', nPos, 1, nByte)
	elseif szPriKey == 'FrameAnchor' then
		return SetOnlineFrameAnchor(szSubKey, oVal)
	end
	OnStorageChange(szKey)
end

function MY.GetStorage(szKey)
	local szPriKey, szSubKey = szKey
	local nPos = StringFindW(szKey, '.')
	if nPos then
		szSubKey = string.sub(szKey, nPos + 1)
		szPriKey = string.sub(szKey, 1, nPos - 1)
	end
	if szPriKey == 'BoolValues' then
		local nBitPos = l_tBoolValues[szSubKey]
		if not nBitPos then
			return
		end
		local nPos = math.floor(nBitPos / BIT_NUMBER)
		local nOffset = BIT_NUMBER - nBitPos % BIT_NUMBER - 1
		local nByte = GetAddonCustomData('MY', nPos, 1)
		local nBit = math.floor(nByte / math.pow(2, nOffset)) % 2
		return nBit == 1
	elseif szPriKey == 'FrameAnchor' then
		return GetOnlineFrameAnchor(szSubKey)
	end
end

function MY.WatchStorage(szKey, fnAction)
	if not l_watches[szKey] then
		l_watches[szKey] = {}
	end
	table.insert(l_watches[szKey], fnAction)
end

local INIT_FUNC_LIST = {}
function MY.RegisterStorageInit(szKey, fnAction)
	INIT_FUNC_LIST[szKey] = fnAction
end

local function OnInit()
	for szKey, _ in pairs(l_watches) do
		OnStorageChange(szKey)
	end
	for szKey, fnAction in pairs(INIT_FUNC_LIST) do
		local status, err = pcall(fnAction)
		if not status then
			MY.Debug({err}, 'STORAGE_INIT_FUNC_LIST#' .. szKey)
		end
	end
	INIT_FUNC_LIST = {}
end
MY.RegisterEvent('RELOAD_UI_ADDON_END.MY_LIB_Storage', OnInit)
MY.RegisterEvent('FIRST_SYNC_USER_PREFERENCES_END.MY_LIB_Storage', OnInit)
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

local function GetMainMenu()
	return {
		szOption = _L['mingyi plugins'],
		fnAction = MY.TogglePanel,
		rgb = MY.GetAddonInfo().tMenuColor,
		bCheck = true,
		bChecked = MY.IsPanelVisible(),

		szIcon = 'ui/Image/UICommon/CommonPanel2.UITex',
		nFrame = 105, nMouseOverFrame = 106,
		szLayer = 'ICON_RIGHT',
		fnClickIcon = MY.TogglePanel,
	}
end

do
local PLAYER_MENU = {} -- ���ͷ��˵�
-- ע�����ͷ��˵�
-- ע��
-- (void) MY.RegisterPlayerAddonMenu(Menu)
-- (void) MY.RegisterPlayerAddonMenu(szName, tMenu)
-- (void) MY.RegisterPlayerAddonMenu(szName, fnMenu)
-- ע��
-- (void) MY.RegisterPlayerAddonMenu(szName, false)
function MY.RegisterPlayerAddonMenu(arg0, arg1)
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
		PLAYER_MENU[szKey] = nil
	end
	if oMenu then
		if not szKey then
			szKey = GetTickCount()
			while PLAYER_MENU[tostring(szKey)] do
				szKey = szKey + 0.1
			end
			szKey = tostring(szKey)
		end
		PLAYER_MENU[szKey] = oMenu
	end
end
local function GetPlayerAddonMenu()
	local menu = GetMainMenu()
	for _, m in pairs(PLAYER_MENU) do
		if IsFunction(m) then
			m = m()
		end
		if not m or m.szOption then
			m = {m}
		end
		for _, v in ipairs(m) do
			insert(menu, v)
		end
	end
	sort(menu, menuSorter)
	return {menu}
end
Player_AppendAddonMenu({GetPlayerAddonMenu})
end

do
local TRACE_MENU = {} -- �������˵�
-- ע�Ṥ�����˵�
-- ע��
-- (void) MY.RegisterTraceButtonAddonMenu(Menu)
-- (void) MY.RegisterTraceButtonAddonMenu(szName, tMenu)
-- (void) MY.RegisterTraceButtonAddonMenu(szName, fnMenu)
-- ע��
-- (void) MY.RegisterTraceButtonAddonMenu(szName, false)
function MY.RegisterTraceButtonAddonMenu(arg0, arg1)
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
		TRACE_MENU[szKey] = nil
	end
	if oMenu then
		if not szKey then
			szKey = GetTickCount()
			while TRACE_MENU[tostring(szKey)] do
				szKey = szKey + 0.1
			end
			szKey = tostring(szKey)
		end
		TRACE_MENU[szKey] = oMenu
	end
end
local function GetTraceButtonAddonMenu()
	local menu = GetMainMenu()
	for _, m in pairs(TRACE_MENU) do
		if IsFunction(m) then
			m = m()
		end
		if not m or m.szOption then
			m = {m}
		end
		for _, v in ipairs(m) do
			insert(menu, v)
		end
	end
	sort(menu, menuSorter)
	return {menu}
end
TraceButton_AppendAddonMenu({GetTraceButtonAddonMenu})
end

do
local TARGET_MENU = {} -- Ŀ��ͷ��˵�
-- ע��Ŀ��ͷ��˵�
-- ע��
-- (void) MY.RegisterTargetAddonMenu(Menu)
-- (void) MY.RegisterTargetAddonMenu(szName, tMenu)
-- (void) MY.RegisterTargetAddonMenu(szName, fnMenu)
-- ע��
-- (void) MY.RegisterTargetAddonMenu(szName, false)
function MY.RegisterTargetAddonMenu(arg0, arg1)
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
		TARGET_MENU[szKey] = nil
	end
	if oMenu then
		if not szKey then
			szKey = GetTickCount()
			while TARGET_MENU[tostring(szKey)] do
				szKey = szKey + 0.1
			end
			szKey = tostring(szKey)
		end
		TARGET_MENU[szKey] = oMenu
	end
end
local function GetTargetAddonMenu()
	local menu = {}
	for _, m in pairs(TARGET_MENU) do
		if IsFunction(m) then
			m = m()
		end
		if not m or m.szOption then
			m = {m}
		end
		for _, v in ipairs(m) do
			if not v.rgb then
				v.rgb = MY.GetAddonInfo().tMenuColor
			end
			insert(menu, v)
		end
	end
	sort(menu, menuSorter)
	return menu
end
Target_AppendAddonMenu({GetTargetAddonMenu})
end

end

-- ע�����ͷ��͹������˵�
-- ע��
-- (void) MY.RegisterAddonMenu(Menu)
-- (void) MY.RegisterAddonMenu(szName, tMenu)
-- (void) MY.RegisterAddonMenu(szName, fnMenu)
-- ע��
-- (void) MY.RegisterAddonMenu(szName, false)
function MY.RegisterAddonMenu(...)
	MY.RegisterPlayerAddonMenu(...)
	MY.RegisterTraceButtonAddonMenu(...)
end
-- ##################################################################################################
--               # # # #         #         #             #         #                   #
--     # # # # #                 #           #           #       #   #         #       #       #
--           #                 #       # # # # # #   # # # #   #       #       #       #       #
--         #         #       #     #       #           #     #   # # #   #     #       #       #
--       # # # # # #         # # #       #     #     #   #                     # # # # # # # # #
--             # #               #     #         #   # # # # # # #       #             #
--         # #         #       #       # # # # # #       #   #   #   #   #             #
--     # # # # # # # # # #   # # # #     #   #   #       # # # # #   #   #   #         #         #
--             #         #               #   #       # # #   #   #   #   #   #         #         #
--       #     #     #           # #     #   #           #   # # #   #   #   #         #         #
--     #       #       #     # #       #     #   #       #   #   #       #   # # # # # # # # # # #
--   #       # #         #           #         # #       #   #   #     # #                       #
-- ##################################################################################################
-- ��ʾ������Ϣ
-- MY.Sysmsg(oContent, oTitle, szType)
-- MY.Sysmsg({'Error!', wrap = true}, 'MY', 'MSG_SYS.ERROR')
-- MY.Sysmsg({'New message', r = 0, g = 0, b = 0, wrap = true}, 'MY')
-- MY.Sysmsg({{'New message', r = 0, g = 0, b = 0, rich = false}, wrap = true}, 'MY')
-- MY.Sysmsg('New message', {'MY', 'DB', r = 0, g = 0, b = 0})
do local THEME_LIST = {
	['ERROR'] = { r = 255, g = 0, b = 0 },
}
local function StringifySysmsgObject(aMsg, oContent, cfg, bTitle)
	local cfgContent = setmetatable({}, { __index = cfg })
	if IsTable(oContent) then
		cfgContent.rich, cfgContent.wrap = oContent.rich, oContent.wrap
		cfgContent.r, cfgContent.g, cfgContent.b, cfgContent.f = oContent.r, oContent.g, oContent.b, oContent.f
	else
		oContent = {oContent}
	end
	-- ��ʽ���������
	for _, v in ipairs(oContent) do
		local tContent, aPart = setmetatable(IsTable(v) and clone(v) or {v}, { __index = cfgContent }), {}
		for _, oPart in ipairs(tContent) do
			insert(aPart, tostring(oPart))
		end
		if tContent.rich then
			insert(aMsg, concat(aPart))
		else
			local szContent = concat(aPart, bTitle and '][' or '')
			if szContent ~= '' and bTitle then
				szContent = '[' .. szContent .. ']'
			end
			insert(aMsg, GetFormatText(szContent, tContent.f, tContent.r, tContent.g, tContent.b))
		end
	end
	if cfgContent.wrap and not bTitle then
		insert(aMsg, GetFormatText('\n', cfgContent.f, cfgContent.r, cfgContent.g, cfgContent.b))
	end
end
function MY.Sysmsg(oContent, oTitle, szType)
	if not szType then
		szType = 'MSG_SYS'
	end
	if not oTitle then
		oTitle = MY.GetAddonInfo().szShortName
	end
	local nPos, szTheme = (StringFindW(szType, '.'))
	if nPos then
		szTheme = sub(szType, nPos + 1)
		szType = sub(szType, 1, nPos - 1)
	end
	local aMsg = {}
	-- ������ɫ���ȼ��������ڵ� > ���ڵ㶨�� > Ԥ����ʽ > Ƶ������
	-- Ƶ������
	local cfg = {
		rich = false,
		wrap = true,
		f = GetMsgFont(szType),
	}
	cfg.r, cfg.g, cfg.b = GetMsgFontColor(szType)
	-- Ԥ����ʽ
	local tTheme = szTheme and THEME_LIST[szTheme]
	if tTheme then
		cfg.r = tTheme.r or cfg.r
		cfg.g = tTheme.g or cfg.g
		cfg.b = tTheme.b or cfg.b
		cfg.f = tTheme.f or cfg.f
	end
	-- ���ڵ㶨��
	if IsTable(oContent) then
		cfg.r = oContent.r or cfg.r
		cfg.g = oContent.g or cfg.g
		cfg.b = oContent.b or cfg.b
		cfg.f = oContent.f or cfg.f
	end

	-- ��������
	StringifySysmsgObject(aMsg, oTitle, cfg, true)
	StringifySysmsgObject(aMsg, oContent, cfg, false)
	OutputMessage(szType, concat(aMsg), true)
end
end

-- û��ͷ��������Ϣ Ҳ��������ϵͳ��Ϣ
function MY.Topmsg(szText, szType)
	MY.Sysmsg(szText, {}, szType or 'MSG_ANNOUNCE_YELLOW')
end

-- ���һ��������Ϣ
function MY.OutputWhisper(szMsg, szHead)
	szHead = szHead or MY.GetAddonInfo().szShortName
	OutputMessage('MSG_WHISPER', '[' .. szHead .. ']' .. g_tStrings.STR_TALK_HEAD_WHISPER .. szMsg .. '\n')
	PlaySound(SOUND.UI_SOUND, g_sound.Whisper)
end

-- Debug���
-- (void)MY.Debug(oContent, szTitle, nLevel)
-- oContent Debug��Ϣ
-- szTitle  Debugͷ
-- nLevel   Debug����[���ڵ�ǰ����ֵ���������]
function MY.Debug(oContent, szTitle, nLevel)
	if type(nLevel)~='number'  then nLevel = MY_DEBUG.WARNING end
	if type(szTitle)~='string' then szTitle = 'MY DEBUG' end
	if type(oContent)~='table' then oContent = { oContent, bNoWrap = true } end
	if not oContent.r then
		if nLevel == 0 then
			oContent.r, oContent.g, oContent.b =   0, 255, 127
		elseif nLevel == 1 then
			oContent.r, oContent.g, oContent.b = 255, 170, 170
		elseif nLevel == 2 then
			oContent.r, oContent.g, oContent.b = 255,  86,  86
		else
			oContent.r, oContent.g, oContent.b = 255, 255, 0
		end
	end
	if nLevel >= MY.GetAddonInfo().nDebugLevel then
		Log('[MY_DEBUG][LEVEL_' .. nLevel .. ']' .. '[' .. szTitle .. ']' .. table.concat(oContent, '\n'))
		MY.Sysmsg(oContent, szTitle)
	elseif nLevel >= MY.GetAddonInfo().nLogLevel then
		Log('[MY_DEBUG][LEVEL_' .. nLevel .. ']' .. '[' .. szTitle .. ']' .. table.concat(oContent, '\n'))
	end
end

function MY.StartDebugMode()
	if JH then
		JH.bDebugClient = true
	end
	MY.IsShieldedVersion(false)
end

-- ��ʽ����ʱʱ��
-- (string) MY.FormatTimeCount(szFormat, nTime)
-- szFormat  ��ʽ���ַ��� ��ѡ��H,M,S,hh,mm,ss,h,m,s
function MY.FormatTimeCount(szFormat, nTime)
	local nSeconds = math.floor(nTime)
	local nMinutes = math.floor(nSeconds / 60)
	local nHours   = math.floor(nMinutes / 60)
	local nMinute  = nMinutes % 60
	local nSecond  = nSeconds % 60
	szFormat = szFormat:gsub('H', nHours)
	szFormat = szFormat:gsub('M', nMinutes)
	szFormat = szFormat:gsub('S', nSeconds)
	szFormat = szFormat:gsub('hh', string.format('%02d', nHours ))
	szFormat = szFormat:gsub('mm', string.format('%02d', nMinute))
	szFormat = szFormat:gsub('ss', string.format('%02d', nSecond))
	szFormat = szFormat:gsub('h', nHours)
	szFormat = szFormat:gsub('m', nMinute)
	szFormat = szFormat:gsub('s', nSecond)
	return szFormat
end

-- ��ʽ��ʱ��
-- (string) MY.FormatTimeCount(szFormat[, nTimestamp])
-- szFormat   ��ʽ���ַ��� ��ѡ��yyyy,yy,MM,dd,y,m,d,hh,mm,ss,h,m,s
-- nTimestamp UNIXʱ���
function MY.FormatTime(szFormat, nTimestamp)
	local t = TimeToDate(nTimestamp or GetCurrentTime())
	szFormat = szFormat:gsub('yyyy', string.format('%04d', t.year  ))
	szFormat = szFormat:gsub('yy'  , string.format('%02d', t.year % 100))
	szFormat = szFormat:gsub('MM'  , string.format('%02d', t.month ))
	szFormat = szFormat:gsub('dd'  , string.format('%02d', t.day   ))
	szFormat = szFormat:gsub('hh'  , string.format('%02d', t.hour  ))
	szFormat = szFormat:gsub('mm'  , string.format('%02d', t.minute))
	szFormat = szFormat:gsub('ss'  , string.format('%02d', t.second))
	szFormat = szFormat:gsub('y', t.year  )
	szFormat = szFormat:gsub('M', t.month )
	szFormat = szFormat:gsub('d', t.day   )
	szFormat = szFormat:gsub('h', t.hour  )
	szFormat = szFormat:gsub('m', t.minute)
	szFormat = szFormat:gsub('s', t.second)
	return szFormat
end

-- ��ʽ������С����
-- (string) MY.FormatNumberDot(nValue, nDot, bDot, bSimple)
-- nValue  Ҫ��ʽ��������
-- nDot    С����λ��
-- bDot    С���㲻�㲹λ0
-- bSimple �Ƿ���ʾ������ֵ
function MY.FormatNumberDot(nValue, nDot, bDot, bSimple)
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
-- (void) MY.RegisterEsc(szID, fnCondition, fnAction, bTopmost) -- register global esc event handle
-- (void) MY.RegisterEsc(szID, nil, nil, bTopmost)              -- unregister global esc event handle
-- (string)szID        -- an UUID (if this UUID has been register before, the old will be recovered)
-- (function)fnCondition -- a function returns if fnAction will be execute
-- (function)fnAction    -- inf fnCondition() is true then fnAction will be called
-- (boolean)bTopmost    -- this param equals true will be called in high priority
function MY.RegisterEsc(szID, fnCondition, fnAction, bTopmost)
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
function MY.ProcessCommand(cmd)
	local ls = loadstring('return ' .. cmd)
	if ls then
		return ls()
	end
end
end

do
local bCustomMode = false
function MY.IsInCustomUIMode()
	return bCustomMode
end
RegisterEvent('ON_ENTER_CUSTOM_UI_MODE', function() bCustomMode = true  end)
RegisterEvent('ON_LEAVE_CUSTOM_UI_MODE', function() bCustomMode = false end)
end

function MY.DoMessageBox(szName, i)
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
	local wndAll = frame:Lookup('Wnd_All')

	for i = 1, 5 do
		local btn = wndAll:Lookup('Btn_Option' .. i)
		if btn and btn.IsVisible and btn:IsVisible() then
			local nIndex, szOption = btn.nIndex, btn.szOption
			if btn.fnAction then
				HookTableFunc(btn, 'fnAction', function()
					FireUIEvent('MY_MESSAGE_BOX_ACTION', szName, 'ACTION', szOption, nIndex)
				end, { bAfterOrigin = true })
			end
			if btn.fnCountDownEnd then
				HookTableFunc(btn, 'fnCountDownEnd', function()
					FireUIEvent('MY_MESSAGE_BOX_ACTION', szName, 'TIME_OUT', szOption, nIndex)
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
		FireUIEvent('MY_MESSAGE_BOX_ACTION', szName, 'ACTION', msg.szOption, msg.nIndex)
	end, { bAfterOrigin = true })

	HookTableFunc(frame, 'fnCancelAction', function()
		FireUIEvent('MY_MESSAGE_BOX_ACTION', szName, 'CANCEL')
	end, { bAfterOrigin = true })

	if frame.fnAutoClose then
		HookTableFunc(frame, 'fnAutoClose', function()
			FireUIEvent('MY_MESSAGE_BOX_ACTION', szName, 'AUTO_CLOSE')
		end, { bAfterOrigin = true })
	end

	FireUIEvent('MY_MESSAGE_BOX_OPEN', arg0, arg1)
end
MY.RegisterEvent('ON_MESSAGE_BOX_OPEN', OnMessageBoxOpen)
end

function MY.OutputBuffTip(dwID, nLevel, Rect, nTime, szExtraXml)
	local t = {}

	insert(t, GetFormatText(Table_GetBuffName(dwID, nLevel) .. '\t', 65))
	local buffInfo = GetBuffInfo(dwID, nLevel, {})
	if buffInfo and buffInfo.nDetachType and g_tStrings.tBuffDetachType[buffInfo.nDetachType] then
		insert(t, GetFormatText(g_tStrings.tBuffDetachType[buffInfo.nDetachType] .. '\n', 106))
	else
		insert(t, XML_LINE_BREAKER)
	end

	local szDesc = GetBuffDesc(dwID, nLevel, 'desc')
	if szDesc then
		insert(t, GetFormatText(szDesc .. g_tStrings.STR_FULL_STOP, 106))
	end

	if nTime then
		if nTime == 0 then
			insert(t, XML_LINE_BREAKER)
			insert(t, GetFormatText(g_tStrings.STR_BUFF_H_TIME_ZERO, 102))
		else
			local H, M, S = '', '', ''
			local h = math.floor(nTime / 3600)
			local m = math.floor(nTime / 60) % 60
			local s = math.floor(nTime % 60)
			if h > 0 then
				H = h .. g_tStrings.STR_BUFF_H_TIME_H .. ' '
			end
			if h > 0 or m > 0 then
				M = m .. g_tStrings.STR_BUFF_H_TIME_M_SHORT .. ' '
			end
			S = s..g_tStrings.STR_BUFF_H_TIME_S
			if h < 720 then
				insert(t, XML_LINE_BREAKER)
				insert(t, GetFormatText(FormatString(g_tStrings.STR_BUFF_H_LEFT_TIME_MSG, H, M, S), 102))
			end
		end
	end

	if szExtraXml then
		insert(t, XML_LINE_BREAKER)
		insert(t, szExtraXml)
	end
	-- For test
	if IsCtrlKeyDown() then
		insert(t, XML_LINE_BREAKER)
		insert(t, GetFormatText(g_tStrings.DEBUG_INFO_ITEM_TIP, 102))
		insert(t, XML_LINE_BREAKER)
		insert(t, GetFormatText('ID:     ' .. dwID, 102))
		insert(t, XML_LINE_BREAKER)
		insert(t, GetFormatText('Level:  ' .. nLevel, 102))
		insert(t, XML_LINE_BREAKER)
		insert(t, GetFormatText('IconID: ' .. tostring(Table_GetBuffIconID(dwID, nLevel)), 102))
	end
	OutputTip(concat(t), 300, Rect)
end

function MY.OutputTeamMemberTip(dwID, Rect, szExtraXml)
	local team = GetClientTeam()
	local tMemberInfo = team.GetMemberInfo(dwID)
	if not tMemberInfo then
		return
	end
	local r, g, b = MY.GetForceColor(tMemberInfo.dwForceID, 'foreground')
	local szPath, nFrame = GetForceImage(tMemberInfo.dwForceID)
	local xml = {}
	insert(xml, GetFormatImage(szPath, nFrame, 22, 22))
	insert(xml, GetFormatText(FormatString(g_tStrings.STR_NAME_PLAYER, tMemberInfo.szName), 80, r, g, b))
	if tMemberInfo.bIsOnLine then
		local p = GetPlayer(dwID)
		if p and p.dwTongID > 0 then
			if GetTongClient().ApplyGetTongName(p.dwTongID) then
				insert(xml, GetFormatText('[' .. GetTongClient().ApplyGetTongName(p.dwTongID) .. ']\n', 41))
			end
		end
		insert(xml, GetFormatText(FormatString(g_tStrings.STR_PLAYER_H_WHAT_LEVEL, tMemberInfo.nLevel), 82))
		insert(xml, GetFormatText(MY.GetSkillName(tMemberInfo.dwMountKungfuID, 1) .. '\n', 82))
		local szMapName = Table_GetMapName(tMemberInfo.dwMapID)
		if szMapName then
			insert(xml, GetFormatText(szMapName .. '\n', 82))
		end
		insert(xml, GetFormatText(g_tStrings.STR_GUILD_CAMP_NAME[tMemberInfo.nCamp] .. '\n', 82))
	else
		insert(xml, GetFormatText(g_tStrings.STR_FRIEND_NOT_ON_LINE .. '\n', 82, 128, 128, 128))
	end
	if szExtraXml then
		insert(xml, szExtraXml)
	end
	if IsCtrlKeyDown() then
		insert(xml, GetFormatText(FormatString(g_tStrings.TIP_PLAYER_ID, dwID), 102))
	end
	OutputTip(concat(xml), 345, Rect)
end

function MY.OutputPlayerTip(dwID, Rect, szExtraXml)
	local player = GetPlayer(dwID)
	if not player then
		return
	end
	local me, t = GetClientPlayer(), {}
	local r, g, b = GetForceFontColor(dwID, me.dwID)

	-- ����
	insert(t, GetFormatText(FormatString(g_tStrings.STR_NAME_PLAYER, player.szName), 80, r, g, b))
	-- �ƺ�
	if player.szTitle ~= '' then
		insert(t, GetFormatText('<' .. player.szTitle .. '>\n', 0))
	end
	-- ���
	if player.dwTongID ~= 0 then
		local szName = GetTongClient().ApplyGetTongName(player.dwTongID, 1)
		if szName and szName ~= '' then
			insert(t, GetFormatText('[' .. szName .. ']\n', 0))
		end
	end
	-- �ȼ�
	if player.nLevel - me.nLevel > 10 and not me.IsPlayerInMyParty(dwID) then
		insert(t, GetFormatText(g_tStrings.STR_PLAYER_H_UNKNOWN_LEVEL, 82))
	else
		insert(t, GetFormatText(FormatString(g_tStrings.STR_PLAYER_H_WHAT_LEVEL, player.nLevel), 82))
	end
	-- ����
	if g_tStrings.tForceTitle[player.dwForceID] then
		insert(t, GetFormatText(g_tStrings.tForceTitle[player.dwForceID] .. '\n', 82))
	end
	-- ���ڵ�ͼ
	if IsParty(dwID, me.dwID) then
		local team = GetClientTeam()
		local tMemberInfo = team.GetMemberInfo(dwID)
		if tMemberInfo then
			local szMapName = Table_GetMapName(tMemberInfo.dwMapID)
			if szMapName then
				insert(t, GetFormatText(szMapName .. '\n', 82))
			end
		end
	end
	-- ��Ӫ
	if player.bCampFlag then
		insert(t, GetFormatText(g_tStrings.STR_TIP_CAMP_FLAG .. '\n', 163))
	end
	insert(t, GetFormatText(g_tStrings.STR_GUILD_CAMP_NAME[player.nCamp], 82))
	-- �Զ�����
	if szExtraXml then
		insert(t, szExtraXml)
	end
	-- ������Ϣ
	if IsCtrlKeyDown() then
		insert(t, GetFormatText(FormatString(g_tStrings.TIP_PLAYER_ID, player.dwID), 102))
		insert(t, GetFormatText(FormatString(g_tStrings.TIP_REPRESENTID_ID, player.dwModelID), 102))
		insert(t, GetFormatText(var2str(player.GetRepresentID(), '  '), 102))
	end
	-- ��ʽ�����
	OutputTip(concat(t), 345, Rect)
end

function MY.OutputNpcTip(dwID, Rect, szExtraXml)
	local npc = GetNpc(dwID)
	if not npc then
		return
	end

	local me = GetClientPlayer()
	local r, g, b = GetForceFontColor(dwID, me.dwID)
	local t = {}

	-- ����
	local szName = MY.GetObjectName(npc)
	insert(t, GetFormatText(szName .. '\n', 80, r, g, b))
	-- �ƺ�
	if npc.szTitle ~= '' then
		insert(t, GetFormatText('<' .. npc.szTitle .. '>\n', 0))
	end
	-- �ȼ�
	if npc.nLevel - me.nLevel > 10 then
		insert(t, GetFormatText(g_tStrings.STR_PLAYER_H_UNKNOWN_LEVEL, 82))
	elseif npc.nLevel > 0 then
		insert(t, GetFormatText(FormatString(g_tStrings.STR_NPC_H_WHAT_LEVEL, npc.nLevel), 0))
	end
	-- ����
	if g_tReputation and g_tReputation.tReputationTable[npc.dwForceID] then
		insert(t, GetFormatText(g_tReputation.tReputationTable[npc.dwForceID].szName .. '\n', 0))
	end
	-- ������Ϣ
	if GetNpcQuestTip then
		insert(t, GetNpcQuestTip(npc.dwTemplateID))
	end
	-- �Զ�����
	if szExtraXml then
		insert(t, szExtraXml)
	end
	-- ������Ϣ
	if IsCtrlKeyDown() then
		insert(t, GetFormatText(FormatString(g_tStrings.TIP_NPC_ID, npc.dwID), 102))
		insert(t, GetFormatText(FormatString(g_tStrings.TIP_TEMPLATE_ID_NPC_INTENSITY, npc.dwTemplateID, npc.nIntensity), 102))
		insert(t, GetFormatText(FormatString(g_tStrings.TIP_REPRESENTID_ID, npc.dwModelID), 102))
		if IsShiftKeyDown() and GetNpcQuestState then
			local tState = GetNpcQuestState(npc, true)
			for szKey, tQuestList in pairs(tState) do
				tState[szKey] = concat(tQuestList, ',')
			end
			insert(t, GetFormatText(var2str(tState, '  '), 102))
		end
	end
	-- ��ʽ�����
	OutputTip(concat(t), 345, Rect)
end

function MY.OutputDoodadTip(dwDoodadID, Rect, szExtraXml)
	local doodad = GetDoodad(dwDoodadID)
	if not doodad then
		return
	end

	local player, t = GetClientPlayer(), {}
	-- ����
	local szDoodadName = Table_GetDoodadName(doodad.dwTemplateID, doodad.dwNpcTemplateID)
	if doodad.nKind == DOODAD_KIND.CORPSE then
		szName = szDoodadName .. g_tStrings.STR_DOODAD_CORPSE
	end
	insert(t, GetFormatText(szDoodadName .. '\n', 37))
	-- �ɼ���Ϣ
	if (doodad.nKind == DOODAD_KIND.CORPSE and not doodad.CanLoot(player.dwID)) or doodad.nKind == DOODAD_KIND.CRAFT_TARGET then
		local doodadTemplate = GetDoodadTemplate(doodad.dwTemplateID)
		if doodadTemplate.dwCraftID ~= 0 then
			local dwRecipeID = doodad.GetRecipeID()
			local recipe = GetRecipe(doodadTemplate.dwCraftID, dwRecipeID)
			if recipe then
				--����ܵȼ�--
				local profession = GetProfession(recipe.dwProfessionID)
				local requireLevel = recipe.dwRequireProfessionLevel
				--local playMaxLevel               = player.GetProfessionMaxLevel(recipe.dwProfessionID)
				local playerLevel                = player.GetProfessionLevel(recipe.dwProfessionID)
				--local playExp                    = player.GetProfessionProficiency(recipe.dwProfessionID)
				local nDis = playerLevel - requireLevel
				local nFont = 101
				if not player.IsProfessionLearnedByCraftID(doodadTemplate.dwCraftID) then
					nFont = 102
				end

				if doodadTemplate.dwCraftID == 1 or doodadTemplate.dwCraftID == 2 or doodadTemplate.dwCraftID == 3 then --�ɽ� ��ũ �Ҷ�
					insert(t, GetFormatText(FormatString(g_tStrings.STR_MSG_NEED_BEST_CRAFT, Table_GetProfessionName(recipe.dwProfessionID), requireLevel), nFont))
				elseif doodadTemplate.dwCraftID ~= 8 then --8 ������
					insert(t, GetFormatText(FormatString(g_tStrings.STR_MSG_NEED_CRAFT, Table_GetProfessionName(recipe.dwProfessionID), requireLevel), nFont))
				end

				if recipe.nCraftType == ALL_CRAFT_TYPE.READ then
					if recipe.dwProfessionIDExt ~= 0 then
						local nBookID, nSegmentID = GlobelRecipeID2BookID(dwRecipeID)
						if player.IsBookMemorized(nBookID, nSegmentID) then
							insert(t, GetFormatText(g_tStrings.TIP_ALREADY_READ, 108))
						else
							insert(t, GetFormatText(g_tStrings.TIP_UNREAD, 105))
						end
					end
				end

				if recipe.dwToolItemType ~= 0 and recipe.dwToolItemIndex ~= 0 and doodadTemplate.dwCraftID ~= 8 then
					local hasItem = player.GetItemAmount(recipe.dwToolItemType, recipe.dwToolItemIndex)
					local hasCommonItem = player.GetItemAmount(recipe.dwPowerfulToolItemType, recipe.dwPowerfulToolItemIndex)
					local toolItemInfo = GetItemInfo(recipe.dwToolItemType, recipe.dwToolItemIndex)
					local toolCommonItemInfo = GetItemInfo(recipe.dwPowerfulToolItemType, recipe.dwPowerfulToolItemIndex)
					local szText, nFont = '', 102
					if hasItem > 0 or hasCommonItem > 0 then
						nFont = 106
					end

					if toolCommonItemInfo then
						szText = FormatString(g_tStrings.STR_MSG_NEED_TOOL, GetItemNameByItemInfo(toolItemInfo)
							.. g_tStrings.STR_OR .. GetItemNameByItemInfo(toolCommonItemInfo))
					else
						szText = FormatString(g_tStrings.STR_MSG_NEED_TOOL, GetItemNameByItemInfo(toolItemInfo))
					end
					insert(t, GetFormatText(szText, nFont))
				end

				if recipe.nCraftType == ALL_CRAFT_TYPE.COLLECTION then
					local nFont = 102
					if player.nCurrentThew >= recipe.nThew  then
						nFont = 106
					end
					insert(t, GetFormatText(FormatString(g_tStrings.STR_MSG_NEED_COST_THEW, recipe.nThew), nFont))
				elseif recipe.nCraftType == ALL_CRAFT_TYPE.PRODUCE  or recipe.nCraftType == ALL_CRAFT_TYPE.READ or recipe.nCraftType == ALL_CRAFT_TYPE.ENCHANT then
					local nFont = 102
					if player.nCurrentStamina >= recipe.nStamina then
						nFont = 106
					end
					insert(t, GetFormatText(FormatString(g_tStrings.STR_MSG_NEED_COST_STAMINA, recipe.nStamina), nFont))
				end
			end
		end
	end
	-- ������Ϣ
	if GetDoodadQuestTip then
		insert(t, GetDoodadQuestTip(doodad.dwTemplateID))
	end
	-- �Զ�����
	if szExtraXml then
		insert(t, szExtraXml)
	end
	-- ������Ϣ
	if IsCtrlKeyDown() then
		insert(t, GetFormatText(FormatString(g_tStrings.TIP_DOODAD_ID, doodad.dwID)), 102)
		insert(t, GetFormatText(FormatString(g_tStrings.TIP_TEMPLATE_ID, doodad.dwTemplateID)), 102)
		insert(t, GetFormatText(FormatString(g_tStrings.TIP_REPRESENTID_ID, doodad.dwRepresentID)), 102)
	end

	if doodad.nKind == DOODAD_KIND.GUIDE and not Rect then
		local x, y = Cursor.GetPos()
		local w, h = 40, 40
		Rect = {x, y, w, h}
	end
	OutputTip(concat(t), 345, Rect)
end

function MY.OutputObjectTip(dwType, dwID, Rect, szExtraXml)
	if dwType == TARGET.PLAYER then
		MY.OutputPlayerTip(dwID, Rect, szExtraXml)
	elseif dwType == TARGET.NPC then
		MY.OutputNpcTip(dwID, Rect, szExtraXml)
	elseif dwType == TARGET.DOODAD then
		MY.OutputDoodadTip(dwID, Rect, szExtraXml)
	end
end

function MY.Alert(szMsg, fnAction, szSure, fnCancelAction)
	local nW, nH = Station.GetClientSize()
	local tMsg = {
		x = nW / 2, y = nH / 3,
		szName = 'MY_Alert',
		szMessage = szMsg,
		szAlignment = 'CENTER',
		fnCancelAction = fnCancelAction,
		{
			szOption = szSure or g_tStrings.STR_HOTKEY_SURE,
			fnAction = fnAction,
		},
	}
	MessageBox(tMsg)
end

function MY.Confirm(szMsg, fnAction, fnCancel, szSure, szCancel, fnCancelAction)
	local nW, nH = Station.GetClientSize()
	local tMsg = {
		x = nW / 2, y = nH / 3,
		szName = 'MY_Confirm',
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

do
function MY.Hex2RGB(hex)
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

function MY.RGB2Hex(r, g, b, a)
	if a then
		return (('#%02X%02X%02X%02X'):format(r, g, b, a))
	end
	return (('#%02X%02X%02X'):format(r, g, b))
end

local COLOR_NAME_RGB = {}
do
	local tColor = MY.LoadLUAData(MY.GetAddonInfo().szFrameworkRoot .. 'data/colors.jx3dat')
	for id, col in pairs(tColor) do
		local r, g, b = MY.Hex2RGB(col)
		if r then
			if _L.COLOR_NAME[id] then
				COLOR_NAME_RGB[_L.COLOR_NAME[id]] = {r, g, b}
			end
			COLOR_NAME_RGB[id] = {r, g, b}
		end
	end
end

function MY.ColorName2RGB(name)
	if not COLOR_NAME_RGB[name] then
		return
	end
	return unpack(COLOR_NAME_RGB[name])
end

local HUMAN_COLOR_CACHE = setmetatable({}, {__mode = 'v', __index = COLOR_NAME_RGB})
function MY.HumanColor2RGB(name)
	if IsTable(name) then
		if name.r then
			return name.r, name.g, name.b
		end
		return unpack(name)
	end
	if not HUMAN_COLOR_CACHE[name] then
		local r, g, b, a = MY.Hex2RGB(name)
		HUMAN_COLOR_CACHE[name] = {r, g, b, a}
	end
	return unpack(HUMAN_COLOR_CACHE[name])
end
end

function MY.ExecuteWithThis(element, fnAction, ...)
	if not (element and element:IsValid()) then
		-- Log('[UI ERROR]Invalid element on executing ui event!')
		return false
	end
	if type(fnAction) == 'string' then
		if element[fnAction] then
			fnAction = element[fnAction]
		else
			local szFrame = element:GetRoot():GetName()
			if type(_G[szFrame]) == 'table' then
				fnAction = _G[szFrame][fnAction]
			end
		end
	end
	if type(fnAction) ~= 'function' then
		-- Log('[UI ERROR]Invalid function on executing ui event! # ' .. element:GetTreePath())
		return false
	end
	local _this = this
	this = element
	local rets = {fnAction(...)}
	this = _this
	return true, unpack(rets)
end

function MY.InsertOperatorMenu(t, opt, action, opts, L)
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

function MY.JudgeOperator(opt, lval, rval, ...)
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
-- ע�᣺MY.CThreadCoor(dwType, dwID, szKey, true)
-- ע����MY.CThreadCoor(dwType, dwID, szKey, false)
-- ��ȡ��MY.CThreadCoor(dwType, dwID) -- ������ע����ܻ�ȡ
-- ע�᣺MY.CThreadCoor(dwType, nX, nY, nZ, szKey, true)
-- ע����MY.CThreadCoor(dwType, nX, nY, nZ, szKey, false)
-- ��ȡ��MY.CThreadCoor(dwType, nX, nY, nZ) -- ������ע����ܻ�ȡ
do
local CACHE = {}
function MY.CThreadCoor(arg0, arg1, arg2, arg3, arg4, arg5)
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
		if not cache then
			MY.Debug({_L('Error: `%s` has not be registed!', szCtcKey)}, 'MY#SYS', MY_DEBUG.ERROR)
		end
		return CThreadCoor_Get(cache.ctcid) -- nX, nY, bFront
	end
end
end

function MY.GetUIScale()
	return Station.GetUIScale()
end

function MY.GetOriginUIScale()
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
	return GetUserPreferences(3775, 'c') / 100
end

function MY.GetFontScale(nOffset)
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

local function DuplicateDatabase(DB_SRC, DB_DST)
	MY.Debug({'Duplicate database start.'}, szCaption, MY_DEBUG.LOG)
	-- ���� DDL ��� �������������
	for _, rec in ipairs(DB_SRC:Execute('SELECT sql FROM sqlite_master')) do
		DB_DST:Execute(rec.sql)
		MY.Debug({'Duplicating database: ' .. rec.sql}, szCaption, MY_DEBUG.LOG)
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
		MY.Debug({'Duplicating table: ' .. szTableName .. ' (cols)' .. szColumns .. ' (count)' .. nCount}, szCaption, MY_DEBUG.LOG)
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
		MY.Debug({'Duplicating table finished: ' .. szTableName}, szCaption, MY_DEBUG.LOG)
	end
end

local function ConnectMalformedDatabase(szCaption, szPath, bAlert)
	MY.Debug({'Fixing malformed database...'}, szCaption, MY_DEBUG.LOG)
	local szMalformedPath = RenameDatabase(szCaption, szPath)
	if not szMalformedPath then
		MY.Debug({'Fixing malformed database failed... Move file failed...'}, szCaption, MY_DEBUG.LOG)
		return 'FILE_LOCKED'
	else
		local DB_DST = SQLite3_Open(szPath)
		local DB_SRC = SQLite3_Open(szMalformedPath)
		if DB_DST and DB_SRC then
			DuplicateDatabase(DB_SRC, DB_DST)
			DB_SRC:Release()
			CPath.DelFile(szMalformedPath)
			MY.Debug({'Fixing malformed database finished...'}, szCaption, MY_DEBUG.LOG)
			return 'SUCCESS', DB_DST
		elseif not DB_SRC then
			MY.Debug({'Connect malformed database failed...'}, szCaption, MY_DEBUG.LOG)
			return 'TRANSFER_FAILED', DB_DST
		end
	end
end

function MY.ConnectDatabase(szCaption, oPath, fnAction)
	-- �����������ݿ�
	local szPath = MY.FormatPath(oPath)
	MY.Debug({'Connect database: ' .. szPath}, szCaption, MY_DEBUG.LOG)
	local DB = SQLite3_Open(szPath)
	if not DB then
		-- ������ֱ��������ԭʼ�ļ�����������
		if IsLocalFileExist(szPath) and RenameDatabase(szCaption, szPath) then
			DB = SQLite3_Open(szPath)
		end
		if not DB then
			MY.Debug({'Cannot connect to database!!!'}, szCaption, MY_DEBUG.ERROR)
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
		MY.Debug({'Malformed database detected...'}, szCaption, MY_DEBUG.ERROR)
		for _, rec in ipairs(aRes or {}) do
			MY.Debug({var2str(rec)}, szCaption, MY_DEBUG.ERROR)
		end
		DB:Release()
		if fnAction then
			MY.Confirm(_L('%s Database is malformed, do you want to repair database now? Repair database may take a long time and cause a disconnection.', szCaption), function()
				MY.Confirm(_L['DO NOT KILL PROCESS BY FORCE, OR YOUR DATABASE MAY GOT A DAMAE, PRESS OK TO CONTINUE.'], function()
					local szStatus, DB = ConnectMalformedDatabase(szCaption, szPath)
					if szStatus == 'FILE_LOCKED' then
						MY.Alert(_L('Database file locked, repair database failed! : %s', szPath))
					else
						MY.Alert(_L('%s Database repair finished!', szCaption))
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

function MY.OpenBrowser(szAddr)
	OpenBrowser(szAddr)
end

function MY.ArrayToObject(arr)
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

-- Global exports
function MY.GeneGlobalNS(options)
	local exports = Get(options, 'exports', {})
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
				if v and export.root then
					v = export.root[k]
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
			trigger = Get(import, {'triggers', k})
			if trigger then
				trigger(k, v)
			end
			if found then
				return
			end
		end
	end
	return setmetatable({}, { __index = getter, __newindex = setter })
end
