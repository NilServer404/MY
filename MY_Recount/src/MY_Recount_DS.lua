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
	UUID = ս��ͳһ��ʾ��,
	nVersion = ���ݰ汾��,
	nTimeBegin  = ս����ʼUNIXʱ���,
	nTimeDuring = ս����������,
	bDistinctEffectID = �������Ƿ����Ч��ID����ͬ����¼,
	Awaytime = {
		��ҵ�dwID = {
			{ ���뿪ʼʱ��, �������ʱ�� }, ...
		}, ...
	},
	Damage = {                                                -- ���ͳ��
		nTimeDuring = ���һ�μ�¼ʱ�뿪ʼ������,
		nTotal = ȫ�ӵ������,
		nTotalEffect = ȫ�ӵ���Ч�����,
		Snapshots = {
			{
				nTimeDuring  = ��ǰ����ս������,
				nTotal       = ��ǰ����ʱ��ȫ�������,
				nTotalEffect = ��ǰ����ʱ��ȫ����Ч�����,
				Statistics   = {
					��ҵ�dwID = {
						nTotal       = ��ǰ����ʱ�������������,
						nTotalEffect = ��ǰ����ʱ����������Ч�����,
					},
					NPC������ = { ... },
				},
			}, ...
		},
		Statistics = {
			��ҵ�dwID = {                                        -- �ö�������ͳ��
				nTotal       = 2314214,                           -- �����
				nTotalEffect = 132144 ,                           -- ��Ч���
				Detail = {                                        -- ����������ͳ��
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
				Skill = {                                         -- ����Ҿ����������ļ���ͳ��
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
				},
			},
			NPC������ = { ... },
		},
	},
	Heal = { ... },
	BeHeal = { ... },
	BeDamage = { ... },
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
	bRecAnonymous     = true,
	bDistinctEffectID = false,
	bRecEverything    = true,
}
local Data          -- ��ǰս�����ݼ�¼
local History = {}  -- ��ʷս����¼
local SZ_REC_FILE = {'cache/fight_recount_log.jx3dat', PATH_TYPE.ROLE}

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
				if History[i].nVersion ~= VERSION then
					remove(History, i)
				end
			end
		end
		O.bSaveHistory      = data.bSaveHistory or false
		O.nMaxHistory       = data.nMaxHistory   or 10
		O.nMinFightTime     = data.nMinFightTime or 30
		O.bRecAnonymous     = LIB.FormatDataStructure(data.bRecAnonymous, true)
		O.bDistinctEffectID = LIB.FormatDataStructure(data.bDistinctEffectID, false)
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
		bRecAnonymous     = O.bRecAnonymous,
		bDistinctEffectID = O.bDistinctEffectID,
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
	if arg0 and LIB.GetFightUUID() ~= Data.UUID then -- �����µ�ս��
		D.Init()
		FireUIEvent('MY_RECOUNT_NEW_FIGHT')
	else
		D.Flush()
	end
	D.InsertEverything(Data, 'FIGHT_TIME', LIB.IsFighting(), LIB.GetFightUUID(), LIB.GetFightTime())
end)
LIB.BreatheCall('MY_Recount_FightTime', 1000, function()
	if LIB.IsFighting() then
		Data.nTimeDuring = GetCurrentTime() - Data.nTimeBegin
		for _, szRecordType in ipairs({'Damage', 'Heal', 'BeDamage', 'BeHeal'}) do
			local tInfo = Data[szRecordType]
			local tSnapshot = {
				nTimeDuring  = Data.nTimeDuring,
				nTotal       = tInfo.nTotal,
				nTotalEffect = tInfo.nTotalEffect,
				Statistics   = {},
			}
			for k, v in pairs(tInfo.Statistics) do
				tSnapshot.Statistics[k] = {
					nTotal = v.nTotal,
					nTotalEffect = v.nTotalEffect,
				}
			end
			insert(Data[szRecordType].Snapshots, tSnapshot)
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
--               ö����ʱ�� Heal Damage BeDamage BeHeal ����
function D.GeneAwayTime(data, dwID, szRecordType)
	local nFightTime = D.GeneFightTime(data, dwID, szRecordType)
	local nAwayTime
	if szRecordType and data[szRecordType] and data[szRecordType].nTimeDuring then
		nAwayTime = data[szRecordType].nTimeDuring - nFightTime
	else
		nAwayTime = data.nTimeDuring - nFightTime
	end
	return max(nAwayTime, 0)
end

-- ����ս��ʱ��
-- D.GeneFightTime(data, dwID, szRecordType)
-- data: ����
-- dwID: ����ս��ʱ��Ľ�ɫID Ϊ��������Ŷӵ�ս��ʱ��
-- szRecordType: ��ͬ���͵������ڹٷ�ʱ���㷨�¼��������ܲ�һ��
--               ö����ʱ�� Heal Damage BeDamage BeHeal ����
function D.GeneFightTime(data, dwID, szRecordType)
	local nTimeDuring = data.nTimeDuring
	local nTimeBegin  = data.nTimeBegin
	if szRecordType and data[szRecordType] and data[szRecordType].nTimeDuring then
		nTimeDuring = data[szRecordType].nTimeDuring
	end
	if dwID and data.Awaytime and data.Awaytime[dwID] then
		for _, rec in ipairs(data.Awaytime[dwID]) do
			local nAwayBegin = max(rec[1], nTimeBegin)
			local nAwayEnd   = rec[2]
			if nAwayEnd then -- �������뿪��¼
				nTimeDuring = nTimeDuring - (nAwayEnd - nAwayBegin)
			else -- �뿪������û�����ļ�¼
				nTimeDuring = nTimeDuring - (data.nTimeBegin + nTimeDuring - nAwayBegin)
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

	-- ��ȡЧ������
	local szEffectName, bAnonymous
	if nEffectType == SKILL_EFFECT_TYPE.SKILL then
		szEffectName = Table_GetSkillName(dwEffectID, dwEffectLevel)
	elseif nEffectType == SKILL_EFFECT_TYPE.BUFF then
		szEffectName = Table_GetBuffName(dwEffectID, dwEffectLevel)
	end
	if not szEffectName then
		bAnonymous = true
		szEffectName = '#' .. dwEffectID
	elseif Data.bDistinctEffectID then
		szEffectName = szEffectName .. '#' .. dwEffectID
	end
	local szDamageEffectName, szHealEffectName = szEffectName, szEffectName
	if nEffectType == SKILL_EFFECT_TYPE.BUFF then
		szHealEffectName = szHealEffectName .. '(HOT)'
		szDamageEffectName = szDamageEffectName .. '(DOT)'
	end

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
		nEffectType, dwEffectID, dwEffectLevel, szEffectName,
		nSkillResult, nTherapy, nEffectTherapy, nDamage, nEffectDamage,
		tResult)

	if bAnonymous and not O.bRecAnonymous then
		return
	end

	-- ʶ��
	local nValue = tResult[SKILL_RESULT_TYPE.INSIGHT_DAMAGE]
	if nValue and nValue > 0 then
		D.AddDamageRecord(Data, dwCaster, dwTarget, szDamageEffectName, nDamage, nEffectDamage, SKILL_RESULT.INSIGHT)
	elseif nSkillResult == SKILL_RESULT.HIT -- ����
		or nSkillResult == SKILL_RESULT.CRITICAL -- ����
	then
		if nTherapy > 0 then -- ������
			D.AddHealRecord(Data, dwCaster, dwTarget, szHealEffectName, nTherapy, nEffectTherapy, nSkillResult)
		end
		if nDamage > 0 or nTherapy == 0 then -- ���˺� ���� ���˺������Ƶ�Ч��
			D.AddDamageRecord(Data, dwCaster, dwTarget, szDamageEffectName, nDamage, nEffectDamage, nSkillResult)
		end
	elseif nSkillResult == SKILL_RESULT.BLOCK  -- ��
		or nSkillResult == SKILL_RESULT.SHIELD -- ��Ч
		or nSkillResult == SKILL_RESULT.MISS   -- ƫ��
		or nSkillResult == SKILL_RESULT.DODGE  -- ����
	then
		D.AddDamageRecord(Data, dwCaster, dwTarget, szDamageEffectName, 0, 0, nSkillResult)
	end

	Data.nTimeDuring = GetCurrentTime() - Data.nTimeBegin
	Data.nTickDuring = GetTime() - Data.nTickBegin
end

-- ͨ��ID��������
function D.GetNameAusID(data, dwID)
	if not data or not dwID then
		return
	end
	return data.Namelist[dwID] or g_tStrings.STR_NAME_UNKNOWN
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
	insert(data.Everything, {GetLogicFrameCount(), GetCurrentTime(), GetTime(), szName, ...})
end

-- ��һ����¼��������
function D.InsertRecord(data, szRecordType, idRecord, idTarget, szEffectName, nValue, nEffectValue, nSkillResult)
	local tInfo   = data[szRecordType]
	local tRecord = tInfo.Statistics[idRecord]
	if not szEffectName or szEffectName == '' then
		return
	end
	------------------------
	-- # �ڣ� tInfo
	------------------------
	tInfo.nTimeDuring = GetCurrentTime() - data.nTimeBegin
	tInfo.nTotal        = tInfo.nTotal + nValue
	tInfo.nTotalEffect  = tInfo.nTotalEffect + nEffectValue
	------------------------
	-- # �ڣ� tRecord
	------------------------
	tRecord.nTotal        = tRecord.nTotal + nValue
	tRecord.nTotalEffect  = tRecord.nTotalEffect + nEffectValue
	------------------------
	-- # �ڣ� tRecord.Detail
	------------------------
	-- ���/���½������ͳ��
	if not tRecord.Detail[nSkillResult] then
		tRecord.Detail[nSkillResult] = {
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
	local tResult = tRecord.Detail[nSkillResult]
	tResult.nCount       = tResult.nCount + 1                                -- ���д���������nSkillResult�����У�
	tResult.nMax         = max(tResult.nMax, nValue)                    -- �����������ֵ
	tResult.nMaxEffect   = max(tResult.nMaxEffect, nEffectValue)        -- �������������Чֵ
	tResult.nMin         = (tResult.nMin ~= -1 and min(tResult.nMin, nValue)) or nValue                         -- ����������Сֵ
	tResult.nMinEffect   = (tResult.nMinEffect ~= -1 and min(tResult.nMinEffect, nEffectValue)) or nEffectValue -- ����������С��Чֵ
	tResult.nTotal       = tResult.nTotal + nValue                           -- �����������˺�
	tResult.nTotalEffect = tResult.nTotalEffect + nEffectValue               -- ������������Ч�˺�
	tResult.nAvg         = floor(tResult.nTotal / tResult.nCount)       -- ��������ƽ��ֵ
	tResult.nAvgEffect   = floor(tResult.nTotalEffect / tResult.nCount) -- ��������ƽ����Чֵ
	if nValue ~= 0 or NZ_SKILL_RESULT[nSkillResult] then
		tResult.nNzCount     = tResult.nNzCount + 1                           -- ���д���������nSkillResult�����У�
		tResult.nNzMin       = (tResult.nNzMin ~= -1 and min(tResult.nNzMin, nValue)) or nValue                         -- ����������Сֵ
		tResult.nNzMinEffect = (tResult.nNzMinEffect ~= -1 and min(tResult.nNzMinEffect, nEffectValue)) or nEffectValue -- ����������С��Чֵ
		tResult.nNzAvg       = floor(tResult.nTotal / tResult.nNzCount)       -- ��������ƽ��ֵ
		tResult.nNzAvgEffect = floor(tResult.nTotalEffect / tResult.nNzCount) -- ��������ƽ����Чֵ
	end

	------------------------
	-- # �ڣ� tRecord.Skill
	------------------------
	-- ��Ӿ��弼�ܼ�¼
	if not tRecord.Skill[szEffectName] then
		tRecord.Skill[szEffectName] = {
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
	local tSkillRecord = tRecord.Skill[szEffectName]
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
	if not tRecord.Target[idTarget] then
		tRecord.Target[idTarget] = {
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
	local tTargetRecord = tRecord.Target[idTarget]
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
function D.AddDamageRecord(data, dwCaster, dwTarget, szEffectName, nDamage, nEffectDamage, nSkillResult)
	-- ����˺���¼
	D.InitObjectData(data, dwCaster, 'Damage')
	D.InsertRecord(data, 'Damage'  , dwCaster, dwTarget, szEffectName, nDamage, nEffectDamage, nSkillResult)
	-- ��ӳ��˼�¼
	D.InitObjectData(data, dwTarget, 'BeDamage')
	D.InsertRecord(data, 'BeDamage', dwTarget, dwCaster, szEffectName, nDamage, nEffectDamage, nSkillResult)
end

-- ����һ�����Ƽ�¼
function D.AddHealRecord(data, dwCaster, dwTarget, szEffectName, nHeal, nEffectHeal, nSkillResult)
	-- ����˺���¼
	D.InitObjectData(data, dwCaster, 'Heal')
	D.InsertRecord(data, 'Heal'    , dwCaster, dwTarget, szEffectName, nHeal, nEffectHeal, nSkillResult)
	-- ��ӳ��˼�¼
	D.InitObjectData(data, dwTarget, 'BeHeal')
	D.InsertRecord(data, 'BeHeal'  , dwTarget, dwCaster, szEffectName, nHeal, nEffectHeal, nSkillResult)
end

-- ȷ�϶��������Ѵ�����δ�����򴴽���
function D.InitObjectData(data, dwID, szChannel)
	-- ���ƻ���
	if not data.Namelist[dwID] then
		data.Namelist[dwID] = LIB.GetObjectName(IsPlayer(dwID) and TARGET.PLAYER or TARGET.NPC, dwID, 'never') -- ���ƻ���
	end
	-- ��������
	if not data.Forcelist[dwID] then
		if IsPlayer(dwID) then
			local player = GetPlayer(dwID)
			if player then
				data.Forcelist[dwID] = player.dwForceID or 0
			end
		else
			data.Forcelist[dwID] = 0
		end
	end
	-- ͳ�ƽṹ��
	if not data[szChannel].Statistics[dwID] then
		data[szChannel].Statistics[dwID] = {
			szMD5        = dwID, -- Ψһ��ʶ
			nTotal       = 0   , -- �����
			nTotalEffect = 0   , -- ��Ч���
			Detail       = {}  , -- �����������ܽ������ͳ��
			Skill        = {}  , -- ����Ҿ����������ļ���ͳ��
			Target       = {}  , -- ����Ҿ����˭��������ͳ��
		}
	end
end

-- ��ʼ��Data
do
local function GeneTypeNS()
	return {
		nTimeDuring  = 0,
		nTotal       = 0,
		nTotalEffect = 0,
		Snapshots    = {},
		Statistics   = {},
	}
end
function D.Init(bForceInit)
	if bForceInit or (not Data) or
	(Data.UUID and LIB.GetFightUUID() ~= Data.UUID) then
		Data = {
			UUID              = LIB.GetFightUUID(),                 -- ս��Ψһ��ʶ
			nVersion          = VERSION,                           -- ���ݰ汾��
			bDistinctEffectID = O.bDistinctEffectID,               -- �Ƿ����ID����ͬ��Ч��
			nTimeBegin        = GetCurrentTime(),                  -- ս����ʼʱ��
			nTickBegin        = GetTime(),                         -- ս����ʼ����ʱ��
			nTimeDuring       =  0,                                -- ս������ʱ��
			nTickDuring       =  0,                                -- ս����������ʱ��
			Awaytime          = {},                                -- ����/����ʱ��ڵ�
			Namelist          = {},                                -- ���ƻ���
			Forcelist         = {},                                -- ��������
			Damage            = GeneTypeNS(),                      -- ���ͳ��
			Heal              = GeneTypeNS(),                      -- ����ͳ��
			BeHeal            = GeneTypeNS(),                      -- ����ͳ��
			BeDamage          = GeneTypeNS(),                      -- ����ͳ��
			Everything        = {},                                -- ս������
		}
	end

	if not Data.UUID and LIB.GetFightUUID() then
		Data.UUID       = LIB.GetFightUUID()
		Data.nTimeBegin = GetCurrentTime()
	end
end
end

-- Data����ѹ����ʷ��¼ �����³�ʼ��Data
function D.Flush()
	if not (Data and Data.UUID) then
		return
	end

	-- ���˿ռ�¼
	if IsEmpty(Data.BeDamage.Statistics)
	and IsEmpty(Data.Damage.Statistics)
	and IsEmpty(Data.Heal.Statistics)
	and IsEmpty(Data.BeHeal.Statistics) then
		return
	end

	-- ������������������Ϊս������
	local nMaxValue, szBossName = 0, nil
	local nEnemyMaxValue, szEnemyBossName = 0, nil
	for id, p in pairs(Data.BeDamage.Statistics) do
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
		for id, p in pairs(Data.Damage.Statistics) do
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

	if Data.nTimeDuring > O.nMinFightTime then
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
	if not (Data and Data.Awaytime) then
		return
	end
	-- ���һ���˵ļ�¼
	local rec = Data.Awaytime[dwID]
	if not rec then -- ��ʼ��һ����¼
		if not bLeave and not bAddWhenRecEmpty then
			return -- ����һ������Ŀ�ʼ���Ҳ�ǿ�Ƽ�¼������
		end
		rec = {}
		Data.Awaytime[dwID] = rec
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
			insert(rec, { Data.nTimeBegin, GetCurrentTime(), nAwayType })
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
				Flush = D.Flush,
			},
		},
		{
			fields = {
				bSaveHistory      = true,
				nMaxHistory       = true,
				nMinFightTime     = true,
				bRecAnonymous     = true,
				bDistinctEffectID = true,
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
				bRecAnonymous     = true,
				bDistinctEffectID = true,
				bRecEverything    = true,
			},
			triggers = {
				bSaveHistory      = D.SaveData,
				nMaxHistory       = D.SaveData,
				nMinFightTime     = D.SaveData,
				bRecAnonymous     = D.SaveData,
				bDistinctEffectID = D.SaveData,
				bRecEverything    = D.SaveData,
			},
			root = O,
		},
	},
}
MY_Recount_DS = LIB.GeneGlobalNS(settings)
end
