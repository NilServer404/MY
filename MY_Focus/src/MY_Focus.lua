--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : �����б�
-- @author   : ���� @˫���� @׷����Ӱ
-- @modifier : Emil Zhai (root@derzh.com)
-- @copyright: Copyright (c) 2013 EMZ Kingsoft Co., Ltd.
--------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
-- these global functions are accessed all the time by the event handler
-- so caching them is worth the effort
-------------------------------------------------------------------------------------------------------------
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
local LIB, UI, DEBUG_LEVEL, PATH_TYPE = MY, MY.UI, MY.DEBUG_LEVEL, MY.PATH_TYPE
local var2str, str2var, clone, empty, ipairs_r = LIB.var2str, LIB.str2var, LIB.clone, LIB.empty, LIB.ipairs_r
local spairs, spairs_r, sipairs, sipairs_r = LIB.spairs, LIB.spairs_r, LIB.sipairs, LIB.sipairs_r
local GetPatch, ApplyPatch = LIB.GetPatch, LIB.ApplyPatch
local Get, Set, RandomChild, GetTraceback = LIB.Get, LIB.Set, LIB.RandomChild, LIB.GetTraceback
local IsArray, IsDictionary, IsEquals = LIB.IsArray, LIB.IsDictionary, LIB.IsEquals
local IsNil, IsBoolean, IsNumber, IsFunction = LIB.IsNil, LIB.IsBoolean, LIB.IsNumber, LIB.IsFunction
local IsEmpty, IsString, IsTable, IsUserdata = LIB.IsEmpty, LIB.IsString, LIB.IsTable, LIB.IsUserdata
local MENU_DIVIDER, EMPTY_TABLE, XML_LINE_BREAKER = LIB.MENU_DIVIDER, LIB.EMPTY_TABLE, LIB.XML_LINE_BREAKER
-------------------------------------------------------------------------------------------------------------
local CHANGGE_REAL_SHADOW_TPLID = 46140 -- �����Ӱ ������Ӱ��
local INI_PATH = LIB.GetAddonInfo().szRoot .. 'MY_Focus/ui/MY_Focus.ini'
local _L = LIB.LoadLangPack(LIB.GetAddonInfo().szRoot .. 'MY_Focus/lang/')
local FOCUS_LIST = {}
local l_tTempFocusList = {
	[TARGET.PLAYER] = {},   -- dwID
	[TARGET.NPC]    = {},   -- dwTemplateID
	[TARGET.DOODAD] = {},   -- dwTemplateID
}
local BASIC_CONFIG_CHANGED = false
local STYLE_CONFIG_CHANGED = false
local l_dwLockType, l_dwLockID, l_lockInDisplay
local O, D = {}, { PASSPHRASE = {111, 198, 5} }
local BASIC_DEFAULT = {
	bEnable   = false   , -- �Ƿ�����
	szStyle   = 'common', -- ��ʽ
	bMinimize = false   , -- �Ƿ���С��
	anchor    = { x=-300, y=220, s='TOPRIGHT', r='TOPRIGHT' }, -- Ĭ������
}
local STYLE_DEFAULT = {
	bFocusINpc         = true    , -- ������ҪNPC
	bFocusFriend       = false   , -- ���㸽������
	bFocusTong         = false   , -- �������Ա
	bOnlyPublicMap     = true    , -- ���ڹ�����ͼ������Ѱ���Ա
	bSortByDistance    = false   , -- ���Ƚ��������Ŀ��
	bFocusEnemy        = false   , -- ����ж����
	bFocusAnmerkungen  = true    , -- �������С����������
	bAutoHide          = true    , -- �޽���ʱ����
	nMaxDisplay        = 5       , -- �����ʾ����
	bAutoFocus         = true    , -- ����Ĭ�Ͻ���
	bEmbeddedFocus     = true    , -- ������ǶĬ�Ͻ���
	bHideDeath         = false   , -- ��������Ŀ��
	bDisplayKungfuIcon = false   , -- ��ʾ�ķ�ͼ��
	bFocusJJCParty     = false   , -- ������������
	bFocusJJCEnemy     = true    , -- ���������ж�
	bShowTarget        = false   , -- ��ʾĿ��Ŀ��
	szDistanceType     = 'global', -- ���������㷽ʽ
	bTraversal         = false   , -- ���������б�
	bHealHelper        = false   , -- ��������ģʽ
	bEnableSceneNavi   = false   , -- ����׷�ٵ�
	fScaleX            = 1       , -- ���ű���
	fScaleY            = 1       , -- ���ű���
	tAutoFocus         = nil     , -- �ɰ�Ĭ�Ͻ�������
	tFocusList         = nil     , -- �ɰ����ý�������
	aPatternFocus      = {}      , -- Ĭ�Ͻ���
	tStaticFocus       = {         -- ���ý���
		[TARGET.PLAYER] = {},    -- dwID
		[TARGET.NPC]    = {},    -- dwTemplateID
		[TARGET.DOODAD] = {},    -- dwTemplateID
	},
}
for k, v in pairs(BASIC_DEFAULT) do
	O[k] = clone(v)
end
for k, v in pairs(STYLE_DEFAULT) do
	O[k] = clone(v)
end
RegisterCustomData('MY_Focus.tAutoFocus')
RegisterCustomData('MY_Focus.tFocusList')

local function FormatAutoFocusData(data)
	local ds = {
		szMethod = 'NAME',
		szPattern = '',
		szDisplay = '',
		dwMapID = -1,
		tType = {
			bAll = true,
			[TARGET.NPC] = false,
			[TARGET.PLAYER] = false,
			[TARGET.DOODAD] = false,
		},
		tRelation = {
			bAll = true,
			bEnemy = false,
			bAlly = false,
		},
		tLife = {
			bEnable = false,
			szOperator = '>',
			nValue = 0,
		},
		nMaxDistance = 0,
	}
	return LIB.FormatDataStructure(data, ds)
end
function D.IsShielded() return LIB.IsShieldedVersion() and LIB.IsInShieldedMap() end
function D.IsEnabled() return O.bEnable and not D.IsShielded() end

function D.CheckFrameOpen(bForceReload)
	if D.IsEnabled() then
		if bForceReload then
			MY_FocusUI.Close()
		end
		MY_FocusUI.Open()
	else
		MY_FocusUI.Close()
	end
end

function D.LoadStyleConfig()
	if STYLE_CONFIG_CHANGED then
		D.SaveConfig()
	end
	local config = LIB.LoadLUAData({'config/focus/' .. O.szStyle .. '.jx3dat', PATH_TYPE.GLOBAL}) or {}
	for k, v in pairs(STYLE_DEFAULT) do
		if IsNil(config[k]) then
			O[k] = clone(v)
		else
			O[k] = config[k]
		end
	end
	D.OnSetAncientPatternFocus()
	D.OnSetAncientStaticFocus()
	D.RescanNearby()
end

function D.SaveStyleConfig()
	if not STYLE_CONFIG_CHANGED then
		return
	end
	local config = {}
	for k, v in pairs(STYLE_DEFAULT) do
		config[k] = O[k]
	end
	LIB.SaveLUAData({'config/focus/' .. O.szStyle .. '.jx3dat', PATH_TYPE.GLOBAL}, config)
	STYLE_CONFIG_CHANGED = false
end

function D.LoadConfig()
	local config = LIB.LoadLUAData({'config/focus.jx3dat', PATH_TYPE.ROLE}) or {}
	for k, v in pairs(BASIC_DEFAULT) do
		if IsNil(config[k]) then
			O[k] = clone(v)
		else
			O[k] = config[k]
		end
	end
	D.LoadStyleConfig()
end

function D.SaveConfig()
	if BASIC_CONFIG_CHANGED then
		local config = {}
		for k, v in pairs(BASIC_DEFAULT) do
			config[k] = O[k]
		end
		LIB.SaveLUAData({'config/focus.jx3dat', PATH_TYPE.ROLE}, config)
		BASIC_CONFIG_CHANGED = false
	end
	D.SaveStyleConfig()
end
LIB.RegisterIdle('MY_Focus_Save', D.SaveConfig)

function D.BeforeConfigChange(k)
	if k == 'szStyle' then
		D.SaveConfig()
	end
end

function D.OnConfigChange(k, v)
	if not IsNil(BASIC_DEFAULT[k]) then
		BASIC_CONFIG_CHANGED = true
	elseif not IsNil(STYLE_DEFAULT[k]) then
		STYLE_CONFIG_CHANGED = true
	end
	if k == 'szStyle' then
		D.LoadStyleConfig()
		D.CheckFrameOpen(true)
	elseif k == 'bEnable' then
		D.CheckFrameOpen()
	elseif k == 'fScaleX' or k == 'fScaleY' then
		FireUIEvent('MY_FOCUS_SCALE_UPDATE')
	elseif k == 'nMaxDisplay' then
		FireUIEvent('MY_FOCUS_MAX_DISPLAY_UPDATE')
	elseif k == 'bAutoHide' then
		FireUIEvent('MY_FOCUS_AUTO_HIDE_UPDATE')
	end
end

function D.GetAllFocusPattern()
	return clone(O.aPatternFocus)
end

-- ��ӡ��޸�Ĭ�Ͻ���
function D.SetFocusPattern(szPattern, tData)
	local nIndex
	szPattern = LIB.TrimString(szPattern)
	for i, v in ipairs_r(O.aPatternFocus) do
		if v.szPattern == szPattern then
			nIndex = i
			remove(O.aPatternFocus, i)
			STYLE_CONFIG_CHANGED = true
		end
	end
	-- ��ʽ������
	if not IsTable(tData) then
		tData = { szPattern = szPattern }
	end
	tData = FormatAutoFocusData(tData)
	-- ���½����б�
	if nIndex then
		insert(O.aPatternFocus, nIndex, tData)
		STYLE_CONFIG_CHANGED = true
	else
		insert(O.aPatternFocus, tData)
		STYLE_CONFIG_CHANGED = true
	end
	D.RescanNearby()
	return tData
end

-- ɾ��Ĭ�Ͻ���
function D.RemoveFocusPattern(szPattern)
	local p
	for i = #O.aPatternFocus, 1, -1 do
		if O.aPatternFocus[i].szPattern == szPattern then
			p = O.aPatternFocus[i]
			remove(O.aPatternFocus, i)
			STYLE_CONFIG_CHANGED = true
		end
	end
	if not p then
		return
	end
	-- ˢ��UI
	if p.szMethod == 'NAME' then
		-- ȫ�ַ�ƥ��ģʽ������Ƿ������ý����� û����ɾ��Handle ����Լ���ܣ�
		for i = #FOCUS_LIST, 1, -1 do
			local p = FOCUS_LIST[i]
			local KObject = LIB.GetObject(p.dwType, p.dwID)
			local dwTemplateID = p.dwType == TARGET.PLAYER and p.dwID or KObject.dwTemplateID
			if KObject and LIB.GetObjectName(KObject, 'never') == szPattern
			and not l_tTempFocusList[p.dwType][p.dwID]
			and not O.tStaticFocus[p.dwType][dwTemplateID] then
				D.OnObjectLeaveScene(p.dwType, p.dwID)
			end
		end
	else
		-- ����ģʽ���ػ潹���б�
		D.RescanNearby()
	end
end

-- ���ID����
function D.SetFocusID(dwType, dwID, bSave)
	dwType, dwID = tonumber(dwType), tonumber(dwID)
	if bSave then
		local KObject = LIB.GetObject(dwType, dwID)
		local dwTemplateID = dwType == TARGET.PLAYER and dwID or KObject.dwTemplateID
		if O.tStaticFocus[dwType][dwTemplateID] then
			return
		end
		O.tStaticFocus[dwType][dwTemplateID] = true
		STYLE_CONFIG_CHANGED = true
		D.RescanNearby()
	else
		if l_tTempFocusList[dwType][dwID] then
			return
		end
		l_tTempFocusList[dwType][dwID] = true
		D.OnObjectEnterScene(dwType, dwID)
	end
end

-- ɾ��ID����
function D.RemoveFocusID(dwType, dwID)
	dwType, dwID = tonumber(dwType), tonumber(dwID)
	if l_tTempFocusList[dwType][dwID] then
		l_tTempFocusList[dwType][dwID] = nil
		D.OnObjectLeaveScene(dwType, dwID)
	end
	local KObject = LIB.GetObject(dwType, dwID)
	local dwTemplateID = dwType == TARGET.PLAYER and dwID or KObject.dwTemplateID
	if O.tStaticFocus[dwType][dwTemplateID] then
		O.tStaticFocus[dwType][dwTemplateID] = nil
		STYLE_CONFIG_CHANGED = true
		D.RescanNearby()
	end
end

-- ��ս����б�
function D.ClearFocus()
	FOCUS_LIST = {}
	FireUIEvent('MY_FOCUS_UPDATE')
end

-- ����ɨ�踽��������½����б�ֻ��������
function D.ScanNearby()
	for _, dwID in ipairs(LIB.GetNearPlayerID()) do
		D.OnObjectEnterScene(TARGET.PLAYER, dwID)
	end
	for _, dwID in ipairs(LIB.GetNearNpcID()) do
		D.OnObjectEnterScene(TARGET.NPC, dwID)
	end
	for _, dwID in ipairs(LIB.GetNearDoodadID()) do
		D.OnObjectEnterScene(TARGET.DOODAD, dwID)
	end
end

-- ����ɨ�踽������
function D.RescanNearby()
	D.ClearFocus()
	D.ScanNearby()
end
LIB.RegisterEvent('MY_ANMERKUNGEN_UPDATE.MY_Focus', D.RescanNearby)

function D.GetEligibleRule(tRules, dwMapID, dwType, dwID, dwTemplateID, szName, szTong)
	for _, v in ipairs(tRules) do
		if (v.tType.bAll or v.tType[dwType])
		and (v.dwMapID == -1 or v.dwMapID == dwMapID)
		and (
			(v.szMethod == 'NAME' and v.szPattern == szName)
			or (v.szMethod == 'NAME_PATT' and szName:find(v.szPattern))
			or (v.szMethod == 'ID' and tonumber(v.szPattern) == dwID)
			or (v.szMethod == 'TEMPLATE_ID' and tonumber(v.szPattern) == dwTemplateID)
			or (v.szMethod == 'TONG_NAME' and v.szPattern == szTong)
			or (v.szMethod == 'TONG_NAME_PATT' and szTong:find(v.szPattern))
		) then
			return v
		end
	end
end

function D.LoadEmbeddedRule()
	-- auto generate embedded data
	local DAT_ROOT = 'MY_Resource/data/focus/'
	local SRC_ROOT = LIB.FormatPath(LIB.GetAddonInfo().szRoot .. '!src-dist/dat/' .. DAT_ROOT)
	local DST_ROOT = LIB.FormatPath(LIB.GetAddonInfo().szRoot .. DAT_ROOT)
	for _, szFile in ipairs(CPath.GetFileList(SRC_ROOT)) do
		LIB.Sysmsg(_L['Encrypt and compressing: '] .. DAT_ROOT .. szFile)
		local data = LoadDataFromFile(SRC_ROOT .. szFile)
		if IsEncodedData(data) then
			data = DecodeData(data)
		end
		data = EncodeData(data, true, true)
		SaveDataToFile(data, DST_ROOT .. szFile, D.PASSPHRASE)
	end
	-- load embedded data
	local function LoadConfigData(szPath)
		local szPath = LIB.GetAddonInfo().szRoot .. szPath
		return LIB.LoadLUAData(szPath, { passphrase = D.PASSPHRASE }) or LIB.LoadLUAData(szPath) or {}
	end
	-- load and format data
	local data = LoadConfigData('MY_Resource/data/focus/$lang.jx3dat') or {}
	for i, v in ipairs(data) do
		data[i] = FormatAutoFocusData(v)
	end
	D.EMBEDDED_FOCUS = data
end

-- ���������Ұ
function D.OnObjectEnterScene(dwType, dwID, nRetryCount)
	if nRetryCount and nRetryCount > 5 then
		return
	end
	if not D.EMBEDDED_FOCUS then
		return LIB.DelayCall(5000, function() D.OnObjectEnterScene(dwType, dwID) end)
	end
	local me = GetClientPlayer()
	local KObject = LIB.GetObject(dwType, dwID)
	if not KObject then
		return
	end

	local szName = LIB.GetObjectName(KObject, 'never')
	-- �����Ҹս�����Ұʱ����Ϊ�յ�����
	if (dwType == TARGET.PLAYER and not szName) or not me then -- �������ս��볡����ʱ�������
		LIB.DelayCall(300, function()
			D.OnObjectEnterScene(dwType, dwID, (nRetryCount or 0) + 1)
		end)
	else-- if szName then -- �ж��Ƿ���Ҫ����
		if not szName then
			szName = LIB.GetObjectName(KObject, 'auto')
		end
		local bFocus, bDeletable = false, true
		local szVia, tRule = '', nil
		local dwMapID = me.GetMapID()
		local dwTemplateID, szTong = -1, ''
		if dwType == TARGET.PLAYER then
			if KObject.dwTongID ~= 0 then
				szTong = GetTongClient().ApplyGetTongName(KObject.dwTongID, 253)
				if not szTong or szTong == '' then -- ���Ŀ��ս��볡����ʱ�����ȡ����������
					LIB.DelayCall(300, function()
						D.OnObjectEnterScene(dwType, dwID, (nRetryCount or 0) + 1)
					end)
				end
			end
		else
			dwTemplateID = KObject.dwTemplateID
		end
		-- �ж���ʱ����
		if l_tTempFocusList[dwType][dwID] then
			bFocus = true
			bDeletable = true
			szVia = _L['Temp focus']
		end
		-- �ж����ý���
		if not bFocus then
			local dwTemplateID = dwType == TARGET.PLAYER and dwID or KObject.dwTemplateID
			if O.tStaticFocus[dwType][dwTemplateID]
			and not (
				dwType == TARGET.NPC
				and dwTemplateID == CHANGGE_REAL_SHADOW_TPLID
				and IsEnemy(UI_GetClientPlayerID(), dwID)
				and LIB.IsShieldedVersion()
			) then
				bFocus = true
				bDeletable = true
				szVia = _L['Static focus']
			end
		end
		-- �ж�Ĭ�Ͻ���
		if not bFocus and O.bAutoFocus then
			tRule = D.GetEligibleRule(O.aPatternFocus, dwMapID, dwType, dwID, dwTemplateID, szName, szTong)
			if tRule then
				bFocus = true
				bDeletable = false
				szVia = _L['Auto focus'] .. ' ' .. tRule.szPattern
			end
		end
		-- �ж���ǶĬ�Ͻ���
		if not bFocus and O.bEmbeddedFocus then
			tRule = D.GetEligibleRule(D.EMBEDDED_FOCUS, dwMapID, dwType, dwID, dwTemplateID, szName, szTong)
			if tRule then
				bFocus = true
				bDeletable = false
				szVia = _L['Embedded focus']
			end
		end

		-- �жϾ�����
		if not bFocus then
			if LIB.IsInArena() or LIB.IsInPubg() or LIB.IsInZombieMap() then
				if dwType == TARGET.PLAYER then
					if O.bFocusJJCEnemy and O.bFocusJJCParty then
						bFocus = true
						bDeletable = false
						szVia = _L['JJC focus']
					elseif O.bFocusJJCParty then
						if not IsEnemy(UI_GetClientPlayerID(), dwID) then
							bFocus = true
							bDeletable = false
							szVia = _L['JJC focus party']
						end
					elseif O.bFocusJJCEnemy then
						if IsEnemy(UI_GetClientPlayerID(), dwID) then
							bFocus = true
							bDeletable = false
							szVia = _L['JJC focus enemy']
						end
					end
				elseif dwType == TARGET.NPC then
					if O.bFocusJJCParty
					and KObject.dwTemplateID == CHANGGE_REAL_SHADOW_TPLID
					and not (IsEnemy(UI_GetClientPlayerID(), dwID) and LIB.IsShieldedVersion()) then
						D.OnRemoveFocus(TARGET.PLAYER, KObject.dwEmployer)
						bFocus = true
						bDeletable = false
						szVia = _L['JJC focus party']
					end
				end
			else
				if not O.bOnlyPublicMap or (not LIB.IsInBattleField() and not LIB.IsInDungeon() and not LIB.IsInArena()) then
					-- �жϺ���
					if dwType == TARGET.PLAYER
					and O.bFocusFriend
					and LIB.GetFriend(dwID) then
						bFocus = true
						bDeletable = false
						szVia = _L['Friend focus']
					end
					-- �ж�ͬ���
					if dwType == TARGET.PLAYER
					and O.bFocusTong
					and dwID ~= LIB.GetClientInfo().dwID
					and LIB.GetTongMember(dwID) then
						bFocus = true
						bDeletable = false
						szVia = _L['Tong member focus']
					end
				end
				-- �жϵж����
				if dwType == TARGET.PLAYER
				and O.bFocusEnemy
				and IsEnemy(UI_GetClientPlayerID(), dwID) then
					bFocus = true
					bDeletable = false
					szVia = _L['Enemy focus']
				end
			end
		end

		-- �ж���ҪNPC
		if not bFocus and O.bFocusINpc
		and dwType == TARGET.NPC
		and LIB.IsImportantNpc(me.GetMapID(), KObject.dwTemplateID) then
			bFocus = true
			bDeletable = false
			szVia = _L['Important npc focus']
		end

		-- �ж�С����
		if not bFocus and O.bFocusAnmerkungen
		and dwType == TARGET.PLAYER
		and MY_Anmerkungen.GetPlayerNote(dwID) then
			bFocus = true
			bDeletable = false
			szVia = _L['Anmerkungen']
		end

		-- �ж����ε�NPC
		if bFocus and dwType == TARGET.NPC and LIB.IsShieldedNpc(dwTemplateID) and LIB.IsShieldedVersion() then
			bFocus = false
			bDeletable = false
		end

		-- ���뽹��
		if bFocus then
			D.OnSetFocus(dwType, dwID, szName, bDeletable, szVia, tRule)
		end
	end
end

-- �����뿪��Ұ
function D.OnObjectLeaveScene(dwType, dwID)
	local KObject = LIB.GetObject(dwType, dwID)
	if KObject then
		if dwType == TARGET.NPC then
			if O.bFocusJJCParty
			and KObject.dwTemplateID == CHANGGE_REAL_SHADOW_TPLID
			and LIB.IsInArena() and not (IsEnemy(UI_GetClientPlayerID(), dwID) and LIB.IsShieldedVersion()) then
				D.OnSetFocus(TARGET.PLAYER, KObject.dwEmployer, LIB.GetObjectName(KObject, 'never'), false, _L['JJC focus party'])
			end
		end
	end
	D.OnRemoveFocus(dwType, dwID)
end

-- Ŀ����뽹���б�
function D.OnSetFocus(dwType, dwID, szName, bDeletable, szVia, tRule)
	local nIndex
	for i, p in ipairs(FOCUS_LIST) do
		if p.dwType == dwType and p.dwID == dwID then
			nIndex = i
			break
		end
	end
	if not nIndex then
		table.insert(FOCUS_LIST, {
			dwType = dwType,
			dwID = dwID,
			szName = szName,
			szVia = szVia,
			tRule = tRule,
			bDeletable = bDeletable,
		})
		nIndex = #FOCUS_LIST
	end
	FireUIEvent('MY_FOCUS_UPDATE')
end

-- Ŀ���Ƴ������б�
function D.OnRemoveFocus(dwType, dwID)
	-- ���б�������ɾ��
	for i = #FOCUS_LIST, 1, -1 do
		local p = FOCUS_LIST[i]
		if p.dwType == dwType and p.dwID == dwID then
			table.remove(FOCUS_LIST, i)
			break
		end
	end
	FireUIEvent('MY_FOCUS_UPDATE')
end

-- ����
function D.SortFocus(fn)
	local p = GetClientPlayer()
	fn = fn or function(p1, p2)
		p1 = LIB.GetObject(p1.dwType, p1.dwID)
		p2 = LIB.GetObject(p2.dwType, p2.dwID)
		if p1 and p2 then
			return pow(p.nX - p1.nX, 2) + pow(p.nY - p1.nY, 2) < pow(p.nX - p2.nX, 2) + pow(p.nY - p2.nY, 2)
		end
		return true
	end
	table.sort(FOCUS_LIST, fn)
end

-- ��ȡ�����б�
function D.GetFocusList()
	local t = {}
	for _, v in ipairs(FOCUS_LIST) do
		table.insert(t, v)
	end
	return t
end

-- ��ȡ��ǰ��ʾ�Ľ����б�
function D.GetDisplayList()
	local t = {}
	local me = GetClientPlayer()
	if not D.IsShielded() and me then
		for _, p in ipairs(FOCUS_LIST) do
			if #t >= O.nMaxDisplay then
				break
			end
			local KObject, bFocus = LIB.GetObject(p.dwType, p.dwID), true
			if not KObject then
				bFocus = false
			end
			if bFocus and O.bHideDeath then
				if p.dwType == TARGET.NPC or p.dwType == TARGET.PLAYER then
					bFocus = KObject.nMoveState ~= MOVE_STATE.ON_DEATH
				else--if p.dwType == TARGET.DOODAD then
					bFocus = KObject.nKind ~= DOODAD_KIND.CORPSE
				end
			end
			if bFocus and p.tRule then
				if bFocus and p.tRule.tLife.bEnable
				and not LIB.JudgeOperator(p.tRule.tLife.szOperator, KObject.nCurrentLife / KObject.nMaxLife * 100, p.tRule.tLife.nValue) then
					bFocus = false
				end
				if bFocus and p.tRule.nMaxDistance ~= 0
				and LIB.GetDistance(me, KObject, O.szDistanceType) > p.tRule.nMaxDistance then
					bFocus = false
				end
				if bFocus and not p.tRule.tRelation.bAll then
					if LIB.IsEnemy(me.dwID, KObject.dwID) then
						bFocus = p.tRule.tRelation.bEnemy
					else
						bFocus = p.tRule.tRelation.bAlly
					end
				end
			end
			if bFocus then
				insert(t, p)
			end
		end
	end
	return t
end

function D.GetTargetMenu(dwType, dwID)
	return {{
		szOption = _L['add to temp focus list'],
		fnAction = function()
			if not O.bEnable then
				O.bEnable = true
				MY_FocusUI.Open()
			end
			D.SetFocusID(dwType, dwID)
		end,
	}, {
		szOption = _L['add to static focus list'],
		fnAction = function()
			if not O.bEnable then
				O.bEnable = true
				MY_FocusUI.Open()
			end
			D.SetFocusID(dwType, dwID, true)
		end,
	}}
end

function D.OnSetAncientPatternFocus()
	if not IsTable(O.tAutoFocus) then
		return
	end
	local tExist = {}
	for _, p in ipairs(O.aPatternFocus) do
		tExist[p.szPattern] = true
	end
	for _, v in ipairs(O.tAutoFocus) do
		local p = FormatAutoFocusData(v)
		if not tExist[p.szPattern] then
			insert(O.aPatternFocus, p)
			tExist[p.szPattern] = true
			D.OnConfigChange('aPatternFocus', O.aPatternFocus)
		end
	end
end

function D.OnSetAncientStaticFocus()
	if not IsTable(O.tAutoFocus) then
		return
	end
	for dwType, tFocus in pairs(O.tFocusList) do
		if O.tStaticFocus[dwType] then
			for dwID, bFocus in pairs(tFocus) do
				O.tStaticFocus[dwType][dwID] = bFocus
				D.OnConfigChange('tStaticFocus', O.tStaticFocus)
			end
		end
	end
end

do
local function onInit()
	-- ��������������
	D.LoadConfig()
	-- ��������
	local k = char(80, 65, 83, 83, 80, 72, 82, 65, 83, 69)
	if IsTable(D[k]) then
		for i = 0, 50 do
			for j, v in ipairs({ 23, 112, 234, 156 }) do
				insert(D[k], (i * j * ((31 * v) % 256)) % 256)
			end
		end
		D[k] = char(unpack(D[k]))
	end
	-- �û��Զ���Ĭ�Ͻ���
	if not O.aPatternFocus then
		O.aPatternFocus = {}
	end
	for i, v in ipairs(O.aPatternFocus) do
		if IsString(v) then
			v = { szPattern = v }
		end
		O.aPatternFocus[i] = FormatAutoFocusData(v)
	end
	-- ���ý���
	if not O.tStaticFocus then
		O.tStaticFocus = {}
	end
	for _, dwType in ipairs({TARGET.PLAYER, TARGET.NPC, TARGET.DOODAD}) do
		if not O.tStaticFocus[dwType] then
			O.tStaticFocus[dwType] = {}
		end
	end
	-- ��ǶĬ�Ͻ���
	D.LoadEmbeddedRule()
	D.CheckFrameOpen()
	D.RescanNearby()
end
LIB.RegisterInit('MY_Focus', onInit)

local function onExit()
	D.SaveConfig()
end
LIB.RegisterExit('MY_Focus', onExit)
end

do
local function onMenu()
	local dwType, dwID = GetClientPlayer().GetTarget()
	return D.GetTargetMenu(dwType, dwID)
end
LIB.RegisterTargetAddonMenu('MY_Focus', onMenu)
end

do
local function onHotKey()
	local dwType, dwID = LIB.GetTarget()
	local aList = D.GetDisplayList()
	local t = aList[1]
	if not t then
		return
	end
	for i, p in ipairs(aList) do
		if p.dwType == dwType and p.dwID == dwID then
			t = aList[i + 1] or t
		end
	end
	LIB.SetTarget(t.dwType, t.dwID)
end
LIB.RegisterHotKey('MY_Focus_LoopTarget', _L['Loop target in focus'], onHotKey)
end

LIB.RegisterTutorial({
	szKey = 'MY_Focus',
	szMessage = _L['Would you like to use MY focus?'],
	fnRequire = function() return not O.bEnable end,
	{
		szOption = _L['Use'],
		bDefault = true,
		fnAction = function()
			O.bEnable = true
			STYLE_CONFIG_CHANGED = true
			MY_FocusUI.Open()
			LIB.RedrawTab('MY_Focus')
		end,
	},
	{
		szOption = _L['Not use'],
		fnAction = function()
			O.bEnable = false
			STYLE_CONFIG_CHANGED = true
			MY_Focus.Close()
			LIB.RedrawTab('MY_Focus')
		end,
	},
})

-- Global exports
do
local settings = {
	exports = {
		{
			fields = {
				bEnable = true,
				szStyle = true,
				bMinimize = true,
				bFocusINpc = true,
				bFocusFriend = true,
				bFocusTong = true,
				bOnlyPublicMap = true,
				bSortByDistance = true,
				bFocusEnemy = true,
				bFocusAnmerkungen = true,
				bAutoHide = true,
				nMaxDisplay = true,
				bAutoFocus = true,
				bEmbeddedFocus = true,
				bHideDeath = true,
				bDisplayKungfuIcon = true,
				bFocusJJCParty = true,
				bFocusJJCEnemy = true,
				bShowTarget = true,
				szDistanceType = true,
				bTraversal = true,
				bHealHelper = true,
				bEnableSceneNavi = true,
				anchor = true,
				fScaleX = true,
				fScaleY = true,
			},
			root = O,
		},
		{
			fields = {
				GetTargetMenu      = D.GetTargetMenu     ,
				IsShielded         = D.IsShielded        ,
				RescanNearby       = D.RescanNearby      ,
				IsEnabled          = D.IsEnabled         ,
				GetAllFocusPattern = D.GetAllFocusPattern,
				SetFocusPattern    = D.SetFocusPattern   ,
				RemoveFocusPattern = D.RemoveFocusPattern,
				GetDisplayList     = D.GetDisplayList    ,
				OnObjectEnterScene = D.OnObjectEnterScene,
				OnObjectLeaveScene = D.OnObjectLeaveScene,
				RemoveFocusID      = D.RemoveFocusID     ,
				SortFocus          = D.SortFocus         ,
			},
		},
	},
	imports = {
		{
			fields = {
				bEnable = true,
				szStyle = true,
				bMinimize = true,
				bFocusINpc = true,
				bFocusFriend = true,
				bFocusTong = true,
				bOnlyPublicMap = true,
				bSortByDistance = true,
				bFocusEnemy = true,
				bFocusAnmerkungen = true,
				bAutoHide = true,
				nMaxDisplay = true,
				bAutoFocus = true,
				bEmbeddedFocus = true,
				bHideDeath = true,
				bDisplayKungfuIcon = true,
				bFocusJJCParty = true,
				bFocusJJCEnemy = true,
				bShowTarget = true,
				szDistanceType = true,
				bTraversal = true,
				bHealHelper = true,
				bEnableSceneNavi = true,
				anchor = true,
				fScaleX = true,
				fScaleY = true,
				tAutoFocus = true,
				tFocusList = true,
			},
			triggers = {
				bEnable = {D.BeforeConfigChange, D.OnConfigChange},
				szStyle = {D.BeforeConfigChange, D.OnConfigChange},
				bMinimize = {D.BeforeConfigChange, D.OnConfigChange},
				anchor = {D.BeforeConfigChange, D.OnConfigChange},
				bFocusINpc = D.OnConfigChange,
				bFocusFriend = D.OnConfigChange,
				bFocusTong = D.OnConfigChange,
				bOnlyPublicMap = D.OnConfigChange,
				bSortByDistance = D.OnConfigChange,
				bFocusEnemy = D.OnConfigChange,
				bFocusAnmerkungen = D.OnConfigChange,
				bAutoHide = D.OnConfigChange,
				nMaxDisplay = D.OnConfigChange,
				bAutoFocus = D.OnConfigChange,
				bEmbeddedFocus = D.OnConfigChange,
				bHideDeath = D.OnConfigChange,
				bDisplayKungfuIcon = D.OnConfigChange,
				bFocusJJCParty = D.OnConfigChange,
				bFocusJJCEnemy = D.OnConfigChange,
				bShowTarget = D.OnConfigChange,
				szDistanceType = D.OnConfigChange,
				bTraversal = D.OnConfigChange,
				bHealHelper = D.OnConfigChange,
				bEnableSceneNavi = D.OnConfigChange,
				fScaleX = D.OnConfigChange,
				fScaleY = D.OnConfigChange,
				tAutoFocus = D.OnSetAncientPatternFocus,
				tFocusList = D.OnSetAncientStaticFocus,
			},
			root = O,
		},
	},
}
MY_Focus = LIB.GeneGlobalNS(settings)
end
