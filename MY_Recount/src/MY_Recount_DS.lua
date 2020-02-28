--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : 战斗统计 数据源
-- @author   : 茗伊 @双梦镇 @追风蹑影
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
[SKILL_RESULT_TYPE]枚举：
SKILL_RESULT_TYPE.PHYSICS_DAMAGE       = 0  -- 外功伤害
SKILL_RESULT_TYPE.SOLAR_MAGIC_DAMAGE   = 1  -- 阳性内功伤害
SKILL_RESULT_TYPE.NEUTRAL_MAGIC_DAMAGE = 2  -- 混元性内功伤害
SKILL_RESULT_TYPE.LUNAR_MAGIC_DAMAGE   = 3  -- 阴性内功伤害
SKILL_RESULT_TYPE.POISON_DAMAGE        = 4  -- 毒性伤害
SKILL_RESULT_TYPE.REFLECTIED_DAMAGE    = 5  -- 反弹伤害
SKILL_RESULT_TYPE.THERAPY              = 6  -- 治疗
SKILL_RESULT_TYPE.STEAL_LIFE           = 7  -- 生命偷取(<D0>从<D1>获得了<D2>点气血。)
SKILL_RESULT_TYPE.ABSORB_THERAPY       = 8  -- 化解治疗
SKILL_RESULT_TYPE.ABSORB_DAMAGE        = 9  -- 化解伤害
SKILL_RESULT_TYPE.SHIELD_DAMAGE        = 10 -- 无效伤害
SKILL_RESULT_TYPE.PARRY_DAMAGE         = 11 -- 拆招
SKILL_RESULT_TYPE.INSIGHT_DAMAGE       = 12 -- 识破
SKILL_RESULT_TYPE.EFFECTIVE_DAMAGE     = 13 -- 有效伤害
SKILL_RESULT_TYPE.EFFECTIVE_THERAPY    = 14 -- 有效治疗
SKILL_RESULT_TYPE.TRANSFER_LIFE        = 15 -- 吸取生命
SKILL_RESULT_TYPE.TRANSFER_MANA        = 16 -- 吸取内力

-- Data DataDisplay History[] 数据结构
Data = {
	UUID = 战斗统一标示符,
	nVersion = 数据版本号,
	nTimeBegin  = 战斗开始UNIX时间戳,
	nTimeDuring = 战斗持续秒数,
	bDistinctEffectID = 该数据是否根据效果ID区分同名记录,
	Awaytime = {
		玩家的dwID = {
			{ 暂离开始时间, 暂离结束时间 }, ...
		}, ...
	},
	Damage = {                                                -- 输出统计
		nTimeDuring = 最后一次记录时离开始的秒数,
		nTotal = 全队的输出量,
		nTotalEffect = 全队的有效输出量,
		Snapshots = {
			{
				nTimeDuring  = 当前快照战斗秒数,
				nTotal       = 当前快照时间全队输出量,
				nTotalEffect = 当前快照时间全队有效输出量,
				Statistics   = {
					玩家的dwID = {
						nTotal       = 当前快照时间该玩家总输出量,
						nTotalEffect = 当前快照时间该玩家总有效输出量,
					},
					NPC的名字 = { ... },
				},
			}, ...
		},
		Statistics = {
			玩家的dwID = {                                        -- 该对象的输出统计
				nTotal       = 2314214,                           -- 总输出
				nTotalEffect = 132144 ,                           -- 有效输出
				Detail = {                                        -- 输出结果分类统计
					SKILL_RESULT.HIT = {
						nCount       = 10    ,                    -- 命中记录数量
						nMax         = 34210 ,                    -- 单次命中最大值
						nMaxEffect   = 29817 ,                    -- 单次命中最大有效值
						nMin         = 8790  ,                    -- 单次命中最小值
						nMinEffect   = 7657  ,                    -- 单次命中最小有效值
						nAvg         = 27818 ,                    -- 单次命中平均值
						nAvgEffect   = 27818 ,                    -- 单次命中平均有效值
						nTotal       = 278560,                    -- 所以命中总伤害
						nTotalEffect = 224750,                    -- 所有命中总有效伤害
					},
					SKILL_RESULT.MISS = { ... },
					SKILL_RESULT.CRITICAL = { ... },
				},
				Skill = {                                         -- 该玩家具体造成输出的技能统计
					四象轮回 = {                                  -- 该玩家四象轮回造成的输出统计
						nCount       = 2     ,                    -- 该玩家四象轮回输出次数
						nMax         = 13415 ,                    -- 该玩家四象轮回最大输出量
						nMaxEffect   = 9080  ,                    -- 该玩家四象轮回最大有效输出量
						nTotal       = 23213 ,                    -- 该玩家四象轮回输出量总和
						nTotalEffect = 321421,                    -- 该玩家四象轮回有效输出量总和
						Detail = {                                -- 该玩家四象轮回输出结果分类统计
							SKILL_RESULT.HIT = {
								nCount       = 10    ,            -- 该玩家四象轮回命中记录数量
								nMax         = 34210 ,            -- 该玩家四象轮回单次命中最大值
								nMaxEffect   = 29817 ,            -- 该玩家四象轮回单次命中最大有效值
								nMin         = 8790  ,            -- 该玩家四象轮回单次命中最小值
								nMinEffect   = 7657  ,            -- 该玩家四象轮回单次命中最小有效值
								nAvg         = 27818 ,            -- 该玩家四象轮回单次命中平均值
								nAvgEffect   = 27818 ,            -- 该玩家四象轮回单次命中平均有效值
								nTotal       = 278560,            -- 该玩家四象轮回所有命中总伤害
								nTotalEffect = 224750,            -- 该玩家四象轮回所有命中总有效伤害
							},
							SKILL_RESULT.MISS = { ... },
							SKILL_RESULT.CRITICAL = { ... },
						},
						Target = {                                -- 该玩家四象轮回承受者统计
							玩家dwID = {                          -- 该玩家四象轮回击中的这个玩家数据统计
								nMax         = 13415 ,            -- 该玩家四象轮回击中的这个玩家最大伤害
								nMaxEffect   = 9080  ,            -- 该玩家四象轮回击中的这个玩家最大有效伤害
								nTotal       = 23213 ,            -- 该玩家四象轮回击中的这个玩家伤害总和
								nTotalEffect = 321421,            -- 该玩家四象轮回击中的这个玩家有效伤害总和
								Count = {                         -- 该玩家四象轮回击中的这个玩家结果统计
									SKILL_RESULT.HIT      = 5,
									SKILL_RESULT.MISS     = 3,
									SKILL_RESULT.CRITICAL = 3,
								},
							},
							Npc名字 = { ... },
							...
						},
					},
					两仪化形 = { ... },
					...
				},
				Target = {                                        -- 该玩家具体造成输出的对象统计
					玩家dwID = {                                  -- 该玩家对该dwID的玩家造成的输出统计
						nCount       = 2     ,                    -- 该玩家对该dwID的玩家输出次数
						nMax         = 13415 ,                    -- 该玩家对该dwID的玩家单次最大输出量
						nMaxEffect   = 9080  ,                    -- 该玩家对该dwID的玩家单次最大有效输出量
						nTotal       = 23213 ,                    -- 该玩家对该dwID的玩家输出量总和
						nTotalEffect = 321421,                    -- 该玩家对该dwID的玩家有效输出量总和
						Detail = {                                -- 该玩家对该dwID的玩家输出结果分类统计
							SKILL_RESULT.HIT = {
								nCount       = 10    ,            -- 该玩家对该dwID的玩家命中记录数量
								nMax         = 34210 ,            -- 该玩家对该dwID的玩家单次命中最大值
								nMaxEffect   = 29817 ,            -- 该玩家对该dwID的玩家单次命中最大有效值
								nMin         = 8790  ,            -- 该玩家对该dwID的玩家单次命中最小值
								nMinEffect   = 7657  ,            -- 该玩家对该dwID的玩家单次命中最小有效值
								nAvg         = 27818 ,            -- 该玩家对该dwID的玩家单次命中平均值
								nAvgEffect   = 27818 ,            -- 该玩家对该dwID的玩家单次命中平均有效值
								nTotal       = 278560,            -- 该玩家对该dwID的玩家所有命中总伤害
								nTotalEffect = 224750,            -- 该玩家对该dwID的玩家所有命中总有效伤害
							},
							SKILL_RESULT.MISS = { ... },
							SKILL_RESULT.CRITICAL = { ... },
						},
						Skill = {                                 -- 该玩家四象轮回承受者统计
							四象轮回 = {                          -- 该玩家四象轮回击中的这个玩家数据统计
								nMax         = 13415 ,            -- 该玩家四象轮回击中的这个玩家最大伤害
								nMaxEffect   = 9080  ,            -- 该玩家四象轮回击中的这个玩家最大有效伤害
								nTotal       = 23213 ,            -- 该玩家四象轮回击中的这个玩家伤害总和
								nTotalEffect = 321421,            -- 该玩家四象轮回击中的这个玩家有效伤害总和
								Count = {                         -- 该玩家四象轮回击中的这个玩家结果统计
									SKILL_RESULT.HIT      = 5,
									SKILL_RESULT.MISS     = 3,
									SKILL_RESULT.CRITICAL = 3,
								},
							},
							两仪化形 = { ... },
							...
						},
					},
				},
			},
			NPC的名字 = { ... },
		},
	},
	Heal = { ... },
	BeHeal = { ... },
	BeDamage = { ... },
}
]]
local SKILL_RESULT = {
	HIT     = 0, -- 命中
	BLOCK   = 1, -- 格挡
	SHIELD  = 2, -- 无效
	MISS    = 3, -- 偏离
	DODGE   = 4, -- 闪避
	CRITICAL= 5, -- 会心
	INSIGHT = 6, -- 识破
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
local Data          -- 当前战斗数据记录
local History = {}  -- 历史战斗记录
local SZ_REC_FILE = {'cache/fight_recount_log.jx3dat', PATH_TYPE.ROLE}

-- 输出两个数里面小一点的那个 其中-1表示极大值
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
-- 登陆游戏加载保存的数据
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

-- 退出游戏保存数据
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
	LIB.SaveLUAData(SZ_REC_FILE, data, { passphrase = false, indent = '\t' })
end

-- 过图清除当前战斗数据
do
local function onLoadingEnding()
	D.Flush()
	D.Init(true)
	FireUIEvent('MY_RECOUNT_NEW_FIGHT')
end
LIB.RegisterEvent('LOADING_ENDING', onLoadingEnding)
LIB.RegisterEvent('RELOAD_UI_ADDON_END', onLoadingEnding)
end

-- 退出战斗 保存数据
LIB.RegisterEvent('MY_FIGHT_HINT', function(event)
	if arg0 and LIB.GetFightUUID() ~= Data.UUID then -- 进入新的战斗
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
-- 获取统计数据
-- (table) D.Get(nIndex) -- 获取指定记录
--     (number)nIndex: 历史记录索引 为0返回当前统计
-- (table) D.Get()       -- 获取所有历史记录列表
function D.Get(nIndex)
	if not nIndex then
		return History
	elseif nIndex == 0 then
		return Data
	else
		return History[nIndex]
	end
end

-- 删除历史统计数据
-- (table) D.Del(nIndex) -- 删除指定序号的记录
--     (number)nIndex: 历史记录索引
-- (table) D.Del(data)   -- 删除指定记录
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

-- 计算暂离时间
-- D.GeneAwayTime(data, dwID, szRecordType)
-- data: 数据
-- dwID: 计算暂离的角色ID 为空则计算团队的暂离时间（目前永远为0）
-- szRecordType: 不同类型的数据在官方时间算法下计算结果可能不一样
--               枚举暂时有 Heal Damage BeDamage BeHeal 四种
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

-- 计算战斗时间
-- D.GeneFightTime(data, dwID, szRecordType)
-- data: 数据
-- szRecordType: 不同类型的数据在官方时间算法下计算结果可能不一样
--               枚举暂时有 Heal Damage BeDamage BeHeal 四种
--               为空则计算普通时间算法
-- dwID: 计算战斗时间的角色ID 为空则计算团队的战斗时间
function D.GeneFightTime(data, szRecordType, dwID)
	local nTimeDuring = data.nTimeDuring
	local nTimeBegin  = data.nTimeBegin
	if szRecordType and data[szRecordType] and data[szRecordType].nTimeDuring then
		nTimeDuring = data[szRecordType].nTimeDuring
	end
	if dwID and data.Awaytime and data.Awaytime[dwID] then
		for _, rec in ipairs(data.Awaytime[dwID]) do
			local nAwayBegin = max(rec[1], nTimeBegin)
			local nAwayEnd   = rec[2]
			if nAwayEnd then -- 完整的离开记录
				nTimeDuring = nTimeDuring - (nAwayEnd - nAwayBegin)
			else -- 离开了至今没回来的记录
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
-- 记录一次LOG
-- D.OnSkillEffect(dwCaster, dwTarget, nEffectType, dwID, dwLevel, nSkillResult, nResultCount, tResult)
-- (number) dwCaster    : 释放者ID
-- (number) dwTarget    : 承受者ID
-- (number) nEffectType : 造成效果的原因（SKILL_EFFECT_TYPE枚举 如SKILL,BUFF）
-- (number) dwID        : 技能ID
-- (number) dwLevel     : 技能等级
-- (number) nSkillResult: 造成的效果结果（SKILL_RESULT枚举 如HIT,MISS）
-- (number) nResultCount      : 造成效果的数值数量（tResult长度）
-- (table ) tResult     : 所有效果数值集合
function D.OnSkillEffect(dwCaster, dwTarget, nEffectType, dwEffectID, dwEffectLevel, nSkillResult, nResultCount, tResult)
	-- 获取释放对象和承受对象
	local KCaster = LIB.GetObject(dwCaster)
	if KCaster and not IsPlayer(dwCaster)
	and KCaster.dwEmployer and KCaster.dwEmployer ~= 0 then -- 宠物的数据算在主人统计中
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

	-- 过滤掉不是队友的以及不是BOSS的
	local me = GetClientPlayer()
	if dwCaster ~= me.dwID                 -- 释放者不是自己
	and dwTarget ~= me.dwID                -- 承受者不是自己
	and dwTargetEmployer ~= me.dwID        -- 承受者主人不是自己
	and not LIB.IsInArena()                 -- 不在竞技场
	and not LIB.IsInBattleField()           -- 不在战场
	and not me.IsPlayerInMyParty(dwCaster) -- 且释放者不是队友
	and not me.IsPlayerInMyParty(dwTarget) -- 且承受者不是队友
	and not (dwTargetEmployer and me.IsPlayerInMyParty(dwTargetEmployer)) -- 且承受者主人不是队友
	then -- 则忽视
		return
	end

	-- 未进战则初始化统计数据（即默认当前帧所有的技能日志为进战技能）
	if not LIB.GetFightUUID() and
	D.nLastAutoInitFrame ~= GetLogicFrameCount() then
		D.nLastAutoInitFrame = GetLogicFrameCount()
		D.Init(true)
	end

	-- 获取效果名称
	local szEffectID = D.InitEffectData(Data, nEffectType, dwEffectID, dwEffectLevel)
	local nTherapy = tResult[SKILL_RESULT_TYPE.THERAPY] or 0
	local nEffectTherapy = tResult[SKILL_RESULT_TYPE.EFFECTIVE_THERAPY] or 0
	local nDamage = (tResult[SKILL_RESULT_TYPE.PHYSICS_DAMAGE      ] or 0) + -- 外功伤害
					(tResult[SKILL_RESULT_TYPE.SOLAR_MAGIC_DAMAGE  ] or 0) + -- 阳性内功伤害
					(tResult[SKILL_RESULT_TYPE.NEUTRAL_MAGIC_DAMAGE] or 0) + -- 混元性内功伤害
					(tResult[SKILL_RESULT_TYPE.LUNAR_MAGIC_DAMAGE  ] or 0) + -- 阴性内功伤害
					(tResult[SKILL_RESULT_TYPE.POISON_DAMAGE       ] or 0) + -- 毒性伤害
					(tResult[SKILL_RESULT_TYPE.REFLECTIED_DAMAGE   ] or 0)   -- 反弹伤害
	local nEffectDamage = tResult[SKILL_RESULT_TYPE.EFFECTIVE_DAMAGE] or 0

	D.InsertEverything(Data,
		'SKILL_EFFECT', dwCaster, dwTarget,
		nEffectType, dwEffectID, dwEffectLevel, szEffectID,
		nSkillResult, nTherapy, nEffectTherapy, nDamage, nEffectDamage,
		tResult)

	-- 识破
	local nValue = tResult[SKILL_RESULT_TYPE.INSIGHT_DAMAGE]
	if nValue and nValue > 0 then
		D.AddDamageRecord(Data, dwCaster, dwTarget, szEffectID, nDamage, nEffectDamage, SKILL_RESULT.INSIGHT)
	elseif nSkillResult == SKILL_RESULT.HIT -- 击中
		or nSkillResult == SKILL_RESULT.CRITICAL -- 会心
	then
		if nTherapy > 0 then -- 有治疗
			D.AddHealRecord(Data, dwCaster, dwTarget, szEffectID, nTherapy, nEffectTherapy, nSkillResult)
		end
		if nDamage > 0 or nTherapy == 0 then -- 有伤害 或者 无伤害无治疗的效果
			D.AddDamageRecord(Data, dwCaster, dwTarget, szEffectID, nDamage, nEffectDamage, nSkillResult)
		end
	elseif nSkillResult == SKILL_RESULT.BLOCK  -- 格挡
		or nSkillResult == SKILL_RESULT.SHIELD -- 无效
		or nSkillResult == SKILL_RESULT.MISS   -- 偏离
		or nSkillResult == SKILL_RESULT.DODGE  -- 闪避
	then
		D.AddDamageRecord(Data, dwCaster, dwTarget, szEffectID, 0, 0, nSkillResult)
	end

	Data.nTimeDuring = GetCurrentTime() - Data.nTimeBegin
	Data.nTickDuring = GetTime() - Data.nTickBegin
end

-- 通过ID计算名字
function D.GetNameAusID(data, dwID)
	if not data or not dwID then
		return
	end
	return data.Namelist[dwID] or g_tStrings.STR_NAME_UNKNOWN
end

-- 通过ID计算势力
function D.GetForceAusID(data, dwID)
	if not data or not dwID then
		return
	end
	return data.Forcelist[dwID] or -1
end

-- 通过ID计算效果信息
function D.GetEffectInfoAusID(data, szEffectID)
	if not data or not szEffectID then
		return
	end
	return unpack(data.Effectlist[szEffectID] or CONSTANT.EMPTY_TABLE)
end

-- 判断是否是友军
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

-- 插入复盘数据
function D.InsertEverything(data, szName, ...)
	if not O.bRecEverything then
		return
	end
	insert(data.Everything, {GetLogicFrameCount(), GetCurrentTime(), GetTime(), szName, ...})
end

-- 将一条记录插入数组
function D.InsertRecord(data, szRecordType, idRecord, idTarget, szEffectName, nValue, nEffectValue, nSkillResult)
	local tInfo   = data[szRecordType]
	local tRecord = tInfo.Statistics[idRecord]
	if not szEffectName or szEffectName == '' then
		return
	end
	------------------------
	-- # 节： tInfo
	------------------------
	tInfo.nTimeDuring = GetCurrentTime() - data.nTimeBegin
	tInfo.nTotal        = tInfo.nTotal + nValue
	tInfo.nTotalEffect  = tInfo.nTotalEffect + nEffectValue
	------------------------
	-- # 节： tRecord
	------------------------
	tRecord.nTotal        = tRecord.nTotal + nValue
	tRecord.nTotalEffect  = tRecord.nTotalEffect + nEffectValue
	------------------------
	-- # 节： tRecord.Detail
	------------------------
	-- 添加/更新结果分类统计
	if not tRecord.Detail[nSkillResult] then
		tRecord.Detail[nSkillResult] = {
			nCount       =  0, -- 命中记录数量（假设nSkillResult是命中）
			nNzCount     =  0, -- 非零值命中记录数量
			nMax         =  0, -- 单次命中最大值
			nMaxEffect   =  0, -- 单次命中最大有效值
			nMin         = -1, -- 单次命中最小值
			nNzMin       = -1, -- 单次非零值命中最小值
			nMinEffect   = -1, -- 单次命中最小有效值
			nNzMinEffect = -1, -- 单次非零值命中最小有效值
			nTotal       =  0, -- 所有命中总伤害
			nTotalEffect =  0, -- 所有命中总有效伤害
			nAvg         =  0, -- 所有命中平均伤害
			nNzAvg       =  0, -- 所有非零值命中平均伤害
			nAvgEffect   =  0, -- 所有命中平均有效伤害
			nNzAvgEffect =  0, -- 所有非零值命中平均有效伤害
		}
	end
	local tResult = tRecord.Detail[nSkillResult]
	tResult.nCount       = tResult.nCount + 1                                -- 命中次数（假设nSkillResult是命中）
	tResult.nMax         = max(tResult.nMax, nValue)                    -- 单次命中最大值
	tResult.nMaxEffect   = max(tResult.nMaxEffect, nEffectValue)        -- 单次命中最大有效值
	tResult.nMin         = (tResult.nMin ~= -1 and min(tResult.nMin, nValue)) or nValue                         -- 单次命中最小值
	tResult.nMinEffect   = (tResult.nMinEffect ~= -1 and min(tResult.nMinEffect, nEffectValue)) or nEffectValue -- 单次命中最小有效值
	tResult.nTotal       = tResult.nTotal + nValue                           -- 所以命中总伤害
	tResult.nTotalEffect = tResult.nTotalEffect + nEffectValue               -- 所有命中总有效伤害
	tResult.nAvg         = floor(tResult.nTotal / tResult.nCount)       -- 单次命中平均值
	tResult.nAvgEffect   = floor(tResult.nTotalEffect / tResult.nCount) -- 单次命中平均有效值
	if nValue ~= 0 or NZ_SKILL_RESULT[nSkillResult] then
		tResult.nNzCount     = tResult.nNzCount + 1                           -- 命中次数（假设nSkillResult是命中）
		tResult.nNzMin       = (tResult.nNzMin ~= -1 and min(tResult.nNzMin, nValue)) or nValue                         -- 单次命中最小值
		tResult.nNzMinEffect = (tResult.nNzMinEffect ~= -1 and min(tResult.nNzMinEffect, nEffectValue)) or nEffectValue -- 单次命中最小有效值
		tResult.nNzAvg       = floor(tResult.nTotal / tResult.nNzCount)       -- 单次命中平均值
		tResult.nNzAvgEffect = floor(tResult.nTotalEffect / tResult.nNzCount) -- 单次命中平均有效值
	end

	------------------------
	-- # 节： tRecord.Skill
	------------------------
	-- 添加具体技能记录
	if not tRecord.Skill[szEffectName] then
		tRecord.Skill[szEffectName] = {
			nCount       =  0, -- 该玩家四象轮回释放次数（假设szEffectName是四象轮回）
			nNzCount     =  0, -- 该玩家非零值四象轮回释放次数
			nMax         =  0, -- 该玩家四象轮回最大输出量
			nMaxEffect   =  0, -- 该玩家四象轮回最大有效输出量
			nTotal       =  0, -- 该玩家四象轮回输出量总和
			nTotalEffect =  0, -- 该玩家四象轮回有效输出量总和
			nAvg         =  0, -- 该玩家所有四象轮回平均伤害
			nNzAvg       =  0, -- 该玩家所有非零值四象轮回平均伤害
			nAvgEffect   =  0, -- 该玩家所有四象轮回平均有效伤害
			nNzAvgEffect =  0, -- 该玩家所有非零值四象轮回平均有效伤害
			Detail       = {}, -- 该玩家四象轮回输出结果分类统计
			Target       = {}, -- 该玩家四象轮回承受者统计
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
	-- # 节： tRecord.Skill[x].Detail
	---------------------------------
	-- 添加/更新具体技能结果分类统计
	if not tSkillRecord.Detail[nSkillResult] then
		tSkillRecord.Detail[nSkillResult] = {
			nCount       =  0, -- 命中记录数量
			nNzCount     =  0, -- 非零值命中记录数量
			nMax         =  0, -- 单次命中最大值
			nMaxEffect   =  0, -- 单次命中最大有效值
			nMin         = -1, -- 单次命中最小值
			nNzMin       = -1, -- 单次非零值命中最小值
			nMinEffect   = -1, -- 单次命中最小有效值
			nNzMinEffect = -1, -- 单次非零值命中最小有效值
			nTotal       =  0, -- 所以命中总伤害
			nTotalEffect =  0, -- 所有命中总有效伤害
			nAvg         =  0, -- 所有命中平均伤害
			nNzAvg       =  0, -- 所有非零值命中平均伤害
			nAvgEffect   =  0, -- 所有命中平均有效伤害
			nNzAvgEffect =  0, -- 所有非零值命中平均有效伤害
		}
	end
	local tResult = tSkillRecord.Detail[nSkillResult]
	tResult.nCount       = tResult.nCount + 1                           -- 命中次数（假设nSkillResult是命中）
	tResult.nMax         = max(tResult.nMax, nValue)               -- 单次命中最大值
	tResult.nMaxEffect   = max(tResult.nMaxEffect, nEffectValue)   -- 单次命中最大有效值
	tResult.nMin         = (tResult.nMin ~= -1 and min(tResult.nMin, nValue)) or nValue                         -- 单次命中最小值
	tResult.nMinEffect   = (tResult.nMinEffect ~= -1 and min(tResult.nMinEffect, nEffectValue)) or nEffectValue -- 单次命中最小有效值
	tResult.nTotal       = tResult.nTotal + nValue                      -- 所以命中总伤害
	tResult.nTotalEffect = tResult.nTotalEffect + nEffectValue          -- 所有命中总有效伤害
	tResult.nAvg         = floor(tResult.nTotal / tResult.nCount)
	tResult.nAvgEffect   = floor(tResult.nTotalEffect / tResult.nCount)
	if nValue ~= 0 or NZ_SKILL_RESULT[nSkillResult] then
		tResult.nNzCount     = tResult.nNzCount + 1                           -- 命中次数（假设nSkillResult是命中）
		tResult.nNzMin       = (tResult.nNzMin ~= -1 and min(tResult.nNzMin, nValue)) or nValue                         -- 单次命中最小值
		tResult.nNzMinEffect = (tResult.nNzMinEffect ~= -1 and min(tResult.nNzMinEffect, nEffectValue)) or nEffectValue -- 单次命中最小有效值
		tResult.nNzAvg       = floor(tResult.nTotal / tResult.nNzCount)
		tResult.nNzAvgEffect = floor(tResult.nTotalEffect / tResult.nNzCount)
	end

	------------------------------
	-- # 节： tRecord.Skill.Target
	------------------------------
	-- 添加具体技能承受者记录
	if not tSkillRecord.Target[idTarget] then
		tSkillRecord.Target[idTarget] = {
			nMax         = 0,            -- 该玩家四象轮回击中的这个玩家最大伤害
			nMaxEffect   = 0,            -- 该玩家四象轮回击中的这个玩家最大有效伤害
			nTotal       = 0,            -- 该玩家四象轮回击中的这个玩家伤害总和
			nTotalEffect = 0,            -- 该玩家四象轮回击中的这个玩家有效伤害总和
			Count = {                    -- 该玩家四象轮回击中的这个玩家结果统计
				-- [SKILL_RESULT.HIT     ] = 5,
				-- [SKILL_RESULT.MISS    ] = 3,
				-- [SKILL_RESULT.CRITICAL] = 3,
			},
			NzCount = {                  -- 该玩家非零值四象轮回击中的这个玩家结果统计
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
	-- # 节： tRecord.Target
	------------------------
	-- 添加具体承受/释放者记录
	if not tRecord.Target[idTarget] then
		tRecord.Target[idTarget] = {
			nCount       =  0, -- 该玩家对idTarget的技能释放次数
			nNzCount     =  0, -- 该玩家对idTarget的非零值技能释放次数
			nMax         =  0, -- 该玩家对idTarget的技能最大输出量
			nMaxEffect   =  0, -- 该玩家对idTarget的技能最大有效输出量
			nTotal       =  0, -- 该玩家对idTarget的技能输出量总和
			nTotalEffect =  0, -- 该玩家对idTarget的技能有效输出量总和
			nAvg         =  0, -- 该玩家对idTarget的技能平均输出量
			nNzAvg       =  0, -- 该玩家对idTarget的非零值技能平均输出量
			nAvgEffect   =  0, -- 该玩家对idTarget的技能平均有效输出量
			nNzAvgEffect =  0, -- 该玩家对idTarget的非零值技能平均有效输出量
			Detail       = {}, -- 该玩家对idTarget的技能输出结果分类统计
			Skill        = {}, -- 该玩家对idTarget的技能具体分别统计
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
	-- # 节： tRecord.Target[x].Detail
	----------------------------------
	-- 添加/更新具体承受/释放者结果分类统计
	if not tTargetRecord.Detail[nSkillResult] then
		tTargetRecord.Detail[nSkillResult] = {
			nCount       =  0, -- 命中记录数量（假设nSkillResult是命中）
			nNzCount     =  0, -- 非零值命中记录数量
			nMax         =  0, -- 单次命中最大值
			nMaxEffect   =  0, -- 单次命中最大有效值
			nMin         = -1, -- 单次命中最小值
			nNzMin       = -1, -- 单次非零值命中最小值
			nMinEffect   = -1, -- 单次命中最小有效值
			nNzMinEffect = -1, -- 单次非零值命中最小有效值
			nTotal       =  0, -- 所以命中总伤害
			nTotalEffect =  0, -- 所有命中总有效伤害
			nAvg         =  0, -- 所有命中平均伤害
			nNzAvg       =  0, -- 所有非零值命中平均伤害
			nAvgEffect   =  0, -- 所有命中平均有效伤害
			nNzAvgEffect =  0, -- 所有非零值命中平均有效伤害
		}
	end
	local tResult = tTargetRecord.Detail[nSkillResult]
	tResult.nCount       = tResult.nCount + 1                           -- 命中次数（假设nSkillResult是命中）
	tResult.nMax         = max(tResult.nMax, nValue)               -- 单次命中最大值
	tResult.nMaxEffect   = max(tResult.nMaxEffect, nEffectValue)   -- 单次命中最大有效值
	tResult.nMin         = (tResult.nMin ~= -1 and min(tResult.nMin, nValue)) or nValue                         -- 单次命中最小值
	tResult.nMinEffect   = (tResult.nMinEffect ~= -1 and min(tResult.nMinEffect, nEffectValue)) or nEffectValue -- 单次命中最小有效值
	tResult.nTotal       = tResult.nTotal + nValue                      -- 所以命中总伤害
	tResult.nTotalEffect = tResult.nTotalEffect + nEffectValue          -- 所有命中总有效伤害
	tResult.nAvg         = floor(tResult.nTotal / tResult.nCount)
	tResult.nAvgEffect   = floor(tResult.nTotalEffect / tResult.nCount)
	if nValue ~= 0 or NZ_SKILL_RESULT[nSkillResult] then
		tResult.nNzCount       = tResult.nNzCount + 1                           -- 命中次数（假设nSkillResult是命中）
		tResult.nNzMin         = (tResult.nNzMin ~= -1 and min(tResult.nNzMin, nValue)) or nValue                         -- 单次命中最小值
		tResult.nNzMinEffect   = (tResult.nNzMinEffect ~= -1 and min(tResult.nNzMinEffect, nEffectValue)) or nEffectValue -- 单次命中最小有效值
		tResult.nNzAvg         = floor(tResult.nTotal / tResult.nNzCount)
		tResult.nNzAvgEffect   = floor(tResult.nTotalEffect / tResult.nNzCount)
	end

	---------------------------------
	-- # 节： tRecord.Target[x].Skill
	---------------------------------
	-- 添加承受者具体技能记录
	if not tTargetRecord.Skill[szEffectName] then
		tTargetRecord.Skill[szEffectName] = {
			nMax         = 0,            -- 该玩家击中这个玩家的四象轮回最大伤害
			nMaxEffect   = 0,            -- 该玩家击中这个玩家的四象轮回最大有效伤害
			nTotal       = 0,            -- 该玩家击中这个玩家的四象轮回伤害总和
			nTotalEffect = 0,            -- 该玩家击中这个玩家的四象轮回有效伤害总和
			Count = {                    -- 该玩家击中这个玩家的四象轮回结果统计
				-- [SKILL_RESULT.HIT     ] = 5,
				-- [SKILL_RESULT.MISS    ] = 3,
				-- [SKILL_RESULT.CRITICAL] = 3,
			},
			NzCount = {                    -- 该玩家非零值击中这个玩家的四象轮回结果统计
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

-- 插入一条伤害记录
function D.AddDamageRecord(data, dwCaster, dwTarget, szEffectID, nDamage, nEffectDamage, nSkillResult)
	-- 添加伤害记录
	D.InitObjectData(data, dwCaster, 'Damage')
	D.InsertRecord(data, 'Damage'  , dwCaster, dwTarget, szEffectID, nDamage, nEffectDamage, nSkillResult)
	-- 添加承伤记录
	D.InitObjectData(data, dwTarget, 'BeDamage')
	D.InsertRecord(data, 'BeDamage', dwTarget, dwCaster, szEffectID, nDamage, nEffectDamage, nSkillResult)
end

-- 插入一条治疗记录
function D.AddHealRecord(data, dwCaster, dwTarget, szEffectID, nHeal, nEffectHeal, nSkillResult)
	-- 添加伤害记录
	D.InitObjectData(data, dwCaster, 'Heal')
	D.InsertRecord(data, 'Heal'    , dwCaster, dwTarget, szEffectID, nHeal, nEffectHeal, nSkillResult)
	-- 添加承伤记录
	D.InitObjectData(data, dwTarget, 'BeHeal')
	D.InsertRecord(data, 'BeHeal'  , dwTarget, dwCaster, szEffectID, nHeal, nEffectHeal, nSkillResult)
end

-- 确认对象数据已创建（未创建则创建）
function D.InitObjectData(data, dwID, szChannel)
	-- 名称缓存
	if not data.Namelist[dwID] then
		data.Namelist[dwID] = LIB.GetObjectName(IsPlayer(dwID) and TARGET.PLAYER or TARGET.NPC, dwID, 'never') -- 名称缓存
	end
	-- 势力缓存
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
	-- 统计结构体
	if not data[szChannel].Statistics[dwID] then
		data[szChannel].Statistics[dwID] = {
			szMD5        = dwID, -- 唯一标识
			nTotal       = 0   , -- 总输出
			nTotalEffect = 0   , -- 有效输出
			Detail       = {}  , -- 输出结果按技能结果分类统计
			Skill        = {}  , -- 该玩家具体造成输出的技能统计
			Target       = {}  , -- 该玩家具体对谁造成输出的统计
		}
	end
end

function D.InitEffectData(data, nType, dwID, nLevel)
	local szKey = nType .. ',' .. dwID .. ',' .. nLevel
	if not data.Effectlist[szKey] then
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
		data.Effectlist[szKey] = {szName, bAnonymous, nType, dwID, nLevel}
	end
	return szKey
end

-- 初始化Data
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
			UUID              = LIB.GetFightUUID(),                 -- 战斗唯一标识
			nVersion          = VERSION,                           -- 数据版本号
			bDistinctEffectID = O.bDistinctEffectID,               -- 是否根据ID区分同名效果
			nTimeBegin        = GetCurrentTime(),                  -- 战斗开始时间
			nTickBegin        = GetTime(),                         -- 战斗开始毫秒时间
			nTimeDuring       =  0,                                -- 战斗持续时间
			nTickDuring       =  0,                                -- 战斗持续毫秒时间
			Awaytime          = {},                                -- 死亡/掉线时间节点
			Namelist          = {},                                -- 名称缓存
			Forcelist         = {},                                -- 势力缓存
			Effectlist        = {},                                -- 效果信息缓存
			Damage            = GeneTypeNS(),                      -- 输出统计
			Heal              = GeneTypeNS(),                      -- 治疗统计
			BeHeal            = GeneTypeNS(),                      -- 承疗统计
			BeDamage          = GeneTypeNS(),                      -- 承伤统计
			Everything        = {},                                -- 战斗复盘
		}
	end

	if not Data.UUID and LIB.GetFightUUID() then
		Data.UUID       = LIB.GetFightUUID()
		Data.nTimeBegin = GetCurrentTime()
	end
end
end

-- Data数据压入历史记录 并重新初始化Data
function D.Flush()
	if not (Data and Data.UUID) then
		return
	end

	-- 过滤空记录
	if IsEmpty(Data.BeDamage.Statistics)
	and IsEmpty(Data.Damage.Statistics)
	and IsEmpty(Data.Heal.Statistics)
	and IsEmpty(Data.BeHeal.Statistics) then
		return
	end

	-- 计算受伤最多的名字作为战斗名称
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
	-- 如果没有 则计算输出最多的NPC名字作为战斗名称
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

-- 系统日志监控（数据源）
LIB.RegisterEvent('SYS_MSG', function()
	if arg0 == 'UI_OME_SKILL_CAST_LOG' then
		-- 技能施放日志；
		-- (arg1)dwCaster：技能施放者 (arg2)dwSkillID：技能ID (arg3)dwLevel：技能等级
		-- D.OnSkillCast(arg1, arg2, arg3)
	elseif arg0 == 'UI_OME_SKILL_CAST_RESPOND_LOG' then
		-- 技能施放结果日志；
		-- (arg1)dwCaster：技能施放者 (arg2)dwSkillID：技能ID
		-- (arg3)dwLevel：技能等级 (arg4)nRespond：见枚举型[[SKILL_RESULT_CODE]]
		-- D.OnSkillCastRespond(arg1, arg2, arg3, arg4)
	elseif arg0 == 'UI_OME_SKILL_EFFECT_LOG' then
		-- if not LIB.IsInArena() then
		-- 技能最终产生的效果（生命值的变化）；
		-- (arg1)dwCaster：施放者 (arg2)dwTarget：目标 (arg3)bReact：是否为反击 (arg4)nType：Effect类型 (arg5)dwID:Effect的ID
		-- (arg6)dwLevel：Effect的等级 (arg7)bCriticalStrike：是否会心 (arg8)nCount：tResultCount数据表中元素个数 (arg9)tResultCount：数值集合
		-- D.OnSkillEffect(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
		if arg7 and arg7 ~= 0 then -- bCriticalStrike
			D.OnSkillEffect(arg1, arg2, arg4, arg5, arg6, SKILL_RESULT.CRITICAL, arg8, arg9)
		else
			D.OnSkillEffect(arg1, arg2, arg4, arg5, arg6, SKILL_RESULT.HIT, arg8, arg9)
		end
		-- end
	elseif arg0 == 'UI_OME_SKILL_BLOCK_LOG' then
		-- 格挡日志；
		-- (arg1)dwCaster：施放者 (arg2)dwTarget：目标 (arg3)nType：Effect的类型
		-- (arg4)dwID：Effect的ID (arg5)dwLevel：Effect的等级 (arg6)nDamageType：伤害类型，见枚举型[[SKILL_RESULT_TYPE]]
		D.OnSkillEffect(arg1, arg2, arg3, arg4, arg5, SKILL_RESULT.BLOCK, nil, {})
	elseif arg0 == 'UI_OME_SKILL_SHIELD_LOG' then
		-- 技能被屏蔽日志；
		-- (arg1)dwCaster：施放者 (arg2)dwTarget：目标
		-- (arg3)nType：Effect的类型 (arg4)dwID：Effect的ID (arg5)dwLevel：Effect的等级
		D.OnSkillEffect(arg1, arg2, arg3, arg4, arg5, SKILL_RESULT.SHIELD, nil, {})
	elseif arg0 == 'UI_OME_SKILL_MISS_LOG' then
		-- 技能未命中目标日志；
		-- (arg1)dwCaster：施放者 (arg2)dwTarget：目标
		-- (arg3)nType：Effect的类型 (arg4)dwID：Effect的ID (arg5)dwLevel：Effect的等级
		D.OnSkillEffect(arg1, arg2, arg3, arg4, arg5, SKILL_RESULT.MISS, nil, {})
	elseif arg0 == 'UI_OME_SKILL_HIT_LOG' then
		-- 技能命中目标日志；
		-- (arg1)dwCaster：施放者 (arg2)dwTarget：目标
		-- (arg3)nType：Effect的类型 (arg4)dwID：Effect的ID (arg5)dwLevel：Effect的等级
		-- D.OnSkillEffect(arg1, arg2, arg3, arg4, arg5, SKILL_RESULT.HIT, nil, {})
	elseif arg0 == 'UI_OME_SKILL_DODGE_LOG' then
		-- 技能被闪避日志；
		-- (arg1)dwCaster：施放者 (arg2)dwTarget：目标
		-- (arg3)nType：Effect的类型 (arg4)dwID：Effect的ID (arg5)dwLevel：Effect的等级
		D.OnSkillEffect(arg1, arg2, arg3, arg4, arg5, SKILL_RESULT.DODGE, nil, {})
	elseif arg0 == 'UI_OME_COMMON_HEALTH_LOG' then
		-- 普通治疗日志；
		-- (arg1)dwCharacterID：承疗玩家ID (arg2)nDeltaLife：增加血量值
		-- D.OnCommonHealth(arg1, arg2)
	end
end)

-- JJC中使用的数据源（不能记录溢出数据）
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

--         if nType == SKILL_RESULT_TYPE.PHYSICS_DAMAGE -- 外功伤害
--         or nType == SKILL_RESULT_TYPE.SOLAR_MAGIC_DAMAGE -- 阳性内功伤害
--         or nType == SKILL_RESULT_TYPE.NEUTRAL_MAGIC_DAMAGE -- 中性内功伤害
--         or nType == SKILL_RESULT_TYPE.LUNAR_MAGIC_DAMAGE -- 阴性内功伤害
--         or nType == SKILL_RESULT_TYPE.POISON_DAMAGE then -- 毒性内功伤害
--         -- if nType == SKILL_RESULT_TYPE.EFFECTIVE_DAMAGE then -- 有效伤害值
--             nResultCount = nResultCount + 1
--             tResult[SKILL_RESULT_TYPE.EFFECTIVE_DAMAGE] = nValue
--         elseif nType == SKILL_RESULT_TYPE.REFLECTIED_DAMAGE then -- 反弹伤害
--             dwCasterID, dwTargetID = dwTargetID, dwCasterID
--         elseif nType == SKILL_RESULT_TYPE.THERAPY then -- 治疗
--         -- elseif nType == SKILL_RESULT_TYPE.EFFECTIVE_THERAPY then -- 有效治疗量
--             nResultCount = nResultCount + 1
--             tResult[SKILL_RESULT_TYPE.EFFECTIVE_THERAPY] = nValue
--         elseif nType == SKILL_RESULT_TYPE.STEAL_LIFE then -- 偷取生命值
--             dwTargetID = dwCasterID
--             nResultCount = nResultCount + 1
--             tResult[SKILL_RESULT_TYPE.EFFECTIVE_THERAPY] = nValue
--         elseif nType == SKILL_RESULT_TYPE.ABSORB_DAMAGE then -- 吸收伤害
--             nResultCount = nResultCount + 1
--             tResult[SKILL_RESULT_TYPE.EFFECTIVE_DAMAGE] = 0
--         elseif nType == SKILL_RESULT_TYPE.SHIELD_DAMAGE then -- 内力抵消伤害
--             nResultCount = nResultCount + 1
--             tResult[SKILL_RESULT_TYPE.EFFECTIVE_DAMAGE] = 0
--         elseif nType == SKILL_RESULT_TYPE.PARRY_DAMAGE then -- 闪避伤害
--             nResultCount = nResultCount + 1
--             tResult[SKILL_RESULT_TYPE.EFFECTIVE_DAMAGE] = 0
--         elseif nType == SKILL_RESULT_TYPE.INSIGHT_DAMAGE then -- 识破伤害
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


-- 有人死了活了做一下时间轴记录
function D.OnTeammateStateChange(dwID, bLeave, nAwayType, bAddWhenRecEmpty)
	if not (Data and Data.Awaytime) then
		return
	end
	-- 获得一个人的记录
	local rec = Data.Awaytime[dwID]
	if not rec then -- 初始化一个记录
		if not bLeave and not bAddWhenRecEmpty then
			return -- 不是一次暂离的开始并且不强制记录则跳过
		end
		rec = {}
		Data.Awaytime[dwID] = rec
	elseif #rec > 0 then -- 检查逻辑
		if bLeave then -- 有人死了
			if not rec[#rec][2] then -- 并且最后一条记录还是死的
				return
			end
		else -- 有人活了
			if rec[#rec][2] then -- 并且本来就是活的
				return
			end
		end
	end
	-- 插入数据到记录
	if bLeave then -- 暂离开始
		insert(rec, { GetCurrentTime(), nil, nAwayType })
	else -- 暂离回来
		if #rec == 0 then -- 没记录到暂离开始 创建一个从本次战斗开始的暂离（俗称还没开打你就死了。。）
			insert(rec, { Data.nTimeBegin, GetCurrentTime(), nAwayType })
		elseif not rec[#rec][2] then -- 如果最后一次暂离还没回来 则完成最后一次暂离的记录
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
	if arg2 == 0 then -- 有人掉线
		D.OnTeammateStateChange(arg1, true, AWAYTIME_TYPE.OFFLINE, false)
	else -- 有人上线
		D.OnTeammateStateChange(arg1, false, AWAYTIME_TYPE.OFFLINE, false)
		local team = GetClientTeam()
		local info = team.GetMemberInfo(arg1)
		if info and info.bDeathFlag then -- 上线死着的 结束离线暂离 开始死亡暂离
			D.OnTeammateStateChange(arg1, true, AWAYTIME_TYPE.DEATH, false)
		end
	end
end)
LIB.RegisterEvent('MY_RECOUNT_NEW_FIGHT', function() -- 开战扫描队友 记录开战就死掉/掉线的人
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
LIB.RegisterEvent('PARTY_ADD_MEMBER', function() -- 中途有人进队 补上暂离记录
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

-- 同名目标数据合并
function D.MergeTargetData(data, tDst, tSrc, bMergeNpc)
	------------------------
	-- # 节： tRecord
	------------------------
	-- 合并总数据
	tDst.nTotal = tDst.nTotal + tSrc.nTotal
	tDst.nTotalEffect = tDst.nTotalEffect + tSrc.nTotalEffect
	------------------------
	-- # 节： tRecord.Detail
	------------------------
	-- 合并分类详情（命中、会心、偏离...）
	for nType, tSrcDetail in pairs(tSrc.Detail) do
		local tDstDetail = tDst.Detail[nType]
		if not tDstDetail then
			tDstDetail = {
				nCount       =  0, -- 命中记录数量（假设nSkillResult是命中）
				nNzCount     =  0, -- 非零值命中记录数量
				nMax         =  0, -- 单次命中最大值
				nMaxEffect   =  0, -- 单次命中最大有效值
				nMin         = -1, -- 单次命中最小值
				nNzMin       = -1, -- 单次非零值命中最小值
				nMinEffect   = -1, -- 单次命中最小有效值
				nNzMinEffect = -1, -- 单次非零值命中最小有效值
				nTotal       =  0, -- 所有命中总伤害
				nTotalEffect =  0, -- 所有命中总有效伤害
				nAvg         =  0, -- 所有命中平均伤害
				nNzAvg       =  0, -- 所有非零值命中平均伤害
				nAvgEffect   =  0, -- 所有命中平均有效伤害
				nNzAvgEffect =  0, -- 所有非零值命中平均有效伤害
			}
			tDst.Detail[nType] = tDstDetail
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
	-- # 节： tRecord.Skill
	------------------------
	-- 合并技能统计（四象轮回、两仪化形...）
	for szSkill, tSrcSkill in pairs(tSrc.Skill) do
		local tDstSkill = tDst.Skill[szSkill]
		if not tDstSkill then
			tDstSkill = {
				nCount       =  0, -- 该玩家四象轮回释放次数（假设szEffectName是四象轮回）
				nNzCount     =  0, -- 该玩家非零值四象轮回释放次数
				nMax         =  0, -- 该玩家四象轮回最大输出量
				nMaxEffect   =  0, -- 该玩家四象轮回最大有效输出量
				nTotal       =  0, -- 该玩家四象轮回输出量总和
				nTotalEffect =  0, -- 该玩家四象轮回有效输出量总和
				nAvg         =  0, -- 该玩家所有四象轮回平均伤害
				nNzAvg       =  0, -- 该玩家所有非零值四象轮回平均伤害
				nAvgEffect   =  0, -- 该玩家所有四象轮回平均有效伤害
				nNzAvgEffect =  0, -- 该玩家所有非零值四象轮回平均有效伤害
				Detail       = {}, -- 该玩家四象轮回输出结果分类统计
				Target       = {}, -- 该玩家四象轮回承受者统计
			}
			tDst.Skill[szSkill] = tDstSkill
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
		-- # 节： tRecord.Skill[x].Detail
		---------------------------------
		-- 合并技能详情统计（四象轮回的命中、会心...）
		for nType, tSrcSkillDetail in pairs(tSrcSkill.Detail) do
			local tDstSkillDetail = tDstSkill.Detail[nType]
			if not tDstSkillDetail then
				tDstSkillDetail = {
					nCount       =  0, -- 命中记录数量
					nNzCount     =  0, -- 非零值命中记录数量
					nMax         =  0, -- 单次命中最大值
					nMaxEffect   =  0, -- 单次命中最大有效值
					nMin         = -1, -- 单次命中最小值
					nNzMin       = -1, -- 单次非零值命中最小值
					nMinEffect   = -1, -- 单次命中最小有效值
					nNzMinEffect = -1, -- 单次非零值命中最小有效值
					nTotal       =  0, -- 所以命中总伤害
					nTotalEffect =  0, -- 所有命中总有效伤害
					nAvg         =  0, -- 所有命中平均伤害
					nNzAvg       =  0, -- 所有非零值命中平均伤害
					nAvgEffect   =  0, -- 所有命中平均有效伤害
					nNzAvgEffect =  0, -- 所有非零值命中平均有效伤害
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
		-- # 节： tRecord.Skill.Target
		------------------------------
		-- 合并技能目标统计（四象轮回对江湖试炼木桩、江湖初级木桩...）
		for dwID, tSrcSkillTarget in pairs(tSrcSkill.Target) do
			local id = bMergeNpc and D.GetNameAusID(data, dwID) or dwID
			local tDstSkillTarget = tDstSkill.Target[id]
			if not tDstSkillTarget then
				tDstSkillTarget = {
					nMax         =  0, -- 该玩家四象轮回击中的这个玩家最大伤害
					nMaxEffect   =  0, -- 该玩家四象轮回击中的这个玩家最大有效伤害
					nTotal       =  0, -- 该玩家四象轮回击中的这个玩家伤害总和
					nTotalEffect =  0, -- 该玩家四象轮回击中的这个玩家有效伤害总和
					Count        = {}, -- 该玩家四象轮回击中的这个玩家结果统计
					NzCount      = {}, -- 该玩家非零值四象轮回击中的这个玩家结果统计
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
	------------------------
	-- # 节： tRecord.Target
	------------------------
	-- 合并目标统计（江湖试炼木桩、江湖初级木桩...）
	for dwID, tSrcTarget in pairs(tSrc.Target) do
		local id = bMergeNpc and D.GetNameAusID(data, dwID) or dwID
		local tDstTarget = tDst.Target[id]
		if not tDstTarget then
			tDstTarget = {
				nCount       =  0, -- 该玩家对idTarget的技能释放次数
				nNzCount     =  0, -- 该玩家对idTarget的非零值技能释放次数
				nMax         =  0, -- 该玩家对idTarget的技能最大输出量
				nMaxEffect   =  0, -- 该玩家对idTarget的技能最大有效输出量
				nTotal       =  0, -- 该玩家对idTarget的技能输出量总和
				nTotalEffect =  0, -- 该玩家对idTarget的技能有效输出量总和
				nAvg         =  0, -- 该玩家对idTarget的技能平均输出量
				nNzAvg       =  0, -- 该玩家对idTarget的非零值技能平均输出量
				nAvgEffect   =  0, -- 该玩家对idTarget的技能平均有效输出量
				nNzAvgEffect =  0, -- 该玩家对idTarget的非零值技能平均有效输出量
				Detail       = {}, -- 该玩家对idTarget的技能输出结果分类统计
				Skill        = {}, -- 该玩家对idTarget的技能具体分别统计
			}
			tDst.Target[id] = tDstTarget
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
		-- # 节： tRecord.Target[x].Detail
		----------------------------------
		-- 合并目标技能详情统计（四象轮回的命中、会心...）
		for nType, tSrcTargetDetail in pairs(tSrcTarget.Detail) do
			local tDstTargetDetail = tDstTarget.Detail[nType]
			if not tDstTargetDetail then
				tDstTargetDetail = {
					nCount       =  0, -- 命中记录数量（假设nSkillResult是命中）
					nNzCount     =  0, -- 非零值命中记录数量
					nMax         =  0, -- 单次命中最大值
					nMaxEffect   =  0, -- 单次命中最大有效值
					nMin         = -1, -- 单次命中最小值
					nNzMin       = -1, -- 单次非零值命中最小值
					nMinEffect   = -1, -- 单次命中最小有效值
					nNzMinEffect = -1, -- 单次非零值命中最小有效值
					nTotal       =  0, -- 所以命中总伤害
					nTotalEffect =  0, -- 所有命中总有效伤害
					nAvg         =  0, -- 所有命中平均伤害
					nNzAvg       =  0, -- 所有非零值命中平均伤害
					nAvgEffect   =  0, -- 所有命中平均有效伤害
					nNzAvgEffect =  0, -- 所有非零值命中平均有效伤害
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
		-- # 节： tRecord.Target[x].Skill
		---------------------------------
		-- 合并目标技能统计（江湖试炼木桩被四象轮回、两仪化形...）
		for szSkill, tSrcTargetSkill in pairs(tSrcTarget.Skill) do
			local tDstTargetSkill = tDstTarget.Skill[szSkill]
			if not tDstTargetSkill then
				tDstTargetSkill = {
					nMax         =  0, -- 该玩家击中这个玩家的四象轮回最大伤害
					nMaxEffect   =  0, -- 该玩家击中这个玩家的四象轮回最大有效伤害
					nTotal       =  0, -- 该玩家击中这个玩家的四象轮回伤害总和
					nTotalEffect =  0, -- 该玩家击中这个玩家的四象轮回有效伤害总和
					Count        = {}, -- 该玩家击中这个玩家的四象轮回结果统计
					NzCount      = {}, -- 该玩家非零值击中这个玩家的四象轮回结果统计
				}
				tDstTarget.Skill[szSkill] = tDstTargetSkill
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

function D.GetMergeTargetData(data, szChannel, id)
	local tData, bMergeNpc = nil, IsString(id)
	for dwID, tSrcData in pairs(data[szChannel].Statistics) do
		if dwID == id or D.GetNameAusID(data, dwID) == id then
			if not tData then
				tData = {
					nTotal = 0,
					nTotalEffect = 0,
					Target = {},
					Skill = {},
					Detail = {},
				}
			end
			D.MergeTargetData(data, tData, tSrcData, bMergeNpc)
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
				Flush = D.Flush,
				GetMergeTargetData = D.GetMergeTargetData,
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
