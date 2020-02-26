--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : 金团记录界面
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@derzh.com)
-- @copyright: Copyright (c) 2013 EMZ Kingsoft Co., Ltd.
--------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-- these global functions are accessed all the time by the event handler
-- so caching them is worth the effort
-----------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local ipairs, pairs, next, pcall, select = ipairs, pairs, next, pcall, select
local sub, len, format, rep = string.sub, string.len, string.format, string.rep
local find, byte, char, gsub = string.find, string.byte, string.char, string.gsub
local type, tonumber, tostring = type, tonumber, tostring
local HUGE, PI, random, abs = math.huge, math.pi, math.random, math.abs
local min, max, floor, ceil = math.min, math.max, math.floor, math.ceil
local pow, sqrt, sin, cos, tan, atan = math.pow, math.sqrt, math.sin, math.cos, math.tan, math.atan
local insert, remove, concat, sort = table.insert, table.remove, table.concat, table.sort
local pack, unpack = table.pack or function(...) return {...} end, table.unpack or unpack
-- jx3 apis caching
local wsub, wlen, wfind, wgsub = wstring.sub, wstring.len, wstring.find, StringReplaceW
local GetTime, GetLogicFrameCount, GetCurrentTime = GetTime, GetLogicFrameCount, GetCurrentTime
local GetClientTeam, UI_GetClientPlayerID = GetClientTeam, UI_GetClientPlayerID
local GetClientPlayer, GetPlayer, GetNpc, IsPlayer = GetClientPlayer, GetPlayer, GetNpc, IsPlayer
local LIB = MY
local UI, DEBUG_LEVEL, PATH_TYPE, PACKET_INFO = LIB.UI, LIB.DEBUG_LEVEL, LIB.PATH_TYPE, LIB.PACKET_INFO
local spairs, spairs_r, sipairs, sipairs_r = LIB.spairs, LIB.spairs_r, LIB.sipairs, LIB.sipairs_r
local ipairs_r, count_c, pairs_c, ipairs_c = LIB.ipairs_r, LIB.count_c, LIB.pairs_c, LIB.ipairs_c
local IsNil, IsBoolean, IsUserdata, IsFunction = LIB.IsNil, LIB.IsBoolean, LIB.IsUserdata, LIB.IsFunction
local IsString, IsTable, IsArray, IsDictionary = LIB.IsString, LIB.IsTable, LIB.IsArray, LIB.IsDictionary
local IsNumber, IsHugeNumber, IsEmpty, IsEquals = LIB.IsNumber, LIB.IsHugeNumber, LIB.IsEmpty, LIB.IsEquals
local Call, XpCall, GetTraceback, RandomChild = LIB.Call, LIB.XpCall, LIB.GetTraceback, LIB.RandomChild
local Get, Set, Clone, GetPatch, ApplyPatch = LIB.Get, LIB.Set, LIB.Clone, LIB.GetPatch, LIB.ApplyPatch
local EncodeLUAData, DecodeLUAData, CONSTANT = LIB.EncodeLUAData, LIB.DecodeLUAData, LIB.CONSTANT
-----------------------------------------------------------------------------------------------------------
local PLUGIN_NAME = 'MY_GKP'
local PLUGIN_ROOT = PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_GKP'
local _L = LIB.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not LIB.AssertVersion(MODULE_NAME, _L[MODULE_NAME], 0x2013900) then
	return
end
--------------------------------------------------------------------------
local SZ_INI = PLUGIN_ROOT .. '/ui/MY_GKP.ini'
local D = {
	GetMoneyTipText = MY_GKP.GetMoneyTipText,
	GetTimeString = MY_GKP.GetTimeString,
	GetMoneyCol = MY_GKP.GetMoneyCol,
	GetFormatLink = MY_GKP.GetFormatLink,
}

MY_GKP_UI = class()

function D.SetDS(frame, szFilePath)
	frame.ds = MY_GKP_DS(szFilePath)
	if frame.ds then
		D.UpdateMode(frame)
		D.DrawTitle(frame)
		D.DrawStat(frame)
		D.DrawAuctionPage(frame)
		D.DrawPaymentPage(frame)
	else
		Wnd.CloseWindow(frame)
		LIB.Alert(_L['Load data source failed!'])
	end
end

---------------------------------------------------------------------->
-- 绘制界面
----------------------------------------------------------------------<

function D.UpdateMode(frame)
	local bMainInstance = frame.ds == MY_GKP_MI.GetDS()
	local ui = UI(frame)
	ui:Fetch('Btn_AddManually'):Visible(bMainInstance)
	ui:Fetch('Btn_Calculate'):Visible(bMainInstance)
	ui:Fetch('GOLD_TEAM_BID_LIST'):Visible(bMainInstance)
	ui:Fetch('Debt'):Visible(bMainInstance)
	ui:Fetch('Btn_ClearRecord'):Visible(bMainInstance)
	ui:Fetch('Btn_HistoryRecord'):Visible(bMainInstance)
	ui:Fetch('Btn_SyncRecord'):Visible(bMainInstance)
	ui:Fetch('Btn_SetHistory'):Visible(not bMainInstance)
end

function D.DrawTitle(frame)
	local txtTitle = frame:Lookup('', 'Text_Title')
	local szMap = frame.ds:GetMap()
	local nTime = frame.ds:GetTime()
	local szText = _L['GKP Golden Team Record']
		.. (szMap ~= '' and (' - ' .. szMap) or '')
		.. (nTime ~= 0 and (' - ' .. LIB.FormatTime(nTime, '%yyyy-%MM-%dd-%hh-%mm-%ss')) or '')
	txtTitle:SetText(szText)
end

function D.DrawStat(frame)
	local a, b = frame.ds:GetAuctionSum()
	local c, d = frame.ds:GetPaymentSum()
	local hStat = frame:Lookup('', 'Handle_Record_Stat')
	local szXml = GetFormatText(_L['Reall Salary:'], 41) .. D.GetMoneyTipText(a + b)
	if LIB.IsDistributer() or not LIB.IsInParty() then
		if c + d < 0 then
			szXml = szXml .. GetFormatText(' || ' .. _L['Spending:'], 41) .. D.GetMoneyTipText(d)
		elseif c ~= 0 then
			szXml = szXml .. GetFormatText(' || ' .. _L['Reall income:'], 41) .. D.GetMoneyTipText(c + d)
		end
		local e = (a + b) - (c + d)
		if a > 0 then
			szXml = szXml .. GetFormatText(' || ' .. _L['Money on Debt:'], 41) .. D.GetMoneyTipText(e)
		end
	end
	hStat:Clear()
	hStat:AppendItemFromString(szXml)
	hStat:FormatAllItemPos()
	hStat:SetSizeByAllItemSize()
	hStat.OnItemMouseEnter = function()
		local br = GetFormatText('\n', 41)
		local szXml = ''
		if a > 0 then
			szXml = szXml .. GetFormatText(_L['Total Auction:'], 41) .. D.GetMoneyTipText(a) .. br
			if b ~= 0 then
				szXml = szXml .. GetFormatText(_L['Salary Allowance:'], 41) .. D.GetMoneyTipText(b) .. br
				szXml = szXml .. GetFormatText(_L['Reall Salary:'], 41) .. D.GetMoneyTipText(a + b) .. br
			end
		end
		if (LIB.IsDistributer() or not LIB.IsInParty()) and c > 0 then
			szXml = szXml .. GetFormatText(_L['Total income:'], 41) .. D.GetMoneyTipText(c) .. br
			if d ~= 0 then
				szXml = szXml .. GetFormatText(_L['Spending:'], 41) .. D.GetMoneyTipText(d) .. br
				szXml = szXml .. GetFormatText(_L['Reall income:'], 41) .. D.GetMoneyTipText(c + d) .. br
			end
		end
		if szXml ~= '' then
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			OutputTip(szXml, 400, { x - w, y, w, h })
		end
	end
	FireUIEvent('GKP_RECORD_TOTAL', a, b)
end

function D.DrawAuctionPage(frame, szKey, szSort)
	if not szKey then
		szKey = frame.hRecordContainer.key or 'nTime'
	end
	if not szSort then
		szSort = frame.hRecordContainer.sort or 'desc'
	end
	local tab = frame.ds:GetAuctionList(szKey, szSort)
	local bMainInstance = frame.ds == MY_GKP_MI.GetDS()
	frame.hRecordContainer.key = szKey
	frame.hRecordContainer.sort = szSort
	frame.hRecordContainer:Clear()
	for k, v in ipairs(tab) do
		if MY_GKP.bDisplayEmptyRecords or v.nMoney ~= 0 then
			local wnd = frame.hRecordContainer:AppendContentFromIni(PLUGIN_ROOT .. '/ui/MY_GKP_Record_Item.ini', 'WndWindow', k)
			local item = wnd:Lookup('', '')
			if k % 2 == 0 then
				item:Lookup('Image_Line'):Hide()
			end
			item:RegisterEvent(32)
			if bMainInstance then
				item.OnItemRButtonClick = function()
					if not LIB.IsDistributer() and not LIB.IsDebugClient('MY_GKP') then
						return LIB.Alert(_L['You are not the distrubutor.'])
					end
					MY_GKP_AuctionUI.Open(this:GetRoot().ds, v, 'EDIT')
				end
			end
			item:Lookup('Text_No'):SetText(k)
			item:Lookup('Image_NameIcon'):FromUITex(GetForceImage(v.dwForceID))
			item:Lookup('Text_Name'):SetText(v.szPlayer)
			item:Lookup('Text_Name'):SetFontColor(LIB.GetForceColor(v.dwForceID))
			local szName = v.szName or LIB.GetItemNameByUIID(v.nUiId)
			item:Lookup('Text_ItemName'):SetText(szName)
			if v.nQuality then
				item:Lookup('Text_ItemName'):SetFontColor(GetItemFontColorByQuality(v.nQuality))
			else
				item:Lookup('Text_ItemName'):SetFontColor(255, 255, 0)
			end
			item:Lookup('Handle_Money'):AppendItemFromString(D.GetMoneyTipText(v.nMoney))
			item:Lookup('Handle_Money'):FormatAllItemPos()
			item:Lookup('Text_Source'):SetText(v.szNpcName)
			if v.bSync then
				item:Lookup('Text_Source'):SetFontColor(0,255,0)
			end
			item:Lookup('Text_Time'):SetText(D.GetTimeString(v.nTime))
			if v.bEdit then
				item:Lookup('Text_Time'):SetFontColor(255,255,0)
			end
			local box = item:Lookup('Box_Item')
			if v.dwTabType == 0 and v.dwIndex == 0 then
				box:SetObject(UI_OBJECT_NOT_NEED_KNOWN)
				box:SetObjectIcon(582)
			else
				if v.nBookID then
					UpdataItemInfoBoxObject(box, v.nVersion, v.dwTabType, v.dwIndex, 99999, v.nBookID)
				else
					UpdataItemInfoBoxObject(box, v.nVersion, v.dwTabType, v.dwIndex, v.nStackNum)
				end
			end
			local hItemName = item:Lookup('Text_ItemName')
			for kk, vv in ipairs({'OnItemMouseEnter', 'OnItemMouseLeave', 'OnItemLButtonDown', 'OnItemLButtonUp'}) do
				hItemName[vv] = function()
					if box[vv] then
						this = box
						box[vv]()
					end
				end
			end
			if bMainInstance then
				wnd:Lookup('WndButton_Delete').OnLButtonClick = function()
					if not LIB.IsDistributer() and not LIB.IsDebugClient('MY_GKP') then
						return LIB.Alert(_L['You are not the distrubutor.'])
					end
					v.bDelete = not v.bDelete
					frame.ds:SetAuctionRec(v)
					if LIB.IsDistributer() then
						LIB.SendBgMsg(PLAYER_TALK_CHANNEL.RAID, 'MY_GKP', 'edit', v)
					end
				end
			else
				wnd:Lookup('WndButton_Delete'):Hide()
			end
			-- tip
			item:Lookup('Text_Name').data = v
			if v.bDelete then
				wnd:SetAlpha(80)
			end
		end
	end
	frame.hRecordContainer:FormatAllContentPos()
end

function D.DrawPaymentPage(frame, szKey, szSort)
	if not szKey then
		szKey = frame.hAccountContainer.key or 'szPlayer'
	end
	if not szSort then
		szSort = frame.hAccountContainer.sort or 'desc'
	end
	local tab = frame.ds:GetPaymentList(szKey, szSort)
	local bMainInstance = frame.ds == MY_GKP_MI.GetDS()
	frame.hAccountContainer.key = szKey
	frame.hAccountContainer.sort = szSort
	frame.hAccountContainer:Clear()
	local tMoney = GetClientPlayer().GetMoney()
	for k, v in ipairs(tab) do
		local c = frame.hAccountContainer:AppendContentFromIni(PLUGIN_ROOT .. '/ui/MY_GKP_Account_Item.ini', 'WndWindow', k)
		local item = c:Lookup('', '')
		if k % 2 == 0 then
			item:Lookup('Image_Line'):Hide()
		end
		c:Lookup('', 'Handle_Money'):AppendItemFromString(D.GetMoneyTipText(v.nGold))
		c:Lookup('', 'Handle_Money'):FormatAllItemPos()
		item:Lookup('Text_No'):SetText(k)
		if v.szPlayer and v.szPlayer ~= 'System' then
			item:Lookup('Image_NameIcon'):FromUITex(GetForceImage(v.dwForceID))
			item:Lookup('Text_Name'):SetText(v.szPlayer)
			item:Lookup('Text_Change'):SetText(_L['Player\'s transation'])
			item:Lookup('Text_Name'):SetFontColor(LIB.GetForceColor(v.dwForceID))
		else
			item:Lookup('Image_NameIcon'):FromUITex('ui/Image/uicommon/commonpanel4.UITex',3)
			item:Lookup('Text_Name'):SetText(_L['System'])
			item:Lookup('Text_Change'):SetText(_L['Reward & other ways'])
		end
		item:Lookup('Text_Map'):SetText(Table_GetMapName(v.dwMapID))
		item:Lookup('Text_Time'):SetText(D.GetTimeString(v.nTime))
		if bMainInstance then
			c:Lookup('WndButton_Delete').OnLButtonClick = function()
				v.bDelete = not v.bDelete
				frame.ds:SetPaymentRec(v)
			end
		else
			c:Lookup('WndButton_Delete'):Hide()
		end
		-- tip
		item:Lookup('Text_Name').data = v
		if v.bDelete then
			c:SetAlpha(80)
		end
	end
	frame.hAccountContainer:FormatAllContentPos()
end

---------------------------------------------------------------------->
-- 窗体创建时会被调用
----------------------------------------------------------------------<
function MY_GKP_UI.OnFrameCreate()
	this.hRecordContainer = this:Lookup('PageSet_Menu/Page_GKP_Record/WndScroll_GKP_Record/WndContainer_Record_List')
	this.hAccountContainer = this:Lookup('PageSet_Menu/Page_GKP_Account/WndScroll_GKP_Account/WndContainer_Account_List')
	local ui = UI(this)
	ui:Text(_L['GKP Golden Team Record']):Anchor('CENTER')
	ui:Append('WndButton', {
		x = 875, y = 48, w = 100, h = 35,
		text = g_tStrings.STR_LOG_SET,
		onclick = function()
			LIB.ShowPanel()
			LIB.FocusPanel()
			LIB.SwitchTab('MY_GKP')
		end,
	})
	ui:Append('WndButton3', {
		name = 'Btn_AddManually',
		x = 15, y = 660, text = _L['Add Manually'],
		onclick = function()
			if not LIB.IsDistributer() and not LIB.IsDebugClient('MY_GKP') then -- debug
				return LIB.Alert(_L['You are not the distrubutor.'])
			end
			MY_GKP_AuctionUI.Open(this:GetRoot().ds)
		end,
	})
	-- 结算工资按钮
	ui:Append('WndButton3', {
		name = 'Btn_Calculate',
		x = 840, y = 620, text = g_tStrings.GOLD_TEAM_SYLARY_LIST,
		onclick = function()
			local ds = this:GetRoot().ds
			local me = GetClientPlayer()
			if not me.IsInParty() and not LIB.IsDebugClient('MY_GKP') then
				return LIB.Alert(_L['You are not in the team.'])
			end
			local team = GetClientTeam()
			if IsEmpty(ds:GetAuctionList()) then
				return LIB.Alert(_L['No Record'])
			end
			if not LIB.IsDistributer() and not LIB.IsDebugClient('MY_GKP') then
				return LIB.Alert(_L['You are not the distrubutor.'])
			end
			GetUserInput(_L['Total Amount of People with Output Settle Account'],function(num)
				if not tonumber(num) then return end
				local a, b = ds:GetAuctionSum()
				LIB.Talk(PLAYER_TALK_CHANNEL.RAID, _L['Salary Settle Account'])
				LIB.Talk(PLAYER_TALK_CHANNEL.RAID, _L('Salary Statistic: income  %d Gold.', a))
				LIB.Talk(PLAYER_TALK_CHANNEL.RAID, _L('Salary Allowance: %d Gold.', b))
				LIB.Talk(PLAYER_TALK_CHANNEL.RAID, _L('Reall Salary: %d Gold.',a + b, a, b))
				if a + b >= 0 then
					LIB.Talk(PLAYER_TALK_CHANNEL.RAID, _L('Amount of People with Settle Account: %d',num))
					LIB.Talk(PLAYER_TALK_CHANNEL.RAID, _L('Actual per person: %d Gold.',math.floor((a + b) / num)))
				else
					LIB.Talk(PLAYER_TALK_CHANNEL.RAID, _L['The Account is Negative, no money is coming out!'])
				end
			end, nil, nil, nil, team.GetTeamSize())
		end,
	})
	-- 消费情况按钮
	ui:Append('WndButton3', {
		name = 'GOLD_TEAM_BID_LIST',
		x = 840, y = 660, text = g_tStrings.GOLD_TEAM_BID_LIST,
		onclick = function()
			local ds = this:GetRoot().ds
			local me = GetClientPlayer()
			if not me.IsInParty() and not LIB.IsDebugClient('MY_GKP') then
				return LIB.Alert(_L['You are not in the team.'])
			end
			local tMember = {}
			local aAuction = ds:GetAuctionList()
			if IsEmpty(aAuction) then
				return LIB.Alert(_L['No Record'])
			end
			if not LIB.IsDistributer() and not LIB.IsDebugClient('MY_GKP') then
				return LIB.Alert(_L['You are not the distrubutor.'])
			end
			FireUIEvent('MY_GKP_SEND_BEGIN')
			local tTime = {}
			for k, v in ipairs(aAuction) do
				if not v.bDelete then
					if not tMember[v.szPlayer] then
						tMember[v.szPlayer] = 0
					end
					if tonumber(v.nMoney) > 0 then
						tMember[v.szPlayer] = tMember[v.szPlayer] + v.nMoney
					end
					table.insert(tTime, { nTime = v.nTime })
				end
			end
			table.sort(tTime, function(a, b)
				return a.nTime < b.nTime
			end)
			local nTime = tTime[#tTime].nTime - tTime[1].nTime -- 所花费的时间

			LIB.Talk(PLAYER_TALK_CHANNEL.RAID, _L['--- Consumption ---'])
			LIB.SendBgMsg(PLAYER_TALK_CHANNEL.RAID, 'MY_GKP', 'GKP_INFO', 'Start', '--- Consumption ---')
			local sort = {}
			for k,v in pairs(tMember) do
				table.insert(sort,{ szName = k, nGold = v })
			end

			table.sort(sort,function(a,b) return a.nGold < b.nGold end)
			for k, v in ipairs(sort) do
				if v.nGold > 0 then
					LIB.Talk(PLAYER_TALK_CHANNEL.RAID, { D.GetFormatLink(v.szName, true), D.GetFormatLink(g_tStrings.STR_TALK_HEAD_SAY1 .. v.nGold .. g_tStrings.STR_GOLD .. g_tStrings.STR_FULL_STOP) })
				end
				LIB.SendBgMsg(PLAYER_TALK_CHANNEL.RAID, 'MY_GKP', 'GKP_INFO', 'Info', v.szName, v.nGold)
			end
			LIB.Talk(PLAYER_TALK_CHANNEL.RAID, _L('Total Auction: %d Gold.', ds:GetAuctionSum()))
			LIB.SendBgMsg(PLAYER_TALK_CHANNEL.RAID, 'MY_GKP', 'GKP_INFO', 'End', _L('Total Auction: %d Gold.', ds:GetAuctionSum()), ds:GetAuctionSum(), nTime)
		end,
	})
	-- 欠费情况
	ui:Append('WndButton3', {
		name = 'Debt',
		x = 690, y = 660, text = _L['Debt Issued'],
		onclick = function()
			local ds = this:GetRoot().ds
			local me = GetClientPlayer()
			if not me.IsInParty() and not LIB.IsDebugClient('MY_GKP') then
				return LIB.Alert(_L['You are not in the team.'])
			end
			local tMember = {}
			local aAuction = ds:GetAuctionList()
			local aPayment = ds:GetPaymentList()
			if IsEmpty(aAuction) then
				return LIB.Alert(_L['No Record'])
			end
			if not LIB.IsDistributer() and not LIB.IsDebugClient('MY_GKP') then
				return LIB.Alert(_L['You are not the distrubutor.'])
			end
			FireUIEvent('MY_GKP_SEND_BEGIN')
			for k, v in ipairs(aAuction) do
				if not v.bDelete then
					if tonumber(v.nMoney) > 0 then
						if not tMember[v.szPlayer] then
							tMember[v.szPlayer] = 0
						end
						tMember[v.szPlayer] = tMember[v.szPlayer] + v.nMoney
					end
				end
			end
			local _Account = {}
			for k, v in ipairs(aPayment) do
				if not v.bDelete and v.szPlayer and v.szPlayer ~= 'System' then
					if tMember[v.szPlayer] then
						tMember[v.szPlayer] = tMember[v.szPlayer] - v.nGold
					else
						if not _Account[v.szPlayer] then
							_Account[v.szPlayer] = 0
						end
						_Account[v.szPlayer] = _Account[v.szPlayer] + v.nGold
					end
				end
			end
			-- 欠账
			local tMember2 = {}
			for k, v in pairs(tMember) do
				if v ~= 0 then
					table.insert(tMember2, { szName = k, nGold = v * -1 })
				end
			end
			-- 正账
			for k, v in pairs(_Account) do
				if v > 0 then
					table.insert(tMember2, { szName = k, nGold = v })
				end
			end

			table.sort(tMember2, function(a, b) return a.nGold < b.nGold end)
			LIB.Talk(PLAYER_TALK_CHANNEL.RAID, _L['Information on Debt'])
			LIB.SendBgMsg(PLAYER_TALK_CHANNEL.RAID, 'MY_GKP', 'GKP_INFO', 'Start', 'Information on Debt')
			for k, v in pairs(tMember2) do
				if v.nGold < 0 then
					LIB.Talk(PLAYER_TALK_CHANNEL.RAID, { D.GetFormatLink(v.szName, true), D.GetFormatLink(g_tStrings.STR_TALK_HEAD_SAY1 .. v.nGold .. g_tStrings.STR_GOLD .. g_tStrings.STR_FULL_STOP) })
					LIB.SendBgMsg(PLAYER_TALK_CHANNEL.RAID, 'MY_GKP', 'GKP_INFO', 'Info', v.szName, v.nGold, '-')
				else
					LIB.Talk(PLAYER_TALK_CHANNEL.RAID, { D.GetFormatLink(v.szName, true), D.GetFormatLink(g_tStrings.STR_TALK_HEAD_SAY1 .. '+' .. v.nGold .. g_tStrings.STR_GOLD .. g_tStrings.STR_FULL_STOP) })
					LIB.SendBgMsg(PLAYER_TALK_CHANNEL.RAID, 'MY_GKP', 'GKP_INFO', 'Info', v.szName, v.nGold, '+')
				end
			end
			local nGold, nGold2 = 0, 0
			for _, v in ipairs(aPayment) do
				if not v.bDelete then
					if v.szPlayer and v.szPlayer ~= 'System' then -- 必须要有交易对象
						if tonumber(v.nGold) > 0 then
							nGold = nGold + v.nGold
						else
							nGold2 = nGold2 + v.nGold
						end
					end
				end
			end
			if nGold ~= 0 then
				LIB.Talk(PLAYER_TALK_CHANNEL.RAID, _L('Received: %d Gold.', nGold))
			end
			if nGold2 ~= 0 then
				LIB.Talk(PLAYER_TALK_CHANNEL.RAID, _L('Spending: %d Gold.', nGold2 * -1))
			end
			LIB.SendBgMsg(PLAYER_TALK_CHANNEL.RAID, 'MY_GKP', 'GKP_INFO', 'End', _L('Received: %d Gold.', nGold))
		end,
	})
	-- 清空数据
	ui:Append('WndButton3', {
		name = 'Btn_ClearRecord',
		x = 540, y = 660, text = _L['Clear Record'],
		onclick = function()
			local fnAction = function()
				MY_GKP_MI.NewDS()
			end
			LIB.Confirm(_L['Are you sure to wipe all of the records?'], fnAction)
		end,
	})
	-- 历史记录
	ui:Append('WndButton3', {
		name = 'Btn_HistoryRecord',
		x = 390, y = 660, text = _L['History record'],
		menu = function()
			local menu = {}
			local aFiles = MY_GKP.GetHistoryFiles()
			for i = 1, min(#aFiles, 21) do
				local info = aFiles[i]
				insert(menu, {
					szOption = info.filename .. '.gkp',
					fnAction = function()
						MY_GKP_Open(info.fullpath)
					end,
				})
			end
			if #menu > 0 then
				insert(menu, CONSTANT.MENU_DIVIDER)
			end
			insert(menu, {
				szOption = _L['Manually load from file.'],
				rgb = { 255, 255, 0 },
				fnAction = function()
					local file = GetOpenFileName(
						_L['Please select gkp file.'],
						'GKP File(*.gkp,*.gkp.jx3dat)\0*.gkp;*.gkp.jx3dat\0All Files(*.*)\0*.*\0\0',
						LIB.FormatPath({'userdata/gkp', PATH_TYPE.ROLE})
					)
					if not IsEmpty(file) then
						LIB.Confirm(_L['Are you sure to cover the current information with the last record data?'], function()
							D.LoadData(file, true)
							LIB.Alert(_L['Reocrd Recovered.'])
						end)
					end
				end
			})
			return menu
		end,
	})
	-- 同步数据
	ui:Append('WndButton3', {
		name = 'Btn_SyncRecord',
		x = 240, y = 660, text = _L['Manual SYNC'],
		tip = _L['Left click to sync from others, right click to sync to others'],
		tippostype = UI.TIP_POSITION.TOP_BOTTOM,
		lmenu = function()
			local me = GetClientPlayer()
			if me.IsInParty() then
				local menu = MY_GKP.GetTeamMemberMenu(function(v)
					LIB.Confirm(_L('Wheater replace the current record with the synchronization [%s]\'s record?\n Please notice, this means you are going to lose the information of current record.', v.szName), function()
						LIB.Alert(_L('Asking for the sychoronization information...\n If no response in longtime, it may because [%s] is not using MY_GKP plugin or not responding.', v.szName))
						LIB.SendBgMsg(PLAYER_TALK_CHANNEL.RAID, 'MY_GKP', 'GKP_Sync', v.szName) -- 请求同步信息
					end)
				end, true)
				table.insert(menu, 1, { bDevide = true })
				table.insert(menu, 1, { szOption = _L['Please select which will be the one you are going to ask record for.'], bDisable = true })
				return menu
			else
				LIB.Alert(_L['You are not in the team.'])
			end
		end,
		rmenu = function()
			local me = GetClientPlayer()
			if not me.IsInParty() then
				LIB.Alert(_L['You are not in the team.'])
			elseif not LIB.IsDistributer() and not LIB.IsDebugClient('MY_GKP') then
				LIB.Alert(_L['You are not the distrubutor.'])
			else
				local menu = MY_GKP.GetTeamMemberMenu(function(v)
					LIB.Confirm(_L('Wheater synchronize your record to [%s]?\n Please notice, this means the opposite sites are going to lose their information of current record.', v.szName), function()
						MY_GKP_MI.SyncSend(v.dwID)
					end)
				end, true)
				table.insert(menu, { bDevide = true })
				table.insert(menu, {
					szOption = _L['Full raid.'],
					fnAction = function()
						LIB.Confirm(_L['Wheater synchronize your record to full raid?\n Please notice, this means the opposite sites are going to lose their information of current record.'], function()
							MY_GKP_MI.SyncSend(0)
						end)
					end,
				})
				table.insert(menu, 1, { bDevide = true })
				table.insert(menu, 1, { szOption = _L['Please select which will be the one you are going to send record to.'], bDisable = true })
				return menu
			end
		end,
	})
	-- 恢复历史记录
	ui:Append('WndButton3', {
		name = 'Btn_SetHistory',
		x = 390, y = 660, text = _L['Set current record'],
		menu = function()
			local frame = this:GetRoot()
			LIB.Confirm(_L['Are you sure to cover the current information with the last record data?'], function()
				MY_GKP_MI.LoadHistory(frame.ds:GetFilePath())
				MY_GKP_MI.OpenPanel()
				Wnd.CloseWindow(frame)
				LIB.Alert(_L['Reocrd Recovered.'])
			end)
		end,
	})

	local hPageSet = ui:Children('#PageSet_Menu')
	hPageSet:Children('#WndCheck_GKP_Record'):Children('#Text_GKP_Record'):Text(g_tStrings.GOLD_BID_RECORD_STATIC_TITLE)
	hPageSet:Children('#WndCheck_GKP_Account'):Children('#Text_GKP_Account'):Text(g_tStrings.GOLD_BID_RPAY_STATIC_TITLE)
	LIB.RegisterEsc('MY_GKP', D.IsOpened, D.ClosePanel)
	-- 排序
	local page = this:Lookup('PageSet_Menu/Page_GKP_Record')
	local t = {
		{'#',         false},
		{'szPlayer',  _L['Gainer']},
		{'szName',    _L['Name of the Items']},
		{'nMoney',    _L['Auction Price']},
		{'szNpcName', _L['Source of the Object']},
		{'nTime',     _L['Distribution Time']},
	}
	for k, v in ipairs(t) do
		if v[2] then
			local txt = page:Lookup('', 'Text_Record_Break' ..k)
			txt:RegisterEvent(786)
			txt:SetText(v[2])
			txt.OnItemLButtonClick = function()
				local sort = txt.sort or 'asc'
				D.DrawAuctionPage(this:GetRoot(), v[1], sort)
				if sort == 'asc' then
					txt.sort = 'desc'
				else
					txt.sort = 'asc'
				end
			end
			txt.OnItemMouseEnter = function()
				this:SetFontColor(255, 128, 0)
			end
			txt.OnItemMouseLeave = function()
				this:SetFontColor(255, 255, 255)
			end
		end
	end

	-- 排序2
	local page = this:Lookup('PageSet_Menu/Page_GKP_Account')
	local t = {
		{'#',        false},
		{'szPlayer', _L['Transation Target']},
		{'nGold',    _L['Changes in Money']},
		{'szPlayer', _L['Ways of Money Change']},
		{'dwMapID',  _L['The Map of Current Location when Money Changes']},
		{'nTime',    _L['The Change of Time']},
	}

	for k, v in ipairs(t) do
		if v[2] then
			local txt = page:Lookup('', 'Text_Account_Break' .. k)
			txt:RegisterEvent(786)
			txt:SetText(v[2])
			txt.OnItemLButtonClick = function()
				local sort = txt.sort or 'asc'
				D.DrawPaymentPage(this:GetRoot(), v[1], sort)
				if sort == 'asc' then
					txt.sort = 'desc'
				else
					txt.sort = 'asc'
				end
			end
			txt.OnItemMouseEnter = function()
				this:SetFontColor(255, 128, 0)
			end
			txt.OnItemMouseLeave = function()
				this:SetFontColor(255, 255, 255)
			end
		end
	end

	this.SetDS = D.SetDS
	this:RegisterEvent('MY_GKP_DATA_UPDATE')
	this:RegisterEvent('MY_GKP_SEND_BEGIN')
	this:RegisterEvent('MY_GKP_SEND_FINISH')
end

function MY_GKP_UI.OnFrameShow()
	this:BringToTop()
	PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
end

function MY_GKP_UI.OnFrameHide()
	PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
end

function MY_GKP_UI.OnEvent(event)
	if event == 'MY_GKP_DATA_UPDATE' then
		if arg0 == '' or arg0 == this.ds:GetFilePath() then
			if arg1 == 'MAP' or arg1 == 'TIME' or arg1 == 'ALL' then
				D.DrawTitle(this)
			end
			if arg1 == 'AUCTION' or arg1 == 'PAYMENT' or arg1 == 'ALL' then
				if arg1 == 'AUCTION' or arg1 == 'ALL' then
					D.DrawAuctionPage(this)
				end
				if arg1 == 'PAYMENT' or arg1 == 'ALL' then
					D.DrawPaymentPage(this)
				end
				D.DrawStat(this)
			end
		end
	elseif event == 'MY_GKP_SEND_BEGIN' then
		this:Lookup('Debt'):Enable(false)
		this:Lookup('GOLD_TEAM_BID_LIST'):Enable(false)
	elseif event == 'MY_GKP_SEND_FINISH' then
		this:Lookup('Debt'):Enable(true)
		this:Lookup('GOLD_TEAM_BID_LIST'):Enable(true)
	end
end

function MY_GKP_UI.OnFrameKeyDown()
	if GetKeyName(Station.GetMessageKey()) == 'Esc' then
		D.ClosePanel()
		return 1
	end
end

function MY_GKP_UI.OnLButtonClick()
	local name = this:GetName()
	if name == 'Btn_Close' then
		Wnd.CloseWindow(this:GetRoot())
	end
end

function MY_GKP_UI.OnItemLButtonDown()
	local szName = this:GetName()
	if szName == 'Text_Name' then
		if IsCtrlKeyDown() then
			return LIB.EditBox_AppendLinkPlayer(this:GetText())
		end
	end
end

function MY_GKP_UI.OnItemMouseEnter()
	local frame = this:GetRoot()
	if this:GetName() == 'Text_Name' then
		local data = this.data
		local szIcon, nFrame = GetForceImage(data.dwForceID)
		local r, g, b = LIB.GetForceColor(data.dwForceID)
		local szXml = GetFormatImage(szIcon,nFrame,20,20) .. GetFormatText('  ' .. data.szPlayer .. g_tStrings.STR_COLON .. '\n', 136, r, g, b)
		if IsCtrlKeyDown() then
			szXml = szXml .. GetFormatText(g_tStrings.DEBUG_INFO_ITEM_TIP .. '\n', 136, 255, 0, 0)
			szXml = szXml .. GetFormatText(EncodeLUAData(data, ' '), 136, 255, 255, 255)
		else
			szXml = szXml .. GetFormatText(_L['System Information as Shown Below\n\n'],136,255,255,255)
			local nNum,nNum1,nNum2 = 0,0,0
			for kk,vv in ipairs(frame.ds:GetAuctionList()) do
				if vv.szPlayer == data.szPlayer and not vv.bDelete then
					if  vv.nMoney > 0 then
						nNum = nNum + vv.nMoney
					else
						nNum1 = nNum1 + vv.nMoney
					end
				end
			end
			local r, g, b = D.GetMoneyCol(nNum)
			szXml = szXml .. GetFormatText(_L['Total Cosumption:'],136,255,128,0) .. GetFormatText(nNum ..g_tStrings.STR_GOLD .. g_tStrings.STR_FULL_STOP .. '\n',136,r,g,b)
			local r, g, b = D.GetMoneyCol(nNum1)
			szXml = szXml .. GetFormatText(_L['Total Allowance:'],136,255,128,0) .. GetFormatText(nNum1 ..g_tStrings.STR_GOLD .. g_tStrings.STR_FULL_STOP .. '\n',136,r,g,b)
			for kk, vv in ipairs(frame.ds:GetPaymentList()) do
				if vv.szPlayer == data.szPlayer and not vv.bDelete and vv.nGold > 0 then
					nNum2 = nNum2 + vv.nGold
				end
			end
			local r, g, b = D.GetMoneyCol(nNum2)
			szXml = szXml .. GetFormatText(_L['Total Payment:'],136,255,128,0) .. GetFormatText(nNum2 ..g_tStrings.STR_GOLD .. g_tStrings.STR_FULL_STOP .. '\n',136,r,g,b)
			local nNum3 = nNum+nNum1-nNum2
			if nNum3 < 0 then
				nNum3 = 0
			end
			local r, g, b = D.GetMoneyCol(nNum3)
			szXml = szXml .. GetFormatText(_L['Money on Debt:'],136,255,128,0) .. GetFormatText(nNum3 ..g_tStrings.STR_GOLD .. g_tStrings.STR_FULL_STOP .. '\n',136,r,g,b)
		end
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputTip(szXml, 400, { x, y, w, h })
	end
end

function MY_GKP_UI.OnItemMouseLeave()
	HideTip()
end

do
local nIndex = 0
function MY_GKP_Open(szFilePath)
	local szName = 'MY_GKP'
	local ds = MY_GKP_DS(szFilePath)
	if ds == MY_GKP_MI.GetDS() then
		szName = szName .. '#MI'
		local frame = Station.Lookup('Normal/' .. szName)
		if frame then
			frame:Show()
			return
		end
	else
		nIndex = nIndex + 1
		szName = szName .. '#' .. nIndex
	end
	Wnd.OpenWindow(SZ_INI, szName):SetDS(szFilePath)
end
end
