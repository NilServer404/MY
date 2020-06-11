--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : �Ŷӹ��� - �ŶӸſ�
-- @author   : ���� @˫���� @׷����Ӱ
-- @modifier : Emil Zhai (root@derzh.com)
-- @copyright: Copyright (c) 2013 EMZ Kingsoft Co., Ltd.
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
local mod, modf, pow, sqrt = math.mod or math.fmod, math.modf, math.pow, math.sqrt
local sin, cos, tan, atan, atan2 = math.sin, math.cos, math.tan, math.atan, math.atan2
local insert, remove, concat, unpack = table.insert, table.remove, table.concat, table.unpack or unpack
local pack, sort, getn = table.pack or function(...) return {...} end, table.sort, table.getn
-- jx3 apis caching
local wsub, wlen, wfind, wgsub = wstring.sub, wstring.len, StringFindW, StringReplaceW
local GetTime, GetLogicFrameCount, GetCurrentTime = GetTime, GetLogicFrameCount, GetCurrentTime
local GetClientTeam, UI_GetClientPlayerID = GetClientTeam, UI_GetClientPlayerID
local GetClientPlayer, GetPlayer, GetNpc, IsPlayer = GetClientPlayer, GetPlayer, GetNpc, IsPlayer
-- lib apis caching
local LIB = MY
local UI, DEBUG_LEVEL, PATH_TYPE, PACKET_INFO = LIB.UI, LIB.DEBUG_LEVEL, LIB.PATH_TYPE, LIB.PACKET_INFO
local wsub, count_c = LIB.wsub, LIB.count_c
local pairs_c, ipairs_c, ipairs_r = LIB.pairs_c, LIB.ipairs_c, LIB.ipairs_r
local spairs, spairs_r, sipairs, sipairs_r = LIB.spairs, LIB.spairs_r, LIB.sipairs, LIB.sipairs_r
local IsNil, IsEmpty, IsEquals, IsString = LIB.IsNil, LIB.IsEmpty, LIB.IsEquals, LIB.IsString
local IsBoolean, IsNumber, IsHugeNumber = LIB.IsBoolean, LIB.IsNumber, LIB.IsHugeNumber
local IsTable, IsArray, IsDictionary = LIB.IsTable, LIB.IsArray, LIB.IsDictionary
local IsFunction, IsUserdata, IsElement = LIB.IsFunction, LIB.IsUserdata, LIB.IsElement
local Call, XpCall, GetTraceback, RandomChild = LIB.Call, LIB.XpCall, LIB.GetTraceback, LIB.RandomChild
local Get, Set, Clone, GetPatch, ApplyPatch = LIB.Get, LIB.Set, LIB.Clone, LIB.GetPatch, LIB.ApplyPatch
local EncodeLUAData, DecodeLUAData, CONSTANT = LIB.EncodeLUAData, LIB.DecodeLUAData, LIB.CONSTANT
-------------------------------------------------------------------------------------------------------
local PLUGIN_NAME = 'MY_TeamTools'
local PLUGIN_ROOT = PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_TeamTools_Summary'
local _L = LIB.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not LIB.AssertVersion(MODULE_NAME, _L[MODULE_NAME], 0x2013900) then
	return
end
--------------------------------------------------------------------------
local D = {
	tAnchor = {},
	tDamage = {},
	tDeath  = {},
}
local SZ_INI = PACKET_INFO.ROOT .. 'MY_TeamTools/ui/MY_TeamTools_Summary.ini'
local MY_IsParty, MY_GetSkillName, MY_GetBuffName = LIB.IsParty, LIB.GetSkillName, LIB.GetBuffName

local RT_EQUIP_TOTAL = {
	'MELEE_WEAPON', -- �ὣ �ؽ�ȡ BIG_SWORD �ؽ�
	'RANGE_WEAPON', -- Զ������
	'CHEST',        -- �·�
	'HELM',         -- ñ��
	'AMULET',       -- ����
	'LEFT_RING',    -- ��ָ
	'RIGHT_RING',   -- ��ָ
	'WAIST',        -- ����
	'PENDANT',      -- ��׹
	'PANTS',        -- ����
	'BOOTS',        -- Ь��
	'BANGLE',       -- ����
}

local RT_SKILL_TYPE = {
	[0]  = 'PHYSICS_DAMAGE',
	[1]  = 'SOLAR_MAGIC_DAMAGE',
	[2]  = 'NEUTRAL_MAGIC_DAMAGE',
	[3]  = 'LUNAR_MAGIC_DAMAGE',
	[4]  = 'POISON_DAMAGE',
	[5]  = 'REFLECTIED_DAMAGE',
	[6]  = 'THERAPY',
	[7]  = 'STEAL_LIFE',
	[8]  = 'ABSORB_THERAPY',
	[9]  = 'ABSORB_DAMAGE',
	[10] = 'SHIELD_DAMAGE',
	[11] = 'PARRY_DAMAGE',
	[12] = 'INSIGHT_DAMAGE',
	[13] = 'EFFECTIVE_DAMAGE',
	[14] = 'EFFECTIVE_THERAPY',
	[15] = 'TRANSFER_LIFE',
	[16] = 'TRANSFER_MANA',
}
-- �ؾ����� ���������
-- local RT_DUNGEON_TOTAL = {}
local RT_SCORE = {
	Equip   = _L['Equip score'],
	Buff    = _L['Buff score'],
	Food    = _L['Food score'],
	Enchant = _L['Enchant score'],
	Special = _L['Special equip score'],
}

local RT_EQUIP_SPECIAL = {
	MELEE_WEAPON = true,
	BIG_SWORD    = true,
	AMULET       = true,
	PENDANT      = true
}

local RT_FOOD_TYPE = {
	[24] = true,
	[17] = true,
	[18] = true,
	[19] = true,
	[20] = true
}
-- ��Ҫ��ص�BUFF
local RT_BUFF_ID = {
	-- ����ְҵBUFF
	[362]  = true,
	[673]  = true,
	[112]  = true,
	[382]  = true,
	[2837] = true,
	-- ������
	[6329] = true,
	[6330] = true,
	-- ������
	[2564] = true,
	[2563] = true,
	-- ��������
	[3098] = true,
	-- ���� / ��˹�
	[2313] = true,
	[5970] = true,
}
local RT_GONGZHAN_ID = 3219
-- default sort
local RT_SORT_MODE    = 'DESC'
local RT_SORT_FIELD   = 'nEquipScore'
local RT_MAPID = 0
local RT_PLAYER_MAP_COPYID = {}
local RT_SELECT_PAGE  = 0
local RT_SELECT_KUNGFU
local RT_SELECT_DEATH
--
local RT_SCORE_FULL = 30000

function D.UpdateDungeonInfo(hDungeon)
	local me = GetClientPlayer()
	local szText = Table_GetMapName(RT_MAPID)
	if me.GetMapID() == RT_MAPID and LIB.IsDungeonMap(RT_MAPID) then
		szText = szText .. '\n' .. 'ID:(' .. me.GetScene().nCopyIndex  ..')'
	else
		local tCD = LIB.GetMapSaveCopy()
		if tCD and tCD[RT_MAPID] then
			szText = szText .. '\n' .. 'ID:(' .. tCD[RT_MAPID][1]  ..')'
		end
	end
	hDungeon:Lookup('Text_Dungeon'):SetText(szText)
end

function D.GetPlayerView()
	return Station.Lookup('Normal/PlayerView')
end

function D.ViewInviteToPlayer(page, dwID)
	local me = GetClientPlayer()
	if dwID ~= me.dwID then
		page.tViewInvite[dwID] = true
		ViewInviteToPlayer(dwID)
	end
end
-- ��������
function D.CountScore(tab, tScore)
	tScore.Food = tScore.Food + #tab.tFood * 100
	tScore.Buff = tScore.Buff + #tab.tBuff * 20
	if tab.nEquipScore then
		tScore.Equip = tScore.Equip + tab.nEquipScore
	end
	if tab.tTemporaryEnchant then
		tScore.Enchant = tScore.Enchant + #tab.tTemporaryEnchant * 300
	end
	if tab.tPermanentEnchant then
		tScore.Enchant = tScore.Enchant + #tab.tPermanentEnchant * 100
	end
	if tab.tEquip then
		for k, v in ipairs(tab.tEquip) do
			tScore.Special = tScore.Special + v.nLevel * 0.15 *  v.nQuality
		end
	end
end
-- �������
function D.CalculateSort(tInfo)
	local nCount = -2
	if RT_SORT_FIELD == 'tBossKill' then
		if LIB.IsDungeonRoleProgressMap(RT_MAPID) then
			nCount = 0
			for _, p in ipairs(tInfo[RT_SORT_FIELD]) do
				if p then
					nCount = nCount + 100
				else
					nCount = nCount + 1
				end
			end
		else
			nCount = tInfo.nCopyID or HUGE
		end
	elseif tInfo[RT_SORT_FIELD] then
		if type(tInfo[RT_SORT_FIELD]) == 'table' then
			nCount = #tInfo[RT_SORT_FIELD]
		else
			nCount = tInfo[RT_SORT_FIELD]
		end
	end
	if nCount == 0 and not tInfo.bIsOnLine then
		nCount = -2
	end
	return nCount
end
function D.Sorter(a, b)
	local nCountA = D.CalculateSort(a)
	local nCountB = D.CalculateSort(b)

	if RT_SORT_MODE == 'ASC' then -- ����
		return nCountA < nCountB
	else
		return nCountA > nCountB
	end
end
-- ����UI ûʲô������� ��Ҫclear
function D.UpdateList(page)
	local me = GetClientPlayer()
	if not me then return end
	local aTeam, tKungfu = D.GetTeam(page), {}
	local tScore = {
		Equip   = 0,
		Buff    = 0,
		Food    = 0,
		Enchant = 0,
		Special = 0,
	}
	sort(aTeam, D.Sorter)

	for k, v in ipairs(aTeam) do
		-- �ķ�ͳ��
		tKungfu[v.dwMountKungfuID] = tKungfu[v.dwMountKungfuID] or {}
		insert(tKungfu[v.dwMountKungfuID], v)
		D.CountScore(v, tScore)
		if not RT_SELECT_KUNGFU or (RT_SELECT_KUNGFU and v.dwMountKungfuID == RT_SELECT_KUNGFU) then
			local szName = 'P' .. v.dwID
			local h = page.hList:Lookup(szName)
			if not h then
				h = page.hList:AppendItemFromData(page.hPlayer)
			end
			h:SetUserData(k)
			h:SetName(szName)
			h.dwID   = v.dwID
			h.szName = v.szName
			-- �ķ�����
			if v.dwMountKungfuID and v.dwMountKungfuID ~= 0 then
				local nIcon = select(2, MY_GetSkillName(v.dwMountKungfuID, 1))
				h:Lookup('Image_Icon'):FromIconID(nIcon)
			else
				h:Lookup('Image_Icon'):FromUITex(GetForceImage(v.dwForceID))
			end
			h:Lookup('Text_Name'):SetText(v.szName)
			h:Lookup('Text_Name'):SetFontColor(LIB.GetForceColor(v.dwForceID))
			-- ҩƷ��BUFF
			if not h['hHandle_Food'] then
				h['hHandle_Food'] = {
					self = h:Lookup('Handle_Food'),
					Pool = UI.HandlePool(h:Lookup('Handle_Food'), '<box>w=29 h=29 eventid=784</box>')
				}
			end
			if not h['hHandle_Equip'] then
				h['hHandle_Equip'] = {
					self = h:Lookup('Handle_Equip'),
					Pool = UI.HandlePool(h:Lookup('Handle_Equip'), '<box>w=29 h=29 eventid=784</box>')
				}
			end
			local hBuff = h:Lookup('Box_Buff')
			local hBox = h:Lookup('Box_Grandpa')
			if not v.bIsOnLine then
				h.hHandle_Equip.Pool:Clear()
				h:Lookup('Text_Toofar1'):Show()
				h:Lookup('Text_Toofar1'):SetText(g_tStrings.STR_GUILD_OFFLINE)
			end
			if not v.KPlayer then
				h.hHandle_Food.Pool:Clear()
				h:Lookup('Text_Toofar1'):Show()
				if v.bIsOnLine then
					h:Lookup('Text_Toofar1'):SetText(_L['Too far'])
				end
				hBuff:Hide()
				hBox:Hide()
			else
				hBuff:Show()
				hBox:Show()
				h:Lookup('Text_Toofar1'):Hide()
				-- СҩUI����
				local handle_food = h.hHandle_Food.self
				for kk, vv in ipairs(v.tFood) do
					local szName = vv.dwID .. '_' .. vv.nLevel
					local nIcon = select(2, MY_GetBuffName(vv.dwID, vv.nLevel))
					local box = handle_food:Lookup(szName)
					if not box then
						box = h.hHandle_Food.Pool:New()
					end
					box:SetName(szName)
					box:SetObject(UI_OBJECT_NOT_NEED_KNOWN, vv.dwID, vv.nLevel, vv.nEndFrame)
					box:SetObjectIcon(nIcon)
					box.OnItemRefreshTip = function()
						local dwID, nLevel, nEndFrame = select(2, this:GetObject())
						local nTime = (nEndFrame - GetLogicFrameCount()) / 16
						local x, y = this:GetAbsPos()
						local w, h = this:GetSize()
						LIB.OutputBuffTip({ x, y, w, h }, dwID, nLevel, nTime)
					end
					local nTime = (vv.nEndFrame - GetLogicFrameCount()) / 16
					if nTime < 480 then
						box:SetAlpha(80)
					else
						box:SetAlpha(255)
					end
					box:Show()
				end
				for i = 0, handle_food:GetItemCount() - 1, 1 do
					local item = handle_food:Lookup(i)
					if item and not item.bFree then
						local dwID, nLevel, nEndFrame = select(2, item:GetObject())
						if dwID and nLevel then
							if not LIB.GetBuff(v.KPlayer, dwID, nLevel) then
								h.hHandle_Food.Pool:Remove(item)
							end
						end
					end
				end
				handle_food:FormatAllItemPos()
				-- BUFF UI����
				if v.tBuff and #v.tBuff > 0 then
					hBuff:EnableObject(true)
					hBuff:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
					hBuff:SetOverTextFontScheme(1, 197)
					hBuff:SetOverText(1, #v.tBuff)
					hBuff.OnItemMouseEnter = function()
						local x, y = this:GetAbsPos()
						local w, h = this:GetSize()
						local xml = {}
						for k, v in ipairs(v.tBuff) do
							local nIcon = select(2, MY_GetBuffName(v.dwID, v.nLevel))
							local nTime = (v.nEndFrame - GetLogicFrameCount()) / 16
							local nAlpha = nTime < 600 and 80 or 255
							insert(xml, '<image> path="fromiconid" frame=' .. nIcon ..' alpha=' .. nAlpha ..  ' w=30 h=30 </image>')
						end
						OutputTip(concat(xml), 250, { x, y, w, h })
					end
				else
					hBuff:SetOverText(1, '')
					hBuff:EnableObject(false)
				end
				if v.bGrandpa then
					hBox:EnableObject(true)
					hBox.OnItemMouseEnter = function()
						local x, y = this:GetAbsPos()
						local w, h = this:GetSize()
						local kBuff = LIB.GetBuff(v.KPlayer, RT_GONGZHAN_ID)
						if kBuff then
							LIB.OutputBuffTip({ x, y, w, h }, kBuff.dwID, kBuff.nLevel)
						end
					end
				end
				hBox:EnableObject(v.bGrandpa)
			end
			-- ҩƷ����ħ
			if v.tTemporaryEnchant and #v.tTemporaryEnchant > 0 then
				local vv = v.tTemporaryEnchant[1]
				local box = h:Lookup('Box_Enchant')
				box:Show()
				if vv.CommonEnchant then
					box:SetObjectIcon(6216)
				else
					box:SetObjectIcon(7577)
				end
				box.OnItemRefreshTip = function()
					local x, y = this:GetAbsPos()
					local w, h = this:GetSize()
					local desc = ''
					if vv.CommonEnchant then
						desc = LIB.Table_GetCommonEnchantDesc(vv.dwTemporaryEnchantID)
					else
						-- ... �ٷ����̫�鷳��
						local tEnchant = GetItemEnchantAttrib(vv.dwTemporaryEnchantID)
						if tEnchant then
							for kkk, vvv in pairs(tEnchant) do
								if vvv.nID == ATTRIBUTE_TYPE.SKILL_EVENT_HANDLER then -- ATTRIBUTE_TYPE.SKILL_EVENT_HANDLER
									local skillEvent = g_tTable.SkillEvent:Search(vvv.nValue1)
									if skillEvent then
										desc = desc .. FormatString(skillEvent.szDesc, vvv.nValue1, vvv.nValue2)
									else
										desc = desc .. '<text>text="unknown skill event id:'.. vvv.nValue1..'"</text>'
									end
								elseif vvv.nID == ATTRIBUTE_TYPE.SET_EQUIPMENT_RECIPE then -- ATTRIBUTE_TYPE.SET_EQUIPMENT_RECIPE
									local tRecipeSkillAtrri = g_tTable.EquipmentRecipe:Search(vvv.nValue1, vvv.nValue2)
									if tRecipeSkillAtrri then
										desc = desc .. tRecipeSkillAtrri.szDesc
									end
								else
									if Table_GetMagicAttributeInfo then
										desc = desc .. FormatString(Table_GetMagicAttributeInfo(vvv.nID, true), vvv.nValue1, vvv.nValue2, 0, 0)
									else
										desc = GetFormatText('Enchant Attrib value ' .. vvv.nValue1 .. ' ', 113)
									end
								end

							end
						end
					end
					if desc and #desc > 0 then
						OutputTip(desc:gsub('font=%d+', 'font=113') .. GetFormatText(FormatString(g_tStrings.STR_ITEM_TEMP_ECHANT_LEFT_TIME ..'\n', GetTimeText(vv.nTemporaryEnchantLeftSeconds)), 102), 400, { x, y, w, h })
					end
				end
				if vv.nTemporaryEnchantLeftSeconds < 480 then
					box:SetAlpha(80)
				else
					box:SetAlpha(255)
				end
			else
				h:Lookup('Box_Enchant'):Hide()
			end
			-- װ��
			if v.tEquip and #v.tEquip > 0 then
				local handle_equip = h.hHandle_Equip.self
				for kk, vv in ipairs(v.tEquip) do

					local szName = tostring(vv.nUiId)
					local box = handle_equip:Lookup(szName)
					if not box then
						box = h.hHandle_Equip.Pool:New()
						LIB.UpdateItemBoxExtend(box, vv.nQuality)
					end
					box:SetName(szName)
					box:SetObject(UI_OBJECT_OTER_PLAYER_ITEM, vv.nUiId, vv.dwBox, vv.dwX, v.dwID)
					box:SetObjectIcon(vv.nIcon)
					local item = GetItem(vv.dwID)
					if item then
						UpdataItemBoxObject(box, vv.dwBox, vv.dwX, item, nil, nil, v.dwID)
					end
					box.OnItemRefreshTip = function()
						local x, y = this:GetAbsPos()
						local w, h = this:GetSize()
						if not GetItem(vv.dwID) then
							D.GetTotalEquipScore(page, v.dwID)
							OutputItemTip(UI_OBJECT_ITEM_INFO, GLOBAL.CURRENT_ITEM_VERSION, vv.dwTabType, vv.dwIndex, {x, y, w, h})
						else
							OutputItemTip(UI_OBJECT_ITEM_ONLY_ID, vv.dwID, nil, nil, { x, y, w, h })
						end
					end
					box:Show()
				end
				for i = 0, handle_equip:GetItemCount() - 1, 1 do
					local item = handle_equip:Lookup(i)
					if item and not item.bFree then
						local nUiId, bDelete = item:GetName(), true
						for kk ,vv in ipairs(v.tEquip) do
							if tostring(vv.nUiId) == nUiId then
								bDelete = false
								break
							end
						end
						if bDelete then
							h.hHandle_Equip.Pool:Remove(item)
						end
					end
				end
				handle_equip:FormatAllItemPos()
			end
			-- װ����
			local hScore = h:Lookup('Text_Score')
			if v.nEquipScore then
				hScore:SetText(v.nEquipScore)
			else
				if v.bIsOnLine then
					hScore:SetText(_L['Loading'])
				else
					hScore:SetText(g_tStrings.STR_GUILD_OFFLINE)
				end
			end
			-- �ؾ�CD
			if not h.hHandle_BossKills then
				h.hHandle_BossKills = {
					self = h:Lookup('Handle_BossKills'),
					Pool = UI.HandlePool(h:Lookup('Handle_BossKills'), '<handle>postype=8 eventid=784 w=16 h=14 <image>name="Image_BossKilled" w=14 h=14 path="ui/Image/UITga/FBcdPanel01.UITex" frame=20</image><image>name="Image_BossAlive" w=14 h=14 path="ui/Image/UITga/FBcdPanel01.UITex" frame=21</image></handle>')
				}
			end
			local hCopyID = h:Lookup('Text_CopyID')
			local hBossKills = h:Lookup('Handle_BossKills')
			if LIB.IsDungeonRoleProgressMap(RT_MAPID) then
				for nIndex, bKill in ipairs(v.tBossKill) do
					local szName = tostring(nIndex)
					local hBossKill = hBossKills:Lookup(szName)
					if not hBossKill then
						hBossKill = h.hHandle_BossKills.Pool:New()
						hBossKill:SetName(szName)
					end
					hBossKill:Lookup('Image_BossAlive'):SetVisible(not bKill)
					hBossKill:Lookup('Image_BossKilled'):SetVisible(bKill)
					hBossKill.OnItemRefreshTip = function()
						local x, y = this:GetAbsPos()
						local w, h = this:GetSize()
						local texts = {}
						for i, boss in ipairs(Table_GetCDProcessBoss(RT_MAPID)) do
							insert(texts, boss.szName .. '\t' .. _L[v.tBossKill[i] and 'x' or 'r'])
						end
						OutputTip(GetFormatText(concat(texts, '\n')), 400, { x, y, w, h })
					end
					hBossKill:Show()
				end
				for i = 0, hBossKills:GetItemCount() - 1, 1 do
					local item = hBossKills:Lookup(i)
					if item and not item.bFree then
						if tonumber(item:GetName()) > #v.tBossKill then
							h.hHandle_BossKills.Pool:Remove(item)
						end
					end
				end
				hBossKills:FormatAllItemPos()
				hCopyID:Hide()
				hBossKills:Show()
			else
				hCopyID:SetText(v.nCopyID == -1 and _L['None'] or v.nCopyID or _L['Unknown'])
				hCopyID:Show()
				hBossKills:Hide()
			end
			-- ս��״̬
			if v.nFightState == 1 then
				h:Lookup('Image_Fight'):Show()
			else
				h:Lookup('Image_Fight'):Hide()
			end
		end
	end
	page.hList:FormatAllItemPos()
	for i = 0, page.hList:GetItemCount() - 1, 1 do
		local item = page.hList:Lookup(i)
		if item and item:IsValid() then
			if not MY_IsParty(item.dwID) and item.dwID ~= me.dwID then
				page.hList:RemoveItem(item)
				page.hList:FormatAllItemPos()
			end
		end
	end
	-- ����
	page.tScore = tScore
	local nScore = 0
	for k, v in pairs(tScore) do
		nScore = nScore + v
	end
	page.hTotalScore:SetText(floor(nScore))
	local nNum      = #D.GetTeamMemberList(true)
	local nAvgScore = nScore / nNum
	page.hProgress:Lookup('Image_Progress'):SetPercentage(nAvgScore / RT_SCORE_FULL)
	page.hProgress:Lookup('Text_Progress'):SetText(_L('Team strength(%d/%d)', floor(nAvgScore), RT_SCORE_FULL))
	-- �ķ�ͳ��
	for k, dwKungfuID in pairs(LIB.GetKungfuIDS()) do
		local h = page.hKungfuList:Lookup(k - 1)
		local img = h:Lookup('Image_Force')
		local nCount = 0
		if tKungfu[dwKungfuID] then
			nCount = #tKungfu[dwKungfuID]
		end
		local szName, nIcon = MY_GetSkillName(dwKungfuID)
		img:FromIconID(nIcon)
		h:Lookup('Text_Num'):SetText(nCount)
		if not tKungfu[dwKungfuID] then
			h:SetAlpha(60)
			h.OnItemMouseEnter = nil
		else
			h:SetAlpha(255)
			h.OnItemMouseEnter = function()
				this:Lookup('Text_Num'):SetFontScheme(101)
				local xml = {}
				insert(xml, GetFormatText(szName .. g_tStrings.STR_COLON .. nCount .. g_tStrings.STR_PERSON ..'\n', 157))
				sort(tKungfu[dwKungfuID], function(a, b)
					local nCountA = a.nEquipScore or -1
					local nCountB = b.nEquipScore or -1
					return nCountA > nCountB
				end)
				for k, v in ipairs(tKungfu[dwKungfuID]) do
					if v.nEquipScore then
						insert(xml, GetFormatText(v.szName .. g_tStrings.STR_COLON ..  v.nEquipScore  ..'\n', 106))
					else
						insert(xml, GetFormatText(v.szName ..'\n', 106))
					end
				end
				local x, y = img:GetAbsPos()
				local w, h = img:GetSize()
				OutputTip(concat(xml), 400, { x, y, w, h })
			end
		end
	end
end

local function CreateItemTable(item, dwBox, dwX)
	return {
		nIcon     = LIB.GetItemIconByUIID(item.nUiId),
		dwID      = item.dwID,
		nLevel    = item.nLevel,
		szName    = LIB.GetItemNameByUIID(item.nUiId),
		nUiId     = item.nUiId,
		nVersion  = item.nVersion,
		dwTabType = item.dwTabType,
		dwIndex   = item.dwIndex,
		nQuality  = item.nQuality,
		dwBox     = dwBox,
		dwX       = dwX
	}
end

function D.GetEquipCache(page, KPlayer)
	if not KPlayer then
		return
	end
	local me = GetClientPlayer()
	local aInfo = {
		tEquip            = {},
		tPermanentEnchant = {},
		tTemporaryEnchant = {}
	}
	-- װ�� Output(GetClientPlayer().GetItem(0,0).GetMagicAttrib())
	for _, equip in ipairs(RT_EQUIP_TOTAL) do
		-- if #aInfo.tEquip >= 3 then break end
		-- �ؽ�ֻ���ؽ�
		if KPlayer.dwForceID == 8 and CONSTANT.EQUIPMENT_INVENTORY[equip] == CONSTANT.EQUIPMENT_INVENTORY.MELEE_WEAPON then
			equip = 'BIG_SWORD'
		end
		local dwBox, dwX = INVENTORY_INDEX.EQUIP, CONSTANT.EQUIPMENT_INVENTORY[equip]
		local item = KPlayer.GetItem(dwBox, dwX)
		if item then
			if RT_EQUIP_SPECIAL[equip] then
				if equip == 'PENDANT' then
					local desc = Table_GetItemDesc(item.nUiId)
					if desc and (desc:find(_L['use'] .. g_tStrings.STR_COLON) or desc:find(_L['Use:']) or desc:find('15' .. g_tStrings.STR_TIME_SECOND)) then
						insert(aInfo.tEquip, CreateItemTable(item, dwBox, dwX))
					end
				-- elseif item.nQuality == 5 then -- ��ɫװ��
				-- 	insert(aInfo.tEquip, CreateItemTable(item))
				else
					-- ����װ��
					local aMagicAttrib = item.GetMagicAttrib()
					for _, tAttrib in ipairs(aMagicAttrib) do
						if tAttrib.nID == ATTRIBUTE_TYPE.SKILL_EVENT_HANDLER then
							insert(aInfo.tEquip, CreateItemTable(item, dwBox, dwX))
							break
						end
					end
				end
			end
			-- ���õĸ�ħ ��������
			if item.dwPermanentEnchantID and item.dwPermanentEnchantID ~= 0 then
				insert(aInfo.tPermanentEnchant, {
					dwPermanentEnchantID = item.dwPermanentEnchantID,
				})
			end
			-- ��ħ / ��ʱ��ħ ��������
			if item.dwTemporaryEnchantID and item.dwTemporaryEnchantID ~= 0 then
				local dat = {
					dwTemporaryEnchantID         = item.dwTemporaryEnchantID,
					nTemporaryEnchantLeftSeconds = item.GetTemporaryEnchantLeftSeconds()
				}
				if LIB.Table_GetCommonEnchantDesc(item.dwTemporaryEnchantID) then
					dat.CommonEnchant = true
				end
				insert(aInfo.tTemporaryEnchant, dat)
			end
		end
	end
	-- ��Щ����һ���ԵĻ�������
	page.tDataCache[KPlayer.dwID] = {
		tEquip            = aInfo.tEquip,
		tPermanentEnchant = aInfo.tPermanentEnchant,
		tTemporaryEnchant = aInfo.tTemporaryEnchant,
		nEquipScore       = KPlayer.GetTotalEquipScore()
	}
	page.tViewInvite[KPlayer.dwID] = nil
	if IsEmpty(page.tViewInvite) then
		if KPlayer.dwID ~= me.dwID then
			FireUIEvent('MY_RAIDTOOLS_SUCCESS') -- װ���������
		end
	else
		ViewInviteToPlayer(next(page.tViewInvite), true)
	end
end

function D.GetTotalEquipScore(page, dwID)
	if not page.tViewInvite[dwID] then
		page.tViewInvite[dwID] = true
		ViewInviteToPlayer(dwID, true)
	end
end

function D.UpdateSelfData()
	local dwMapID = RT_MAPID
	local dwID = UI_GetClientPlayerID()
	local function fnAction(tMapID)
		local aCopyID = tMapID[dwMapID]
		if not RT_PLAYER_MAP_COPYID[dwID] then
			RT_PLAYER_MAP_COPYID[dwID] = {}
		end
		RT_PLAYER_MAP_COPYID[dwID][dwMapID] = IsTable(aCopyID) and aCopyID[1] or -1
		FireUIEvent('MY_TEAMTOOLS_SUMMARY')
	end
	LIB.GetMapSaveCopy(fnAction)
end

function D.RequestTeamData()
	local me = GetClientPlayer()
	if not me then
		return
	end
	local aRequestID, aRefreshID = {}, {}
	local bDungeonMap = LIB.IsDungeonMap(RT_MAPID)
	local bIsDungeonRoleProgressMap = LIB.IsDungeonRoleProgressMap(RT_MAPID)
	--[[#DEBUG BEGIN]]
	if bIsDungeonRoleProgressMap then
		LIB.Debug(PACKET_INFO.NAME_SPACE, 'Update team map progress.', DEBUG_LEVEL.LOG)
	end
	--[[#DEBUG END]]
	local aTeamMemberList = D.GetTeamMemberList(true)
	for _, dwID in ipairs(aTeamMemberList) do
		if bIsDungeonRoleProgressMap then -- �ؾ�����
			ApplyDungeonRoleProgress(RT_MAPID, dwID) -- �ɹ��ص� UPDATE_DUNGEON_ROLE_PROGRESS(dwMapID, dwPlayerID)
		elseif bDungeonMap then -- �ؾ�CDID
			if not RT_PLAYER_MAP_COPYID[dwID] then
				RT_PLAYER_MAP_COPYID[dwID] = {}
			end
			if RT_PLAYER_MAP_COPYID[dwID][RT_MAPID] then
				insert(aRefreshID, dwID)
			else
				insert(aRequestID, dwID)
			end
		end
	end
	if not IsEmpty(aRequestID) or not IsEmpty(aRefreshID) then
		--[[#DEBUG BEGIN]]
		LIB.Debug(PACKET_INFO.NAME_SPACE, 'Request team map copy id.', DEBUG_LEVEL.LOG)
		--[[#DEBUG END]]
		if #aRequestID == #aTeamMemberList then
			aRequestID = nil
		end
		if LIB.IsSafeLocked(SAFE_LOCK_EFFECT_TYPE.TALK) then
			LIB.Systopmsg(_L['Fetch teammate\'s data failed, please unlock talk and reopen.'])
		else
			LIB.SendBgMsg(PLAYER_TALK_CHANNEL.RAID, 'MY_MAP_COPY_ID_REQUEST', {RT_MAPID, aRequestID, nil})
		end
	end
	-- ˢ���Լ���
	D.UpdateSelfData()
end

-- ��ȡ�ŶӴ󲿷���� �ǻ���
function D.GetTeam(page)
	local me    = GetClientPlayer()
	local team  = GetClientTeam()
	local aList = {}
	local bIsInParty = LIB.IsInParty()
	local bIsDungeonRoleProgressMap = LIB.IsDungeonRoleProgressMap(RT_MAPID)
	local aProgressMapBoss = bIsDungeonRoleProgressMap and Table_GetCDProcessBoss(RT_MAPID)
	local aRequestMapCopyID = {}
	local aTeamMemberList = D.GetTeamMemberList()
	for _, dwID in ipairs(aTeamMemberList) do
		local KPlayer = GetPlayer(dwID)
		local info = bIsInParty and team.GetMemberInfo(dwID) or {}
		local aInfo = {
			KPlayer           = KPlayer,
			szName            = KPlayer and KPlayer.szName or info.szName or _L['Loading...'],
			dwID              = dwID,  -- ID
			dwForceID         = KPlayer and KPlayer.dwForceID or info.dwForceID, -- ����ID
			dwMountKungfuID   = info and info.dwMountKungfuID or UI_GetPlayerMountKungfuID(), -- �ڹ�
			-- tPermanentEnchant = {}, -- ��ħ
			-- tTemporaryEnchant = {}, -- ��ʱ��ħ
			-- tEquip            = {}, -- ��Чװ��
			tBuff             = {}, -- ����BUFF
			tFood             = {}, -- С�Ժ͸�ħ
			-- nEquipScore       = -1,  -- װ����
			nCopyID           = RT_PLAYER_MAP_COPYID[dwID] and RT_PLAYER_MAP_COPYID[dwID][RT_MAPID], -- �ؾ�ID
			tBossKill         = {}, -- �ؾ�����
			nFightState       = KPlayer and KPlayer.bFightState and 1 or 0, -- ս��״̬
			bIsOnLine         = true,
			bGrandpa          = false, -- ��ү
		}
		if info and info.bIsOnLine ~= nil then
			aInfo.bIsOnLine = info.bIsOnLine
		end
		if KPlayer then
			-- С�Ժ�buff
			local aBuff, nCount, buff, nType = LIB.GetBuffList(KPlayer)
			for i = 1, nCount do
				buff = aBuff[i]
				nType = GetBuffInfo(buff.dwID, buff.nLevel, {}).nDetachType or 0
				if RT_FOOD_TYPE[nType] then
					insert(aInfo.tFood, buff)
				end
				if RT_BUFF_ID[buff.dwID] then
					insert(aInfo.tBuff, buff)
				end
				if buff.dwID == RT_GONGZHAN_ID then -- grandpa
					aInfo.bGrandpa = true
				end
			end
			if me.dwID == KPlayer.dwID then
				D.GetEquipCache(page, me)
			end
		end
		-- �ؾ�����
		if aInfo.bIsOnLine and bIsDungeonRoleProgressMap then
			for i, boss in ipairs(aProgressMapBoss) do
				aInfo.tBossKill[i] = GetDungeonRoleProgress(RT_MAPID, dwID, boss.dwProgressID)
			end
		end
		setmetatable(aInfo, { __index = page.tDataCache[dwID] })
		insert(aList, aInfo)
	end
	return aList
end

function D.GetEquip(page)
	local hView = D.GetPlayerView()
	if hView and hView:IsVisible() then -- �鿴װ����ʱ��ֹͣ����
		return
	end
	local me = GetClientPlayer()
	if not me then
		return
	end
	local team = GetClientTeam()
	for k, v in ipairs(D.GetTeamMemberList()) do
		if v ~= me.dwID then
			local info = team.GetMemberInfo(v)
			if info.bIsOnLine then
				D.GetTotalEquipScore(page, v)
			end
		end
	end
end

-- ��ȡ�Ŷӳ�Ա�б�
function D.GetTeamMemberList(bIsOnLine)
	local me   = GetClientPlayer()
	local team = GetClientTeam()
	if me.IsInParty() then
		if bIsOnLine then
			local tTeam = {}
			for k, v in ipairs(team.GetTeamMemberList()) do
				local info = team.GetMemberInfo(v)
				if info and info.bIsOnLine then
					insert(tTeam, v)
				end
			end
			return tTeam
		else
			return team.GetTeamMemberList()
		end
	else
		return { me.dwID }
	end
end

function D.SetMapID(dwMapID)
	if RT_MAPID == dwMapID then
		return
	end
	RT_MAPID = dwMapID
	FireUIEvent('MY_RAIDTOOLS_MAPID_CHANGE')
end

LIB.RegisterEvent('LOADING_END', function()
	D.SetMapID(GetClientPlayer().GetMapID())
end)

LIB.RegisterBgMsg('MY_MAP_COPY_ID', function(_, data, nChannel, dwID, szName, bIsSelf)
	local dwMapID, aCopyID = data[1], data[2]
	if not RT_PLAYER_MAP_COPYID[dwID] then
		RT_PLAYER_MAP_COPYID[dwID] = {}
	end
	RT_PLAYER_MAP_COPYID[dwID][dwMapID] = IsTable(aCopyID) and aCopyID[1] or -1
	FireUIEvent('MY_TEAMTOOLS_SUMMARY')
end)

function D.OnInitPage()
	local frameTemp = Wnd.OpenWindow(SZ_INI, 'MY_TeamTools_Summary')
	local wnd = frameTemp:Lookup('Wnd_Summary')
	wnd:ChangeRelation(this, true, true)
	Wnd.CloseWindow(frameTemp)

	local page = this
	local frame = page:GetRoot()
	frame:RegisterEvent('PEEK_OTHER_PLAYER')
	frame:RegisterEvent('PARTY_ADD_MEMBER')
	frame:RegisterEvent('PARTY_DISBAND')
	frame:RegisterEvent('PARTY_DELETE_MEMBER')
	frame:RegisterEvent('PARTY_SET_MEMBER_ONLINE_FLAG')
	frame:RegisterEvent('ON_APPLY_PLAYER_SAVED_COPY_RESPOND')
	frame:RegisterEvent('UPDATE_DUNGEON_ROLE_PROGRESS')
	frame:RegisterEvent('LOADING_END')
	-- �ų���� ���������ǩ
	frame:RegisterEvent('TEAM_AUTHORITY_CHANGED')
	-- �Զ����¼�
	frame:RegisterEvent('MY_TEAMTOOLS_SUMMARY')
	frame:RegisterEvent('MY_RAIDTOOLS_SUCCESS')
	frame:RegisterEvent('MY_RAIDTOOLS_DEATH')
	frame:RegisterEvent('MY_RAIDTOOLS_ENTER_MAP')
	frame:RegisterEvent('MY_RAIDTOOLS_MAPID_CHANGE')
	-- �����ķ�ѡ��
	RT_SELECT_KUNGFU = nil
	page.hPlayer = frame:CreateItemData(SZ_INI, 'Handle_Item_Player')
	page.hList = page:Lookup('Wnd_Summary/Scroll_Player', '')

	this.tScore = {}
	-- ����
	local hTitle = page:Lookup('Wnd_Summary', 'Handle_Player_BG')
	for k, v in ipairs({'dwForceID', 'tFood', 'tBuff', 'tEquip', 'nEquipScore', 'tBossKill', 'nFightState'}) do
		local txt = hTitle:Lookup('Text_Title_' .. k)
		txt.nFont = txt:GetFontScheme()
		txt.OnItemMouseEnter = function()
			this:SetFontScheme(101)
		end
		txt.OnItemMouseLeave = function()
			this:SetFontScheme(this.nFont)
		end
		txt.OnItemLButtonClick = function()
			if v == RT_SORT_FIELD then
				RT_SORT_MODE = RT_SORT_MODE == 'ASC' and 'DESC' or 'ASC'
			else
				RT_SORT_MODE = 'DESC'
			end
			RT_SORT_FIELD = v
			D.UpdateList(page) -- set userdata
			page.hList:Sort()
			page.hList:FormatAllItemPos()
		end
	end
	-- װ����
	this.hTotalScore = page:Lookup('Wnd_Summary', 'Handle_Score/Text_TotalScore')
	this.hProgress   = page:Lookup('Wnd_Summary', 'Handle_Progress')
	-- �ؾ���Ϣ
	local hDungeon = page:Lookup('Wnd_Summary', 'Handle_Dungeon')
	D.UpdateDungeonInfo(hDungeon)
	this.hKungfuList = page:Lookup('Wnd_Summary', 'Handle_Kungfu/Handle_Kungfu_List')
	this.hKungfu     = frame:CreateItemData(SZ_INI, 'Handle_Kungfu_Item')
	this.hKungfuList:Clear()
	for k, dwKungfuID in pairs(LIB.GetKungfuIDS()) do
		local h = this.hKungfuList:AppendItemFromData(this.hKungfu, dwKungfuID)
		local img = h:Lookup('Image_Force')
		img:FromIconID(select(2, MY_GetSkillName(dwKungfuID)))
		h:Lookup('Text_Num'):SetText(0)
		h.nFont = h:Lookup('Text_Num'):GetFontScheme()
		h.OnItemMouseLeave = function()
			HideTip()
			if RT_SELECT_KUNGFU == tonumber(this:GetName()) then
				this:Lookup('Text_Num'):SetFontScheme(101)
			else
				this:Lookup('Text_Num'):SetFontScheme(h.nFont)
			end
		end
		h.OnItemLButtonClick = function()
			if this:GetAlpha() ~= 255 then
				return
			end
			page.hList:Clear()
			if RT_SELECT_KUNGFU then
				if RT_SELECT_KUNGFU == tonumber(this:GetName()) then
					RT_SELECT_KUNGFU = nil
					h:Lookup('Text_Num'):SetFontScheme(101)
					return D.UpdateList(page)
				else
					local h = this:GetParent():Lookup(tostring(RT_SELECT_KUNGFU))
					h:Lookup('Text_Num'):SetFontScheme(h.nFont)
				end
			end
			RT_SELECT_KUNGFU = tonumber(this:GetName())
			this:Lookup('Text_Num'):SetFontScheme(101)
			D.UpdateList(page)
		end
	end
	this.hKungfuList:FormatAllItemPos()
	-- ui ��ʱ����
	this.tViewInvite = {} -- ����װ������
	this.tDataCache  = {} -- ��ʱ����
	-- lang
	page:Lookup('Wnd_Summary', 'Handle_Player_BG/Text_Title_3'):SetText(_L['BUFF'])
	page:Lookup('Wnd_Summary', 'Handle_Player_BG/Text_Title_4'):SetText(_L['Equip'])
	page:Lookup('Wnd_Summary', 'Handle_Player_BG/Text_Title_6'):SetText(_L['Dungeon CD'])
	page:Lookup('Wnd_Summary', 'Handle_Player_BG/Text_Title_7'):SetText(_L['Fight'])
end

function D.OnActivePage()
	local hView = D.GetPlayerView()
	if hView and hView:IsVisible() then
		hView:Hide()
	end
	LIB.BreatheCall('MY_RaidTools_Draw', 1000, D.UpdateList, this)
	LIB.BreatheCall('MY_RaidTools_GetEquip', 3000, D.GetEquip, this)
	LIB.BreatheCall('MY_RaidTools_RequestTeamData', 30000, D.RequestTeamData, this)
end

function D.OnDeactivePage()
	LIB.BreatheCall('MY_RaidTools_Draw', false)
	LIB.BreatheCall('MY_RaidTools_GetEquip', false)
	LIB.BreatheCall('MY_RaidTools_RequestTeamData', false)
end

function D.OnEvent(szEvent)
	if szEvent == 'MY_TEAMTOOLS_SUMMARY' then
		D.UpdateList(this)
	elseif szEvent == 'UPDATE_DUNGEON_ROLE_PROGRESS' then
		D.UpdateList(this)
	elseif szEvent == 'PEEK_OTHER_PLAYER' then
		if arg0 == CONSTANT.PEEK_OTHER_PLAYER_RESPOND.SUCCESS then
			if this.tViewInvite[arg1] then
				D.GetEquipCache(this, GetPlayer(arg1)) -- ץȡ��������
			end
		else
			this.tViewInvite[arg1] = nil
		end
	elseif szEvent == 'PARTY_SET_MEMBER_ONLINE_FLAG' then
		if arg2 == 0 then
			this.tDataCache[arg1] = nil
		end
	elseif szEvent == 'PARTY_DELETE_MEMBER' then
		local me = GetClientPlayer()
		if me.dwID == arg1 then
			this.tDataCache = {}
			this.hList:Clear()
		else
			this.tDataCache[arg1] = nil
		end
	elseif szEvent == 'LOADING_END' or szEvent == 'PARTY_DISBAND' then
		this.tDataCache = {}
		this.hList:Clear()
		-- �ؾ���Ϣ
		local hDungeon = this:Lookup('Wnd_Summary', 'Handle_Dungeon')
		D.UpdateDungeonInfo(hDungeon)
	elseif szEvent == 'MY_RAIDTOOLS_MAPID_CHANGE' then
		D.RequestTeamData() -- ��ͼ�仯ˢ��
		local hDungeon = this:Lookup('Wnd_Summary', 'Handle_Dungeon')
		D.UpdateDungeonInfo(hDungeon)
	elseif szEvent == 'ON_APPLY_PLAYER_SAVED_COPY_RESPOND' then
		local hDungeon = this:Lookup('Wnd_Summary', 'Handle_Dungeon')
		D.UpdateDungeonInfo(hDungeon)
	elseif szEvent == 'MY_RAIDTOOLS_SUCCESS' then
		if RT_SORT_FIELD == 'nEquipScore' then
			D.UpdateList(this)
			this.hList:Sort()
			this.hList:FormatAllItemPos()
		end
	end
end

function D.OnLButtonClick()
end

function D.OnItemMouseEnter()
	local szName = this:GetName()
	if this:GetType() == 'Box' then
		this:SetObjectMouseOver(true)
	elseif szName == 'Handle_Score' then
		local img = this:Lookup('Image_Score')
		img:SetFrame(23)
		local nScore = this:Lookup('Text_TotalScore'):GetText()
		local xml = {}
		insert(xml, GetFormatText(g_tStrings.STR_SCORE .. g_tStrings.STR_COLON .. nScore ..'\n', 65))
		for k, v in pairs(this:GetParent():GetParent():GetParent().tScore) do
			insert(xml, GetFormatText(RT_SCORE[k] .. g_tStrings.STR_COLON, 67))
			insert(xml, GetFormatText(v ..'\n', 44))
		end
		local x, y = img:GetAbsPos()
		local w, h = img:GetSize()
		OutputTip(concat(xml), 400, { x, y, w, h })
	end
end

function D.OnItemMouseLeave()
	local szName = this:GetName()
	if this:GetType() == 'Box' then
		this:SetObjectMouseOver(false)
	elseif szName == 'Handle_Score' then
		this:Lookup('Image_Score'):SetFrame(22)
	end
	HideTip()
end

function D.OnItemLButtonClick()
	local szName = this:GetName()
	if szName == 'Handle_Dungeon' then
		local menu = LIB.GetDungeonMenu(function(p) D.SetMapID(p.dwID) end)
		menu.x, menu.y = Cursor.GetPos(true)
		PopupMenu(menu)
	elseif tonumber(szName:find('P(%d+)')) then
		local dwID = tonumber(szName:match('P(%d+)'))
		if IsCtrlKeyDown() then
			LIB.EditBox_AppendLinkPlayer(this.szName)
		else
			D.ViewInviteToPlayer(this:GetParent():GetParent():GetParent():GetParent(), dwID)
		end
	end
end

function D.OnItemRButtonClick()
	local szName = this:GetName()
	local dwID = tonumber(szName:match('P(%d+)'))
	local me = GetClientPlayer()
	if dwID and dwID ~= me.dwID then
		local page = this:GetParent():GetParent():GetParent():GetParent()
		local menu = {
			{ szOption = this.szName, bDisable = true },
			{ bDevide = true }
		}
		InsertPlayerCommonMenu(menu, dwID, this.szName)
		menu[#menu] = {
			szOption = g_tStrings.STR_LOOKUP, fnAction = function()
				D.ViewInviteToPlayer(page, dwID)
			end
		}
		local t = {}
		InsertTargetMenu(t, dwID)
		for _, v in ipairs(t) do
			if v.szOption == g_tStrings.LOOKUP_INFO then
				for _, vv in ipairs(v) do
					if vv.szOption == g_tStrings.LOOKUP_NEW_TANLENT then
						insert(menu, vv)
						break
					end
				end
				break
			end
		end
		if MY_CharInfo and MY_CharInfo.ViewCharInfoToPlayer then
			menu[#menu + 1] = {
				szOption = g_tStrings.STR_LOOK .. g_tStrings.STR_EQUIP_ATTR, fnAction = function()
					MY_CharInfo.ViewCharInfoToPlayer(dwID)
				end
			}
		end
		PopupMenu(menu)
	end
end

-- Module exports
do
local settings = {
	exports = {
		{
			fields = {
				OnInitPage = D.OnInitPage,
				OnDeactivePage = D.OnDeactivePage,
			},
		},
		{
			root = D,
			preset = 'UIEvent'
		},
	},
}
MY_TeamTools.RegisterModule('Summary', _L['MY_TeamTools_Summary'], LIB.GeneGlobalNS(settings))
end

-- Global exports
do
local settings = {
	exports = {
		{
			fields = {
			},
		},
	},
}
MY_TeamTools_Summary = LIB.GeneGlobalNS(settings)
end
