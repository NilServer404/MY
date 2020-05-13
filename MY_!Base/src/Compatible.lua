--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : �������������ȫ�ֺ���
-- @author   : ���� @˫���� @׷����Ӱ
-- @modifier : Emil Zhai (root@derzh.com)
-- @copyright: Copyright (c) 2013 EMZ Kingsoft Co., Ltd.
--------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- these global functions are accessed all the time by the event handler
-- so caching them is worth the effort
---------------------------------------------------------------------------------------------------
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
---------------------------------------------------------------------------------------------------
MENU_DIVIDER = { bDevide = true }
EMPTY_TABLE = SetmetaReadonly({})
XML_LINE_BREAKER = GetFormatText('\n')

if not GetCampImageFrame then
	function GetCampImageFrame(eCamp, bFight)	-- ui\Image\UICommon\CommonPanel2.UITex
		local nFrame = nil
		if eCamp == CAMP.GOOD then
			if bFight then
				nFrame = 117
			else
				nFrame = 7
			end
		elseif eCamp == CAMP.EVIL then
			if bFight then
				nFrame = 116
			else
				nFrame = 5
			end
		end
		return nFrame
	end
end

if not GetCampImage then
	function GetCampImage(eCamp, bFight)
		local nFrame = GetCampImageFrame(eCamp, bFight)
		if nFrame then
			return 'ui\\Image\\UICommon\\CommonPanel2.UITex', nFrame
		end
	end
end

-- ֻ������
if not SetmetaReadonly then
function SetmetaReadonly(t)
	for k, v in pairs(t) do
		if type(v) == 'table' then
			t[k] = SetmetaReadonly(v)
		end
	end
	return setmetatable({}, {
		__index     = t,
		__newindex  = function() assert(false, 'table is readonly\n') end,
		__metatable = {
			const_table = t,
		},
	})
end
end

-- -- ֻ�����ֵ�ö��
-- if not pairs_c then
-- function pairs_c(t, ...)
-- 	if type(t) == 'table' then
-- 		local metatable = getmetatable(t)
-- 		if type(metatable) == 'table' and metatable.const_table then
-- 			return pairs(metatable.const_table, ...)
-- 		end
-- 	end
-- 	return pairs(t, ...)
-- end
-- end

-- -- ֻ��������ö��
-- if not ipairs_c then
-- function ipairs_c(t, ...)
-- 	if type(t) == 'table' then
-- 		local metatable = getmetatable(t)
-- 		if type(metatable) == 'table' and metatable.const_table then
-- 			return ipairs(metatable.const_table, ...)
-- 		end
-- 	end
-- 	return ipairs(t, ...)
-- end
-- end

if not clone then
function clone(var)
	local szType = type(var)
	if szType == 'nil'
	or szType == 'boolean'
	or szType == 'number'
	or szType == 'string' then
		return var
	elseif szType == 'table' then
		local t = {}
		for key, val in pairs(var) do
			key = clone(key)
			val = clone(val)
			t[key] = val
		end
		return t
	elseif szType == 'function'
	or szType == 'userdata' then
		return nil
	else
		return nil
	end
end
end

if not empty then
function empty(var)
	local szType = type(var)
	if szType == 'nil' then
		return true
	elseif szType == 'boolean' then
		return var
	elseif szType == 'number' then
		return var == 0
	elseif szType == 'string' then
		return var == ''
	elseif szType == 'function' then
		return false
	elseif szType == 'table' then
		for _, _ in pairs(var) do
			return false
		end
		return true
	else
		return false
	end
end
end

if not var2str then
local function table_r(var, level, indent)
	local t = {}
	local szType = type(var)
	if szType == 'nil' then
		insert(t, 'nil')
	elseif szType == 'number' then
		insert(t, tostring(var))
	elseif szType == 'string' then
		insert(t, string.format('%q', var))
	elseif szType == 'function' then
		local s = string.dump(var)
		insert(t, 'loadstring("')
		-- 'string slice too long'
		for i = 1, #s, 2000 do
			insert(t, concat({'', byte(s, i, i + 2000 - 1)}, '\\'))
		end
		insert(t, '")')
	elseif szType == 'boolean' then
		insert(t, tostring(var))
	elseif szType == 'table' then
		insert(t, '{')
		local s_tab_equ = '='
		if indent then
			s_tab_equ = ' = '
			if not empty(var) then
				insert(t, '\n')
			end
		end
		local nohash = true
		local key, val, lastkey, lastval, hasval
		local tlist, thash = {}, {}
		repeat
			key, val = next(var, lastkey)
			if key then
				-- judge if this is a pure list table
				if nohash and (
					type(key) ~= 'number'
					or (lastval == nil and key ~= 1) -- first loop and index is not 1 : hash table
					or (lastkey and lastkey + 1 ~= key)
				) then
					nohash = false
				end
				-- process to insert to table
				-- insert indent
				if indent then
					insert(t, rep(indent, level + 1))
				end
				-- insert key
				if nohash then -- pure list: do not need a key
				elseif type(key) == 'string' and key:find('^[a-zA-Z_][a-zA-Z0-9_]*$') then -- a = val
					insert(t, key)
					insert(t, s_tab_equ)
				else -- [10010] = val -- ['.start with or contains special char'] = val
					insert(t, '[')
					insert(t, table_r(key, level + 1, indent))
					insert(t, ']')
					insert(t, s_tab_equ)
				end
				-- insert value
				insert(t, table_r(val, level + 1, indent))
				insert(t, ',')
				if indent then
					insert(t, '\n')
				end
				lastkey, lastval, hasval = key, val, true
			end
		until not key
		-- remove last `,` if no indent
		if not indent and hasval then
			remove(t)
		end
		-- insert `}` with indent
		if indent and not empty(var) then
			insert(t, rep(indent, level))
		end
		insert(t, '}')
	else --if (szType == 'userdata') then
		insert(t, '"')
		insert(t, tostring(var))
		insert(t, '"')
	end
	return concat(t)
end
function var2str(var, indent, level)
	return table_r(var, level or 0, indent)
end
end

local _RoleName
if not GetUserRoleName then
function GetUserRoleName()
	if not _RoleName then
		_RoleName = GetClientPlayer() and GetClientPlayer().szName
	end
	return _RoleName
end
end

if not GetUserAccount then
function GetUserAccount()
	local szAccount
	local hFrame = Wnd.OpenWindow('LoginPassword')
	if hFrame then
		local hEdit = hFrame:Lookup('WndPassword/Edit_Account')
		if hEdit then
			szAccount = hEdit:GetText()
		end
		Wnd.CloseWindow(hFrame)
	end
	return szAccount
end
end

-- get item name by item
if not GetItemNameByItem then
function GetItemNameByItem(item)
	if item.nGenre == ITEM_GENRE.BOOK then
		local nBookID, nSegID = GlobelRecipeID2BookID(item.nBookID)
		return Table_GetSegmentName(nBookID, nSegID) or g_tStrings.BOOK
	else
		return Table_GetItemName(item.nUiId)
	end
end
end

if not GetItemNameByItemInfo then
function GetItemNameByItemInfo(itemInfo, nBookInfo)
	if itemInfo.nGenre == ITEM_GENRE.BOOK then
		if nBookInfo then
			local nBookID, nSegID = GlobelRecipeID2BookID(nBookInfo)
			return Table_GetSegmentName(nBookID, nSegID) or g_tStrings.BOOK
		else
			return Table_GetItemName(itemInfo.nUiId)
		end
	else
		return Table_GetItemName(itemInfo.nUiId)
	end
end
end

if not GetItemNameByUIID then
function GetItemNameByUIID(nUiId)
	return Table_GetItemName(nUiId)
end
end

if not UI_OBJECT then
UI_OBJECT = SetmetaReadonly({
	NONE             = -1, -- ��Box
	ITEM             = 0 , -- �����е���Ʒ��nUiId, dwBox, dwX, nItemVersion, nTabType, nIndex
	SHOP_ITEM        = 1 , -- �̵�������۵���Ʒ nUiId, dwID, dwShopID, dwIndex
	OTER_PLAYER_ITEM = 2 , -- ����������ϵ���Ʒ nUiId, dwBox, dwX, dwPlayerID
	ITEM_ONLY_ID     = 3 , -- ֻ��һ��ID����Ʒ������װ������֮��ġ�nUiId, dwID, nItemVersion, nTabType, nIndex
	ITEM_INFO        = 4 , -- ������Ʒ nUiId, nItemVersion, nTabType, nIndex, nCount(��nCount����dwRecipeID)
	SKILL            = 5 , -- ���ܡ�dwSkillID, dwSkillLevel, dwOwnerID
	CRAFT            = 6 , -- ���ա�dwProfessionID, dwBranchID, dwCraftID
	SKILL_RECIPE     = 7 , -- �䷽dwID, dwLevel
	SYS_BTN          = 8 , -- ϵͳ����ݷ�ʽdwID
	MACRO            = 9 , -- ��
	MOUNT            = 10, -- ��Ƕ
	ENCHANT          = 11, -- ��ħ
	NOT_NEED_KNOWN   = 15, -- ����Ҫ֪������
	PENDANT          = 16, -- �Ҽ�
	PET              = 17, -- ����
	MEDAL            = 18, -- �������
	BUFF             = 19, -- BUFF
	MONEY            = 20, -- ��Ǯ
	TRAIN            = 21, -- ��Ϊ
	EMOTION_ACTION   = 22, -- ��������
})
end

GLOBAL_HEAD_CLIENTPLAYER = GLOBAL_HEAD_CLIENTPLAYER or 0
GLOBAL_HEAD_OTHERPLAYER  = GLOBAL_HEAD_OTHERPLAYER  or 1
GLOBAL_HEAD_NPC          = GLOBAL_HEAD_NPC          or 2
GLOBAL_HEAD_LIFE         = GLOBAL_HEAD_LIFE         or 0
GLOBAL_HEAD_GUILD        = GLOBAL_HEAD_GUILD        or 1
GLOBAL_HEAD_TITLE        = GLOBAL_HEAD_TITLE        or 2
GLOBAL_HEAD_NAME         = GLOBAL_HEAD_NAME         or 3
GLOBAL_HEAD_MARK         = GLOBAL_HEAD_MARK         or 4

EQUIPMENT_SUIT_COUNT = 4
PET_COUT_PER_PAGE    = 16
PET_MAX_COUNT        = 64

if not EQUIPMENT_SUB then
EQUIPMENT_SUB = {
	MELEE_WEAPON      = 0 , -- ��ս����
	RANGE_WEAPON      = 1 , -- Զ������
	CHEST             = 2 , -- ����
	HELM              = 3 , -- ͷ��
	AMULET            = 4 , -- ����
	RING              = 5 , -- ��ָ
	WAIST             = 6 , -- ����
	PENDANT           = 7 , -- ��׺
	PANTS             = 8 , -- ����
	BOOTS             = 9 , -- Ь��
	BANGLE            = 10, -- ����
	WAIST_EXTEND      = 11, -- �����Ҽ�
	PACKAGE           = 12, -- ����
	ARROW             = 13, -- ����
	BACK_EXTEND       = 14, -- �����Ҽ�
	HORSE             = 15, -- ����
	BULLET            = 16, -- �������
	FACE_EXTEND       = 17, -- �����Ҽ�
	MINI_AVATAR       = 18, -- Сͷ��
	PET               = 19, -- ����
	L_SHOULDER_EXTEND = 20, -- ���Ҽ�
	R_SHOULDER_EXTEND = 21, -- �Ҽ�Ҽ�
	BACK_CLOAK_EXTEND = 22, -- ����
	TOTAL             = 23, --
}
end

if not EQUIPMENT_INVENTORY then
EQUIPMENT_INVENTORY = {
	MELEE_WEAPON  = 1 , -- ��ͨ��ս����
	BIG_SWORD     = 2 , -- �ؽ�
	RANGE_WEAPON  = 3 , -- Զ������
	CHEST         = 4 , -- ����
	HELM          = 5 , -- ͷ��
	AMULET        = 6 , -- ����
	LEFT_RING     = 7 , -- ���ֽ�ָ
	RIGHT_RING    = 8 , -- ���ֽ�ָ
	WAIST         = 9 , -- ����
	PENDANT       = 10, -- ��׺
	PANTS         = 11, -- ����
	BOOTS         = 12, -- Ь��
	BANGLE        = 13, -- ����
	PACKAGE1      = 14, -- ��չ����1
	PACKAGE2      = 15, -- ��չ����2
	PACKAGE3      = 16, -- ��չ����3
	PACKAGE4      = 17, -- ��չ����4
	PACKAGE_MIBAO = 18, -- �󶨰�ȫ��Ʒ״̬�����͵Ķ��ⱳ���� ��ItemList V9������
	BANK_PACKAGE1 = 19, -- �ֿ���չ����1
	BANK_PACKAGE2 = 20, -- �ֿ���չ����2
	BANK_PACKAGE3 = 21, -- �ֿ���չ����3
	BANK_PACKAGE4 = 22, -- �ֿ���չ����4
	BANK_PACKAGE5 = 23, -- �ֿ���չ����5
	ARROW         = 24, -- ����
	TOTAL         = 25,
}
end

if not FORCE_TYPE then
FORCE_TYPE = {
	JIANG_HU  = 0 , -- ����
	SHAO_LIN  = 1 , -- ����
	WAN_HUA   = 2 , -- ��
	TIAN_CE   = 3 , -- ���
	CHUN_YANG = 4 , -- ����
	QI_XIU    = 5 , -- ����
	WU_DU     = 6 , -- �嶾
	TANG_MEN  = 7 , -- ����
	CANG_JIAN = 8 , -- �ؽ�
	GAI_BANG  = 9 , -- ؤ��
	MING_JIAO = 10, -- ����
	CANG_YUN  = 21, -- ����
}
end

if not KUNGFU_TYPE then
KUNGFU_TYPE = {
	TIAN_CE     = 1,      -- ����ڹ�
	WAN_HUA     = 2,      -- ���ڹ�
	CHUN_YANG   = 3,      -- �����ڹ�
	QI_XIU      = 4,      -- �����ڹ�
	SHAO_LIN    = 5,      -- �����ڹ�
	CANG_JIAN   = 6,      -- �ؽ��ڹ�
	GAI_BANG    = 7,      -- ؤ���ڹ�
	MING_JIAO   = 8,      -- �����ڹ�
	WU_DU       = 9,      -- �嶾�ڹ�
	TANG_MEN    = 10,     -- �����ڹ�
	CANG_YUN    = 18,     -- �����ڹ�
}
end

if not PEEK_OTHER_PLAYER_RESPOND then
PEEK_OTHER_PLAYER_RESPOND = {
	INVALID             = 0,
	SUCCESS             = 1,
	FAILED              = 2,
	CAN_NOT_FIND_PLAYER = 3,
	TOO_FAR             = 4,
}
end

if not WND_CONTAINER_STYLE then
WND_CONTAINER_STYLE = {
	WND_CONTAINER_STYLE_CUSTOM       = 0,
	WND_CONTAINER_STYLE_LEFT_TOP     = 1,
	WND_CONTAINER_STYLE_LEFT_BOTTOM  = 2,
	WND_CONTAINER_STYLE_RIGHT_TOP    = 3,
	WND_CONTAINER_STYLE_RIGHT_BOTTOM = 4,
	WND_CONTAINER_STYLE_END          = 5,
}
end

INVENTORY_GUILD_BANK      = INVENTORY_GUILD_BANK or (INVENTORY_INDEX.TOTAL + 1) --���ֿ��������һ������λ��
INVENTORY_GUILD_PAGE_SIZE = INVENTORY_GUILD_PAGE_SIZE or 100
if not GetGuildBankBagPos then
function GetGuildBankBagPos(nPage, nIndex)
	return INVENTORY_GUILD_BANK, nPage * INVENTORY_GUILD_PAGE_SIZE + nIndex
end
end

MY_DEBUG = SetmetaReadonly({
	LOG     = 0,
	PMLOG   = 0,
	WARNING = 1,
	ERROR   = 2,
})

if not IsPhoneLock then
function IsPhoneLock()
	return GetClientPlayer() and GetClientPlayer().IsTradingMibaoSwitchOpen()
end
end

if not FormatDataStructure then
function FormatDataStructure(data, struct)
	local szType = type(struct)
	if szType == type(data) then
		if szType == 'table' then
			local t = {}
			for k, v in pairs(struct) do
				t[k] = FormatDataStructure(data[k], v)
			end
			return t
		end
	else
		data = clone(struct)
	end
	return data
end
end

if not IsSameData then
function IsSameData(data1, data2)
	if type(data1) == 'table' and type(data2) == 'table' then
		for k, v in pairs(data1) do
			if not IsSameData(data1[k], data2[k]) then
				return false
			end
		end
		return true
	else
		return data1 == data2
	end
end
end

if not IsSelf then
function IsSelf(dwSrcID, dwTarID)
	return dwSrcID ~= 0 and dwSrcID == dwTarID and IsPlayer(dwSrcID) and IsPlayer(dwTarID)
end
end

------------------------------------
--            ����ͨѶ            --
------------------------------------
-- ON_BG_CHANNEL_MSG
-- arg0: ��ϢszKey
-- arg1: ��Ϣ��ԴƵ��
-- arg2: ��Ϣ������ID
-- arg3: ��Ϣ����������
-- arg4: ������������������
------------------------------------
-- �ж�һ��tSay�ṹ�ǲ��Ǳ���ͨѶ
if not IsBgMsg then
function IsBgMsg(t)
	return type(t) == 'table' and t[1] and t[1].type == 'eventlink' and t[1].name == 'BG_CHANNEL_MSG'
end
end

-- ������ͨѶ
-- if not ProcessBgMsg then
-- function ProcessBgMsg(t, nChannel, dwTalkerID, szName, bEcho)
-- 	if IsBgMsg(t) and not bEcho and not (
-- 		nChannel == PLAYER_TALK_CHANNEL.NEARBY
-- 	 	or nChannel == PLAYER_TALK_CHANNEL.WORLD
-- 	 	or nChannel == PLAYER_TALK_CHANNEL.FORCE
-- 	 	or nChannel == PLAYER_TALK_CHANNEL.CAMP
-- 	 	or nChannel == PLAYER_TALK_CHANNEL.FRIENDS
-- 	 	or nChannel == PLAYER_TALK_CHANNEL.MENTOR
-- 	) then
-- 		local szKey, aParam = t[1].linkinfo or '', {}
-- 		if #t > 1 then
-- 			for i = 2, #t do
-- 				if t[i].type == 'text' then
-- 					table.insert(aParam, (t[i].text))
-- 				elseif t[i].type == 'eventlink' and t[i].name == '' then
-- 					table.insert(aParam, (str2var(t[i].linkinfo)))
-- 				end
-- 			end
-- 		end
-- 		FireUIEvent('ON_BG_CHANNEL_MSG', szKey, nChannel, dwTalkerID, szName, aParam)
-- 	end
-- end
-- end

-- ���ͱ���ͨѶ
-- SendBgMsg('����', 'RAID_READY_CONFIRM') -- ���˱���ͨѶ
-- SendBgMsg(PLAYER_TALK_CHANNEL.RAID, 'RAID_READY_CONFIRM') -- Ƶ������ͨѶ
if not SendBgMsg then
function SendBgMsg(nChannel, szKey, ...)
	local tSay ={{ type = 'eventlink', name = 'BG_CHANNEL_MSG', linkinfo = szKey }}
	local szTarget = ''
	if type(nChannel) == 'string' then
		szTarget = nChannel
		nChannel = PLAYER_TALK_CHANNEL.WHISPER
	end
	for _, v in ipairs({...}) do
		table.insert(tSay, { type = 'eventlink', name = '', linkinfo = var2str(v) })
	end
	GetClientPlayer().Talk(nChannel, szTarget, tSay)
end
end
------------------------------------
-- ���ֿ��ܱ���ͨѶ����̫�� ��Ҫ�ִη���
-- ����д������������� �Ժ���ʱ����˵��
-- ��_SendBgMsg��ProcessBgMsg���������ͺ�
-- �ǵ�ÿ����������ʱ���ͽ������ݰٷֱȵ��¼�
------------------------------------
--           ����ͨѶEND           --
------------------------------------

if not HookSound then
local hook = {}
function HookSound(szSound, szKey, fnCondition)
	if not hook[szSound] then
		hook[szSound] = {}
	end
	hook[szSound][szKey] = fnCondition
end
local sounds = {}
for k, v in pairs(g_sound) do
	sounds[k], g_sound[k] = g_sound[k], nil
end
local function getsound(t, k)
	if hook[k] then
		for szKey, fnCondition in pairs(hook[k]) do
			if fnCondition() then
				return
			end
		end
	end
	return sounds[k]
end
local function setsound(t, k, v)
	sounds[k] = v
end
setmetatable(g_sound, {__index = getsound, __newindex = setsound})

local function resumegsound()
	setmetatable(g_sound, nil)
	for k, v in pairs(sounds) do
		g_sound[k] = v
	end
end
RegisterEvent('GAME_EXIT', resumegsound)
RegisterEvent('PLAYER_EXIT_GAME', resumegsound)
RegisterEvent('RELOAD_UI_ADDON_BEGIN', resumegsound)
end

-- ѡ���� ����
if not ipairs_r then
local function fnBpairs(tab, nIndex)
	nIndex = nIndex - 1
	if nIndex > 0 then
		return nIndex, tab[nIndex]
	end
end

function ipairs_r(tab)
	return fnBpairs, tab, #tab + 1
end
end

if not str2var then
local szTempLog = 'interface/temp.log'
local szTempJx3dat = 'interface/temp.jx3dat'
function str2var(szText)
	Log(szTempLog, szText, 'clear close')
	CPath.Move(szTempLog, szTempJx3dat)
	local data = LoadLUAData(szTempJx3dat)
	CPath.DelFile(szTempJx3dat)
	return data
end
end

if not GVoiceBase_GetSaying then
GVoiceBase_GetSaying = GV_GetSayings
end

if not GVoiceBase_CheckMicState then
GVoiceBase_CheckMicState = GVoice_CheckMicState
end

if not Table_GetCommonEnchantDesc then
function Table_GetCommonEnchantDesc(enchant_id)
	local res = g_tTable.CommonEnchant:Search(enchant_id)
	if res then
		return res.desc
	end
end
end
if not Table_GetProfessionName then
function Table_GetProfessionName(dwProfessionID)
	local szName = ''
	local tProfession = g_tTable.ProfessionName:Search(dwProfessionID)
	if tProfession then
		szName = tProfession.szName
	end
	return szName
end
end

if not Table_GetDoodadTemplateName then
function Table_GetDoodadTemplateName(dwTemplateID)
	local szName = ''
	local tDoodad = g_tTable.DoodadTemplate:Search(dwTemplateID)
	if tDoodad then
		szName = tDoodad.szName
	end
	return szName
end
end

if not EditBox_AppendLinkPlayer then
function EditBox_AppendLinkPlayer(szName)
	local edit = Station.Lookup('Lowest2/EditBox/Edit_Input')
	edit:InsertObj('['.. szName ..']', { type = 'name', text = '['.. szName ..']', name = szName })
	Station.SetFocusWindow(edit)
	return true
end
end

if not EditBox_AppendLinkItem then
function EditBox_AppendLinkItem(dwID)
	local item = GetItem(dwID)
	if not item then
		return false
	end
	local szName = '[' .. GetItemNameByItem(item) ..']'
	local edit = Station.Lookup('Lowest2/EditBox/Edit_Input')
	edit:InsertObj(szName, { type = 'item', text = szName, item = item.dwID })
	Station.SetFocusWindow(edit)
	return true
end
end

if not FORMAT_WMSG_RET then
function FORMAT_WMSG_RET(stop, callFrame)
	local ret = 0
	if stop then
		ret = ret + 1 --01
	end

	if callFrame then
		ret = ret + 2 --10
	end
	return ret
end
end
-------------------------------------------
-- �������API���ݷ�ֹö���Լ��ӿ�û�е��±���
-------------------------------------------
if not MIC_STATE then
MIC_STATE = {
	NOT_AVIAL = 1,
	CLOSE_NOT_IN_ROOM = 2,
	CLOSE_IN_ROOM = 3,
	KEY = 4,
	FREE = 5,
}
end

if not GVoiceBase_IsOpen then
function GVoiceBase_IsOpen()
	return false
end
end

if not GVoiceBase_GetMicState then
function GVoiceBase_GetMicState()
	return MIC_STATE.CLOSE_NOT_IN_ROOM
end
end

if not GVoiceBase_SwitchMicState then
function GVoiceBase_SwitchMicState()
end
end

if not GVoiceBase_CheckMicState then
function GVoiceBase_CheckMicState()
end
end

if not SPEAKER_STATE then
SPEAKER_STATE = {
	OPEN = 1,
	CLOSE = 2,
}
end

if not GVoiceBase_GetSpeakerState then
function GVoiceBase_GetSpeakerState()
	return SPEAKER_STATE.CLOSE
end
end

if not GVoiceBase_SwitchSpeakerState then
function GVoiceBase_SwitchSpeakerState()
end
end

if not GVoiceBase_GetSaying then
function GVoiceBase_GetSaying()
	return {}
end
end

if not GVoiceBase_IsMemberSaying then
function GVoiceBase_IsMemberSaying(dwMemberID, sayingInfo)
	return false
end
end

if not GVoiceBase_IsMemberForbid then
function GVoiceBase_IsMemberForbid(dwMemberID)
	return false
end
end

if not GVoiceBase_ForbidMember then
function GVoiceBase_ForbidMember(dwMemberID, Forbid)
end
end

if not Table_IsTreasureBattleFieldMap then
function Table_IsTreasureBattleFieldMap()
	return false
end
end

if not Table_GetTeamRecruit then
function Table_GetTeamRecruit()
	local res = {}
	local nCount = g_tTable.TeamRecruit:GetRowCount()
	for i = 2, nCount do
		local tLine = g_tTable.TeamRecruit:GetRow(i)
		local dwType = tLine.dwType
		local szTypeName = tLine.szTypeName

		if dwType > 0 then
			res[dwType] = res[dwType] or {Type=dwType, TypeName=szTypeName}
			res[dwType].bParent = true
			local dwSubType = tLine.dwSubType
			local szSubTypeName = tLine.szSubTypeName
			if dwSubType > 0 then
				res[dwType][dwSubType] = res[dwType][dwSubType] or {SubType=dwSubType, SubTypeName=szSubTypeName}
				res[dwType][dwSubType].bParent = true
				table.insert(res[dwType][dwSubType], tLine)
			else
				table.insert(res[dwType], tLine)
			end
		end
	end
	return res
end
end

if not Table_IsSimplePlayer then
function Table_IsSimplePlayer(dwTemplateID)
	local tLine = g_tTable.SimplePlayer:Search(dwTemplateID)
	if tLine then
		return true
	end
	return false
end
end

if not ForceIDToKungfuIDs then
-- * ��ȡ���ɶ�Ӧ�ķ�ID�б�
local m_tForceToKungfu
function ForceIDToKungfuIDs(dwForceID)
	if not m_tForceToKungfu then
		m_tForceToKungfu = {
			[FORCE_TYPE.SHAO_LIN ] = { 10002, 10003, },
			[FORCE_TYPE.WAN_HUA  ] = { 10021, 10028, },
			[FORCE_TYPE.TIAN_CE  ] = { 10026, 10062, },
			[FORCE_TYPE.CHUN_YANG] = { 10014, 10015, },
			[FORCE_TYPE.QI_XIU   ] = { 10080, 10081, },
			[FORCE_TYPE.WU_DU    ] = { 10175, 10176, },
			[FORCE_TYPE.TANG_MEN ] = { 10224, 10225, },
			[FORCE_TYPE.CANG_JIAN] = { 10144, 10145, },
			[FORCE_TYPE.GAI_BANG ] = { 10268, },
			[FORCE_TYPE.MING_JIAO] = { 10242, 10243, },
			[FORCE_TYPE.CANG_YUN ] = { 10389, 10390, },
			[FORCE_TYPE.CHANG_GE ] = { 10447, 10448, },
			[FORCE_TYPE.BA_DAO   ] = { 10464, },
		}
	end
	return m_tForceToKungfu[dwForceID] or {}
end
end

UpdateItemInfoBoxObject = UpdataItemInfoBoxObject

if not Table_SchoolToForce then
function Table_SchoolToForce(dwSchoolID)
	local nCount = g_tTable.ForceToSchool:GetRowCount()
	local dwForceID = 0
	for i = 1, nCount do
		tLine = g_tTable.ForceToSchool:GetRow(i)
		if dwSchoolID == tLine.dwSchoolID then
			dwForceID = tLine.dwForceID
		end
	end
	return dwForceID
end
end

if not Table_GetSkillSchoolKungfu then
function Table_GetSkillSchoolKungfu(dwSchoolID)
	local tKungFungList = {}
	local tLine = g_tTable.SkillSchoolKungfu:Search(dwSchoolID)
	if tLine then
		local szKungfu = tLine.szKungfu
		for s in string.gmatch(szKungfu, "%d+") do
			local dwID = tonumber(s)
			if dwID then
				table.insert(tKungFungList, dwID)
			end
		end
	end
	return tKungFungList
end
end


if not Table_GetMKungfuList then
function Table_GetMKungfuList(dwKungfuID)
	local tLine = g_tTable.MKungfuKungfu:Search(dwKungfuID)
	local tKungfu = {}
	if tLine and tLine.szKungfu then
		local szKungfu = tLine.szKungfu
		for s in string.gmatch(szKungfu, "%d+") do
			local dwID = tonumber(s)
			if dwID then
				table.insert(tKungfu, dwID)
			end
		end
	end
	return tKungfu
end
end


if not Table_GetNewKungfuSkill then
function Table_GetNewKungfuSkill(dwMountKungfu, dwKungfuID)
	local tLine = g_tTable.SkillKungFuShow:Search(dwMountKungfu) or {}
	if empty(tLine) then
		return nil
	end
	if tLine.dwKungfu ~= dwKungfuID then
		return nil
	end
	local tSkill = {}
	local szSkill = tLine.szNewSkillID
	for s in string.gmatch(szSkill, "%d+") do
		local dwID = tonumber(s)
		if dwID then
			table.insert(tSkill, dwID)
		end
	end
	if tSkill and not empty(tSkill) then
		return tSkill
	end
	return nil
end
end

if not Table_GetKungfuSkillList then
function Table_GetKungfuSkillList(dwKungfuID)
	local tSkill = {}
	local tLine = g_tTable.KungfuSkill:Search(dwKungfuID)
	if tLine then
		local szSkill = tLine.szSkill
		for s in string.gmatch(szSkill, "%d+") do
			local dwID = tonumber(s)
			if dwID then
				table.insert(tSkill, dwID)
			end
		end
	end
	return tSkill
end
end

if not Table_GetSkillExtCDID then
do local cache = {}
function Table_GetSkillExtCDID(dwID)
	if cache[dwID] == nil then
		local tLine = g_tTable.SkillExtCDID:Search(dwID)
		cache[dwID] = tLine and tLine.dwExtID or false
	end
	return cache[dwID] and cache[dwID] or nil
end
end
end
