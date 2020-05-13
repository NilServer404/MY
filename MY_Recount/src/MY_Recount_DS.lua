--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : ս��ͳ�� ����Դ
-- @author   : ���� @˫���� @׷����Ӱ
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
local PLUGIN_NAME = 'MY_Recount'
local PLUGIN_ROOT = PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_Recount'
local _L = LIB.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not LIB.AssertVersion(MODULE_NAME, _L[MODULE_NAME], 0x2013900) then
	return
end
--------------------------------------------------------------------------
local DK = {
	UUID        = 'UUID'       , -- ս��Ψһ��ʶ
	VERSION     = 'nVersion'   , -- ���ݰ汾��
	TIME_BEGIN  = 'nTimeBegin' , -- ս����ʼʱ��
	TICK_BEGIN  = 'nTickBegin' , -- ս����ʼ����ʱ��
	TIME_DURING = 'nTimeDuring', -- ս������ʱ��
	TICK_DURING = 'nTickDuring', -- ս����������ʱ��
	AWAYTIME    = 'Awaytime'   , -- ����/����ʱ��ڵ�
	NAME_LIST   = 'Namelist'   , -- ���ƻ���
	FORCE_LIST  = 'Forcelist'  , -- ��������
	EFFECT_LIST = 'Effectlist' , -- Ч����Ϣ����
	DAMAGE      = 'Damage'     , -- ���ͳ��
	HEAL        = 'Heal'       , -- ����ͳ��
	BE_HEAL     = 'BeHeal'     , -- ����ͳ��
	BE_DAMAGE   = 'BeDamage'   , -- ����ͳ��
	EVERYTHING  = 'Everything' , -- ս������
}

local DK_REC = {
	TIME_DURING = 'nTimeDuring',
	TOTAL = 'nTotal',
	TOTAL_EFFECT = 'nTotalEffect',
	SNAPSHOTS = 'Snapshots',
	STATISTICS = 'Statistics',
}

local DK_REC_SNAPSHOT = {
	TIME_DURING = 'nTimeDuring',
	TOTAL = 'nTotal',
	TOTAL_EFFECT = 'nTotalEffect',
	STATISTICS = 'Statistics',
}

local DK_REC_SNAPSHOT_STAT = {
	TOTAL = 'nTotal',
	TOTAL_EFFECT = 'nTotalEffect',
}

local DK_REC_STAT = {
	TOTAL = 'nTotal',
	TOTAL_EFFECT = 'nTotalEffect',
	DETAIL = 'Detail',
	SKILL = 'Skill',
	TARGET = 'Target',
}

local DK_REC_STAT_DETAIL = {
	COUNT         = 'nCount'      , -- ���м�¼����������nSkillResult�����У�
	NZ_COUNT      = 'nNzCount'    , -- ����ֵ���м�¼����
	MAX           = 'nMax'        , -- �����������ֵ
	MAX_EFFECT    = 'nMaxEffect'  , -- �������������Чֵ
	MIN           = 'nMin'        , -- ����������Сֵ
	NZ_MIN        = 'nNzMin'      , -- ���η���ֵ������Сֵ
	MIN_EFFECT    = 'nMinEffect'  , -- ����������С��Чֵ
	NZ_MIN_EFFECT = 'nNzMinEffect', -- ���η���ֵ������С��Чֵ
	TOTAL         = 'nTotal'      , -- �����������˺�
	TOTAL_EFFECT  = 'nTotalEffect', -- ������������Ч�˺�
	AVG           = 'nAvg'        , -- ��������ƽ���˺�
	NZ_AVG        = 'nNzAvg'      , -- ���з���ֵ����ƽ���˺�
	AVG_EFFECT    = 'nAvgEffect'  , -- ��������ƽ����Ч�˺�
	NZ_AVG_EFFECT = 'nNzAvgEffect', -- ���з���ֵ����ƽ����Ч�˺�
}
--[[
[SKILL_RESULT_TYPE]ö�٣�
SKILL_RESULT_TYPE.PHYSICS_DAMAGE       = 0  -- �⹦�˺�
SKILL_RESULT_TYPE.SOLAR_MAGIC_DAMAGE   = 1  -- �����ڹ��˺�
SKILL_RESULT_TYPE.NEUTRAL_MAGIC_DAMAGE = 2  -- ��Ԫ���ڹ��˺�
SKILL_RESULT_TYPE.LUNAR_MAGIC_DAMAGE   = 3  -- �����ڹ��˺�
SKILL_RESULT_TYPE.POISON_DAMAGE        = 4  -- �����˺�
SKILL_RESULT_TYPE.REFLECTIED_DAMAGE    = 5  -- �����˺�
SKILL_RESULT_TYPE.THERAPY              = 6  -- ����
SKILL_RESULT_TYPE.STEAL_LIFE           = 7  -- ����͵ȡ(<D0>��<D1>�����<D2>����Ѫ��)
SKILL_RESULT_TYPE.ABSORB_THERAPY       = 8  -- ��������
SKILL_RESULT_TYPE.ABSORB_DAMAGE        = 9  -- �����˺�
SKILL_RESULT_TYPE.SHIELD_DAMAGE        = 10 -- ��Ч�˺�
SKILL_RESULT_TYPE.PARRY_DAMAGE         = 11 -- ����
SKILL_RESULT_TYPE.INSIGHT_DAMAGE       = 12 -- ʶ��
SKILL_RESULT_TYPE.EFFECTIVE_DAMAGE     = 13 -- ��Ч�˺�
SKILL_RESULT_TYPE.EFFECTIVE_THERAPY    = 14 -- ��Ч����
SKILL_RESULT_TYPE.TRANSFER_LIFE        = 15 -- ��ȡ����
SKILL_RESULT_TYPE.TRANSFER_MANA        = 16 -- ��ȡ����

-- Data DataDisplay History[] ���ݽṹ
Data = {
	[DK.UUID] = ս��ͳһ��ʾ��,
	[DK.VERSION] = ���ݰ汾��,
	[DK.TIME_BEGIN] = ս����ʼUNIXʱ���,
	[DK.TIME_DURING] = ս����������,
	[DK.AWAYTIME] = {
		��ҵ�dwID = {
			{ ���뿪ʼʱ��, �������ʱ�� }, ...
		}, ...
	},
	[DK.DAMAGE] = {                                                -- ���ͳ��
		[DK_REC.TIME_DURING] = ���һ�μ�¼ʱ�뿪ʼ������,
		[DK_REC.TOTAL] = ȫ�ӵ������,
		[DK_REC.TOTAL_EFFECT] = ȫ�ӵ���Ч�����,
		[DK_REC.SNAPSHOTS] = {
			{
				[DK_REC_SNAPSHOT.TIME_DURING ] = ��ǰ����ս������,
				[DK_REC_SNAPSHOT.TOTAL       ] = ��ǰ����ʱ��ȫ�������,
				[DK_REC_SNAPSHOT.TOTAL_EFFECT] = ��ǰ����ʱ��ȫ����Ч�����,
				[DK_REC_SNAPSHOT.STATISTICS  ] = {
					��ҵ�dwID = {
						[DK_REC_SNAPSHOT_STAT.TOTAL       ] = ��ǰ����ʱ�������������,
						[DK_REC_SNAPSHOT_STAT.TOTAL_EFFECT] = ��ǰ����ʱ����������Ч�����,
					},
					NPC������ = { ... },
				},
			}, ...
		},
		[DK_REC.STATISTICS] = {
			��ҵ�dwID = {                                        -- �ö�������ͳ��
				[DK_REC_STAT.TOTAL       ] = 2314214,       -- �����
				[DK_REC_STAT.TOTAL_EFFECT] = 132144 ,       -- ��Ч���
				[DK_REC_STAT.DETAIL      ] = {              -- ����������ͳ��
					SKILL_RESULT.HIT = {
						nCount       = 10    ,                    -- ���м�¼����
						nMax         = 34210 ,                    -- �����������ֵ
						nMaxEffect   = 29817 ,                    -- �������������Чֵ
						nMin         = 8790  ,                    -- ����������Сֵ
						nMinEffect   = 7657  ,                    -- ����������С��Чֵ
						nAvg         = 27818 ,                    -- ��������ƽ��ֵ
						nAvgEffect   = 27818 ,                    -- ��������ƽ����Чֵ
						nTotal       = 278560,                    -- �����������˺�
						nTotalEffect = 224750,                    -- ������������Ч�˺�
					},
					SKILL_RESULT.MISS = { ... },
					SKILL_RESULT.CRITICAL = { ... },
				},
				[DK_REC_STAT.SKILL] = {                     -- ����Ҿ����������ļ���ͳ��
					�����ֻ� = {                                  -- ����������ֻ���ɵ����ͳ��
						nCount       = 2     ,                    -- ����������ֻ��������
						nMax         = 13415 ,                    -- ����������ֻ���������
						nMaxEffect   = 9080  ,                    -- ����������ֻ������Ч�����
						nTotal       = 23213 ,                    -- ����������ֻ�������ܺ�
						nTotalEffect = 321421,                    -- ����������ֻ���Ч������ܺ�
						Detail = {                                -- ����������ֻ�����������ͳ��
							SKILL_RESULT.HIT = {
								nCount       = 10    ,            -- ����������ֻ����м�¼����
								nMax         = 34210 ,            -- ����������ֻص����������ֵ
								nMaxEffect   = 29817 ,            -- ����������ֻص������������Чֵ
								nMin         = 8790  ,            -- ����������ֻص���������Сֵ
								nMinEffect   = 7657  ,            -- ����������ֻص���������С��Чֵ
								nAvg         = 27818 ,            -- ����������ֻص�������ƽ��ֵ
								nAvgEffect   = 27818 ,            -- ����������ֻص�������ƽ����Чֵ
								nTotal       = 278560,            -- ����������ֻ������������˺�
								nTotalEffect = 224750,            -- ����������ֻ�������������Ч�˺�
							},
							SKILL_RESULT.MISS = { ... },
							SKILL_RESULT.CRITICAL = { ... },
						},
						Target = {                                -- ����������ֻس�����ͳ��
							���dwID = {                          -- ����������ֻػ��е�����������ͳ��
								nMax         = 13415 ,            -- ����������ֻػ��е�����������˺�
								nMaxEffect   = 9080  ,            -- ����������ֻػ��е������������Ч�˺�
								nTotal       = 23213 ,            -- ����������ֻػ��е��������˺��ܺ�
								nTotalEffect = 321421,            -- ����������ֻػ��е���������Ч�˺��ܺ�
								Count = {                         -- ����������ֻػ��е������ҽ��ͳ��
									SKILL_RESULT.HIT      = 5,
									SKILL_RESULT.MISS     = 3,
									SKILL_RESULT.CRITICAL = 3,
								},
							},
							Npc���� = { ... },
							...
						},
					},
					���ǻ��� = { ... },
					...
				},
				Target = {                                        -- ����Ҿ����������Ķ���ͳ��
					���dwID = {                                  -- ����ҶԸ�dwID�������ɵ����ͳ��
						nCount       = 2     ,                    -- ����ҶԸ�dwID������������
						nMax         = 13415 ,                    -- ����ҶԸ�dwID����ҵ�����������
						nMaxEffect   = 9080  ,                    -- ����ҶԸ�dwID����ҵ��������Ч�����
						nTotal       = 23213 ,                    -- ����ҶԸ�dwID�����������ܺ�
						nTotalEffect = 321421,                    -- ����ҶԸ�dwID�������Ч������ܺ�
						Detail = {                                -- ����ҶԸ�dwID���������������ͳ��
							SKILL_RESULT.HIT = {
								nCount       = 10    ,            -- ����ҶԸ�dwID��������м�¼����
								nMax         = 34210 ,            -- ����ҶԸ�dwID����ҵ����������ֵ
								nMaxEffect   = 29817 ,            -- ����ҶԸ�dwID����ҵ������������Чֵ
								nMin         = 8790  ,            -- ����ҶԸ�dwID����ҵ���������Сֵ
								nMinEffect   = 7657  ,            -- ����ҶԸ�dwID����ҵ���������С��Чֵ
								nAvg         = 27818 ,            -- ����ҶԸ�dwID����ҵ�������ƽ��ֵ
								nAvgEffect   = 27818 ,            -- ����ҶԸ�dwID����ҵ�������ƽ����Чֵ
								nTotal       = 278560,            -- ����ҶԸ�dwID����������������˺�
								nTotalEffect = 224750,            -- ����ҶԸ�dwID�����������������Ч�˺�
							},
							SKILL_RESULT.MISS = { ... },
							SKILL_RESULT.CRITICAL = { ... },
						},
						Skill = {                                 -- ����������ֻس�����ͳ��
							�����ֻ� = {                          -- ����������ֻػ��е�����������ͳ��
								nMax         = 13415 ,            -- ����������ֻػ��е�����������˺�
								nMaxEffect   = 9080  ,            -- ����������ֻػ��е������������Ч�˺�
								nTotal       = 23213 ,            -- ����������ֻػ��е��������˺��ܺ�
								nTotalEffect = 321421,            -- ����������ֻػ��е���������Ч�˺��ܺ�
								Count = {                         -- ����������ֻػ��е������ҽ��ͳ��
									SKILL_RESULT.HIT      = 5,
									SKILL_RESULT.MISS     = 3,
									SKILL_RESULT.CRITICAL = 3,
								},
							},
							���ǻ��� = { ... },
							...
						},
					},
				},
			},
			NPC������ = { ... },
		},
	},
	[DK.HEAL] = { ... },
	[DK.BE_HEAL] = { ... },
	[DK.BE_DAMAGE] = { ... },
}
]]
local SKILL_RESULT = {
	HIT     = 0, -- ����
	BLOCK   = 1, -- ��
	SHIELD  = 2, -- ��Ч
	MISS    = 3, -- ƫ��
	DODGE   = 4, -- ����
	CRITICAL= 5, -- ����
	INSIGHT = 6, -- ʶ��
}
local NZ_SKILL_RESULT = {
	[SKILL_RESULT.BLOCK ] = true,
	[SKILL_RESULT.SHIELD] = true,
	[SKILL_RESULT.MISS  ] = true,
	[SKILL_RESULT.DODGE ] = true,
}
local AWAYTIME_TYPE = {
	DEATH          = 0,
	OFFLINE        = 1,
	HALFWAY_JOINED = 2,
}
local VERSION = 1

local D = {}
local O = {
	bSaveHistory      = false,
	nMaxHistory       = 10,
	nMinFightTime     = 30,
	bRecEverything    = true,
}
local Data          -- ��ǰս�����ݼ�¼
local History = {}  -- ��ʷս����¼
local SZ_REC_FILE = {'cache/fight_recount_log.jx3dat', PATH_TYPE.ROLE}

-- �������������Сһ����Ǹ� ����-1��ʾ����ֵ
local function Min(a, b)
	if a == -1 then
		return b
	end
	if b == -1 then
		return a
	end
	return min(a, b)
end

-- ##################################################################################################
--             #                 #         #             #         #                 # # # # # # #
--   # # # # # # # # # # #       #   #     #             #         #         # # #   #     #     #
--       #     #     #         #     #     #             # # # #   #           #     #     #     #
--       # # # # # # #         #     # # # # # # #       #     #   # #         #     # # # # # # #
--             #             # #   #       #           #       #   #   #       #     #     #     #
--     # # # # # # # # #       #           #           #       #   #     #   # # #   #     #     #
--             #       #       #           #         #   #   #     #     #     #     # # # # # # #
--   # # # # # # # # # # #     #   # # # # # # # #       #   #     #           #           #
--             #       #       #           #               #       #           #     # # # # # # #
--     # # # # # # # # #       #           #             #   #     #           # #         #
--             #               #           #           #       #             # #           #
--           # #               #           #         #           # # # # #         # # # # # # # #
-- ##################################################################################################
-- ��½��Ϸ���ر��������
function D.LoadData()
	local data = LIB.LoadLUAData(SZ_REC_FILE, { passphrase = false })
	if data then
		if data.bSaveHistory or data.History then
			History = data.History or {}
			for i = #History, 1, -1 do
				if History[i][DK.VERSION] ~= VERSION then
					remove(History, i)
				end
			end
		end
		O.bSaveHistory      = data.bSaveHistory or false
		O.nMaxHistory       = data.nMaxHistory   or 10
		O.nMinFightTime     = data.nMinFightTime or 30
		O.bRecEverything    = LIB.FormatDataStructure(data.bRecEverything, false)
	end
	D.Init()
end

-- �˳���Ϸ��������
function D.SaveData()
	local data = {
		History = O.bSaveHistory and History or nil,
		bSaveHistory      = O.bSaveHistory,
		nMaxHistory       = O.nMaxHistory,
		nMinFightTime     = O.nMinFightTime,
		bRecEverything    = O.bRecEverything,
	}
	LIB.SaveLUAData(SZ_REC_FILE, data, { passphrase = false })
end

-- ��ͼ�����ǰս������
do
local function onLoadingEnding()
	D.Flush()
	D.Init(true)
	FireUIEvent('MY_RECOUNT_NEW_FIGHT')
end
LIB.RegisterEvent('LOADING_ENDING', onLoadingEnding)
LIB.RegisterEvent('RELOAD_UI_ADDON_END', onLoadingEnding)
end

-- �˳�ս�� ��������
LIB.RegisterEvent('MY_FIGHT_HINT', function(event)
	if arg0 and LIB.GetFightUUID() ~= Data[DK.UUID] then -- �����µ�ս��
		D.Init()
		FireUIEvent('MY_RECOUNT_NEW_FIGHT')
	else
		D.Flush()
	end
	D.InsertEverything(Data, 'FIGHT_TIME', LIB.IsFighting(), LIB.GetFightUUID(), LIB.GetFightTime())
end)
LIB.BreatheCall('MY_Recount_FightTime', 1000, function()
	if LIB.IsFighting() then
		Data[DK.TIME_DURING] = GetCurrentTime() - Data[DK.TIME_BEGIN]
		for _, szRecordType in ipairs({DK.DAMAGE, DK.HEAL, DK.BE_DAMAGE, DK.BE_HEAL}) do
			local tInfo = Data[szRecordType]
			local tSnapshot = {
				[DK_REC_SNAPSHOT.TIME_DURING ] = Data[DK.TIME_DURING],
				[DK_REC_SNAPSHOT.TOTAL       ] = tInfo[DK_REC.TOTAL],
				[DK_REC_SNAPSHOT.TOTAL_EFFECT] = tInfo[DK_REC.TOTAL_EFFECT],
				[DK_REC_SNAPSHOT.STATISTICS  ] = {},
			}
			for k, v in pairs(tInfo[DK_REC.STATISTICS]) do
				tSnapshot[DK_REC_SNAPSHOT.STATISTICS][k] = {
					[DK_REC_SNAPSHOT_STAT.TOTAL] = v[DK_REC_STAT.TOTAL],
					[DK_REC_SNAPSHOT_STAT.TOTAL_EFFECT] = v.nTotalEffect,
				}
			end
			insert(Data[szRecordType][DK_REC.SNAPSHOTS], tSnapshot)
		end
	end
end)

-- ################################################################################################## --
--                             #           #             #       #                                    --
--     # # # # # # # # #         #         #             #         #           # # # # # # # # #      --
--         #       #                       #             #   # # # # # # #     #               #      --
--         #       #         # # # # #     # # # #   # # # #   #       #       #               #      --
--         #       #           #         #     #         #       #   #         #               #      --
--         #       #           #       #   #   #         #   # # # # # # #     #               #      --
--   # # # # # # # # # # #     # # # #     #   #         # #       #           #               #      --
--         #       #           #     #     #   #     # # #   # # # # # # #     #               #      --
--         #       #           #     #     #   #         #       #     #       #               #      --
--       #         #           #     #       #           #     # #     #       # # # # # # # # #      --
--       #         #           #     #     #   #         #         # #         #               #      --
--     #           #         #     # #   #       #     # #   # # #     # #                            --
-- ################################################################################################## --
-- ��ȡͳ������
-- (table) D.Get(nIndex) -- ��ȡָ����¼
--     (number)nIndex: ��ʷ��¼���� Ϊ0���ص�ǰͳ��
-- (table) D.Get()       -- ��ȡ������ʷ��¼�б�
function D.Get(nIndex)
	if not nIndex then
		return History
	elseif nIndex == 0 then
		return Data
	else
		return History[nIndex]
	end
end

-- ɾ����ʷͳ������
-- (table) D.Del(nIndex) -- ɾ��ָ����ŵļ�¼
--     (number)nIndex: ��ʷ��¼����
-- (table) D.Del(data)   -- ɾ��ָ����¼
function D.Del(data)
	if type(data) == 'number' then
		remove(History, data)
	else
		for i = #History, 1, -1 do
			if History[i] == data then
				remove(History, i)
			end
		end
	end
end

-- ��������ʱ��
-- D.GeneAwayTime(data, dwID, szRecordType)
-- data: ����
-- dwID: ��������Ľ�ɫID Ϊ��������Ŷӵ�����ʱ�䣨Ŀǰ��ԶΪ0��
-- szRecordType: ��ͬ���͵������ڹٷ�ʱ���㷨�¼��������ܲ�һ��
--               ö����ʱ�� DK.HEAL DK.DAMAGE DK.BE_DAMAGE DK.BE_HEAL ����
function D.GeneAwayTime(data, dwID, szRecordType)
	local nFightTime = D.GeneFightTime(data, dwID, szRecordType)
	local nAwayTime
	if szRecordType and data[szRecordType] and data[szRecordType][DK_REC.TIME_DURING] then
		nAwayTime = data[szRecordType][DK_REC.TIME_DURING] - nFightTime
	else
		nAwayTime = data[DK.TIME_DURING] - nFightTime
	end
	return max(nAwayTime, 0)
end

-- ����ս��ʱ��
-- D.GeneFightTime(data, dwID, szRecordType)
-- data: ����
-- szRecordType: ��ͬ���͵������ڹٷ�ʱ���㷨�¼��������ܲ�һ��
--               ö����ʱ�� DK.HEAL DK.DAMAGE DK.BE_DAMAGE DK.BE_HEAL ����
--               Ϊ���������ͨʱ���㷨
-- dwID: ����ս��ʱ��Ľ�ɫID Ϊ��������Ŷӵ�ս��ʱ��
function D.GeneFightTime(data, szRecordType, dwID)
	local nTimeDuring = data[DK.TIME_DURING]
	local nTimeBegin  = data[DK.TIME_BEGIN]
	if szRecordType and data[szRecordType] and data[szRecordType][DK_REC.TIME_DURING] then
		nTimeDuring = data[szRecordType][DK_REC.TIME_DURING]
	end
	if dwID and data[DK.AWAYTIME] and data[DK.AWAYTIME][dwID] then
		for _, rec in ipairs(data[DK.AWAYTIME][dwID]) do
			local nAwayBegin = max(rec[1], nTimeBegin)
			local nAwayEnd   = rec[2]
			if nAwayEnd then -- �������뿪��¼
				nTimeDuring = nTimeDuring - (nAwayEnd - nAwayBegin)
			else -- �뿪������û�����ļ�¼
				nTimeDuring = nTimeDuring - (data[DK.TIME_BEGIN] + nTimeDuring - nAwayBegin)
				break
			end
		end
	end
	return max(nTimeDuring, 0)
end

-- ################################################################################################## --
--         #       #             #                     #     # # # # # # #       #     # # # # #      --
--     #   #   #   #             #     # # # # # #       #   #   #   #   #       #     #       #      --
--         #       #             #     #         #           #   #   #   #   # # # #   # # # # #      --
--   # # # # # #   # # # #   # # # #   # # # # # #           # # # # # # #     #                      --
--       # #     #     #         #     #     #       # # #       #             # #   # # # # # # #    --
--     #   # #     #   #         #     # # # # # #       #       # # # # #   #   #     #       #      --
--   #     #   #   #   #         # #   #     #           #   # #         #   # # # #   # # # # #      --
--       #         #   #     # # #     # # # # # #       #       #     #         #     #       #      --
--   # # # # #     #   #         #     # #       #       #         # #           # #   # # # # #      --
--     #     #       #           #   #   #       #       #   # # #           # # #     #       # #    --
--       # #       #   #         #   #   # # # # #     #   #                     #   # # # # # #      --
--   # #     #   #       #     # # #     #       #   #       # # # # # # #       #             #      --
-- ################################################################################################## --
-- ��¼һ��LOG
-- D.OnSkillEffect(dwCaster, dwTarget, nEffectType, dwID, dwLevel, nSkillResult, nResultCount, tResult)
-- (number) dwCaster    : �ͷ���ID
-- (number) dwTarget    : ������ID
-- (number) nEffectType : ���Ч����ԭ��SKILL_EFFECT_TYPEö�� ��SKILL,BUFF��
-- (number) dwID        : ����ID
-- (number) dwLevel     : ���ܵȼ�
-- (number) nSkillResult: ��ɵ�Ч�������SKILL_RESULTö�� ��HIT,MISS��
-- (number) nResultCount      : ���Ч������ֵ������tResult���ȣ�
-- (table ) tResult     : ����Ч����ֵ����
function D.OnSkillEffect(dwCaster, dwTarget, nEffectType, dwEffectID, dwEffectLevel, nSkillResult, nResultCount, tResult)
	-- ��ȡ�ͷŶ���ͳ��ܶ���
	local KCaster = LIB.GetObject(dwCaster)
	if KCaster and not IsPlayer(dwCaster)
	and KCaster.dwEmployer and KCaster.dwEmployer ~= 0 then -- �����������������ͳ����
		KCaster = LIB.GetObject(KCaster.dwEmployer)
	end
	local KTarget, dwTargetEmployer = LIB.GetObject(dwTarget), nil
	if KTarget and not IsPlayer(dwTarget)
	and KTarget.dwEmployer and KTarget.dwEmployer ~= 0 then
		dwTargetEmployer = KTarget.dwEmployer
	end
	if not (KCaster and KTarget) then
		return
	end
	dwCaster = KCaster.dwID
	dwTarget = KTarget.dwID

	-- ���˵����Ƕ��ѵ��Լ�����BOSS��
	local me = GetClientPlayer()
	if dwCaster ~= me.dwID                 -- �ͷ��߲����Լ�
	and dwTarget ~= me.dwID                -- �����߲����Լ�
	and dwTargetEmployer ~= me.dwID        -- ���������˲����Լ�
	and not LIB.IsInArena()                 -- ���ھ�����
	and not LIB.IsInBattleField()           -- ����ս��
	and not me.IsPlayerInMyParty(dwCaster) -- ���ͷ��߲��Ƕ���
	and not me.IsPlayerInMyParty(dwTarget) -- �ҳ����߲��Ƕ���
	and not (dwTargetEmployer and me.IsPlayerInMyParty(dwTargetEmployer)) -- �ҳ��������˲��Ƕ���
	then -- �����
		return
	end

	-- δ��ս���ʼ��ͳ�����ݣ���Ĭ�ϵ�ǰ֡���еļ�����־Ϊ��ս���ܣ�
	if not LIB.GetFightUUID() and
	D.nLastAutoInitFrame ~= GetLogicFrameCount() then
		D.nLastAutoInitFrame = GetLogicFrameCount()
		D.Init(true)
	end

	-- ��ȡЧ������
	local szEffectID = D.InitEffectData(Data, nEffectType, dwEffectID, dwEffectLevel)
	local nTherapy = tResult[SKILL_RESULT_TYPE.THERAPY] or 0
	local nEffectTherapy = tResult[SKILL_RESULT_TYPE.EFFECTIVE_THERAPY] or 0
	local nDamage = (tResult[SKILL_RESULT_TYPE.PHYSICS_DAMAGE      ] or 0) + -- �⹦�˺�
					(tResult[SKILL_RESULT_TYPE.SOLAR_MAGIC_DAMAGE  ] or 0) + -- �����ڹ��˺�
					(tResult[SKILL_RESULT_TYPE.NEUTRAL_MAGIC_DAMAGE] or 0) + -- ��Ԫ���ڹ��˺�
					(tResult[SKILL_RESULT_TYPE.LUNAR_MAGIC_DAMAGE  ] or 0) + -- �����ڹ��˺�
					(tResult[SKILL_RESULT_TYPE.POISON_DAMAGE       ] or 0) + -- �����˺�
					(tResult[SKILL_RESULT_TYPE.REFLECTIED_DAMAGE   ] or 0)   -- �����˺�
	local nEffectDamage = tResult[SKILL_RESULT_TYPE.EFFECTIVE_DAMAGE] or 0

	D.InsertEverything(Data,
		'SKILL_EFFECT', dwCaster, dwTarget,
		nEffectType, dwEffectID, dwEffectLevel, szEffectID,
		nSkillResult, nTherapy, nEffectTherapy, nDamage, nEffectDamage,
		tResult)

	-- ʶ��
	local nValue = tResult[SKILL_RESULT_TYPE.INSIGHT_DAMAGE]
	if nValue and nValue > 0 then
		D.AddDamageRecord(Data, dwCaster, dwTarget, szEffectID, nDamage, nEffectDamage, SKILL_RESULT.INSIGHT)
	elseif nSkillResult == SKILL_RESULT.HIT -- ����
		or nSkillResult == SKILL_RESULT.CRITICAL -- ����
	then
		if nTherapy > 0 then -- ������
			D.AddHealRecord(Data, dwCaster, dwTarget, szEffectID, nTherapy, nEffectTherapy, nSkillResult)
		end
		if nDamage > 0 or nTherapy == 0 then -- ���˺� ���� ���˺������Ƶ�Ч��
			D.AddDamageRecord(Data, dwCaster, dwTarget, szEffectID, nDamage, nEffectDamage, nSkillResult)
		end
	elseif nSkillResult == SKILL_RESULT.BLOCK  -- ��
		or nSkillResult == SKILL_RESULT.SHIELD -- ��Ч
		or nSkillResult == SKILL_RESULT.MISS   -- ƫ��
		or nSkillResult == SKILL_RESULT.DODGE  -- ����
	then
		D.AddDamageRecord(Data, dwCaster, dwTarget, szEffectID, 0, 0, nSkillResult)
	end

	Data[DK.TIME_DURING] = GetCurrentTime() - Data[DK.TIME_BEGIN]
	Data[DK.TICK_DURING] = GetTime() - Data[DK.TICK_BEGIN]
end

-- ͨ��ID��������
function D.GetNameAusID(data, dwID)
	if not data or not dwID then
		return
	end
	return data[DK.NAME_LIST][dwID] or g_tStrings.STR_NAME_UNKNOWN
end

-- ͨ��ID��������
function D.GetForceAusID(data, dwID)
	if not data or not dwID then
		return
	end
	return data[DK.FORCE_LIST][dwID] or -1
end

-- ͨ��ID����Ч����Ϣ
function D.GetEffectInfoAusID(data, szEffectID)
	if not data or not szEffectID then
		return
	end
	return unpack(data[DK.EFFECT_LIST][szEffectID] or CONSTANT.EMPTY_TABLE)
end

-- ͨ��ID��;����Ч����
function D.GetEffectNameAusID(data, szChannel, szEffectID)
	if not data or not szChannel or not szEffectID then
		return
	end
	local info = data[DK.EFFECT_LIST][szEffectID]
	if info and not IsEmpty(info[1]) then
		if info[3] == SKILL_EFFECT_TYPE.BUFF then
			if szChannel == DK.HEAL or szChannel == DK.BE_HEAL then
				return info[1] .. '(HOT)'
			end
			return info[1] .. '(DOT)'
		end
		return info[1]
	end
end

-- �ж��Ƿ����Ѿ�
function D.IsParty(id)
	local dwID = tonumber(id)
	if dwID then
		if dwID == UI_GetClientPlayerID() then
			return true
		else
			return IsParty(dwID, UI_GetClientPlayerID())
		end
	else
		return false
	end
end

-- ���븴������
function D.InsertEverything(data, szName, ...)
	if not O.bRecEverything then
		return
	end
	insert(data[DK.EVERYTHING], {GetLogicFrameCount(), GetCurrentTime(), GetTime(), szName, ...})
end

-- ��һ����¼��������
function D.InsertRecord(data, szRecordType, idRecord, idTarget, szEffectName, nValue, nEffectValue, nSkillResult)
	local tInfo   = data[szRecordType]
	local tRecord = tInfo[DK_REC.STATISTICS][idRecord]
	if not szEffectName or szEffectName == '' then
		return
	end
	------------------------
	-- # �ڣ� tInfo
	------------------------
	tInfo[DK_REC.TIME_DURING ] = GetCurrentTime() - data[DK.TIME_BEGIN]
	tInfo[DK_REC.TOTAL       ] = tInfo[DK_REC.TOTAL] + nValue
	tInfo[DK_REC.TOTAL_EFFECT] = tInfo[DK_REC.TOTAL_EFFECT] + nEffectValue
	------------------------
	-- # �ڣ� tRecord
	------------------------
	tRecord[DK_REC_STAT.TOTAL       ] = tRecord[DK_REC_STAT.TOTAL] + nValue
	tRecord[DK_REC_STAT.TOTAL_EFFECT] = tRecord[DK_REC_STAT.TOTAL_EFFECT] + nEffectValue
	------------------------
	-- # �ڣ� tRecord.Detail
	------------------------
	-- ���/���½������ͳ��
	if not tRecord[DK_REC_STAT.DETAIL][nSkillResult] then
		tRecord[DK_REC_STAT.DETAIL][nSkillResult] = {
			[DK_REC_STAT_DETAIL.COUNT        ] =  0, -- ���м�¼����������nSkillResult�����У�
			[DK_REC_STAT_DETAIL.NZ_COUNT     ] =  0, -- ����ֵ���м�¼����
			[DK_REC_STAT_DETAIL.MAX          ] =  0, -- �����������ֵ
			[DK_REC_STAT_DETAIL.MAX_EFFECT   ] =  0, -- �������������Чֵ
			[DK_REC_STAT_DETAIL.MIN          ] = -1, -- ����������Сֵ
			[DK_REC_STAT_DETAIL.NZ_MIN       ] = -1, -- ���η���ֵ������Сֵ
			[DK_REC_STAT_DETAIL.MIN_EFFECT   ] = -1, -- ����������С��Чֵ
			[DK_REC_STAT_DETAIL.NZ_MIN_EFFECT] = -1, -- ���η���ֵ������С��Чֵ
			[DK_REC_STAT_DETAIL.TOTAL        ] =  0, -- �����������˺�
			[DK_REC_STAT_DETAIL.TOTAL_EFFECT ] =  0, -- ������������Ч�˺�
			[DK_REC_STAT_DETAIL.AVG          ] =  0, -- ��������ƽ���˺�
			[DK_REC_STAT_DETAIL.NZ_AVG       ] =  0, -- ���з���ֵ����ƽ���˺�
			[DK_REC_STAT_DETAIL.AVG_EFFECT   ] =  0, -- ��������ƽ����Ч�˺�
			[DK_REC_STAT_DETAIL.NZ_AVG_EFFECT] =  0, -- ���з���ֵ����ƽ����Ч�˺�
		}
	end
	local tResult = tRecord[DK_REC_STAT.DETAIL][nSkillResult]
	tResult[DK_REC_STAT_DETAIL.COUNT     ] = tResult[DK_REC_STAT_DETAIL.COUNT] + 1 -- ���д���������nSkillResult�����У�
	tResult[DK_REC_STAT_DETAIL.MAX       ] = max(tResult[DK_REC_STAT_DETAIL.MAX], nValue) -- �����������ֵ
	tResult[DK_REC_STAT_DETAIL.MAX_EFFECT] = max(tResult[DK_REC_STAT_DETAIL.MAX_EFFECT], nEffectValue) -- �������������Чֵ
	tResult[DK_REC_STAT_DETAIL.MIN       ] = Min(tResult[DK_REC_STAT_DETAIL.MIN], nValue) -- ����������Сֵ
	tResult[DK_REC_STAT_DETAIL.MIN_EFFECT] = Min(tResult[DK_REC_STAT_DETAIL.MIN_EFFECT], nEffectValue) -- ����������С��Чֵ
	tResult[DK_REC_STAT_DETAIL.TOTAL       ] = tResult[DK_REC_STAT_DETAIL.TOTAL] + nValue -- �����������˺�
	tResult[DK_REC_STAT_DETAIL.TOTAL_EFFECT] = tResult[DK_REC_STAT_DETAIL.TOTAL_EFFECT] + nEffectValue -- ������������Ч�˺�
	tResult[DK_REC_STAT_DETAIL.AVG         ] = floor(tResult[DK_REC_STAT_DETAIL.TOTAL] / tResult[DK_REC_STAT_DETAIL.COUNT]) -- ��������ƽ��ֵ
	tResult[DK_REC_STAT_DETAIL.AVG_EFFECT  ] = floor(tResult[DK_REC_STAT_DETAIL.TOTAL_EFFECT] / tResult[DK_REC_STAT_DETAIL.COUNT]) -- ��������ƽ����Чֵ
	if nValue ~= 0 or NZ_SKILL_RESULT[nSkillResult] then
		tResult[DK_REC_STAT_DETAIL.NZ_COUNT] = tResult[DK_REC_STAT_DETAIL.NZ_COUNT] + 1 -- ���д���������nSkillResult�����У�
		tResult[DK_REC_STAT_DETAIL.NZ_MIN  ] = Min(tResult[DK_REC_STAT_DETAIL.NZ_MIN], nValue) -- ����������Сֵ
		tResult[DK_REC_STAT_DETAIL.NZ_MIN_EFFECT] = Min(tResult[DK_REC_STAT_DETAIL.NZ_MIN_EFFECT], nEffectValue) -- ����������С��Чֵ
		tResult[DK_REC_STAT_DETAIL.NZ_AVG       ] = floor(tResult[DK_REC_STAT_DETAIL.TOTAL] / tResult[DK_REC_STAT_DETAIL.NZ_COUNT]) -- ��������ƽ��ֵ
		tResult[DK_REC_STAT_DETAIL.NZ_AVG_EFFECT] = floor(tResult[DK_REC_STAT_DETAIL.TOTAL_EFFECT] / tResult[DK_REC_STAT_DETAIL.NZ_COUNT]) -- ��������ƽ����Чֵ
	end

	------------------------
	-- # �ڣ� tRecord.Skill
	------------------------
	-- ��Ӿ��弼�ܼ�¼
	if not tRecord[DK_REC_STAT.SKILL][szEffectName] then
		tRecord[DK_REC_STAT.SKILL][szEffectName] = {
			nCount       =  0, -- ����������ֻ��ͷŴ���������szEffectName�������ֻأ�
			nNzCount     =  0, -- ����ҷ���ֵ�����ֻ��ͷŴ���
			nMax         =  0, -- ����������ֻ���������
			nMaxEffect   =  0, -- ����������ֻ������Ч�����
			nTotal       =  0, -- ����������ֻ�������ܺ�
			nTotalEffect =  0, -- ����������ֻ���Ч������ܺ�
			nAvg         =  0, -- ��������������ֻ�ƽ���˺�
			nNzAvg       =  0, -- ��������з���ֵ�����ֻ�ƽ���˺�
			nAvgEffect   =  0, -- ��������������ֻ�ƽ����Ч�˺�
			nNzAvgEffect =  0, -- ��������з���ֵ�����ֻ�ƽ����Ч�˺�
			Detail       = {}, -- ����������ֻ�����������ͳ��
			Target       = {}, -- ����������ֻس�����ͳ��
		}
	end
	local tSkillRecord = tRecord[DK_REC_STAT.SKILL][szEffectName]
	tSkillRecord.nCount       = tSkillRecord.nCount + 1
	tSkillRecord.nMax         = max(tSkillRecord.nMax, nValue)
	tSkillRecord.nMaxEffect   = max(tSkillRecord.nMaxEffect, nEffectValue)
	tSkillRecord.nTotal       = tSkillRecord.nTotal + nValue
	tSkillRecord.nTotalEffect = tSkillRecord.nTotalEffect + nEffectValue
	tSkillRecord.nAvg         = floor(tSkillRecord.nTotal / tSkillRecord.nCount)
	tSkillRecord.nAvgEffect   = floor(tSkillRecord.nTotalEffect / tSkillRecord.nCount)
	if nValue ~= 0 or NZ_SKILL_RESULT[nSkillResult] then
		tSkillRecord.nNzCount     = tSkillRecord.nNzCount + 1
		tSkillRecord.nNzAvg       = floor(tSkillRecord.nTotal / tSkillRecord.nNzCount)
		tSkillRecord.nNzAvgEffect = floor(tSkillRecord.nTotalEffect / tSkillRecord.nNzCount)
	end

	---------------------------------
	-- # �ڣ� tRecord.Skill[x].Detail
	---------------------------------
	-- ���/���¾��弼�ܽ������ͳ��
	if not tSkillRecord.Detail[nSkillResult] then
		tSkillRecord.Detail[nSkillResult] = {
			nCount       =  0, -- ���м�¼����
			nNzCount     =  0, -- ����ֵ���м�¼����
			nMax         =  0, -- �����������ֵ
			nMaxEffect   =  0, -- �������������Чֵ
			nMin         = -1, -- ����������Сֵ
			nNzMin       = -1, -- ���η���ֵ������Сֵ
			nMinEffect   = -1, -- ����������С��Чֵ
			nNzMinEffect = -1, -- ���η���ֵ������С��Чֵ
			nTotal       =  0, -- �����������˺�
			nTotalEffect =  0, -- ������������Ч�˺�
			nAvg         =  0, -- ��������ƽ���˺�
			nNzAvg       =  0, -- ���з���ֵ����ƽ���˺�
			nAvgEffect   =  0, -- ��������ƽ����Ч�˺�
			nNzAvgEffect =  0, -- ���з���ֵ����ƽ����Ч�˺�
		}
	end
	local tResult = tSkillRecord.Detail[nSkillResult]
	tResult.nCount       = tResult.nCount + 1                           -- ���д���������nSkillResult�����У�
	tResult.nMax         = max(tResult.nMax, nValue)               -- �����������ֵ
	tResult.nMaxEffect   = max(tResult.nMaxEffect, nEffectValue)   -- �������������Чֵ
	tResult.nMin         = (tResult.nMin ~= -1 and min(tResult.nMin, nValue)) or nValue                         -- ����������Сֵ
	tResult.nMinEffect   = (tResult.nMinEffect ~= -1 and min(tResult.nMinEffect, nEffectValue)) or nEffectValue -- ����������С��Чֵ
	tResult.nTotal       = tResult.nTotal + nValue                      -- �����������˺�
	tResult.nTotalEffect = tResult.nTotalEffect + nEffectValue          -- ������������Ч�˺�
	tResult.nAvg         = floor(tResult.nTotal / tResult.nCount)
	tResult.nAvgEffect   = floor(tResult.nTotalEffect / tResult.nCount)
	if nValue ~= 0 or NZ_SKILL_RESULT[nSkillResult] then
		tResult.nNzCount     = tResult.nNzCount + 1                           -- ���д���������nSkillResult�����У�
		tResult.nNzMin       = (tResult.nNzMin ~= -1 and min(tResult.nNzMin, nValue)) or nValue                         -- ����������Сֵ
		tResult.nNzMinEffect = (tResult.nNzMinEffect ~= -1 and min(tResult.nNzMinEffect, nEffectValue)) or nEffectValue -- ����������С��Чֵ
		tResult.nNzAvg       = floor(tResult.nTotal / tResult.nNzCount)
		tResult.nNzAvgEffect = floor(tResult.nTotalEffect / tResult.nNzCount)
	end

	------------------------------
	-- # �ڣ� tRecord.Skill.Target
	------------------------------
	-- ��Ӿ��弼�ܳ����߼�¼
	if not tSkillRecord.Target[idTarget] then
		tSkillRecord.Target[idTarget] = {
			nMax         = 0,            -- ����������ֻػ��е�����������˺�
			nMaxEffect   = 0,            -- ����������ֻػ��е������������Ч�˺�
			nTotal       = 0,            -- ����������ֻػ��е��������˺��ܺ�
			nTotalEffect = 0,            -- ����������ֻػ��е���������Ч�˺��ܺ�
			Count = {                    -- ����������ֻػ��е������ҽ��ͳ��
				-- [SKILL_RESULT.HIT     ] = 5,
				-- [SKILL_RESULT.MISS    ] = 3,
				-- [SKILL_RESULT.CRITICAL] = 3,
			},
			NzCount = {                  -- ����ҷ���ֵ�����ֻػ��е������ҽ��ͳ��
				-- [SKILL_RESULT.HIT     ] = 5,
				-- [SKILL_RESULT.MISS    ] = 3,
				-- [SKILL_RESULT.CRITICAL] = 3,
			},
		}
	end
	local tSkillTargetData = tSkillRecord.Target[idTarget]
	tSkillTargetData.nMax                = max(tSkillTargetData.nMax, nValue)
	tSkillTargetData.nMaxEffect          = max(tSkillTargetData.nMaxEffect, nEffectValue)
	tSkillTargetData.nTotal              = tSkillTargetData.nTotal + nValue
	tSkillTargetData.nTotalEffect        = tSkillTargetData.nTotalEffect + nEffectValue
	tSkillTargetData.Count[nSkillResult] = (tSkillTargetData.Count[nSkillResult] or 0) + 1
	if nValue ~= 0 then
		tSkillTargetData.NzCount[nSkillResult] = (tSkillTargetData.NzCount[nSkillResult] or 0) + 1
	end

	------------------------
	-- # �ڣ� tRecord.Target
	------------------------
	-- ��Ӿ������/�ͷ��߼�¼
	if not tRecord[DK_REC_STAT.TARGET][idTarget] then
		tRecord[DK_REC_STAT.TARGET][idTarget] = {
			nCount       =  0, -- ����Ҷ�idTarget�ļ����ͷŴ���
			nNzCount     =  0, -- ����Ҷ�idTarget�ķ���ֵ�����ͷŴ���
			nMax         =  0, -- ����Ҷ�idTarget�ļ�����������
			nMaxEffect   =  0, -- ����Ҷ�idTarget�ļ��������Ч�����
			nTotal       =  0, -- ����Ҷ�idTarget�ļ���������ܺ�
			nTotalEffect =  0, -- ����Ҷ�idTarget�ļ�����Ч������ܺ�
			nAvg         =  0, -- ����Ҷ�idTarget�ļ���ƽ�������
			nNzAvg       =  0, -- ����Ҷ�idTarget�ķ���ֵ����ƽ�������
			nAvgEffect   =  0, -- ����Ҷ�idTarget�ļ���ƽ����Ч�����
			nNzAvgEffect =  0, -- ����Ҷ�idTarget�ķ���ֵ����ƽ����Ч�����
			Detail       = {}, -- ����Ҷ�idTarget�ļ�������������ͳ��
			Skill        = {}, -- ����Ҷ�idTarget�ļ��ܾ���ֱ�ͳ��
		}
	end
	local tTargetRecord = tRecord[DK_REC_STAT.TARGET][idTarget]
	tTargetRecord.nCount       = tTargetRecord.nCount + 1
	tTargetRecord.nMax         = max(tTargetRecord.nMax, nValue)
	tTargetRecord.nMaxEffect   = max(tTargetRecord.nMaxEffect, nEffectValue)
	tTargetRecord.nTotal       = tTargetRecord.nTotal + nValue
	tTargetRecord.nTotalEffect = tTargetRecord.nTotalEffect + nEffectValue
	tTargetRecord.nAvg         = floor(tTargetRecord.nTotal / tTargetRecord.nCount)
	tTargetRecord.nAvgEffect   = floor(tTargetRecord.nTotalEffect / tTargetRecord.nCount)
	if nValue ~= 0 or NZ_SKILL_RESULT[nSkillResult] then
		tTargetRecord.nNzCount     = tTargetRecord.nNzCount + 1
		tTargetRecord.nNzAvg       = floor(tTargetRecord.nTotal / tTargetRecord.nNzCount)
		tTargetRecord.nNzAvgEffect = floor(tTargetRecord.nTotalEffect / tTargetRecord.nNzCount)
	end

	----------------------------------
	-- # �ڣ� tRecord.Target[x].Detail
	----------------------------------
	-- ���/���¾������/�ͷ��߽������ͳ��
	if not tTargetRecord.Detail[nSkillResult] then
		tTargetRecord.Detail[nSkillResult] = {
			nCount       =  0, -- ���м�¼����������nSkillResult�����У�
			nNzCount     =  0, -- ����ֵ���м�¼����
			nMax         =  0, -- �����������ֵ
			nMaxEffect   =  0, -- �������������Чֵ
			nMin         = -1, -- ����������Сֵ
			nNzMin       = -1, -- ���η���ֵ������Сֵ
			nMinEffect   = -1, -- ����������С��Чֵ
			nNzMinEffect = -1, -- ���η���ֵ������С��Чֵ
			nTotal       =  0, -- �����������˺�
			nTotalEffect =  0, -- ������������Ч�˺�
			nAvg         =  0, -- ��������ƽ���˺�
			nNzAvg       =  0, -- ���з���ֵ����ƽ���˺�
			nAvgEffect   =  0, -- ��������ƽ����Ч�˺�
			nNzAvgEffect =  0, -- ���з���ֵ����ƽ����Ч�˺�
		}
	end
	local tResult = tTargetRecord.Detail[nSkillResult]
	tResult.nCount       = tResult.nCount + 1                           -- ���д���������nSkillResult�����У�
	tResult.nMax         = max(tResult.nMax, nValue)               -- �����������ֵ
	tResult.nMaxEffect   = max(tResult.nMaxEffect, nEffectValue)   -- �������������Чֵ
	tResult.nMin         = (tResult.nMin ~= -1 and min(tResult.nMin, nValue)) or nValue                         -- ����������Сֵ
	tResult.nMinEffect   = (tResult.nMinEffect ~= -1 and min(tResult.nMinEffect, nEffectValue)) or nEffectValue -- ����������С��Чֵ
	tResult.nTotal       = tResult.nTotal + nValue                      -- �����������˺�
	tResult.nTotalEffect = tResult.nTotalEffect + nEffectValue          -- ������������Ч�˺�
	tResult.nAvg         = floor(tResult.nTotal / tResult.nCount)
	tResult.nAvgEffect   = floor(tResult.nTotalEffect / tResult.nCount)
	if nValue ~= 0 or NZ_SKILL_RESULT[nSkillResult] then
		tResult.nNzCount       = tResult.nNzCount + 1                           -- ���д���������nSkillResult�����У�
		tResult.nNzMin         = (tResult.nNzMin ~= -1 and min(tResult.nNzMin, nValue)) or nValue                         -- ����������Сֵ
		tResult.nNzMinEffect   = (tResult.nNzMinEffect ~= -1 and min(tResult.nNzMinEffect, nEffectValue)) or nEffectValue -- ����������С��Чֵ
		tResult.nNzAvg         = floor(tResult.nTotal / tResult.nNzCount)
		tResult.nNzAvgEffect   = floor(tResult.nTotalEffect / tResult.nNzCount)
	end

	---------------------------------
	-- # �ڣ� tRecord.Target[x].Skill
	---------------------------------
	-- ��ӳ����߾��弼�ܼ�¼
	if not tTargetRecord.Skill[szEffectName] then
		tTargetRecord.Skill[szEffectName] = {
			nMax         = 0,            -- ����һ��������ҵ������ֻ�����˺�
			nMaxEffect   = 0,            -- ����һ��������ҵ������ֻ������Ч�˺�
			nTotal       = 0,            -- ����һ��������ҵ������ֻ��˺��ܺ�
			nTotalEffect = 0,            -- ����һ��������ҵ������ֻ���Ч�˺��ܺ�
			Count = {                    -- ����һ��������ҵ������ֻؽ��ͳ��
				-- [SKILL_RESULT.HIT     ] = 5,
				-- [SKILL_RESULT.MISS    ] = 3,
				-- [SKILL_RESULT.CRITICAL] = 3,
			},
			NzCount = {                    -- ����ҷ���ֵ���������ҵ������ֻؽ��ͳ��
				-- [SKILL_RESULT.HIT     ] = 5,
				-- [SKILL_RESULT.MISS    ] = 3,
				-- [SKILL_RESULT.CRITICAL] = 3,
			},
		}
	end
	local tTargetSkillData = tTargetRecord.Skill[szEffectName]
	tTargetSkillData.nMax                = max(tTargetSkillData.nMax, nValue)
	tTargetSkillData.nMaxEffect          = max(tTargetSkillData.nMaxEffect, nEffectValue)
	tTargetSkillData.nTotal              = tTargetSkillData.nTotal + nValue
	tTargetSkillData.nTotalEffect        = tTargetSkillData.nTotalEffect + nEffectValue
	tTargetSkillData.Count[nSkillResult] = (tTargetSkillData.Count[nSkillResult] or 0) + 1
	if nValue ~= 0 then
		tTargetSkillData.NzCount[nSkillResult] = (tTargetSkillData.NzCount[nSkillResult] or 0) + 1
	end
end

-- ����һ���˺���¼
function D.AddDamageRecord(data, dwCaster, dwTarget, szEffectID, nDamage, nEffectDamage, nSkillResult)
	-- ����˺���¼
	D.InitObjectData(data, dwCaster, DK.DAMAGE)
	D.InsertRecord(data, DK.DAMAGE, dwCaster, dwTarget, szEffectID, nDamage, nEffectDamage, nSkillResult)
	-- ��ӳ��˼�¼
	D.InitObjectData(data, dwTarget, DK.BE_DAMAGE)
	D.InsertRecord(data, DK.BE_DAMAGE, dwTarget, dwCaster, szEffectID, nDamage, nEffectDamage, nSkillResult)
end

-- ����һ�����Ƽ�¼
function D.AddHealRecord(data, dwCaster, dwTarget, szEffectID, nHeal, nEffectHeal, nSkillResult)
	-- ����˺���¼
	D.InitObjectData(data, dwCaster, DK.HEAL)
	D.InsertRecord(data, DK.HEAL, dwCaster, dwTarget, szEffectID, nHeal, nEffectHeal, nSkillResult)
	-- ��ӳ��˼�¼
	D.InitObjectData(data, dwTarget, DK.BE_HEAL)
	D.InsertRecord(data, DK.BE_HEAL, dwTarget, dwCaster, szEffectID, nHeal, nEffectHeal, nSkillResult)
end

-- ȷ�϶��������Ѵ�����δ�����򴴽���
function D.InitObjectData(data, dwID, szChannel)
	-- ���ƻ���
	if not data[DK.NAME_LIST][dwID] then
		data[DK.NAME_LIST][dwID] = LIB.GetObjectName(IsPlayer(dwID) and TARGET.PLAYER or TARGET.NPC, dwID, 'never') -- ���ƻ���
	end
	-- ��������
	if not data[DK.FORCE_LIST][dwID] then
		if IsPlayer(dwID) then
			local player = GetPlayer(dwID)
			if player then
				data[DK.FORCE_LIST][dwID] = player.dwForceID or 0
			end
		else
			data[DK.FORCE_LIST][dwID] = 0
		end
	end
	-- ͳ�ƽṹ��
	if not data[szChannel][DK_REC.STATISTICS][dwID] then
		data[szChannel][DK_REC.STATISTICS][dwID] = {
			szMD5        = dwID, -- Ψһ��ʶ
			[DK_REC_STAT.TOTAL       ] = 0 , -- �����
			[DK_REC_STAT.TOTAL_EFFECT] = 0 , -- ��Ч���
			[DK_REC_STAT.DETAIL      ] = {}, -- �����������ܽ������ͳ��
			[DK_REC_STAT.SKILL       ] = {}, -- ����Ҿ����������ļ���ͳ��
			[DK_REC_STAT.TARGET      ] = {}, -- ����Ҿ����˭��������ͳ��
		}
	end
end

function D.InitEffectData(data, nType, dwID, nLevel)
	local szKey = nType .. ',' .. dwID .. ',' .. nLevel
	if not data[DK.EFFECT_LIST][szKey] then
		local szName, bAnonymous
		if nType == SKILL_EFFECT_TYPE.SKILL then
			szName = Table_GetSkillName(dwID, nLevel)
		elseif nType == SKILL_EFFECT_TYPE.BUFF then
			szName = Table_GetBuffName(dwID, nLevel)
		end
		if not szName then
			bAnonymous = true
			szName = '#' .. dwID .. ',' .. nLevel
		end
		data[DK.EFFECT_LIST][szKey] = {szName, bAnonymous, nType, dwID, nLevel}
	end
	return szKey
end

-- ��ʼ��Data
do
local function GeneTypeNS()
	return {
		[DK_REC.TIME_DURING ] = 0,
		[DK_REC.TOTAL       ] = 0,
		[DK_REC.TOTAL_EFFECT] = 0,
		[DK_REC.SNAPSHOTS   ] = {},
		[DK_REC.STATISTICS  ] = {},
	}
end
function D.Init(bForceInit)
	if bForceInit or (not Data) or
	(Data[DK.UUID] and LIB.GetFightUUID() ~= Data[DK.UUID]) then
		Data = {
			[DK.UUID       ] = LIB.GetFightUUID(),                -- ս��Ψһ��ʶ
			[DK.VERSION    ] = VERSION,                           -- ���ݰ汾��
			[DK.TIME_BEGIN ] = GetCurrentTime(),                  -- ս����ʼʱ��
			[DK.TICK_BEGIN ] = GetTime(),                         -- ս����ʼ����ʱ��
			[DK.TIME_DURING] =  0,                                -- ս������ʱ��
			[DK.TICK_DURING] =  0,                                -- ս����������ʱ��
			[DK.AWAYTIME   ] = {},                                -- ����/����ʱ��ڵ�
			[DK.NAME_LIST  ] = {},                                -- ���ƻ���
			[DK.FORCE_LIST ] = {},                                -- ��������
			[DK.EFFECT_LIST] = {},                                -- Ч����Ϣ����
			[DK.DAMAGE     ] = GeneTypeNS(),                      -- ���ͳ��
			[DK.HEAL       ] = GeneTypeNS(),                      -- ����ͳ��
			[DK.BE_HEAL    ] = GeneTypeNS(),                      -- ����ͳ��
			[DK.BE_DAMAGE  ] = GeneTypeNS(),                      -- ����ͳ��
			[DK.EVERYTHING ] = {},                                -- ս������
		}
	end

	if not Data[DK.UUID] and LIB.GetFightUUID() then
		Data[DK.UUID] = LIB.GetFightUUID()
		Data[DK.TIME_BEGIN] = GetCurrentTime()
	end
end
end

-- Data����ѹ����ʷ��¼ �����³�ʼ��Data
function D.Flush()
	if not (Data and Data[DK.UUID]) then
		return
	end

	-- ���˿ռ�¼
	if IsEmpty(Data[DK.BE_DAMAGE][DK_REC.STATISTICS])
	and IsEmpty(Data[DK.DAMAGE][DK_REC.STATISTICS])
	and IsEmpty(Data[DK.HEAL][DK_REC.STATISTICS])
	and IsEmpty(Data[DK.BE_HEAL][DK_REC.STATISTICS]) then
		return
	end

	-- ������������������Ϊս������
	local nMaxValue, szBossName = 0, nil
	local nEnemyMaxValue, szEnemyBossName = 0, nil
	for id, p in pairs(Data[DK.BE_DAMAGE][DK_REC.STATISTICS]) do
		if nEnemyMaxValue < p.nTotalEffect and not D.IsParty(id) then
			nEnemyMaxValue  = p.nTotalEffect
			szEnemyBossName = D.GetNameAusID(Data, id)
		end
		if nMaxValue < p.nTotalEffect and id ~= UI_GetClientPlayerID() then
			nMaxValue  = p.nTotalEffect
			szBossName = D.GetNameAusID(Data, id)
		end
	end
	-- ���û�� ������������NPC������Ϊս������
	if not szBossName or not szEnemyBossName then
		for id, p in pairs(Data[DK.DAMAGE][DK_REC.STATISTICS]) do
			if nEnemyMaxValue < p.nTotalEffect and not D.IsParty(id) then
				nEnemyMaxValue  = p.nTotalEffect
				szEnemyBossName = D.GetNameAusID(Data, id)
			end
			if nMaxValue < p.nTotalEffect and not tonumber(id) then
				nMaxValue  = p.nTotalEffect
				szBossName = D.GetNameAusID(Data, id)
			end
		end
	end
	Data.szBossName = szEnemyBossName or szBossName or ''

	if Data[DK.TIME_DURING] > O.nMinFightTime then
		insert(History, 1, Data)
		while #History > O.nMaxHistory do
			remove(History)
		end
	end

	D.Init(true)
end

-- ϵͳ��־��أ�����Դ��
LIB.RegisterEvent('SYS_MSG', function()
	if arg0 == 'UI_OME_SKILL_CAST_LOG' then
		-- ����ʩ����־��
		-- (arg1)dwCaster������ʩ���� (arg2)dwSkillID������ID (arg3)dwLevel�����ܵȼ�
		-- D.OnSkillCast(arg1, arg2, arg3)
	elseif arg0 == 'UI_OME_SKILL_CAST_RESPOND_LOG' then
		-- ����ʩ�Ž����־��
		-- (arg1)dwCaster������ʩ���� (arg2)dwSkillID������ID
		-- (arg3)dwLevel�����ܵȼ� (arg4)nRespond����ö����[[SKILL_RESULT_CODE]]
		-- D.OnSkillCastRespond(arg1, arg2, arg3, arg4)
	elseif arg0 == 'UI_OME_SKILL_EFFECT_LOG' then
		-- if not LIB.IsInArena() then
		-- �������ղ�����Ч��������ֵ�ı仯����
		-- (arg1)dwCaster��ʩ���� (arg2)dwTarget��Ŀ�� (arg3)bReact���Ƿ�Ϊ���� (arg4)nType��Effect���� (arg5)dwID:Effect��ID
		-- (arg6)dwLevel��Effect�ĵȼ� (arg7)bCriticalStrike���Ƿ���� (arg8)nCount��tResultCount���ݱ���Ԫ�ظ��� (arg9)tResultCount����ֵ����
		-- D.OnSkillEffect(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
		if arg7 and arg7 ~= 0 then -- bCriticalStrike
			D.OnSkillEffect(arg1, arg2, arg4, arg5, arg6, SKILL_RESULT.CRITICAL, arg8, arg9)
		else
			D.OnSkillEffect(arg1, arg2, arg4, arg5, arg6, SKILL_RESULT.HIT, arg8, arg9)
		end
		-- end
	elseif arg0 == 'UI_OME_SKILL_BLOCK_LOG' then
		-- ����־��
		-- (arg1)dwCaster��ʩ���� (arg2)dwTarget��Ŀ�� (arg3)nType��Effect������
		-- (arg4)dwID��Effect��ID (arg5)dwLevel��Effect�ĵȼ� (arg6)nDamageType���˺����ͣ���ö����[[SKILL_RESULT_TYPE]]
		D.OnSkillEffect(arg1, arg2, arg3, arg4, arg5, SKILL_RESULT.BLOCK, nil, {})
	elseif arg0 == 'UI_OME_SKILL_SHIELD_LOG' then
		-- ���ܱ�������־��
		-- (arg1)dwCaster��ʩ���� (arg2)dwTarget��Ŀ��
		-- (arg3)nType��Effect������ (arg4)dwID��Effect��ID (arg5)dwLevel��Effect�ĵȼ�
		D.OnSkillEffect(arg1, arg2, arg3, arg4, arg5, SKILL_RESULT.SHIELD, nil, {})
	elseif arg0 == 'UI_OME_SKILL_MISS_LOG' then
		-- ����δ����Ŀ����־��
		-- (arg1)dwCaster��ʩ���� (arg2)dwTarget��Ŀ��
		-- (arg3)nType��Effect������ (arg4)dwID��Effect��ID (arg5)dwLevel��Effect�ĵȼ�
		D.OnSkillEffect(arg1, arg2, arg3, arg4, arg5, SKILL_RESULT.MISS, nil, {})
	elseif arg0 == 'UI_OME_SKILL_HIT_LOG' then
		-- ��������Ŀ����־��
		-- (arg1)dwCaster��ʩ���� (arg2)dwTarget��Ŀ��
		-- (arg3)nType��Effect������ (arg4)dwID��Effect��ID (arg5)dwLevel��Effect�ĵȼ�
		-- D.OnSkillEffect(arg1, arg2, arg3, arg4, arg5, SKILL_RESULT.HIT, nil, {})
	elseif arg0 == 'UI_OME_SKILL_DODGE_LOG' then
		-- ���ܱ�������־��
		-- (arg1)dwCaster��ʩ���� (arg2)dwTarget��Ŀ��
		-- (arg3)nType��Effect������ (arg4)dwID��Effect��ID (arg5)dwLevel��Effect�ĵȼ�
		D.OnSkillEffect(arg1, arg2, arg3, arg4, arg5, SKILL_RESULT.DODGE, nil, {})
	elseif arg0 == 'UI_OME_COMMON_HEALTH_LOG' then
		-- ��ͨ������־��
		-- (arg1)dwCharacterID���������ID (arg2)nDeltaLife������Ѫ��ֵ
		-- D.OnCommonHealth(arg1, arg2)
	end
end)

-- JJC��ʹ�õ�����Դ�����ܼ�¼������ݣ�
-- LIB.RegisterEvent('SKILL_EFFECT_TEXT', function(event)
--     if LIB.IsInArena() then
--         local dwCasterID      = arg0
--         local dwTargetID      = arg1
--         local bCriticalStrike = arg2
--         local nType           = arg3
--         local nValue          = arg4
--         local dwSkillID       = arg5
--         local dwSkillLevel    = arg6
--         local nEffectType     = arg7
--         local nResultCount    = 1
--         local tResult         = { [nType] = nValue }

--         if nType == SKILL_RESULT_TYPE.PHYSICS_DAMAGE -- �⹦�˺�
--         or nType == SKILL_RESULT_TYPE.SOLAR_MAGIC_DAMAGE -- �����ڹ��˺�
--         or nType == SKILL_RESULT_TYPE.NEUTRAL_MAGIC_DAMAGE -- �����ڹ��˺�
--         or nType == SKILL_RESULT_TYPE.LUNAR_MAGIC_DAMAGE -- �����ڹ��˺�
--         or nType == SKILL_RESULT_TYPE.POISON_DAMAGE then -- �����ڹ��˺�
--         -- if nType == SKILL_RESULT_TYPE.EFFECTIVE_DAMAGE then -- ��Ч�˺�ֵ
--             nResultCount = nResultCount + 1
--             tResult[SKILL_RESULT_TYPE.EFFECTIVE_DAMAGE] = nValue
--         elseif nType == SKILL_RESULT_TYPE.REFLECTIED_DAMAGE then -- �����˺�
--             dwCasterID, dwTargetID = dwTargetID, dwCasterID
--         elseif nType == SKILL_RESULT_TYPE.THERAPY then -- ����
--         -- elseif nType == SKILL_RESULT_TYPE.EFFECTIVE_THERAPY then -- ��Ч������
--             nResultCount = nResultCount + 1
--             tResult[SKILL_RESULT_TYPE.EFFECTIVE_THERAPY] = nValue
--         elseif nType == SKILL_RESULT_TYPE.STEAL_LIFE then -- ͵ȡ����ֵ
--             dwTargetID = dwCasterID
--             nResultCount = nResultCount + 1
--             tResult[SKILL_RESULT_TYPE.EFFECTIVE_THERAPY] = nValue
--         elseif nType == SKILL_RESULT_TYPE.ABSORB_DAMAGE then -- �����˺�
--             nResultCount = nResultCount + 1
--             tResult[SKILL_RESULT_TYPE.EFFECTIVE_DAMAGE] = 0
--         elseif nType == SKILL_RESULT_TYPE.SHIELD_DAMAGE then -- ���������˺�
--             nResultCount = nResultCount + 1
--             tResult[SKILL_RESULT_TYPE.EFFECTIVE_DAMAGE] = 0
--         elseif nType == SKILL_RESULT_TYPE.PARRY_DAMAGE then -- �����˺�
--             nResultCount = nResultCount + 1
--             tResult[SKILL_RESULT_TYPE.EFFECTIVE_DAMAGE] = 0
--         elseif nType == SKILL_RESULT_TYPE.INSIGHT_DAMAGE then -- ʶ���˺�
--             nResultCount = nResultCount + 1
--             tResult[SKILL_RESULT_TYPE.EFFECTIVE_DAMAGE] = 0
--         end
--         if bCriticalStrike then -- bCriticalStrike
--             D.OnSkillEffect(dwCasterID, dwTargetID, nEffectType, dwSkillID, dwSkillLevel, SKILL_RESULT.CRITICAL, nResultCount, tResult)
--         else
--             D.OnSkillEffect(dwCasterID, dwTargetID, nEffectType, dwSkillID, dwSkillLevel, SKILL_RESULT.HIT, nResultCount, tResult)
--         end
--     end
-- end)


-- �������˻�����һ��ʱ�����¼
function D.OnTeammateStateChange(dwID, bLeave, nAwayType, bAddWhenRecEmpty)
	if not (Data and Data[DK.AWAYTIME]) then
		return
	end
	-- ���һ���˵ļ�¼
	local rec = Data[DK.AWAYTIME][dwID]
	if not rec then -- ��ʼ��һ����¼
		if not bLeave and not bAddWhenRecEmpty then
			return -- ����һ������Ŀ�ʼ���Ҳ�ǿ�Ƽ�¼������
		end
		rec = {}
		Data[DK.AWAYTIME][dwID] = rec
	elseif #rec > 0 then -- ����߼�
		if bLeave then -- ��������
			if not rec[#rec][2] then -- �������һ����¼��������
				return
			end
		else -- ���˻���
			if rec[#rec][2] then -- ���ұ������ǻ��
				return
			end
		end
	end
	-- �������ݵ���¼
	if bLeave then -- ���뿪ʼ
		insert(rec, { GetCurrentTime(), nil, nAwayType })
	else -- �������
		if #rec == 0 then -- û��¼�����뿪ʼ ����һ���ӱ���ս����ʼ�����루�׳ƻ�û����������ˡ�����
			insert(rec, { Data[DK.TIME_BEGIN], GetCurrentTime(), nAwayType })
		elseif not rec[#rec][2] then -- ������һ�����뻹û���� ��������һ������ļ�¼
			rec[#rec][2] = GetCurrentTime()
		end
	end
end
LIB.RegisterEvent('PARTY_UPDATE_MEMBER_INFO', function()
	local team = GetClientTeam()
	local info = team.GetMemberInfo(arg1)
	if info then
		D.OnTeammateStateChange(arg1, info.bDeathFlag, AWAYTIME_TYPE.DEATH, false)
	end
end)
LIB.RegisterEvent('PARTY_SET_MEMBER_ONLINE_FLAG', function()
	if arg2 == 0 then -- ���˵���
		D.OnTeammateStateChange(arg1, true, AWAYTIME_TYPE.OFFLINE, false)
	else -- ��������
		D.OnTeammateStateChange(arg1, false, AWAYTIME_TYPE.OFFLINE, false)
		local team = GetClientTeam()
		local info = team.GetMemberInfo(arg1)
		if info and info.bDeathFlag then -- �������ŵ� ������������ ��ʼ��������
			D.OnTeammateStateChange(arg1, true, AWAYTIME_TYPE.DEATH, false)
		end
	end
end)
LIB.RegisterEvent('MY_RECOUNT_NEW_FIGHT', function() -- ��սɨ����� ��¼��ս������/���ߵ���
	local team = GetClientTeam()
	local me = GetClientPlayer()
	if team and me and (me.IsInParty() or me.IsInRaid()) then
		for _, dwID in ipairs(team.GetTeamMemberList()) do
			local info = team.GetMemberInfo(dwID)
			if info then
				if not info.bIsOnLine then
					D.OnTeammateStateChange(dwID, true, AWAYTIME_TYPE.OFFLINE, true)
				elseif info.bDeathFlag then
					D.OnTeammateStateChange(dwID, true, AWAYTIME_TYPE.DEATH, true)
				end
			end
		end
	end
end)
LIB.RegisterEvent('PARTY_ADD_MEMBER', function() -- ��;���˽��� ���������¼
	local team = GetClientTeam()
	local info = team.GetMemberInfo(arg1)
	if info then
		D.OnTeammateStateChange(arg1, false, AWAYTIME_TYPE.HALFWAY_JOINED, true)
		if info.bDeathFlag then
			D.OnTeammateStateChange(arg1, true, AWAYTIME_TYPE.DEATH, true)
		end
	end
end)

LIB.RegisterInit('MY_Recount_DS', function()
	D.LoadData()
end)

LIB.RegisterFlush('MY_Recount_DS', D.SaveData)

-- ͬ��Ŀ�����ݺϲ�
function D.MergeTargetData(tDst, tSrc, data, szChannel, bMergeNpc, bMergeEffect, bHideAnonymous)
	------------------------
	-- # �ڣ� tRecord
	------------------------
	-- �ϲ�������
	tDst[DK_REC_STAT.TOTAL] = tDst[DK_REC_STAT.TOTAL] + tSrc[DK_REC_STAT.TOTAL]
	tDst[DK_REC_STAT.TOTAL_EFFECT] = tDst[DK_REC_STAT.TOTAL_EFFECT] + tSrc[DK_REC_STAT.TOTAL_EFFECT]
	------------------------
	-- # �ڣ� tRecord.Detail
	------------------------
	-- �ϲ��������飨���С����ġ�ƫ��...��
	for nType, tSrcDetail in pairs(tSrc[DK_REC_STAT.DETAIL]) do
		local tDstDetail = tDst[DK_REC_STAT.DETAIL][nType]
		if not tDstDetail then
			tDstDetail = {
				nCount       =  0, -- ���м�¼����������nSkillResult�����У�
				nNzCount     =  0, -- ����ֵ���м�¼����
				nMax         =  0, -- �����������ֵ
				nMaxEffect   =  0, -- �������������Чֵ
				nMin         = -1, -- ����������Сֵ
				nNzMin       = -1, -- ���η���ֵ������Сֵ
				nMinEffect   = -1, -- ����������С��Чֵ
				nNzMinEffect = -1, -- ���η���ֵ������С��Чֵ
				nTotal       =  0, -- �����������˺�
				nTotalEffect =  0, -- ������������Ч�˺�
				nAvg         =  0, -- ��������ƽ���˺�
				nNzAvg       =  0, -- ���з���ֵ����ƽ���˺�
				nAvgEffect   =  0, -- ��������ƽ����Ч�˺�
				nNzAvgEffect =  0, -- ���з���ֵ����ƽ����Ч�˺�
			}
			tDst[DK_REC_STAT.DETAIL][nType] = tDstDetail
		end
		tDstDetail.nCount       = tDstDetail.nCount + tSrcDetail.nCount
		tDstDetail.nNzCount     = tDstDetail.nNzCount + tSrcDetail.nNzCount
		tDstDetail.nMax         = max(tDstDetail.nMax, tSrcDetail.nMax)
		tDstDetail.nMaxEffect   = max(tDstDetail.nMaxEffect, tSrcDetail.nMaxEffect)
		tDstDetail.nMin         = Min(tDstDetail.nMin, tSrcDetail.nMin)
		tDstDetail.nNzMin       = Min(tDstDetail.nNzMin, tSrcDetail.nNzMin)
		tDstDetail.nMinEffect   = Min(tDstDetail.nMinEffect, tSrcDetail.nMinEffect)
		tDstDetail.nNzMinEffect = Min(tDstDetail.nNzMinEffect, tSrcDetail.nNzMinEffect)
		tDstDetail.nTotal       = tDstDetail.nTotal + tSrcDetail.nTotal
		tDstDetail.nTotalEffect = tDstDetail.nTotalEffect + tSrcDetail.nTotalEffect
		tDstDetail.nAvg         = floor(tDstDetail.nTotal / tDstDetail.nCount)
		tDstDetail.nNzAvg       = floor(tDstDetail.nTotal / tDstDetail.nNzCount)
		tDstDetail.nAvgEffect   = floor(tDstDetail.nTotalEffect / tDstDetail.nCount)
		tDstDetail.nNzAvgEffect = floor(tDstDetail.nTotalEffect / tDstDetail.nNzCount)
	end
	------------------------
	-- # �ڣ� tRecord.Skill
	------------------------
	-- �ϲ�����ͳ�ƣ������ֻء����ǻ���...��
	for szEffectID, tSrcSkill in pairs(tSrc[DK_REC_STAT.SKILL]) do
		if not bHideAnonymous or not select(2, D.GetEffectInfoAusID(data, szEffectID)) then
			local id = bMergeEffect
				and D.GetEffectNameAusID(data, szChannel, szEffectID)
				or szEffectID
			local tDstSkill = tDst[DK_REC_STAT.SKILL][id]
			if not tDstSkill then
				tDstSkill = {
					nCount       =  0, -- ����������ֻ��ͷŴ���������szEffectName�������ֻأ�
					nNzCount     =  0, -- ����ҷ���ֵ�����ֻ��ͷŴ���
					nMax         =  0, -- ����������ֻ���������
					nMaxEffect   =  0, -- ����������ֻ������Ч�����
					nTotal       =  0, -- ����������ֻ�������ܺ�
					nTotalEffect =  0, -- ����������ֻ���Ч������ܺ�
					nAvg         =  0, -- ��������������ֻ�ƽ���˺�
					nNzAvg       =  0, -- ��������з���ֵ�����ֻ�ƽ���˺�
					nAvgEffect   =  0, -- ��������������ֻ�ƽ����Ч�˺�
					nNzAvgEffect =  0, -- ��������з���ֵ�����ֻ�ƽ����Ч�˺�
					Detail       = {}, -- ����������ֻ�����������ͳ��
					Target       = {}, -- ����������ֻس�����ͳ��
				}
				tDst[DK_REC_STAT.SKILL][id] = tDstSkill
			end
			tDstSkill.nCount       = tDstSkill.nCount + tSrcSkill.nCount
			tDstSkill.nNzCount     = tDstSkill.nNzCount + tSrcSkill.nNzCount
			tDstSkill.nMax         = max(tDstSkill.nMax, tSrcSkill.nMax)
			tDstSkill.nMaxEffect   = max(tDstSkill.nMaxEffect, tSrcSkill.nMaxEffect)
			tDstSkill.nTotal       = tDstSkill.nTotal + tSrcSkill.nTotal
			tDstSkill.nTotalEffect = tDstSkill.nTotalEffect + tSrcSkill.nTotalEffect
			tDstSkill.nAvg         = floor(tDstSkill.nTotal / tDstSkill.nCount)
			tDstSkill.nAvgEffect   = floor(tDstSkill.nTotalEffect / tDstSkill.nCount)
			tDstSkill.nNzAvg       = floor(tDstSkill.nTotal / tDstSkill.nNzCount)
			tDstSkill.nNzAvgEffect = floor(tDstSkill.nTotalEffect / tDstSkill.nNzCount)
			---------------------------------
			-- # �ڣ� tRecord.Skill[x].Detail
			---------------------------------
			-- �ϲ���������ͳ�ƣ������ֻص����С�����...��
			for nType, tSrcSkillDetail in pairs(tSrcSkill.Detail) do
				local tDstSkillDetail = tDstSkill.Detail[nType]
				if not tDstSkillDetail then
					tDstSkillDetail = {
						nCount       =  0, -- ���м�¼����
						nNzCount     =  0, -- ����ֵ���м�¼����
						nMax         =  0, -- �����������ֵ
						nMaxEffect   =  0, -- �������������Чֵ
						nMin         = -1, -- ����������Сֵ
						nNzMin       = -1, -- ���η���ֵ������Сֵ
						nMinEffect   = -1, -- ����������С��Чֵ
						nNzMinEffect = -1, -- ���η���ֵ������С��Чֵ
						nTotal       =  0, -- �����������˺�
						nTotalEffect =  0, -- ������������Ч�˺�
						nAvg         =  0, -- ��������ƽ���˺�
						nNzAvg       =  0, -- ���з���ֵ����ƽ���˺�
						nAvgEffect   =  0, -- ��������ƽ����Ч�˺�
						nNzAvgEffect =  0, -- ���з���ֵ����ƽ����Ч�˺�
					}
					tDstSkill.Detail[nType] = tDstSkillDetail
				end
				tDstSkillDetail.nCount       = tDstSkillDetail.nCount + tSrcSkillDetail.nCount
				tDstSkillDetail.nNzCount     = tDstSkillDetail.nNzCount + tSrcSkillDetail.nNzCount
				tDstSkillDetail.nMax         = max(tDstSkillDetail.nMax, tSrcSkillDetail.nMax)
				tDstSkillDetail.nMaxEffect   = max(tDstSkillDetail.nMaxEffect, tSrcSkillDetail.nMaxEffect)
				tDstSkillDetail.nMin         = Min(tDstSkillDetail.nMin, tSrcSkillDetail.nMin)
				tDstSkillDetail.nNzMin       = Min(tDstSkillDetail.nNzMin, tSrcSkillDetail.nNzMin)
				tDstSkillDetail.nMinEffect   = Min(tDstSkillDetail.nMinEffect, tSrcSkillDetail.nMinEffect)
				tDstSkillDetail.nNzMinEffect = Min(tDstSkillDetail.nNzMinEffect, tSrcSkillDetail.nNzMinEffect)
				tDstSkillDetail.nTotal       = tDstSkillDetail.nTotal + tSrcSkillDetail.nTotal
				tDstSkillDetail.nTotalEffect = tDstSkillDetail.nTotalEffect + tSrcSkillDetail.nTotalEffect
				tDstSkillDetail.nAvg         = floor(tDstSkillDetail.nTotal / tDstSkillDetail.nCount)
				tDstSkillDetail.nNzAvg       = floor(tDstSkillDetail.nTotal / tDstSkillDetail.nNzCount)
				tDstSkillDetail.nAvgEffect   = floor(tDstSkillDetail.nTotalEffect / tDstSkillDetail.nCount)
				tDstSkillDetail.nNzAvgEffect = floor(tDstSkillDetail.nTotalEffect / tDstSkillDetail.nNzCount)
			end
			------------------------------
			-- # �ڣ� tRecord.Skill.Target
			------------------------------
			-- �ϲ�����Ŀ��ͳ�ƣ������ֻضԽ�������ľ׮����������ľ׮...��
			for dwID, tSrcSkillTarget in pairs(tSrcSkill.Target) do
				local id = bMergeNpc and D.GetNameAusID(data, dwID) or dwID
				local tDstSkillTarget = tDstSkill.Target[id]
				if not tDstSkillTarget then
					tDstSkillTarget = {
						nMax         =  0, -- ����������ֻػ��е�����������˺�
						nMaxEffect   =  0, -- ����������ֻػ��е������������Ч�˺�
						nTotal       =  0, -- ����������ֻػ��е��������˺��ܺ�
						nTotalEffect =  0, -- ����������ֻػ��е���������Ч�˺��ܺ�
						Count        = {}, -- ����������ֻػ��е������ҽ��ͳ��
						NzCount      = {}, -- ����ҷ���ֵ�����ֻػ��е������ҽ��ͳ��
					}
					tDstSkill.Target[id] = tDstSkillTarget
				end
				tDstSkillTarget.nMax         = tDstSkillTarget.nMax + tSrcSkillTarget.nMax
				tDstSkillTarget.nMaxEffect   = tDstSkillTarget.nMaxEffect + tSrcSkillTarget.nMaxEffect
				tDstSkillTarget.nTotal       = tDstSkillTarget.nTotal + tSrcSkillTarget.nTotal
				tDstSkillTarget.nTotalEffect = tDstSkillTarget.nTotalEffect + tSrcSkillTarget.nTotalEffect
				for k, v in pairs(tSrcSkillTarget.Count) do
					tDstSkillTarget.Count[k] = (tDstSkillTarget.Count[k] or 0) + v
				end
				for k, v in pairs(tSrcSkillTarget.NzCount) do
					tDstSkillTarget.NzCount[k] = (tDstSkillTarget.NzCount[k] or 0) + v
				end
			end
		end
	end
	------------------------
	-- # �ڣ� tRecord.Target
	------------------------
	-- �ϲ�Ŀ��ͳ�ƣ���������ľ׮����������ľ׮...��
	for dwID, tSrcTarget in pairs(tSrc[DK_REC_STAT.TARGET]) do
		local id = bMergeNpc and D.GetNameAusID(data, dwID) or dwID
		local tDstTarget = tDst[DK_REC_STAT.TARGET][id]
		if not tDstTarget then
			tDstTarget = {
				nCount       =  0, -- ����Ҷ�idTarget�ļ����ͷŴ���
				nNzCount     =  0, -- ����Ҷ�idTarget�ķ���ֵ�����ͷŴ���
				nMax         =  0, -- ����Ҷ�idTarget�ļ�����������
				nMaxEffect   =  0, -- ����Ҷ�idTarget�ļ��������Ч�����
				nTotal       =  0, -- ����Ҷ�idTarget�ļ���������ܺ�
				nTotalEffect =  0, -- ����Ҷ�idTarget�ļ�����Ч������ܺ�
				nAvg         =  0, -- ����Ҷ�idTarget�ļ���ƽ�������
				nNzAvg       =  0, -- ����Ҷ�idTarget�ķ���ֵ����ƽ�������
				nAvgEffect   =  0, -- ����Ҷ�idTarget�ļ���ƽ����Ч�����
				nNzAvgEffect =  0, -- ����Ҷ�idTarget�ķ���ֵ����ƽ����Ч�����
				Detail       = {}, -- ����Ҷ�idTarget�ļ�������������ͳ��
				Skill        = {}, -- ����Ҷ�idTarget�ļ��ܾ���ֱ�ͳ��
			}
			tDst[DK_REC_STAT.TARGET][id] = tDstTarget
		end
		tDstTarget.nCount       = tDstTarget.nCount + tSrcTarget.nCount
		tDstTarget.nNzCount     = tDstTarget.nNzCount + tSrcTarget.nNzCount
		tDstTarget.nMax         = max(tDstTarget.nMax, tSrcTarget.nMax)
		tDstTarget.nMaxEffect   = max(tDstTarget.nMaxEffect, tSrcTarget.nMaxEffect)
		tDstTarget.nTotal       = tDstTarget.nTotal + tSrcTarget.nTotal
		tDstTarget.nTotalEffect = tDstTarget.nTotalEffect + tSrcTarget.nTotalEffect
		tDstTarget.nAvg         = floor(tDstTarget.nTotal / tDstTarget.nCount)
		tDstTarget.nAvgEffect   = floor(tDstTarget.nTotalEffect / tDstTarget.nCount)
		tDstTarget.nNzAvg       = floor(tDstTarget.nTotal / tDstTarget.nNzCount)
		tDstTarget.nNzAvgEffect = floor(tDstTarget.nTotalEffect / tDstTarget.nNzCount)
		----------------------------------
		-- # �ڣ� tRecord.Target[x].Detail
		----------------------------------
		-- �ϲ�Ŀ�꼼������ͳ�ƣ������ֻص����С�����...��
		for nType, tSrcTargetDetail in pairs(tSrcTarget.Detail) do
			local tDstTargetDetail = tDstTarget.Detail[nType]
			if not tDstTargetDetail then
				tDstTargetDetail = {
					nCount       =  0, -- ���м�¼����������nSkillResult�����У�
					nNzCount     =  0, -- ����ֵ���м�¼����
					nMax         =  0, -- �����������ֵ
					nMaxEffect   =  0, -- �������������Чֵ
					nMin         = -1, -- ����������Сֵ
					nNzMin       = -1, -- ���η���ֵ������Сֵ
					nMinEffect   = -1, -- ����������С��Чֵ
					nNzMinEffect = -1, -- ���η���ֵ������С��Чֵ
					nTotal       =  0, -- �����������˺�
					nTotalEffect =  0, -- ������������Ч�˺�
					nAvg         =  0, -- ��������ƽ���˺�
					nNzAvg       =  0, -- ���з���ֵ����ƽ���˺�
					nAvgEffect   =  0, -- ��������ƽ����Ч�˺�
					nNzAvgEffect =  0, -- ���з���ֵ����ƽ����Ч�˺�
				}
				tDstTarget.Detail[nType] = tDstTargetDetail
			end
			tDstTargetDetail.nCount       = tDstTargetDetail.nCount + tSrcTargetDetail.nCount
			tDstTargetDetail.nNzCount     = tDstTargetDetail.nNzCount + tSrcTargetDetail.nNzCount
			tDstTargetDetail.nMax         = max(tDstTargetDetail.nMax, tSrcTargetDetail.nMax)
			tDstTargetDetail.nMaxEffect   = max(tDstTargetDetail.nMaxEffect, tSrcTargetDetail.nMaxEffect)
			tDstTargetDetail.nMin         = Min(tDstTargetDetail.nMin, tSrcTargetDetail.nMin)
			tDstTargetDetail.nNzMin       = Min(tDstTargetDetail.nNzMin, tSrcTargetDetail.nNzMin)
			tDstTargetDetail.nMinEffect   = Min(tDstTargetDetail.nMinEffect, tSrcTargetDetail.nMinEffect)
			tDstTargetDetail.nNzMinEffect = Min(tDstTargetDetail.nNzMinEffect, tSrcTargetDetail.nNzMinEffect)
			tDstTargetDetail.nTotal       = tDstTargetDetail.nTotal + tSrcTargetDetail.nTotal
			tDstTargetDetail.nTotalEffect = tDstTargetDetail.nTotalEffect + tSrcTargetDetail.nTotalEffect
			tDstTargetDetail.nAvg         = floor(tDstTargetDetail.nTotal / tDstTargetDetail.nCount)
			tDstTargetDetail.nNzAvg       = floor(tDstTargetDetail.nTotal / tDstTargetDetail.nNzCount)
			tDstTargetDetail.nAvgEffect   = floor(tDstTargetDetail.nTotalEffect / tDstTargetDetail.nCount)
			tDstTargetDetail.nNzAvgEffect = floor(tDstTargetDetail.nTotalEffect / tDstTargetDetail.nNzCount)
		end
		---------------------------------
		-- # �ڣ� tRecord.Target[x].Skill
		---------------------------------
		-- �ϲ�Ŀ�꼼��ͳ�ƣ���������ľ׮�������ֻء����ǻ���...��
		for szEffectID, tSrcTargetSkill in pairs(tSrcTarget.Skill) do
			if not bHideAnonymous or not select(2, D.GetEffectInfoAusID(data, szEffectID)) then
				local id = bMergeEffect
					and D.GetEffectNameAusID(data, szEffectID)
					or szEffectID
				local tDstTargetSkill = tDstTarget.Skill[id]
				if not tDstTargetSkill then
					tDstTargetSkill = {
						nMax         =  0, -- ����һ��������ҵ������ֻ�����˺�
						nMaxEffect   =  0, -- ����һ��������ҵ������ֻ������Ч�˺�
						nTotal       =  0, -- ����һ��������ҵ������ֻ��˺��ܺ�
						nTotalEffect =  0, -- ����һ��������ҵ������ֻ���Ч�˺��ܺ�
						Count        = {}, -- ����һ��������ҵ������ֻؽ��ͳ��
						NzCount      = {}, -- ����ҷ���ֵ���������ҵ������ֻؽ��ͳ��
					}
					tDstTarget.Skill[id] = tDstTargetSkill
				end
				tDstTargetSkill.nMax         = max(tDstTargetSkill.nMax, tSrcTargetSkill.nMax)
				tDstTargetSkill.nMaxEffect   = max(tDstTargetSkill.nMaxEffect, tSrcTargetSkill.nMaxEffect)
				tDstTargetSkill.nTotal       = tDstTargetSkill.nTotal + tSrcTargetSkill.nTotal
				tDstTargetSkill.nTotalEffect = tDstTargetSkill.nTotalEffect + tSrcTargetSkill.nTotalEffect
				for k, v in pairs(tSrcTargetSkill.Count) do
					tDstTargetSkill.Count[k] = (tDstTargetSkill.Count[k] or 0) + v
				end
				for k, v in pairs(tSrcTargetSkill.NzCount) do
					tDstTargetSkill.NzCount[k] = (tDstTargetSkill.NzCount[k] or 0) + v
				end
			end
		end
	end
end

function D.GetMergeTargetData(data, szChannel, id, bMergeNpc, bMergeEffect, bHideAnonymous)
	if not bMergeNpc and not bMergeEffect and not bHideAnonymous then
		return data[szChannel][DK_REC.STATISTICS][id]
	end
	local tData = nil
	for dwID, tSrcData in pairs(data[szChannel][DK_REC.STATISTICS]) do
		if dwID == id or D.GetNameAusID(data, dwID) == id then
			if not tData then
				tData = {
					[DK_REC_STAT.TOTAL       ] = 0,
					[DK_REC_STAT.TOTAL_EFFECT] = 0,
					[DK_REC_STAT.TARGET      ] = {},
					[DK_REC_STAT.SKILL       ] = {},
					[DK_REC_STAT.DETAIL      ] = {},
				}
			end
			D.MergeTargetData(tData, tSrcData, data, szChannel, bMergeNpc, bMergeEffect, bHideAnonymous)
		end
	end
	return tData
end

-- Global exports
do
local settings = {
	exports = {
		{
			fields = {
				Get = D.Get,
				Del = D.Del,
				GeneAwayTime = D.GeneAwayTime,
				GeneFightTime = D.GeneFightTime,
				GetNameAusID = D.GetNameAusID,
				GetForceAusID = D.GetForceAusID,
				GetEffectInfoAusID = D.GetEffectInfoAusID,
				GetEffectNameAusID = D.GetEffectNameAusID,
				Flush = D.Flush,
				GetMergeTargetData = D.GetMergeTargetData,
				DK = DK,
				DK_REC = DK_REC,
				DK_REC_SNAPSHOT = DK_REC_SNAPSHOT,
				DK_REC_SNAPSHOT_STAT = DK_REC_SNAPSHOT_STAT,
				DK_REC_STAT = DK_REC_STAT,
				DK_REC_STAT_DETAIL = DK_REC_STAT_DETAIL,
			},
		},
		{
			fields = {
				bSaveHistory      = true,
				nMaxHistory       = true,
				nMinFightTime     = true,
				bRecEverything    = true,
			},
			root = O,
		},
	},
	imports = {
		{
			fields = {
				bSaveHistory      = true,
				nMaxHistory       = true,
				nMinFightTime     = true,
				bRecEverything    = true,
			},
			triggers = {
				bSaveHistory      = D.SaveData,
				nMaxHistory       = D.SaveData,
				nMinFightTime     = D.SaveData,
				bRecEverything    = D.SaveData,
			},
			root = O,
		},
	},
}
MY_Recount_DS = LIB.GeneGlobalNS(settings)
end
