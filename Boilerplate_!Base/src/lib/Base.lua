--------------------------------------------------------
-- This file is part of the JX3 Plugin Project.
-- @desc     : ��������ö��
-- @copyright: Copyright (c) 2009 Kingsoft Co., Ltd.
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
-------------------------------------------------------------------------------------------------------
-- wstring ����
local _wsub = wstring.sub
local function wsub(str, s, e)
	local nLen = wlen(str)
	if s < 0 then
		s = nLen + s + 1
	end
	if not e then
		e = nLen
	elseif e < 0 then
		e = nLen + e + 1
	end
	return _wsub(str, s, e)
end
-------------------------------------------------------------------------------------------------------
-- ���غ�������
-------------------------------------------------------------------------------------------------------
local function IsStreaming()
	return _G.SM_IsEnable and _G.SM_IsEnable()
end
local _BUILD_                 = '19700101'
local _NATURAL_VERSION_       = 0
local _VERSION_               = '0.0.0'
local _MENU_COLOR_            = {255, 255, 255}
local _MAX_PLAYER_LEVEL_      = 100
local _INTERFACE_ROOT_        = 'Interface/'
local _NAME_SPACE_            = 'Boilerplate'
local _ADDON_ROOT_            = _INTERFACE_ROOT_ .. _NAME_SPACE_ .. '/'
local _DATA_ROOT_             = (IsStreaming() and (_G.GetUserDataFolder() .. '/' .. GetUserAccount() .. '/interface/') or _INTERFACE_ROOT_) .. _NAME_SPACE_ .. '#DATA/'
local _FRAMEWORK_ROOT_        = _ADDON_ROOT_ .. _NAME_SPACE_ .. '_!Base/'
local _UICOMPONENT_ROOT_      = _FRAMEWORK_ROOT_ .. 'ui/components/'
local _LOGO_UITEX_            = _FRAMEWORK_ROOT_ .. 'img/Logo.UITex'
local _LOGO_MAIN_FRAME_       = 0
local _LOGO_MENU_FRAME_       = 1
local _LOGO_MENU_HOVER_FRAME_ = 2
local _POSTER_UITEX_          = _ADDON_ROOT_ .. _NAME_SPACE_ .. '_Resource/img/Poster.UITex'
local _POSTER_FRAME_COUNT_    = 1
local _DEBUG_LEVEL_           = tonumber(LoadLUAData(_DATA_ROOT_ .. 'debug.level.jx3dat') or nil) or 4
local _DELOG_LEVEL_           = tonumber(LoadLUAData(_DATA_ROOT_ .. 'delog.level.jx3dat') or nil) or 4
-------------------------------------------------------------------------------------------------------
-- ��ʼ�����Թ���
-------------------------------------------------------------------------------------------------------
-----------------------------------------------
-- ������Ϊֻ��
-----------------------------------------------
local SetmetaReadonly = SetmetaReadonly
if not SetmetaReadonly then
	SetmetaReadonly = function(t)
		for k, v in pairs(t) do
			if type(v) == 'table' then
				t[k] = SetmetaReadonly(v)
			end
		end
		return setmetatable({}, {
			__index     = t,
			__newindex  = function() assert(false, 'table is readonly\n') end,
			__metatable = {
				const_table = t,
			},
		})
	end
end
local DEBUG_LEVEL = SetmetaReadonly({
	PMLOG   = 0,
	LOG     = 1,
	WARNING = 2,
	ERROR   = 3,
	DEBUG   = 3,
})
---------------------------------------------------
-- ���Թ���
---------------------------------------------------
if _DEBUG_LEVEL_ <= DEBUG_LEVEL.DEBUG then
	if not ECHO_LUA_ERROR then
		ECHO_LUA_ERROR = { ID = _NAME_SPACE_ }
	elseif type(ECHO_LUA_ERROR) == 'table' then
		ECHO_LUA_ERROR.ID = _NAME_SPACE_
	end
	RegisterEvent('CALL_LUA_ERROR', function()
		if ECHO_LUA_ERROR and ECHO_LUA_ERROR.ID == _NAME_SPACE_ then
			print(arg0)
			OutputMessage('MSG_SYS', arg0)
		end
	end)
	TraceButton_AppendAddonMenu({{
		szOption = 'ReloadUIAddon',
		fnAction = function()
			ReloadUIAddon()
		end,
	}})
end
Log('[' .. _NAME_SPACE_ .. '] Debug level ' .. _DEBUG_LEVEL_ .. ' / delog level ' .. _DELOG_LEVEL_)
-------------------------------------------------------------------------------------------------------
-- ��Ϸ���ԡ���Ϸ��Ӫ��֧���롢��Ϸ���а���롢��Ϸ�汾��
-------------------------------------------------------------------------------------------------------
local _GAME_LANG_, _GAME_BRANCH_, _GAME_EDITION_, _GAME_VERSION_
do
	local szVersionLineFullName, szVersion, szVersionLineName, szVersionEx, szVersionName = GetVersion()
	_GAME_LANG_ = lower(szVersionLineName)
	if _GAME_LANG_ == 'classic' then
		_GAME_LANG_ = 'zhcn'
	end
	_GAME_BRANCH_ = lower(szVersionLineName)
	_GAME_EDITION_ = lower(szVersionLineName .. '_' .. szVersionEx)
	_GAME_VERSION_ = lower(szVersion)
end
-------------------------------------------------------------------------------------------------------
-- �������԰�
-------------------------------------------------------------------------------------------------------
local function LoadLangPack(szLangFolder)
	local t0 = LoadLUAData(_FRAMEWORK_ROOT_..'lang/default') or {}
	local t1 = LoadLUAData(_FRAMEWORK_ROOT_..'lang/' .. _GAME_LANG_) or {}
	for k, v in pairs(t1) do
		t0[k] = v
	end
	if type(szLangFolder)=='string' then
		szLangFolder = gsub(szLangFolder,'[/\\]+$','')
		local t2 = LoadLUAData(szLangFolder..'/default') or {}
		for k, v in pairs(t2) do
			t0[k] = v
		end
		local t3 = LoadLUAData(szLangFolder..'/' .. _GAME_LANG_) or {}
		for k, v in pairs(t3) do
			t0[k] = v
		end
	end
	setmetatable(t0, {
		__index = function(t, k) return k end,
		__call = function(t, k, ...) return format(t[k], ...) end,
	})
	return t0
end
local _L = LoadLangPack(_FRAMEWORK_ROOT_ .. 'lang/lib/')
local _NAME_             = _L.PLUGIN_NAME
local _SHORT_NAME_       = _L.PLUGIN_SHORT_NAME
local _AUTHOR_           = _L.PLUGIN_AUTHOR
local _AUTHOR_WEIBO_     = _L.PLUGIN_AUTHOR_WEIBO
local _AUTHOR_WEIBO_URL_ = 'https://weibo.com/'
local _AUTHOR_SIGNATURE_ = _L.PLUGIN_AUTHOR_SIGNATURE
local _AUTHOR_ROLES_     = {
}
local _AUTHOR_HEADER_ = GetFormatText(_NAME_ .. ' ' .. _L['[Author]'], 8, 89, 224, 232)
local _AUTHOR_PROTECT_NAMES_ = {
}
local _AUTHOR_FAKE_HEADER_ = GetFormatText(_L['[Fake author]'], 8, 255, 95, 159)
-------------------------------------------------------------------------------------------------------
-- ͨ�ú���
-------------------------------------------------------------------------------------------------------
-----------------------------------------------
-- ��¡����
-----------------------------------------------
local function Clone(var)
	if type(var) == 'table' then
		local ret = {}
		for k, v in pairs(var) do
			ret[Clone(k)] = Clone(v)
		end
		return ret
	else
		return var
	end
end
-----------------------------------------------
-- Lua�������л�
-----------------------------------------------
local EncodeLUAData = _G.var2str
-----------------------------------------------
-- Lua���ݷ����л�
-----------------------------------------------
local DecodeLUAData = _G.str2var or function(szText)
	local DECODE_ROOT = _DATA_ROOT_ .. '#cache/decode/'
	local DECODE_PATH = DECODE_ROOT .. GetCurrentTime() .. GetTime() .. random(0, 999999) .. '.jx3dat'
	CPath.MakeDir(DECODE_ROOT)
	SaveDataToFile(szText, DECODE_PATH)
	local data = LoadLUAData(DECODE_PATH)
	CPath.DelFile(DECODE_PATH)
	return data
end
-----------------------------------------------
-- ��ȡ����
-----------------------------------------------
local function Get(var, keys, dft)
	local res = false
	if type(keys) == 'string' then
		local ks = {}
		for k in gmatch(keys, '[^%.]+') do
			insert(ks, k)
		end
		keys = ks
	end
	if type(keys) == 'table' then
		for _, k in ipairs(keys) do
			if type(var) == 'table' then
				var, res = var[k], true
			else
				var, res = dft, false
				break
			end
		end
	end
	if var == nil then
		var, res = dft, false
	end
	return var, res
end
-----------------------------------------------
-- ��������
-----------------------------------------------
local function Set(var, keys, val)
	local res = false
	if type(keys) == 'string' then
		local ks = {}
		for k in gmatch(keys, '[^%.]+') do
			insert(ks, k)
		end
		keys = ks
	end
	if type(keys) == 'table' then
		local n = #keys
		for i = 1, n do
			local k = keys[i]
			if type(var) == 'table' then
				if i == n then
					var[k], res = val, true
				else
					if var[k] == nil then
						var[k] = {}
					end
					var = var[k]
				end
			else
				break
			end
		end
	end
	return res
end
-----------------------------------------------
-- �ж��Ƿ�Ϊ��
-----------------------------------------------
local function IsEmpty(var)
	local szType = type(var)
	if szType == 'nil' then
		return true
	elseif szType == 'boolean' then
		return var
	elseif szType == 'number' then
		return var == 0
	elseif szType == 'string' then
		return var == ''
	elseif szType == 'function' then
		return false
	elseif szType == 'table' then
		for _, _ in pairs(var) do
			return false
		end
		return true
	else
		return false
	end
end
-----------------------------------------------
-- ����ж����
-----------------------------------------------
local function IsEquals(o1, o2)
	if o1 == o2 then
		return true
	elseif type(o1) ~= type(o2) then
		return false
	elseif type(o1) == 'table' then
		local t = {}
		for k, v in pairs(o1) do
			if IsEquals(o1[k], o2[k]) then
				t[k] = true
			else
				return false
			end
		end
		for k, v in pairs(o2) do
			if not t[k] then
				return false
			end
		end
		return true
	end
	return false
end
-----------------------------------------------
-- �������
-----------------------------------------------
local function RandomChild(var)
	if type(var) == 'table' and #var > 0 then
		return var[random(1, #var)]
	end
end
-----------------------------------------------
-- ���������ж�
-----------------------------------------------
local function IsArray(var)
	if type(var) ~= 'table' then
		return false
	end
	local i = 1
	for k, _ in pairs(var) do
		if k ~= i then
			return false
		end
		i = i + 1
	end
	return true
end
local function IsDictionary(var)
	if type(var) ~= 'table' then
		return false
	end
	local i = 1
	for k, _ in pairs(var) do
		if k ~= i then
			return true
		end
		i = i + 1
	end
	return false
end
local function IsNil     (var) return type(var) == 'nil'      end
local function IsTable   (var) return type(var) == 'table'    end
local function IsNumber  (var) return type(var) == 'number'   end
local function IsString  (var) return type(var) == 'string'   end
local function IsBoolean (var) return type(var) == 'boolean'  end
local function IsFunction(var) return type(var) == 'function' end
local function IsUserdata(var) return type(var) == 'userdata' end
local function IsHugeNumber(var) return IsNumber(var) and not (var < HUGE) end
local function IsElement(element) return type(element) == 'table' and element.IsValid and element:IsValid() or false end
-----------------------------------------------
-- �������ݲ���
-----------------------------------------------
local function GetPatch(oBase, oData)
	-- dictionary patch
	if IsDictionary(oData) or (IsDictionary(oBase) and IsTable(oData) and IsEmpty(oData)) then
		-- dictionary raw value patch
		if not IsTable(oBase) then
			return { v = oData }
		end
		-- dictionary children patch
		local tKeys, bDiff = {}, false
		local oPatch = {}
		for k, v in pairs(oData) do
			local patch = GetPatch(oBase[k], v)
			if not IsNil(patch) then
				bDiff = true
				insert(oPatch, { k = k, v = patch })
			end
			tKeys[k] = true
		end
		for k, v in pairs(oBase) do
			if not tKeys[k] then
				bDiff = true
				insert(oPatch, { k = k, v = nil })
			end
		end
		if not bDiff then
			return nil
		end
		return oPatch
	end
	if not IsEquals(oBase, oData) then
		-- nil value patch
		if IsNil(oData) then
			return { t = 'nil' }
		end
		-- table value patch
		if IsTable(oData) then
			return { v = oData }
		end
		-- other patch value
		return oData
	end
	-- empty patch
	return nil
end
-----------------------------------------------
-- ����Ӧ�ò���
-----------------------------------------------
local function ApplyPatch(oBase, oPatch, bNew)
	if bNew ~= false then
		oBase = Clone(oBase)
		oPatch = Clone(oPatch)
	end
	-- patch in dictionary type can only be a special value patch
	if IsDictionary(oPatch) then
		-- nil value patch
		if oPatch.t == 'nil' then
			return nil
		end
		-- raw value patch
		if not IsNil(oPatch.v) then
			return oPatch.v
		end
	end
	-- dictionary patch
	if IsTable(oPatch) and IsDictionary(oPatch[1]) then
		if not IsTable(oBase) then
			oBase = {}
		end
		for _, patch in ipairs(oPatch) do
			if IsNil(patch.v) then
				oBase[patch.k] = nil
			else
				oBase[patch.k] = ApplyPatch(oBase[patch.k], patch.v, false)
			end
		end
		return oBase
	end
	-- empty patch
	if IsNil(oPatch) then
		return oBase
	end
	-- other patch value
	return oPatch
end
-----------------------------------------------
-- ѡ���� ����
-----------------------------------------------
local ipairs_r
do
local function fnBpairs(tab, nIndex)
	nIndex = nIndex - 1
	if nIndex > 0 then
		return nIndex, tab[nIndex]
	end
end
function ipairs_r(tab)
	return fnBpairs, tab, #tab + 1
end
end
-----------------------------------------------
-- ֻ����ѡ����
-----------------------------------------------
-- -- ֻ�����ֵ�ö��
-- local pairs_c = pairs_c or function(t, ...)
-- 	if type(t) == 'table' then
-- 		local metatable = getmetatable(t)
-- 		if type(metatable) == 'table' and metatable.const_table then
-- 			return pairs(metatable.const_table, ...)
-- 		end
-- 	end
-- 	return pairs(t, ...)
-- end
-- -- ֻ��������ö��
-- local ipairs_c = ipairs_c or function(t, ...)
-- 	if type(t) == 'table' then
-- 		local metatable = getmetatable(t)
-- 		if type(metatable) == 'table' and metatable.const_table then
-- 			return ipairs(metatable.const_table, ...)
-- 		end
-- 	end
-- 	return ipairs(t, ...)
-- end
-----------------------------------------------
-- ���Ͱ�ȫѡ����
-----------------------------------------------
local spairs, sipairs, spairs_r, sipairs_r
do
local function SafeIter(a, i)
	i = i + 1
	if a[i] then
		return i, a[i][1], a[i][2], a[i][3]
	end
end
function sipairs(...)
	local argc = select('#', ...)
	local argv = {...}
	local iters = {}
	for i = 1, argc do
		if IsTable(argv[i]) then
			for j, v in ipairs(argv[i]) do
				insert(iters, {v, argv[i], j})
			end
		end
	end
	return SafeIter, iters, 0
end
function spairs(...)
	local argc = select('#', ...)
	local argv = {...}
	local iters = {}
	for i = 1, argc do
		if IsTable(argv[i]) then
			for j, v in pairs(argv[i]) do
				insert(iters, {v, argv[i], j})
			end
		end
	end
	return SafeIter, iters, 0
end
local function SafeIterR(a, i)
	i = i - 1
	if i > 0 then
		return i, a[i][1], a[i][2], a[i][3]
	end
end
function sipairs_r(...)
	local argc = select('#', ...)
	local argv = {...}
	local iters = {}
	for i = 1, argc do
		if IsTable(argv[i]) then
			for j, v in ipairs(argv[i]) do
				insert(iters, {v, argv[i], j})
			end
		end
	end
	return SafeIterR, iters, #iters + 1
end
function spairs_r(...)
	local argc = select('#', ...)
	local argv = {...}
	local iters = {}
	for i = 1, argc do
		if IsTable(argv[i]) then
			for j, v in pairs(argv[i]) do
				insert(iters, {v, argv[i], j})
			end
		end
	end
	return SafeIterR, iters, #iters + 1
end
end
-----------------------------------------------
-- ��
-----------------------------------------------
local Class
do
local function createInstance(c, ins, ...)
	if not ins then
		ins = c
	end
	if c.ctor then
		c.ctor(ins, ...)
	end
	return c
end
function Class(className, super)
	local classPrototype
	if type(super) == 'string' then
		className, super = super, nil
	end
	if not className then
		className = 'Unnamed Class'
	end
	classPrototype = (function ()
		local proxys = {}
		if super then
			proxys.super = super
			setmetatable(proxys, { __index = super })
		end
		return setmetatable({}, {
			__index = proxys,
			__tostring = function(t) return className .. ' (class prototype)' end,
			__call = function (...)
				return createInstance(setmetatable({}, {
					__index = classPrototype,
					__tostring = function(t) return className .. ' (class instance)' end,
				}), nil, ...)
			end,
		})
	end)()
	return classPrototype
end
end
-----------------------------------------------
-- ��ȡ����ջ
-----------------------------------------------
local TRACEBACK_DEL = ('\n[^\n]*' .. _NAME_SPACE_ .. '%.lua:%d+:%sin%sfunction%s\'GetTraceback\'[^\n]*'):gsub("(%%?)(.)", function(percent, letter)
    if percent ~= "" or not letter:match("%a") then
		-- if the '%' matched, or `letter` is not a letter, return "as is"
		return percent .. letter
    else
		-- else, return a case-insensitive character class of the matched letter
		return format("[%s%s]", letter:lower(), letter:upper())
    end
end)
local function GetTraceback(str)
	local traceback = debug and debug.traceback and debug.traceback():gsub(TRACEBACK_DEL, '')
	if traceback then
		if str then
			str = str .. '\n' .. traceback
		else
			str = traceback
		end
	end
	return str or ''
end
-----------------------------------------------
-- ��ȫ����
-----------------------------------------------
local Call, XpCall
do
local xpAction, xpArgs, xpErrMsg, xpTraceback
local function CallHandler()
	return xpAction(unpack(xpArgs))
end
local function CallErrorHandler(errMsg)
	xpErrMsg = errMsg
	xpTraceback = GetTraceback()
	FireUIEvent("CALL_LUA_ERROR", GetTraceback(errMsg) .. '\n')
end
local function XpCallErrorHandler(errMsg)
	xpErrMsg = errMsg
	xpTraceback = GetTraceback()
end
function Call(arg0, ...)
	xpAction, xpArgs, xpErrMsg, xpTraceback = arg0, {...}, nil, nil
	local res = {xpcall(CallHandler, CallErrorHandler)}
	if not res[1] then
		res[2] = xpErrMsg
		res[3] = xpTraceback
	end
	xpAction, xpArgs, xpErrMsg, xpTraceback = nil, nil, nil, nil
	return unpack(res)
end
function XpCall(arg0, ...)
	xpAction, xpArgs, xpErrMsg, xpTraceback = arg0, {...}, nil, nil
	local res = {xpcall(CallHandler, XpCallErrorHandler)}
	if not res[1] then
		res[2] = xpErrMsg
		res[3] = xpTraceback
	end
	xpAction, xpArgs, xpErrMsg, xpTraceback = nil, nil, nil, nil
	return unpack(res)
end
end
local function SafeCall(f, ...)
	if not IsFunction(f) then
		return false
	end
	return Call(f, ...)
end

local NSFormatString
do local CACHE = {}
function NSFormatString(s)
	if not CACHE[s] then
		CACHE[s] = wgsub(s, '{$NS}', _NAME_SPACE_)
	end
	return CACHE[s]
end
end

local function GetGameAPI(szAddon, szInside)
	local api = _G[szAddon]
	if not api then
		local env = GetInsideEnv()
		if env then
			api = env[szInside or szAddon]
		end
	end
	return api
end
-----------------------------------------------
-- �������Ϣ
-----------------------------------------------
local PACKET_INFO
do
local tInfo = {
	NAME                  = _NAME_                 ,
	SHORT_NAME            = _SHORT_NAME_           ,
	VERSION               = _VERSION_              ,
	NATURAL_VERSION       = _NATURAL_VERSION_      ,
	BUILD                 = _BUILD_                ,
	NAME_SPACE            = _NAME_SPACE_           ,
	DEBUG_LEVEL           = _DEBUG_LEVEL_          ,
	DELOG_LEVEL           = _DELOG_LEVEL_          ,
	INTERFACE_ROOT        = _INTERFACE_ROOT_       ,
	ROOT                  = _ADDON_ROOT_           ,
	DATA_ROOT             = _DATA_ROOT_            ,
	FRAMEWORK_ROOT        = _FRAMEWORK_ROOT_       ,
	UICOMPONENT_ROOT      = _UICOMPONENT_ROOT_     ,
	LOGO_UITEX            = _LOGO_UITEX_           ,
	LOGO_MAIN_FRAME       = _LOGO_MAIN_FRAME_      ,
	LOGO_MENU_FRAME       = _LOGO_MENU_FRAME_      ,
	LOGO_MENU_HOVER_FRAME = _LOGO_MENU_HOVER_FRAME_,
	POSTER_UITEX          = _POSTER_UITEX_         ,
	POSTER_FRAME_COUNT    = _POSTER_FRAME_COUNT_   ,
	AUTHOR                = _AUTHOR_               ,
	AUTHOR_WEIBO          = _AUTHOR_WEIBO_         ,
	AUTHOR_WEIBO_URL      = _AUTHOR_WEIBO_URL_     ,
	AUTHOR_SIGNATURE      = _AUTHOR_SIGNATURE_     ,
	AUTHOR_ROLES          = _AUTHOR_ROLES_         ,
	AUTHOR_HEADER         = _AUTHOR_HEADER_        ,
	AUTHOR_PROTECT_NAMES  = _AUTHOR_PROTECT_NAMES_ ,
	AUTHOR_FAKE_HEADER    = _AUTHOR_FAKE_HEADER_   ,
	MENU_COLOR            = _MENU_COLOR_           ,
	MAX_PLAYER_LEVEL      = _MAX_PLAYER_LEVEL_     ,
}
PACKET_INFO = SetmetaReadonly(tInfo)
-- ���������ҵȼ�����
local function onPlayerEnterScene()
	_MAX_PLAYER_LEVEL_ = max(_MAX_PLAYER_LEVEL_, GetClientPlayer().nMaxLevel)
	tInfo.MAX_PLAYER_LEVEL = _MAX_PLAYER_LEVEL_
end
RegisterEvent('PLAYER_ENTER_SCENE', onPlayerEnterScene)
end
-----------------------------------------------
-- ö��
-----------------------------------------------
local function KvpToObject(kvp)
	local t = {}
	for _, v in ipairs(kvp) do
		if not IsNil(v[1]) then
			t[v[1]] = v[2]
		end
	end
	return t
end
local GLOBAL = setmetatable({}, {
	__index = setmetatable({
		GAME_LANG     = _GAME_LANG_   ,
		GAME_BRANCH  = _GAME_BRANCH_,
		GAME_EDITION  = _GAME_EDITION_,
		GAME_VERSION  = _GAME_VERSION_,
	}, { __index = _G.GLOBAL }),
	__newindex = function() end,
})
local PATH_TYPE = SetmetaReadonly({
	NORMAL = 0,
	DATA   = 1,
	ROLE   = 2,
	GLOBAL = 3,
	SERVER = 4,
})
local FORCE_TYPE = FORCE_TYPE or SetmetaReadonly({
	JIANG_HU  = 0 , -- ����
	SHAO_LIN  = 1 , -- ����
	WAN_HUA   = 2 , -- ��
	TIAN_CE   = 3 , -- ���
	CHUN_YANG = 4 , -- ����
	QI_XIU    = 5 , -- ����
	WU_DU     = 6 , -- �嶾
	TANG_MEN  = 7 , -- ����
	CANG_JIAN = 8 , -- �ؽ�
	GAI_BANG  = 9 , -- ؤ��
	MING_JIAO = 10, -- ����
	CANG_YUN  = 21, -- ����
	LING_XUE  = 25, -- ��ѩ
	YAN_TIAN  = 211, -- ����
})
local CONSTANT = setmetatable({}, {
	__index = {
		MENU_DIVIDER = SetmetaReadonly({ bDevide = true }),
		EMPTY_TABLE = SetmetaReadonly({}),
		XML_LINE_BREAKER = GetFormatText('\n'),
		UI_OBJECT = UI_OBJECT or SetmetaReadonly({
			NONE             = -1, -- ��Box
			ITEM             = 0 , -- �����е���Ʒ��nUiId, dwBox, dwX, nItemVersion, nTabType, nIndex
			SHOP_ITEM        = 1 , -- �̵�������۵���Ʒ nUiId, dwID, dwShopID, dwIndex
			OTER_PLAYER_ITEM = 2 , -- ����������ϵ���Ʒ nUiId, dwBox, dwX, dwPlayerID
			ITEM_ONLY_ID     = 3 , -- ֻ��һ��ID����Ʒ������װ������֮��ġ�nUiId, dwID, nItemVersion, nTabType, nIndex
			ITEM_INFO        = 4 , -- ������Ʒ nUiId, nItemVersion, nTabType, nIndex, nCount(��nCount����dwRecipeID)
			SKILL            = 5 , -- ���ܡ�dwSkillID, dwSkillLevel, dwOwnerID
			CRAFT            = 6 , -- ���ա�dwProfessionID, dwBranchID, dwCraftID
			SKILL_RECIPE     = 7 , -- �䷽dwID, dwLevel
			SYS_BTN          = 8 , -- ϵͳ����ݷ�ʽdwID
			MACRO            = 9 , -- ��
			MOUNT            = 10, -- ��Ƕ
			ENCHANT          = 11, -- ��ħ
			NOT_NEED_KNOWN   = 15, -- ����Ҫ֪������
			PENDANT          = 16, -- �Ҽ�
			PET              = 17, -- ����
			MEDAL            = 18, -- �������
			BUFF             = 19, -- BUFF
			MONEY            = 20, -- ��Ǯ
			TRAIN            = 21, -- ��Ϊ
			EMOTION_ACTION   = 22, -- ��������
		}),
		GLOBAL_HEAD = GLOBAL_HEAD or SetmetaReadonly({
			CLIENTPLAYER = 0,
			OTHERPLAYER  = 1,
			NPC          = 2,
			LIFE         = 0,
			GUILD        = 1,
			TITLE        = 2,
			NAME         = 3,
			MARK         = 4,
		}),
		EQUIPMENT_SUB = EQUIPMENT_SUB or SetmetaReadonly({
			MELEE_WEAPON      = 0 , -- ��ս����
			RANGE_WEAPON      = 1 , -- Զ������
			CHEST             = 2 , -- ����
			HELM              = 3 , -- ͷ��
			AMULET            = 4 , -- ����
			RING              = 5 , -- ��ָ
			WAIST             = 6 , -- ����
			PENDANT           = 7 , -- ��׺
			PANTS             = 8 , -- ����
			BOOTS             = 9 , -- Ь��
			BANGLE            = 10, -- ����
			WAIST_EXTEND      = 11, -- �����Ҽ�
			PACKAGE           = 12, -- ����
			ARROW             = 13, -- ����
			BACK_EXTEND       = 14, -- �����Ҽ�
			HORSE             = 15, -- ����
			BULLET            = 16, -- �������
			FACE_EXTEND       = 17, -- �����Ҽ�
			MINI_AVATAR       = 18, -- Сͷ��
			PET               = 19, -- ����
			L_SHOULDER_EXTEND = 20, -- ���Ҽ�
			R_SHOULDER_EXTEND = 21, -- �Ҽ�Ҽ�
			BACK_CLOAK_EXTEND = 22, -- ����
			TOTAL             = 23, --
		}),
		EQUIPMENT_INVENTORY = EQUIPMENT_INVENTORY or SetmetaReadonly({
			MELEE_WEAPON  = 1 , -- ��ͨ��ս����
			BIG_SWORD     = 2 , -- �ؽ�
			RANGE_WEAPON  = 3 , -- Զ������
			CHEST         = 4 , -- ����
			HELM          = 5 , -- ͷ��
			AMULET        = 6 , -- ����
			LEFT_RING     = 7 , -- ���ֽ�ָ
			RIGHT_RING    = 8 , -- ���ֽ�ָ
			WAIST         = 9 , -- ����
			PENDANT       = 10, -- ��׺
			PANTS         = 11, -- ����
			BOOTS         = 12, -- Ь��
			BANGLE        = 13, -- ����
			PACKAGE1      = 14, -- ��չ����1
			PACKAGE2      = 15, -- ��չ����2
			PACKAGE3      = 16, -- ��չ����3
			PACKAGE4      = 17, -- ��չ����4
			PACKAGE_MIBAO = 18, -- �󶨰�ȫ��Ʒ״̬�����͵Ķ��ⱳ���� ��ItemList V9������
			BANK_PACKAGE1 = 19, -- �ֿ���չ����1
			BANK_PACKAGE2 = 20, -- �ֿ���չ����2
			BANK_PACKAGE3 = 21, -- �ֿ���չ����3
			BANK_PACKAGE4 = 22, -- �ֿ���չ����4
			BANK_PACKAGE5 = 23, -- �ֿ���չ����5
			ARROW         = 24, -- ����
			TOTAL         = 25,
		}),
		FORCE_TYPE = FORCE_TYPE,
		KUNGFU_TYPE = KUNGFU_TYPE or SetmetaReadonly({
			TIAN_CE     = 1,      -- ����ڹ�
			WAN_HUA     = 2,      -- ���ڹ�
			CHUN_YANG   = 3,      -- �����ڹ�
			QI_XIU      = 4,      -- �����ڹ�
			SHAO_LIN    = 5,      -- �����ڹ�
			CANG_JIAN   = 6,      -- �ؽ��ڹ�
			GAI_BANG    = 7,      -- ؤ���ڹ�
			MING_JIAO   = 8,      -- �����ڹ�
			WU_DU       = 9,      -- �嶾�ڹ�
			TANG_MEN    = 10,     -- �����ڹ�
			CANG_YUN    = 18,     -- �����ڹ�
			LING_XUE    = 22,     -- ��ѩ�ڹ�
			YAN_TIAN    = 23,     -- �����ڹ�
		}),
		PEEK_OTHER_PLAYER_RESPOND = PEEK_OTHER_PLAYER_RESPOND or SetmetaReadonly({
			INVALID             = 0,
			SUCCESS             = 1,
			FAILED              = 2,
			CAN_NOT_FIND_PLAYER = 3,
			TOO_FAR             = 4,
		}),
		WND_CONTAINER_STYLE = _G.WND_CONTAINER_STYLE or SetmetaReadonly({
			CUSTOM       = 0,
			LEFT_TOP     = 1,
			LEFT_BOTTOM  = 2,
			RIGHT_TOP    = 3,
			RIGHT_BOTTOM = 4,
			END          = 5,
		}),
		MIC_STATE = MIC_STATE or SetmetaReadonly({
			NOT_AVIAL = 1,
			CLOSE_NOT_IN_ROOM = 2,
			CLOSE_IN_ROOM = 3,
			KEY = 4,
			FREE = 5,
		}),
		SPEAKER_STATE = SPEAKER_STATE or SetmetaReadonly({
			OPEN = 1,
			CLOSE = 2,
		}),
		ITEM_QUALITY = SetmetaReadonly({
			GRAY    = 0, -- ��ɫ
			WHITE   = 1, -- ��ɫ
			GREEN   = 2, -- ��ɫ
			BLUE    = 3, -- ��ɫ
			PURPLE  = 4, -- ��ɫ
			NACARAT = 5, -- ��ɫ
			GLODEN  = 6, -- ����
		}),
		CRAFT_TYPE = {
			MINING = 1, --�ɿ�
			HERBALISM = 2, -- ��ũ
			SKINNING = 3, -- �Ҷ�
			READING = 8, -- �Ķ�
		},
		MOBA_MAP = {
			[412] = true, -- ���ǵ�
		},
		STARVE_MAP = {
			[421] = true, -- �˿��С������ѹ�
			[422] = true, -- �˿��С�ɣ���ԭ
			[423] = true, -- �˿��С���ˮկ
			[424] = true, -- �˿��С�����Ϫ
			[425] = true, -- �˿��С��Ļ���
			[433] = true, -- �˿��С��м��ջ
			[434] = true, -- �˿��С�����ɽ
			[435] = true, -- �˿��С����幬
			[436] = true, -- �˿��С�������
			[437] = true, -- �˿��С���ѩ·
			[438] = true, -- �˿��С��ż�̳
			[439] = true, -- �˿��С���ӫ��
			[440] = true, -- �˿��С�����Ͽ
			[441] = true, -- �˿��С��������
			[442] = true, -- �˿��С������ֵ�
			[443] = true, -- �˿��С�������
			[461] = true, -- �˿��С���ӣ��
		},
		-- ��ͬ���ֵĵ�ͼ ȫ��ָ��ͬһ��ID
		MAP_NAME_FIX = {
			[143] = 147, -- ����֮��
			[144] = 147, -- ����֮��
			[145] = 147, -- ����֮��
			[146] = 147, -- ����֮��
			[195] = 196, -- ���Ź�֮��
			[276] = 281, -- �ý�԰
			[278] = 281, -- �ý�԰
			[279] = 281, -- �ý�԰
			[280] = 281, -- �ý�԰
			[296] = 297, -- ���ž���
		},
		NPC_NAME = {},
		NPC_NAME_FIX = {
			[58294] = 62347, -- ��������
		},
		NPC_HIDDEN = {
			[19153] = true, -- �ʹ���Χ�ܿ�
			[27634] = true, -- �ػ��갲»ɽ�ܿ�
			[56383] = true, -- ͨ�ؽ�����ɱ��ֿ���
			[60045] = true, -- ����ǵ�����η��Ĳ�֪��ʲô����
		},
		DOODAD_NAME = {},
		DOODAD_NAME_FIX = {},
		-- skillid, uitex, frame
		KUNGFU_LIST = {
			-- MT
			{ dwID = 10062, nIcon = 632  , szUITex = 'ui/Image/icon/skill_tiance01.UITex'    , nFrame = 0  }, -- ����
			{ dwID = 10243, nIcon = 3864 , szUITex = 'ui/Image/icon/mingjiao_taolu_7.UITex'  , nFrame = 0  }, -- ����
			{ dwID = 10389, nIcon = 6315 , szUITex = 'ui/Image/icon/Skill_CangY_33.UITex'    , nFrame = 0  }, -- ����
			{ dwID = 10002, nIcon = 429  , szUITex = 'ui/Image/icon/skill_shaolin14.UITex'   , nFrame = 0  }, -- ����
			-- ����
			{ dwID = 10080, nIcon = 887  , szUITex = 'ui/Image/icon/skill_qixiu02.UITex'     , nFrame = 0  }, -- ����
			{ dwID = 10176, nIcon = 2767 , szUITex = 'ui/Image/icon/wudu_neigong_2.UITex'    , nFrame = 0  }, -- ����
			{ dwID = 10028, nIcon = 412  , szUITex = 'ui/Image/icon/skill_wanhua23.UITex'    , nFrame = 0  }, -- �뾭
			{ dwID = 10448, nIcon = 7067 , szUITex = 'ui/Image/icon/skill_0514_23.UITex'     , nFrame = 0  }, -- ��֪
			-- �ڹ�
			{ dwID = 10225, nIcon = 3184 , szUITex = 'ui/Image/icon/skill_tangm_20.UITex'    , nFrame = 0  }, -- ����
			{ dwID = 10081, nIcon = 888  , szUITex = 'ui/Image/icon/skill_qixiu03.UITex'     , nFrame = 0  }, -- ����
			{ dwID = 10175, nIcon = 2766 , szUITex = 'ui/Image/icon/wudu_neigong_1.UITex'    , nFrame = 0  }, -- ����
			{ dwID = 10242, nIcon = 3865 , szUITex = 'ui/Image/icon/mingjiao_taolu_8.UITex'  , nFrame = 0  }, -- ��Ӱ
			{ dwID = 10014, nIcon = 627  , szUITex = 'ui/Image/icon/skill_chunyang21.UITex'  , nFrame = 0  }, -- ��ϼ
			{ dwID = 10021, nIcon = 406  , szUITex = 'ui/Image/icon/skill_wanhua17.UITex'    , nFrame = 0  }, -- ����
			{ dwID = 10003, nIcon = 425  , szUITex = 'ui/Image/icon/skill_shaolin10.UITex'   , nFrame = 0  }, -- �׾�
			{ dwID = 10447, nIcon = 7071 , szUITex = 'ui/Image/icon/skill_0514_27.UITex'     , nFrame = 0  }, -- Ī��
			{ dwID = 10615, nIcon = 13894, szUITex = 'ui/image/icon/skill_20_9_14_1.uitex'   , nFrame = 19 }, -- ̫��
			-- �⹦
			{ dwID = 10390, nIcon = 6314 , szUITex = 'ui/Image/icon/Skill_CangY_32.UITex'    , nFrame = 0  }, -- ��ɽ
			{ dwID = 10224, nIcon = 3165 , szUITex = 'ui/Image/icon/skill_tangm_01.UITex'    , nFrame = 0  }, -- ����
			{ dwID = 10144, nIcon = 2376 , szUITex = 'ui/Image/icon/cangjian_neigong_1.UITex', nFrame = 0  }, -- ��ˮ
			{ dwID = 10145, nIcon = 2377 , szUITex = 'ui/Image/icon/cangjian_neigong_2.UITex', nFrame = 0  }, -- ɽ��
			{ dwID = 10015, nIcon = 619  , szUITex = 'ui/Image/icon/skill_chunyang13.UITex'  , nFrame = 0  }, -- ����
			{ dwID = 10026, nIcon = 633  , szUITex = 'ui/Image/icon/skill_tiance02.UITex'    , nFrame = 0  }, -- ��ѩ
			{ dwID = 10268, nIcon = 4610 , szUITex = 'ui/Image/icon/skill_GB_30.UITex'       , nFrame = 0  }, -- Ц��
			{ dwID = 10464, nIcon = 8424 , szUITex = 'ui/Image/icon/daoj_16_8_25_16.UITex'   , nFrame = 0  }, -- �Ե�
			{ dwID = 10533, nIcon = 10709, szUITex = 'ui/image/icon/JNPL_18_10_30_27.uitex'  , nFrame = 45 }, -- ����
			{ dwID = 10585, nIcon = 12128, szUITex = 'ui/image/icon/JNLXG_19_10_21_9.uitex'  , nFrame = 74 }, -- ��ѩ
		},
		FORCE_AVATAR = setmetatable(
			KvpToObject({
				{ FORCE_TYPE.JIANG_HU , {'ui\\Image\\PlayerAvatar\\jianghu.tga'  , -2, false} }, -- ����
				{ FORCE_TYPE.SHAO_LIN , {'ui\\Image\\PlayerAvatar\\shaolin.tga'  , -2, false} }, -- ����
				{ FORCE_TYPE.WAN_HUA  , {'ui\\Image\\PlayerAvatar\\wanhua.tga'   , -2, false} }, -- ��
				{ FORCE_TYPE.TIAN_CE  , {'ui\\Image\\PlayerAvatar\\tiance.tga'   , -2, false} }, -- ���
				{ FORCE_TYPE.CHUN_YANG, {'ui\\Image\\PlayerAvatar\\chunyang.tga' , -2, false} }, -- ����
				{ FORCE_TYPE.QI_XIU   , {'ui\\Image\\PlayerAvatar\\qixiu.tga'    , -2, false} }, -- ����
				{ FORCE_TYPE.WU_DU    , {'ui\\Image\\PlayerAvatar\\wudu.tga'     , -2, false} }, -- �嶾
				{ FORCE_TYPE.TANG_MEN , {'ui\\Image\\PlayerAvatar\\tangmen.tga'  , -2, false} }, -- ����
				{ FORCE_TYPE.CANG_JIAN, {'ui\\Image\\PlayerAvatar\\cangjian.tga' , -2, false} }, -- �ؽ�
				{ FORCE_TYPE.GAI_BANG , {'ui\\Image\\PlayerAvatar\\gaibang.tga'  , -2, false} }, -- ؤ��
				{ FORCE_TYPE.MING_JIAO, {'ui\\Image\\PlayerAvatar\\mingjiao.tga' , -2, false} }, -- ����
				{ FORCE_TYPE.CANG_YUN , {'ui\\Image\\PlayerAvatar\\cangyun.tga'  , -2, false} }, -- ����
				{ FORCE_TYPE.CHANG_GE , {'ui\\Image\\PlayerAvatar\\changge.tga'  , -2, false} }, -- ����
				{ FORCE_TYPE.BA_DAO   , {'ui\\Image\\PlayerAvatar\\badao.tga'    , -2, false} }, -- �Ե�
				{ FORCE_TYPE.PENG_LAI , {'ui\\Image\\PlayerAvatar\\penglai.tga'  , -2, false} }, -- ����
				{ FORCE_TYPE.LING_XUE , {'ui\\Image\\PlayerAvatar\\lingxuege.tga', -2, false} }, -- ��ѩ
			}),
			{
				__index = function(t, k)
					return t[FORCE_TYPE.JIANG_HU]
				end,
				__metatable = true,
			}),
		FORCE_COLOR_FG_DEFAULT = setmetatable(
			KvpToObject({
				{ FORCE_TYPE.JIANG_HU , { 255, 255, 255 } }, -- ����
				{ FORCE_TYPE.SHAO_LIN , { 255, 178,  95 } }, -- ����
				{ FORCE_TYPE.WAN_HUA  , { 196, 152, 255 } }, -- ��
				{ FORCE_TYPE.TIAN_CE  , { 255, 111,  83 } }, -- ���
				{ FORCE_TYPE.CHUN_YANG, {  22, 216, 216 } }, -- ����
				{ FORCE_TYPE.QI_XIU   , { 255, 129, 176 } }, -- ����
				{ FORCE_TYPE.WU_DU    , {  55, 147, 255 } }, -- �嶾
				{ FORCE_TYPE.TANG_MEN , { 121, 183,  54 } }, -- ����
				{ FORCE_TYPE.CANG_JIAN, { 214, 249,  93 } }, -- �ؽ�
				{ FORCE_TYPE.GAI_BANG , { 205, 133,  63 } }, -- ؤ��
				{ FORCE_TYPE.MING_JIAO, { 240,  70,  96 } }, -- ����
				{ FORCE_TYPE.CANG_YUN , IsStreaming() and { 255, 143, 80 } or { 180, 60, 0 } }, -- ����
				{ FORCE_TYPE.CHANG_GE , { 100, 250, 180 } }, -- ����
				{ FORCE_TYPE.BA_DAO   , { 106, 108, 189 } }, -- �Ե�
				{ FORCE_TYPE.PENG_LAI , { 171, 227, 250 } }, -- ����
				{ FORCE_TYPE.LING_XUE , IsStreaming() and { 253, 86, 86 } or { 161,   9,  34 } }, -- ��ѩ
				{ FORCE_TYPE.YAN_TIAN , { 166,  83, 251 } }, -- ����
			}),
			{
				__index = function(t, k)
					return { 225, 225, 225 }
				end,
				__metatable = true,
			}),
		FORCE_COLOR_BG_DEFAULT = setmetatable(
			KvpToObject({
				{ FORCE_TYPE.JIANG_HU , { 220, 220, 220 } }, -- ����
				{ FORCE_TYPE.SHAO_LIN , { 125, 112,  10 } }, -- ����
				{ FORCE_TYPE.WAN_HUA  , {  47,  14,  70 } }, -- ��
				{ FORCE_TYPE.TIAN_CE  , { 105,  14,  14 } }, -- ���
				{ FORCE_TYPE.CHUN_YANG, {   8,  90, 113 } }, -- ���� 56,175,255,232
				{ FORCE_TYPE.QI_XIU   , { 162,  74, 129 } }, -- ����
				{ FORCE_TYPE.WU_DU    , {   7,  82, 154 } }, -- �嶾
				{ FORCE_TYPE.TANG_MEN , {  75, 113,  40 } }, -- ����
				{ FORCE_TYPE.CANG_JIAN, { 148, 152,  27 } }, -- �ؽ�
				{ FORCE_TYPE.GAI_BANG , { 159, 102,  37 } }, -- ؤ��
				{ FORCE_TYPE.MING_JIAO, { 145,  80,  17 } }, -- ����
				{ FORCE_TYPE.CANG_YUN , { 157,  47,   2 } }, -- ����
				{ FORCE_TYPE.CHANG_GE , {  31, 120, 103 } }, -- ����
				{ FORCE_TYPE.BA_DAO   , {  49,  39, 110 } }, -- �Ե�
				{ FORCE_TYPE.PENG_LAI , {  93,  97, 126 } }, -- ����
				{ FORCE_TYPE.LING_XUE , { 161,   9,  34 } }, -- ��ѩ
				{ FORCE_TYPE.YAN_TIAN , {  96,  45, 148 } }, -- ����
			}),
			{
				__index = function(t, k)
					return { 200, 200, 200 } -- NPC �Լ�δ֪����
				end,
				__metatable = true,
			}),
		CAMP_COLOR_FG_DEFAULT = setmetatable(
			KvpToObject({
				{ CAMP.NEUTRAL, { 255, 255, 255 } }, -- ����
				{ CAMP.GOOD   , {  60, 128, 220 } }, -- ������
				{ CAMP.EVIL   , IsStreaming() and { 255, 63, 63 } or { 160, 30, 30 } }, -- ���˹�
			}),
			{
				__index = function(t, k)
					return { 225, 225, 225 }
				end,
				__metatable = true,
			}),
		CAMP_COLOR_BG_DEFAULT = setmetatable(
			KvpToObject({
				{ CAMP.NEUTRAL, { 255, 255, 255 } }, -- ����
				{ CAMP.GOOD   , {  60, 128, 220 } }, -- ������
				{ CAMP.EVIL   , { 160,  30,  30 } }, -- ���˹�
			}),
			{
				__index = function(t, k)
					return { 225, 225, 225 }
				end,
				__metatable = true,
			}),
		MSG_THEME = SetmetaReadonly({
			NORMAL = 0,
			ERROR = 1,
			WARNING = 2,
			SUCCESS = 3,
		}),
		QUEST_INFO = { -- ������Ϣ {����ID, ������NPCģ��ID}
			BIG_WARS = {
				-- 95��
				-- {14765, 869}, -- ��ս��Ӣ��΢ɽ��Ժ��
				-- {14766, 869}, -- ��ս��Ӣ�������֣�
				-- {14767, 869}, -- ��ս��Ӣ�������Ժ��
				-- {14768, 869}, -- ��ս��Ӣ����ɽʥȪ��
				-- {14769, 869}, -- ��ս��Ӣ������ˮ鿣�
				-- 95����
				-- {17816, 869}, -- ��ս��Ӣ�۵������£�
				-- {17817, 869}, -- ��ս��Ӣ���������
				-- {17818, 869}, -- ��ս��Ӣ�۵��ֺ�����
				-- {17819, 869}, -- ��ս��Ӣ��Ϧ�ո�
				-- {17820, 869}, -- ��ս��Ӣ�۰׵�ˮ����
				-- 100��
				-- {19191, 869}, -- ��ս��Ӣ�۾ű�ݣ�
				-- {19192, 869}, -- ��ս��Ӣ���������죡
				-- {19195, 869}, -- ��ս��Ӣ�۾�������
				-- {19196, 869}, -- ��ս��Ӣ�۴�����˿����
				-- {19197, 869}, -- ��ս��Ӣ����Ԩ����
				-- {21570, 869}, -- ��ս��Ӣ�����ױ�Ժ��
				-- {21572, 869}, -- ��ս��Ӣ�������죡
				-- 110��
				{22939, 869}, -- ��ս��Ӣ�۽�ڣ���䣡
				{22941, 869}, -- ��ս��Ӣ����ͩɽׯ��
				{22942, 869}, -- ��ս��Ӣ���������ǣ�
				{22950, 869}, -- ��ս��Ӣ���޺��ţ�
				{22951, 869}, -- ��ս��Ӣ�����뼯�浺��
			},
			TEAHOUSE_ROUTINE = {
				-- 90��
				-- {11115}, -- �������̽�����
				-- 95��
				-- {14246, 45009}, -- ���������в�
				-- 100��
				-- {19514, 63734}, -- �׺��Ʒ��Ų���
				-- 110��
				{22700, 63734}, -- ����������ƽ��
			},
			PUBLIC_ROUTINE = {
				{14831, 869}, -- ������Զ��������
			},
			ROOKIE_ROUTINE = {{21433, 67083}},
			CAMP_CRYSTAL_SCRAMBLE = {
				[CAMP.GOOD] = {
					-- {14727, 46968}, -- ��ھ���������
					-- {14729, 46968}, -- ��ھ���������
					-- {14893, 62002}, -- �����ˣ�ľ�����Ϸ�����
					-- {18904, 62002}, -- ��Դ��������
					-- {19200, 62002}, -- ��Դ��������
					-- {19310, 62002}, -- ��Դ��������
					-- {19719, 62002}, -- ���׵�ԴѰ����
					-- 100����
					-- {20306, 67195}, -- ľ�����Ϸ�����
					-- {20307, 67195}, -- ľ�����Ϸ�����
					-- {20308, 67195}, -- ľ�����Ϸ�����
					-- 110��
					{22195, 100967}, -- ���Ӻ���Σ��Ǳ
					{22196, 100967}, -- ���Ӻ���Σ��Ǳ
					{22197, 100967}, -- ���Ӻ���Σ��Ǳ
					{22680, 67195}, -- �������϶����
				},
				[CAMP.EVIL] = {
					-- {14728, 46969}, -- ��ھ���������
					-- {14730, 46969}, -- ��ھ���������
					-- {14894, 62039}, -- ���˹ȣ�ľ�����Ϸ�����
					-- {18936, 62039}, -- ��Դ��������
					-- {19201, 62039}, -- ��Դ��������
					-- {19311, 62039}, -- ��Դ��������
					-- {19720, 62039}, -- ���׵�ԴѰ����
					-- 100����
					-- {20309, 67196}, -- ľ�����Ϸ�����
					-- {20310, 67196}, -- ľ�����Ϸ�����
					-- {20311, 67196}, -- ľ�����Ϸ�����
					-- 110��
					{22198, 100961}, -- ���Ӻ���Σ��Ǳ
					{22199, 100961}, -- ���Ӻ���Σ��Ǳ
					{22200, 100961}, -- ���Ӻ���Σ��Ǳ
					{22679, 67196}, -- �������϶����
				},
			},
			CAMP_STRONGHOLD_TRADE = {
				[CAMP.GOOD] = {
					{11864, 36388}, -- �ݵ�ó�ף�������
				},
				[CAMP.EVIL] = {
					{11991, 36387}, -- �ݵ�ó�ף����˹�
				},
			},
			DRAGON_GATE_DESPAIR = {
				{17895, 59149},
			},
			LEXUS_REALITY = {
				{20220, 64489},
			},
			LIDU_GHOST_TOWN = {
				{18317, 64489},
			},
			FORCE_ROUTINE = KvpToObject({
				{ FORCE_TYPE.TIAN_CE  , {{8206, 16747}, {11254, 16747}, {11255, 16747}} }, -- ���
				{ FORCE_TYPE.CHUN_YANG, {{8347, 16747}, {8398, 16747}} }, -- ����
				{ FORCE_TYPE.WAN_HUA  , {{8348, 16747}, {8399, 16747}, {22842, 16747}, {22929, 16747}} }, -- ��
				{ FORCE_TYPE.SHAO_LIN , {{8349, 16747}, {8400, 16747}, {22851, 16747}, {22930, 16747}} }, -- ����
				{ FORCE_TYPE.QI_XIU   , {{8350, 16747}, {8401, 16747}, {22757, 16747}, {22758, 16747}} }, -- ����
				{ FORCE_TYPE.CANG_JIAN, {{8351, 16747}, {8402, 16747}, {22766, 16747}, {22767, 16747}} }, -- �ؽ�
				{ FORCE_TYPE.WU_DU    , {{8352, 16747}, {8403, 16747}} }, -- �嶾
				{ FORCE_TYPE.TANG_MEN , {{8353, 16747}, {8404, 16747}} }, -- ����
				{ FORCE_TYPE.MING_JIAO, {{9796, 16747}, {9797, 16747}} }, -- ����
				{ FORCE_TYPE.GAI_BANG , {{11245, 16747}, {11246, 16747}} }, -- ؤ��
				{ FORCE_TYPE.CANG_YUN , {{12701, 16747}, {12702, 16747}} }, -- ����
				{ FORCE_TYPE.CHANG_GE , {{14731, 16747}, {14732, 16747}} }, -- ����
				{ FORCE_TYPE.BA_DAO   , {{16205, 16747}, {16206, 16747}} }, -- �Ե�
				{ FORCE_TYPE.PENG_LAI , {{19225, 16747}, {19226, 16747}} }, -- ����
				{ FORCE_TYPE.LING_XUE , {{21067, 16747}, {21068, 16747}} }, -- ��ѩ
				{ FORCE_TYPE.YAN_TIAN , {{22775, 16747}, {22776, 16747}} }, -- ����
			}),
			PICKING_FAIRY_GRASS = {{8332, 16747}},
			FIND_DRAGON_VEINS = {{13600, 16747}},
			SNEAK_ROUTINE = {{7669, 16747}},
			ILLUSTRATION_ROUTINE = {{8440, 15675}},
		},
		BUFF_INFO = {
			EXAM_SHENG = {{10936, 0}},
			EXAM_HUI = {{4125, 0}},
		},
		SKILL_TYPE = {
			[15054] = {
				[25] = 'HEAL', -- ÷����Ū
			},
		},
		MINI_MAP_POINT = {
			QUEST_REGION    = 1,
			TEAMMATE        = 2,
			SPARKING        = 3,
			DEATH           = 4,
			QUEST_NPC       = 5,
			DOODAD          = 6,
			MAP_MARK        = 7,
			FUNCTION_NPC    = 8,
			RED_NAME        = 9,
			NEW_PQ	        = 10,
			SPRINT_POINT    = 11,
			FAKE_FELLOW_PET = 12,
		},
		HOMELAND_RESULT_CODE = _G.HOMELAND_RESULT_CODE or {
			APPLY_COMMUNITY_INFO = 503,
		},
		FLOWERS_UIID = {
			[163810] = true, -- ��õ��
			[163811] = true, -- ��õ��
			[163812] = true, -- ��õ��
			[163813] = true, -- ��õ��
			[163814] = true, -- ��õ��
			[163815] = true, -- ��õ��
			[163816] = true, -- ��õ��
			[163817] = true, -- ��õ��
			[163818] = true, -- ��ɫõ��
			[163819] = true, -- ��õ��
			[163820] = true, -- �۰ٺ�
			[163821] = true, -- �Ȱٺ�
			[163822] = true, -- �װٺ�
			[163823] = true, -- �ưٺ�
			[163824] = true, -- �̰ٺ�
			[163825] = true, -- ��ɫ����
			[163826] = true, -- ��ɫ����
			[163827] = true, -- ��ɫ����
			[163828] = true, -- ��ɫ����
			[163829] = true, -- ��ɫ����
			[163830] = true, -- ��ɫ����
			[163831] = true, -- ��ɫ������
			[163832] = true, -- ��ɫ������
			[163833] = true, -- ��ɫ������
			[163834] = true, -- ��ɫ������
			[163835] = true, -- ��ɫ������
			[163836] = true, -- ����ǣţ
			[163837] = true, -- 糽�ǣţ
			[163838] = true, -- ���ǣţ
			[163839] = true, -- �Ͻ�ǣţ
			[163840] = true, -- �ƽ�ǣţ
			[163841] = true, -- ӫ�������
			[163842] = true, -- ӫ�������
			[163843] = true, -- ӫ�������
			[163844] = true, -- ӫ�������
			[163845] = true, -- ӫ�������
			[250069] = true, -- ���ȶ�������
			[250070] = true, -- ���ȶ�������
			[250071] = true, -- ���ȶ�������
			[250072] = true, -- ���ȶ�������
			[250073] = true, -- ���ȶ�������
			[250074] = true, -- ���ȶ�������
			[250075] = true, -- ���ȶ���������
			[250076] = true, -- ���ȶ������Ʒ�
			[250510] = true, -- �׺�«
			[250512] = true, -- ���«
			[250513] = true, -- �Ⱥ�«
			[250514] = true, -- �ƺ�«
			[250515] = true, -- �̺�«
			[250516] = true, -- ���«
			[250517] = true, -- ����«
			[250518] = true, -- �Ϻ�«
			[250519] = true, -- ��ͨ����
			[250520] = true, -- ����
			[250521] = true, -- ����
			[250522] = true, -- ����
			[250523] = true, -- ��ͨ���
			[250524] = true, -- �Ϲ����
			[250525] = true, -- ��ݼ����
			[250526] = true, -- ��ݼ�����
			[250527] = true, -- ��ݼ���Ϻ�
			[250528] = true, -- �ۻƹ�
			[250529] = true, -- �ϻƹ�
		},
		PLAYER_TALK_CHANNEL_TO_MSG_TYPE = KvpToObject({
			{ PLAYER_TALK_CHANNEL.WHISPER          , 'MSG_WHISPER'           },
			{ PLAYER_TALK_CHANNEL.NEARBY           , 'MSG_NORMAL'            },
			{ PLAYER_TALK_CHANNEL.TEAM             , 'MSG_PARTY'             },
			{ PLAYER_TALK_CHANNEL.TONG             , 'MSG_GUILD'             },
			{ PLAYER_TALK_CHANNEL.TONG_ALLIANCE    , 'MSG_GUILD_ALLIANCE'    },
			{ PLAYER_TALK_CHANNEL.TONG_SYS         , 'MSG_GUILD'             },
			{ PLAYER_TALK_CHANNEL.WORLD            , 'MSG_WORLD'             },
			{ PLAYER_TALK_CHANNEL.FORCE            , 'MSG_SCHOOL'            },
			{ PLAYER_TALK_CHANNEL.CAMP             , 'MSG_CAMP'              },
			{ PLAYER_TALK_CHANNEL.FRIENDS          , 'MSG_FRIEND'            },
			{ PLAYER_TALK_CHANNEL.RAID             , 'MSG_TEAM'              },
			{ PLAYER_TALK_CHANNEL.SENCE            , 'MSG_MAP'               },
			{ PLAYER_TALK_CHANNEL.BATTLE_FIELD     , 'MSG_BATTLE_FILED'      },
			{ PLAYER_TALK_CHANNEL.LOCAL_SYS        , 'MSG_SYS'               },
			{ PLAYER_TALK_CHANNEL.GM_MESSAGE       , 'MSG_SYS'               },
			{ PLAYER_TALK_CHANNEL.NPC_WHISPER      , 'MSG_NPC_WHISPER'       },
			{ PLAYER_TALK_CHANNEL.NPC_SAY_TO       , 'MSG_NPC_WHISPER'       },
			{ PLAYER_TALK_CHANNEL.NPC_NEARBY       , 'MSG_NPC_NEARBY'        },
			{ PLAYER_TALK_CHANNEL.NPC_PARTY        , 'MSG_NPC_PARTY'         },
			{ PLAYER_TALK_CHANNEL.NPC_SENCE        , 'MSG_NPC_YELL'          },
			{ PLAYER_TALK_CHANNEL.FACE             , 'MSG_FACE'              },
			{ PLAYER_TALK_CHANNEL.NPC_FACE         , 'MSG_NPC_FACE'          },
			{ PLAYER_TALK_CHANNEL.NPC_SAY_TO_CAMP  , 'MSG_CAMP'              },
			{ PLAYER_TALK_CHANNEL.IDENTITY         , 'MSG_IDENTITY'          },
			{ PLAYER_TALK_CHANNEL.BULLET_SCREEN    , 'MSG_JJC_BULLET_SCREEN' },
			{ PLAYER_TALK_CHANNEL.BATTLE_FIELD_SIDE, 'MSG_BATTLE_FIELD_SIDE' },
		}),
		MSG_TYPE_MENU = {
			{
				szCaption = g_tStrings.CHANNEL_CHANNEL,
				tChannels = {
					'MSG_NORMAL', 'MSG_PARTY', 'MSG_MAP', 'MSG_BATTLE_FILED', 'MSG_GUILD', 'MSG_GUILD_ALLIANCE', 'MSG_SCHOOL', 'MSG_WORLD',
					'MSG_TEAM', 'MSG_CAMP', 'MSG_GROUP', 'MSG_WHISPER', 'MSG_SEEK_MENTOR', 'MSG_FRIEND', 'MSG_IDENTITY', 'MSG_SYS',
				},
			}, {
				szCaption = g_tStrings.FIGHT_CHANNEL,
				tChannels = {
					[g_tStrings.STR_NAME_OWN] = {
						'MSG_SKILL_SELF_HARMFUL_SKILL', 'MSG_SKILL_SELF_BENEFICIAL_SKILL', 'MSG_SKILL_SELF_BUFF',
						'MSG_SKILL_SELF_BE_HARMFUL_SKILL', 'MSG_SKILL_SELF_BE_BENEFICIAL_SKILL', 'MSG_SKILL_SELF_DEBUFF',
						'MSG_SKILL_SELF_SKILL', 'MSG_SKILL_SELF_MISS', 'MSG_SKILL_SELF_FAILED', 'MSG_SELF_DEATH',
					},
					[g_tStrings.TEAMMATE] = {
						'MSG_SKILL_PARTY_HARMFUL_SKILL', 'MSG_SKILL_PARTY_BENEFICIAL_SKILL', 'MSG_SKILL_PARTY_BUFF',
						'MSG_SKILL_PARTY_BE_HARMFUL_SKILL', 'MSG_SKILL_PARTY_BE_BENEFICIAL_SKILL', 'MSG_SKILL_PARTY_DEBUFF',
						'MSG_SKILL_PARTY_SKILL', 'MSG_SKILL_PARTY_MISS', 'MSG_PARTY_DEATH',
					},
					[g_tStrings.OTHER_PLAYER] = {'MSG_SKILL_OTHERS_SKILL', 'MSG_SKILL_OTHERS_MISS', 'MSG_OTHERS_DEATH'},
					['NPC'] = {'MSG_SKILL_NPC_SKILL', 'MSG_SKILL_NPC_MISS', 'MSG_NPC_DEATH'},
					[g_tStrings.OTHER] = {'MSG_OTHER_ENCHANT', 'MSG_OTHER_SCENE'},
				},
			}, {
				szCaption = g_tStrings.CHANNEL_COMMON,
				tChannels = {
					[g_tStrings.ENVIROMENT] = {'MSG_NPC_NEARBY', 'MSG_NPC_YELL', 'MSG_NPC_PARTY', 'MSG_NPC_WHISPER'},
					[g_tStrings.EARN] = {
						'MSG_MONEY', 'MSG_EXP', 'MSG_ITEM', 'MSG_REPUTATION', 'MSG_CONTRIBUTE',
						'MSG_ATTRACTION', 'MSG_PRESTIGE', 'MSG_TRAIN', 'MSG_DESGNATION',
						'MSG_ACHIEVEMENT', 'MSG_MENTOR_VALUE', 'MSG_THEW_STAMINA', 'MSG_TONG_FUND'
					},
				},
			}
		},
		EQUIPMENT_SUIT_COUNT = _G.EQUIPMENT_SUIT_COUNT or 4,
		INVENTORY_GUILD_BANK = INVENTORY_GUILD_BANK or INVENTORY_INDEX.TOTAL + 1, --���ֿ��������һ������λ��
		INVENTORY_GUILD_PAGE_SIZE = INVENTORY_GUILD_PAGE_SIZE or 100,
		INVENTORY_GUILD_PAGE_BOX_COUNT = 98,
	},
	__newindex = function() end,
})
---------------------------------------------------------------------------------------------
local LIB = {
	UI               = {}              ,
	wsub             = wsub            ,
	count_c          = count_c         ,
	pairs_c          = pairs_c         ,
	ipairs_c         = ipairs_c        ,
	ipairs_r         = ipairs_r        ,
	spairs           = spairs          ,
	spairs_r         = spairs_r        ,
	sipairs          = sipairs         ,
	sipairs_r        = sipairs_r       ,
	IsArray          = IsArray         ,
	IsDictionary     = IsDictionary    ,
	IsEquals         = IsEquals        ,
	IsNil            = IsNil           ,
	IsBoolean        = IsBoolean       ,
	IsNumber         = IsNumber        ,
	IsUserdata       = IsUserdata      ,
	IsHugeNumber     = IsHugeNumber    ,
	IsElement        = IsElement       ,
	IsEmpty          = IsEmpty         ,
	IsString         = IsString        ,
	IsTable          = IsTable         ,
	IsFunction       = IsFunction      ,
	Clone            = Clone           ,
	Call             = Call            ,
	XpCall           = XpCall          ,
	SafeCall         = SafeCall        ,
	SetmetaReadonly  = SetmetaReadonly ,
	Set              = Set             ,
	Get              = Get             ,
	Class            = Class           ,
	GetPatch         = GetPatch        ,
	ApplyPatch       = ApplyPatch      ,
	EncodeLUAData    = EncodeLUAData   ,
	DecodeLUAData    = DecodeLUAData   ,
	RandomChild      = RandomChild     ,
	KvpToObject      = KvpToObject     ,
	GetTraceback     = GetTraceback    ,
	IsStreaming      = IsStreaming     ,
	NSFormatString   = NSFormatString  ,
	GetGameAPI       = GetGameAPI      ,
	LoadLangPack     = LoadLangPack    ,
	GLOBAL           = GLOBAL          ,
	CONSTANT         = CONSTANT        ,
	PATH_TYPE        = PATH_TYPE       ,
	DEBUG_LEVEL      = DEBUG_LEVEL     ,
	PACKET_INFO      = PACKET_INFO     ,
}
_G[_NAME_SPACE_] = LIB
---------------------------------------------------------------------------------------------
