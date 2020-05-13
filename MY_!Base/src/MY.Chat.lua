--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : �������ģ��
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
-----------------------------------------------
-- ���غ����ͱ���
-----------------------------------------------
local _L = MY.LoadLangPack()
local EMPTY_TABLE = SetmetaReadonly({})

-- ��������ٳ�����
-- ���츴�Ʋ�����
function MY.RepeatChatLine(hTime)
	local edit = Station.Lookup('Lowest2/EditBox/Edit_Input')
	if not edit then
		return
	end
	MY.CopyChatLine(hTime)
	local tMsg = edit:GetTextStruct()
	if #tMsg == 0 then
		return
	end
	local nChannel, szName = EditBox_GetChannel()
	if MY.CanTalk(nChannel) then
		GetClientPlayer().Talk(nChannel, szName or '', tMsg)
		edit:ClearText()
	end
end

-- ����ɾ����
function MY.RemoveChatLine(hTime)
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

-- ��ȡ����������Text
function MY.GetCopyLinkText(szText, rgbf)
	szText = szText or _L[' * ']
	rgbf   = rgbf   or { f = 10 }

	return GetFormatText(szText, rgbf.f, rgbf.r, rgbf.g, rgbf.b, 82691,
		'this.bMyChatRendered=true\nthis.OnItemLButtonDown=MY.ChatLinkEventHandlers.OnCopyLClick\nthis.OnItemMButtonDown=MY.ChatLinkEventHandlers.OnCopyMClick\nthis.OnItemRButtonDown=MY.ChatLinkEventHandlers.OnCopyRClick\nthis.OnItemMouseEnter=MY.ChatLinkEventHandlers.OnCopyMouseEnter\nthis.OnItemMouseLeave=MY.ChatLinkEventHandlers.OnCopyMouseLeave',
		'copylink')
end

-- ��ȡ����������Text
function MY.GetTimeLinkText(rgbfs, dwTime)
	if not dwTime then
		dwTime = GetCurrentTime()
	end
	rgbfs = rgbfs or { f = 10 }
	return GetFormatText(
		MY.FormatTime(rgbfs.s or '[hh:mm.ss]', dwTime),
		rgbfs.f, rgbfs.r, rgbfs.g, rgbfs.b, 82691,
		'this.bMyChatRendered=true\nthis.OnItemLButtonDown=MY.ChatLinkEventHandlers.OnCopyLClick\nthis.OnItemMButtonDown=MY.ChatLinkEventHandlers.OnCopyMClick\nthis.OnItemRButtonDown=MY.ChatLinkEventHandlers.OnCopyRClick\nthis.OnItemMouseEnter=MY.ChatLinkEventHandlers.OnCopyMouseEnter\nthis.OnItemMouseLeave=MY.ChatLinkEventHandlers.OnCopyMouseLeave',
		'timelink'
	)
end

-- ����������
function MY.CopyChatLine(hTime, bTextEditor)
	local edit = Station.Lookup('Lowest2/EditBox/Edit_Input')
	if bTextEditor then
		edit = UI.OpenTextEditor():find('.WndEdit')[1]
	end
	if not edit then
		return
	end
	Station.Lookup('Lowest2/EditBox'):Show()
	edit:ClearText()
	local h, i, bBegin, bContent = hTime:GetParent(), hTime:GetIndex(), nil, false
	-- loop
	for i = i + 1, h:GetItemCount() - 1 do
		local p = h:Lookup(i)
		if p:GetType() == 'Text' then
			local szName = p:GetName()
			if szName ~= 'timelink' and szName ~= 'copylink' and szName ~= 'msglink' and szName ~= 'time' then
				local szText, bEnd = p:GetText(), false
				if not bTextEditor and StringFindW(szText, '\n') then
					szText = StringReplaceW(szText, '\n', '')
					bEnd = true
				end
				bContent = true
				if szName == 'itemlink' then
					edit:InsertObj(szText, { type = 'item', text = szText, item = p:GetUserData() })
				elseif szName == 'iteminfolink' then
					edit:InsertObj(szText, { type = 'iteminfo', text = szText, version = p.nVersion, tabtype = p.dwTabType, index = p.dwIndex })
				elseif string.sub(szName, 1, 8) == 'namelink' then
					if bBegin == nil then
						bBegin = false
					end
					edit:InsertObj(szText, { type = 'name', text = szText, name = string.match(szText, '%[(.*)%]') })
				elseif szName == 'questlink' then
					edit:InsertObj(szText, { type = 'quest', text = szText, questid = p:GetUserData() })
				elseif szName == 'recipelink' then
					edit:InsertObj(szText, { type = 'recipe', text = szText, craftid = p.dwCraftID, recipeid = p.dwRecipeID })
				elseif szName == 'enchantlink' then
					edit:InsertObj(szText, { type = 'enchant', text = szText, proid = p.dwProID, craftid = p.dwCraftID, recipeid = p.dwRecipeID })
				elseif szName == 'skilllink' then
					local o = clone(p.skillKey)
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
								szText, bBegin = string.sub(szText, nB + nE), true
								edit:ClearText()
							end
						end
					end
					if szText ~= '' and (table.getn(edit:GetTextStruct()) > 0 or szText ~= g_tStrings.STR_FACE) then
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
				local emo = MY.GetChatEmotion(dwID)
				if emo then
					edit:InsertObj(emo.szCmd, { type = 'emotion', text = emo.szCmd, id = emo.dwID })
				end
			end
		end
	end
	Station.SetFocusWindow(edit)
end

do local ChatLinkEvents, PEEK_PLAYER = {}, {}
MY.RegisterEvent('PEEK_OTHER_PLAYER', function()
	if not PEEK_PLAYER[arg1] then
		return
	end
	if arg0 == PEEK_OTHER_PLAYER_RESPOND.INVALID then
		OutputMessage('MSG_ANNOUNCE_RED', _L['Invalid player ID!'])
	elseif arg0 == PEEK_OTHER_PLAYER_RESPOND.FAILED then
		OutputMessage('MSG_ANNOUNCE_RED', _L['Peek other player failed!'])
	elseif arg0 == PEEK_OTHER_PLAYER_RESPOND.CAN_NOT_FIND_PLAYER then
		OutputMessage('MSG_ANNOUNCE_RED', _L['Can not find player to peek!'])
	elseif arg0 == PEEK_OTHER_PLAYER_RESPOND.TOO_FAR then
		OutputMessage('MSG_ANNOUNCE_RED', _L['Player is too far to peek!'])
	end
	PEEK_PLAYER[arg1] = nil
end)
function ChatLinkEvents.OnNameLClick(element, link)
	if not link then
		link = element
	end
	if IsCtrlKeyDown() and IsAltKeyDown() then
		local menu = {}
		InsertInviteTeamMenu(menu, (UI(link):text():gsub('[%[%]]', '')))
		menu[1].fnAction()
	elseif IsCtrlKeyDown() then
		MY.CopyChatItem(link)
	elseif IsShiftKeyDown() then
		MY.SetTarget(TARGET.PLAYER, UI(link):text())
	elseif IsAltKeyDown() then
		if MY_Farbnamen and MY_Farbnamen.Get then
			local info = MY_Farbnamen.Get((UI(link):text():gsub('[%[%]]', '')))
			if info then
				PEEK_PLAYER[info.dwID] = true
				ViewInviteToPlayer(info.dwID)
			end
		end
	else
		MY.SwitchChat(UI(link):text())
		local edit = Station.Lookup('Lowest2/EditBox/Edit_Input')
		if edit then
			Station.SetFocusWindow(edit)
		end
	end
end
function ChatLinkEvents.OnNameRClick(element, link)
	if not link then
		link = element
	end
	PopupMenu(MY.GetTargetContextMenu(TARGET.PLAYER, (UI(link):text():gsub('[%[%]]', ''))))
end
function ChatLinkEvents.OnCopyLClick(element, link)
	if not link then
		link = element
	end
	MY.CopyChatLine(link, IsCtrlKeyDown())
end
function ChatLinkEvents.OnCopyMClick(element, link)
	if not link then
		link = element
	end
	MY.RemoveChatLine(link)
end
function ChatLinkEvents.OnCopyRClick(element, link)
	if not link then
		link = element
	end
	MY.RepeatChatLine(link)
end
function ChatLinkEvents.OnCopyMouseEnter(element, link)
	if not link then
		link = element
	end
	local x, y = element:GetAbsPos()
	local w, h = element:GetSize()
	local szText = GetFormatText(_L['LClick to copy to editbox.\nMClick to remove this line.\nRClick to repeat this line.'], 136)
	OutputTip(szText, 450, {x, y, w, h}, MY_TIP_POSTYPE.TOP_BOTTOM)
end
function ChatLinkEvents.OnCopyMouseLeave(element, link)
	if not link then
		link = element
	end
	HideTip()
end
function ChatLinkEvents.OnItemLClick(element, link)
	if not link then
		link = element
	end
	OnItemLinkDown(link)
end
function ChatLinkEvents.OnItemRClick(element, link)
	if not link then
		link = element
	end
	if IsCtrlKeyDown() then
		MY.CopyChatItem(link)
	end
end
MY.ChatLinkEvents = ChatLinkEvents

local ChatLinkEventHandlers = {}
function ChatLinkEventHandlers.OnNameLClick() ChatLinkEvents.OnNameLClick(this) end
function ChatLinkEventHandlers.OnNameRClick() ChatLinkEvents.OnNameRClick(this) end
function ChatLinkEventHandlers.OnCopyLClick() ChatLinkEvents.OnCopyLClick(this) end
function ChatLinkEventHandlers.OnCopyMClick() ChatLinkEvents.OnCopyMClick(this) end
function ChatLinkEventHandlers.OnCopyRClick() ChatLinkEvents.OnCopyRClick(this) end
function ChatLinkEventHandlers.OnCopyMouseEnter() ChatLinkEvents.OnCopyMouseEnter(this) end
function ChatLinkEventHandlers.OnCopyMouseLeave() ChatLinkEvents.OnCopyMouseLeave(this) end
function ChatLinkEventHandlers.OnItemLClick() ChatLinkEvents.OnItemLClick(this) end
function ChatLinkEventHandlers.OnItemRClick() ChatLinkEvents.OnItemRClick(this) end
MY.ChatLinkEventHandlers = ChatLinkEventHandlers

-- ��link�¼���Ӧ
-- (userdata) MY.RenderChatLink(userdata link)                   ����link�ĸ����¼��� namelink��һ��������TextԪ��
-- (userdata) MY.RenderChatLink(userdata element, userdata link) ����element�ĸ����¼��� ����Դ��link
-- (string) MY.RenderChatLink(string szMsg)                      ��ʽ��szMsg ��������ĳ����� ���ʱ����Ӧ
-- link   : һ��������TextԪ��
-- element: һ�����Թ������Ϣ��Ӧ��UIԪ��
-- szMsg  : ��ʽ����UIXML��Ϣ
function MY.RenderChatLink(arg1, arg2)
	if type(arg1) == 'string' then -- szMsg
		local szMsg = arg1
		local xmls = MY.Xml.Decode(szMsg)
		if xmls then
			for i, xml in ipairs(xmls) do
				if xml and xml['.'] == 'text' and xml[''] and xml[''].name then
					local name, script = xml[''].name, xml[''].script
					if script then
						script = script .. '\n'
					else
						script = ''
					end

					if name:sub(1, 8) == 'namelink' then
						script = script .. 'this.bMyChatRendered=true\nthis.OnItemLButtonDown=MY.ChatLinkEventHandlers.OnNameLClick\nthis.OnItemRButtonDown=MY.ChatLinkEventHandlers.OnNameRClick'
					elseif name == 'copy' or name == 'copylink' or name == 'timelink' then
						script = script .. 'this.bMyChatRendered=true\nthis.OnItemLButtonDown=MY.ChatLinkEventHandlers.OnCopyLClick\nthis.OnItemMButtonDown=MY.ChatLinkEventHandlers.OnCopyMClick\nthis.OnItemRButtonDown=MY.ChatLinkEventHandlers.OnCopyRClick\nthis.OnItemMouseEnter=MY.ChatLinkEventHandlers.OnCopyMouseEnter\nthis.OnItemMouseLeave=MY.ChatLinkEventHandlers.OnCopyMouseLeave'
					else
						script = script .. 'this.bMyChatRendered=true\nthis.OnItemLButtonDown=MY.ChatLinkEventHandlers.OnItemLClick\nthis.OnItemRButtonDown=MY.ChatLinkEventHandlers.OnItemRClick'
					end

					if #script > 0 then
						xml[''].eventid = 82803
						xml[''].script = script
					end
				end
			end
			szMsg = MY.Xml.Encode(xmls)
		end
		return szMsg
	elseif type(arg1) == 'table' and type(arg1.GetName) == 'function' then
		local element = arg1
		local link = arg2 or arg1
		if element.bMyChatRendered then
			return
		end
		local ui = UI(element)
		local name = ui:name()
		if name:sub(1, 8) == 'namelink' then
			ui:lclick(function() ChatLinkEvents.OnNameLClick(element, link) end)
			ui:rclick(function() ChatLinkEvents.OnNameRClick(element, link) end)
		elseif name == 'copy' or name == 'copylink' then
			ui:lclick(function() ChatLinkEvents.OnCopyLClick(element, link) end)
			ui:rclick(function() ChatLinkEvents.OnCopyRClick(element, link) end)
			ui:mclick(function() ChatLinkEvents.OnCopyMClick(element, link) end)
		else
			ui:lclick(function() ChatLinkEvents.OnItemLClick(element, link) end)
			ui:rclick(function() ChatLinkEvents.OnItemRClick(element, link) end)
		end
		element.bMyChatRendered = true
		return element
	end
end
end

-- ����Item�������
function MY.CopyChatItem(p)
	local edit = Station.Lookup('Lowest2/EditBox/Edit_Input')
	if not edit then
		return
	end
	if p:GetType() == 'Text' then
		local szText, szName = p:GetText(), p:GetName()
		if szName == 'itemlink' then
			edit:InsertObj(szText, { type = 'item', text = szText, item = p:GetUserData() })
		elseif szName == 'iteminfolink' then
			edit:InsertObj(szText, { type = 'iteminfo', text = szText, version = p.nVersion, tabtype = p.dwTabType, index = p.dwIndex })
		elseif string.sub(szName, 1, 8) == 'namelink' then
			edit:InsertObj(szText, { type = 'name', text = szText, name = string.match(szText, '%[(.*)%]') })
		elseif szName == 'questlink' then
			edit:InsertObj(szText, { type = 'quest', text = szText, questid = p:GetUserData() })
		elseif szName == 'recipelink' then
			edit:InsertObj(szText, { type = 'recipe', text = szText, craftid = p.dwCraftID, recipeid = p.dwRecipeID })
		elseif szName == 'enchantlink' then
			edit:InsertObj(szText, { type = 'enchant', text = szText, proid = p.dwProID, craftid = p.dwCraftID, recipeid = p.dwRecipeID })
		elseif szName == 'skilllink' then
			local o = clone(p.skillKey)
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

--������Ϣ
function MY.FormatChatContent(szMsg)
	local t = MY.Xml.Decode(szMsg)
	-- Output(t)
	local t2 = {}
	for _, node in ipairs(t) do
		local ntype = MY.Xml.GetNodeType(node)
		local ndata = MY.Xml.GetNodeData(node)
		-- ��̬����
		if ntype == 'image' then
			local emo = MY.GetChatEmotion(ndata.path, ndata.frame, 'image')
			if emo then
				table.insert(t2, {type = 'emotion', text = emo.szCmd, innerText = emo.szCmd, id = emo.dwID})
			end
		-- ��̬����
		elseif ntype == 'animate' then
			local emo = MY.GetChatEmotion(ndata.path, ndata.group, 'animate')
			if emo then
				table.insert(t2, {type = 'emotion', text = emo.szCmd, innerText = emo.szCmd, id = emo.dwID})
			end
		-- ��������
		elseif ntype == 'text' then
			local is_normaltext = false
			-- ��ͨ����
			if not ndata.name then
				is_normaltext = true
			-- ��Ʒ����
			elseif ndata.name == 'itemlink' then
				table.insert(t2, {type = 'item', text = ndata.text, innerText = ndata.text:sub(2, -2), item = ndata.userdata})
			-- ��Ʒ��Ϣ
			elseif ndata.name == 'iteminfolink' then
				local version, tab, index = string.match(ndata.script, 'this.nVersion=(%d+)%s*this.dwTabType=(%d+)%s*this.dwIndex=(%d+)')
				table.insert(t2, {type = 'iteminfo', text = ndata.text, innerText = ndata.text:sub(2, -2), version = version, tabtype = tab, index = index})
			-- ����
			elseif ndata.name:sub(1, 9) == 'namelink_' then
				table.insert(t2, {type = 'name', text = ndata.text, innerText = ndata.text, name = ndata.text:sub(2, -2)})
			-- ����
			elseif ndata.name == 'questlink' then
				table.insert(t2, {type = 'quest', text = ndata.text, innerText = ndata.text:sub(2, -2), questid = ndata.userdata})
			-- �����
			elseif ndata.name == 'recipelink' then
				local craft, recipe = string.match(ndata.script, 'this.dwCraftID=(%d+)%s*this.dwRecipeID=(%d+)')
				table.insert(t2, {type = 'recipe', text = ndata.text, innerText = ndata.text:sub(2, -2), craftid = craft, recipeid = recipe})
			-- ����
			elseif ndata.name == 'skilllink' then
				local skillinfo = string.match(ndata.script, 'this.skillKey=%{(.-)%}')
				local skillKey = {}
				for w in string.gfind(skillinfo, '(.-)%,') do
					local k, v  = string.match(w, '(.-)=(%w+)')
					skillKey[k] = v
				end
				skillKey.text = ndata.text
				skillKey.innerText = ndata.text:sub(2, -2)
				table.insert(t2, skillKey)
			-- �ƺ�
			elseif ndata.name == 'designationlink' then
				local id, fix = string.match(ndata.script, 'this.dwID=(%d+)%s*this.bPrefix=(.-)')
				table.insert(t2, {type = 'designation', text = ndata.text, innerText = ndata.text:sub(2, -2), id = id, prefix = fix})
			-- �����ؼ�
			elseif ndata.name == 'skillrecipelink' then
				local id, level = string.match(ndata.script, 'this.dwID=(%d+)%s*this.dwLevel=(%d+)')
				table.insert(t2, {type = 'skillrecipe', text = ndata.text, innerText = ndata.text:sub(2, -2), id = id, level = level})
			-- �鼮
			elseif ndata.name == 'booklink' then
				local version, tab, index, id = string.match(ndata.script, 'this.nVersion=(%d+)%s*this.dwTabType=(%d+)%s*this.dwIndex=(%d+)%s*this.nBookRecipeID=(%d+)')
				table.insert(t2, {type = 'book', text = ndata.text, innerText = ndata.text:sub(2, -2), version = version, tabtype = tab, index = index, bookinfo = id})
			-- �ɾ�
			elseif ndata.name == 'achievementlink' then
				local id = string.match(ndata.script, 'this.dwID=(%d+)')
				table.insert(t2, {type = 'achievement', text = ndata.text, innerText = ndata.text:sub(2, -2), id = id})
			-- ǿ��
			elseif ndata.name == 'enchantlink' then
				local pro, craft, recipe = string.match(ndata.script, 'this.dwProID=(%d+)%s*this.dwCraftID=(%d+)%s*this.dwRecipeID=(%d+)')
				table.insert(t2, {type = 'enchant', text = ndata.text, innerText = ndata.text:sub(2, -2), proid = pro, craftid = craft, recipeid = recipe})
			-- �¼�
			elseif ndata.name == 'eventlink' then
				local eventname, linkinfo = string.match(ndata.script, 'this.szName="(.-)"%s*this.szLinkInfo="(.-)"$')
				if not eventname then
					eventname, linkinfo = string.match(ndata.script, 'this.szName="(.-)"%s*this.szLinkInfo="(.-)"')
				end
				table.insert(t2, {type = 'eventlink', text = ndata.text, innerText = ndata.text:sub(2, -2), name = eventname, linkinfo = linkinfo:gsub('\\(.)', '%1')})
			-- δ֪���͵��ַ���
			elseif ndata.text then
				is_normaltext = true
			end
			if is_normaltext then
				table.insert(t2, {type = 'text', text = ndata.text, innerText = ndata.text})
			end
		end
	end
	return t2
end

-- �ַ�����һ������table�ṹ��
function MY.StringfyChatContent(t)
	local t1 = {}
	for _, v in ipairs(t) do
		table.insert(t1, v.text)
	end
	return table.concat(t1)
end

-- �ж�ĳ��Ƶ���ܷ���
-- (bool) MY.CanTalk(number nChannel)
function MY.CanTalk(nChannel)
	for _, v in ipairs({'WHISPER', 'TEAM', 'RAID', 'BATTLE_FIELD', 'NEARBY', 'TONG', 'TONG_ALLIANCE' }) do
		if nChannel == PLAYER_TALK_CHANNEL[v] then
			return true
		end
	end
	return false
end

do
-- get channel header
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
-- �л�����Ƶ��
-- (void) MY.SwitchChat(number nChannel)
-- (void) MY.SwitchChat(string szHeader)
-- (void) MY.SwitchChat(string szName)
function MY.SwitchChat(nChannel)
	local szHeader = TALK_CHANNEL_HEADER[nChannel]
	if szHeader then
		SwitchChatChannel(szHeader)
	elseif nChannel == PLAYER_TALK_CHANNEL.WHISPER then
		Station.Lookup('Lowest2/EditBox'):Show()
		Station.Lookup('Lowest2/EditBox/Edit_Input'):SetText('/w ')
		Station.SetFocusWindow('Lowest2/EditBox/Edit_Input')
	elseif type(nChannel) == 'string' then
		if string.sub(nChannel, 1, 1) == '/' then
			if nChannel == '/cafk' or nChannel == '/catr' then
				SwitchChatChannel(nChannel)
				MY.Talk(nil, nChannel, nil, nil, nil, true)
				Station.Lookup('Lowest2/EditBox'):Show()
			else
				SwitchChatChannel(nChannel..' ')
			end
		else
			SwitchChatChannel('/w ' .. string.gsub(nChannel,'[%[%]]','') .. ' ')
		end
	end
end
end

-- ���������õ�������
function MY.FocusChatBox()
	Station.SetFocusWindow('Lowest2/EditBox/Edit_Input')
end

do
-- ��������ʼ��
local MAX_EMOTION_LEN, EMOTION_CACHE = 0
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
			MAX_EMOTION_LEN = math.max(MAX_EMOTION_LEN, wstring.len(t1.szCmd))
		end
		EMOTION_CACHE = t
	end
end

-- ��ȡ��������б�
-- typedef emo table
-- (emo[]) MY.GetChatEmotion()                             -- �������б����б�
-- (emo)   MY.GetChatEmotion(szCommand)                    -- ����ָ��Cmd�ı���
-- (emo)   MY.GetChatEmotion(szImageFile, nFrame, szType)  -- ����ָ��ͼ��ı���
function MY.GetChatEmotion(arg0, arg1, arg2)
	InitEmotion()
	local t
	if not arg0 then
		t = EMOTION_CACHE
	elseif not arg1 then
		t = EMOTION_CACHE[arg0]
	elseif arg2 then
		arg0 = string.gsub(arg0, '\\\\', '\\')
		t = EMOTION_CACHE[arg0..','..arg1..','..arg2]
	end
	return clone(t)
end

-- parse faceicon in talking message
local function ParseFaceIcon(t)
	InitEmotion()
	local t2 = {}
	for _, v in ipairs(t) do
		if v.type ~= 'text' then
			if v.type == 'emotion' then
				v.type = 'text'
			end
			table.insert(t2, v)
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
					szLeft = szLeft .. string.sub(szText, 1, nPos - 1)
					szText = string.sub(szText, nPos)
					for i = math.min(MAX_EMOTION_LEN, wstring.len(szText)), 2, -1 do
						local szTest = wstring.sub(szText, 1, i)
						local emo = MY.GetChatEmotion(szTest)
						if emo then
							szFace, dwFaceID = szTest, emo.dwID
							szText = szText:sub(szFace:len() + 1)
							break
						end
					end
					if szFace then -- emotion cmd matched
						if #szLeft > 0 then
							table.insert(t2, { type = 'text', text = szLeft })
							szLeft = ''
						end
						table.insert(t2, { type = 'emotion', text = szFace, id = dwFaceID })
					elseif nPos then -- find '#' but not match emotion
						szLeft = szLeft .. szText:sub(1, 1)
						szText = szText:sub(2)
					end
				end
			end
			if #szLeft > 0 then
				table.insert(t2, { type = 'text', text = szLeft })
				szLeft = ''
			end
		end
	end
	return t2
end
-- parse name in talking message
local function ParseName(t)
	local me = GetClientPlayer()
	local tar = MY.GetObject(me.GetTarget())
	for i, v in ipairs(t) do
		if v.type == 'text' then
			v.text = string.gsub(v.text, '%$zj', '[' .. me.szName .. ']')
			if tar then
				v.text = string.gsub(v.text, '%$mb', '[' .. tar.szName .. ']')
			end
		end
	end
	local t2 = {}
	for _, v in ipairs(t) do
		if v.type ~= 'text' then
			if v.type == 'name' then
				v = { type = 'text', text = '['..v.name..']' }
			end
			table.insert(t2, v)
		else
			local nOff, nLen = 1, string.len(v.text)
			while nOff <= nLen do
				local szName = nil
				local nPos1, nPos2 = string.find(v.text, '%[[^%[%]]+%]', nOff)
				if not nPos1 then
					nPos1 = nLen
				else
					szName = string.sub(v.text, nPos1 + 1, nPos2 - 1)
					nPos1 = nPos1 - 1
				end
				if nPos1 >= nOff then
					table.insert(t2, { type = 'text', text = string.sub(v.text, nOff, nPos1) })
					nOff = nPos1 + 1
				end
				if szName then
					table.insert(t2, { type = 'name', text = '[' .. szName .. ']', name = szName })
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
					local _, nEndPos = wstring.find(szText, szSensitiveWord)
					if nEndPos and nEndPos < nSensitiveWordEndPos then
						local nSensitiveWordLenW = wstring.len(szSensitiveWord)
						nSensitiveWordEndLen = string.len(wstring.sub(szSensitiveWord, nSensitiveWordLenW, nSensitiveWordLenW))
						nSensitiveWordEndPos = nEndPos
					end
				end

				table.insert(t2, {
					type = 'text',
					text = string.sub(szText, 1, nSensitiveWordEndPos - nSensitiveWordEndLen)
				})
				szText = string.sub(szText, nSensitiveWordEndPos + 1 - nSensitiveWordEndLen)
			end
		else
			table.insert(t2, v)
		end
	end
	return t2
end

-- ������������
-- (void) MY.Talk(string szTarget, string szText[, boolean bNoEscape, [boolean bSaveDeny, [boolean bPushToChatBox] ] ])
-- (void) MY.Talk([number nChannel, ] string szText[, boolean bNoEscape[boolean bSaveDeny, [boolean bPushToChatBox] ] ])
-- szTarget       -- ���ĵ�Ŀ���ɫ��
-- szText         -- �������ݣ������Ϊ���� KPlayer.Talk �� table��
-- nChannel       -- *��ѡ* ����Ƶ����PLAYER_TALK_CHANNLE.*��Ĭ��Ϊ����
-- bNoEscape      -- *��ѡ* ���������������еı���ͼƬ�����֣�Ĭ��Ϊ false
-- bSaveDeny      -- *��ѡ* �������������������ɷ��Ե�Ƶ�����ݣ�Ĭ��Ϊ false
-- bPushToChatBox -- *��ѡ* �����͵������Ĭ��Ϊ false
-- �ر�ע�⣺nChannel, szText ���ߵĲ���˳����Ե�����ս��/�Ŷ�����Ƶ�������л�
function MY.Talk(nChannel, szText, szUUID, bNoEscape, bSaveDeny, bPushToChatBox)
	local szTarget, me = '', GetClientPlayer()
	-- channel
	if not nChannel then
		nChannel = PLAYER_TALK_CHANNEL.NEARBY
	elseif type(nChannel) == 'string' then
		if not szText then
			szText = nChannel
			nChannel = PLAYER_TALK_CHANNEL.NEARBY
		elseif type(szText) == 'number' then
			szText, nChannel = nChannel, szText
		else
			szTarget = nChannel
			nChannel = PLAYER_TALK_CHANNEL.WHISPER
		end
	elseif nChannel == PLAYER_TALK_CHANNEL.RAID and me.GetScene().nType == MAP_TYPE.BATTLE_FIELD then
		nChannel = PLAYER_TALK_CHANNEL.BATTLE_FIELD
	elseif nChannel == PLAYER_TALK_CHANNEL.LOCAL_SYS then
		return MY.Sysmsg({szText}, '')
	end
	-- say body
	local tSay = nil
	if type(szText) == 'table' then
		tSay = szText
	else
		tSay = {{ type = 'text', text = szText}}
	end
	if not bNoEscape then
		tSay = ParseFaceIcon(tSay)
		tSay = ParseName(tSay)
	end
	tSay = ParseAntiSWS(tSay)
	if MY.IsShieldedVersion() then
		local nLen = 0
		for i, v in ipairs(tSay) do
			if nLen <= 64 then
				nLen = nLen + MY.StringLenW(v.text or v.name or '')
				if nLen > 64 then
					if v.text then v.text = MY.StringSubW(v.text, 1, 64 - nLen ) end
					if v.name then v.name = MY.StringSubW(v.name, 1, 64 - nLen ) end
					for j=#tSay, i+1, -1 do
						table.remove(tSay, j)
					end
				end
			end
		end
	end
	if bPushToChatBox or (bSaveDeny and not MY.CanTalk(nChannel)) then
		local edit = Station.Lookup('Lowest2/EditBox/Edit_Input')
		edit:ClearText()
		for _, v in ipairs(tSay) do
			edit:InsertObj(v.text, v)
		end
		-- change to this channel
		MY.SwitchChat(nChannel)
		-- set focus
		Station.SetFocusWindow(edit)
	else
		if not tSay[1]
		or tSay[1].name ~= ''
		or tSay[1].type ~= 'eventlink' then
			table.insert(tSay, 1, {
				type = 'eventlink', name = '',
				linkinfo = MY.JsonEncode({
					via = 'MY',
					uuid = szUUID and tostring(szUUID),
				})
			})
		end
		me.Talk(nChannel, szTarget, tSay)
	end
end
end

function MY.EditBoxInsertItemInfo(dwTabType, dwIndex, nBookInfo, nVersion)
	local itemInfo = GetItemInfo(dwTabType, dwIndex)
	if not itemInfo then
		return false
	end
	if not nVersion then
		nVersion = GLOBAL.CURRENT_ITEM_VERSION
	end
	local edit = Station.Lookup('Lowest2/EditBox/Edit_Input')
	if itemInfo.nGenre == ITEM_GENRE.BOOK then
		if not nBookInfo then
			return false
		end
		local nBookID, nSegmentID = GlobelRecipeID2BookID(nBookInfo)
		local szName = '[' .. Table_GetSegmentName(nBookID, nSegmentID) .. ']'
		edit:InsertObj(szName, {
			type = 'book',
			text = szName,
			version = nVersion,
			tabtype = dwTabType,
			index = dwIndex,
			bookinfo = nBookInfo,
		})
		Station.SetFocusWindow(edit)
	else
		local szName = '[' .. GetItemNameByItemInfo(itemInfo) .. ']'
		edit:InsertObj(szName, {
			type = 'iteminfo',
			text = szName,
			version = nVersion,
			tabtype = dwTabType,
			index = dwIndex,
		})
		Station.SetFocusWindow(edit)
	end
	return true
end

do
local SPACE = ' '
local W_SPACE = g_tStrings.STR_ONE_CHINESE_SPACE
local metaAlignment = { __index = function() return 'L' end }
local function MergeHW(s)
	return s:gsub(W_SPACE, 'W'):gsub(' (W*) ', W_SPACE .. '%1'):gsub('W', W_SPACE)
end
function MY.TabTalk(nChannel, aTable, aAlignment)
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
		local aTalk, szFixL, szFixR = {}
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
				aTalk[j] = szFixL .. szText .. szFixR
			elseif aAlignment[j] == 'R' then
				aTalk[j] = MergeHW(szFixL .. szFixR) .. szText
			else
				aTalk[j] = szText .. MergeHW(szFixL .. szFixR)
			end
		end
		-- MY.Sysmsg({(concat(aTalk, '|'))})
		MY.Talk(nChannel, (concat(aTalk, ' ')))
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
function MY.GetChannelDailyLimit(nLevel, nChannel)
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

do
local CHANNEL_GROUP = {
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
}
function MY.GetChatChannelMenu(fnAction, tChecked)
	local t = {}
	for _, cg in ipairs(CHANNEL_GROUP) do
		local t1 = { szOption = cg.szCaption }
		if cg.tChannels[1] then
			for _, szChannel in ipairs(cg.tChannels) do
				insert(t1,{
					szOption = g_tStrings.tChannelName[szChannel],
					rgb = GetMsgFontColor(szChannel, true),
					UserData = szChannel,
					fnAction = fnAction,
					bCheck = true,
					bChecked = tChecked[szChannel]
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
						bChecked = tChecked[szChannel]
					})
				end
			end
		end
		insert(t, t1)
	end
	return t
end
end

-- Register:   MY.RegisterMsgMonitor(string szKey, function fnAction, table tChannels)
--             MY.RegisterMsgMonitor(function fnAction, table tChannels)
-- Unregister: MY.RegisterMsgMonitor(string szKey)
do local MSG_MONITOR_FUNC = {}
function MY.RegisterMsgMonitor(arg0, arg1, arg2)
	local szKey, fnAction, tChannels
	local tp0, tp1, tp2 = type(arg0), type(arg1), type(arg2)
	if tp0 == 'string' and tp1 == 'function' and tp2 == 'table' then
		szKey, fnAction, tChannels = arg0, arg1, arg2
	elseif tp0 == 'function' and tp1 == 'table' then
		fnAction, tChannels = arg0, arg1
	elseif tp0 == 'string' and not arg1 then
		szKey = arg0
	end

	if szKey and MSG_MONITOR_FUNC[szKey] then
		UnRegisterMsgMonitor(MSG_MONITOR_FUNC[szKey].fn)
		MSG_MONITOR_FUNC[szKey] = nil
	end
	if fnAction and tChannels then
		MSG_MONITOR_FUNC[szKey] = { fn = function(szMsg, nFont, bRich, r, g, b, szChannel, dwTalkerID, szName)
			-- filter addon comm.
			if StringFindW(szMsg, 'eventlink') and StringFindW(szMsg, _L['Addon comm.']) then
				return
			end
			fnAction(szMsg, nFont, bRich, r, g, b, szChannel, dwTalkerID, szName)
		end, ch = tChannels }
		RegisterMsgMonitor(MSG_MONITOR_FUNC[szKey].fn, MSG_MONITOR_FUNC[szKey].ch)
	end
end
end

do
-- HOOK������
local CHAT_HOOK = {
	BEFORE = {},
	AFTER = {},
	FILTER = {},
}
function MY.HookChatPanel(szType, fnAction)
	local szKey = nil
	local nPos = StringFindW(szType, '.')
	if nPos then
		szKey = sub(szType, nPos + 1)
		szType = sub(szType, 1, nPos - 1)
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
		local status, invalid = pcall(fnAction, h, szMsg, ...)
		if status then
			if not invalid then
				return h, '', ...
			end
		else
			MY.Debug({msg}, 'HookChatPanel.FILTER#' .. szKey, MY_DEBUG.ERROR)
		end
	end
	for szKey, fnAction in pairs(CHAT_HOOK.BEFORE) do
		local status = pcall(fnAction, h, szMsg, ...)
		if not status then
			MY.Debug({msg}, 'HookChatPanel.BEFORE#' .. szKey, MY_DEBUG.ERROR)
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
	if not l_hPrevItem then
		return
	end
	local nCount = h:GetItemCount()
	local nStart = -1
	if l_hPrevItem == 0 then
		nStart = 0
	elseif l_hPrevItem and l_hPrevItem:IsValid() then
		nStart = l_hPrevItem:GetIndex() + 1
	end
	if nStart >= 0 and nStart < nCount then
		for szKey, fnAction in pairs(CHAT_HOOK.AFTER) do
			local status = pcall(fnAction, h, nStart, ...)
			if not status then
				MY.Debug({msg}, 'HookChatPanel.AFTER#' .. szKey, MY_DEBUG.ERROR)
			end
		end
	end
	l_hPrevItem = nil
end

local HOOKED_UI = setmetatable({}, { __mode = 'k' })
local function Hook(i)
	local h = Station.Lookup('Lowest2/ChatPanel' .. i .. '/Wnd_Message', 'Handle_Message')
	if h and not HOOKED_UI[h] then
		HOOKED_UI[h] = true
		HookTableFunc(h, 'AppendItemFromString', BeforeChatAppendItemFromString, { bHookParams = true })
		HookTableFunc(h, 'AppendItemFromString', AfterChatAppendItemFromString, { bAfterOrigin = true, bHookParams = true })
	end
end
MY.RegisterEvent('CHAT_PANEL_OPEN.ChatPanelHook', function(event) Hook(arg0) end)

local function Unhook(i)
	local h = Station.Lookup('Lowest2/ChatPanel' .. i .. '/Wnd_Message', 'Handle_Message')
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
HookAll()
MY.RegisterEvent('CHAT_PANEL_INIT.ChatPanelHook', HookAll)
MY.RegisterEvent('RELOAD_UI_ADDON_END.ChatPanelHook', HookAll)

local function UnhookAll()
	for i = 1, 10 do
		Unhook(i)
	end
end
MY.RegisterExit('ChatPanelHook', UnhookAll)
MY.RegisterReload('ChatPanelHook', UnhookAll)
end

do
local function OnChatPanelNamelinkLButtonDown(...)
	if this.__MY_OnItemLButtonDown then
		this.__MY_OnItemLButtonDown(...)
	end
	MY.ChatLinkEventHandlers.OnNameLClick(...)
end

MY.HookChatPanel('AFTER.MYLIB_HOOKNAME', function(h, nIndex)
	for i = nIndex, h:GetItemCount() - 1 do
		local hItem = h:Lookup(i)
		if hItem:GetName():find('^namelink_%d+$') and not hItem.bMyChatRendered then
			hItem.bMyChatRendered = true
			if hItem.OnItemLButtonDown then
				hItem.__MY_OnItemLButtonDown = hItem.OnItemLButtonDown
			end
			hItem.OnItemLButtonDown = OnChatPanelNamelinkLButtonDown
		end
	end
end)
end
