--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : ս��ͳ�� ����Դ
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
local PLUGIN_NAME = 'MY_Recount'
local PLUGIN_ROOT = PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_Recount'
local _L = LIB.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not LIB.AssertVersion(MODULE_NAME, _L[MODULE_NAME], 0x2013900) then
	return
end
--------------------------------------------------------------------------
local DEBUG = false

local DK = {
	UUID        = DEBUG and 'UUID'        or  1, -- ս��Ψһ��ʶ
	BOSSNAME    = DEBUG and 'szBossName'  or  2, -- ��־����
	VERSION     = DEBUG and 'nVersion'    or  3, -- ���ݰ汾��
	TIME_BEGIN  = DEBUG and 'nTimeBegin'  or  4, -- ս����ʼʱ��
	TICK_BEGIN  = DEBUG and 'nTickBegin'  or  5, -- ս����ʼ����ʱ��
	TIME_DURING = DEBUG and 'nTimeDuring' or  6, -- ս������ʱ��
	TICK_DURING = DEBUG and 'nTickDuring' or  7, -- ս����������ʱ��
	AWAYTIME    = DEBUG and 'Awaytime'    or  8, -- ����/����ʱ��ڵ�
	NAME_LIST   = DEBUG and 'Namelist'    or  9, -- ���ƻ���
	FORCE_LIST  = DEBUG and 'Forcelist'   or 10, -- ��������
	EFFECT_LIST = DEBUG and 'Effectlist'  or 11, -- Ч����Ϣ����
	DAMAGE      = DEBUG and 'Damage'      or 12, -- ���ͳ��
	HEAL        = DEBUG and 'Heal'        or 13, -- ����ͳ��
	BE_HEAL     = DEBUG and 'BeHeal'      or 14, -- ����ͳ��
	BE_DAMAGE   = DEBUG and 'BeDamage'    or 15, -- ����ͳ��
	EVERYTHING  = DEBUG and 'Everything'  or 16, -- ս������
	ABSORB      = DEBUG and 'Absorb'      or 17, -- ����ͳ��
	PLAYER_LIST = DEBUG and 'Playerlist'  or 18, -- �����Ϣ����
	SERVER      = DEBUG and 'Server'      or 19, -- ���ڷ�����
	MAP         = DEBUG and 'Map'         or 20, -- ���ڵ�ͼ
}

local DK_REC = {
	TIME_DURING  = DEBUG and 'nTimeDuring'  or 1,
	TOTAL        = DEBUG and 'nTotal'       or 2,
	TOTAL_EFFECT = DEBUG and 'nTotalEffect' or 3,
	STAT         = DEBUG and 'Statistics'   or 4,
}

local DK_REC_STAT = {
	TOTAL        = DEBUG and 'nTotal'       or 1,
	TOTAL_EFFECT = DEBUG and 'nTotalEffect' or 2,
	DETAIL       = DEBUG and 'Detail'       or 3,
	SKILL        = DEBUG and 'Skill'        or 4,
	TARGET       = DEBUG and 'Target'       or 5,
}

local DK_REC_STAT_DETAIL = {
	COUNT         = DEBUG and 'nCount'       or  1, -- ���м�¼����������nSkillResult�����У�
	NZ_COUNT      = DEBUG and 'nNzCount'     or  2, -- ����ֵ���м�¼����
	MAX           = DEBUG and 'nMax'         or  3, -- �����������ֵ
	MAX_EFFECT    = DEBUG and 'nMaxEffect'   or  4, -- �������������Чֵ
	MIN           = DEBUG and 'nMin'         or  5, -- ����������Сֵ
	NZ_MIN        = DEBUG and 'nNzMin'       or  6, -- ���η���ֵ������Сֵ
	MIN_EFFECT    = DEBUG and 'nMinEffect'   or  7, -- ����������С��Чֵ
	NZ_MIN_EFFECT = DEBUG and 'nNzMinEffect' or  8, -- ���η���ֵ������С��Чֵ
	TOTAL         = DEBUG and 'nTotal'       or  9, -- �����������˺�
	TOTAL_EFFECT  = DEBUG and 'nTotalEffect' or 10, -- ������������Ч�˺�
	AVG           = DEBUG and 'nAvg'         or 11, -- ��������ƽ���˺�
	NZ_AVG        = DEBUG and 'nNzAvg'       or 12, -- ���з���ֵ����ƽ���˺�
	AVG_EFFECT    = DEBUG and 'nAvgEffect'   or 13, -- ��������ƽ����Ч�˺�
	NZ_AVG_EFFECT = DEBUG and 'nNzAvgEffect' or 14, -- ���з���ֵ����ƽ����Ч�˺�
}

local DK_REC_STAT_SKILL = {
	COUNT         = DEBUG and 'nCount'       or  1, -- ����������ֻ��ͷŴ���������szEffectName�������ֻأ�
	NZ_COUNT      = DEBUG and 'nNzCount'     or  2, -- ����ҷ���ֵ�����ֻ��ͷŴ���
	MAX           = DEBUG and 'nMax'         or  3, -- ����������ֻ���������
	MAX_EFFECT    = DEBUG and 'nMaxEffect'   or  4, -- ����������ֻ������Ч�����
	TOTAL         = DEBUG and 'nTotal'       or  5, -- ����������ֻ�������ܺ�
	TOTAL_EFFECT  = DEBUG and 'nTotalEffect' or  6, -- ����������ֻ���Ч������ܺ�
	AVG           = DEBUG and 'nAvg'         or  7, -- ��������������ֻ�ƽ���˺�
	NZ_AVG        = DEBUG and 'nNzAvg'       or  8, -- ��������з���ֵ�����ֻ�ƽ���˺�
	AVG_EFFECT    = DEBUG and 'nAvgEffect'   or  9, -- ��������������ֻ�ƽ����Ч�˺�
	NZ_AVG_EFFECT = DEBUG and 'nNzAvgEffect' or 10, -- ��������з���ֵ�����ֻ�ƽ����Ч�˺�
	DETAIL        = DEBUG and 'Detail'       or 11, -- ����������ֻ�����������ͳ��
	TARGET        = DEBUG and 'Target'       or 12, -- ����������ֻس�����ͳ��
}

local DK_REC_STAT_SKILL_DETAIL = {
	COUNT         = DEBUG and 'nCount'       or  1, -- ���м�¼����
	NZ_COUNT      = DEBUG and 'nNzCount'     or  2, -- ����ֵ���м�¼����
	MAX           = DEBUG and 'nMax'         or  3, -- �����������ֵ
	MAX_EFFECT    = DEBUG and 'nMaxEffect'   or  4, -- �������������Чֵ
	MIN           = DEBUG and 'nMin'         or  5, -- ����������Сֵ
	NZ_MIN        = DEBUG and 'nNzMin'       or  6, -- ���η���ֵ������Сֵ
	MIN_EFFECT    = DEBUG and 'nMinEffect'   or  7, -- ����������С��Чֵ
	NZ_MIN_EFFECT = DEBUG and 'nNzMinEffect' or  8, -- ���η���ֵ������С��Чֵ
	TOTAL         = DEBUG and 'nTotal'       or  9, -- �����������˺�
	TOTAL_EFFECT  = DEBUG and 'nTotalEffect' or 10, -- ������������Ч�˺�
	AVG           = DEBUG and 'nAvg'         or 11, -- ��������ƽ���˺�
	NZ_AVG        = DEBUG and 'nNzAvg'       or 12, -- ���з���ֵ����ƽ���˺�
	AVG_EFFECT    = DEBUG and 'nAvgEffect'   or 13, -- ��������ƽ����Ч�˺�
	NZ_AVG_EFFECT = DEBUG and 'nNzAvgEffect' or 14, -- ���з���ֵ����ƽ����Ч�˺�
}

local DK_REC_STAT_SKILL_TARGET = {
	MAX          = DEBUG and 'nMax'         or 1, -- ����������ֻػ��е�����������˺�
	MAX_EFFECT   = DEBUG and 'nMaxEffect'   or 2, -- ����������ֻػ��е������������Ч�˺�
	TOTAL        = DEBUG and 'nTotal'       or 3, -- ����������ֻػ��е��������˺��ܺ�
	TOTAL_EFFECT = DEBUG and 'nTotalEffect' or 4, -- ����������ֻػ��е���������Ч�˺��ܺ�
	COUNT        = DEBUG and 'Count'        or 5, -- ����������ֻػ��е������ҽ��ͳ��
	NZ_COUNT     = DEBUG and 'NzCount'      or 6, -- ����ҷ���ֵ�����ֻػ��е������ҽ��ͳ��
}

local DK_REC_STAT_TARGET = {
	COUNT         = DEBUG and 'nCount'       or  1, -- ����Ҷ�idTarget�ļ����ͷŴ���
	NZ_COUNT      = DEBUG and 'nNzCount'     or  2, -- ����Ҷ�idTarget�ķ���ֵ�����ͷŴ���
	MAX           = DEBUG and 'nMax'         or  3, -- ����Ҷ�idTarget�ļ�����������
	MAX_EFFECT    = DEBUG and 'nMaxEffect'   or  4, -- ����Ҷ�idTarget�ļ��������Ч�����
	TOTAL         = DEBUG and 'nTotal'       or  5, -- ����Ҷ�idTarget�ļ���������ܺ�
	TOTAL_EFFECT  = DEBUG and 'nTotalEffect' or  6, -- ����Ҷ�idTarget�ļ�����Ч������ܺ�
	AVG           = DEBUG and 'nAvg'         or  7, -- ����Ҷ�idTarget�ļ���ƽ�������
	NZ_AVG        = DEBUG and 'nNzAvg'       or  8, -- ����Ҷ�idTarget�ķ���ֵ����ƽ�������
	AVG_EFFECT    = DEBUG and 'nAvgEffect'   or  9, -- ����Ҷ�idTarget�ļ���ƽ����Ч�����
	NZ_AVG_EFFECT = DEBUG and 'nNzAvgEffect' or 10, -- ����Ҷ�idTarget�ķ���ֵ����ƽ����Ч�����
	DETAIL        = DEBUG and 'Detail'       or 11, -- ����Ҷ�idTarget�ļ�������������ͳ��
	SKILL         = DEBUG and 'Skill'        or 12, -- ����Ҷ�idTarget�ļ��ܾ���ֱ�ͳ��
}

local DK_REC_STAT_TARGET_DETAIL = {
	COUNT         = DEBUG and 'nCount'       or  1, -- ���м�¼����������nSkillResult�����У�
	NZ_COUNT      = DEBUG and 'nNzCount'     or  2, -- ����ֵ���м�¼����
	MAX           = DEBUG and 'nMax'         or  3, -- �����������ֵ
	MAX_EFFECT    = DEBUG and 'nMaxEffect'   or  4, -- �������������Чֵ
	MIN           = DEBUG and 'nMin'         or  5, -- ����������Сֵ
	NZ_MIN        = DEBUG and 'nNzMin'       or  6, -- ���η���ֵ������Сֵ
	MIN_EFFECT    = DEBUG and 'nMinEffect'   or  7, -- ����������С��Чֵ
	NZ_MIN_EFFECT = DEBUG and 'nNzMinEffect' or  8, -- ���η���ֵ������С��Чֵ
	TOTAL         = DEBUG and 'nTotal'       or  9, -- �����������˺�
	TOTAL_EFFECT  = DEBUG and 'nTotalEffect' or 10, -- ������������Ч�˺�
	AVG           = DEBUG and 'nAvg'         or 11, -- ��������ƽ���˺�
	NZ_AVG        = DEBUG and 'nNzAvg'       or 12, -- ���з���ֵ����ƽ���˺�
	AVG_EFFECT    = DEBUG and 'nAvgEffect'   or 13, -- ��������ƽ����Ч�˺�
	NZ_AVG_EFFECT = DEBUG and 'nNzAvgEffect' or 14, -- ���з���ֵ����ƽ����Ч�˺�
}

local DK_REC_STAT_TARGET_SKILL = {
	MAX          = DEBUG and 'nMax'         or  1, -- ����һ��������ҵ������ֻ�����˺�
	MAX_EFFECT   = DEBUG and 'nMaxEffect'   or  2, -- ����һ��������ҵ������ֻ������Ч�˺�
	TOTAL        = DEBUG and 'nTotal'       or  3, -- ����һ��������ҵ������ֻ��˺��ܺ�
	TOTAL_EFFECT = DEBUG and 'nTotalEffect' or  4, -- ����һ��������ҵ������ֻ���Ч�˺��ܺ�
	COUNT        = DEBUG and 'Count'        or  5, -- ����һ��������ҵ������ֻؽ��ͳ��
	NZ_COUNT     = DEBUG and 'NzCount'      or  6, -- ����ҷ���ֵ���������ҵ������ֻؽ��ͳ��
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

-- Data��DataDisplay��HISTORY_CACHE[szFilePath].Data ���ݽṹ
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
		[DK_REC.STAT] = {
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
	HIT      = 0, -- ����
	BLOCK    = 1, -- ��
	SHIELD   = 2, -- ��Ч
	MISS     = 3, -- ƫ��
	DODGE    = 4, -- ����
	CRITICAL = 5, -- ����
	INSIGHT  = 6, -- ʶ��
	ABSORB   = 7, -- ����
}
local NZ_SKILL_RESULT = {
	[SKILL_RESULT.BLOCK ] = true,
	[SKILL_RESULT.SHIELD] = true,
	[SKILL_RESULT.MISS  ] = true,
	[SKILL_RESULT.DODGE ] = true,
}
local SKILL_RESULT_NAME = {
	[SKILL_RESULT.HIT     ] = g_tStrings.STR_HIT_NAME     ,
	[SKILL_RESULT.BLOCK   ] = g_tStrings.STR_IMMUNITY_NAME,
	[SKILL_RESULT.SHIELD  ] = g_tStrings.STR_SHIELD_NAME  ,
	[SKILL_RESULT.MISS    ] = g_tStrings.STR_MSG_MISS     ,
	[SKILL_RESULT.DODGE   ] = g_tStrings.STR_MSG_DODGE    ,
	[SKILL_RESULT.CRITICAL] = g_tStrings.STR_CS_NAME      ,
	[SKILL_RESULT.INSIGHT ] = g_tStrings.STR_MSG_INSIGHT  ,
	[SKILL_RESULT.ABSORB  ] = g_tStrings.STR_MSG_ABSORB   ,
}
local ABSORB_BUFF = {
	[134  ] = 9999, -- ��������_��ϼ
	[1754 ] = 9999, -- �ؽ�_������_Ȫ����_����
	[4244 ] = 9999, -- ����_�ɶ���_���ն�
	[4400 ] = 9999, -- ����_ʥ����_����ת���ն�
	[4719 ] = 9999, -- ����_�ɶ���_����ת�˺�����
	[5135 ] = 9999, -- ������������_Ⱥ�嵰��
	[5735 ] = 9999, -- �ؽ�_Ȫ����
	[6223 ] = 9999, -- �嶾_��Ѩ_�������ն�
	[6224 ] = 9999, -- �嶾_��Ѩ_���˺�
	[8253 ] = 9999, -- ��ѹ_�����˺����ն�
	[8279 ] = 9999, -- �ܱ�
	[8291 ] = 9999, -- �ܻ��˺����ն�
	[8292 ] = 9999, -- �ܱڼ�ǿ��
	[8515 ] = 9999, -- ��Ϣ_20%�˺����ն�
	[9584 ] = 9999, -- ÷����Ū����һ����5%�˺����ն�
	[10266] = 9999, -- ����_÷����Ū
	[11187] = 9999, -- ������������_�����ӻ�
	[11530] = 9999, -- ��ֵ_����Ӷ�
	[15415] = 9999, -- �¸�ħT�·��˺����ն�
	[15415] = 9999, -- �¸�ħT�·��˺����ն���ѩ�ط�
	[15948] = 9999, -- ��Ӱ�˺����ն�
	[16441] = 9999, -- ������������_�𻯽���
	[16568] = 9999, -- �嶾�°���������_��֧���
	[16721] = 9999, -- Ԫ���_��������_����
	[16877] = 9999, -- ������������_��ջ���
	[16882] = 9999, -- ������������_��ӡ�����������ն�
	[16883] = 9999, -- ������������_��ӡ�����������ն�
	[16884] = 9999, -- ������������_��ӡ�����������ն�
	[16911] = 9999, -- ������������_÷�����
	[17015] = 9999, -- ��б��¥����
	[17028] = 9999, -- ����ؼ�����
	[17047] = 9999, -- ������Զ�
	[17094] = 9999, -- �ﻯ�������ն�
	[9334 ] = 9998, -- ÷����Ū
}
local AWAYTIME_TYPE = {
	DEATH          = 0,
	OFFLINE        = 1,
	HALFWAY_JOINED = 2,
}
local EVERYTHING_TYPE = {
	SKILL_EFFECT = 1,
	FIGHT_TIME = 2,
	DEATH = 3,
	ONLINE = 4,
	BUFF_UPDATE = 5,
	ENTER_LEAVE_SCENE = 6,
	SYS_MSG = 7,
	PLAYER_SAY = 8,
	WARNING_MESSAGE = 9,
	FIGHT_HINT = 10,
}
local VERSION = 2

local D = {}
local O = {
	bEnable            = false, -- ���ݼ�¼�ܿ��� ��ֹ�ٷ�SB����BUFF�ű�Ϲ����д����Ƶ̫��˦���������߼�
	bSaveHistoryOnExit = false, -- �˳���Ϸʱ������ʷ����
	bSaveHistoryOnExFi = false, -- ����ս��ʱ������ʷ����
	nMaxHistory        = 10   , -- �����ʷ��������
	nMinFightTime      = 30   , -- ��Сս��ʱ��
	bRecEverything     = true , -- �Ƿ�ɼ���������
	bSaveEverything    = false, -- ����ս����¼ʱ�Ƿ�洢��������
}
local Data          -- ��ǰս�����ݼ�¼
local HISTORY_CACHE = setmetatable({}, { __mode = 'v' }) -- ��ʷս����¼���� { [szFile] = Data }
local KEPT_CACHE = {} -- �����˵����޳��˸��̼�¼��ս����¼���� { [szFile] = Data }
local UNSAVED_CACHE = {} -- δ�����ս����¼���� { [szFile] = Data }
local DS_DATA_CONFIG = { passphrase = false, crc = false }
local DS_ROOT = {'userdata/fight_stat/', PATH_TYPE.ROLE}
local SZ_CFG_FILE = {'userdata/fight_stat/config.jx3dat', PATH_TYPE.ROLE}
local SKILL_EFFECT_CACHE = {} -- ����ļ���Ч������ ����սʱ�����������ѹ������
local BUFF_UPDATE_CACHE = {} -- �����BUFFЧ������ ����սʱ�����������ѹ������
local ABSORB_CACHE = {} -- Ŀ�����Դ��״̬�����
local LOG_REPLAY_FRAME = GLOBAL.GAME_FPS * 1 -- ��սʱ�򽫶�õ�����ѹ�������߼�֡��
local SKILL_TYPE = CONSTANT.SKILL_TYPE

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

local AsyncSaveLuaData = _G.AsyncSaveLuaData or SaveLUAData

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
-- ��¼��Ϸ���ر��������
function D.LoadData()
	local data = LIB.LoadLUAData(SZ_CFG_FILE, DS_DATA_CONFIG)
	if data then
		if IsTable(data.History) then
			for _, data in ipairs(data.History) do
				UNSAVED_CACHE[LIB.FormatPath(DS_ROOT) .. D.GetDataFileName(data)] = data
			end
			D.SaveHistory()
		end
		O.bEnable            = data.bEnable or false
		O.bSaveHistoryOnExit = data.bSaveHistoryOnExit or data.bSaveHistory or false
		O.bSaveHistoryOnExFi = data.bSaveHistoryOnExFi or false
		O.nMaxHistory        = data.nMaxHistory or 10
		O.nMinFightTime      = data.nMinFightTime or 30
		O.bRecEverything     = data.bRecEverything or false
		O.bSaveEverything    = data.bSaveEverything1 or false
		MY_Recount_UI.CheckOpen()
	end
	D.InitData()
end

-- �˳���Ϸ��������
function D.SaveData()
	local data = {
		bEnable            = O.bEnable           ,
		bSaveHistoryOnExit = O.bSaveHistoryOnExit,
		bSaveHistoryOnExFi = O.bSaveHistoryOnExFi,
		nMaxHistory        = O.nMaxHistory       ,
		nMinFightTime      = O.nMinFightTime     ,
		bRecEverything     = O.bRecEverything    ,
		bSaveEverything1   = O.bSaveEverything   ,
	}
	LIB.SaveLUAData(SZ_CFG_FILE, data, DS_DATA_CONFIG)
end

-- ������ʷ�����б�
function D.GetHistoryFiles()
	local aFiles = {}
	local aFileName, tFileName = {}, {}
	local szRoot = LIB.FormatPath(DS_ROOT)
	for k, _ in pairs(HISTORY_CACHE) do
		if wfind(k, szRoot) == 1 then
			k = k:sub(#szRoot + 1)
			if not tFileName[k] then
				insert(aFileName, k)
				tFileName[k] = true
			end
		end
	end
	for _, v in ipairs(CPath.GetFileList(szRoot)) do
		if not tFileName[v] then
			insert(aFileName, v)
			tFileName[v] = true
		end
	end
	for _, filename in ipairs(aFileName) do
		local year, month, day, hour, minute, second, bossname, during = filename:match('^(%d+)%-(%d+)%-(%d+)%-(%d+)%-(%d+)%-(%d+)%_(.-)_(%d+%.?%d*)%.fstt%.jx3dat')
		if year then
			year = tonumber(year)
			month = tonumber(month)
			day = tonumber(day)
			hour = tonumber(hour)
			minute = tonumber(minute)
			second = tonumber(second)
			during = tonumber(during)
			insert(aFiles, {
				year, month, day, hour, minute, second,
				bossname = bossname,
				during = during,
				time = DateToTime(
					year,
					month,
					day,
					hour,
					minute,
					second
				),
				filename = filename:sub(1, -13),
				fullname = filename,
				fullpath = szRoot .. filename,
			})
		end
	end
	local function sortFile(a, b)
		local n = max(#a, #b)
		for i = 1, n do
			if not a[i] then
				return true
			elseif not b[i] then
				return false
			elseif a[i] ~= b[i] then
				return a[i] > b[i]
			end
		end
		return false
	end
	sort(aFiles, sortFile)
	return aFiles
end

-- ������ʷ��������
function D.LimitHistoryFile()
	local aFiles = D.GetHistoryFiles()
	for i = O.nMaxHistory + 1, #aFiles do
		CPath.DelFile(aFiles[i].fullpath)
		HISTORY_CACHE[aFiles[i].fullpath] = nil
		UNSAVED_CACHE[aFiles[i].fullpath] = nil
		KEPT_CACHE[aFiles[i].fullpath] = nil
	end
end

-- ����һ�����������ļ���
function D.GetDataFileName(data)
	return LIB.FormatTime(data[DK.TIME_BEGIN], '%yyyy-%MM-%dd-%hh-%mm-%ss')
			.. '_' .. (data[DK.BOSSNAME] or g_tStrings.STR_NAME_UNKNOWN)
			.. '_' .. ceil(data[DK.TIME_DURING])
			.. '.fstt.jx3dat'
end

-- ���滺�����ʷ����
function D.SaveHistory()
	for szFilePath, data in pairs(UNSAVED_CACHE) do
		--[[#DEBUG BEGIN]]
		LIB.Debug('MY_Recount_DS.SaveHistory: ' .. szFilePath, DEBUG_LEVEL.LOG)
		--[[#DEBUG END]]
		local saveData = data
		if not O.bSaveEverything then -- ��������ʱ�޳��������ݣ���ֹ����
			--[[#DEBUG BEGIN]]
			LIB.Debug('MY_Recount_DS.SaveHistoryWithoutEverything: ' .. szFilePath, DEBUG_LEVEL.LOG)
			--[[#DEBUG END]]
			saveData = {}
			for k, v in pairs(data) do
				saveData[k] = k == DK.EVERYTHING
					and {}
					or v
			end
			KEPT_CACHE[szFilePath] = data -- ���븴�����ݱ��������ֹ��GC
		end
		AsyncSaveLuaData(szFilePath, saveData, { crc = false })
	end
	D.LimitHistoryFile()
	UNSAVED_CACHE = {}
end

-- ��ͼ�����ǰս������
do
local function onLoadingEnding()
	D.Flush()
	ABSORB_CACHE = {}
	FireUIEvent('MY_RECOUNT_NEW_FIGHT')
end
LIB.RegisterEvent('LOADING_ENDING', onLoadingEnding)
LIB.RegisterEvent('RELOAD_UI_ADDON_END', onLoadingEnding)
end

-- �˳�ս�� ��������
LIB.RegisterEvent('MY_FIGHT_HINT', function()
	if not O.bEnable then
		return
	end
	local nLFC, nTime, nTick = GetLogicFrameCount(), GetCurrentTime(), GetTime()
	local bFighting, szUUID, nDuring = arg0, arg1, arg2
	if not bFighting then
		D.InsertEverything(Data, nLFC, nTime, nTick, EVERYTHING_TYPE.FIGHT_TIME, bFighting, szUUID, nDuring)
	end
	if bFighting and szUUID ~= Data[DK.UUID] then -- �����µ�ս��
		D.InitData()
		D.ReplayRecentLog()
		FireUIEvent('MY_RECOUNT_NEW_FIGHT')
	else
		D.Flush()
	end
	if bFighting then
		D.InsertEverything(Data, nLFC, nTime, nTick, EVERYTHING_TYPE.FIGHT_TIME, bFighting, szUUID, nDuring)
	end
end)

function D.GetPlayer(dwID)
	local me = GetClientPlayer()
	local team = GetClientTeam()
	local p, info
	if dwID == UI_GetClientPlayerID() then
		p = me
		info = {
			dwMountKungfuID = UI_GetPlayerMountKungfuID(),
			szName = me.szName,
			nMaxLife = me.nMaxLife,
			nCurrentLife = me.nCurrentLife,
		}
	else
		p = GetPlayer(dwID)
		info = team.GetMemberInfo(dwID)
	end
	return p, info
end

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
-- (table) D.Get(szFilePath) -- ��ȡָ����¼
--     (string) szFilePath: ��ʷ��¼�ļ�ȫ·�� ��'CURRENT'���ص�ǰͳ��
function D.Get(szFilePath)
	if szFilePath == 'CURRENT' then
		return Data
	end
	if not HISTORY_CACHE[szFilePath] then
		--[[#DEBUG BEGIN]]
		LIB.Debug('MY_Recount_DS.CacheMiss: ' .. szFilePath, DEBUG_LEVEL.LOG)
		--[[#DEBUG END]]
		HISTORY_CACHE[szFilePath] = LIB.LoadLUAData(szFilePath, DS_DATA_CONFIG)
	end
	return HISTORY_CACHE[szFilePath]
end

-- ɾ����ʷͳ������
-- (void) D.Del(szFilePath) -- ɾ��ָ���ļ��ļ�¼
--     (string)szFilePath: ��ʷ��¼�ļ�ȫ·��
-- (void) D.Del(data)       -- ɾ��ָ����¼
function D.Del(data)
	if IsString(data) then
		CPath.DelFile(data)
		HISTORY_CACHE[data] = nil
		UNSAVED_CACHE[data] = nil
		KEPT_CACHE[data] = nil
	else
		for szFilePath, v in pairs(HISTORY_CACHE) do
			if v.data == data then
				HISTORY_CACHE[szFilePath] = nil
				CPath.DelFile(szFilePath)
			end
		end
		for szFilePath, v in pairs(UNSAVED_CACHE) do
			if v.data == data then
				UNSAVED_CACHE[szFilePath] = nil
			end
		end
		for szFilePath, v in pairs(KEPT_CACHE) do
			if v.data == data then
				KEPT_CACHE[szFilePath] = nil
			end
		end
	end
end

-- ��������ʱ��
-- D.GeneAwayTime(data, dwID, szRecordType)
-- data: ����
-- dwID: ��������Ľ�ɫID Ϊ��������Ŷӵ�����ʱ�䣨Ŀǰ��ԶΪ0��
-- szRecordType: ��ͬ���͵������ڹٷ�ʱ���㷨�¼��������ܲ�һ��
--               ö����ʱ�� DK.HEAL DK.DAMAGE DK.BE_DAMAGE DK.BE_HEAL DK.ABSORB ����
do local nFightTime, nAwayTime
function D.GeneAwayTime(data, dwID, szRecordType)
	nFightTime = D.GeneFightTime(data, dwID, szRecordType)
	if szRecordType and data[szRecordType] and data[szRecordType][DK_REC.TIME_DURING] then
		nAwayTime = data[szRecordType][DK_REC.TIME_DURING] - nFightTime
	else
		nAwayTime = data[DK.TIME_DURING] - nFightTime
	end
	return max(nAwayTime, 0)
end
end

-- ����ս��ʱ��
-- D.GeneFightTime(data, dwID, szRecordType)
-- data: ����
-- szRecordType: ��ͬ���͵������ڹٷ�ʱ���㷨�¼��������ܲ�һ��
--               ö����ʱ�� DK.HEAL DK.DAMAGE DK.BE_DAMAGE DK.BE_HEAL DK.ABSORB ����
--               Ϊ���������ͨʱ���㷨
-- dwID: ����ս��ʱ��Ľ�ɫID Ϊ��������Ŷӵ�ս��ʱ��
do local nTimeDuring, nTimeBegin, nAwayBegin, nAwayEnd
function D.GeneFightTime(data, szRecordType, dwID)
	nTimeDuring = data[DK.TIME_DURING]
	nTimeBegin  = data[DK.TIME_BEGIN]
	if nTimeDuring < 0 then
		nTimeDuring = floor(LIB.GetFightTime() / 1000) + nTimeDuring + 1
	end
	if szRecordType and data[szRecordType] and data[szRecordType][DK_REC.TIME_DURING] then
		nTimeDuring = data[szRecordType][DK_REC.TIME_DURING]
	end
	if dwID and data[DK.AWAYTIME] and data[DK.AWAYTIME][dwID] then
		for _, rec in ipairs(data[DK.AWAYTIME][dwID]) do
			nAwayBegin = max(rec[1], nTimeBegin)
			nAwayEnd   = rec[2]
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
-- D.ProcessSkillEffect(dwCaster, dwTarget, nEffectType, dwID, dwLevel, nSkillResult, nResultCount, tResult)
-- (number) dwCaster    : �ͷ���ID
-- (number) dwTarget    : ������ID
-- (number) nEffectType : ���Ч����ԭ��SKILL_EFFECT_TYPEö�� ��SKILL,BUFF��
-- (number) dwID        : ����ID
-- (number) dwLevel     : ���ܵȼ�
-- (number) nSkillResult: ��ɵ�Ч�������SKILL_RESULTö�� ��HIT,MISS��
-- (number) nResultCount: ���Ч������ֵ������tResult���ȣ�
-- (table ) tResult     : ����Ч����ֵ����
do local KCaster, KTarget, dwTargetEmployer, me, szEffectID, nTherapy, nEffectTherapy, nDamage, nEffectDamage, szType
function D.ProcessSkillEffect(nLFC, nTime, nTick, dwCaster, dwTarget, nEffectType, dwEffectID, dwEffectLevel, nSkillResult, nResultCount, tResult)
	-- ��ȡ�ͷŶ���ͳ��ܶ���
	KCaster = LIB.GetObject(dwCaster)
	if KCaster and not IsPlayer(dwCaster) and KCaster.dwEmployer and KCaster.dwEmployer ~= 0 then -- �����������������ͳ����
		KCaster = LIB.GetObject(KCaster.dwEmployer)
	end
	KTarget, dwTargetEmployer = LIB.GetObject(dwTarget), nil
	if KTarget and not IsPlayer(dwTarget) and KTarget.dwEmployer and KTarget.dwEmployer ~= 0 then
		dwTargetEmployer = KTarget.dwEmployer
	end
	if not (KCaster and KTarget) then
		return
	end
	dwCaster = KCaster.dwID
	dwTarget = KTarget.dwID

	-- ���˵����Ƕ��ѵ��Լ����������
	me = GetClientPlayer()
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
	if not LIB.GetFightUUID() and D.nLastAutoInitFrame ~= GetLogicFrameCount() then
		D.nLastAutoInitFrame = GetLogicFrameCount()
		D.InitData()
	end

	-- ��ȡЧ������
	szEffectID = D.InitEffectData(Data, nEffectType, dwEffectID, dwEffectLevel)
	nTherapy = tResult[SKILL_RESULT_TYPE.THERAPY] or 0
	nEffectTherapy = tResult[SKILL_RESULT_TYPE.EFFECTIVE_THERAPY] or 0
	nDamage = (tResult[SKILL_RESULT_TYPE.PHYSICS_DAMAGE      ] or 0) + -- �⹦�˺�
					(tResult[SKILL_RESULT_TYPE.SOLAR_MAGIC_DAMAGE  ] or 0) + -- �����ڹ��˺�
					(tResult[SKILL_RESULT_TYPE.NEUTRAL_MAGIC_DAMAGE] or 0) + -- ��Ԫ���ڹ��˺�
					(tResult[SKILL_RESULT_TYPE.LUNAR_MAGIC_DAMAGE  ] or 0) + -- �����ڹ��˺�
					(tResult[SKILL_RESULT_TYPE.POISON_DAMAGE       ] or 0) + -- �����˺�
					(tResult[SKILL_RESULT_TYPE.REFLECTIED_DAMAGE   ] or 0)   -- �����˺�
	nEffectDamage = tResult[SKILL_RESULT_TYPE.EFFECTIVE_DAMAGE] or 0

	D.InsertEverything(Data,
		nLFC, nTime, nTick,
		EVERYTHING_TYPE.SKILL_EFFECT, dwCaster, dwTarget,
		nEffectType, dwEffectID, dwEffectLevel, szEffectID,
		nSkillResult, nTherapy, nEffectTherapy, nDamage, nEffectDamage,
		tResult)

	if nSkillResult == SKILL_RESULT.HIT -- ����
		or nSkillResult == SKILL_RESULT.CRITICAL -- ����
	then
		if nTherapy > 0 then -- ����������
			D.AddHealRecord(Data, dwCaster, dwTarget, szEffectID, nTherapy, nEffectTherapy, nSkillResult)
		elseif nDamage > 0 then -- ���˺�����
			D.AddDamageRecord(Data, dwCaster, dwTarget, szEffectID, nDamage, nEffectDamage, nSkillResult)
		else -- ���˺������Ƶ�Ч��
			szType = SKILL_TYPE[dwEffectID] and SKILL_TYPE[dwEffectID][dwEffectLevel]
			if szType == 'HEAL' then -- �������Ƽ���
				D.AddHealRecord(Data, dwCaster, dwTarget, szEffectID, nTherapy, nEffectTherapy, nSkillResult)
			else -- if szType == 'DAMAGE' then -- �����������
				D.AddDamageRecord(Data, dwCaster, dwTarget, szEffectID, nDamage, nEffectDamage, nSkillResult)
			end
		end
	elseif nSkillResult == SKILL_RESULT.ABSORB then -- ������
		D.AddAbsorbRecord(Data, dwCaster, dwTarget, szEffectID, nTherapy, nSkillResult)
	elseif nSkillResult == SKILL_RESULT.INSIGHT then -- ʶ��
		D.AddDamageRecord(Data, dwCaster, dwTarget, szEffectID, nDamage, nEffectDamage, SKILL_RESULT.INSIGHT)
	elseif nSkillResult == SKILL_RESULT.BLOCK  -- ��
		or nSkillResult == SKILL_RESULT.SHIELD -- ��Ч
		or nSkillResult == SKILL_RESULT.MISS   -- ƫ��
		or nSkillResult == SKILL_RESULT.DODGE  -- ����
	then
		D.AddDamageRecord(Data, dwCaster, dwTarget, szEffectID, 0, 0, nSkillResult)
	end
end
end

do local nLFC, nTime, nTick
function D.OnSkillEffect(dwCaster, dwTarget, nEffectType, dwEffectID, dwEffectLevel, nSkillResult, nResultCount, tResult)
	nLFC, nTime, nTick = GetLogicFrameCount(), GetCurrentTime(), GetTime()
	while SKILL_EFFECT_CACHE[1] and nLFC - SKILL_EFFECT_CACHE[1][1] > LOG_REPLAY_FRAME do
		remove(SKILL_EFFECT_CACHE, 1)
	end
	insert(SKILL_EFFECT_CACHE, {nLFC, nTime, nTick, dwCaster, dwTarget, nEffectType, dwEffectID, dwEffectLevel, nSkillResult, nResultCount, tResult})
	D.ProcessSkillEffect(nLFC, nTime, nTick, dwCaster, dwTarget, nEffectType, dwEffectID, dwEffectLevel, nSkillResult, nResultCount, tResult)
end
end

do local KCaster, szEffectID
function D.ProcessBuffUpdate(nLFC, nTime, nTick, dwCaster, dwTarget, dwBuffID, dwBuffLevel, nStackNum, bDelete, nEndFrame, bCanCancel)
	KCaster = LIB.GetObject(dwCaster)
	if KCaster and not IsPlayer(dwCaster) and KCaster.dwEmployer and KCaster.dwEmployer ~= 0 then -- �����������������ͳ����
		dwCaster = KCaster.dwEmployer
	end
	szEffectID = D.InitEffectData(Data, SKILL_EFFECT_TYPE.BUFF, dwBuffID, dwBuffLevel)
	D.InitObjectData(Data, dwCaster)
	D.InitObjectData(Data, dwTarget)
	D.InsertEverything(
		Data,
		nLFC, nTime, nTick,
		EVERYTHING_TYPE.BUFF_UPDATE,
		dwCaster, dwTarget, dwBuffID, dwBuffLevel, szEffectID, bDelete, nStackNum, nEndFrame, bCanCancel)
end
end

do local nLFC, nTime, nTick
function D.OnBuffUpdate(dwCaster, dwTarget, dwBuffID, dwBuffLevel, nStackNum, bDelete, nEndFrame, bCanCancel)
	if dwBuffID == 0 then
		return
	end
	nLFC, nTime, nTick = GetLogicFrameCount(), GetCurrentTime(), GetTime()
	while BUFF_UPDATE_CACHE[1] and nLFC - BUFF_UPDATE_CACHE[1][1] > LOG_REPLAY_FRAME do
		remove(BUFF_UPDATE_CACHE, 1)
	end
	insert(BUFF_UPDATE_CACHE, {nLFC, nTime, nTick, dwCaster, dwTarget, dwBuffID, dwBuffLevel, nStackNum, bDelete, nEndFrame, bCanCancel})
	D.ProcessBuffUpdate(nLFC, nTime, nTick, dwCaster, dwTarget, dwBuffID, dwBuffLevel, nStackNum, bDelete, nEndFrame, bCanCancel)
end
end

do local nCurLFC, nLFC, nTime, nTick, dwCaster, dwTarget,
	nEffectType, dwEffectID, dwEffectLevel, nSkillResult, nResultCount, tResult,
	dwBuffID, dwBuffLevel, nStackNum, bDelete, nEndFrame, bCanCancel
function D.ReplayRecentLog()
	nCurLFC = GetLogicFrameCount()
	for _, v in ipairs(SKILL_EFFECT_CACHE) do
		nLFC, nTime, nTick, dwCaster, dwTarget, nEffectType, dwEffectID, dwEffectLevel, nSkillResult, nResultCount, tResult = unpack(v)
		if nCurLFC - nLFC <= LOG_REPLAY_FRAME then
			D.ProcessSkillEffect(nLFC, nTime, nTick, dwCaster, dwTarget, nEffectType, dwEffectID, dwEffectLevel, nSkillResult, nResultCount, tResult)
		end
	end
	for _, v in ipairs(BUFF_UPDATE_CACHE) do
		nLFC, nTime, nTick, dwCaster, dwTarget, dwBuffID, dwBuffLevel, nStackNum, bDelete, nEndFrame, bCanCancel = unpack(v)
		if nCurLFC - nLFC <= LOG_REPLAY_FRAME then
			D.ProcessBuffUpdate(nLFC, nTime, nTick, dwCaster, dwTarget, dwBuffID, dwBuffLevel, nStackNum, bDelete, nEndFrame, bCanCancel)
		end
	end
end
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
do local info
function D.GetEffectNameAusID(data, szChannel, szEffectID)
	if not data or not szChannel or not szEffectID then
		return
	end
	info = data[DK.EFFECT_LIST][szEffectID]
	if info and not IsEmpty(info[1]) then
		if info[3] == SKILL_EFFECT_TYPE.BUFF then
			if szChannel == DK.HEAL or szChannel == DK.BE_HEAL then
				return info[1] .. '(HOT)'
			end
			if szChannel == DK.ABSORB then
				return info[1]
			end
			return info[1] .. '(DOT)'
		end
		return info[1]
	end
end
end

-- �ж��Ƿ����Ѿ�
do local dwID
function D.IsParty(id)
	dwID = tonumber(id)
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
end

-- ���븴������
function D.InsertEverything(data, nLFC, nTime, nTick, szName, ...)
	if not O.bRecEverything then
		return
	end
	insert(data[DK.EVERYTHING], {nLFC, nTime, nTick, szName, ...})
end

-- ��һ����¼��������
do local tInfo, tRecord, tResult, tSkillRecord, tSkillTargetData, tTargetRecord, tTargetSkillData
function D.InsertRecord(data, szRecordType, dwOwnerID, dwTargetID, szEffectID, nValue, nEffectValue, nSkillResult)
	tInfo   = data[szRecordType]
	tRecord = tInfo[DK_REC.STAT][dwOwnerID]
	if not szEffectID or szEffectID == '' then
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
	tResult = tRecord[DK_REC_STAT.DETAIL][nSkillResult]
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
	if not tRecord[DK_REC_STAT.SKILL][szEffectID] then
		tRecord[DK_REC_STAT.SKILL][szEffectID] = {
			[DK_REC_STAT_SKILL.COUNT        ] =  0, -- ����������ֻ��ͷŴ���������szEffectName�������ֻأ�
			[DK_REC_STAT_SKILL.NZ_COUNT     ] =  0, -- ����ҷ���ֵ�����ֻ��ͷŴ���
			[DK_REC_STAT_SKILL.MAX          ] =  0, -- ����������ֻ���������
			[DK_REC_STAT_SKILL.MAX_EFFECT   ] =  0, -- ����������ֻ������Ч�����
			[DK_REC_STAT_SKILL.TOTAL        ] =  0, -- ����������ֻ�������ܺ�
			[DK_REC_STAT_SKILL.TOTAL_EFFECT ] =  0, -- ����������ֻ���Ч������ܺ�
			[DK_REC_STAT_SKILL.AVG          ] =  0, -- ��������������ֻ�ƽ���˺�
			[DK_REC_STAT_SKILL.NZ_AVG       ] =  0, -- ��������з���ֵ�����ֻ�ƽ���˺�
			[DK_REC_STAT_SKILL.AVG_EFFECT   ] =  0, -- ��������������ֻ�ƽ����Ч�˺�
			[DK_REC_STAT_SKILL.NZ_AVG_EFFECT] =  0, -- ��������з���ֵ�����ֻ�ƽ����Ч�˺�
			[DK_REC_STAT_SKILL.DETAIL       ] = {}, -- ����������ֻ�����������ͳ��
			[DK_REC_STAT_SKILL.TARGET       ] = {}, -- ����������ֻس�����ͳ��
		}
	end
	tSkillRecord = tRecord[DK_REC_STAT.SKILL][szEffectID]
	tSkillRecord[DK_REC_STAT_SKILL.COUNT       ] = tSkillRecord[DK_REC_STAT_SKILL.COUNT] + 1
	tSkillRecord[DK_REC_STAT_SKILL.MAX         ] = max(tSkillRecord[DK_REC_STAT_SKILL.MAX], nValue)
	tSkillRecord[DK_REC_STAT_SKILL.MAX_EFFECT  ] = max(tSkillRecord[DK_REC_STAT_SKILL.MAX_EFFECT], nEffectValue)
	tSkillRecord[DK_REC_STAT_SKILL.TOTAL       ] = tSkillRecord[DK_REC_STAT_SKILL.TOTAL] + nValue
	tSkillRecord[DK_REC_STAT_SKILL.TOTAL_EFFECT] = tSkillRecord[DK_REC_STAT_SKILL.TOTAL_EFFECT] + nEffectValue
	tSkillRecord[DK_REC_STAT_SKILL.AVG         ] = floor(tSkillRecord[DK_REC_STAT_SKILL.TOTAL] / tSkillRecord[DK_REC_STAT_SKILL.COUNT])
	tSkillRecord[DK_REC_STAT_SKILL.AVG_EFFECT  ] = floor(tSkillRecord[DK_REC_STAT_SKILL.TOTAL_EFFECT] / tSkillRecord[DK_REC_STAT_SKILL.COUNT])
	if nValue ~= 0 or NZ_SKILL_RESULT[nSkillResult] then
		tSkillRecord[DK_REC_STAT_SKILL.NZ_COUNT]     = tSkillRecord[DK_REC_STAT_SKILL.NZ_COUNT] + 1
		tSkillRecord[DK_REC_STAT_SKILL.NZ_AVG]       = floor(tSkillRecord[DK_REC_STAT_SKILL.TOTAL] / tSkillRecord[DK_REC_STAT_SKILL.NZ_COUNT])
		tSkillRecord[DK_REC_STAT_SKILL.NZ_AVG_EFFECT] = floor(tSkillRecord[DK_REC_STAT_SKILL.TOTAL_EFFECT] / tSkillRecord[DK_REC_STAT_SKILL.NZ_COUNT])
	end

	---------------------------------
	-- # �ڣ� tRecord.Skill[x].Detail
	---------------------------------
	-- ���/���¾��弼�ܽ������ͳ��
	if not tSkillRecord[DK_REC_STAT_SKILL.DETAIL][nSkillResult] then
		tSkillRecord[DK_REC_STAT_SKILL.DETAIL][nSkillResult] = {
			[DK_REC_STAT_SKILL_DETAIL.COUNT        ] =  0, -- ���м�¼����
			[DK_REC_STAT_SKILL_DETAIL.NZ_COUNT     ] =  0, -- ����ֵ���м�¼����
			[DK_REC_STAT_SKILL_DETAIL.MAX          ] =  0, -- �����������ֵ
			[DK_REC_STAT_SKILL_DETAIL.MAX_EFFECT   ] =  0, -- �������������Чֵ
			[DK_REC_STAT_SKILL_DETAIL.MIN          ] = -1, -- ����������Сֵ
			[DK_REC_STAT_SKILL_DETAIL.NZ_MIN       ] = -1, -- ���η���ֵ������Сֵ
			[DK_REC_STAT_SKILL_DETAIL.MIN_EFFECT   ] = -1, -- ����������С��Чֵ
			[DK_REC_STAT_SKILL_DETAIL.NZ_MIN_EFFECT] = -1, -- ���η���ֵ������С��Чֵ
			[DK_REC_STAT_SKILL_DETAIL.TOTAL        ] =  0, -- �����������˺�
			[DK_REC_STAT_SKILL_DETAIL.TOTAL_EFFECT ] =  0, -- ������������Ч�˺�
			[DK_REC_STAT_SKILL_DETAIL.AVG          ] =  0, -- ��������ƽ���˺�
			[DK_REC_STAT_SKILL_DETAIL.NZ_AVG       ] =  0, -- ���з���ֵ����ƽ���˺�
			[DK_REC_STAT_SKILL_DETAIL.AVG_EFFECT   ] =  0, -- ��������ƽ����Ч�˺�
			[DK_REC_STAT_SKILL_DETAIL.NZ_AVG_EFFECT] =  0, -- ���з���ֵ����ƽ����Ч�˺�
		}
	end
	tResult = tSkillRecord[DK_REC_STAT_SKILL.DETAIL][nSkillResult]
	tResult[DK_REC_STAT_SKILL_DETAIL.COUNT       ] = tResult[DK_REC_STAT_SKILL_DETAIL.COUNT] + 1 -- ���д���������nSkillResult�����У�
	tResult[DK_REC_STAT_SKILL_DETAIL.MAX         ] = max(tResult[DK_REC_STAT_SKILL_DETAIL.MAX], nValue) -- �����������ֵ
	tResult[DK_REC_STAT_SKILL_DETAIL.MAX_EFFECT  ] = max(tResult[DK_REC_STAT_SKILL_DETAIL.MAX_EFFECT], nEffectValue) -- �������������Чֵ
	tResult[DK_REC_STAT_SKILL_DETAIL.MIN         ] = Min(tResult[DK_REC_STAT_SKILL_DETAIL.MIN], nValue) -- ����������Сֵ
	tResult[DK_REC_STAT_SKILL_DETAIL.MIN_EFFECT  ] = Min(tResult[DK_REC_STAT_SKILL_DETAIL.MIN_EFFECT], nEffectValue) -- ����������С��Чֵ
	tResult[DK_REC_STAT_SKILL_DETAIL.TOTAL       ] = tResult[DK_REC_STAT_SKILL_DETAIL.TOTAL] + nValue -- �����������˺�
	tResult[DK_REC_STAT_SKILL_DETAIL.TOTAL_EFFECT] = tResult[DK_REC_STAT_SKILL_DETAIL.TOTAL_EFFECT] + nEffectValue -- ������������Ч�˺�
	tResult[DK_REC_STAT_SKILL_DETAIL.AVG         ] = floor(tResult[DK_REC_STAT_SKILL_DETAIL.TOTAL] / tResult[DK_REC_STAT_SKILL_DETAIL.COUNT])
	tResult[DK_REC_STAT_SKILL_DETAIL.AVG_EFFECT  ] = floor(tResult[DK_REC_STAT_SKILL_DETAIL.TOTAL_EFFECT] / tResult[DK_REC_STAT_SKILL_DETAIL.COUNT])
	if nValue ~= 0 or NZ_SKILL_RESULT[nSkillResult] then
		tResult[DK_REC_STAT_SKILL_DETAIL.NZ_COUNT     ] = tResult[DK_REC_STAT_SKILL_DETAIL.NZ_COUNT] + 1 -- ���д���������nSkillResult�����У�
		tResult[DK_REC_STAT_SKILL_DETAIL.NZ_MIN       ] = Min(tResult[DK_REC_STAT_SKILL_DETAIL.NZ_MIN], nValue) -- ����������Сֵ
		tResult[DK_REC_STAT_SKILL_DETAIL.NZ_MIN_EFFECT] = Min(tResult[DK_REC_STAT_SKILL_DETAIL.NZ_MIN_EFFECT], nEffectValue) -- ����������С��Чֵ
		tResult[DK_REC_STAT_SKILL_DETAIL.NZ_AVG       ] = floor(tResult[DK_REC_STAT_SKILL_DETAIL.TOTAL] / tResult[DK_REC_STAT_SKILL_DETAIL.NZ_COUNT])
		tResult[DK_REC_STAT_SKILL_DETAIL.NZ_AVG_EFFECT] = floor(tResult[DK_REC_STAT_SKILL_DETAIL.TOTAL_EFFECT] / tResult[DK_REC_STAT_SKILL_DETAIL.NZ_COUNT])
	end

	------------------------------
	-- # �ڣ� tRecord.Skill.Target
	------------------------------
	-- ��Ӿ��弼�ܳ����߼�¼
	if not tSkillRecord[DK_REC_STAT_SKILL.TARGET][dwTargetID] then
		tSkillRecord[DK_REC_STAT_SKILL.TARGET][dwTargetID] = {
			[DK_REC_STAT_SKILL_TARGET.MAX         ] = 0, -- ����������ֻػ��е�����������˺�
			[DK_REC_STAT_SKILL_TARGET.MAX_EFFECT  ] = 0, -- ����������ֻػ��е������������Ч�˺�
			[DK_REC_STAT_SKILL_TARGET.TOTAL       ] = 0, -- ����������ֻػ��е��������˺��ܺ�
			[DK_REC_STAT_SKILL_TARGET.TOTAL_EFFECT] = 0, -- ����������ֻػ��е���������Ч�˺��ܺ�
			[DK_REC_STAT_SKILL_TARGET.COUNT       ] = {  -- ����������ֻػ��е������ҽ��ͳ��
				-- [SKILL_RESULT.HIT     ] = 5,
				-- [SKILL_RESULT.MISS    ] = 3,
				-- [SKILL_RESULT.CRITICAL] = 3,
			},
			[DK_REC_STAT_SKILL_TARGET.NZ_COUNT    ] = {  -- ����ҷ���ֵ�����ֻػ��е������ҽ��ͳ��
				-- [SKILL_RESULT.HIT     ] = 5,
				-- [SKILL_RESULT.MISS    ] = 3,
				-- [SKILL_RESULT.CRITICAL] = 3,
			},
		}
	end
	tSkillTargetData = tSkillRecord[DK_REC_STAT_SKILL.TARGET][dwTargetID]
	tSkillTargetData[DK_REC_STAT_SKILL_TARGET.MAX         ] = max(tSkillTargetData[DK_REC_STAT_SKILL_TARGET.MAX], nValue)
	tSkillTargetData[DK_REC_STAT_SKILL_TARGET.MAX_EFFECT  ] = max(tSkillTargetData[DK_REC_STAT_SKILL_TARGET.MAX_EFFECT], nEffectValue)
	tSkillTargetData[DK_REC_STAT_SKILL_TARGET.TOTAL       ] = tSkillTargetData[DK_REC_STAT_SKILL_TARGET.TOTAL] + nValue
	tSkillTargetData[DK_REC_STAT_SKILL_TARGET.TOTAL_EFFECT] = tSkillTargetData[DK_REC_STAT_SKILL_TARGET.TOTAL_EFFECT] + nEffectValue
	tSkillTargetData[DK_REC_STAT_SKILL_TARGET.COUNT][nSkillResult] = (tSkillTargetData[DK_REC_STAT_SKILL_TARGET.COUNT][nSkillResult] or 0) + 1
	if nValue ~= 0 then
		tSkillTargetData[DK_REC_STAT_SKILL_TARGET.NZ_COUNT][nSkillResult] = (tSkillTargetData[DK_REC_STAT_SKILL_TARGET.NZ_COUNT][nSkillResult] or 0) + 1
	end

	------------------------
	-- # �ڣ� tRecord.Target
	------------------------
	-- ��Ӿ������/�ͷ��߼�¼
	if not tRecord[DK_REC_STAT.TARGET][dwTargetID] then
		tRecord[DK_REC_STAT.TARGET][dwTargetID] = {
			[DK_REC_STAT_TARGET.COUNT        ] =  0, -- ����Ҷ�idTarget�ļ����ͷŴ���
			[DK_REC_STAT_TARGET.NZ_COUNT     ] =  0, -- ����Ҷ�idTarget�ķ���ֵ�����ͷŴ���
			[DK_REC_STAT_TARGET.MAX          ] =  0, -- ����Ҷ�idTarget�ļ�����������
			[DK_REC_STAT_TARGET.MAX_EFFECT   ] =  0, -- ����Ҷ�idTarget�ļ��������Ч�����
			[DK_REC_STAT_TARGET.TOTAL        ] =  0, -- ����Ҷ�idTarget�ļ���������ܺ�
			[DK_REC_STAT_TARGET.TOTAL_EFFECT ] =  0, -- ����Ҷ�idTarget�ļ�����Ч������ܺ�
			[DK_REC_STAT_TARGET.AVG          ] =  0, -- ����Ҷ�idTarget�ļ���ƽ�������
			[DK_REC_STAT_TARGET.NZ_AVG       ] =  0, -- ����Ҷ�idTarget�ķ���ֵ����ƽ�������
			[DK_REC_STAT_TARGET.AVG_EFFECT   ] =  0, -- ����Ҷ�idTarget�ļ���ƽ����Ч�����
			[DK_REC_STAT_TARGET.NZ_AVG_EFFECT] =  0, -- ����Ҷ�idTarget�ķ���ֵ����ƽ����Ч�����
			[DK_REC_STAT_TARGET.DETAIL       ] = {}, -- ����Ҷ�idTarget�ļ�������������ͳ��
			[DK_REC_STAT_TARGET.SKILL        ] = {}, -- ����Ҷ�idTarget�ļ��ܾ���ֱ�ͳ��
		}
	end
	tTargetRecord = tRecord[DK_REC_STAT.TARGET][dwTargetID]
	tTargetRecord[DK_REC_STAT_TARGET.COUNT       ] = tTargetRecord[DK_REC_STAT_TARGET.COUNT] + 1
	tTargetRecord[DK_REC_STAT_TARGET.MAX         ] = max(tTargetRecord[DK_REC_STAT_TARGET.MAX], nValue)
	tTargetRecord[DK_REC_STAT_TARGET.MAX_EFFECT  ] = max(tTargetRecord[DK_REC_STAT_TARGET.MAX_EFFECT], nEffectValue)
	tTargetRecord[DK_REC_STAT_TARGET.TOTAL       ] = tTargetRecord[DK_REC_STAT_TARGET.TOTAL] + nValue
	tTargetRecord[DK_REC_STAT_TARGET.TOTAL_EFFECT] = tTargetRecord[DK_REC_STAT_TARGET.TOTAL_EFFECT] + nEffectValue
	tTargetRecord[DK_REC_STAT_TARGET.AVG         ] = floor(tTargetRecord[DK_REC_STAT_TARGET.TOTAL] / tTargetRecord[DK_REC_STAT_TARGET.COUNT])
	tTargetRecord[DK_REC_STAT_TARGET.AVG_EFFECT  ] = floor(tTargetRecord[DK_REC_STAT_TARGET.TOTAL_EFFECT] / tTargetRecord[DK_REC_STAT_TARGET.COUNT])
	if nValue ~= 0 or NZ_SKILL_RESULT[nSkillResult] then
		tTargetRecord[DK_REC_STAT_TARGET.NZ_COUNT     ] = tTargetRecord[DK_REC_STAT_TARGET.NZ_COUNT] + 1
		tTargetRecord[DK_REC_STAT_TARGET.NZ_AVG       ] = floor(tTargetRecord[DK_REC_STAT_TARGET.TOTAL] / tTargetRecord[DK_REC_STAT_TARGET.NZ_COUNT])
		tTargetRecord[DK_REC_STAT_TARGET.NZ_AVG_EFFECT] = floor(tTargetRecord[DK_REC_STAT_TARGET.TOTAL_EFFECT] / tTargetRecord[DK_REC_STAT_TARGET.NZ_COUNT])
	end

	----------------------------------
	-- # �ڣ� tRecord.Target[x].Detail
	----------------------------------
	-- ���/���¾������/�ͷ��߽������ͳ��
	if not tTargetRecord[DK_REC_STAT_TARGET.DETAIL][nSkillResult] then
		tTargetRecord[DK_REC_STAT_TARGET.DETAIL][nSkillResult] = {
			[DK_REC_STAT_TARGET_DETAIL.COUNT        ] =  0, -- ���м�¼����������nSkillResult�����У�
			[DK_REC_STAT_TARGET_DETAIL.NZ_COUNT     ] =  0, -- ����ֵ���м�¼����
			[DK_REC_STAT_TARGET_DETAIL.MAX          ] =  0, -- �����������ֵ
			[DK_REC_STAT_TARGET_DETAIL.MAX_EFFECT   ] =  0, -- �������������Чֵ
			[DK_REC_STAT_TARGET_DETAIL.MIN          ] = -1, -- ����������Сֵ
			[DK_REC_STAT_TARGET_DETAIL.NZ_MIN       ] = -1, -- ���η���ֵ������Сֵ
			[DK_REC_STAT_TARGET_DETAIL.MIN_EFFECT   ] = -1, -- ����������С��Чֵ
			[DK_REC_STAT_TARGET_DETAIL.NZ_MIN_EFFECT] = -1, -- ���η���ֵ������С��Чֵ
			[DK_REC_STAT_TARGET_DETAIL.TOTAL        ] =  0, -- �����������˺�
			[DK_REC_STAT_TARGET_DETAIL.TOTAL_EFFECT ] =  0, -- ������������Ч�˺�
			[DK_REC_STAT_TARGET_DETAIL.AVG          ] =  0, -- ��������ƽ���˺�
			[DK_REC_STAT_TARGET_DETAIL.NZ_AVG       ] =  0, -- ���з���ֵ����ƽ���˺�
			[DK_REC_STAT_TARGET_DETAIL.AVG_EFFECT   ] =  0, -- ��������ƽ����Ч�˺�
			[DK_REC_STAT_TARGET_DETAIL.NZ_AVG_EFFECT] =  0, -- ���з���ֵ����ƽ����Ч�˺�
		}
	end
	tResult = tTargetRecord[DK_REC_STAT_TARGET.DETAIL][nSkillResult]
	tResult[DK_REC_STAT_TARGET_DETAIL.COUNT       ] = tResult[DK_REC_STAT_TARGET_DETAIL.COUNT] + 1 -- ���д���������nSkillResult�����У�
	tResult[DK_REC_STAT_TARGET_DETAIL.MAX         ] = max(tResult[DK_REC_STAT_TARGET_DETAIL.MAX], nValue) -- �����������ֵ
	tResult[DK_REC_STAT_TARGET_DETAIL.MAX_EFFECT  ] = max(tResult[DK_REC_STAT_TARGET_DETAIL.MAX_EFFECT], nEffectValue) -- �������������Чֵ
	tResult[DK_REC_STAT_TARGET_DETAIL.MIN         ] = Min(tResult[DK_REC_STAT_TARGET_DETAIL.MIN], nValue) -- ����������Сֵ
	tResult[DK_REC_STAT_TARGET_DETAIL.MIN_EFFECT  ] = Min(tResult[DK_REC_STAT_TARGET_DETAIL.MIN_EFFECT], nEffectValue) -- ����������С��Чֵ
	tResult[DK_REC_STAT_TARGET_DETAIL.TOTAL       ] = tResult[DK_REC_STAT_TARGET_DETAIL.TOTAL] + nValue -- �����������˺�
	tResult[DK_REC_STAT_TARGET_DETAIL.TOTAL_EFFECT] = tResult[DK_REC_STAT_TARGET_DETAIL.TOTAL_EFFECT] + nEffectValue -- ������������Ч�˺�
	tResult[DK_REC_STAT_TARGET_DETAIL.AVG         ] = floor(tResult[DK_REC_STAT_TARGET_DETAIL.TOTAL] / tResult[DK_REC_STAT_TARGET_DETAIL.COUNT])
	tResult[DK_REC_STAT_TARGET_DETAIL.AVG_EFFECT  ] = floor(tResult[DK_REC_STAT_TARGET_DETAIL.TOTAL_EFFECT] / tResult[DK_REC_STAT_TARGET_DETAIL.COUNT])
	if nValue ~= 0 or NZ_SKILL_RESULT[nSkillResult] then
		tResult[DK_REC_STAT_TARGET_DETAIL.NZ_COUNT     ] = tResult[DK_REC_STAT_TARGET_DETAIL.NZ_COUNT] + 1 -- ���д���������nSkillResult�����У�
		tResult[DK_REC_STAT_TARGET_DETAIL.NZ_MIN       ] = Min(tResult[DK_REC_STAT_TARGET_DETAIL.NZ_MIN], nValue) -- ����������Сֵ
		tResult[DK_REC_STAT_TARGET_DETAIL.NZ_MIN_EFFECT] = Min(tResult[DK_REC_STAT_TARGET_DETAIL.NZ_MIN_EFFECT], nEffectValue) -- ����������С��Чֵ
		tResult[DK_REC_STAT_TARGET_DETAIL.NZ_AVG       ] = floor(tResult[DK_REC_STAT_TARGET_DETAIL.TOTAL] / tResult[DK_REC_STAT_TARGET_DETAIL.NZ_COUNT])
		tResult[DK_REC_STAT_TARGET_DETAIL.NZ_AVG_EFFECT] = floor(tResult[DK_REC_STAT_TARGET_DETAIL.TOTAL_EFFECT] / tResult[DK_REC_STAT_TARGET_DETAIL.NZ_COUNT])
	end

	---------------------------------
	-- # �ڣ� tRecord.Target[x].Skill
	---------------------------------
	-- ��ӳ����߾��弼�ܼ�¼
	if not tTargetRecord[DK_REC_STAT_TARGET.SKILL][szEffectID] then
		tTargetRecord[DK_REC_STAT_TARGET.SKILL][szEffectID] = {
			[DK_REC_STAT_TARGET_SKILL.MAX         ] = 0, -- ����һ��������ҵ������ֻ�����˺�
			[DK_REC_STAT_TARGET_SKILL.MAX_EFFECT  ] = 0, -- ����һ��������ҵ������ֻ������Ч�˺�
			[DK_REC_STAT_TARGET_SKILL.TOTAL       ] = 0, -- ����һ��������ҵ������ֻ��˺��ܺ�
			[DK_REC_STAT_TARGET_SKILL.TOTAL_EFFECT] = 0, -- ����һ��������ҵ������ֻ���Ч�˺��ܺ�
			[DK_REC_STAT_TARGET_SKILL.COUNT       ] = {  -- ����һ��������ҵ������ֻؽ��ͳ��
				-- [SKILL_RESULT.HIT     ] = 5,
				-- [SKILL_RESULT.MISS    ] = 3,
				-- [SKILL_RESULT.CRITICAL] = 3,
			},
			[DK_REC_STAT_TARGET_SKILL.NZ_COUNT    ] = {  -- ����ҷ���ֵ���������ҵ������ֻؽ��ͳ��
				-- [SKILL_RESULT.HIT     ] = 5,
				-- [SKILL_RESULT.MISS    ] = 3,
				-- [SKILL_RESULT.CRITICAL] = 3,
			},
		}
	end
	tTargetSkillData = tTargetRecord[DK_REC_STAT_TARGET.SKILL][szEffectID]
	tTargetSkillData[DK_REC_STAT_TARGET_SKILL.MAX         ] = max(tTargetSkillData[DK_REC_STAT_TARGET_SKILL.MAX], nValue)
	tTargetSkillData[DK_REC_STAT_TARGET_SKILL.MAX_EFFECT  ] = max(tTargetSkillData[DK_REC_STAT_TARGET_SKILL.MAX_EFFECT], nEffectValue)
	tTargetSkillData[DK_REC_STAT_TARGET_SKILL.TOTAL       ] = tTargetSkillData[DK_REC_STAT_TARGET_SKILL.TOTAL] + nValue
	tTargetSkillData[DK_REC_STAT_TARGET_SKILL.TOTAL_EFFECT] = tTargetSkillData[DK_REC_STAT_TARGET_SKILL.TOTAL_EFFECT] + nEffectValue
	tTargetSkillData[DK_REC_STAT_TARGET_SKILL.COUNT][nSkillResult] = (tTargetSkillData[DK_REC_STAT_TARGET_SKILL.COUNT][nSkillResult] or 0) + 1
	if nValue ~= 0 then
		tTargetSkillData[DK_REC_STAT_TARGET_SKILL.NZ_COUNT][nSkillResult] = (tTargetSkillData[DK_REC_STAT_TARGET_SKILL.NZ_COUNT][nSkillResult] or 0) + 1
	end
	tInfo, tRecord, tResult, tSkillRecord, tSkillTargetData, tTargetRecord, tTargetSkillData = nil
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

-- ����һ�������¼
function D.AddAbsorbRecord(data, dwCaster, dwTarget, szEffectID, nAbsorb, nSkillResult)
	-- ��ӻ����¼
	D.InitObjectData(data, dwCaster, DK.ABSORB)
	D.InsertRecord(data, DK.ABSORB, dwCaster, dwTarget, szEffectID, nAbsorb, nAbsorb, nSkillResult)
end

-- ���������Ϣ
function D.SavePlayerInfo(data, dwID, bRefresh)
	if (bRefresh or not data[DK.PLAYER_LIST][dwID]) and IsPlayer(dwID) then
		local player, info = D.GetPlayer(dwID)
		if player and info and not IsEmpty(info.dwMountKungfuID) then
			local aEquip, nEquipScore = {}, player.GetTotalEquipScore()
			for nEquipIndex, tEquipInfo in pairs(LIB.GetPlayerEquipInfo(player)) do
				insert(aEquip, {
					nEquipIndex,
					tEquipInfo.dwTabType,
					tEquipInfo.dwTabIndex,
					tEquipInfo.nStrengthLevel,
					tEquipInfo.aSlotItem,
					tEquipInfo.dwPermanentEnchantID,
					tEquipInfo.dwTemporaryEnchantID,
					tEquipInfo.dwTemporaryEnchantLeftSeconds,
				})
			end
			if not IsEmpty(aEquip) and not IsEmpty(nEquipScore) then
				local aInfo = {
					info.dwMountKungfuID,
					player.GetTotalEquipScore(),
					aEquip,
				}
				data[DK.PLAYER_LIST][dwID] = aInfo
			end
		end
	end
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
	if szChannel and not data[szChannel][DK_REC.STAT][dwID] then
		data[szChannel][DK_REC.STAT][dwID] = {
			[DK_REC_STAT.TOTAL       ] = 0 , -- �����
			[DK_REC_STAT.TOTAL_EFFECT] = 0 , -- ��Ч���
			[DK_REC_STAT.DETAIL      ] = {}, -- �����������ܽ������ͳ��
			[DK_REC_STAT.SKILL       ] = {}, -- ����Ҿ����������ļ���ͳ��
			[DK_REC_STAT.TARGET      ] = {}, -- ����Ҿ����˭��������ͳ��
		}
	end
	-- �����Ϣ����
	D.SavePlayerInfo(data, dwID)
end

do local szKey
function D.InitEffectData(data, nType, dwID, nLevel)
	szKey = nType .. ',' .. dwID .. ',' .. nLevel
	if not data[DK.EFFECT_LIST][szKey] then
		local szName, bAnonymous = nil, false
		if nType == SKILL_EFFECT_TYPE.SKILL then
			szName = Table_GetSkillName(dwID, nLevel)
		elseif nType == SKILL_EFFECT_TYPE.BUFF then
			szName = Table_GetBuffName(dwID, nLevel)
		end
		if not szName or szName == '' then
			bAnonymous = true
			szName = '#' .. dwID .. ',' .. nLevel
		end
		data[DK.EFFECT_LIST][szKey] = {szName, bAnonymous, nType, dwID, nLevel}
	end
	return szKey
end
end

-- ��ʼ��Data
do
local function GeneTypeNS()
	return {
		[DK_REC.TIME_DURING ] = 0,
		[DK_REC.TOTAL       ] = 0,
		[DK_REC.TOTAL_EFFECT] = 0,
		[DK_REC.STAT        ] = {},
	}
end
function D.InitData()
	local bFighting = LIB.IsFighting()
	local nFightTick = bFighting and LIB.GetFightTime() or 0
	Data = {
		[DK.UUID       ] = LIB.GetFightUUID(),                -- ս��Ψһ��ʶ
		[DK.VERSION    ] = VERSION,                           -- ���ݰ汾��
		[DK.SERVER     ] = LIB.GetRealServer(2),              -- ���ڷ�����
		[DK.MAP        ] = LIB.GetMapID(),                    -- ���ڵ�ͼ
		[DK.TIME_BEGIN ] = GetCurrentTime(),                  -- ս����ʼʱ��
		[DK.TICK_BEGIN ] = GetTime(),                         -- ս����ʼ����ʱ��
		[DK.TIME_DURING] = - (nFightTick / 1000) - 1,         -- ս������ʱ�� ������ʾ����ս����δ���� ����ֵΪ��¼��ʼʱ����ս��������һ
		[DK.TICK_DURING] = - nFightTick - 1,                  -- ս����������ʱ�� ������ʾ����ս����δ���� ����ֵΪ��¼��ʼʱ����ս����������һ
		[DK.AWAYTIME   ] = {},                                -- ����/����ʱ��ڵ�
		[DK.NAME_LIST  ] = {},                                -- ���ƻ���
		[DK.FORCE_LIST ] = {},                                -- ��������
		[DK.PLAYER_LIST] = {},                                -- �����Ϣ����
		[DK.EFFECT_LIST] = {},                                -- Ч����Ϣ����
		[DK.DAMAGE     ] = GeneTypeNS(),                      -- ���ͳ��
		[DK.HEAL       ] = GeneTypeNS(),                      -- ����ͳ��
		[DK.BE_HEAL    ] = GeneTypeNS(),                      -- ����ͳ��
		[DK.BE_DAMAGE  ] = GeneTypeNS(),                      -- ����ͳ��
		[DK.ABSORB     ] = GeneTypeNS(),                      -- ����ͳ��
		[DK.EVERYTHING ] = {},                                -- ս������
	}
end
end

-- Data����ѹ����ʷ��¼ �����³�ʼ��Data
function D.Flush()
	if Data and Data[DK.UUID] then
		-- ���˿ռ�¼
		if IsEmpty(Data[DK.BE_DAMAGE][DK_REC.STAT])
		and IsEmpty(Data[DK.DAMAGE][DK_REC.STAT])
		and IsEmpty(Data[DK.HEAL][DK_REC.STAT])
		and IsEmpty(Data[DK.BE_HEAL][DK_REC.STAT]) then
			return
		end

		-- ������������������Ϊս������
		local nMaxValue, szBossName = 0, nil
		local nEnemyMaxValue, szEnemyBossName = 0, nil
		for id, p in pairs(Data[DK.BE_DAMAGE][DK_REC.STAT]) do
			if nEnemyMaxValue < p[DK_REC_STAT.TOTAL_EFFECT] and not D.IsParty(id) then
				nEnemyMaxValue  = p[DK_REC_STAT.TOTAL_EFFECT]
				szEnemyBossName = D.GetNameAusID(Data, id)
			end
			if nMaxValue < p[DK_REC_STAT.TOTAL_EFFECT] and id ~= UI_GetClientPlayerID() then
				nMaxValue  = p[DK_REC_STAT.TOTAL_EFFECT]
				szBossName = D.GetNameAusID(Data, id)
			end
		end
		-- ���û�� ������������NPC������Ϊս������
		if not szBossName or not szEnemyBossName then
			for id, p in pairs(Data[DK.DAMAGE][DK_REC.STAT]) do
				if nEnemyMaxValue < p[DK_REC_STAT.TOTAL_EFFECT] and not D.IsParty(id) then
					nEnemyMaxValue  = p[DK_REC_STAT.TOTAL_EFFECT]
					szEnemyBossName = D.GetNameAusID(Data, id)
				end
				if nMaxValue < p[DK_REC_STAT.TOTAL_EFFECT] and not tonumber(id) then
					nMaxValue  = p[DK_REC_STAT.TOTAL_EFFECT]
					szBossName = D.GetNameAusID(Data, id)
				end
			end
		end
		Data[DK.BOSSNAME] = szEnemyBossName or szBossName or g_tStrings.STR_NAME_UNKNOWN

		local nFightTick = LIB.GetFightTime() or 0
		Data[DK.TIME_DURING] = floor(nFightTick / 1000) + Data[DK.TIME_DURING] + 1
		Data[DK.TICK_DURING] = nFightTick + Data[DK.TICK_DURING] + 1

		if Data[DK.TIME_DURING] > O.nMinFightTime then
			local szFilePath = LIB.FormatPath(DS_ROOT) .. D.GetDataFileName(Data)
			HISTORY_CACHE[szFilePath] = Data
			UNSAVED_CACHE[szFilePath] = Data
			if O.bSaveHistoryOnExFi then
				D.SaveHistory()
			end
		end
	end
	D.InitData()
end

-- ϵͳ��־��أ�����Դ��
do local aAbsorbInfo, nLFC
LIB.RegisterEvent('SYS_MSG', function()
	if not O.bEnable then
		return
	end
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
		elseif arg9[SKILL_RESULT_TYPE.INSIGHT_DAMAGE] then -- ʶ��
			D.OnSkillEffect(arg1, arg2, arg4, arg5, arg6, SKILL_RESULT.INSIGHT, arg8, arg9)
		else
			D.OnSkillEffect(arg1, arg2, arg4, arg5, arg6, SKILL_RESULT.HIT, arg8, arg9)
		end
		-- �ܻ����˺����������ṩ�ߵ�������
		if arg9[SKILL_RESULT_TYPE.ABSORB_DAMAGE] then
			aAbsorbInfo = ABSORB_CACHE[arg2]
			nLFC = GetLogicFrameCount()
			if aAbsorbInfo then
				for _, tAbsorbInfo in ipairs(aAbsorbInfo) do
					if tAbsorbInfo.nEndFrame >= nLFC then
						D.OnSkillEffect(
							tAbsorbInfo.dwSrcID, arg2,
							tAbsorbInfo.nEffectType, tAbsorbInfo.dwEffectID, tAbsorbInfo.dwEffectLevel,
							SKILL_RESULT.ABSORB, 1, {
								[SKILL_RESULT_TYPE.THERAPY] = arg9[SKILL_RESULT_TYPE.ABSORB_DAMAGE],
								[SKILL_RESULT_TYPE.EFFECTIVE_THERAPY] = arg9[SKILL_RESULT_TYPE.ABSORB_DAMAGE],
							})
						break
					end
				end
			end
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
end

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
--         elseif tResult[SKILL_RESULT_TYPE.INSIGHT_DAMAGE] then -- ʶ��
--             D.OnSkillEffect(dwCasterID, dwTargetID, nEffectType, dwSkillID, dwSkillLevel, SKILL_RESULT.INSIGHT, nResultCount, tResult)
--         else
--             D.OnSkillEffect(dwCasterID, dwTargetID, nEffectType, dwSkillID, dwSkillLevel, SKILL_RESULT.HIT, nResultCount, tResult)
--         end
--     end
-- end)


-- ϵͳBUFF��أ�����Դ��
do local nAbsorbPriority, nLFC, aAbsorbInfo, tAbsorbInfo
local function AbsorbSorter(p1, p2)
	if p1.nPriority == p2.nPriority then
		return p1.dwInitTime < p2.dwInitTime
	end
	return p1.nPriority > p2.nPriority
end
LIB.RegisterEvent('BUFF_UPDATE', function()
	-- local owner, bdelete, index, cancancel, id  , stacknum, endframe, binit, level, srcid, isvalid, leftframe
	--     = arg0 , arg1   , arg2 , arg3     , arg4, arg5    , arg6    , arg7 , arg8 , arg9 , arg10  , arg11
	if not O.bEnable then
		return
	end
	nAbsorbPriority = ABSORB_BUFF[arg4]
	if nAbsorbPriority then -- BUFF��
		aAbsorbInfo = ABSORB_CACHE[arg0]
		if not aAbsorbInfo then
			aAbsorbInfo = {}
			ABSORB_CACHE[arg0] = aAbsorbInfo
		end
		tAbsorbInfo = nil
		for _, v in ipairs(aAbsorbInfo) do
			if v.dwViaID == arg4 then
				tAbsorbInfo = v
				break
			end
		end
		nLFC = GetLogicFrameCount()
		if arg1 then
			if tAbsorbInfo then
				tAbsorbInfo.nEndFrame = nLFC
			end
		else
			if not tAbsorbInfo then
				tAbsorbInfo = {
					nPriority = nAbsorbPriority,
					dwViaID = arg4,
					dwInitTime = nLFC,
				}
				insert(aAbsorbInfo, tAbsorbInfo)
				sort(aAbsorbInfo, AbsorbSorter)
			end
			if arg7 then
				tAbsorbInfo.dwInitTime = nLFC
				sort(aAbsorbInfo, AbsorbSorter)
			end
			tAbsorbInfo.dwSrcID = arg9
			tAbsorbInfo.nEffectType = SKILL_EFFECT_TYPE.BUFF
			tAbsorbInfo.dwEffectID = arg4
			tAbsorbInfo.dwEffectLevel = arg8
			tAbsorbInfo.nEndFrame = arg6
		end
	end
	-- buff update��
	-- arg0��dwPlayerID��arg1��bDelete��arg2��nIndex��arg3��bCanCancel
	-- arg4��dwBuffID��arg5��nStackNum��arg6��nEndFrame��arg7����update all?
	-- arg8��nLevel��arg9��dwSkillSrcID
	D.OnBuffUpdate(arg9, arg0, arg4, arg8, arg5, arg1, arg6, arg3)
end)
end

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
	if not O.bEnable then
		return
	end
	local team = GetClientTeam()
	local info = team.GetMemberInfo(arg1)
	if info then
		D.OnTeammateStateChange(arg1, info.bDeathFlag, AWAYTIME_TYPE.DEATH, false)
	end
end)
for _, v in ipairs({
	{'NPC_ENTER_SCENE', TARGET.NPC, 1},
	{'NPC_LEAVE_SCENE', TARGET.NPC, 0},
	{'DOODAD_ENTER_SCENE', TARGET.DOODAD, 1},
	{'DOODAD_LEAVE_SCENE', TARGET.DOODAD, 0},
	{'PLAYER_ENTER_SCENE', TARGET.PLAYER, 1},
	{'PLAYER_LEAVE_SCENE', TARGET.PLAYER, 0},
}) do
	local szEvent, dwType, nEnter = unpack(v)
	LIB.RegisterEvent(szEvent, function()
		if not O.bEnable then
			return
		end
		-- �������ݵ���־
		local nLFC, nTime, nTick = GetLogicFrameCount(), GetCurrentTime(), GetTime()
		local dwID, dwTemplateID = arg0, 0
		local KObject = LIB.GetObject(dwType, dwID)
		local nCurrentLife, nMaxLife, nCurrentMana, nMaxMana = 0, 0
		if KObject and (dwType == TARGET.NPC or dwType == TARGET.PLAYER) then
			nCurrentLife, nMaxLife = KObject.nCurrentLife, KObject.nMaxLife
			nCurrentMana, nMaxMana = KObject.nCurrentMana, KObject.nMaxMana
		end
		if dwType == TARGET.NPC or dwType == TARGET.DOODAD then
			if KObject then
				dwTemplateID = KObject.dwTemplateID
			end
		elseif dwType == TARGET.PLAYER then
			if not LIB.IsParty(dwID) then
				return
			end
			D.SavePlayerInfo(Data, dwID, true)
		end
		D.InsertEverything(
			Data, nLFC, nTime, nTick,
			EVERYTHING_TYPE.ENTER_LEAVE_SCENE, nEnter,
			TARGET.NPC, dwID,
			LIB.GetObjectName(TARGET.NPC, dwID, 'never'), dwTemplateID,
			nCurrentLife, nMaxLife, nCurrentMana, nMaxMana
		)
	end)
end
-- ϵͳ��Ϣ��־
LIB.RegisterMsgMonitor('MSG_SYS.MY_Recount_DS_Everything', function(szChannel, szMsg, nFont, bRich)
	if not O.bEnable then
		return
	end
	if bRich then
		szMsg = LIB.GetPureText(szMsg)
	end
	local nLFC, nTime, nTick = GetLogicFrameCount(), GetCurrentTime(), GetTime()
	D.InsertEverything(
		Data, nLFC, nTime, nTick,
		EVERYTHING_TYPE.SYS_MSG, szMsg:gsub('\r', '')
	)
end)
-- ��ɫ������־
LIB.RegisterEvent('PLAYER_SAY', function()
	if not O.bEnable then
		return
	end
	if not IsPlayer(arg1) then
		local szText = LIB.GetPureText(arg0)
		if szText and szText ~= '' then
			local npc = GetNpc(arg1)
			local nLFC, nTime, nTick = GetLogicFrameCount(), GetCurrentTime(), GetTime()
			D.InsertEverything(
				Data, nLFC, nTime, nTick,
				EVERYTHING_TYPE.PLAYER_SAY,
				-- szContent, dwNpcID, szNpcName, dwNpcTemplateID
				szText, arg1, arg3 == '' and '%' or arg3, npc and npc.dwTemplateID or 0
			)
		end
	end
end)
-- ϵͳ�������־
LIB.RegisterEvent('ON_WARNING_MESSAGE', function()
	if not O.bEnable then
		return
	end
	local nLFC, nTime, nTick = GetLogicFrameCount(), GetCurrentTime(), GetTime()
	D.InsertEverything(
		Data, nLFC, nTime, nTick,
		EVERYTHING_TYPE.WARNING_MESSAGE,
		-- szContent
		arg1
	)
end)
-- �����˳�ս����־
LIB.RegisterEvent({'MY_NPC_FIGHT_HINT', 'MY_PLAYER_FIGHT_HINT'}, function(e)
	if not O.bEnable then
		return
	end
	local nLFC, nTime, nTick = GetLogicFrameCount(), GetCurrentTime(), GetTime()
	local dwType = e == 'MY_NPC_FIGHT_HINT' and TARGET.NPC or TARGET.PLAYER
	local dwID, bFight, dwTemplateID = arg0, arg1, 0
	local KObject = LIB.GetObject(dwType, dwID)
	local szName = LIB.GetObjectName(KObject, 'never') or ''
	local nCurrentLife, nMaxLife, nCurrentMana, nMaxMana = 0, 0
	if KObject then
		nCurrentLife, nMaxLife = KObject.nCurrentLife, KObject.nMaxLife
		nCurrentMana, nMaxMana = KObject.nCurrentMana, KObject.nMaxMana
	end
	if dwType == TARGET.NPC or dwType == TARGET.DOODAD then
		if KObject then
			dwTemplateID = KObject.dwTemplateID
		end
	elseif dwType == TARGET.PLAYER then
		if not LIB.IsParty(dwID) then
			return
		end
		D.SavePlayerInfo(Data, dwID, true)
	end
	D.InsertEverything(
		Data, nLFC, nTime, nTick,
		EVERYTHING_TYPE.FIGHT_HINT,
		dwType, dwID, bFight,
		szName, dwTemplateID,
		nCurrentLife, nMaxLife, nCurrentMana, nMaxMana
	)
end)
-- ������־
LIB.RegisterEvent('SYS_MSG', function()
	if not O.bEnable then
		return
	end
	if arg0 ~= 'UI_OME_DEATH_NOTIFY' then
		return
	end
	-- �������ݵ���־
	local nLFC, nTime, nTick = GetLogicFrameCount(), GetCurrentTime(), GetTime()
	local dwID, dwKiller = arg1, arg2
	if LIB.IsParty(dwID) or LIB.IsParty(dwKiller) then
		D.InsertEverything(
			Data, nLFC, nTime, nTick,
			EVERYTHING_TYPE.DEATH, dwID, dwKiller,
			LIB.GetObjectName(IsPlayer(dwID) and TARGET.PLAYER or TARGET.NPC, dwID),
			LIB.GetObjectName(IsPlayer(dwKiller) and TARGET.PLAYER or TARGET.NPC, dwKiller)
		)
	end
end)
-- ����������־
LIB.RegisterEvent('PARTY_SET_MEMBER_ONLINE_FLAG', function()
	if not O.bEnable then
		return
	end
	if LIB.IsParty(arg1) then
		local nLFC, nTime, nTick = GetLogicFrameCount(), GetCurrentTime(), GetTime()
		D.InsertEverything(
			Data, nLFC, nTime, nTick,
			EVERYTHING_TYPE.ONLINE, arg1, arg2,
			LIB.GetObjectName(TARGET.PLAYER, arg1)
		)
	end
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
-- ����ս�������¼
LIB.RegisterEvent('MY_RECOUNT_NEW_FIGHT', function() -- ��սɨ����� ��¼��ս������/���ߵ���
	if not O.bEnable then
		return
	end
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
-- ��;���˽��� ���������¼
LIB.RegisterEvent('PARTY_ADD_MEMBER', function()
	if not O.bEnable then
		return
	end
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

LIB.RegisterFlush('MY_Recount_DS', function()
	D.SaveData()
	if O.bSaveHistoryOnExit then
		D.SaveHistory()
	end
end)

-- ͬ��Ŀ�����ݺϲ�
do local tDstDetail, id, tDstSkill, tDstSkillDetail, tDstSkillTarget, tDstTarget, tDstTargetDetail, tDstTargetSkill
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
		tDstDetail = tDst[DK_REC_STAT.DETAIL][nType]
		if not tDstDetail then
			tDstDetail = {
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
			tDst[DK_REC_STAT.DETAIL][nType] = tDstDetail
		end
		tDstDetail[DK_REC_STAT_DETAIL.COUNT        ] = tDstDetail[DK_REC_STAT_DETAIL.COUNT] + tSrcDetail[DK_REC_STAT_DETAIL.COUNT]
		tDstDetail[DK_REC_STAT_DETAIL.NZ_COUNT     ] = tDstDetail[DK_REC_STAT_DETAIL.NZ_COUNT] + tSrcDetail[DK_REC_STAT_DETAIL.NZ_COUNT]
		tDstDetail[DK_REC_STAT_DETAIL.MAX          ] = max(tDstDetail[DK_REC_STAT_DETAIL.MAX], tSrcDetail[DK_REC_STAT_DETAIL.MAX])
		tDstDetail[DK_REC_STAT_DETAIL.MAX_EFFECT   ] = max(tDstDetail[DK_REC_STAT_DETAIL.MAX_EFFECT], tSrcDetail[DK_REC_STAT_DETAIL.MAX_EFFECT])
		tDstDetail[DK_REC_STAT_DETAIL.MIN          ] = Min(tDstDetail[DK_REC_STAT_DETAIL.MIN], tSrcDetail[DK_REC_STAT_DETAIL.MIN])
		tDstDetail[DK_REC_STAT_DETAIL.NZ_MIN       ] = Min(tDstDetail[DK_REC_STAT_DETAIL.NZ_MIN], tSrcDetail[DK_REC_STAT_DETAIL.NZ_MIN])
		tDstDetail[DK_REC_STAT_DETAIL.MIN_EFFECT   ] = Min(tDstDetail[DK_REC_STAT_DETAIL.MIN_EFFECT], tSrcDetail[DK_REC_STAT_DETAIL.MIN_EFFECT])
		tDstDetail[DK_REC_STAT_DETAIL.NZ_MIN_EFFECT] = Min(tDstDetail[DK_REC_STAT_DETAIL.NZ_MIN_EFFECT], tSrcDetail[DK_REC_STAT_DETAIL.NZ_MIN_EFFECT])
		tDstDetail[DK_REC_STAT_DETAIL.TOTAL        ] = tDstDetail[DK_REC_STAT_DETAIL.TOTAL] + tSrcDetail[DK_REC_STAT_DETAIL.TOTAL]
		tDstDetail[DK_REC_STAT_DETAIL.TOTAL_EFFECT ] = tDstDetail[DK_REC_STAT_DETAIL.TOTAL_EFFECT] + tSrcDetail[DK_REC_STAT_DETAIL.TOTAL_EFFECT]
		tDstDetail[DK_REC_STAT_DETAIL.AVG          ] = floor(tDstDetail[DK_REC_STAT_DETAIL.TOTAL] / tDstDetail[DK_REC_STAT_DETAIL.COUNT])
		tDstDetail[DK_REC_STAT_DETAIL.NZ_AVG       ] = floor(tDstDetail[DK_REC_STAT_DETAIL.TOTAL] / tDstDetail[DK_REC_STAT_DETAIL.NZ_COUNT])
		tDstDetail[DK_REC_STAT_DETAIL.AVG_EFFECT   ] = floor(tDstDetail[DK_REC_STAT_DETAIL.TOTAL_EFFECT] / tDstDetail[DK_REC_STAT_DETAIL.COUNT])
		tDstDetail[DK_REC_STAT_DETAIL.NZ_AVG_EFFECT] = floor(tDstDetail[DK_REC_STAT_DETAIL.TOTAL_EFFECT] / tDstDetail[DK_REC_STAT_DETAIL.NZ_COUNT])
	end
	------------------------
	-- # �ڣ� tRecord.Skill
	------------------------
	-- �ϲ�����ͳ�ƣ������ֻء����ǻ���...��
	for szEffectID, tSrcSkill in pairs(tSrc[DK_REC_STAT.SKILL]) do
		if not bHideAnonymous or not select(2, D.GetEffectInfoAusID(data, szEffectID)) then
			id = bMergeEffect
				and D.GetEffectNameAusID(data, szChannel, szEffectID)
				or szEffectID
			tDstSkill = tDst[DK_REC_STAT.SKILL][id]
			if not tDstSkill then
				tDstSkill = {
					tEffectID = {},
					[DK_REC_STAT_SKILL.COUNT        ] =  0, -- ����������ֻ��ͷŴ���������szEffectName�������ֻأ�
					[DK_REC_STAT_SKILL.NZ_COUNT     ] =  0, -- ����ҷ���ֵ�����ֻ��ͷŴ���
					[DK_REC_STAT_SKILL.MAX          ] =  0, -- ����������ֻ���������
					[DK_REC_STAT_SKILL.MAX_EFFECT   ] =  0, -- ����������ֻ������Ч�����
					[DK_REC_STAT_SKILL.TOTAL        ] =  0, -- ����������ֻ�������ܺ�
					[DK_REC_STAT_SKILL.TOTAL_EFFECT ] =  0, -- ����������ֻ���Ч������ܺ�
					[DK_REC_STAT_SKILL.AVG          ] =  0, -- ��������������ֻ�ƽ���˺�
					[DK_REC_STAT_SKILL.NZ_AVG       ] =  0, -- ��������з���ֵ�����ֻ�ƽ���˺�
					[DK_REC_STAT_SKILL.AVG_EFFECT   ] =  0, -- ��������������ֻ�ƽ����Ч�˺�
					[DK_REC_STAT_SKILL.NZ_AVG_EFFECT] =  0, -- ��������з���ֵ�����ֻ�ƽ����Ч�˺�
					[DK_REC_STAT_SKILL.DETAIL       ] = {}, -- ����������ֻ�����������ͳ��
					[DK_REC_STAT_SKILL.TARGET       ] = {}, -- ����������ֻس�����ͳ��
				}
				tDst[DK_REC_STAT.SKILL][id] = tDstSkill
			end
			tDstSkill.tEffectID[szEffectID] = true
			tDstSkill[DK_REC_STAT_SKILL.COUNT        ] = tDstSkill[DK_REC_STAT_SKILL.COUNT] + tSrcSkill[DK_REC_STAT_SKILL.COUNT]
			tDstSkill[DK_REC_STAT_SKILL.NZ_COUNT     ] = tDstSkill[DK_REC_STAT_SKILL.NZ_COUNT] + tSrcSkill[DK_REC_STAT_SKILL.NZ_COUNT]
			tDstSkill[DK_REC_STAT_SKILL.MAX          ] = max(tDstSkill[DK_REC_STAT_SKILL.MAX], tSrcSkill[DK_REC_STAT_SKILL.MAX])
			tDstSkill[DK_REC_STAT_SKILL.MAX_EFFECT   ] = max(tDstSkill[DK_REC_STAT_SKILL.MAX_EFFECT], tSrcSkill[DK_REC_STAT_SKILL.MAX_EFFECT])
			tDstSkill[DK_REC_STAT_SKILL.TOTAL        ] = tDstSkill[DK_REC_STAT_SKILL.TOTAL] + tSrcSkill[DK_REC_STAT_SKILL.TOTAL]
			tDstSkill[DK_REC_STAT_SKILL.TOTAL_EFFECT ] = tDstSkill[DK_REC_STAT_SKILL.TOTAL_EFFECT] + tSrcSkill[DK_REC_STAT_SKILL.TOTAL_EFFECT]
			tDstSkill[DK_REC_STAT_SKILL.AVG          ] = floor(tDstSkill[DK_REC_STAT_SKILL.TOTAL] / tDstSkill[DK_REC_STAT_SKILL.COUNT])
			tDstSkill[DK_REC_STAT_SKILL.AVG_EFFECT   ] = floor(tDstSkill[DK_REC_STAT_SKILL.TOTAL_EFFECT] / tDstSkill[DK_REC_STAT_SKILL.COUNT])
			tDstSkill[DK_REC_STAT_SKILL.NZ_AVG       ] = floor(tDstSkill[DK_REC_STAT_SKILL.TOTAL] / tDstSkill[DK_REC_STAT_SKILL.NZ_COUNT])
			tDstSkill[DK_REC_STAT_SKILL.NZ_AVG_EFFECT] = floor(tDstSkill[DK_REC_STAT_SKILL.TOTAL_EFFECT] / tDstSkill[DK_REC_STAT_SKILL.NZ_COUNT])
			---------------------------------
			-- # �ڣ� tRecord.Skill[x].Detail
			---------------------------------
			-- �ϲ���������ͳ�ƣ������ֻص����С�����...��
			for nType, tSrcSkillDetail in pairs(tSrcSkill[DK_REC_STAT_SKILL.DETAIL]) do
				tDstSkillDetail = tDstSkill[DK_REC_STAT_SKILL.DETAIL][nType]
				if not tDstSkillDetail then
					tDstSkillDetail = {
						[DK_REC_STAT_SKILL_DETAIL.COUNT        ] =  0, -- ���м�¼����
						[DK_REC_STAT_SKILL_DETAIL.NZ_COUNT     ] =  0, -- ����ֵ���м�¼����
						[DK_REC_STAT_SKILL_DETAIL.MAX          ] =  0, -- �����������ֵ
						[DK_REC_STAT_SKILL_DETAIL.MAX_EFFECT   ] =  0, -- �������������Чֵ
						[DK_REC_STAT_SKILL_DETAIL.MIN          ] = -1, -- ����������Сֵ
						[DK_REC_STAT_SKILL_DETAIL.NZ_MIN       ] = -1, -- ���η���ֵ������Сֵ
						[DK_REC_STAT_SKILL_DETAIL.MIN_EFFECT   ] = -1, -- ����������С��Чֵ
						[DK_REC_STAT_SKILL_DETAIL.NZ_MIN_EFFECT] = -1, -- ���η���ֵ������С��Чֵ
						[DK_REC_STAT_SKILL_DETAIL.TOTAL        ] =  0, -- �����������˺�
						[DK_REC_STAT_SKILL_DETAIL.TOTAL_EFFECT ] =  0, -- ������������Ч�˺�
						[DK_REC_STAT_SKILL_DETAIL.AVG          ] =  0, -- ��������ƽ���˺�
						[DK_REC_STAT_SKILL_DETAIL.NZ_AVG       ] =  0, -- ���з���ֵ����ƽ���˺�
						[DK_REC_STAT_SKILL_DETAIL.AVG_EFFECT   ] =  0, -- ��������ƽ����Ч�˺�
						[DK_REC_STAT_SKILL_DETAIL.NZ_AVG_EFFECT] =  0, -- ���з���ֵ����ƽ����Ч�˺�
					}
					tDstSkill[DK_REC_STAT_SKILL.DETAIL][nType] = tDstSkillDetail
				end
				tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.COUNT        ] = tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.COUNT] + tSrcSkillDetail[DK_REC_STAT_SKILL_DETAIL.COUNT]
				tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.NZ_COUNT     ] = tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.NZ_COUNT] + tSrcSkillDetail[DK_REC_STAT_SKILL_DETAIL.NZ_COUNT]
				tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.MAX          ] = max(tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.MAX], tSrcSkillDetail[DK_REC_STAT_SKILL_DETAIL.MAX])
				tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.MAX_EFFECT   ] = max(tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.MAX_EFFECT], tSrcSkillDetail[DK_REC_STAT_SKILL_DETAIL.MAX_EFFECT])
				tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.MIN          ] = Min(tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.MIN], tSrcSkillDetail[DK_REC_STAT_SKILL_DETAIL.MIN])
				tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.NZ_MIN       ] = Min(tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.NZ_MIN], tSrcSkillDetail[DK_REC_STAT_SKILL_DETAIL.NZ_MIN])
				tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.MIN_EFFECT   ] = Min(tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.MIN_EFFECT], tSrcSkillDetail[DK_REC_STAT_SKILL_DETAIL.MIN_EFFECT])
				tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.NZ_MIN_EFFECT] = Min(tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.NZ_MIN_EFFECT], tSrcSkillDetail[DK_REC_STAT_SKILL_DETAIL.NZ_MIN_EFFECT])
				tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.TOTAL        ] = tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.TOTAL] + tSrcSkillDetail[DK_REC_STAT_SKILL_DETAIL.TOTAL]
				tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.TOTAL_EFFECT ] = tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.TOTAL_EFFECT] + tSrcSkillDetail[DK_REC_STAT_SKILL_DETAIL.TOTAL_EFFECT]
				tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.AVG          ] = floor(tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.TOTAL] / tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.COUNT])
				tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.NZ_AVG       ] = floor(tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.TOTAL] / tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.NZ_COUNT])
				tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.AVG_EFFECT   ] = floor(tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.TOTAL_EFFECT] / tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.COUNT])
				tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.NZ_AVG_EFFECT] = floor(tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.TOTAL_EFFECT] / tDstSkillDetail[DK_REC_STAT_SKILL_DETAIL.NZ_COUNT])
			end
			------------------------------
			-- # �ڣ� tRecord.Skill.Target
			------------------------------
			-- �ϲ�����Ŀ��ͳ�ƣ������ֻضԽ�������ľ׮����������ľ׮...��
			for dwID, tSrcSkillTarget in pairs(tSrcSkill[DK_REC_STAT_SKILL.TARGET]) do
				id = bMergeNpc and D.GetNameAusID(data, dwID) or dwID
				tDstSkillTarget = tDstSkill[DK_REC_STAT_SKILL.TARGET][id]
				if not tDstSkillTarget then
					tDstSkillTarget = {
						[DK_REC_STAT_SKILL_TARGET.MAX         ] = 0, -- ����������ֻػ��е�����������˺�
						[DK_REC_STAT_SKILL_TARGET.MAX_EFFECT  ] = 0, -- ����������ֻػ��е������������Ч�˺�
						[DK_REC_STAT_SKILL_TARGET.TOTAL       ] = 0, -- ����������ֻػ��е��������˺��ܺ�
						[DK_REC_STAT_SKILL_TARGET.TOTAL_EFFECT] = 0, -- ����������ֻػ��е���������Ч�˺��ܺ�
						[DK_REC_STAT_SKILL_TARGET.COUNT       ] = {}, -- ����������ֻػ��е������ҽ��ͳ��
						[DK_REC_STAT_SKILL_TARGET.NZ_COUNT    ] = {}, -- ����ҷ���ֵ�����ֻػ��е������ҽ��ͳ��
					}
					tDstSkill[DK_REC_STAT_SKILL.TARGET][id] = tDstSkillTarget
				end
				tDstSkillTarget[DK_REC_STAT_SKILL_TARGET.MAX         ] = tDstSkillTarget[DK_REC_STAT_SKILL_TARGET.MAX] + tSrcSkillTarget[DK_REC_STAT_SKILL_TARGET.MAX]
				tDstSkillTarget[DK_REC_STAT_SKILL_TARGET.MAX_EFFECT  ] = tDstSkillTarget[DK_REC_STAT_SKILL_TARGET.MAX_EFFECT] + tSrcSkillTarget[DK_REC_STAT_SKILL_TARGET.MAX_EFFECT]
				tDstSkillTarget[DK_REC_STAT_SKILL_TARGET.TOTAL       ] = tDstSkillTarget[DK_REC_STAT_SKILL_TARGET.TOTAL] + tSrcSkillTarget[DK_REC_STAT_SKILL_TARGET.TOTAL]
				tDstSkillTarget[DK_REC_STAT_SKILL_TARGET.TOTAL_EFFECT] = tDstSkillTarget[DK_REC_STAT_SKILL_TARGET.TOTAL_EFFECT] + tSrcSkillTarget[DK_REC_STAT_SKILL_TARGET.TOTAL_EFFECT]
				for k, v in pairs(tSrcSkillTarget[DK_REC_STAT_SKILL_TARGET.COUNT]) do
					tDstSkillTarget[DK_REC_STAT_SKILL_TARGET.COUNT][k] = (tDstSkillTarget[DK_REC_STAT_SKILL_TARGET.COUNT][k] or 0) + v
				end
				for k, v in pairs(tSrcSkillTarget[DK_REC_STAT_SKILL_TARGET.NZ_COUNT]) do
					tDstSkillTarget[DK_REC_STAT_SKILL_TARGET.NZ_COUNT][k] = (tDstSkillTarget[DK_REC_STAT_SKILL_TARGET.NZ_COUNT][k] or 0) + v
				end
			end
		end
	end
	------------------------
	-- # �ڣ� tRecord.Target
	------------------------
	-- �ϲ�Ŀ��ͳ�ƣ���������ľ׮����������ľ׮...��
	for dwID, tSrcTarget in pairs(tSrc[DK_REC_STAT.TARGET]) do
		id = bMergeNpc and D.GetNameAusID(data, dwID) or dwID
		tDstTarget = tDst[DK_REC_STAT.TARGET][id]
		if not tDstTarget then
			tDstTarget = {
				[DK_REC_STAT_TARGET.COUNT        ] =  0, -- ����Ҷ�idTarget�ļ����ͷŴ���
				[DK_REC_STAT_TARGET.NZ_COUNT     ] =  0, -- ����Ҷ�idTarget�ķ���ֵ�����ͷŴ���
				[DK_REC_STAT_TARGET.MAX          ] =  0, -- ����Ҷ�idTarget�ļ�����������
				[DK_REC_STAT_TARGET.MAX_EFFECT   ] =  0, -- ����Ҷ�idTarget�ļ��������Ч�����
				[DK_REC_STAT_TARGET.TOTAL        ] =  0, -- ����Ҷ�idTarget�ļ���������ܺ�
				[DK_REC_STAT_TARGET.TOTAL_EFFECT ] =  0, -- ����Ҷ�idTarget�ļ�����Ч������ܺ�
				[DK_REC_STAT_TARGET.AVG          ] =  0, -- ����Ҷ�idTarget�ļ���ƽ�������
				[DK_REC_STAT_TARGET.NZ_AVG       ] =  0, -- ����Ҷ�idTarget�ķ���ֵ����ƽ�������
				[DK_REC_STAT_TARGET.AVG_EFFECT   ] =  0, -- ����Ҷ�idTarget�ļ���ƽ����Ч�����
				[DK_REC_STAT_TARGET.NZ_AVG_EFFECT] =  0, -- ����Ҷ�idTarget�ķ���ֵ����ƽ����Ч�����
				[DK_REC_STAT_TARGET.DETAIL       ] = {}, -- ����Ҷ�idTarget�ļ�������������ͳ��
				[DK_REC_STAT_TARGET.SKILL        ] = {}, -- ����Ҷ�idTarget�ļ��ܾ���ֱ�ͳ��
			}
			tDst[DK_REC_STAT.TARGET][id] = tDstTarget
		end
		tDstTarget[DK_REC_STAT_TARGET.COUNT        ] = tDstTarget[DK_REC_STAT_TARGET.COUNT] + tSrcTarget[DK_REC_STAT_TARGET.COUNT]
		tDstTarget[DK_REC_STAT_TARGET.NZ_COUNT     ] = tDstTarget[DK_REC_STAT_TARGET.NZ_COUNT] + tSrcTarget[DK_REC_STAT_TARGET.NZ_COUNT]
		tDstTarget[DK_REC_STAT_TARGET.MAX          ] = max(tDstTarget[DK_REC_STAT_TARGET.MAX], tSrcTarget[DK_REC_STAT_TARGET.MAX])
		tDstTarget[DK_REC_STAT_TARGET.MAX_EFFECT   ] = max(tDstTarget[DK_REC_STAT_TARGET.MAX_EFFECT], tSrcTarget[DK_REC_STAT_TARGET.MAX_EFFECT])
		tDstTarget[DK_REC_STAT_TARGET.TOTAL        ] = tDstTarget[DK_REC_STAT_TARGET.TOTAL] + tSrcTarget[DK_REC_STAT_TARGET.TOTAL]
		tDstTarget[DK_REC_STAT_TARGET.TOTAL_EFFECT ] = tDstTarget[DK_REC_STAT_TARGET.TOTAL_EFFECT] + tSrcTarget[DK_REC_STAT_TARGET.TOTAL_EFFECT]
		tDstTarget[DK_REC_STAT_TARGET.AVG          ] = floor(tDstTarget[DK_REC_STAT_TARGET.TOTAL] / tDstTarget[DK_REC_STAT_TARGET.COUNT])
		tDstTarget[DK_REC_STAT_TARGET.AVG_EFFECT   ] = floor(tDstTarget[DK_REC_STAT_TARGET.TOTAL_EFFECT] / tDstTarget[DK_REC_STAT_TARGET.COUNT])
		tDstTarget[DK_REC_STAT_TARGET.NZ_AVG       ] = floor(tDstTarget[DK_REC_STAT_TARGET.TOTAL] / tDstTarget[DK_REC_STAT_TARGET.NZ_COUNT])
		tDstTarget[DK_REC_STAT_TARGET.NZ_AVG_EFFECT] = floor(tDstTarget[DK_REC_STAT_TARGET.TOTAL_EFFECT] / tDstTarget[DK_REC_STAT_TARGET.NZ_COUNT])
		----------------------------------
		-- # �ڣ� tRecord.Target[x].Detail
		----------------------------------
		-- �ϲ�Ŀ�꼼������ͳ�ƣ������ֻص����С�����...��
		for nType, tSrcTargetDetail in pairs(tSrcTarget[DK_REC_STAT_TARGET.DETAIL]) do
			tDstTargetDetail = tDstTarget[DK_REC_STAT_TARGET.DETAIL][nType]
			if not tDstTargetDetail then
				tDstTargetDetail = {
					[DK_REC_STAT_TARGET_DETAIL.COUNT        ] =  0, -- ���м�¼����������nSkillResult�����У�
					[DK_REC_STAT_TARGET_DETAIL.NZ_COUNT     ] =  0, -- ����ֵ���м�¼����
					[DK_REC_STAT_TARGET_DETAIL.MAX          ] =  0, -- �����������ֵ
					[DK_REC_STAT_TARGET_DETAIL.MAX_EFFECT   ] =  0, -- �������������Чֵ
					[DK_REC_STAT_TARGET_DETAIL.MIN          ] = -1, -- ����������Сֵ
					[DK_REC_STAT_TARGET_DETAIL.NZ_MIN       ] = -1, -- ���η���ֵ������Сֵ
					[DK_REC_STAT_TARGET_DETAIL.MIN_EFFECT   ] = -1, -- ����������С��Чֵ
					[DK_REC_STAT_TARGET_DETAIL.NZ_MIN_EFFECT] = -1, -- ���η���ֵ������С��Чֵ
					[DK_REC_STAT_TARGET_DETAIL.TOTAL        ] =  0, -- �����������˺�
					[DK_REC_STAT_TARGET_DETAIL.TOTAL_EFFECT ] =  0, -- ������������Ч�˺�
					[DK_REC_STAT_TARGET_DETAIL.AVG          ] =  0, -- ��������ƽ���˺�
					[DK_REC_STAT_TARGET_DETAIL.NZ_AVG       ] =  0, -- ���з���ֵ����ƽ���˺�
					[DK_REC_STAT_TARGET_DETAIL.AVG_EFFECT   ] =  0, -- ��������ƽ����Ч�˺�
					[DK_REC_STAT_TARGET_DETAIL.NZ_AVG_EFFECT] =  0, -- ���з���ֵ����ƽ����Ч�˺�
				}
				tDstTarget[DK_REC_STAT_TARGET.DETAIL][nType] = tDstTargetDetail
			end
			tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.COUNT        ] = tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.COUNT] + tSrcTargetDetail[DK_REC_STAT_TARGET_DETAIL.COUNT]
			tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.NZ_COUNT     ] = tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.NZ_COUNT] + tSrcTargetDetail[DK_REC_STAT_TARGET_DETAIL.NZ_COUNT]
			tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.MAX          ] = max(tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.MAX], tSrcTargetDetail[DK_REC_STAT_TARGET_DETAIL.MAX])
			tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.MAX_EFFECT   ] = max(tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.MAX_EFFECT], tSrcTargetDetail[DK_REC_STAT_TARGET_DETAIL.MAX_EFFECT])
			tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.MIN          ] = Min(tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.MIN], tSrcTargetDetail[DK_REC_STAT_TARGET_DETAIL.MIN])
			tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.NZ_MIN       ] = Min(tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.NZ_MIN], tSrcTargetDetail[DK_REC_STAT_TARGET_DETAIL.NZ_MIN])
			tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.MIN_EFFECT   ] = Min(tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.MIN_EFFECT], tSrcTargetDetail[DK_REC_STAT_TARGET_DETAIL.MIN_EFFECT])
			tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.NZ_MIN_EFFECT] = Min(tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.NZ_MIN_EFFECT], tSrcTargetDetail[DK_REC_STAT_TARGET_DETAIL.NZ_MIN_EFFECT])
			tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.TOTAL        ] = tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.TOTAL] + tSrcTargetDetail[DK_REC_STAT_TARGET_DETAIL.TOTAL]
			tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.TOTAL_EFFECT ] = tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.TOTAL_EFFECT] + tSrcTargetDetail[DK_REC_STAT_TARGET_DETAIL.TOTAL_EFFECT]
			tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.AVG          ] = floor(tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.TOTAL] / tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.COUNT])
			tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.NZ_AVG       ] = floor(tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.TOTAL] / tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.NZ_COUNT])
			tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.AVG_EFFECT   ] = floor(tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.TOTAL_EFFECT] / tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.COUNT])
			tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.NZ_AVG_EFFECT] = floor(tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.TOTAL_EFFECT] / tDstTargetDetail[DK_REC_STAT_TARGET_DETAIL.NZ_COUNT])
		end
		---------------------------------
		-- # �ڣ� tRecord.Target[x].Skill
		---------------------------------
		-- �ϲ�Ŀ�꼼��ͳ�ƣ���������ľ׮�������ֻء����ǻ���...��
		for szEffectID, tSrcTargetSkill in pairs(tSrcTarget[DK_REC_STAT_TARGET.SKILL]) do
			if not bHideAnonymous or not select(2, D.GetEffectInfoAusID(data, szEffectID)) then
				id = bMergeEffect
					and D.GetEffectNameAusID(data, szChannel, szEffectID)
					or szEffectID
				tDstTargetSkill = tDstTarget[DK_REC_STAT_TARGET.SKILL][id]
				if not tDstTargetSkill then
					tDstTargetSkill = {
						tEffectID = {},
						[DK_REC_STAT_TARGET_SKILL.MAX         ] = 0, -- ����һ��������ҵ������ֻ�����˺�
						[DK_REC_STAT_TARGET_SKILL.MAX_EFFECT  ] = 0, -- ����һ��������ҵ������ֻ������Ч�˺�
						[DK_REC_STAT_TARGET_SKILL.TOTAL       ] = 0, -- ����һ��������ҵ������ֻ��˺��ܺ�
						[DK_REC_STAT_TARGET_SKILL.TOTAL_EFFECT] = 0, -- ����һ��������ҵ������ֻ���Ч�˺��ܺ�
						[DK_REC_STAT_TARGET_SKILL.COUNT       ] = {}, -- ����һ��������ҵ������ֻؽ��ͳ��
						[DK_REC_STAT_TARGET_SKILL.NZ_COUNT    ] = {}, -- ����ҷ���ֵ���������ҵ������ֻؽ��ͳ��
					}
					tDstTarget[DK_REC_STAT_TARGET.SKILL][id] = tDstTargetSkill
				end
				tDstTargetSkill.tEffectID[szEffectID] = true
				tDstTargetSkill[DK_REC_STAT_TARGET_SKILL.MAX         ] = max(tDstTargetSkill[DK_REC_STAT_TARGET_SKILL.MAX], tSrcTargetSkill[DK_REC_STAT_TARGET_SKILL.MAX])
				tDstTargetSkill[DK_REC_STAT_TARGET_SKILL.MAX_EFFECT  ] = max(tDstTargetSkill[DK_REC_STAT_TARGET_SKILL.MAX_EFFECT], tSrcTargetSkill[DK_REC_STAT_TARGET_SKILL.MAX_EFFECT])
				tDstTargetSkill[DK_REC_STAT_TARGET_SKILL.TOTAL       ] = tDstTargetSkill[DK_REC_STAT_TARGET_SKILL.TOTAL] + tSrcTargetSkill[DK_REC_STAT_TARGET_SKILL.TOTAL]
				tDstTargetSkill[DK_REC_STAT_TARGET_SKILL.TOTAL_EFFECT] = tDstTargetSkill[DK_REC_STAT_TARGET_SKILL.TOTAL_EFFECT] + tSrcTargetSkill[DK_REC_STAT_TARGET_SKILL.TOTAL_EFFECT]
				for k, v in pairs(tSrcTargetSkill[DK_REC_STAT_TARGET_SKILL.COUNT]) do
					tDstTargetSkill[DK_REC_STAT_TARGET_SKILL.COUNT][k] = (tDstTargetSkill[DK_REC_STAT_TARGET_SKILL.COUNT][k] or 0) + v
				end
				for k, v in pairs(tSrcTargetSkill[DK_REC_STAT_TARGET_SKILL.NZ_COUNT]) do
					tDstTargetSkill[DK_REC_STAT_TARGET_SKILL.NZ_COUNT][k] = (tDstTargetSkill[DK_REC_STAT_TARGET_SKILL.NZ_COUNT][k] or 0) + v
				end
			end
		end
	end
end
end

do local tData
function D.GetMergeTargetData(data, szChannel, id, bMergeNpc, bMergeEffect, bHideAnonymous)
	if not bMergeNpc and not bMergeEffect and not bHideAnonymous then
		return data[szChannel][DK_REC.STAT][id]
	end
	tData = nil
	for dwID, tSrcData in pairs(data[szChannel][DK_REC.STAT]) do
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
end

-- Global exports
do
local settings = {
	exports = {
		{
			fields = {
				GetHistoryFiles = D.GetHistoryFiles,
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
				SKILL_RESULT = SKILL_RESULT,
				SKILL_RESULT_NAME = SKILL_RESULT_NAME,
				EVERYTHING_TYPE = EVERYTHING_TYPE,
				DK = DK,
				DK_REC = DK_REC,
				DK_REC_STAT = DK_REC_STAT,
				DK_REC_STAT_DETAIL = DK_REC_STAT_DETAIL,
				DK_REC_STAT_SKILL = DK_REC_STAT_SKILL,
				DK_REC_STAT_SKILL_DETAIL = DK_REC_STAT_SKILL_DETAIL,
				DK_REC_STAT_SKILL_TARGET = DK_REC_STAT_SKILL_TARGET,
				DK_REC_STAT_TARGET = DK_REC_STAT_TARGET,
				DK_REC_STAT_TARGET_DETAIL = DK_REC_STAT_TARGET_DETAIL,
				DK_REC_STAT_TARGET_SKILL = DK_REC_STAT_TARGET_SKILL,
			},
		},
		{
			fields = {
				bEnable            = true,
				bSaveHistoryOnExit = true,
				bSaveHistoryOnExFi = true,
				nMaxHistory        = true,
				nMinFightTime      = true,
				bRecEverything     = true,
				bSaveEverything    = true,
			},
			root = O,
		},
	},
	imports = {
		{
			fields = {
				bEnable            = true,
				bSaveHistoryOnExit = true,
				bSaveHistoryOnExFi = true,
				nMaxHistory        = true,
				nMinFightTime      = true,
				bRecEverything     = true,
				bSaveEverything    = true,
			},
			triggers = {
				bEnable = function()
					D.SaveData()
					MY_Recount_UI.CheckOpen()
				end,
				bSaveHistoryOnExit = D.SaveData,
				bSaveHistoryOnExFi = D.SaveData,
				nMaxHistory        = D.SaveData,
				nMinFightTime      = D.SaveData,
				bRecEverything     = D.SaveData,
				bSaveEverything    = D.SaveData,
			},
			root = O,
		},
	},
}
MY_Recount_DS = LIB.GeneGlobalNS(settings)
end
