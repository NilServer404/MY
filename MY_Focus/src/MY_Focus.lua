--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : �����б�
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
local Get, Set, Clone, GetPatch, ApplyPatch = LIB.Get, LIB.Set, LIB.Clone, LIB.GetPatch, LIB.ApplyPatch
local Call, XpCall, SafeCall, NSFormatString = LIB.Call, LIB.XpCall, LIB.SafeCall, LIB.NSFormatString
local GetTraceback, RandomChild = LIB.GetTraceback, LIB.RandomChild
local EncodeLUAData, DecodeLUAData, CONSTANT = LIB.EncodeLUAData, LIB.DecodeLUAData, LIB.CONSTANT
-------------------------------------------------------------------------------------------------------
local PLUGIN_NAME = 'MY_Focus'
local PLUGIN_ROOT = PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_Focus'
local _L = LIB.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not LIB.AssertVersion(MODULE_NAME, _L[MODULE_NAME], 0x2016100) then
	return
end
--------------------------------------------------------------------------

local CHANGGE_REAL_SHADOW_TPLID = 46140 -- �����Ӱ ������Ӱ��
local INI_PATH = PACKET_INFO.ROOT .. 'MY_Focus/ui/MY_Focus.ini'
local FOCUS_LIST = {}
local l_tTempFocusList = {
	[TARGET.PLAYER] = {},   -- dwID
	[TARGET.NPC]    = {},   -- dwTemplateID
	[TARGET.DOODAD] = {},   -- dwTemplateID
}
local PRIVATE_CONFIG_LOADED = false
local PRIVATE_CONFIG_CHANGED = false
local PUBLIC_CONFIG_LOADED = false
local PUBLIC_CONFIG_CHANGED = false
local l_dwLockType, l_dwLockID, l_lockInDisplay
local O, D = {}, {}
local PRIVATE_DEFAULT = {
	bEnable     = false   , -- �Ƿ�����
	szStyle     = 'common', -- ��ʽ
	bMinimize   = false   , -- �Ƿ���С��
	bAutoHide   = true    , -- �޽���ʱ����
	nMaxDisplay = 5       , -- �����ʾ����
	fScaleX     = 1       , -- ���ű���
	fScaleY     = 1       , -- ���ű���
	anchor      = { x=-300, y=220, s='TOPRIGHT', r='TOPRIGHT' }, -- Ĭ������
}
local PUBLIC_DEFAULT = {
	bFocusINpc         = true    , -- ������ҪNPC
	bFocusFriend       = false   , -- ���㸽������
	bFocusTong         = false   , -- �������Ա
	bOnlyPublicMap     = true    , -- ���ڹ�����ͼ������Ѱ���Ա
	bSortByDistance    = false   , -- ���Ƚ��������Ŀ��
	bFocusEnemy        = false   , -- ����ж����
	bFocusAnmerkungen  = true    , -- �������С����������
	bAutoFocus         = true    , -- ����Ĭ�Ͻ���
	bTeamMonFocus      = true    , -- �����ŶӼ�ؽ���
	bHideDeath         = false   , -- ��������Ŀ��
	bDisplayKungfuIcon = false   , -- ��ʾ�ķ�ͼ��
	bFocusJJCParty     = false   , -- ������������
	bFocusJJCEnemy     = true    , -- ���������ж�
	bShowTarget        = false   , -- ��ʾĿ��Ŀ��
	szDistanceType     = 'global', -- ���������㷽ʽ
	bTraversal         = false   , -- ���������б�
	bHealHelper        = false   , -- ��������ģʽ
	bShowTipRB         = false   , -- ����Ļ���½���ʾ��Ϣ
	bEnableSceneNavi   = false   , -- ����׷�ٵ�
	tAutoFocus         = nil     , -- �ɰ�Ĭ�Ͻ�������
	tFocusList         = nil     , -- �ɰ����ý�������
	aPatternFocus      = {}      , -- Ĭ�Ͻ���
	tStaticFocus       = {         -- ���ý���
		[TARGET.PLAYER] = {},    -- dwID
		[TARGET.NPC]    = {},    -- dwTemplateID
		[TARGET.DOODAD] = {},    -- dwTemplateID
	},
}
for k, v in pairs(PRIVATE_DEFAULT) do
	O[k] = Clone(v)
end
for k, v in pairs(PUBLIC_DEFAULT) do
	O[k] = Clone(v)
end
RegisterCustomData('MY_Focus.tAutoFocus')
RegisterCustomData('MY_Focus.tFocusList')

function D.IsShielded() return LIB.IsShieldedVersion('MY_Focus') and LIB.IsInShieldedMap() end
function D.IsEnabled() return O.bEnable and not D.IsShielded() end

do
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
function D.FormatAutoFocusData(data)
	return LIB.FormatDataStructure(data, ds)
end
local dsl = {
	'__META__',
	__VALUE__ = {},
	__CHILD_TEMPLATE__ = ds,
}
function D.FormatAutoFocusDataList(datalist)
	return LIB.FormatDataStructure(datalist, dsl)
end
end

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

function D.LoadPublicConfig()
	if PUBLIC_CONFIG_CHANGED then
		D.SaveConfig()
	end
	-- ����ȫ�ֹ�������
	local config = LIB.LoadLUAData({'config/focus/' .. O.szStyle .. '.jx3dat', PATH_TYPE.GLOBAL}) or {}
	for k, v in pairs(PUBLIC_DEFAULT) do
		if IsNil(config[k]) then
			O[k] = Clone(v)
		else
			O[k] = config[k]
		end
	end
	-- ���ط�����ȫ������
	local config = LIB.LoadLUAData({'config/focus/' .. O.szStyle .. '.jx3dat', PATH_TYPE.SERVER}) or {}
	-- ������ý�����Ҫ�ֿ����� ������ͻ
	if config.tStaticFocus and config.tStaticFocus[TARGET.PLAYER] then
		O.tStaticFocus[TARGET.PLAYER] = config.tStaticFocus[TARGET.PLAYER]
	elseif not O.tStaticFocus[TARGET.PLAYER] then
		O.tStaticFocus[TARGET.PLAYER] = {}
	end
	-- ���ñ��λ
	PUBLIC_CONFIG_LOADED = true
	-- �ɰ�����ת��
	D.OnSetAncientPatternFocus()
	D.OnSetAncientStaticFocus()
	-- ɨ�踽�����
	D.RescanNearby()
end

function D.SavePublicConfig()
	if not PUBLIC_CONFIG_LOADED or not PUBLIC_CONFIG_CHANGED then
		return
	end
	-- ����ȫ�ֹ�������
	local config = {}
	for k, v in pairs(PUBLIC_DEFAULT) do
		config[k] = O[k]
	end
	config.tStaticFocus = {
		[TARGET.NPC] = O.tStaticFocus[TARGET.NPC],
		[TARGET.DOODAD] = O.tStaticFocus[TARGET.DOODAD],
	}
	LIB.SaveLUAData({'config/focus/' .. O.szStyle .. '.jx3dat', PATH_TYPE.GLOBAL}, config)
	-- �����������������
	local config = {
		tStaticFocus = { [TARGET.PLAYER] = O.tStaticFocus[TARGET.PLAYER] }
	}
	LIB.SaveLUAData({'config/focus/' .. O.szStyle .. '.jx3dat', PATH_TYPE.SERVER}, config)
	-- ���ñ��λ
	PUBLIC_CONFIG_CHANGED = false
end

function D.LoadConfig()
	local config = LIB.LoadLUAData({'config/focus.jx3dat', PATH_TYPE.ROLE}) or {}
	for k, v in pairs(PRIVATE_DEFAULT) do
		if IsNil(config[k]) then
			O[k] = Clone(v)
		else
			O[k] = config[k]
		end
	end
	PRIVATE_CONFIG_LOADED = true
	D.LoadPublicConfig()
end

function D.SaveConfig()
	if PRIVATE_CONFIG_LOADED and PRIVATE_CONFIG_CHANGED then
		local config = {}
		for k, v in pairs(PRIVATE_DEFAULT) do
			config[k] = O[k]
		end
		LIB.SaveLUAData({'config/focus.jx3dat', PATH_TYPE.ROLE}, config)
		PRIVATE_CONFIG_CHANGED = false
	end
	D.SavePublicConfig()
end
LIB.RegisterIdle('MY_Focus_Save', D.SaveConfig)

function D.BeforeConfigChange(k)
	if k == 'szStyle' then
		D.SaveConfig()
	end
end

function D.OnConfigChange(k, v)
	if not IsNil(PRIVATE_DEFAULT[k]) then
		PRIVATE_CONFIG_CHANGED = true
	elseif not IsNil(PUBLIC_DEFAULT[k]) then
		PUBLIC_CONFIG_CHANGED = true
	end
	if k == 'szStyle' then
		D.LoadPublicConfig()
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
	return Clone(O.aPatternFocus)
end

-- ��ӡ��޸�Ĭ�Ͻ���
function D.SetFocusPattern(szPattern, tData)
	local nIndex
	szPattern = LIB.TrimString(szPattern)
	for i, v in ipairs_r(O.aPatternFocus) do
		if v.szPattern == szPattern then
			nIndex = i
			remove(O.aPatternFocus, i)
			PUBLIC_CONFIG_CHANGED = true
		end
	end
	-- ��ʽ������
	if not IsTable(tData) then
		tData = { szPattern = szPattern }
	end
	tData = D.FormatAutoFocusData(tData)
	-- ���½����б�
	if nIndex then
		insert(O.aPatternFocus, nIndex, tData)
		PUBLIC_CONFIG_CHANGED = true
	else
		insert(O.aPatternFocus, tData)
		PUBLIC_CONFIG_CHANGED = true
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
			PUBLIC_CONFIG_CHANGED = true
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
		PUBLIC_CONFIG_CHANGED = true
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
		PUBLIC_CONFIG_CHANGED = true
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

function D.GetEligibleRules(tRules, dwMapID, dwType, dwID, dwTemplateID, szName, szTong)
	local aRule = {}
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
			insert(aRule, v)
		end
	end
	return aRule
end

-- ���������Ұ
function D.OnObjectEnterScene(dwType, dwID, nRetryCount)
	if nRetryCount and nRetryCount > 5 then
		return
	end
	local me = GetClientPlayer()
	if not me then
		return LIB.DelayCall(5000, function() D.OnObjectEnterScene(dwType, dwID) end)
	end
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
		local bFocus, aVia = false, {}
		local dwMapID = LIB.GetMapID(true)
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
			insert(aVia, {
				bDeletable = true,
				szVia = _L['Temp focus'],
			})
			bFocus = true
		end
		-- �ж����ý���
		if not bFocus then
			local dwTemplateID = dwType == TARGET.PLAYER and dwID or KObject.dwTemplateID
			if O.tStaticFocus[dwType][dwTemplateID]
			and not (
				dwType == TARGET.NPC
				and dwTemplateID == CHANGGE_REAL_SHADOW_TPLID
				and IsEnemy(UI_GetClientPlayerID(), dwID)
				and LIB.IsShieldedVersion('CHANGGE_SHADOW')
			) then
				insert(aVia, {
					bDeletable = true,
					szVia = _L['Static focus'],
				})
				bFocus = true
			end
		end
		-- �ж�Ĭ�Ͻ���
		if not bFocus and O.bAutoFocus then
			local aRule = D.GetEligibleRules(O.aPatternFocus, dwMapID, dwType, dwID, dwTemplateID, szName, szTong)
			for _, tRule in ipairs(aRule) do
				insert(aVia, {
					tRule = tRule,
					bDeletable = false,
					szVia = _L['Auto focus'] .. ' ' .. tRule.szPattern,
				})
				bFocus = true
			end
		end
		-- �ж��ŶӼ�ؽ���
		if not bFocus and D.TEAMMON_FOCUS and O.bTeamMonFocus then
			local aRule = D.GetEligibleRules(D.TEAMMON_FOCUS, dwMapID, dwType, dwID, dwTemplateID, szName, szTong)
			for _, tRule in ipairs(aRule) do
				insert(aVia, {
					tRule = tRule,
					bDeletable = false,
					szVia = _L['TeamMon focus'] .. ' ' .. tRule.szPattern,
				})
				bFocus = true
			end
		end

		-- �жϾ�����
		if not bFocus then
			if LIB.IsInArena() or LIB.IsInPubg() or LIB.IsInZombieMap() then
				if dwType == TARGET.PLAYER then
					if O.bFocusJJCEnemy and O.bFocusJJCParty then
						insert(aVia, {
							bDeletable = false,
							szVia = _L['Auto focus in arena'],
						})
						bFocus = true
					elseif O.bFocusJJCParty then
						if not IsEnemy(UI_GetClientPlayerID(), dwID) then
							insert(aVia, {
								bDeletable = false,
								szVia = _L['Auto focus party in arena'],
							})
							bFocus = true
						end
					elseif O.bFocusJJCEnemy then
						if IsEnemy(UI_GetClientPlayerID(), dwID) then
							insert(aVia, {
								bDeletable = false,
								szVia = _L['Auto focus enemy in arena'],
							})
							bFocus = true
						end
					end
				elseif dwType == TARGET.NPC then
					if O.bFocusJJCParty
					and KObject.dwTemplateID == CHANGGE_REAL_SHADOW_TPLID
					and not (IsEnemy(UI_GetClientPlayerID(), dwID) and LIB.IsShieldedVersion('CHANGGE_SHADOW')) then
						D.OnRemoveFocus(TARGET.PLAYER, KObject.dwEmployer)
						insert(aVia, {
							bDeletable = false,
							szVia = _L['Auto focus party in arena'],
						})
						bFocus = true
					end
				end
			else
				if not O.bOnlyPublicMap or (not LIB.IsInBattleField() and not LIB.IsInDungeon() and not LIB.IsInArena()) then
					-- �жϺ���
					if dwType == TARGET.PLAYER
					and O.bFocusFriend
					and LIB.GetFriend(dwID) then
						insert(aVia, {
							bDeletable = false,
							szVia = _L['Friend focus'],
						})
						bFocus = true
					end
					-- �ж�ͬ���
					if dwType == TARGET.PLAYER
					and O.bFocusTong
					and dwID ~= LIB.GetClientInfo().dwID
					and LIB.GetTongMember(dwID) then
						insert(aVia, {
							bDeletable = false,
							szVia = _L['Tong member focus'],
						})
						bFocus = true
					end
				end
				-- �жϵж����
				if dwType == TARGET.PLAYER
				and O.bFocusEnemy
				and IsEnemy(UI_GetClientPlayerID(), dwID) then
					insert(aVia, {
						bDeletable = false,
						szVia = _L['Enemy focus'],
					})
					bFocus = true
				end
			end
		end

		-- �ж���ҪNPC
		if not bFocus and O.bFocusINpc
		and dwType == TARGET.NPC
		and LIB.IsImportantNpc(dwMapID, KObject.dwTemplateID) then
			insert(aVia, {
				bDeletable = false,
				szVia = _L['Important npc focus'],
			})
			bFocus = true
		end

		-- �ж�С����
		if not bFocus and O.bFocusAnmerkungen
		and dwType == TARGET.PLAYER
		and MY_Anmerkungen.GetPlayerNote(dwID) then
			insert(aVia, {
				bDeletable = false,
				szVia = _L['Anmerkungen'],
			})
			bFocus = true
		end

		-- �ж����ε�NPC
		if bFocus and dwType == TARGET.NPC and LIB.IsShieldedNpc(dwTemplateID, 'FOCUS') and LIB.IsShieldedVersion('TARGET') then
			bFocus = false
		end

		-- ���뽹��
		if bFocus then
			D.OnSetFocus(dwType, dwID, szName, aVia)
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
			and LIB.IsInArena() and not (IsEnemy(UI_GetClientPlayerID(), dwID) and LIB.IsShieldedVersion('TARGET')) then
				D.OnSetFocus(TARGET.PLAYER, KObject.dwEmployer, LIB.GetObjectName(KObject, 'never'), _L['Auto focus party in arena'])
			end
		end
	end
	D.OnRemoveFocus(dwType, dwID)
end

-- Ŀ����뽹���б�
function D.OnSetFocus(dwType, dwID, szName, aVia)
	local nIndex
	for i, p in ipairs(FOCUS_LIST) do
		if p.dwType == dwType and p.dwID == dwID then
			nIndex = i
			break
		end
	end
	if not nIndex then
		insert(FOCUS_LIST, {
			dwType = dwType,
			dwID = dwID,
			szName = szName,
			aVia = aVia,
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
			remove(FOCUS_LIST, i)
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
	sort(FOCUS_LIST, fn)
end

-- ��ȡ�����б�
function D.GetFocusList()
	local t = {}
	for _, v in ipairs(FOCUS_LIST) do
		insert(t, v)
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
			local KObject = LIB.GetObject(p.dwType, p.dwID)
			if KObject then
				local bFocus, tRule, szVia, bDeletable = false
				for _, via in ipairs(p.aVia) do
					if via.tRule then
						local bRuleFocus = true
						if bRuleFocus and via.tRule.tLife.bEnable
						and not LIB.JudgeOperator(via.tRule.tLife.szOperator, KObject.nCurrentLife / KObject.nMaxLife * 100, via.tRule.tLife.nValue) then
							bRuleFocus = false
						end
						if bRuleFocus and via.tRule.nMaxDistance ~= 0
						and LIB.GetDistance(me, KObject, O.szDistanceType) > via.tRule.nMaxDistance then
							bRuleFocus = false
						end
						if bRuleFocus and not via.tRule.tRelation.bAll then
							if LIB.IsEnemy(me.dwID, KObject.dwID) then
								bRuleFocus = via.tRule.tRelation.bEnemy
							else
								bRuleFocus = via.tRule.tRelation.bAlly
							end
						end
						if bRuleFocus then
							bFocus = true
							tRule = via.tRule
							szVia = via.szVia
							bDeletable = via.bDeletable
							break
						end
					else
						bFocus = true
						szVia = via.szVia
						bDeletable = via.bDeletable
					end
				end
				if bFocus and O.bHideDeath then
					if p.dwType == TARGET.NPC or p.dwType == TARGET.PLAYER then
						bFocus = KObject.nMoveState ~= MOVE_STATE.ON_DEATH
					else--if p.dwType == TARGET.DOODAD then
						bFocus = KObject.nKind ~= DOODAD_KIND.CORPSE
					end
				end
				if bFocus then
					insert(t, setmetatable({
						tRule = tRule,
						szVia = szVia,
						bDeletable = bDeletable,
					}, { __index = p }))
				end
			end
		end
	end
	return t
end

function D.GetTargetMenu(dwType, dwID)
	return {{
		szOption = _L['Add to temp focus list'],
		fnAction = function()
			if not O.bEnable then
				O.bEnable = true
				MY_FocusUI.Open()
			end
			D.SetFocusID(dwType, dwID)
		end,
	}, {
		szOption = _L['Add to static focus list'],
		fnAction = function()
			if not O.bEnable then
				O.bEnable = true
				MY_FocusUI.Open()
			end
			D.SetFocusID(dwType, dwID, true)
		end,
	}}
end

function D.FormatRuleText(v, bNoBasic)
	local aText = {}
	if not bNoBasic then
		if not v.tType or v.tType.bAll then
			insert(aText, _L['All type'])
		else
			local aSub = {}
			for _, eType in ipairs({ TARGET.NPC, TARGET.PLAYER, TARGET.DOODAD }) do
				if v.tType[eType] then
					insert(aSub, _L.TARGET[eType])
				end
			end
			insert(aText, #aSub == 0 and _L['None type'] or concat(aSub, '|'))
		end
	end
	if not v.tRelation or v.tRelation.bAll then
		insert(aText, _L['All relation'])
	else
		local aSub = {}
		for _, szRelation in ipairs({ 'Enemy', 'Ally' }) do
			if v.tRelation['b' .. szRelation] then
				insert(aSub, _L.RELATION[szRelation])
			end
		end
		insert(aText, #aSub == 0 and _L['None relation'] or concat(aSub, '|'))
	end
	if not bNoBasic and v.szPattern then
		return v.szPattern .. ' (' .. concat(aText, ',') .. ')'
	end
	return concat(aText, ',')
end

function D.OpenRuleEditor(tData, onChangeNotify, bHideBase)
	local tData = D.FormatAutoFocusData(tData)
	local frame = UI.CreateFrame('MY_Focus_Editor', { close = true, text = _L['Focus rule editor'] })
	local ui = UI(frame)
	local X, Y, W = 30, 50, 350
	local nX, nY = X, Y
	local dY = 27
	if not bHideBase then
		W = 450
		-- ƥ�䷽ʽ
		ui:Append('Text', { x = nX, y = nY, color = {255, 255, 0}, text = _L['Judge method'] }):AutoWidth()
		nX, nY = X + 10, nY + dY
		for i, eType in ipairs({ 'NAME', 'NAME_PATT', 'ID', 'TEMPLATE_ID', 'TONG_NAME', 'TONG_NAME_PATT' }) do
			if i == 5 then
				nX, nY = X + 10, nY + dY
			end
			nX = ui:Append('WndRadioBox', {
				x = nX, y = nY,
				group = 'judge_method',
				text = _L.JUDGE_METHOD[eType],
				checked = tData.szMethod == eType,
				oncheck = function()
					tData.szMethod = eType
					onChangeNotify(tData)
				end,
			}):AutoWidth():Pos('BOTTOMRIGHT') + 5
		end
		nX, nY = X, nY + dY
		-- Ŀ������
		ui:Append('Text', { x = nX, y = nY, color = {255, 255, 0}, text = _L['Target type'] }):AutoWidth()
		nX, nY = X + 10, nY + dY
		nX = ui:Append('WndCheckBox', {
			x = nX, y = nY,
			text = _L['All'],
			checked = tData.tType.bAll,
			oncheck = function()
				tData.tType.bAll = not tData.tType.bAll
				onChangeNotify(tData)
			end,
		}):AutoWidth():Pos('BOTTOMRIGHT') + 5
		for _, eType in ipairs({ TARGET.NPC, TARGET.PLAYER, TARGET.DOODAD }) do
			nX = ui:Append('WndCheckBox', {
				x = nX, y = nY,
				text = _L.TARGET[eType],
				checked = tData.tType[eType],
				oncheck = function()
					tData.tType[eType] = not tData.tType[eType]
					onChangeNotify(tData)
				end,
				autoenable = function() return not tData.tType.bAll end,
			}):AutoWidth():Pos('BOTTOMRIGHT') + 5
		end
		nX, nY = X, nY + dY
	end
	-- Ŀ���ϵ
	ui:Append('Text', { x = nX, y = nY, color = {255, 255, 0}, text = _L['Target relation'] }):AutoWidth()
	nX, nY = X + 10, nY + dY
	nX = ui:Append('WndCheckBox', {
		x = nX, y = nY,
		text = _L['All'],
		checked = tData.tRelation.bAll,
		oncheck = function()
			tData.tRelation.bAll = not tData.tRelation.bAll
			onChangeNotify(tData)
		end,
	}):AutoWidth():Pos('BOTTOMRIGHT') + 5
	for _, szRelation in ipairs({ 'Enemy', 'Ally' }) do
		nX = ui:Append('WndCheckBox', {
			x = nX, y = nY,
			text = _L.RELATION[szRelation],
			checked = tData.tRelation['b' .. szRelation],
			oncheck = function()
				tData.tRelation['b' .. szRelation] = not tData.tRelation['b' .. szRelation]
				onChangeNotify(tData)
			end,
			autoenable = function() return not tData.tRelation.bAll end,
		}):AutoWidth():Pos('BOTTOMRIGHT') + 5
	end
	nX, nY = X, nY + dY
	-- Ŀ��Ѫ���ٷֱ�
	ui:Append('Text', { x = nX, y = nY, color = {255, 255, 0}, text = _L['Target life percentage'] }):AutoWidth()
	nX, nY = X + 10, nY + dY
	nX = ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 100, h = 25,
		text = _L['Enable'],
		checked = tData.tLife.bEnable,
		oncheck = function()
			tData.tLife.bEnable = not tData.tLife.bEnable
			onChangeNotify(tData)
		end,
	}):AutoWidth():Pos('BOTTOMRIGHT') + 5
	nX = ui:Append('WndComboBox', {
		x = nX, y = nY, w = 200,
		text = _L['Operator'],
		menu = function()
			return LIB.InsertOperatorMenu({}, tData.tLife.szOperator, function(op)
				tData.tLife.szOperator = op
				onChangeNotify(tData)
			end)
		end,
		autoenable = function() return tData.tLife.bEnable end,
	}):AutoWidth():Pos('BOTTOMRIGHT') + 5
	nX = ui:Append('WndEditBox', {
		x = nX, y = nY, w = 100, h = 25,
		text = tData.tLife.nValue,
		onchange = function(szText)
			local nValue = tonumber(szText) or 0
			tData.tLife.nValue = nValue
			onChangeNotify(tData)
		end,
		autoenable = function() return tData.tLife.bEnable end,
	}):AutoWidth():Pos('BOTTOMRIGHT') + 5
	nX, nY = X, nY + dY
	-- ��Զ����
	ui:Append('Text', { x = nX, y = nY, color = {255, 255, 0}, text = _L['Max distance'] }):AutoWidth()
	nX, nY = X + 10, nY + dY
	nX = ui:Append('WndEditBox', {
		x = nX, y = nY, w = 200, h = 25,
		text = tData.nMaxDistance,
		onchange = function(szText)
			local nValue = tonumber(szText) or 0
			tData.nMaxDistance = nValue
			onChangeNotify(tData)
		end,
	}):AutoWidth():Pos('BOTTOMRIGHT') + 5
	nX, nY = X, nY + dY
	-- ������ʾ
	ui:Append('Text', { x = nX, y = nY, color = {255, 255, 0}, text = _L['Name display'] }):AutoWidth()
	nX, nY = X + 10, nY + dY
	nX = ui:Append('WndEditBox', {
		x = nX, y = nY, w = 200, h = 25,
		text = tData.szDisplay,
		onchange = function(szText)
			tData.szDisplay = szText
			onChangeNotify(tData)
		end,
	}):AutoWidth():Pos('BOTTOMRIGHT') + 5
	nX, nY = X, nY + dY

	nY = nY + 20
	ui:Append('WndButton', {
		x = (W - 100) / 2, y = nY, w = 100,
		text = g_tStrings.STR_FRIEND_DEL, color = { 255, 0, 0 },
		buttonstyle = 2,
		onclick = function()
			LIB.Confirm(_L['Sure to delete?'], function()
				onChangeNotify()
				ui:Remove()
			end)
		end,
	})
	nX, nY = X, nY + dY

	ui:Size(W, nY + 40):Anchor('CENTER')
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
		local p = D.FormatAutoFocusData(v)
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
local function UpdateTeamMonData()
	D.TEAMMON_FOCUS = {}
	local aDS = {}
	local dwMapID = LIB.GetMapID(true)
	if MY_TeamMon and MY_TeamMon.GetTable then
		for _, p in ipairs({
			{'NPC', TARGET.NPC},
			{'DOODAD', TARGET.DOODAD},
		}) do
			local aData = MY_TeamMon.GetTable(p[1])
			if aData then
				insert(aDS, { dwType = p[2], aData = aData })
			end
		end
	end
	for _, ds in ipairs(aDS) do
		for _, data in spairs(ds.aData[-1], ds.aData[dwMapID]) do
			if data.aFocus then
				for _, p in ipairs(data.aFocus) do
					local rule = Clone(p)
					rule.szMethod = 'TEMPLATE_ID'
					rule.szPattern = tostring(data.dwID)
					rule.tType = {
						bAll = false,
						[TARGET.NPC] = false,
						[TARGET.PLAYER] = false,
						[TARGET.DOODAD] = false,
					}
					rule.tType[ds.dwType] = true
					insert(D.TEAMMON_FOCUS, D.FormatAutoFocusData(rule))
				end
			end
		end
	end
	D.RescanNearby()
end
LIB.RegisterEvent('LOADING_ENDING.MY_Focus', UpdateTeamMonData)
local function onTeamMonUpdate()
	if arg0 and not arg0['NPC'] and not arg0['DOODAD'] then
		return
	end
	UpdateTeamMonData()
end
LIB.RegisterEvent('MY_TM_DATA_RELOAD.MY_Focus', onTeamMonUpdate)
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
		O.aPatternFocus[i] = D.FormatAutoFocusData(v)
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
	D.CheckFrameOpen()
	D.RescanNearby()
end
LIB.RegisterInit('MY_Focus', onInit)

local function Flush()
	D.SaveConfig()
end
LIB.RegisterFlush('MY_Focus', Flush)
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
			PUBLIC_CONFIG_CHANGED = true
			MY_FocusUI.Open()
			LIB.RedrawTab('MY_Focus')
		end,
	},
	{
		szOption = _L['Not use'],
		fnAction = function()
			O.bEnable = false
			PUBLIC_CONFIG_CHANGED = true
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
				bTeamMonFocus = true,
				bHideDeath = true,
				bDisplayKungfuIcon = true,
				bFocusJJCParty = true,
				bFocusJJCEnemy = true,
				bShowTarget = true,
				szDistanceType = true,
				bTraversal = true,
				bHealHelper = true,
				bShowTipRB = true,
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
				SetFocusID         = D.SetFocusID        ,
				RemoveFocusID      = D.RemoveFocusID     ,
				SortFocus          = D.SortFocus         ,
				OpenRuleEditor     = D.OpenRuleEditor    ,
				FormatRuleText     = D.FormatRuleText    ,
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
				bTeamMonFocus = true,
				bHideDeath = true,
				bDisplayKungfuIcon = true,
				bFocusJJCParty = true,
				bFocusJJCEnemy = true,
				bShowTarget = true,
				szDistanceType = true,
				bTraversal = true,
				bHealHelper = true,
				bShowTipRB = true,
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
				bTeamMonFocus = D.OnConfigChange,
				bHideDeath = D.OnConfigChange,
				bDisplayKungfuIcon = D.OnConfigChange,
				bFocusJJCParty = D.OnConfigChange,
				bFocusJJCEnemy = D.OnConfigChange,
				bShowTarget = D.OnConfigChange,
				szDistanceType = D.OnConfigChange,
				bTraversal = D.OnConfigChange,
				bHealHelper = D.OnConfigChange,
				bShowTipRB = D.OnConfigChange,
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
