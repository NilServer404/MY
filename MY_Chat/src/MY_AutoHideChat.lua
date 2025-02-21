--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : �Զ�����������
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
local PLUGIN_NAME = 'MY_Chat'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_Chat'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^9.0.0') then
	return
end
--------------------------------------------------------------------------

local STATE = {
	SHOW    = 1, -- ����ʾ
	HIDE    = 2, -- ������
	SHOWING = 3, -- ������ʾ��
	HIDDING = 4, -- ����������
}
local m_nState = STATE.SHOW
local O = X.CreateUserSettingsModule('MY_Chat', _L['Chat'], {
	bEnable = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Chat'],
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
})
local D = {}

-- get sys chat bg alpha
function D.GetBgAlpha()
	return Station.Lookup('Lowest2/ChatPanel1'):Lookup('Wnd_Message', 'Shadow_Back'):GetAlpha() / 255
end

-- show panel
function D.ShowChatPanel(nShowFrame, nDelayFrame, callback)
	-- �������֡��
	if not nShowFrame then
		nShowFrame = GLOBAL.GAME_FPS / 4
	end
	-- �����ӳ�֡��
	if not nDelayFrame then
		nDelayFrame = 0
	end
	-- switch case
	if m_nState == STATE.SHOW then
		-- return when chat panel is visible
		if callback then
			X.Call(callback)
		end
		return
	elseif m_nState == STATE.SHOWING then
		return
	elseif m_nState == STATE.HIDE then
		-- show each
		for i = 1, 10 do
			local hFrame = Station.Lookup('Lowest2/ChatPanel' .. i)
			if hFrame then
				hFrame:SetMousePenetrable(false)
			end
		end
	elseif m_nState == STATE.HIDDING then
		-- unregister hide animate
		X.BreatheCall('MY_AutoHideChat_Hide', false)
	end
	m_nState = STATE.SHOWING

	-- get start alpha
	local nStartAlpha = Station.Lookup('Lowest1/ChatTitleBG'):GetAlpha()
	local nStartFrame = GetLogicFrameCount()
	-- register animate breathe call
	X.BreatheCall('MY_AutoHideChat_Show', function()
		local nFrame = GetLogicFrameCount()
		if nFrame - nDelayFrame < nStartFrame then
			D.fAhBgAlpha = D.GetBgAlpha()
			return
		end
		-- calc new alpha
		local nAlpha = math.min(math.ceil((nFrame - nDelayFrame - nStartFrame) / nShowFrame * (255 - nStartAlpha) + nStartAlpha), 255)
		-- alpha each panel
		for i = 1, 10 do
			local hFrame = Station.Lookup('Lowest2/ChatPanel' .. i)
			if hFrame then
				hFrame:SetAlpha(nAlpha)
				hFrame:Lookup('Wnd_Message', 'Shadow_Back'):SetAlpha(nAlpha * D.fAhBgAlpha)
			end
		end
		Station.Lookup('Lowest1/ChatTitleBG'):SetAlpha(nAlpha)
		Station.Lookup('Lowest1/ChatTitleBG', 'Image_BG'):SetAlpha(nAlpha * D.fAhBgAlpha)
		if nAlpha == 255 then
			m_nState = STATE.SHOW
			if callback then
				X.Call(callback)
			end
			return 0
		end
	end)
end

-- hide panel
function D.HideChatPanel(nHideFrame, nDelayFrame, callback)
	-- ������ʧ֡��
	if not nHideFrame then
		nHideFrame = GLOBAL.GAME_FPS / 2
	end
	-- �����ӳ�֡��
	if not nDelayFrame then
		nDelayFrame = GLOBAL.GAME_FPS * 5
	end
	-- switch case
	if m_nState == STATE.SHOW then
		-- get bg alpha
		D.fAhBgAlpha = D.GetBgAlpha()
	elseif m_nState == STATE.SHOWING then
		return
	elseif m_nState == STATE.HIDE then
		-- return when chat panel is not visible
		if callback then
			X.Call(callback)
		end
		return
	elseif m_nState == STATE.HIDDING then
		-- unregister hide animate
		X.BreatheCall('MY_AutoHideChat_Hide', false)
	end
	m_nState = STATE.HIDDING

	-- get start alpha
	local nStartAlpha = Station.Lookup('Lowest1/ChatTitleBG'):GetAlpha()
	local nStartFrame = GetLogicFrameCount()
	-- register animate breathe call
	X.BreatheCall('MY_AutoHideChat_Hide', function()
		local nFrame = GetLogicFrameCount()
		if nFrame - nDelayFrame < nStartFrame then
			D.fAhBgAlpha = D.GetBgAlpha()
			return
		end
		-- calc new alpha
		local nAlpha = math.max(math.ceil((1 - (nFrame - nDelayFrame - nStartFrame) / nHideFrame) * nStartAlpha), 0)
		-- if panel setting panel is opened then delay again
		local hPanelSettingFrame = Station.Lookup('Normal/ChatSettingPanel')
		if hPanelSettingFrame and hPanelSettingFrame:IsVisible() then
			nStartFrame = GetLogicFrameCount()
			return
		end
		-- if mouse over chat panel then delay again
		local hMouseOverWnd = Station.GetMouseOverWindow()
		if hMouseOverWnd and hMouseOverWnd:GetRoot():GetName():sub(1, 9) == 'ChatPanel' then
			nStartFrame = GetLogicFrameCount()
			nAlpha = 255
		end
		-- alpha each panel
		for i = 1, 10 do
			local hFrame = Station.Lookup('Lowest2/ChatPanel' .. i)
			if hFrame then
				hFrame:SetAlpha(nAlpha)
				hFrame:Lookup('Wnd_Message', 'Shadow_Back'):SetAlpha(nAlpha * D.fAhBgAlpha)
				-- hide if alpha turns to zero
				if nAlpha == 0 then
					hFrame:SetMousePenetrable(true)
				end
			end
		end
		Station.Lookup('Lowest1/ChatTitleBG'):SetAlpha(nAlpha)
		Station.Lookup('Lowest1/ChatTitleBG', 'Image_BG'):SetAlpha(nAlpha * D.fAhBgAlpha)
		if nAlpha == 0 then
			m_nState = STATE.HIDE
			if callback then
				X.Call(callback)
			end
			return 0
		end
	end)
end

-- ��ʼ��/��Ч ����
function D.Apply()
	local shaBack = Station.Lookup('Lowest2/ChatPanel1/Wnd_Message', 'Shadow_Back')
	local editInput = X.GetChatInput()
	if not shaBack or not editInput then
		return
	end
	if O.bEnable then
		-- get bg alpha
		if not D.fAhBgAlpha then
			D.fAhBgAlpha = shaBack:GetAlpha() / 255
			D.bAhAnimate = D.bAhAnimate or false
		end
		-- hook chat panel as event listener
		X.HookChatPanel('AFTER', 'MY_AutoHideChat', function(h)
			-- if input box get focus then return
			local focus = Station.GetFocusWindow()
			if focus and focus == X.GetChatInput() then
				return
			end
			-- show when new msg
			D.ShowChatPanel(GLOBAL.GAME_FPS / 4, 0, function()
				-- hide after 5 sec
				D.HideChatPanel(GLOBAL.GAME_FPS / 2, GLOBAL.GAME_FPS * 5)
			end)
		end)

		-- hook chat edit box
		-- save org
		if editInput._MY_T_AHCP_OnSetFocus == nil then
			editInput._MY_T_AHCP_OnSetFocus = editInput.OnSetFocus or false
		end
		-- show when chat panel get focus
		editInput.OnSetFocus = function()
			D.ShowChatPanel(GLOBAL.GAME_FPS / 4, 0)
			if this._MY_T_AHCP_OnSetFocus then
				this._MY_T_AHCP_OnSetFocus()
			end
		end
		-- save org
		if editInput._MY_T_AHCP_OnKillFocus == nil then
			editInput._MY_T_AHCP_OnKillFocus = editInput.OnKillFocus or false
		end
		-- hide after input box lost focus for 5 sec
		editInput.OnKillFocus = function()
			D.HideChatPanel(GLOBAL.GAME_FPS / 2, GLOBAL.GAME_FPS * 5)
			if this._MY_T_AHCP_OnKillFocus then
				this._MY_T_AHCP_OnKillFocus()
			end
		end
	else
		if editInput._MY_T_AHCP_OnSetFocus then
			editInput.OnSetFocus = editInput._MY_T_AHCP_OnSetFocus
		else
			editInput.OnSetFocus = nil
		end
		editInput._MY_T_AHCP_OnSetFocus = nil

		if editInput._MY_T_AHCP_OnKillFocus then
			editInput.OnKillFocus = editInput._MY_T_AHCP_OnKillFocus
		else
			editInput.OnKillFocus = nil
		end
		editInput._MY_T_AHCP_OnKillFocus = nil
		X.HookChatPanel('AFTER', 'MY_AutoHideChat', false)

		D.ShowChatPanel()
	end
end
X.RegisterUserSettingsUpdate('@@INIT@@', 'MY_AutoHideChat', D.Apply)

function D.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY, nLH)
	nX = nPaddingX
	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 'auto',
		text = _L['Auto hide chat panel'],
		checked = O.bEnable,
		oncheck = function(bChecked)
			O.bEnable = bChecked
			D.Apply()
		end,
	}):Width()
	nY = nY + nLH
	return nX, nY
end

-- Global exports
do
local settings = {
	name = 'MY_AutoHideChat',
	exports = {
		{
			fields = {
				OnPanelActivePartial = D.OnPanelActivePartial,
			},
		},
	},
}
MY_AutoHideChat = X.CreateModule(settings)
end
