--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : 常用工具
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

do
local TARGET_TYPE, TARGET_ID
local function onHotKey()
	if TARGET_TYPE then
		X.SetTarget(TARGET_TYPE, TARGET_ID)
		TARGET_TYPE, TARGET_ID = nil
	else
		TARGET_TYPE, TARGET_ID = X.GetTarget()
		X.SetTarget(TARGET.PLAYER, UI_GetClientPlayerID())
	end
end
X.RegisterHotKey('MY_AutoLoopMeAndTarget', _L['Loop target between me and target'], onHotKey)
end

local PS = { nPriority = 0 }
function PS.OnPanelActive(wnd)
	local ui = UI(wnd)
	local nPaddingX, nPaddingY = 25, 25
	local nW, nH = ui:Size()
	local nX, nY = nPaddingX, nPaddingY
	local nLH = 28

	-- 目标
	nX = nPaddingX
	nY = nY + ui:Append('Text', { x = nX, y = nY, h = 'auto', text = _L['Target'], color = {255, 255, 0} }):Height() + 5
	nX = nX + 10
	nX, nY = MY_FooterTip.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)

	-- 战斗
	nX = nPaddingX
	nY = nY + ui:Append('Text', { x = nX, y = nY, h = 'auto', text = _L['Battle'], color = {255, 255, 0} }):Height() + 5
	nX = nX + 10
	nX, nY = MY_VisualSkill.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)
	nX, nY = MY_DynamicActionBarPos.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)
	nX, nY = MY_ArenaHelper.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)
	nX, nY = nPaddingX + 10, nY + nLH
	nX, nY = MY_ShenxingHelper.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)

	-- 其他
	nX = nPaddingX
	nY = nY + ui:Append('Text', { x = nX, y = nY, h = 'auto', text = _L['Others'], color = {255, 255, 0} }):Height() + 5
	nX = nX + 10
	nX, nY = MY_AchievementWiki.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)
	nX, nY = MY_PetWiki.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)
	nX, nY = MY_YunMacro.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)
	nX, nY = MY_ItemWiki.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)
	nX, nY = MY_ItemPrice.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)

	nX, nY = nPaddingX + 10, nY + nLH
	if MY_BagEx then
		nX, nY = MY_BagEx.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)
	end
	if MY_BagSort then
		nX, nY = MY_BagSort.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)
	end
	nX, nY = MY_HideAnnounceBg.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)
	nX, nY = MY_FriendTipLocation.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)

	nX, nY = nPaddingX + 10, nY + nLH
	nX, nY = MY_Domesticate.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)
	nX, nY = MY_Memo.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)

	nX, nY = MY_AutoSell.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY, nLH)
	nX, nY = nPaddingX + 10, nY + nLH

	-- 右侧浮动
	MY_GongzhanCheck.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY, nLH)
	MY_LockFrame.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY, nLH)
	MY_DynamicItem.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY, nLH)
end
X.RegisterPanel(_L['General'], 'MY_Toolbox', _L['MY_Toolbox'], 134, PS)
