--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : ��ƽѪ������
-- @author   : ���� @˫���� @׷����Ӱ
-- @modifier : Emil Zhai (root@derzh.com)
-- @copyright: Copyright (c) 2013 EMZ Kingsoft Co., Ltd.
--------------------------------------------------------
--------------------------------------------------------------------------------------------------------
-- these global functions are accessed all the time by the event handler
-- so caching them is worth the effort
--------------------------------------------------------------------------------------------------------
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
local MY, UI = MY, MY.UI
local var2str, str2var, clone, empty, ipairs_r = MY.var2str, MY.str2var, MY.clone, MY.empty, MY.ipairs_r
local spairs, spairs_r, sipairs, sipairs_r = MY.spairs, MY.spairs_r, MY.sipairs, MY.sipairs_r
local GetPatch, ApplyPatch = MY.GetPatch, MY.ApplyPatch
local Get, Set, RandomChild, GetTraceback = MY.Get, MY.Set, MY.RandomChild, MY.GetTraceback
local IsArray, IsDictionary, IsEquals = MY.IsArray, MY.IsDictionary, MY.IsEquals
local IsNil, IsBoolean, IsNumber, IsFunction = MY.IsNil, MY.IsBoolean, MY.IsNumber, MY.IsFunction
local IsEmpty, IsString, IsTable, IsUserdata = MY.IsEmpty, MY.IsString, MY.IsTable, MY.IsUserdata
local MENU_DIVIDER, EMPTY_TABLE, XML_LINE_BREAKER = MY.MENU_DIVIDER, MY.EMPTY_TABLE, MY.XML_LINE_BREAKER
--------------------------------------------------------------------------------------------------------
local _L, D = MY.LoadLangPack(MY.GetAddonInfo().szRoot .. 'MY_LifeBar/lang/'), {}
local CONFIG_DEFAULTS = setmetatable({
	DEFAULT  = MY.LoadLUAData(MY.GetAddonInfo().szRoot .. 'MY_LifeBar/config/default/$lang.jx3dat'),
	OFFICIAL = MY.LoadLUAData(MY.GetAddonInfo().szRoot .. 'MY_LifeBar/config/official/$lang.jx3dat'),
	CLEAR    = MY.LoadLUAData(MY.GetAddonInfo().szRoot .. 'MY_LifeBar/config/clear/$lang.jx3dat'),
	XLIFEBAR = MY.LoadLUAData(MY.GetAddonInfo().szRoot .. 'MY_LifeBar/config/xlifebar/$lang.jx3dat'),
}, { __index = function(t, k) return t.DEFAULT end })

if not CONFIG_DEFAULTS.DEFAULT then
    return MY.Debug({_L['Default config cannot be loaded, please reinstall!!!']}, _L['x lifebar'], MY_DEBUG.ERROR)
end
local Config, ConfigLoaded = clone(CONFIG_DEFAULTS.DEFAULT), false
local CONFIG_PATH = 'config/xlifebar/%s.jx3dat'

function D.GetConfigPath()
	return (CONFIG_PATH:format(MY_LifeBar.szConfig))
end

-- ��������Զ�������������÷������� ʵ��Ĭ�����ò����û�����Ӱ��
function D.AutoAdjustScale()
	local fUIScale = MY.GetOriginUIScale()
	if Config.fDesignUIScale ~= fUIScale then
		Config.fGlobalUIScale = Config.fGlobalUIScale * Config.fDesignUIScale / fUIScale
		Config.fDesignUIScale = fUIScale
	end
	local nFontOffset = Font.GetOffset()
	if Config.nDesignFontOffset ~= nFontOffset then
		Config.fTextScale = Config.fTextScale * MY.GetFontScale(Config.nDesignFontOffset) / MY.GetFontScale()
		Config.nDesignFontOffset = nFontOffset
	end
end

do
local function onUIScaled()
	if not ConfigLoaded then
		return
	end
	D.AutoAdjustScale()
	FireUIEvent('MY_LIFEBAR_CONFIG_UPDATE')
end
MY.RegisterEvent('UI_SCALED.MY_LifeBar_Config', onUIScaled)
end

function D.LoadConfig(szConfig)
	if IsTable(szConfig) then
		Config = szConfig
	else
		if IsString(szConfig) then
			if MY_LifeBar.szConfig ~= szConfig then
				if ConfigLoaded then
					D.SaveConfig()
				end
				MY_LifeBar.szConfig = szConfig
			end
		end
		Config = MY.LoadLUAData({ D.GetConfigPath(), MY_DATA_PATH.GLOBAL })
	end
	if Config and not Config.fDesignUIScale then -- ����������
		Config.fDesignUIScale = MY.GetOriginUIScale()
		Config.fMatchedFontOffset = Font.GetOffset()
	end
	Config = MY.FormatDataStructure(Config, CONFIG_DEFAULTS[Config and Config.eCss or ''], true)
	D.AutoAdjustScale()
	ConfigLoaded = true
	FireUIEvent('MY_LIFEBAR_CONFIG_LOADED')
end
MY.RegisterInit(D.LoadConfig)

function D.SaveConfig()
	if not ConfigLoaded then
		return
	end
	MY.SaveLUAData({ D.GetConfigPath(), MY_DATA_PATH.GLOBAL }, Config)
end
MY.RegisterExit(D.SaveConfig)

MY_LifeBar_Config = setmetatable({}, {
	__call = function(t, op, ...)
		local argc = select('#', ...)
		local argv = {...}
		if op == 'get' then
			local config = Config
			for i = 1, argc do
				if not IsTable(config) then
					return
				end
				config = config[argv[i]]
			end
			return config
		elseif op == 'set' then
			local config = Config
			for i = 1, argc - 2 do
				if not IsTable(config) then
					return
				end
				config = config[argv[i]]
			end
			if not IsTable(config) then
				return
			end
			config[argv[argc - 1]] = argv[argc]
		elseif op == 'reset' then
			if not argv[1] then
				MessageBox({
					szName = 'MY_LifeBar_Restore_Default',
					szAlignment = 'CENTER',
					szMessage = _L['Please choose your favorite lifebar style.\nYou can rechoose in setting panel.'],
					{
						szOption = _L['Official default style'],
						fnAction = function()
							D.LoadConfig(clone(CONFIG_DEFAULTS.OFFICIAL))
						end,
					},
					{
						szOption = _L['Official clear style'],
						fnAction = function()
							D.LoadConfig(clone(CONFIG_DEFAULTS.CLEAR))
						end,
					},
					{
						szOption = _L['XLifeBar style'],
						fnAction = function()
							D.LoadConfig(clone(CONFIG_DEFAULTS.XLIFEBAR))
						end,
					},
					{
						szOption = _L['Keep current'],
						fnAction = function()
							if Config.eCss == '' then
								Config.eCss = 'DEFAULT'
							end
						end,
					},
				})
			else
				D.LoadConfig(clone(CONFIG_DEFAULTS[argv[1]]))
			end
		elseif op == 'save' then
			return D.SaveConfig(...)
		elseif op == 'load' then
			return D.LoadConfig(...)
		elseif op == 'loaded' then
			return ConfigLoaded
		end
	end,
	__index = function(t, k) return Config[k] end,
	__newindex = function(t, k, v) Config[k] = v end,
})
