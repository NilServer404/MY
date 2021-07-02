--------------------------------------------------------
-- This file is part of the JX3 Plugin Project.
-- @desc     : �������ģ��
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
-- lib apis caching
local LIB = Boilerplate
local UI, GLOBAL, CONSTANT = LIB.UI, LIB.GLOBAL, LIB.CONSTANT
local PACKET_INFO, DEBUG_LEVEL, PATH_TYPE = LIB.PACKET_INFO, LIB.DEBUG_LEVEL, LIB.PATH_TYPE
local wsub, count_c, lodash = LIB.wsub, LIB.count_c, LIB.lodash
local pairs_c, ipairs_c, ipairs_r = LIB.pairs_c, LIB.ipairs_c, LIB.ipairs_r
local spairs, spairs_r, sipairs, sipairs_r = LIB.spairs, LIB.spairs_r, LIB.sipairs, LIB.sipairs_r
local IsNil, IsEmpty, IsEquals, IsString = LIB.IsNil, LIB.IsEmpty, LIB.IsEquals, LIB.IsString
local IsBoolean, IsNumber, IsHugeNumber = LIB.IsBoolean, LIB.IsNumber, LIB.IsHugeNumber
local IsTable, IsArray, IsDictionary = LIB.IsTable, LIB.IsArray, LIB.IsDictionary
local IsFunction, IsUserdata, IsElement = LIB.IsFunction, LIB.IsUserdata, LIB.IsElement
local EncodeLUAData, DecodeLUAData, Schema = LIB.EncodeLUAData, LIB.DecodeLUAData, LIB.Schema
local GetTraceback, RandomChild, GetGameAPI = LIB.GetTraceback, LIB.RandomChild, LIB.GetGameAPI
local Get, Set, Clone, GetPatch, ApplyPatch = LIB.Get, LIB.Set, LIB.Clone, LIB.GetPatch, LIB.ApplyPatch
local IIf, CallWithThis, SafeCallWithThis = LIB.IIf, LIB.CallWithThis, LIB.SafeCallWithThis
local Call, XpCall, SafeCall, NSFormatString = LIB.Call, LIB.XpCall, LIB.SafeCall, LIB.NSFormatString
-------------------------------------------------------------------------------------------------------
local _L = LIB.LoadLangPack(PACKET_INFO.FRAMEWORK_ROOT .. 'lang/lib/')

local RENDERED_FLAG_KEY = NSFormatString('b{$NS}ChatRendered')
local ITEM_LBUTTONDOWN_KEY = NSFormatString('__{$NS}_OnItemLButtonDown')

-- ��ȡ���������
-- (WndEdit?) LIB.GetChatInput()
function LIB.GetChatInput()
	local frame = Station.SearchFrame('EditBox')
	return frame and frame:Lookup('Edit_Input')
end

-- ��������ٳ�����
-- ���츴�Ʋ�����
function LIB.RepeatChatLine(hTime)
	local edit = LIB.GetChatInput()
	if not edit then
		return
	end
	LIB.CopyChatLine(hTime)
	local tMsg = edit:GetTextStruct()
	if #tMsg == 0 then
		return
	end
	local nChannel, szName = EditBox_GetChannel()
	if LIB.CanUseChatChannel(nChannel) then
		GetClientPlayer().Talk(nChannel, szName or '', tMsg)
		edit:ClearText()
	end
end

-- ����ɾ����
function LIB.RemoveChatLine(hTime)
	local nIndex   = hTime:GetIndex()
	local hHandle  = hTime:GetParent()
	local nCount   = hHandle:GetItemCount()
	local bCurrent = true
	for i = nIndex, nCount - 1 do
		local hItem = hHandle:Lookup(nIndex)
		if hItem:GetType() == 'Text' and
		(hItem:GetName() == 'timelink' or
		 hItem:GetName() == 'copylink' or
		 hItem:GetName() == 'copy') then
		-- timestrap found
			if not bCurrent then
			-- is not current timestrap
				break
			end
		else -- current timestrap ended
			bCurrent = false
		end -- remove until next timestrap
		hHandle:RemoveItem(hItem)
	end
	hHandle:FormatAllItemPos()
end

local function GetCopyLinkScript(opt)
	local handlerEntry = NSFormatString('{$NS}.ChatLinkEventHandlers')
	local szScript = NSFormatString('this[\'b{$NS}ChatRendered\']=true;this.OnItemMouseEnter=')
		.. handlerEntry .. '.OnCopyMouseEnter;this.OnItemMouseLeave=' .. handlerEntry .. '.OnCopyMouseLeave;'
	if opt.lclick ~= false then
		szScript = szScript .. 'this.bLButton=true;this.OnItemLButtonDown='.. handlerEntry .. '.OnCopyLClick;'
		if opt.richtext and not LIB.ContainsEchoMsgHeader(opt.richtext) then
			szScript = szScript .. 'this.szRichText=' .. EncodeLUAData(opt.richtext or '') .. ';'
		end
	end
	if opt.mclick then
		szScript = szScript .. 'this.bMButton=true;this.OnItemMButtonDown='.. handlerEntry .. '.OnCopyMClick;'
	end
	if opt.rclick ~= false then
		szScript = szScript .. 'this.bRButton=true;this.OnItemRButtonDown='.. handlerEntry .. '.OnCopyRClick;'
	end
	return szScript
end

-- ��ȡ�����������ַ���
-- (string) LIB.GetChatCopyXML(szText: string, opt?: table)
function LIB.GetChatCopyXML(szText, opt)
	if not IsString(szText) then
		szText = _L[' * ']
	end
	if not IsTable(opt) then
		opt = { f = 10 }
	end
	return GetFormatText(szText, opt.f, opt.r, opt.g, opt.b, 82691, GetCopyLinkScript(opt), 'copylink')
end

-- ��ȡ����������ʱ�䴮
-- (string) LIB.GetChatTimeXML(szText: string, opt?: table)
function LIB.GetChatTimeXML(dwTime, opt)
	if not IsTable(opt) then
		opt = { f = 10 }
	end
	local szText = LIB.FormatTime(dwTime, opt.s or '[%hh:%mm:%ss]')
	return GetFormatText(szText, opt.f, opt.r, opt.g, opt.b, 82691, GetCopyLinkScript(opt), 'timelink')
end

-- ���������õ�������
-- (void) LIB.FocusChatInput()
function LIB.FocusChatInput()
	local edit = LIB.GetChatInput()
	if edit then
		Station.SetFocusWindow(edit)
	end
end

-- ���������
-- (void) LIB.ClearChatInput()
function LIB.ClearChatInput()
	local edit = LIB.GetChatInput()
	if not edit then
		return
	end
	edit:ClearText()
end

-- LIB.InsertChatInput(szType, ...data)
function LIB.InsertChatInput(szType, ...)
	local edit = LIB.GetChatInput()
	if not edit then
		return
	end
	local szText, data
	if szType == 'achievement' then
		local dwAchieve = ...
		local achi = LIB.GetAchievement(dwAchieve)
		if not achi then
			return
		end
		szText = '[' .. achi.szName .. ']'
		data = {
			type = 'achievement',
			text = szText,
			id = achi.dwID,
		}
	elseif szType == 'iteminfo' then
		local dwTabType, dwIndex, nBookInfo, nVersion = ...
		local itemInfo = GetItemInfo(dwTabType, dwIndex)
		if itemInfo then
			if not nVersion then
				nVersion = GLOBAL.CURRENT_ITEM_VERSION
			end
			if itemInfo.nGenre == ITEM_GENRE.BOOK then
				if nBookInfo then
					local nBookID, nSegmentID = GlobelRecipeID2BookID(nBookInfo)
					if nBookID then
						szText = '[' .. Table_GetSegmentName(nBookID, nSegmentID) .. ']'
						data = {
							type = 'book',
							text = szText,
							version = nVersion,
							tabtype = dwTabType,
							index = dwIndex,
							bookinfo = nBookInfo,
						}
					end
				end
			else
				szText = '[' .. LIB.GetItemNameByItemInfo(itemInfo) .. ']'
				data = {
					type = 'iteminfo',
					text = szText,
					version = nVersion,
					tabtype = dwTabType,
					index = dwIndex,
				}
			end
		end
	end
	if not szText or not data then
		return false
	end
	edit:GetRoot():Show()
	edit:InsertObj(szText, data)
	return true
end

-- ����������
function LIB.CopyChatLine(hTime, bTextEditor, bRichText)
	local edit = LIB.GetChatInput()
	if bTextEditor then
		edit = UI.OpenTextEditor():Find('.WndEdit')[1]
	end
	if not edit then
		return
	end
	edit:GetRoot():Show()
	edit:ClearText()
	if bRichText then
		edit:InsertText(hTime.szRichText)
	else
		local h, i, bBegin, bContent = hTime:GetParent(), hTime:GetIndex(), nil, false
		-- loop
		for i = i + 1, h:GetItemCount() - 1 do
			local p = h:Lookup(i)
			if p:GetType() == 'Text' then
				local szName = p:GetName()
				if szName ~= 'timelink' and szName ~= 'copylink' and szName ~= 'msglink' and szName ~= 'time' then
					local szText, bEnd = p:GetText(), false
					if not bTextEditor and StringFindW(szText, '\n') then
						szText = wgsub(szText, '\n', '')
						bEnd = true
					end
					bContent = true
					if szName == 'itemlink' then
						edit:InsertObj(szText, { type = 'item', text = szText, item = p:GetUserData() })
					elseif szName == 'iteminfolink' then
						edit:InsertObj(szText, { type = 'iteminfo', text = szText, version = p.nVersion, tabtype = p.dwTabType, index = p.dwIndex })
					elseif szName == 'namelink' or sub(szName, 1, 9) == 'namelink_' then
						if bBegin == nil then
							bBegin = false
						end
						edit:InsertObj(szText, { type = 'name', text = szText, name = match(szText, '%[(.*)%]') })
					elseif szName == 'questlink' then
						edit:InsertObj(szText, { type = 'quest', text = szText, questid = p:GetUserData() })
					elseif szName == 'recipelink' then
						edit:InsertObj(szText, { type = 'recipe', text = szText, craftid = p.dwCraftID, recipeid = p.dwRecipeID })
					elseif szName == 'enchantlink' then
						edit:InsertObj(szText, { type = 'enchant', text = szText, proid = p.dwProID, craftid = p.dwCraftID, recipeid = p.dwRecipeID })
					elseif szName == 'skilllink' then
						local o = Clone(p.skillKey)
						o.type, o.text = 'skill', szText
						edit:InsertObj(szText, o)
					elseif szName =='skillrecipelink' then
						edit:InsertObj(szText, { type = 'skillrecipe', text = szText, id = p.dwID, level = p.dwLevelD })
					elseif szName =='booklink' then
						edit:InsertObj(szText, { type = 'book', text = szText, tabtype = p.dwTabType, index = p.dwIndex, bookinfo = p.nBookRecipeID, version = p.nVersion })
					elseif szName =='achievementlink' then
						edit:InsertObj(szText, { type = 'achievement', text = szText, id = p.dwID })
					elseif szName =='designationlink' then
						edit:InsertObj(szText, { type = 'designation', text = szText, id = p.dwID, prefix = p.bPrefix })
					elseif szName =='eventlink' then
						if szText and #szText > 0 then -- ���˲����Ϣ
							edit:InsertObj(szText, { type = 'eventlink', text = szText, name = p.szName, linkinfo = p.szLinkInfo })
						end
					else
						if bBegin == false then
							for _, v in ipairs({g_tStrings.STR_TALK_HEAD_WHISPER, g_tStrings.STR_TALK_HEAD_SAY, g_tStrings.STR_TALK_HEAD_SAY1, g_tStrings.STR_TALK_HEAD_SAY2 }) do
								local nB, nE = StringFindW(szText, v)
								if nB then
									szText, bBegin = sub(szText, nB + nE), true
									edit:ClearText()
								end
							end
						end
						if szText ~= '' and (getn(edit:GetTextStruct()) > 0 or szText ~= g_tStrings.STR_FACE) then
							edit:InsertText(szText)
						end
					end
					if bEnd then
						break
					end
				elseif bTextEditor and bContent and (szName == 'timelink' or szName == 'copylink' or szName == 'msglink' or szName == 'time') then
					break
				end
			elseif p:GetType() == 'Image' or p:GetType() == 'Animate' then
				local dwID = tonumber((p:GetName():gsub('^emotion_', '')))
				if dwID then
					local emo = LIB.GetChatEmotion(dwID)
					if emo then
						edit:InsertObj(emo.szCmd, { type = 'emotion', text = emo.szCmd, id = emo.dwID })
					end
				else
					local szImg, nFrame = p:GetImagePath()
					if szImg == 'ui\\image\\common\\money.uitex' and nFrame == 0 then
						edit:InsertText(_L['Gold'])
					elseif szImg == 'ui\\image\\common\\money.uitex' and nFrame == 2 then
						edit:InsertText(_L['Silver'])
					elseif szImg == 'ui\\image\\common\\money.uitex' and nFrame == 1 then
						edit:InsertText(_L['Copper'])
					elseif szImg == 'ui\\image\\common\\money.uitex' and (nFrame == 31 or nFrame == 32 or nFrame == 33 or nFrame == 34) then
						edit:InsertText(_L['Brics'])
					end
				end
			end
		end
	end
	Station.SetFocusWindow(edit)
end

-- �������Ԫ��ͨ���¼��鿴��ɫװ�����λ
local PEEK_PLAYER = {}
LIB.RegisterEvent('PEEK_OTHER_PLAYER', function()
	if not PEEK_PLAYER[arg1] then
		return
	end
	if arg0 == CONSTANT.PEEK_OTHER_PLAYER_RESPOND.INVALID then
		OutputMessage('MSG_ANNOUNCE_RED', _L['Invalid player ID!'])
	elseif arg0 == CONSTANT.PEEK_OTHER_PLAYER_RESPOND.FAILED then
		OutputMessage('MSG_ANNOUNCE_RED', _L['Peek other player failed!'])
	elseif arg0 == CONSTANT.PEEK_OTHER_PLAYER_RESPOND.CAN_NOT_FIND_PLAYER then
		OutputMessage('MSG_ANNOUNCE_RED', _L['Can not find player to peek!'])
	elseif arg0 == CONSTANT.PEEK_OTHER_PLAYER_RESPOND.TOO_FAR then
		OutputMessage('MSG_ANNOUNCE_RED', _L['Player is too far to peek!'])
	end
	PEEK_PLAYER[arg1] = nil
end)

-- �������Ԫ��ͨ���¼��󶨺���
local ChatLinkEvents = {
	OnNameLClick = function(element, link)
		if not link then
			link = element
		end
		if IsCtrlKeyDown() and IsAltKeyDown() then
			local menu = {}
			InsertInviteTeamMenu(menu, (UI(link):Text():gsub('[%[%]]', '')))
			menu[1].fnAction()
		elseif IsCtrlKeyDown() then
			LIB.CopyChatItem(link)
		elseif IsShiftKeyDown() then
			if not LIB.IsInShieldedMap() or not LIB.IsShieldedVersion('TARGET') then
				LIB.SetTarget(TARGET.PLAYER, UI(link):Text())
			end
		elseif IsAltKeyDown() then
			if _G.MY_Farbnamen and _G.MY_Farbnamen.Get then
				local info = _G.MY_Farbnamen.Get((UI(link):Text():gsub('[%[%]]', '')))
				if info then
					PEEK_PLAYER[info.dwID] = true
					ViewInviteToPlayer(info.dwID)
				end
			end
		else
			LIB.SwitchChatChannel(UI(link):Text())
			local edit = LIB.GetChatInput()
			if edit then
				Station.SetFocusWindow(edit)
			end
		end
	end,
	OnNameRClick = function(element, link)
		if not link then
			link = element
		end
		PopupMenu(LIB.GetTargetContextMenu(TARGET.PLAYER, (UI(link):Text():gsub('[%[%]]', ''))))
	end,
	OnCopyLClick = function(element, link)
		if not link then
			link = element
		end
		LIB.CopyChatLine(link, IsCtrlKeyDown(), IsCtrlKeyDown() and IsShiftKeyDown())
	end,
	OnCopyMClick = function(element, link)
		if not link then
			link = element
		end
		LIB.RemoveChatLine(link)
	end,
	OnCopyRClick = function(element, link)
		if not link then
			link = element
		end
		LIB.RepeatChatLine(link)
	end,
	OnCopyMouseEnter = function(el, link)
		if not link then
			link = el
		end
		local x, y = el:GetAbsPos()
		local w, h = el:GetSize()
		local s = ''
		if el.bLButton then
			s = s .. _L['LClick to copy to editbox.\n']
		end
		if el.bMButton then
			s = s .. _L['MClick to remove this line.\n']
		end
		if el.bRButton then
			s = s .. _L['RClick to repeat this line.\n']
		end
		local szText = GetFormatText(s:sub(1, -2), 136)
		OutputTip(szText, 450, {x, y, w, h}, UI.TIP_POSITION.TOP_BOTTOM)
	end,
	OnCopyMouseLeave = function(element, link)
		if not link then
			link = element
		end
		HideTip()
	end,
	OnItemLClick = function(element, link)
		if not link then
			link = element
		end
		OnItemLinkDown(link)
	end,
	OnItemRClick = function(element, link)
		if not link then
			link = element
		end
		if IsCtrlKeyDown() then
			LIB.CopyChatItem(link)
		end
	end,
}
LIB.ChatLinkEvents = LIB.SetmetaReadonly(ChatLinkEvents)

-- �������Ԫ��ͨ���¼��󶨺�����this��
local ChatLinkEventHandlers = {}
for k, f in pairs(ChatLinkEvents) do
	ChatLinkEventHandlers[k] = function()
		f(this)
	end
end
LIB.ChatLinkEventHandlers = LIB.SetmetaReadonly(ChatLinkEventHandlers)

-- ��link�¼���Ӧ
-- (userdata) LIB.RenderChatLink(userdata link)                   ����link�ĸ����¼��� namelink��һ��������TextԪ��
-- (userdata) LIB.RenderChatLink(userdata element, userdata link) ����element�ĸ����¼��� ����Դ��link
-- (string) LIB.RenderChatLink(string szMsg)                      ��ʽ��szMsg ��������ĳ����� ���ʱ����Ӧ
-- link   : һ��������TextԪ��
-- element: һ�����Թ������Ϣ��Ӧ��UIԪ��
-- szMsg  : ��ʽ����UIXML��Ϣ
function LIB.RenderChatLink(arg1, arg2)
	if IsString(arg1) then -- szMsg
		local szMsg = arg1
		local aXMLNode = LIB.XMLDecode(szMsg)
		if aXMLNode then
			for _, node in ipairs(aXMLNode) do
				if LIB.XMLIsNode(node) and LIB.XMLGetNodeType(node) == 'text' and LIB.XMLGetNodeData(node, 'name') then
					local name, script = LIB.XMLGetNodeData(node, 'name'), LIB.XMLGetNodeData(node, 'script')
					if script then
						script = script .. '\n'
					else
						script = ''
					end

					local handlerEntry = NSFormatString('{$NS}.ChatLinkEventHandlers')
					if name == 'namelink' or name:sub(1, 9) == 'namelink_' then
						script = script .. 'this.' .. RENDERED_FLAG_KEY .. '=true;this.OnItemLButtonDown='
							.. handlerEntry .. '.OnNameLClick;this.OnItemRButtonDown='
							.. handlerEntry .. '.OnNameRClick'
					elseif name == 'copy' or name == 'copylink' or name == 'timelink' then
						script = script .. 'this.' .. RENDERED_FLAG_KEY .. '=true;this.OnItemLButtonDown='
							.. handlerEntry .. '.OnCopyLClick;this.OnItemMButtonDown='
							.. handlerEntry .. '.OnCopyMClick;this.OnItemRButtonDown='
							.. handlerEntry .. '.OnCopyRClick;this.OnItemMouseEnter='
							.. handlerEntry .. '.OnCopyMouseEnter;this.OnItemMouseLeave='
							.. handlerEntry .. '.OnCopyMouseLeave'
					else
						script = script .. 'this.' .. RENDERED_FLAG_KEY .. '=true;this.OnItemLButtonDown='
							.. handlerEntry .. '.OnItemLClick;this.OnItemRButtonDown='
							.. handlerEntry .. '.OnItemRClick'
					end

					if #script > 0 then
						LIB.XMLSetNodeData(node, 'eventid', 82803)
						LIB.XMLSetNodeData(node, 'script', script)
					end
				end
			end
			szMsg = LIB.XMLEncode(aXMLNode)
		end
		return szMsg
	elseif IsElement(arg1) then
		local element = arg1
		local link = arg2 or arg1
		if element[RENDERED_FLAG_KEY] then
			return
		end
		local ui = UI(element)
		local name = ui:Name()
		if name == 'namelink' or name:sub(1, 9) == 'namelink_' then
			ui:LClick(function() ChatLinkEvents.OnNameLClick(element, link) end)
			ui:RClick(function() ChatLinkEvents.OnNameRClick(element, link) end)
		elseif name == 'copy' or name == 'copylink' then
			ui:LClick(function() ChatLinkEvents.OnCopyLClick(element, link) end)
			ui:RClick(function() ChatLinkEvents.OnCopyRClick(element, link) end)
			ui:MClick(function() ChatLinkEvents.OnCopyMClick(element, link) end)
		else
			ui:LClick(function() ChatLinkEvents.OnItemLClick(element, link) end)
			ui:RClick(function() ChatLinkEvents.OnItemRClick(element, link) end)
		end
		element[RENDERED_FLAG_KEY] = true
		return element
	end
end

-- ����Item�������
function LIB.CopyChatItem(p)
	local edit = LIB.GetChatInput()
	if not edit then
		return
	end
	if p:GetType() == 'Text' then
		local szText, szName = p:GetText(), p:GetName()
		if szName == 'itemlink' then
			edit:InsertObj(szText, { type = 'item', text = szText, item = p:GetUserData() })
		elseif szName == 'iteminfolink' then
			edit:InsertObj(szText, { type = 'iteminfo', text = szText, version = p.nVersion, tabtype = p.dwTabType, index = p.dwIndex })
		elseif szName == 'namelink' or sub(szName, 1, 9) == 'namelink_' then
			edit:InsertObj(szText, { type = 'name', text = szText, name = match(szText, '%[(.*)%]') })
		elseif szName == 'questlink' then
			edit:InsertObj(szText, { type = 'quest', text = szText, questid = p:GetUserData() })
		elseif szName == 'recipelink' then
			edit:InsertObj(szText, { type = 'recipe', text = szText, craftid = p.dwCraftID, recipeid = p.dwRecipeID })
		elseif szName == 'enchantlink' then
			edit:InsertObj(szText, { type = 'enchant', text = szText, proid = p.dwProID, craftid = p.dwCraftID, recipeid = p.dwRecipeID })
		elseif szName == 'skilllink' then
			local o = Clone(p.skillKey)
			o.type, o.text = 'skill', szText
			edit:InsertObj(szText, o)
		elseif szName =='skillrecipelink' then
			edit:InsertObj(szText, { type = 'skillrecipe', text = szText, id = p.dwID, level = p.dwLevelD })
		elseif szName =='booklink' then
			edit:InsertObj(szText, { type = 'book', text = szText, tabtype = p.dwTabType, index = p.dwIndex, bookinfo = p.nBookRecipeID, version = p.nVersion })
		elseif szName =='achievementlink' then
			edit:InsertObj(szText, { type = 'achievement', text = szText, id = p.dwID })
		elseif szName =='designationlink' then
			edit:InsertObj(szText, { type = 'designation', text = szText, id = p.dwID, prefix = p.bPrefix })
		elseif szName =='eventlink' then
			edit:InsertObj(szText, { type = 'eventlink', text = szText, name = p.szName, linkinfo = p.szLinkInfo })
		end
		Station.SetFocusWindow(edit)
	end
end

-- �ӽ�������Ԫ�ؽ���ԭʼ������Ϣ����
-- (aSay: table) LIB.ParseChatData(oData: Element, tOption: table)
-- (aSay: table) LIB.ParseChatData(oData: XMLString, tOption: table)
-- (aSay: table) LIB.ParseChatData(oData: XMLNode, tOption: table)
do
local function ParseChatData(oData, tOption, aContent, bIgnoreRange)
	if IsString(oData) then
		local aXMLNode = LIB.XMLDecode(oData)
		if aXMLNode then
			for _, node in ipairs(aXMLNode) do
				ParseChatData(node, tOption, aContent, true)
			end
		end
	elseif LIB.XMLIsNode(oData) then
		local node = oData
		local nodeType = LIB.XMLGetNodeType(node)
		local nodeName = LIB.XMLGetNodeData(node, 'name') or ''
		local nodeText = LIB.XMLGetNodeData(node, 'text')
		local nodeScript = LIB.XMLGetNodeData(node, 'script')
		local nodeUserdata = LIB.XMLGetNodeData(node, 'userdata')
		if nodeType == 'handle' then -- ��Ԫ�صݹ�
			local children = LIB.XMLGetNodeChildren(node)
			local nStartIndex = not bIgnoreRange and tOption.nStartIndex or 0
			local nEndIndex = not bIgnoreRange and tOption.nEndIndex or (#children - 1)
			for nIndex = nStartIndex, nEndIndex do
				ParseChatData(children[nIndex + 1], tOption, aContent, true)
			end
		elseif nodeType == 'text' then -- ��������
			if nodeName == 'itemlink' then -- ��Ʒ����
				insert(aContent, {
					type = 'item',
					text = nodeText, innerText = nodeText:sub(2, -2), item = nodeUserdata,
				})
			elseif nodeName == 'iteminfolink' then -- ��Ʒ��Ϣ
				local version, tab, index = match(nodeScript, 'this.nVersion=(%d+)%s*this.dwTabType=(%d+)%s*this.dwIndex=(%d+)')
				insert(aContent, {
					type = 'iteminfo',
					text = nodeText, innerText = nodeText:sub(2, -2),
					version = version, tabtype = tab, index = index,
				})
			elseif nodeName:sub(1, 9) == 'namelink_' then -- ����
				insert(aContent, {
					type = 'name',
					text = nodeText, innerText = nodeText,
					name = nodeText:sub(2, -2), id = nodeName:sub(10),
				})
			elseif nodeName == 'questlink' then -- ����
				insert(aContent, {
					type = 'quest',
					text = nodeText, innerText = nodeText:sub(2, -2), questid = nodeUserdata,
				})
			elseif nodeName == 'recipelink' then -- �����
				local craft, recipe = match(nodeScript, 'this.dwCraftID=(%d+)%s*this.dwRecipeID=(%d+)')
				insert(aContent, {
					type = 'recipe',
					text = nodeText, innerText = nodeText:sub(2, -2),
					craftid = craft, recipeid = recipe,
				})
			elseif nodeName == 'skilllink' then -- ����
				local skillinfo = match(nodeScript, 'this.skillKey=%{(.-)%}')
				local skillKey = {}
				for w in gmatch(skillinfo, '(.-)%,') do
					local k, v  = match(w, '(.-)=(%w+)')
					skillKey[k] = v
				end
				skillKey.type = 'skill'
				skillKey.text = nodeText
				skillKey.innerText = nodeText:sub(2, -2)
				insert(aContent, skillKey)
			elseif nodeName == 'designationlink' then -- �ƺ�
				local id, fix = match(nodeScript, 'this.dwID=(%d+)%s*this.bPrefix=(.-)')
				insert(aContent, {
					type = 'designation',
					text = nodeText, innerText = nodeText:sub(2, -2), id = id, prefix = fix,
				})
			elseif nodeName == 'skillrecipelink' then -- �����ؼ�
				local id, level = match(nodeScript, 'this.dwID=(%d+)%s*this.dwLevel=(%d+)')
				insert(aContent, {
					type = 'skillrecipe',
					text = nodeText, innerText = nodeText:sub(2, -2), id = id, level = level,
				})
			elseif nodeName == 'booklink' then -- �鼮
				local version, tab, index, id = match(nodeScript, 'this.nVersion=(%d+)%s*this.dwTabType=(%d+)%s*this.dwIndex=(%d+)%s*this.nBookRecipeID=(%d+)')
				insert(aContent, {
					type = 'book',
					text = nodeText, innerText = nodeText:sub(2, -2),
					version = version, tabtype = tab, index = index, bookinfo = id,
				})
			elseif nodeName == 'achievementlink' then -- �ɾ�
				local id = match(nodeScript, 'this.dwID=(%d+)')
				insert(aContent, {
					type = 'achievement',
					text = nodeText, innerText = nodeText:sub(2, -2), id = id,
				})
			elseif nodeName == 'enchantlink' then -- ǿ��
				local pro, craft, recipe = match(nodeScript, 'this.dwProID=(%d+)%s*this.dwCraftID=(%d+)%s*this.dwRecipeID=(%d+)')
				insert(aContent, {
					type = 'enchant',
					text = nodeText, innerText = nodeText:sub(2, -2),
					proid = pro, craftid = craft, recipeid = recipe,
				})
			elseif nodeName == 'eventlink' then -- �¼�
				local eventname, linkinfo = match(nodeScript, 'this.szName="(.-)"%s*this.szLinkInfo="(.-)"$')
				if not eventname then
					eventname, linkinfo = match(nodeScript, 'this.szName="(.-)"%s*this.szLinkInfo="(.-)"')
				end
				insert(aContent, {
					type = 'eventlink',
					text = nodeText, innerText = nodeText:sub(2, -2),
					name = eventname, linkinfo = linkinfo:gsub('\\(.)', '%1'),
				})
			elseif not IsEmpty(nodeText) then -- δ֪���͵��ַ�������ͨ�ı�
				insert(aContent, {
					type = 'text',
					text = nodeText, innerText = nodeText,
				})
			end
		elseif nodeType == 'image' or nodeType == 'animate' then -- ����
			if sub(nodeName, 1, 8) == 'emotion_' then -- ����
				local dwID = tonumber((nodeName:sub(9)))
				if dwID then
					local emo = LIB.GetChatEmotion(dwID)
					if emo then
						insert(aContent, {
							type = 'emotion',
							text = emo.szCmd, innerText = emo.szCmd, id = emo.dwID,
						})
					end
				end
			else -- ���ҵ�λ
				local path = LIB.XMLGetNodeData(node, 'path')
				local frame = LIB.XMLGetNodeData(node, 'frame')
				if path == 'ui\\image\\common\\money.uitex' and frame == 0 then
					insert(aContent, {
						type = 'text',
						text = _L['Gold'], innerText = _L['Gold'],
					})
				elseif path == 'ui\\image\\common\\money.uitex' and frame == 2 then
					insert(aContent, {
						type = 'text',
						text = _L['Silver'], innerText = _L['Silver'],
					})
				elseif path == 'ui\\image\\common\\money.uitex' and frame == 1 then
					insert(aContent, {
						type = 'text',
						text = _L['Copper'], innerText = _L['Copper'],
					})
				elseif path == 'ui\\image\\common\\money.uitex' and (frame == 31 or frame == 32 or frame == 33 or frame == 34) then
					insert(aContent, {
						type = 'text',
						text = _L['Brics'], innerText = _L['Brics'],
					})
				end
			end
		end
	elseif IsElement(oData) then
		local elem = oData
		local elemType = elem:GetType()
		local elemName = elem:GetName()
		if elemType == 'Handle' then -- ��Ԫ�صݹ�
			local nStartIndex = not bIgnoreRange and tOption.nStartIndex or 0
			local nEndIndex = not bIgnoreRange and tOption.nEndIndex or (elem:GetItemCount() - 1)
			for nIndex = nStartIndex, nEndIndex do
				ParseChatData(elem:Lookup(nIndex), tOption, aContent, true)
			end
		elseif elemType == 'Text' then -- ��������
			local elemText = elem:GetText()
			local elemUserdata = elem:GetUserData()
			if elemName == 'itemlink' then -- ��Ʒ����
				insert(aContent, {
					type = 'item',
					text = elemText, innerText = elemText:sub(2, -2), item = elemUserdata,
				})
			elseif elemName == 'iteminfolink' then -- ��Ʒ��Ϣ
				insert(aContent, {
					type = 'iteminfo',
					text = elemText, innerText = elemText:sub(2, -2),
					version = elem.nVersion, tabtype = elem.dwTabType, index = elem.dwIndex,
				})
			elseif sub(elemName, 1, 9) == 'namelink_' then -- ����
				insert(aContent, {
					type = 'name',
					text = elemText, innerText = elemText,
					name = match(elemText, '%[(.*)%]'), id = elemName:sub(10),
				})
			elseif elemName == 'questlink' then -- ����
				insert(aContent, {
					type = 'quest',
					text = elemText, innerText = elemText:sub(2, -2), questid = elemUserdata,
				})
			elseif elemName == 'recipelink' then -- �����
				insert(aContent, {
					type = 'recipe',
					text = elemText, innerText = elemText:sub(2, -2),
					craftid = elem.dwCraftID, recipeid = elem.dwRecipeID,
				})
			elseif elemName == 'skilllink' then -- ����
				local skillKey = Clone(elem.skillKey)
				skillKey.type = 'skill'
				skillKey.text = elemText
				skillKey.innerText = elemText:sub(2, -2)
				insert(aContent, skillKey)
			elseif elemName =='designationlink' then -- �ƺ�
				insert(aContent, {
					type = 'designation',
					text = elemText, innerText = elemText:sub(2, -2), id = elem.dwID, prefix = elem.bPrefix,
				})
			elseif elemName =='skillrecipelink' then -- �����ؼ�
				insert(aContent, {
					type = 'skillrecipe',
					text = elemText, innerText = elemText:sub(2, -2), id = elem.dwID, level = elem.dwLevelD,
				})
			elseif elemName =='booklink' then -- �鼮
				insert(aContent, {
					type = 'book',
					text = elemText, innerText = elemText:sub(2, -2),
					version = elem.nVersion, tabtype = elem.dwTabType, index = elem.dwIndex, bookinfo = elem.nBookRecipeID,
				})
			elseif elemName =='achievementlink' then -- �ɾ�
				insert(aContent, {
					type = 'achievement',
					text = elemText, innerText = elemText:sub(2, -2), id = elem.dwID,
				})
			elseif elemName == 'enchantlink' then -- ǿ��
				insert(aContent, {
					type = 'enchant',
					text = elemText, innerText = elemText:sub(2, -2),
					proid = elem.dwProID, craftid = elem.dwCraftID, recipeid = elem.dwRecipeID,
				})
			elseif elemName =='eventlink' then -- �¼�
				insert(aContent, {
					type = 'eventlink',
					text = elemText, innerText = elemText:sub(2, -2),
					name = elem.szName, linkinfo = elem.szLinkInfo,
				})
			elseif not IsEmpty(elemText) then -- δ֪���͵��ַ�������ͨ�ı�
				insert(aContent, {
					type = 'text',
					text = elemText, innerText = elemText,
				})
			end
		elseif elemType == 'Image' or elemType == 'Animate' then
			if sub(elemName, 1, 8) == 'emotion_' then -- ����
				local dwID = tonumber((elemName:sub(9)))
				if dwID then
					local emo = LIB.GetChatEmotion(dwID)
					if emo then
						insert(aContent, {
							type = 'emotion',
							text = emo.szCmd, innerText = emo.szCmd, id = emo.dwID,
						})
					end
				end
			else -- ���ҵ�λ
				local path, frame = elem:GetImagePath()
				if path == 'ui\\image\\common\\money.uitex' and frame == 0 then
					insert(aContent, {
						type = 'text',
						text = _L['Gold'], innerText = _L['Gold'],
					})
				elseif path == 'ui\\image\\common\\money.uitex' and frame == 2 then
					insert(aContent, {
						type = 'text',
						text = _L['Silver'], innerText = _L['Silver'],
					})
				elseif path == 'ui\\image\\common\\money.uitex' and frame == 1 then
					insert(aContent, {
						type = 'text',
						text = _L['Copper'], innerText = _L['Copper'],
					})
				elseif path == 'ui\\image\\common\\money.uitex' and (frame == 31 or frame == 32 or frame == 33 or frame == 34) then
					insert(aContent, {
						type = 'text',
						text = _L['Brics'], innerText = _L['Brics'],
					})
				end
			end
		end
	elseif IsArray(oData) then
		for _, node in ipairs(oData) do
			ParseChatData(node, tOption, aContent, true)
		end
	end
	return aContent
end
function LIB.ParseChatData(oData, tOption)
	return ParseChatData(oData, tOption, {}, false)
end
end

-- ��ԭʼ������Ϣ���ݹ�������Ԫ�ظ��ı��ַ���
-- (aSay: table) LIB.XmlifyChatData(aSay: table, r?: number, g?: number, b?: number, font?: number)
function LIB.XmlifyChatData(t, r, g, b, f)
	local aXML = {}
	for _, v in ipairs(t) do
		if v.type == 'text' then
			insert(aXML, GetFormatText(v.text, f, r, g, b))
		elseif v.type == 'name' then
			insert(aXML, GetFormatText(v.text, f, r, g, b, 515, nil, 'namelink_' .. (v.id or 0)))
		end
	end
	return concat(aXML)
end

-- ��ԭʼ������Ϣ���ݹ������Ķ��ַ���
-- (string) LIB.StringifyChatText(aSay: table)
function LIB.StringifyChatText(t)
	local aText = {}
	for _, v in ipairs(t) do
		if v.text then -- v.type == 'text' or v.type == 'name'
			insert(aText, v.text)
		elseif v.type == 'emotion' then
			local emo = LIB.GetChatEmotion(v.id)
			if emo then
				insert(aText, emo.szCmd)
			end
		end
	end
	return concat(aText)
end

-- �ж�ĳ��Ƶ���ܷ���
-- (bool) LIB.CanUseChatChannel(number nChannel)
function LIB.CanUseChatChannel(nChannel)
	for _, v in ipairs({'WHISPER', 'TEAM', 'RAID', 'BATTLE_FIELD', 'NEARBY', 'TONG', 'TONG_ALLIANCE'}) do
		if nChannel == PLAYER_TALK_CHANNEL[v] then
			return true
		end
	end
	return false
end

-- �л�����Ƶ��
-- (void) LIB.SwitchChatChannel(number nChannel)
-- (void) LIB.SwitchChatChannel(string szHeader)
-- (void) LIB.SwitchChatChannel(string szName)
do
local TALK_CHANNEL_HEADER = {
	[PLAYER_TALK_CHANNEL.NEARBY] = '/s ',
	[PLAYER_TALK_CHANNEL.FRIENDS] = '/o ',
	[PLAYER_TALK_CHANNEL.TONG_ALLIANCE] = '/a ',
	[PLAYER_TALK_CHANNEL.TEAM] = '/p ',
	[PLAYER_TALK_CHANNEL.RAID] = '/t ',
	[PLAYER_TALK_CHANNEL.BATTLE_FIELD] = '/b ',
	[PLAYER_TALK_CHANNEL.TONG] = '/g ',
	[PLAYER_TALK_CHANNEL.SENCE] = '/y ',
	[PLAYER_TALK_CHANNEL.FORCE] = '/f ',
	[PLAYER_TALK_CHANNEL.CAMP] = '/c ',
	[PLAYER_TALK_CHANNEL.WORLD] = '/h ',
}
function LIB.SwitchChatChannel(nChannel)
	local szHeader = TALK_CHANNEL_HEADER[nChannel]
	if szHeader then
		SwitchChatChannel(szHeader)
	elseif nChannel == PLAYER_TALK_CHANNEL.WHISPER then
		local edit = LIB.GetChatInput()
		if edit then
			edit:GetRoot():Show()
			edit:SetText('/w ')
			Station.SetFocusWindow(edit)
		end
	elseif type(nChannel) == 'string' then
		if sub(nChannel, 1, 1) == '/' then
			if nChannel == '/cafk' or nChannel == '/catr' then
				local edit = LIB.GetChatInput()
				if edit then
					edit:ClearText()
					for _, v in ipairs({{ type = 'text', text = nChannel }}) do
						edit:InsertObj(v.text, v)
					end
				end
			else
				SwitchChatChannel(nChannel..' ')
			end
		else
			SwitchChatChannel('/w ' .. gsub(nChannel,'[%[%]]','') .. ' ')
		end
	end
end
end

do
-- ��������ʼ��
local MAX_EMOTION_LEN, EMOTION_CACHE = 0, nil
local function InitEmotion()
	if not EMOTION_CACHE then
		local t = {}
		for i = 1, g_tTable.FaceIcon:GetRowCount() do
			local tLine = g_tTable.FaceIcon:GetRow(i)
			local t1 = {
				nFrame = tLine.nFrame,
				dwID   = tLine.dwID or (10000 + i),
				szCmd  = tLine.szCommand,
				szType = tLine.szType,
				szImageFile = tLine.szImageFile or 'ui/Image/UICommon/Talk_face.UITex'
			}
			t[t1.dwID] = t1
			t[t1.szCmd] = t1
			t[t1.szImageFile..','..t1.nFrame..','..t1.szType] = t1
			MAX_EMOTION_LEN = max(MAX_EMOTION_LEN, wlen(t1.szCmd))
		end
		EMOTION_CACHE = t
	end
end
-- ��ȡ��������б�
-- typedef emo table
-- (emo[]) LIB.GetChatEmotion()                             -- �������б����б�
-- (emo)   LIB.GetChatEmotion(szCommand)                    -- ����ָ��Cmd�ı���
-- (emo)   LIB.GetChatEmotion(szImageFile, nFrame, szType)  -- ����ָ��ͼ��ı���
function LIB.GetChatEmotion(arg0, arg1, arg2)
	InitEmotion()
	local t
	if not arg0 then
		t = EMOTION_CACHE
	elseif not arg1 then
		t = EMOTION_CACHE[arg0]
	elseif arg2 then
		arg0 = gsub(arg0, '\\\\', '\\')
		t = EMOTION_CACHE[arg0..','..arg1..','..arg2]
	end
	return Clone(t)
end
-- parse faceicon in talking message
local function ParseFaceIcon(t)
	InitEmotion()
	local t2 = {}
	for _, v in ipairs(t) do
		if v.type ~= 'text' then
			-- if v.type == 'emotion' then
			-- 	v.type = 'text'
			-- end
			insert(t2, v)
		else
			local szText = v.text
			local szLeft = ''
			while szText and #szText > 0 do
				local szFace, dwFaceID = nil, nil
				local nPos = StringFindW(szText, '#')
				if not nPos then
					szLeft = szLeft .. szText
					szText = ''
				else
					szLeft = szLeft .. sub(szText, 1, nPos - 1)
					szText = sub(szText, nPos)
					for i = min(MAX_EMOTION_LEN, wlen(szText)), 2, -1 do
						local szTest = wsub(szText, 1, i)
						local emo = LIB.GetChatEmotion(szTest)
						if emo then
							szFace, dwFaceID = szTest, emo.dwID
							szText = szText:sub(szFace:len() + 1)
							break
						end
					end
					if szFace then -- emotion cmd matched
						if #szLeft > 0 then
							insert(t2, { type = 'text', text = szLeft })
							szLeft = ''
						end
						insert(t2, { type = 'emotion', text = szFace, id = dwFaceID })
					elseif nPos then -- find '#' but not match emotion
						szLeft = szLeft .. szText:sub(1, 1)
						szText = szText:sub(2)
					end
				end
			end
			if #szLeft > 0 then
				insert(t2, { type = 'text', text = szLeft })
				szLeft = ''
			end
		end
	end
	return t2
end
-- parse name in talking message
local function ParseName(t)
	local me = GetClientPlayer()
	local tar = LIB.GetObject(me.GetTarget())
	for i, v in ipairs(t) do
		if v.type == 'text' then
			v.text = gsub(v.text, '%$zj', '[' .. me.szName .. ']')
			if tar then
				v.text = gsub(v.text, '%$mb', '[' .. tar.szName .. ']')
			end
		end
	end
	local t2 = {}
	for _, v in ipairs(t) do
		if v.type ~= 'text' then
			-- if v.type == 'name' then
			-- 	v = { type = 'text', text = '['..v.name..']' }
			-- end
			insert(t2, v)
		else
			local nOff, nLen = 1, len(v.text)
			while nOff <= nLen do
				local szName = nil
				local nPos1, nPos2 = find(v.text, '%[[^%[%]]+%]', nOff)
				if not nPos1 then
					nPos1 = nLen
				else
					szName = sub(v.text, nPos1 + 1, nPos2 - 1)
					nPos1 = nPos1 - 1
				end
				if nPos1 >= nOff then
					insert(t2, { type = 'text', text = sub(v.text, nOff, nPos1) })
					nOff = nPos1 + 1
				end
				if szName then
					insert(t2, { type = 'name', text = '[' .. szName .. ']', name = szName })
					nOff = nPos2 + 1
				end
			end
		end
	end
	return t2
end
local SENSITIVE_WORD = {
	'   ',
	'  ' .. g_tStrings.STR_ONE_CHINESE_SPACE,
	' '  .. g_tStrings.STR_ONE_CHINESE_SPACE:rep(2),
	g_tStrings.STR_ONE_CHINESE_SPACE:rep(3),
	g_tStrings.STR_ONE_CHINESE_SPACE:rep(2) .. ' ',
	g_tStrings.STR_ONE_CHINESE_SPACE .. '  ',
	' ' .. g_tStrings.STR_ONE_CHINESE_SPACE .. ' ',
	g_tStrings.STR_ONE_CHINESE_SPACE .. ' ' .. g_tStrings.STR_ONE_CHINESE_SPACE,
}
-- anti sensitive word shielding in talking message
local function ParseAntiSWS(t)
	local t2 = {}
	for _, v in ipairs(t) do
		if v.type == 'text' then
			local szText = v.text
			while szText and #szText > 0 do
				local nSensitiveWordEndLen = 1 -- ���һ���ַ���Ҫ�ü������ַ�����С
				local nSensitiveWordEndPos = #szText + 1
				for _, szSensitiveWord in ipairs(SENSITIVE_WORD) do
					local _, nEndPos = wfind(szText, szSensitiveWord)
					if nEndPos and nEndPos < nSensitiveWordEndPos then
						local nSensitiveWordLenW = wlen(szSensitiveWord)
						nSensitiveWordEndLen = len(wsub(szSensitiveWord, nSensitiveWordLenW, nSensitiveWordLenW))
						nSensitiveWordEndPos = nEndPos
					end
				end

				insert(t2, {
					type = 'text',
					text = sub(szText, 1, nSensitiveWordEndPos - nSensitiveWordEndLen)
				})
				szText = sub(szText, nSensitiveWordEndPos + 1 - nSensitiveWordEndLen)
			end
		else
			insert(t2, v)
		end
	end
	return t2
end

-- parserOptions �����������Ͷ���
-- parserOptions         (object|boolean) ���������� true ��ʾȫ�������� false ��ʾȫ������
-- parserOptions.name    (boolean)        �������������е����֣�Ĭ�Ͻ���
-- parserOptions.emotion (boolean)        �������������еı���ͼƬ�����֣�Ĭ�Ͻ���
-- parserOptions.sws     (boolean)        ��ȫ�Թؼ���У�飬Ĭ�ϲ�У��
-- parserOptions.len     (boolean)        ������󳤶�����У�飬Ĭ�ϲ�У��
local StandardizeParserOptions
do
local DEFAULT_PARSER_OPTIONS = LIB.SetmetaReadonly({
	name = true,
	emotion = true,
	sws = false,
	len = true,
})
local FULL_PARSER_OPTIONS = LIB.SetmetaReadonly({
	name = true,
	emotion = true,
	sws = true,
	len = true,
})
local NULL_PARSER_OPTIONS = LIB.SetmetaReadonly({
	name = false,
	emotion = false,
	sws = false,
	len = false,
})
function StandardizeParserOptions(parsers)
	if parsers == true then
		parsers = FULL_PARSER_OPTIONS
	elseif parsers == false then
		parsers = NULL_PARSER_OPTIONS
	elseif not IsTable(parsers) then
		parsers = DEFAULT_PARSER_OPTIONS
	end
	local mt = {
		__index = function(_, k)
			local v = parsers[k]
			if IsNil(v) then
				v = DEFAULT_PARSER_OPTIONS[k]
			end
			return v
		end,
	}
	return setmetatable({}, mt)
end
end

-- ��ʽ����������
-- szText        -- �������ݣ������Ϊ���� KPlayer.Talk �� table��
-- parserOptions -- �������򣬲μ� @parserOptions ����
local function StandardizeChatData(szText, parserOptions)
	-- �������ݸ�ʽ��׼��
	local aSay = nil
	if IsTable(szText) then
		aSay = Clone(szText)
	else
		aSay = {{ type = 'text', text = szText }}
	end
	-- ���˻��з�
	if LIB.IsShieldedVersion('TALK', 2) then
		for _, v in ipairs(aSay) do
			if v.text then
				v.text = wgsub(v.text, '\n', ' ')
			end
			if v.name then
				v.name = wgsub(v.name, '\n', ' ')
			end
		end
	end
	-- ����ת��
	if parserOptions.emotion then
		aSay = ParseFaceIcon(aSay)
	end
	-- ����ת��
	if parserOptions.name then
		aSay = ParseName(aSay)
	end
	-- ��ȫ�Ժͳ���У��
	if parserOptions.sws then
		aSay = ParseAntiSWS(aSay)
	end
	if parserOptions.len and LIB.IsShieldedVersion('TALK') then
		local nLen = 0
		for i, v in ipairs(aSay) do
			if nLen <= 64 then
				nLen = nLen + wlen(v.text or v.name or '')
				if nLen > 64 then
					if v.text then
						v.text = wsub(v.text, 1, 64 - nLen)
					end
					if v.name then
						v.name = wsub(v.name, 1, 64 - nLen)
					end
					for j = #aSay, i + 1, -1 do
						remove(aSay, j)
					end
				end
			end
		end
	end
	return aSay
end

-- ��������ǩ��
-- aSay        -- ��׼����������
-- uuid        -- ��ϢΨһ��ʶ��
-- me          -- ��������ɫ����
local function SignChatData(aSay, uuid, me)
	if not aSay[1] or aSay[1].name ~= '' or aSay[1].type ~= 'eventlink' then
		insert(aSay, 1, { type = 'eventlink', name = '', text = '' })
	end
	local dwTime = GetCurrentTime()
	local szLinkInfo = LIB.JsonEncode({
		_ = dwTime,
		c = LIB.IsDebugClient(true)
			and GetStringCRC(me.szName .. dwTime .. '8545ada2-f687-4c95-8558-27cbf823745a')
			or nil,
		via = PACKET_INFO.NAME_SPACE,
		uuid = uuid and tostring(uuid),
	})
	aSay[1].linkinfo = szLinkInfo
	return aSay
end

-- ������������
-- (void) LIB.SetChatInput(string szText[, table parsers, [string uuid]])
-- szText    -- �������ݣ������Ϊ���� KPlayer.Talk �� table��
-- parsers   -- *��ѡ* �������������μ� LIB.SendChat: tOptions.parsers
-- uuid      -- *��ѡ* ��ϢΨһ��ʶ�����μ� LIB.SendChat: tOptions.uuid
function LIB.SetChatInput(szText, parsers, uuid)
	local me = GetClientPlayer()
	local edit = LIB.GetChatInput()
	if me and edit then
		local parserOptions = StandardizeParserOptions(parsers)
		local aSay = StandardizeChatData(szText, parserOptions)
		local aSignSay = SignChatData(aSay, uuid, me)
		edit:ClearText()
		for _, v in ipairs(aSignSay) do
			edit:InsertObj(v.text, v)
		end
	end
end

-- ������������
-- (void) LIB.SendChat(mixed uTarget, string szText[, boolean bNoEscape, [boolean bSaveDeny] ])
-- uTarget   -- ����Ŀ�꣺
--              1��(number) PLAYER_TALK_CHANNLE.* ս��/�Ŷ�����Ƶ���������л�
--              2��(string) ���ĵ�Ŀ���ɫ��
-- szText    -- �������ݣ������Ϊ���� KPlayer.Talk �� table��
-- tOptions  -- �߼�����
--              tOptions.uuid            (string)         ��ϢΨһ��ʶ��������ˢ������
--              tOptions.parsers         (object|boolean) ���������� true ��ʾȫ�������� false ��ʾȫ������
--              tOptions.parsers.name    (boolean)        �������������е����֣�Ĭ�Ͻ���
--              tOptions.parsers.emotion (boolean)        �������������еı���ͼƬ�����֣�Ĭ�Ͻ���
--              tOptions.save            (boolean)        �������������������ɷ��Ե�Ƶ�����ݣ�Ĭ��Ϊ false
function LIB.SendChat(nChannel, szText, tOptions)
	if not tOptions then
		tOptions = {}
	end
	-- ����Ƿ�ת�����������
	if tOptions.save and not LIB.CanUseChatChannel(nChannel) then
		LIB.SetChatInput(szText, tOptions.parsers)
		LIB.SwitchChatChannel(nChannel)
		LIB.FocusChatInput()
		return
	end
	-- ��ʼ������
	local szTarget, me = '', GetClientPlayer()
	if IsString(nChannel) then
		szTarget = nChannel
		nChannel = PLAYER_TALK_CHANNEL.WHISPER
	elseif nChannel == PLAYER_TALK_CHANNEL.RAID and me.GetScene().nType == MAP_TYPE.BATTLE_FIELD then
		nChannel = PLAYER_TALK_CHANNEL.BATTLE_FIELD
	end
	-- ��ʽ�����ж��Ƿ���ϵͳ���
	local bSystem = nChannel == PLAYER_TALK_CHANNEL.LOCAL_SYS
	local parserOptions = StandardizeParserOptions(tOptions.parsers)
	if bSystem then
		parserOptions.sws = false
		parserOptions.len = false
	end
	local aSay = StandardizeChatData(szText, parserOptions)
	if bSystem then
		local szXml = LIB.XmlifyChatData(aSay, GetMsgFontColor('MSG_SYS'))
		return LIB.Sysmsg({ szXml, rich = true })
	end
	-- ǩ��������
	local aSignSay = SignChatData(aSay, tOptions.uuid, me)
	me.Talk(nChannel, szTarget, aSay)
end
end

do
local SPACE = ' '
local W_SPACE = g_tStrings.STR_ONE_CHINESE_SPACE
local metaAlignment = { __index = function() return 'L' end }
local function MergeHW(s)
	return s:gsub(W_SPACE, 'W'):gsub(' (W*) ', W_SPACE .. '%1'):gsub('W', W_SPACE)
end
function LIB.SendTabChat(nChannel, aTable, aAlignment)
	local aLenHW, aMaxLenHW = {}, {}
	for i, aText in ipairs(aTable) do
		aLenHW[i] = {}
		for j, szText in ipairs(aText) do
			aLenHW[i][j] = #szText
			aMaxLenHW[j] = max(aLenHW[i][j], aMaxLenHW[j] or 0)
		end
	end
	local aAlignment = setmetatable(aAlignment or {}, metaAlignment)
	for i, aText in ipairs(aTable) do
		local aSay, szFixL, szFixR = {}, nil, nil
		local nFixLenFW, nFixLenHW
		for j, szText in ipairs(aText) do
			nFixLenFW = floor(max(0, aMaxLenHW[j] - aLenHW[i][j]) / 2)
			if nFixLenFW % 2 == 1 then
				nFixLenFW = nFixLenFW - 1
			end
			nFixLenHW = aMaxLenHW[j] - (aLenHW[i][j] + nFixLenFW * 2)
			szFixL = W_SPACE:rep(ceil(nFixLenFW / 2)) .. SPACE:rep(ceil(nFixLenHW / 2))
			szFixR = W_SPACE:rep(floor(nFixLenFW / 2)) .. SPACE:rep(floor(nFixLenHW / 2))
			if aAlignment[j] == 'M' then
				aSay[j] = szFixL .. szText .. szFixR
			elseif aAlignment[j] == 'R' then
				aSay[j] = MergeHW(szFixL .. szFixR) .. szText
			else
				aSay[j] = szText .. MergeHW(szFixL .. szFixR)
			end
		end
		-- LIB.Sysmsg(concat(aSay, '|'))
		LIB.SendChat(nChannel, (concat(aSay, ' ')))
	end
end
end

do
local m_LevelUpData
local function GetRegisterChannelLimitTable()
	if not m_LevelUpData then
		local me = GetClientPlayer()
		if not me then
			return false
		end
		local path = ('settings\\LevelUpData\\%s.tab'):format(({
			[ROLE_TYPE.STANDARD_MALE  ] = 'StandardMale'  ,
			[ROLE_TYPE.STANDARD_FEMALE] = 'StandardFemale',
			[ROLE_TYPE.STRONG_MALE    ] = 'StrongMale'    ,
			[ROLE_TYPE.SEXY_FEMALE    ] = 'SexyFemale'    ,
			[ROLE_TYPE.LITTLE_BOY     ] = 'LittleBoy'     ,
			[ROLE_TYPE.LITTLE_GIRL    ] = 'LittleGirl'    ,
		})[me.nRoleType])
		local tTitle = {
			{f = 'i', t = 'Level'},
			{f = 'i', t = 'Experience'},
			{f = 'i', t = 'Strength'},
			{f = 'i', t = 'Agility'},
			{f = 'i', t = 'Vigor'},
			{f = 'i', t = 'Spirit'},
			{f = 'i', t = 'Spunk'},
			{f = 'i', t = 'MaxLife'},
			{f = 'i', t = 'MaxMana'},
			{f = 'i', t = 'MaxStamina'},
			{f = 'i', t = 'MaxThew'},
			{f = 'i', t = 'MaxAssistExp'},
			{f = 'i', t = 'MaxAssistTimes'},
			{f = 'i', t = 'RunSpeed'},
			{f = 'i', t = 'JumpSpeed'},
			{f = 'i', t = 'Height'},
			{f = 'i', t = 'LifeReplenish'},
			{f = 'i', t = 'LifeReplenishPercent'},
			{f = 'i', t = 'LifeReplenishExt'},
			{f = 'i', t = 'ManaReplenish'},
			{f = 'i', t = 'ManaReplenishPercent'},
			{f = 'i', t = 'ManaReplenishExt'},
			{f = 'i', t = 'HitBase'},
			{f = 'i', t = 'ParryBaseRate'},
			{f = 'i', t = 'PhysicsCriticalStrike'},
			{f = 'i', t = 'SolarCriticalStrike'},
			{f = 'i', t = 'NeutralCriticalStrike'},
			{f = 'i', t = 'LunarCriticalStrike'},
			{f = 'i', t = 'PoisonCriticalStrike'},
			{f = 'i', t = 'NoneWeaponAttackSpeedBase'},
			{f = 'i', t = 'MaxPhysicsDefence'},
			{f = 'i', t = 'WorldChannelDailyLimit'},
			{f = 'i', t = 'ForceChannelDailyLimit'},
			{f = 'i', t = 'CampChannelDailyLimit'},
			{f = 'i', t = 'MaxContribution'},
			{f = 'i', t = 'WhisperDailyLimit'},
			{f = 'i', t = 'IdentityChannelDailyLimit'},
			{f = 'i', t = 'SprintPowerMax'},
			{f = 'i', t = 'SprintPowerCost'},
			{f = 'i', t = 'SprintPowerRevive'},
			{f = 'i', t = 'SprintPowerCostOnWall'},
			{f = 'i', t = 'SprintPowerCostStandOnWall'},
			{f = 'i', t = 'SprintPowerCostRunOnWallExtra'},
			{f = 'i', t = 'HorseSprintPowerMax'},
			{f = 'i', t = 'HorseSprintPowerCost'},
			{f = 'i', t = 'HorseSprintPowerRevive'},
			{f = 'i', t = 'SceneChannelDailyLimit'},
			{f = 'i', t = 'NearbyChannelDailyLimit'},
			{f = 'i', t = 'WorldChannelDailyLimitByVIP'},
			{f = 'i', t = 'WorldChannelDailyLimitBySuperVIP'},
		}
		m_LevelUpData = KG_Table.Load(path, tTitle, FILE_OPEN_MODE.NORMAL)
	end
	return m_LevelUpData
end
local DAILY_LIMIT_TABLE_KEY = {
	[PLAYER_TALK_CHANNEL.WORLD  ] = 'WorldChannelDailyLimit',
	[PLAYER_TALK_CHANNEL.FORCE  ] = 'ForceChannelDailyLimit',
	[PLAYER_TALK_CHANNEL.CAMP   ] = 'CampChannelDailyLimit',
	[PLAYER_TALK_CHANNEL.SENCE  ] = 'SceneChannelDailyLimit',
	[PLAYER_TALK_CHANNEL.NEARBY ] = 'NearbyChannelDailyLimit',
	[PLAYER_TALK_CHANNEL.WHISPER] = 'WhisperDailyLimit',
}
function LIB.GetChatChannelDailyLimit(nLevel, nChannel)
	local LevelUpData = GetRegisterChannelLimitTable()
	if not LevelUpData then
		return false
	end
	local szKey = DAILY_LIMIT_TABLE_KEY[nChannel]
	if not szKey then
		return -1
	end
	local tUpData = LevelUpData:Search(nLevel)
	if not tUpData then
		return false
	end
	return tUpData[szKey] or -1
end
end

function LIB.GetMsgTypeMenu(fnAction, tChecked)
	local t = {}
	for _, cg in ipairs(CONSTANT.MSG_TYPE_MENU) do
		local t1 = { szOption = cg.szCaption }
		if cg.tChannels[1] then
			for _, szChannel in ipairs(cg.tChannels) do
				insert(t1,{
					szOption = g_tStrings.tChannelName[szChannel],
					rgb = GetMsgFontColor(szChannel, true),
					UserData = szChannel,
					fnAction = fnAction,
					bCheck = true,
					bChecked = tChecked[szChannel],
				})
			end
		else
			for szPrefix, tChannels in pairs(cg.tChannels) do
				if #t1 > 0 then
					insert(t1,{ bDevide = true })
				end
				insert(t1,{ szOption = szPrefix, bDisable = true })
				for _, szChannel in ipairs(tChannels) do
					insert(t1,{
						szOption = g_tStrings.tChannelName[szChannel],
						rgb = GetMsgFontColor(szChannel, true),
						UserData = szChannel,
						fnAction = fnAction,
						bCheck = true,
						bChecked = tChecked[szChannel],
					})
				end
			end
		end
		insert(t, t1)
	end
	return t
end

-----------------------------------------------------------------------------------------
-- ������ HOOK
-----------------------------------------------------------------------------------------
do
-- HOOK������
local CHAT_HOOK = {
	BEFORE = {},
	AFTER = {},
	FILTER = {},
}
function LIB.HookChatPanel(szType, szKey, fnAction)
	if IsFunction(szKey) then
		szKey, fnAction = nil, szKey
	end
	if not CHAT_HOOK[szType] then
		return
	end
	if not szKey then
		szKey = GetTickCount()
		while CHAT_HOOK[szType][tostring(szKey)] do
			szKey = szKey + 0.1
		end
		szKey = tostring(szKey)
	end
	if IsNil(fnAction) then
		return CHAT_HOOK[szType][szKey]
	end
	if not IsFunction(fnAction) then
		fnAction = nil
	end
	CHAT_HOOK[szType][szKey] = fnAction
	return szKey
end

local l_hPrevItem
local function BeforeChatAppendItemFromString(h, szMsg, ...) -- h, szMsg, szChannel, dwTime, nR, nG, nB, ...
	for szKey, fnAction in pairs(CHAT_HOOK.FILTER) do
		local res, err, trace = XpCall(fnAction, h, szMsg, ...)
		if res then
			if not err then
				return h, '', ...
			end
		--[[#DEBUG BEGIN]]
		else
			FireUIEvent('CALL_LUA_ERROR', err .. '\nHookChatPanel.FILTER:' .. szKey .. '\n' .. trace .. '\n')
		--[[#DEBUG END]]
		end
	end
	for szKey, fnAction in pairs(CHAT_HOOK.BEFORE) do
		local res, err, trace = XpCall(fnAction, h, szMsg, ...)
		if res then
			if IsString(err) then
				szMsg = err
			end
		--[[#DEBUG BEGIN]]
		else
			FireUIEvent('CALL_LUA_ERROR', err .. '\nHookChatPanel.BEFORE:' .. szKey .. '\n' .. trace .. '\n')
		--[[#DEBUG END]]
		end
	end
	local nCount = h:GetItemCount()
	if nCount == 0 then
		l_hPrevItem = 0
	else
		l_hPrevItem = h:Lookup(nCount - 1)
	end
	return h, szMsg, ...
end

local function AfterChatAppendItemFromString(h, ...)
	if l_hPrevItem then
		local nCount = h:GetItemCount()
		local nStart = -1
		if l_hPrevItem == 0 then
			nStart = 0
		elseif l_hPrevItem and l_hPrevItem:IsValid() then
			nStart = l_hPrevItem:GetIndex() + 1
		end
		if nStart >= 0 and nStart < nCount then
			for szKey, fnAction in pairs(CHAT_HOOK.AFTER) do
				local res, err, trace = XpCall(fnAction, h, nStart, ...)
				if not res then
					FireUIEvent('CALL_LUA_ERROR', err .. '\nHookChatPanel.AFTER: ' .. szKey .. '\n' .. trace .. '\n')
				end
			end
		end
		l_hPrevItem = nil
	end
	return h, ...
end

local HOOKED_UI = setmetatable({}, { __mode = 'k' })
local function Hook(i)
	local h = Station.Lookup('Lowest2/ChatPanel' .. i .. '/Wnd_Message', 'Handle_Message')
		or Station.Lookup('Normal1/ChatPanel' .. i .. '/Wnd_Message', 'Handle_Message')
	if h and not HOOKED_UI[h] then
		HOOKED_UI[h] = true
		HookTableFunc(h, 'AppendItemFromString', BeforeChatAppendItemFromString, { bHookParams = true })
		HookTableFunc(h, 'AppendItemFromString', AfterChatAppendItemFromString, { bAfterOrigin = true, bHookParams = true })
	end
end
LIB.RegisterEvent('CHAT_PANEL_OPEN', 'ChatPanelHook', function(event) Hook(arg0) end)

local function Unhook(i)
	local h = Station.Lookup('Lowest2/ChatPanel' .. i .. '/Wnd_Message', 'Handle_Message')
		or Station.Lookup('Normal1/ChatPanel' .. i .. '/Wnd_Message', 'Handle_Message')
	if h and HOOKED_UI[h] then
		HOOKED_UI[h] = nil
		UnhookTableFunc(h, 'AppendItemFromString', BeforeChatAppendItemFromString)
		UnhookTableFunc(h, 'AppendItemFromString', AfterChatAppendItemFromString)
	end
end

local function HookAll()
	for i = 1, 10 do
		Hook(i)
	end
end
LIB.RegisterInit('LIB#ChatPanelHook', HookAll)
LIB.RegisterEvent('CHAT_PANEL_INIT', 'ChatPanelHook', HookAll)

local function UnhookAll()
	for i = 1, 10 do
		Unhook(i)
	end
end
LIB.RegisterExit('LIB#ChatPanelHook', UnhookAll)
LIB.RegisterReload('LIB#ChatPanelHook', UnhookAll)
end

do
local function OnChatPanelNamelinkLButtonDown(...)
	if this[ITEM_LBUTTONDOWN_KEY] then
		this[ITEM_LBUTTONDOWN_KEY](...)
	end
	LIB.ChatLinkEventHandlers.OnNameLClick(...)
end

LIB.HookChatPanel(NSFormatString('AFTER.{$NS}#HOOKNAME'), function(h, nIndex)
	for i = nIndex, h:GetItemCount() - 1 do
		local hItem = h:Lookup(i)
		if hItem:GetName():find('^namelink_%d+$') and not hItem[RENDERED_FLAG_KEY] then
			hItem[RENDERED_FLAG_KEY] = true
			if hItem.OnItemLButtonDown then
				hItem[ITEM_LBUTTONDOWN_KEY] = hItem.OnItemLButtonDown
			end
			hItem.OnItemLButtonDown = OnChatPanelNamelinkLButtonDown
		end
	end
end)
end

-- ��ֹɽկ
RegisterTalkFilter(function(nChannel, aSay, dwTalkerID, szName, bEcho, bOnlyShowBallon, bSecurity, bGMAccount, bCheater, dwTitleID, dwIdePetTemplateID)
	if IsRemotePlayer(dwTalkerID) then
		return
	end
	local szRealName = szName
	local nPos = StringFindW(szName, '@')
	if nPos then
		szRealName = szName:sub(1, nPos - 1)
	end
	local p = aSay[1]
	if p and p.type == 'eventlink' and p.name == '' then
		local data = LIB.JsonDecode(p.linkinfo)
		if data and data._ and data.c and data.c == GetStringCRC(szName .. data._ .. '8545ada2-f687-4c95-8558-27cbf823745a') then
			return
		end
	end
	if UI_GetClientPlayerID() ~= dwTalkerID and PACKET_INFO.AUTHOR_PROTECT_NAMES[szRealName] and PACKET_INFO.AUTHOR_ROLES[dwTalkerID] ~= szName then
		return true
	end
end, {
	PLAYER_TALK_CHANNEL.NEARBY,
	PLAYER_TALK_CHANNEL.SENCE,
	PLAYER_TALK_CHANNEL.WORLD,
	PLAYER_TALK_CHANNEL.TEAM,
	PLAYER_TALK_CHANNEL.RAID,
	PLAYER_TALK_CHANNEL.BATTLE_FIELD,
	PLAYER_TALK_CHANNEL.TONG,
	PLAYER_TALK_CHANNEL.FORCE,
	PLAYER_TALK_CHANNEL.CAMP,
	PLAYER_TALK_CHANNEL.WHISPER,
	PLAYER_TALK_CHANNEL.FRIENDS,
	PLAYER_TALK_CHANNEL.TONG_ALLIANCE,
})
