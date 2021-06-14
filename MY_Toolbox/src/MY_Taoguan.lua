--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : �Զ��������չ�
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
local LIB = MY
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
local Call, XpCall, SafeCall, NSFormatString = LIB.Call, LIB.XpCall, LIB.SafeCall, LIB.NSFormatString
-------------------------------------------------------------------------------------------------------
local PLUGIN_NAME = 'MY_Toolbox'
local PLUGIN_ROOT = PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_Taoguan'
local _L = LIB.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not LIB.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^4.0.0') then
	return
end
--------------------------------------------------------------------------
-- �������� -- ��һ����һ���屶�������������չ�
-- ���˽��� -- ��һ���������չ�ʧ������������ɻ���
-- �������� -- ��һ���������屶�������������չ�
-- ������� -- ��һ���������չ�ʧ������һ�����
-- ���ǹ� -- ��һ�����屶�������������չ�
-- ���� -- ��һ���������չ�ʧ������ʧ����

local FILTER_ITEM = {
	{ szName = LIB.GetObjectName('ITEM_INFO', 5, 6072), bFilter = true }, -- ����
	{ szName = LIB.GetObjectName('ITEM_INFO', 5, 6069), bFilter = true }, -- ��������
	{ szName = LIB.GetObjectName('ITEM_INFO', 5, 6068), bFilter = true }, -- �������
	{ szName = LIB.GetObjectName('ITEM_INFO', 5, 6067), bFilter = true }, -- ��������
	{ szName = LIB.GetObjectName('ITEM_INFO', 5, 6076), bFilter = true }, -- ��������
	{ szName = LIB.GetObjectName('ITEM_INFO', 5, 6073), bFilter = true }, -- ����
	{ szName = LIB.GetObjectName('ITEM_INFO', 5, 6070), bFilter = true }, -- �����
	{ szName = LIB.GetObjectName('ITEM_INFO', 5, 6077), bFilter = true }, -- ��������
	{ szName = LIB.GetObjectName('ITEM_INFO', 5, 8025, 1168), bFilter = true }, -- ��ֽ������
	{ szName = LIB.GetObjectName('ITEM_INFO', 5, 8025, 1170), bFilter = true }, -- ��ֽ������
	{ szName = LIB.GetObjectName('ITEM_INFO', 5, 6066), bFilter = true }, -- Ԫ����
	{ szName = LIB.GetObjectName('ITEM_INFO', 5, 6067), bFilter = true }, -- �һ���
	{ szName = LIB.GetObjectName('ITEM_INFO', 5, 6024), bFilter = true }, -- ���������
	{ szName = LIB.GetObjectName('ITEM_INFO', 5, 6048), bFilter = false }, -- ��ľ�ơ���
	{ szName = LIB.GetObjectName('ITEM_INFO', 5, 6049), bFilter = true }, -- ��ľ�ơ���
	{ szName = LIB.GetObjectName('ITEM_INFO', 5, 6050), bFilter = true }, -- ��ľ�ơ���
	{ szName = LIB.GetObjectName('ITEM_INFO', 5, 6051), bFilter = true }, -- ��ľ�ơ���
	{ szName = LIB.GetObjectName('ITEM_INFO', 5, 6200), bFilter = true }, -- ͼ������������
	{ szName = LIB.GetObjectName('ITEM_INFO', 5, 6203), bFilter = true }, -- ͼ������������
	{ szName = LIB.GetObjectName('ITEM_INFO', 5, 6258), bFilter = false }, -- �౾ӡ�Ķһ�ȯ
	{ szName = LIB.GetObjectName('ITEM_INFO', 5, 31599), bFilter = false }, -- ս����
	{ szName = LIB.GetObjectName('ITEM_INFO', 5, 30692), bFilter = false }, -- ������
	{ szName = LIB.GetObjectName('ITEM_INFO', 5, 20959), bFilter = false }, -- �����չ�
	{ szName = LIB.GetObjectName('ITEM_INFO', 5, 6027), bFilter = false }, -- ��������
	{ szName = LIB.GetObjectName('ITEM_INFO', 5, 6030), bFilter = false }, -- ���˽���
	{ szName = LIB.GetObjectName('ITEM_INFO', 5, 6028), bFilter = false }, -- ��������
	{ szName = LIB.GetObjectName('ITEM_INFO', 5, 6031), bFilter = false }, -- �������
	{ szName = LIB.GetObjectName('ITEM_INFO', 5, 6043), bFilter = false }, -- ��ס���¹ⱦ��
}
local FILTER_ITEM_DEFAULT = {}
for _, p in ipairs(FILTER_ITEM) do
	FILTER_ITEM_DEFAULT[p.szName] = p.bFilter
end

local O = LIB.CreateUserSettingsModule('MY_Taoguan', _L['MY_Toolbox'], {
	nPausePoint = { -- ͣ�ҷ�����
		ePathType = PATH_TYPE.ROLE,
		szLabel = _L['MY_Taoguan'],
		xSchema = Schema.Number,
		xDefaultValue = 327680,
	},
	bUseTaoguan = { -- ��Ҫʱʹ�ñ������չ�
		ePathType = PATH_TYPE.ROLE,
		szLabel = _L['MY_Taoguan'],
		xSchema = Schema.Boolean,
		xDefaultValue = true,
	},
	bNoYinchuiUseJinchui = { -- ûС����ʱʹ��С��
		ePathType = PATH_TYPE.ROLE,
		szLabel = _L['MY_Taoguan'],
		xSchema = Schema.Boolean,
		xDefaultValue = false,
	},
	nUseXiaojinchui = { -- ����ʹ��С�𴸵ķ���
		ePathType = PATH_TYPE.ROLE,
		szLabel = _L['MY_Taoguan'],
		xSchema = Schema.Number,
		xDefaultValue = 320,
	},
	bPauseNoXiaojinchui = { -- ȱ��С��ʱͣ��
		ePathType = PATH_TYPE.ROLE,
		szLabel = _L['MY_Taoguan'],
		xSchema = Schema.Boolean,
		xDefaultValue = true,
	},
	nUseXingyunXiangnang = { -- ��ʼ���������ҵķ���
		ePathType = PATH_TYPE.ROLE,
		szLabel = _L['MY_Taoguan'],
		xSchema = Schema.Number,
		xDefaultValue = 80,
	},
	bPauseNoXingyunXiangnang = { -- ȱ����������ʱͣ��
		ePathType = PATH_TYPE.ROLE,
		szLabel = _L['MY_Taoguan'],
		xSchema = Schema.Boolean,
		xDefaultValue = false,
	},
	nUseXingyunJinnang = { -- ��ʼ�����˽��ҵķ���
		ePathType = PATH_TYPE.ROLE,
		szLabel = _L['MY_Taoguan'],
		xSchema = Schema.Number,
		xDefaultValue = 80,
	},
	bPauseNoXingyunJinnang = { -- ȱ�����˽���ʱͣ��
		ePathType = PATH_TYPE.ROLE,
		szLabel = _L['MY_Taoguan'],
		xSchema = Schema.Boolean,
		xDefaultValue = false,
	},
	nUseRuyiXiangnang = { -- ��ʼ���������ҵķ���
		ePathType = PATH_TYPE.ROLE,
		szLabel = _L['MY_Taoguan'],
		xSchema = Schema.Number,
		xDefaultValue = 80,
	},
	bPauseNoRuyiXiangnang = { -- ȱ����������ʱͣ��
		ePathType = PATH_TYPE.ROLE,
		szLabel = _L['MY_Taoguan'],
		xSchema = Schema.Boolean,
		xDefaultValue = false,
	},
	nUseRuyiJinnang = { -- ��ʼ��������ҵķ���
		ePathType = PATH_TYPE.ROLE,
		szLabel = _L['MY_Taoguan'],
		xSchema = Schema.Number,
		xDefaultValue = 80,
	},
	bPauseNoRuyiJinnang = { -- ȱ���������ʱͣ��
		ePathType = PATH_TYPE.ROLE,
		szLabel = _L['MY_Taoguan'],
		xSchema = Schema.Boolean,
		xDefaultValue = false,
	},
	nUseJiyougu = { -- ��ʼ�Լ��ǹȵķ���
		ePathType = PATH_TYPE.ROLE,
		szLabel = _L['MY_Taoguan'],
		xSchema = Schema.Number,
		xDefaultValue = 1280,
	},
	bPauseNoJiyougu = { -- ȱ�ټ��ǹ�ʱͣ��
		ePathType = PATH_TYPE.ROLE,
		szLabel = _L['MY_Taoguan'],
		xSchema = Schema.Boolean,
		xDefaultValue = true,
	},
	nUseZuisheng = { -- ��ʼ�������ķ���
		ePathType = PATH_TYPE.ROLE,
		szLabel = _L['MY_Taoguan'],
		xSchema = Schema.Number,
		xDefaultValue = 1280,
	},
	bPauseNoZuisheng = { -- ȱ������ʱͣ��
		ePathType = PATH_TYPE.ROLE,
		szLabel = _L['MY_Taoguan'],
		xSchema = Schema.Boolean,
		xDefaultValue = true,
	},
	tFilterItem = {
		ePathType = PATH_TYPE.ROLE,
		szLabel = _L['MY_Taoguan'],
		xSchema = Schema.Map(Schema.String, Schema.Boolean),
		xDefaultValue = FILTER_ITEM_DEFAULT,
	},
})

---------------------------------------------------------------------
-- ���غ����ͱ���
---------------------------------------------------------------------
local TAOGUAN = LIB.GetItemNameByUIID(74224) -- �����չ�
local XIAOJINCHUI = LIB.GetItemNameByUIID(65611) -- С��
local XIAOYINCHUI = LIB.GetItemNameByUIID(65609) -- С����
local MEILIANGYUQIAN = LIB.GetItemNameByUIID(65589) -- ÷����ǩ
local XINGYUNXIANGNANG = LIB.GetItemNameByUIID(65578) -- ��������
local XINGYUNJINNANG = LIB.GetItemNameByUIID(65581) -- ���˽���
local RUYIXIANGNANG = LIB.GetItemNameByUIID(65579) -- ��������
local RUYIJINNANG = LIB.GetItemNameByUIID(65582) -- �������
local JIYOUGU = LIB.GetItemNameByUIID(65580) -- ���ǹ�
local ZUISHENG = LIB.GetItemNameByUIID(65583) -- ����
local ITEM_CD = 1 * GLOBAL.GAME_FPS + 8 -- ��ҩCD
local HAMMER_CD = 5 * GLOBAL.GAME_FPS + 8 -- ����CD
local MAX_POINT_POW = 16 -- ������߱�����2^n��

local D = {
	bEnable = false, -- ����״̬
	nPoint = 0, -- ��ǰ�ܷ���
	nUseItemLFC = 0, -- �ϴγ�ҩ���߼�֡
	nUseHammerLFC = 0, -- �ϴ��ô��ӵ��߼�֡
	dwDoodadID = 0, -- �Զ�ʰȡ���˵Ľ������ID
	aUseItemPS = { -- ���ý������Ʒʹ������
		{ szName = XIAOJINCHUI, szID = 'Xiaojinchui' },
		{ szName = XINGYUNXIANGNANG, szID = 'XingyunXiangnang' },
		{ szName = XINGYUNJINNANG, szID = 'XingyunJinnang' },
		{ szName = RUYIXIANGNANG, szID = 'RuyiXiangnang' },
		{ szName = RUYIJINNANG, szID = 'RuyiJinnang' },
		{ szName = JIYOUGU, szID = 'Jiyougu' },
		{ szName = ZUISHENG, szID = 'Zuisheng' },
	},
	aUseItemOrder = { -- ״̬ת�ƺ�������Ʒ��BUFF�ж��߼�
		{
			{ szName = JIYOUGU, szID = 'Jiyougu', dwBuffID = 1660, nBuffLevel = 3 },
			{ szName = RUYIXIANGNANG, szID = 'RuyiXiangnang', dwBuffID = 1660, nBuffLevel = 2 },
			{ szName = XINGYUNXIANGNANG, szID = 'XingyunXiangnang', dwBuffID = 1660, nBuffLevel = 1 },
		},
		{
			{ szName = ZUISHENG, szID = 'Zuisheng', dwBuffID = 1661, nBuffLevel = 3 },
			{ szName = RUYIJINNANG, szID = 'RuyiJinnang', dwBuffID = 1661, nBuffLevel = 2 },
			{ szName = XINGYUNJINNANG, szID = 'XingyunJinnang', dwBuffID = 1661, nBuffLevel = 1 },
		},
	},
}

-- ʹ�ñ�����Ʒ
function D.UseBagItem(szName, bWarn)
	local me = GetClientPlayer()
	for i = 1, 6 do
		for j = 0, me.GetBoxSize(i) - 1 do
		local it = GetPlayerItem(me, i, j)
			if it and it.szName == szName then
				--[[#DEBUG BEGIN]]
				LIB.Debug('MY_Taoguan', 'UseItem: ' .. i .. ',' .. j .. ' ' .. szName, DEBUG_LEVEL.LOG)
				--[[#DEBUG END]]
				OnUseItem(i, j)
				return true
			end
		end
	end
	if bWarn then
		LIB.Systopmsg(_L('Auto taoguan: missing [%s]!', szName))
	end
end

-- �ҹ���״̬��ת�ƺ���
function D.BreakCanStateTransfer()
	local me = GetClientPlayer()
	if not me or not D.bEnable then
		return
	end
	local nLFC = GetLogicFrameCount()
	-- ȷ�ϵ��ҽ�ȷ�Ͽ�
	LIB.DoMessageBox('PlayerMessageBoxCommon')
	-- ��ҩ����CD��ȴ�
	if nLFC - D.nUseItemLFC < ITEM_CD then
		return
	end
	-- ����ҩBUFF�������
	for _, aItem in ipairs(D.aUseItemOrder) do
		-- ÿ���������ȼ�˳����
		for _, item in ipairs(aItem) do
			-- ���ϳ�ҩ��������
			if D.nPoint >= O['nUse' .. item.szID] then
				-- ����Ѿ���BUFF�����Թ�ҩ�ˣ�������ѭ��
				if LIB.GetBuff(me, item.dwBuffID, item.nBuffLevel) then
					break
				end
				-- �����Գ�ҩ
				if D.UseBagItem(item.szName, O['bPauseNo' .. item.szID]) then
					D.nUseItemLFC = nLFC
					-- �Գɹ��ˣ��ȴ��´�״̬��ת�ƺ�������
					return
				end
				if O['bPauseNo' .. item.szID] then
					-- ��ʧ���ˣ���ͣ�ҹ���
					D.Stop()
					return
				end
			end
		end
	end
	-- ���ӻ���CD��ȴ�
	if nLFC - D.nUseHammerLFC < HAMMER_CD then
		return
	end
	-- Ѱ�����ҵ��չ�
	local npcTaoguan
	for _, npc in ipairs(LIB.GetNearNpc()) do
		if npc and npc.dwTemplateID == 6820 then
			if LIB.GetDistance(npc) < 4 then
				npcTaoguan = npc
				break
			end
		end
	end
	-- û�����ҵ��չ޿����Լ���һ��
	if not npcTaoguan and O.bUseTaoguan then
		if D.UseBagItem(TAOGUAN) then
			D.nUseItemLFC = nLFC
		end
	end
	-- ����û���ҵ�������ȴ�
	if not npcTaoguan then
		return
	end
	-- �ҵ������ˣ���ΪĿ��
	LIB.SetTarget(TARGET.NPC, npcTaoguan.dwID)
	-- ��Ҫ��С�𴸣�����Ѿ��
	if D.nPoint >= O.nUseXiaojinchui then
		if D.UseBagItem(XIAOJINCHUI, O.bPauseNoXiaojinchui) then
			-- �ҳɹ��ˣ��ȴ���CD
			D.nUseHammerLFC = nLFC
			return
		end
		if O.bPauseNoXiaojinchui then
			-- ��ʧ���ˣ���ͣ�ҹ���
			D.Stop()
			return
		end
	end
	-- ��Ҫ��С����������Ѿ��
	if D.UseBagItem(XIAOYINCHUI) then
		-- �ҳɹ��ˣ��ȴ���CD
		D.nUseHammerLFC = nLFC
		return
	end
	-- û��С����ʱʹ��С�𴸣�
	if O.bNoYinchuiUseJinchui and D.UseBagItem(XIAOJINCHUI) then
		-- �ҳɹ��ˣ��ȴ���CD
		D.nUseHammerLFC = nLFC
		return
	end
	-- û�н�Ҳû������������ѽ
	D.UseBagItem(XIAOYINCHUI, true)
	D.Stop()
end

-------------------------------------
-- �¼�����
-------------------------------------
function D.MonitorZP(szChannel, szMsg)
	local _, _, nP = find(szMsg, _L['Current total score:(%d+)'])
	if nP then
		D.nPoint = tonumber(nP)
		if D.nPoint >= O.nPausePoint then
			D.Stop()
			D.bReachLimit = true
			LIB.Systopmsg(_L['Auto taoguan: reach limit!'])
		end
		D.nUseHammerLFC = GetLogicFrameCount()
	end
end

function D.OnLootItem()
	if arg0 == GetClientPlayer().dwID and arg2 > 2 and GetItem(arg1).szName == MEILIANGYUQIAN then
		D.nPoint = 0
		LIB.Systopmsg(_L['Auto taoguan: score clear!'])
	end
end

function D.OnDoodadEnter()
	if D.bEnable or D.bReachLimit then
		local d = GetDoodad(arg0)
		if d and d.szName == TAOGUAN and d.CanDialog(GetClientPlayer())
			and LIB.GetDistance(d) < 4.1
		then
			D.dwDoodadID = arg0
			LIB.DelayCall(520, function()
				LIB.InteractDoodad(D.dwDoodadID)
			end)
		end
	end
end

function D.OnOpenDoodad()
	if D.bEnable or D.bReachLimit then
		local d = GetDoodad(D.dwDoodadID)
		if d and d.szName == TAOGUAN then
			local nQ, nM, me = 1, d.GetLootMoney(), GetClientPlayer()
			if nM > 0 then
				LootMoney(d.dwID)
			end
			for i = 0, 31 do
				local it, bRoll, bDist = d.GetLootItem(i, me)
				if not it then
					break
				end
				local szName = GetItemNameByItem(it)
				if it.nQuality >= nQ and not bRoll and not bDist
					and not O.tFilterItem[szName]
				then
					LootItem(d.dwID, it.dwID)
				else
					LIB.Systopmsg(_L('Auto taoguan: filter item [%s].', szName))
				end
			end
			local hL = Station.Lookup('Normal/LootList', 'Handle_LootList')
			if hL then
				hL:Clear()
			end
		end
		D.bReachLimit = nil
	end
end

-- �ҹ��ӿ�ʼ��ע���¼���
function D.Start()
	if D.bEnable then
		return
	end
	D.bEnable = true
	LIB.RegisterMsgMonitor('MSG_SYS.MY_Taoguan', D.MonitorZP)
	LIB.BreatheCall('MY_Taoguan', D.BreakCanStateTransfer)
	LIB.RegisterEvent('LOOT_ITEM.MY_Taoguan', D.OnLootItem)
	LIB.RegisterEvent('DOODAD_ENTER_SCENE.MY_Taoguan', D.OnDoodadEnter)
	LIB.RegisterEvent('HELP_EVENT.MY_Taoguan', function()
		if arg0 == 'OnOpenpanel' and arg1 == 'LOOT'
			and D.bEnable and D.dwDoodadID ~= 0
		then
			D.OnOpenDoodad()
			D.dwDoodadID = 0
		end
	end)
	LIB.Systopmsg(_L['Auto taoguan: on.'])
end

-- �ҹ��ӹرգ�ע���¼���
function D.Stop()
	if not D.bEnable then
		return
	end
	D.bEnable = false
	LIB.RegisterMsgMonitor('MSG_SYS.MY_Taoguan', false)
	LIB.BreatheCall('MY_Taoguan', false)
	LIB.RegisterEvent('NPC_ENTER_SCENE.MY_Taoguan', false)
	LIB.RegisterEvent('LOOT_ITEM.MY_Taoguan', false)
	LIB.RegisterEvent('DOODAD_ENTER_SCENE.MY_Taoguan', false)
	LIB.RegisterEvent('HELP_EVENT.MY_Taoguan', false)
	LIB.Systopmsg(_L['Auto taoguan: off.'])
end

-- �ҹ��ӿ���
function D.Switch()
	if D.bEnable then
		D.Stop()
	else
		D.Start()
	end
end

-------------------------------------
-- ���ý���
-------------------------------------
local PS = {}

function PS.OnPanelActive(wnd)
	local ui = UI(wnd)
	local X, Y = 20, 20
	local nX, nY = X, Y

	ui:Append('Text', { text = _L['Feature setting'], x = nX, y = nY, font = 27 })

	-- �����ﵽ����ͣ��
	nX = X + 10
	nY = nY + 28
	nX = ui:Append('Text', { text = _L['Stop simple broken can when score reaches'], x = nX, y = nY }):AutoWidth():Pos('BOTTOMRIGHT') + 5
	nX = ui:Append('WndComboBox', {
		x = nX, y = nY, w = 100, h = 25,
		text = O.nPausePoint,
		menu = function()
			local ui = UI(this)
			local m0 = {}
			for i = 2, MAX_POINT_POW do
				local v = 10 * 2 ^ i
				insert(m0, { szOption = tostring(v), fnAction = function()
					O.nPausePoint = v
					ui:Text(tostring(v))
				end })
			end
			return m0
		end,
	}):Pos('BOTTOMRIGHT') + 10
	ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 200,
		text = _L['Put can if needed?'],
		checked = O.bUseTaoguan,
		oncheck = function(bChecked) O.bUseTaoguan = bChecked end,
	}):AutoWidth()

	-- û��С����ʱʹ��С��
	-- nX = X + 10
	nY = nY + 28
	ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 200,
		text = _L('When no %s use %s?', XIAOYINCHUI, XIAOJINCHUI),
		checked = O.bNoYinchuiUseJinchui,
		oncheck = function(bChecked) O.bNoYinchuiUseJinchui = bChecked end,
	}):AutoWidth()

	-- ���ֶ���ʹ�÷�����ȱ��ͣ��
	local nMaxItemNameLen = 0
	for _, p in ipairs(D.aUseItemPS) do
		nMaxItemNameLen = max(nMaxItemNameLen, wlen(p.szName))
	end
	for _, p in ipairs(D.aUseItemPS) do
		nX = X + 10
		nY = nY + 28
		nX = ui:Append('Text', {
			x = nX, y = nY,
			text = _L('Use %s when score reaches', p.szName .. rep(g_tStrings.STR_ONE_CHINESE_SPACE, nMaxItemNameLen - wlen(p.szName))),
		}):AutoWidth():Pos('BOTTOMRIGHT') + 5
		nX = ui:Append('WndComboBox', {
			x = nX, y = nY, w = 100, h = 25,
			text = MY_Taoguan['nUse' .. p.szID],
			menu = function()
				local ui = UI(this)
				local m0 = {}
				for i = 2, MAX_POINT_POW - 1 do
					local v = 10 * 2 ^ i
					insert(m0, { szOption = tostring(v), fnAction = function()
						MY_Taoguan['nUse' .. p.szID] = v
						ui:Text(tostring(v))
					end })
				end
				return m0
			end,
		}):Pos('BOTTOMRIGHT') + 10
		nX = ui:Append('WndCheckBox', {
			x = nX, y = nY,
			text = _L['Stop break when no item'],
			checked = MY_Taoguan['bPauseNo' .. p.szID],
			oncheck = function(bChecked)
				MY_Taoguan['bPauseNo' .. p.szID] = bChecked
			end,
		}):AutoWidth():Pos('BOTTOMRIGHT') + 10
	end

	-- ʰȡ����
	nX = X + 10
	nY = nY + 38
	nX = ui:Append('WndComboBox', {
		x = nX, y = nY, w = 150,
		text = _L['Pickup filters'],
		menu = function()
			local m0 = {}
			for _, p in ipairs(FILTER_ITEM) do
				insert(m0, {
					szOption = p.szName,
					bCheck = true, bChecked = O.tFilterItem[p.szName],
					fnAction = function(d, b)
						O.tFilterItem[p.szName] = b
						O.tFilterItem = O.tFilterItem
					end,
				})
			end
			for k, v in pairs(O.tFilterItem) do
				if FILTER_ITEM_DEFAULT[k] == nil then
					insert(m0, {
						szOption = k,
						bCheck = true, bChecked = v,
						fnAction = function(d, b)
							O.tFilterItem[k] = b
							O.tFilterItem = O.tFilterItem
						end,
						szIcon = 'ui/Image/UICommon/CommonPanel2.UITex',
						nFrame = 49,
						nMouseOverFrame = 51,
						nIconWidth = 17,
						nIconHeight = 17,
						szLayer = 'ICON_RIGHTMOST',
						fnClickIcon = function()
							O.tFilterItem[k] = nil
							O.tFilterItem = O.tFilterItem
							UI.ClosePopupMenu()
						end,
					})
				end
			end
			if #m0 > 0 then
				insert(m0, CONSTANT.MENU_DIVIDER)
			end
			insert(m0, {
				szOption = _L['Custom add'],
				fnAction = function()
					local function fnConfirm(szText)
						O.tFilterItem[szText] = true
					end
					GetUserInput(_L['Please input custom name'], fnConfirm, nil, nil, nil, '', 20)
				end,
			})
			return m0
		end,
	}):AutoWidth():Pos('BOTTOMRIGHT') + 10
	ui:Append('Text', { x = nX, y = nY, text = _L['(Checked will not be picked up, if still pick please check system auto pick config)'] })

	-- ���ư�ť
	nX = X + 10
	nY = nY + 36
	nX = ui:Append('WndButton', {
		x = nX, y = nY, w = 130, h = 30,
		text = _L['Start/stop break can'],
		onclick = D.Switch,
	}):Pos('BOTTOMRIGHT') + 5
	nX = ui:Append('WndButton', {
		x = nX, y = nY, w = 130, h = 30,
		text = _L['Restore default config'],
		onclick = function()
			O('reset')
			LIB.SwitchTab('MY_Taoguan', true)
		end,
	}):Pos('BOTTOMRIGHT')
end
LIB.RegisterPanel(_L['Target'], 'MY_Taoguan', _L[MODULE_NAME], 119, PS)
