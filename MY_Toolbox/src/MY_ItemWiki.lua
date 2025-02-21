--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : 物品百科查询
-- @author   : 茗伊 @双梦镇 @追风蹑影
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
--------------------------------------------------------------------------

local O = X.CreateUserSettingsModule('MY_ItemWiki', _L['General'], {
	bEnable = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
	nW = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		xSchema = X.Schema.Number,
		xDefaultValue = 850,
	},
	nH = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		xSchema = X.Schema.Number,
		xDefaultValue = 610,
	},
})
local D = {}

function D.OnWebSizeChange()
	O.nW, O.nH = this:GetSize()
end

function D.Open(dwTabType, dwTabIndex, nBookID)
	if nBookID < 0 then
		nBookID = nil
	end
	local szName = X.GetObjectName('ITEM_INFO', dwTabType, dwTabIndex, nBookID)
	if not szName then
		return
	end
	local szURL = 'https://page.j3cx.com/item/' .. table.concat({dwTabType, dwTabIndex, nBookID}, '/') .. '?'
		.. X.EncodePostData(X.UrlEncode({
			l = AnsiToUTF8(GLOBAL.GAME_LANG),
			L = AnsiToUTF8(GLOBAL.GAME_EDITION),
			player = AnsiToUTF8(GetUserRoleName()),
		}))
	local szKey = 'ItemWiki_' .. table.concat({dwTabType, dwTabIndex, nBookID}, '_')
	local szTitle = szName
	szKey = UI.OpenBrowser(szURL, {
		key = szKey,
		title = szTitle,
		w = O.nW, h = O.nH,
		readonly = true,
	})
	UI(UI.LookupBrowser(szKey)):Size(D.OnWebSizeChange)
end

function D.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY)
	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 'auto',
		text = _L['Item wiki'],
		checked = MY_ItemWiki.bEnable,
		oncheck = function(bChecked)
			MY_ItemWiki.bEnable = bChecked
		end,
		tip = _L['Hold SHIFT and r-click bag box to show item wiki'],
		tippostype = UI.TIP_POSITION.BOTTOM_TOP,
	}):Width() + 5
	return nX, nY
end

-- Global exports
do
local settings = {
	name = 'MY_ItemWiki',
	exports = {
		{
			fields = {
				'Open',
				'OnPanelActivePartial',
			},
			root = D,
		},
		{
			fields = {
				'bEnable',
				'nW',
				'nH',
			},
			root = O,
		},
	},
	imports = {
		{
			fields = {
				'bEnable',
				'nW',
				'nH',
			},
			root = O,
		},
	},
}
MY_ItemWiki = X.CreateModule(settings)
end

Box_AppendAddonMenu({function(box)
	if not X.IsElement(box) or box:GetType() ~= 'Box' or not O.bEnable then
		return
	end
	local _, dwBox, dwX = box:GetObjectData()
	if not dwBox or not dwX then
		return
	end
	local item = GetPlayerItem(GetClientPlayer(), dwBox, dwX)
	if not item then
		return
	end
	local dwTabType = item.dwTabType
	local dwTabIndex = item.dwIndex
	local nBookID = item.nGenre == ITEM_GENRE.BOOK and item.nBookID or -1
	return {{ szOption = _L['Item wiki'], fnAction = function() D.Open(dwTabType, dwTabIndex, nBookID) end }}
end})
