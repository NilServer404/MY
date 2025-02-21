--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : �ƶ˺�
-- @author   : ���� @˫���� @׷����Ӱ
-- @modifier : Emil Zhai (root@derzh.com)
-- @copyright: Copyright (c) 2013 EMZ Kingsoft Co., Ltd.
--------------------------------------------------------
-------------------------------------------------------------------------------------------------------
-- these global functions are accessed all the time by the event handler
-- so caching them is worth the effort
-------------------------------------------------------------------------------------------------------
local ipairs, pairs, next, pcall, select = ipairs, pairs, next, pcall, select
local string, math, table = string, math, table
-- lib apis caching
local X = MY
local UI, GLOBAL, CONSTANT, wstring, lodash = X.UI, X.GLOBAL, X.CONSTANT, X.wstring, X.lodash
-------------------------------------------------------------------------------------------------------
local PLUGIN_NAME = 'MY_Toolbox'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_Toolbox'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^9.0.0') then
	return
end
X.RegisterRestriction('MY_YunMacro', { ['*'] = false, classic = true })
--------------------------------------------------------------------------

local O = X.CreateUserSettingsModule('MY_YunMacro', _L['General'], {
	bEnable = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
})
local D = {}

function D.Hook()
	local frame = Station.SearchFrame('MacroSettingPanel')
	if not frame then
		return
	end
	local edtName = frame:Lookup('Edit_Name')
	local edtDesc = frame:Lookup('Edit_Desc')
	local edtMacro = frame:Lookup('Edit_Content')
	local btnNew = frame:Lookup('Btn_New')
	local hIconList = frame:Lookup('', 'Handle_Icon')
	local nX = edtName:GetRelX() + edtName:GetW() + 10
	local nY = edtName:GetRelY() - 4
	nX = nX + UI(frame):Append('WndButton', {
		name = 'Btn_YunMacro_Update',
		x = nX, y = nY,
		w = 'auto', h = edtName:GetH(),
		text = _L['Sync yun macro'],
		onclick = function()
			local szName = X.TrimString(edtName:GetText())
			if X.IsEmpty(szName) then
				return X.Alert(_L['Please input macro name first.'])
			end
			X.Alert('MY_YunMacro', _L['Macro update started, please keep panel opened and wait.'], nil, _L['Got it'])
			X.Ajax({
				driver = 'auto', mode = 'auto', method = 'auto',
				url = 'https://pull.j3cx.com/api/macro/query?'
					.. X.EncodePostData(X.UrlEncode({
						l = AnsiToUTF8(GLOBAL.GAME_LANG),
						L = AnsiToUTF8(GLOBAL.GAME_EDITION),
						name = AnsiToUTF8(szName),
					})),
				success = function(szHTML)
					local res, err = X.JsonDecode(szHTML)
					if res then
						local bValid, szErrID, nLine, szErrMsg = X.IsMacroValid(res.data)
						if bValid then
							res.desc = X.ReplaceSensitiveWord(res.desc)
						else
							res, err = false, szErrMsg
						end
					end
					if not res then
						return X.Alert('MY_YunMacro', _L['ERR: Info content is illegal!'] .. '\n\n' .. err, nil, _L['Got it'])
					end
					if res.icon then
						for i = 0, hIconList:GetItemCount() - 1 do
							hIconList:Lookup(i):SetObjectInUse(false)
						end
						local box = hIconList:Lookup(0)
						box:SetObjectInUse(true)
						box:SetObjectIcon(res.icon)
						box.nIconID = res.icon
						hIconList.nIconID = res.icon
					end
					edtDesc:SetText(res.desc)
					edtDesc:SetCaretPos(0)
					edtMacro:SetText(res.data)
					edtMacro:SetCaretPos(0)
					X.Alert('MY_YunMacro', _L['Macro update succeed, please click save button.'], nil, _L['Got it'])
				end,
				error = function()
					X.Alert('MY_YunMacro', _L['Macro update failed...'], nil, _L['Got it'])
				end,
			})
		end,
	}):Width()
	UI(frame):Append('WndButton', {
		name = 'Btn_YunMacro_Details',
		x = nX, y = nY,
		w = 'auto', h = edtName:GetH(),
		text = _L['Show yun macro details'],
		onclick = function()
			local szName = X.TrimString(edtName:GetText())
			if X.IsEmpty(szName) then
				return X.Alert(_L['Please input macro name first.'])
			end
			local szURL = 'https://page.j3cx.com/macro/details?'
				.. X.EncodePostData(X.UrlEncode({
					l = AnsiToUTF8(GLOBAL.GAME_LANG),
					L = AnsiToUTF8(GLOBAL.GAME_EDITION),
					name = AnsiToUTF8(szName),
				}))
			UI.OpenBrowser(szURL, { key = 'MY_YunMacro_' .. GetStringCRC(szName), layer = 'Topmost', readonly = true })
		end,
	})
	UI(frame):Append('WndButton', {
		name = 'Btn_YunMacro_Tops',
		x = edtMacro:GetRelX(), y = btnNew:GetRelY(),
		w = btnNew:GetW(), h = btnNew:GetH(),
		text = _L['Top yun macro'],
		onclick = function()
			local szURL = 'https://page.j3cx.com/macro/tops?'
				.. X.EncodePostData(X.UrlEncode({
					l = AnsiToUTF8(GLOBAL.GAME_LANG),
					L = AnsiToUTF8(GLOBAL.GAME_EDITION),
					kungfu = tostring(UI_GetPlayerMountKungfuID()),
				}))
			X.OpenBrowser(szURL)
		end,
	})
end

function D.Unhook()
	local frame = Station.SearchFrame('MacroSettingPanel')
	if not frame then
		return
	end
	for _, s in ipairs({
		'Btn_YunMacro_Update',
		'Btn_YunMacro_Details',
		'Btn_YunMacro_Tops',
	}) do
		local el = frame:Lookup(s)
		if el then
			el:Destroy()
		end
	end
end

function D.Apply()
	if D.bReady and O.bEnable then
		D.Hook()
		X.RegisterFrameCreate('MacroSettingPanel', 'MY_YunMacro', D.Hook)
		X.RegisterReload('MY_YunMacro', D.Unhook)
	else
		D.Unhook()
		X.RegisterFrameCreate('MacroSettingPanel', 'MY_YunMacro', false)
		X.RegisterReload('MY_YunMacro', false)
	end
end

X.RegisterUserSettingsUpdate('@@INIT@@', 'MY_YunMacro', function()
	D.bReady = true
	D.Apply()
end)

function D.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY)
	if not X.IsRestricted('MY_YunMacro') then
		nX = nX + ui:Append('WndCheckBox', {
			x = nX, y = nY, w = 'auto',
			text = _L['Show yun macro buttons on macro panel.'],
			checked = MY_YunMacro.bEnable,
			oncheck = function(bChecked)
				MY_YunMacro.bEnable = bChecked
			end,
		}):Width() + 5
	end
	return nX, nY
end

-- Global exports
do
local settings = {
	name = 'MY_YunMacro',
	exports = {
		{
			fields = {
				'OnPanelActivePartial',
			},
			root = D,
		},
		{
			fields = {
				'bEnable',
			},
			root = O,
		},
	},
	imports = {
		{
			fields = {
				'bEnable',
			},
			triggers = {
				bEnable = D.Apply,
			},
			root = O,
		},
	},
}
MY_YunMacro = X.CreateModule(settings)
end
