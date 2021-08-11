--------------------------------------------------------
-- This file is part of the JX3 Plugin Project.
-- @desc     : TextEditor
-- @copyright: Copyright (c) 2009 Kingsoft Co., Ltd.
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
local _L = X.LoadLangPack(X.PACKET_INFO.FRAMEWORK_ROOT .. 'lang/lib/')

-- ���ı��༭��
function UI.OpenTextEditor(szText, szFrameName)
	if not szFrameName then
		szFrameName = X.NSFormatString('{$NS}_DefaultTextEditor')
	end
	local w, h, ui = 400, 300, nil
	local function OnResize()
		local nW, nH = select(3, ui:Size())
		ui:Children('.WndEditBox'):Size(nW, nH)
	end
	ui = UI.CreateFrame(szFrameName, {
		w = w, h = h, text = _L['Text Editor'], alpha = 180,
		anchor = { s='CENTER', r='CENTER', x=0, y=0 },
		simple = true, close = true, esc = true,
		dragresize = true, minimize = true, ondragresize = OnResize,
	})
	ui:Append('WndEditBox', { x = 0, y = 0, multiline = true, text = szText })
	ui:Focus()
	OnResize()
	return ui
end
