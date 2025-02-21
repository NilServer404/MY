--------------------------------------------------------
-- This file is part of the JX3 Plugin Project.
-- @desc     : 游戏常量枚举
-- @copyright: Copyright (c) 2009 Kingsoft Co., Ltd.
--------------------------------------------------------
-------------------------------------------------------------------------------------------------------
-- these global functions are accessed all the time by the event handler
-- so caching them is worth the effort
-------------------------------------------------------------------------------------------------------
local ipairs, pairs, next, pcall, select = ipairs, pairs, next, pcall, select
local string, math, table = string, math, table
-- lib apis caching
local X = MY
local UI, GLOBAL, CONSTANT, wstring, lodash = X.UI, X.GLOBAL, X.CONSTANT, X.wstring, X.lodash
-------------------------------------------------------------------------------------------------------
local _L = X.LoadLangPack(X.PACKET_INFO.FRAMEWORK_ROOT .. 'lang/lib/')

local KvpToObject = X.KvpToObject
local bStream = GLOBAL.GAME_PROVIDER == 'remote'
local bClassic = GLOBAL.GAME_BRANCH == 'classic'

local function PickBranch(tData)
	return tData[GLOBAL.GAME_BRANCH] or tData['zhcn']
end

local FORCE_TYPE = (function()
	local FORCE_TYPE = _G.FORCE_TYPE or SetmetaReadonly({
		JIANG_HU  = 0 , -- 江湖
		SHAO_LIN  = 1 , -- 少林
		WAN_HUA   = 2 , -- 万花
		TIAN_CE   = 3 , -- 天策
		CHUN_YANG = 4 , -- 纯阳
		QI_XIU    = 5 , -- 七秀
		WU_DU     = 6 , -- 五毒
		TANG_MEN  = 7 , -- 唐门
		CANG_JIAN = 8 , -- 藏剑
		GAI_BANG  = 9 , -- 丐帮
		MING_JIAO = 10, -- 明教
		CANG_YUN  = 21, -- 苍云
		CHANG_GE  = 22, -- 长歌
		BA_DAO    = 23, -- 霸刀
		PENG_LAI  = 24, -- 蓬莱
		LING_XUE  = 25, -- 凌雪
		YAN_TIAN  = 211, -- 衍天
	})
	local res = {}
	for k, v in X.pairs_c(FORCE_TYPE) do
		if g_tStrings.tForceTitle[v] then
			res[k] = v
		end
	end
	return SetmetaReadonly(res)
end)()

CONSTANT = {
	MENU_DIVIDER = SetmetaReadonly({ bDevide = true }),
	EMPTY_TABLE = SetmetaReadonly({}),
	XML_LINE_BREAKER = GetFormatText('\n'),
	MAX_PLAYER_LEVEL = 50,
	UI_OBJECT = UI_OBJECT or SetmetaReadonly({
		NONE             = -1, -- 空Box
		ITEM             = 0 , -- 身上有的物品。nUiId, dwBox, dwX, nItemVersion, nTabType, nIndex
		SHOP_ITEM        = 1 , -- 商店里面出售的物品 nUiId, dwID, dwShopID, dwIndex
		OTER_PLAYER_ITEM = 2 , -- 其他玩家身上的物品 nUiId, dwBox, dwX, dwPlayerID
		ITEM_ONLY_ID     = 3 , -- 只有一个ID的物品。比如装备链接之类的。nUiId, dwID, nItemVersion, nTabType, nIndex
		ITEM_INFO        = 4 , -- 类型物品 nUiId, nItemVersion, nTabType, nIndex, nCount(书nCount代表dwRecipeID)
		SKILL            = 5 , -- 技能。dwSkillID, dwSkillLevel, dwOwnerID
		CRAFT            = 6 , -- 技艺。dwProfessionID, dwBranchID, dwCraftID
		SKILL_RECIPE     = 7 , -- 配方dwID, dwLevel
		SYS_BTN          = 8 , -- 系统栏快捷方式dwID
		MACRO            = 9 , -- 宏
		MOUNT            = 10, -- 镶嵌
		ENCHANT          = 11, -- 附魔
		NOT_NEED_KNOWN   = 15, -- 不需要知道类型
		PENDANT          = 16, -- 挂件
		PET              = 17, -- 宠物
		MEDAL            = 18, -- 宠物徽章
		BUFF             = 19, -- BUFF
		MONEY            = 20, -- 金钱
		TRAIN            = 21, -- 修为
		EMOTION_ACTION   = 22, -- 动作表情
	}),
	GLOBAL_HEAD = GLOBAL_HEAD or SetmetaReadonly({
		CLIENTPLAYER = 0,
		OTHERPLAYER  = 1,
		NPC          = 2,
		LIFE         = 0,
		GUILD        = 1,
		TITLE        = 2,
		NAME         = 3,
		MARK         = 4,
	}),
	EQUIPMENT_SUB = EQUIPMENT_SUB or SetmetaReadonly({
		MELEE_WEAPON      = 0 , -- 近战武器
		RANGE_WEAPON      = 1 , -- 远程武器
		CHEST             = 2 , -- 上衣
		HELM              = 3 , -- 头部
		AMULET            = 4 , -- 项链
		RING              = 5 , -- 戒指
		WAIST             = 6 , -- 腰带
		PENDANT           = 7 , -- 腰缀
		PANTS             = 8 , -- 裤子
		BOOTS             = 9 , -- 鞋子
		BANGLE            = 10, -- 护臂
		WAIST_EXTEND      = 11, -- 腰部挂件
		PACKAGE           = 12, -- 包裹
		ARROW             = 13, -- 暗器
		BACK_EXTEND       = 14, -- 背部挂件
		HORSE             = 15, -- 坐骑
		BULLET            = 16, -- 弩或陷阱
		FACE_EXTEND       = 17, -- 脸部挂件
		MINI_AVATAR       = 18, -- 小头像
		PET               = 19, -- 跟宠
		L_SHOULDER_EXTEND = 20, -- 左肩挂件
		R_SHOULDER_EXTEND = 21, -- 右肩挂件
		BACK_CLOAK_EXTEND = 22, -- 披风
		TOTAL             = 23, --
	}),
	EQUIPMENT_INVENTORY = EQUIPMENT_INVENTORY or SetmetaReadonly({
		MELEE_WEAPON  = 1 , -- 普通近战武器
		BIG_SWORD     = 2 , -- 重剑
		RANGE_WEAPON  = 3 , -- 远程武器
		CHEST         = 4 , -- 上衣
		HELM          = 5 , -- 头部
		AMULET        = 6 , -- 项链
		LEFT_RING     = 7 , -- 左手戒指
		RIGHT_RING    = 8 , -- 右手戒指
		WAIST         = 9 , -- 腰带
		PENDANT       = 10, -- 腰缀
		PANTS         = 11, -- 裤子
		BOOTS         = 12, -- 鞋子
		BANGLE        = 13, -- 护臂
		PACKAGE1      = 14, -- 扩展背包1
		PACKAGE2      = 15, -- 扩展背包2
		PACKAGE3      = 16, -- 扩展背包3
		PACKAGE4      = 17, -- 扩展背包4
		PACKAGE_MIBAO = 18, -- 绑定安全产品状态下赠送的额外背包格 （ItemList V9新增）
		BANK_PACKAGE1 = 19, -- 仓库扩展背包1
		BANK_PACKAGE2 = 20, -- 仓库扩展背包2
		BANK_PACKAGE3 = 21, -- 仓库扩展背包3
		BANK_PACKAGE4 = 22, -- 仓库扩展背包4
		BANK_PACKAGE5 = 23, -- 仓库扩展背包5
		ARROW         = 24, -- 暗器
		TOTAL         = 25,
	}),
	CHARACTER_OTACTION_TYPE = setmetatable({}, {
		__index = setmetatable(
			{
				ACTION_IDLE            = 0,
				ACTION_SKILL_PREPARE   = 1,
				ACTION_SKILL_CHANNEL   = 2,
				ACTION_RECIPE_PREPARE  = 3,
				ACTION_PICK_PREPARE    = 4,
				ACTION_PICKING         = 5,
				ACTION_ITEM_SKILL      = 6,
				ACTION_CUSTOM_PREPARE  = 7,
				ACTION_CUSTOM_CHANNEL  = 8,
				ACTION_SKILL_HOARD     = 9,
				ANCIENT_ACTION_PREPARE = 1000,
			},
			{ __index = _G.CHARACTER_OTACTION_TYPE }),
		__newindex = function() end,
	}),
	ROLE_TYPE_LABEL = SetmetaReadonly({
		[ROLE_TYPE.STANDARD_MALE  ] = _L['Man'],
		[ROLE_TYPE.STANDARD_FEMALE] = _L['Woman'],
		[ROLE_TYPE.LITTLE_BOY     ] = _L['Boy'],
		[ROLE_TYPE.LITTLE_GIRL    ] = _L['Girl'],
	}),
	FORCE_TYPE = FORCE_TYPE,
	FORCE_TYPE_LABEL = g_tStrings.tForceTitle,
	KUNGFU_TYPE = (function()
		local KUNGFU_TYPE = _G.KUNGFU_TYPE or SetmetaReadonly({
			TIAN_CE     = 1,      -- 天策内功
			WAN_HUA     = 2,      -- 万花内功
			CHUN_YANG   = 3,      -- 纯阳内功
			QI_XIU      = 4,      -- 七秀内功
			SHAO_LIN    = 5,      -- 少林内功
			CANG_JIAN   = 6,      -- 藏剑内功
			GAI_BANG    = 7,      -- 丐帮内功
			MING_JIAO   = 8,      -- 明教内功
			WU_DU       = 9,      -- 五毒内功
			TANG_MEN    = 10,     -- 唐门内功
			CANG_YUN    = 18,     -- 苍云内功
			CHANG_GE    = 19,     -- 长歌内功
			BA_DAO      = 20,     -- 霸刀内功
			PENG_LAI    = 21,     -- 蓬莱内功
			LING_XUE    = 22,     -- 凌雪内功
			YAN_TIAN    = 23,     -- 衍天内功
		})
		local res = {}
		for k, v in X.pairs_c(KUNGFU_TYPE) do
			if g_tStrings.tForceTitle[v] then
				res[k] = v
			end
		end
		return SetmetaReadonly(res)
	end)(),
	PEEK_OTHER_PLAYER_RESPOND = PEEK_OTHER_PLAYER_RESPOND or SetmetaReadonly({
		INVALID             = 0,
		SUCCESS             = 1,
		FAILED              = 2,
		CAN_NOT_FIND_PLAYER = 3,
		TOO_FAR             = 4,
	}),
	MIC_STATE = MIC_STATE or SetmetaReadonly({
		NOT_AVIAL = 1,
		CLOSE_NOT_IN_ROOM = 2,
		CLOSE_IN_ROOM = 3,
		KEY = 4,
		FREE = 5,
	}),
	SPEAKER_STATE = SPEAKER_STATE or SetmetaReadonly({
		OPEN = 1,
		CLOSE = 2,
	}),
	ITEM_QUALITY = SetmetaReadonly({
		GRAY    = 0, -- 灰色
		WHITE   = 1, -- 白色
		GREEN   = 2, -- 绿色
		BLUE    = 3, -- 蓝色
		PURPLE  = 4, -- 紫色
		NACARAT = 5, -- 橙色
		GLODEN  = 6, -- 暗金
	}),
	CRAFT_TYPE = {
		MINING = 1, --采矿
		HERBALISM = 2, -- 神农
		SKINNING = 3, -- 庖丁
		READING = 8, -- 阅读
	},
	MOBA_MAP = {
		[412] = true, -- 列星岛
	},
	STARVE_MAP = {
		[421] = true, -- 浪客行·悬棺裂谷
		[422] = true, -- 浪客行·桑珠草原
		[423] = true, -- 浪客行·东水寨
		[424] = true, -- 浪客行·湘竹溪
		[425] = true, -- 浪客行·荒魂镇
		[433] = true, -- 浪客行·有间客栈
		[434] = true, -- 浪客行·绥梦山
		[435] = true, -- 浪客行·华清宫
		[436] = true, -- 浪客行·枫阳村
		[437] = true, -- 浪客行·荒雪路
		[438] = true, -- 浪客行·古祭坛
		[439] = true, -- 浪客行·雾荧洞
		[440] = true, -- 浪客行·阴风峡
		[441] = true, -- 浪客行·翡翠瑶池
		[442] = true, -- 浪客行·胡杨林道
		[443] = true, -- 浪客行·浮景峰
		[461] = true, -- 浪客行·落樱林
		[527] = true, -- 浪客行·苍离岛
		[528] = true, -- 浪客行·漓水
	},
	-- 相同名字的地图 全部指向同一个ID
	MAP_NAME_FIX = {
		[143] = 147, -- 试炼之地
		[144] = 147, -- 试炼之地
		[145] = 147, -- 试炼之地
		[146] = 147, -- 试炼之地
		[195] = 196, -- 雁门关之役
		[276] = 281, -- 拭剑园
		[278] = 281, -- 拭剑园
		[279] = 281, -- 拭剑园
		[280] = 281, -- 拭剑园
		[296] = 297, -- 龙门绝境
	},
	NPC_NAME = {},
	NPC_NAME_FIX = {
		[58294] = 62347, -- 剑出鸿蒙
	},
	NPC_HIDDEN = {
		[19153] = true, -- 皇宫范围总控
		[27634] = true, -- 秦皇陵安禄山总控
		[56383] = true, -- 通关进度完成表现控制
		[60045] = true, -- 辉天堑铁库牢房的不知道什么东西
	},
	DOODAD_NAME = {},
	DOODAD_NAME_FIX = {
		[3713] = 1, -- 遗体
		[3714] = 1, -- 遗体
	},
	KUNGFU_LIST = (function()
		-- skillid, uitex, frame
		local KUNGFU_LIST = {
			-- MT
			{ dwForceID = FORCE_TYPE.TIAN_CE  , dwID = 10062, nIcon = 632  , szUITex = 'ui/Image/icon/skill_tiance01.UITex'    , nFrame = 0  }, -- 天策 铁牢律
			{ dwForceID = FORCE_TYPE.MING_JIAO, dwID = 10243, nIcon = 3864 , szUITex = 'ui/Image/icon/mingjiao_taolu_7.UITex'  , nFrame = 0  }, -- 明教 明尊琉璃体
			{ dwForceID = FORCE_TYPE.CANG_YUN , dwID = 10389, nIcon = 6315 , szUITex = 'ui/Image/icon/Skill_CangY_33.UITex'    , nFrame = 0  }, -- 苍云 铁骨衣
			{ dwForceID = FORCE_TYPE.SHAO_LIN , dwID = 10002, nIcon = 429  , szUITex = 'ui/Image/icon/skill_shaolin14.UITex'   , nFrame = 0  }, -- 少林 洗髓经
			-- 治疗
			{ dwForceID = FORCE_TYPE.QI_XIU   , dwID = 10080, nIcon = 887  , szUITex = 'ui/Image/icon/skill_qixiu02.UITex'     , nFrame = 0  }, -- 七秀 云裳心经
			{ dwForceID = FORCE_TYPE.WU_DU    , dwID = 10176, nIcon = 2767 , szUITex = 'ui/Image/icon/wudu_neigong_2.UITex'    , nFrame = 0  }, -- 五毒 补天诀
			{ dwForceID = FORCE_TYPE.WAN_HUA  , dwID = 10028, nIcon = 412  , szUITex = 'ui/Image/icon/skill_wanhua23.UITex'    , nFrame = 0  }, -- 万花 离经易道
			{ dwForceID = FORCE_TYPE.CHANG_GE , dwID = 10448, nIcon = 7067 , szUITex = 'ui/Image/icon/skill_0514_23.UITex'     , nFrame = 0  }, -- 长歌 相知
			{ dwForceID = FORCE_TYPE.YAO_ZONG , dwID = 10626, nIcon = 15593, szUITex = 'ui/image/icon/skill_21_9_10_1.UITex '  , nFrame = 0  }, -- 药宗 灵素
			-- 内功
			{ dwForceID = FORCE_TYPE.TANG_MEN , dwID = 10225, nIcon = 3184 , szUITex = 'ui/Image/icon/skill_tangm_20.UITex'    , nFrame = 0  }, -- 唐门 天罗诡道
			{ dwForceID = FORCE_TYPE.QI_XIU   , dwID = 10081, nIcon = 888  , szUITex = 'ui/Image/icon/skill_qixiu03.UITex'     , nFrame = 0  }, -- 七秀 冰心诀
			{ dwForceID = FORCE_TYPE.WU_DU    , dwID = 10175, nIcon = 2766 , szUITex = 'ui/Image/icon/wudu_neigong_1.UITex'    , nFrame = 0  }, -- 五毒 毒经
			{ dwForceID = FORCE_TYPE.MING_JIAO, dwID = 10242, nIcon = 3865 , szUITex = 'ui/Image/icon/mingjiao_taolu_8.UITex'  , nFrame = 0  }, -- 明教 焚影圣诀
			{ dwForceID = FORCE_TYPE.CHUN_YANG, dwID = 10014, nIcon = 627  , szUITex = 'ui/Image/icon/skill_chunyang21.UITex'  , nFrame = 0  }, -- 纯阳 紫霞功
			{ dwForceID = FORCE_TYPE.WAN_HUA  , dwID = 10021, nIcon = 406  , szUITex = 'ui/Image/icon/skill_wanhua17.UITex'    , nFrame = 0  }, -- 万花 花间游
			{ dwForceID = FORCE_TYPE.SHAO_LIN , dwID = 10003, nIcon = 425  , szUITex = 'ui/Image/icon/skill_shaolin10.UITex'   , nFrame = 0  }, -- 少林 易经经
			{ dwForceID = FORCE_TYPE.CHANG_GE , dwID = 10447, nIcon = 7071 , szUITex = 'ui/Image/icon/skill_0514_27.UITex'     , nFrame = 0  }, -- 长歌 莫问
			{ dwForceID = FORCE_TYPE.YAN_TIAN , dwID = 10615, nIcon = 13894, szUITex = 'ui/image/icon/skill_20_9_14_1.uitex'   , nFrame = 0  }, -- 衍天 太玄经
			{ dwForceID = FORCE_TYPE.YAO_ZONG , dwID = 10627, nIcon = 15594, szUITex = 'ui/image/icon/skill_21_9_10_2.UITex '  , nFrame = 0  }, -- 药宗 无方
			-- 外功
			{ dwForceID = FORCE_TYPE.CANG_YUN , dwID = 10390, nIcon = 6314 , szUITex = 'ui/Image/icon/Skill_CangY_32.UITex'    , nFrame = 0  }, -- 苍云 分山劲
			{ dwForceID = FORCE_TYPE.TANG_MEN , dwID = 10224, nIcon = 3165 , szUITex = 'ui/Image/icon/skill_tangm_01.UITex'    , nFrame = 0  }, -- 唐门 惊羽诀
			{ dwForceID = FORCE_TYPE.CANG_JIAN, dwID = 10144, nIcon = 2376 , szUITex = 'ui/Image/icon/cangjian_neigong_1.UITex', nFrame = 0  }, -- 藏剑 问水诀
			{ dwForceID = FORCE_TYPE.CANG_JIAN, dwID = 10145, nIcon = 2377 , szUITex = 'ui/Image/icon/cangjian_neigong_2.UITex', nFrame = 0  }, -- 藏剑 山居剑意
			{ dwForceID = FORCE_TYPE.CHUN_YANG, dwID = 10015, nIcon = 619  , szUITex = 'ui/Image/icon/skill_chunyang13.UITex'  , nFrame = 0  }, -- 纯阳 太虚剑意
			{ dwForceID = FORCE_TYPE.TIAN_CE  , dwID = 10026, nIcon = 633  , szUITex = 'ui/Image/icon/skill_tiance02.UITex'    , nFrame = 0  }, -- 天策 傲血战意
			{ dwForceID = FORCE_TYPE.GAI_BANG , dwID = 10268, nIcon = 4610 , szUITex = 'ui/Image/icon/skill_GB_30.UITex'       , nFrame = 0  }, -- 丐帮 笑尘诀
			{ dwForceID = FORCE_TYPE.BA_DAO   , dwID = 10464, nIcon = 8424 , szUITex = 'ui/Image/icon/daoj_16_8_25_16.UITex'   , nFrame = 0  }, -- 霸刀 北傲诀
			{ dwForceID = FORCE_TYPE.PENG_LAI , dwID = 10533, nIcon = 10709, szUITex = 'ui/image/icon/JNPL_18_10_30_27.uitex'  , nFrame = 0  }, -- 蓬莱 凌海诀
			{ dwForceID = FORCE_TYPE.LING_XUE , dwID = 10585, nIcon = 12128, szUITex = 'ui/image/icon/JNLXG_19_10_21_9.uitex'  , nFrame = 0  }, -- 凌雪 隐龙诀
		}
		local res = {}
		for _, v in ipairs(KUNGFU_LIST) do
			if v.dwForceID and Table_GetSkill(v.dwID) then
				table.insert(res, v)
			end
		end
		return res
	end)(),
	KUNGFU_NAME_ABBREVIATION = setmetatable(X.Clone(_L.KUNGFU_NAME_ABBREVIATION), {
		__index = function(t)
			return _L.KUNGFU_NAME_ABBREVIATION[0]
		end,
		__metatable = true,
	}),
	FORCE_AVATAR = setmetatable(
		KvpToObject({
			{ FORCE_TYPE.JIANG_HU , {'ui\\Image\\PlayerAvatar\\jianghu.tga'       , -2, false} }, -- 江湖
			{ FORCE_TYPE.SHAO_LIN , {'ui\\Image\\PlayerAvatar\\shaolin.tga'       , -2, false} }, -- 少林
			{ FORCE_TYPE.WAN_HUA  , {'ui\\Image\\PlayerAvatar\\wanhua.tga'        , -2, false} }, -- 万花
			{ FORCE_TYPE.TIAN_CE  , {'ui\\Image\\PlayerAvatar\\tiance.tga'        , -2, false} }, -- 天策
			{ FORCE_TYPE.CHUN_YANG, {'ui\\Image\\PlayerAvatar\\chunyang.tga'      , -2, false} }, -- 纯阳
			{ FORCE_TYPE.QI_XIU   , {'ui\\Image\\PlayerAvatar\\qixiu.tga'         , -2, false} }, -- 七秀
			{ FORCE_TYPE.WU_DU    , {'ui\\Image\\PlayerAvatar\\wudu.tga'          , -2, false} }, -- 五毒
			{ FORCE_TYPE.TANG_MEN , {'ui\\Image\\PlayerAvatar\\tangmen.tga'       , -2, false} }, -- 唐门
			{ FORCE_TYPE.CANG_JIAN, {'ui\\Image\\PlayerAvatar\\cangjian.tga'      , -2, false} }, -- 藏剑
			{ FORCE_TYPE.GAI_BANG , {'ui\\Image\\PlayerAvatar\\gaibang.tga'       , -2, false} }, -- 丐帮
			{ FORCE_TYPE.MING_JIAO, {'ui\\Image\\PlayerAvatar\\mingjiao.tga'      , -2, false} }, -- 明教
			{ FORCE_TYPE.CANG_YUN , {'ui\\Image\\PlayerAvatar\\cangyun.tga'       , -2, false} }, -- 苍云
			{ FORCE_TYPE.CHANG_GE , {'ui\\Image\\PlayerAvatar\\changge.tga'       , -2, false} }, -- 长歌
			{ FORCE_TYPE.BA_DAO   , {'ui\\Image\\PlayerAvatar\\badao.tga'         , -2, false} }, -- 霸刀
			{ FORCE_TYPE.PENG_LAI , {'ui\\Image\\PlayerAvatar\\penglai.tga'       , -2, false} }, -- 蓬莱
			{ FORCE_TYPE.LING_XUE , {'ui\\Image\\PlayerAvatar\\lingxuege.tga'     , -2, false} }, -- 凌雪
			{ FORCE_TYPE.YAO_ZONG , {'ui\\Image\\PlayerAvatar\\beitianyaozong.dds', -2, false} }, -- 药宗
		}),
		{
			__index = function(t, k)
				return t[FORCE_TYPE.JIANG_HU]
			end,
			__metatable = true,
		}),
	FORCE_COLOR_FG_DEFAULT = setmetatable(
		KvpToObject({
			{ FORCE_TYPE.JIANG_HU , { 255, 255, 255 } }, -- 江湖
			{ FORCE_TYPE.SHAO_LIN , { 255, 178,  95 } }, -- 少林
			{ FORCE_TYPE.WAN_HUA  , { 196, 152, 255 } }, -- 万花
			{ FORCE_TYPE.TIAN_CE  , { 255, 111,  83 } }, -- 天策
			{ FORCE_TYPE.CHUN_YANG, {  22, 216, 216 } }, -- 纯阳
			{ FORCE_TYPE.QI_XIU   , { 255, 129, 176 } }, -- 七秀
			{ FORCE_TYPE.WU_DU    , {  55, 147, 255 } }, -- 五毒
			{ FORCE_TYPE.TANG_MEN , { 121, 183,  54 } }, -- 唐门
			{ FORCE_TYPE.CANG_JIAN, { 214, 249,  93 } }, -- 藏剑
			{ FORCE_TYPE.GAI_BANG , { 205, 133,  63 } }, -- 丐帮
			{ FORCE_TYPE.MING_JIAO, { 240,  70,  96 } }, -- 明教
			{ FORCE_TYPE.CANG_YUN , bStream and { 255, 143, 80 } or { 180, 60, 0 } }, -- 苍云
			{ FORCE_TYPE.CHANG_GE , { 100, 250, 180 } }, -- 长歌
			{ FORCE_TYPE.BA_DAO   , { 106, 108, 189 } }, -- 霸刀
			{ FORCE_TYPE.PENG_LAI , { 171, 227, 250 } }, -- 蓬莱
			{ FORCE_TYPE.LING_XUE , bStream and { 253, 86, 86 } or { 161,   9,  34 } }, -- 凌雪
			{ FORCE_TYPE.YAN_TIAN , { 166,  83, 251 } }, -- 衍天
			{ FORCE_TYPE.YAO_ZONG , {   0, 172, 153 } }, -- 药宗
		}),
		{
			__index = function(t, k)
				return { 225, 225, 225 }
			end,
			__metatable = true,
		}),
	FORCE_COLOR_BG_DEFAULT = setmetatable(
		KvpToObject({
			{ FORCE_TYPE.JIANG_HU , { 220, 220, 220 } }, -- 江湖
			{ FORCE_TYPE.SHAO_LIN , { 125, 112,  10 } }, -- 少林
			{ FORCE_TYPE.WAN_HUA  , {  47,  14,  70 } }, -- 万花
			{ FORCE_TYPE.TIAN_CE  , { 105,  14,  14 } }, -- 天策
			{ FORCE_TYPE.CHUN_YANG, {   8,  90, 113 } }, -- 纯阳 56,175,255,232
			{ FORCE_TYPE.QI_XIU   , { 162,  74, 129 } }, -- 七秀
			{ FORCE_TYPE.WU_DU    , {   7,  82, 154 } }, -- 五毒
			{ FORCE_TYPE.TANG_MEN , {  75, 113,  40 } }, -- 唐门
			{ FORCE_TYPE.CANG_JIAN, { 148, 152,  27 } }, -- 藏剑
			{ FORCE_TYPE.GAI_BANG , { 159, 102,  37 } }, -- 丐帮
			{ FORCE_TYPE.MING_JIAO, { 145,  80,  17 } }, -- 明教
			{ FORCE_TYPE.CANG_YUN , { 157,  47,   2 } }, -- 苍云
			{ FORCE_TYPE.CHANG_GE , {  31, 120, 103 } }, -- 长歌
			{ FORCE_TYPE.BA_DAO   , {  49,  39, 110 } }, -- 霸刀
			{ FORCE_TYPE.PENG_LAI , {  93,  97, 126 } }, -- 蓬莱
			{ FORCE_TYPE.LING_XUE , { 161,   9,  34 } }, -- 凌雪
			{ FORCE_TYPE.YAN_TIAN , {  96,  45, 148 } }, -- 衍天
			{ FORCE_TYPE.YAO_ZONG , {  10,  81,  87 } }, -- 药宗
		}),
		{
			__index = function(t, k)
				return { 200, 200, 200 } -- NPC 以及未知门派
			end,
			__metatable = true,
		}),
	CAMP_COLOR_FG_DEFAULT = setmetatable(
		KvpToObject({
			{ CAMP.NEUTRAL, { 255, 255, 255 } }, -- 中立
			{ CAMP.GOOD   , {  60, 128, 220 } }, -- 浩气盟
			{ CAMP.EVIL   , bStream and { 255, 63, 63 } or { 160, 30, 30 } }, -- 恶人谷
		}),
		{
			__index = function(t, k)
				return { 225, 225, 225 }
			end,
			__metatable = true,
		}),
	CAMP_COLOR_BG_DEFAULT = setmetatable(
		KvpToObject({
			{ CAMP.NEUTRAL, { 255, 255, 255 } }, -- 中立
			{ CAMP.GOOD   , {  60, 128, 220 } }, -- 浩气盟
			{ CAMP.EVIL   , { 160,  30,  30 } }, -- 恶人谷
		}),
		{
			__index = function(t, k)
				return { 225, 225, 225 }
			end,
			__metatable = true,
		}),
	MSG_THEME = SetmetaReadonly({
		NORMAL = 0,
		ERROR = 1,
		WARNING = 2,
		SUCCESS = 3,
	}),
	QUEST_INFO = { -- 任务信息 {任务ID, 接任务NPC模板ID}
		BIG_WARS = PickBranch({
			classic = {
				-- 70级
				{5116, 869}, -- 赏金·英雄三才阵
				-- {5117, 869}, -- 无效任务名称
				{5118, 869}, -- 赏金·英雄天工坊
				{5119, 869}, -- 赏金·英雄空雾峰
				{5120, 869}, -- 赏金·英雄无盐岛
				{5121, 869}, -- 赏金·英雄灵霄峡
			},
			remake = {
				-- 95级
				-- {14765, 869}, -- 大战！英雄微山书院！
				-- {14766, 869}, -- 大战！英雄天泣林！
				-- {14767, 869}, -- 大战！英雄梵空禅院！
				-- {14768, 869}, -- 大战！英雄阴山圣泉！
				-- {14769, 869}, -- 大战！英雄引仙水榭！
				-- 95级后
				-- {17816, 869}, -- 大战！英雄稻香秘事！
				-- {17817, 869}, -- 大战！英雄银雾湖！
				-- {17818, 869}, -- 大战！英雄刀轮海厅！
				-- {17819, 869}, -- 大战！英雄夕颜阁！
				-- {17820, 869}, -- 大战！英雄白帝水宫！
				-- 100级
				-- {19191, 869}, -- 大战！英雄九辩馆！
				-- {19192, 869}, -- 大战！英雄泥兰洞天！
				-- {19195, 869}, -- 大战！英雄镜泊糊！
				-- {19196, 869}, -- 大战！英雄大衍盘丝洞！
				-- {19197, 869}, -- 大战！英雄迷渊岛！
				-- {21570, 869}, -- 大战！英雄玄鹤别院！
				-- {21572, 869}, -- 大战！英雄周天屿！
				-- 110级
				{22939, 869}, -- 大战！英雄剑冢惊变！
				{22941, 869}, -- 大战！英雄梧桐山庄！
				{22942, 869}, -- 大战！英雄月落三星！
				{22950, 869}, -- 大战！英雄罗汉门！
				{22951, 869}, -- 大战！英雄梦入集真岛！
			},
		}),
		TEAHOUSE_ROUTINE = PickBranch({
			classic = {
				-- 70级
				{8656, 101195}, -- 江湖烟雨任平生
			},
			remake = {
				-- 90级
				-- {11115}, -- 乱世烽烟江湖行
				-- 95级
				-- {14246, 45009}, -- 快马江湖杯中茶
				-- 100级
				-- {19514, 63734}, -- 沧海云帆闻茶香
				-- 110级
				{22700, 101195}, -- 江湖烟雨任平生
			},
		}),
		PUBLIC_ROUTINE = PickBranch({
			remake = {
				{14831, 869}, -- 江湖道远侠义天下
			},
		}),
		ROOKIE_ROUTINE = PickBranch({
			remake = {
				{21433, 67083},
			},
		}),
		CAMP_CRYSTAL_SCRAMBLE = PickBranch({
			remake = {
				[CAMP.GOOD] = {
					-- {14727, 46968}, -- 戈壁晶矿引烽烟
					-- {14729, 46968}, -- 戈壁晶矿引烽烟
					-- {14893, 62002}, -- 浩气盟！木兰洲上烽烟起
					-- {18904, 62002}, -- 道源蓝晶起波涛
					-- {19200, 62002}, -- 道源蓝晶起波涛
					-- {19310, 62002}, -- 道源蓝晶起波涛
					-- {19719, 62002}, -- 经首道源寻物资
					-- 100级后
					-- {20306, 67195}, -- 木兰洲上烽烟起
					-- {20307, 67195}, -- 木兰洲上烽烟起
					-- {20308, 67195}, -- 木兰洲上烽烟起
					-- 110级
					{22195, 100967}, -- 西子湖畔危机潜
					{22196, 100967}, -- 西子湖畔危机潜
					{22197, 100967}, -- 西子湖畔危机潜
					{22680, 67195}, -- 观澜泽畔夺神兵
				},
				[CAMP.EVIL] = {
					-- {14728, 46969}, -- 戈壁晶矿引烽烟
					-- {14730, 46969}, -- 戈壁晶矿引烽烟
					-- {14894, 62039}, -- 恶人谷！木兰洲上烽烟起
					-- {18936, 62039}, -- 道源蓝晶起波涛
					-- {19201, 62039}, -- 道源蓝晶起波涛
					-- {19311, 62039}, -- 道源蓝晶起波涛
					-- {19720, 62039}, -- 经首道源寻物资
					-- 100级后
					-- {20309, 67196}, -- 木兰洲上烽烟起
					-- {20310, 67196}, -- 木兰洲上烽烟起
					-- {20311, 67196}, -- 木兰洲上烽烟起
					-- 110级
					{22198, 100961}, -- 西子湖畔危机潜
					{22199, 100961}, -- 西子湖畔危机潜
					{22200, 100961}, -- 西子湖畔危机潜
					{22679, 67196}, -- 观澜泽畔夺神兵
				},
			},
		}),
		CAMP_STRONGHOLD_TRADE = PickBranch({
			remake = {
				[CAMP.GOOD] = {
					{11864, 36388}, -- 据点贸易！浩气盟
				},
				[CAMP.EVIL] = {
					{11991, 36387}, -- 据点贸易！恶人谷
				},
			},
		}),
		DRAGON_GATE_DESPAIR = {
			{17895, 59149},
		},
		LEXUS_REALITY = {
			{20220, 64489},
		},
		LIDU_GHOST_TOWN = {
			{18317, 64489},
		},
		FORCE_ROUTINE = KvpToObject({
			{ FORCE_TYPE.TIAN_CE  , {{8206, 16747}, {11254, 16747}, {11255, 16747}} }, -- 天策
			{ FORCE_TYPE.CHUN_YANG, {{8347, 16747}, {8398, 16747}} }, -- 纯阳
			{ FORCE_TYPE.WAN_HUA  , {{8348, 16747}, {8399, 16747}, {22842, 16747}, {22929, 16747}} }, -- 万花
			{ FORCE_TYPE.SHAO_LIN , {{8349, 16747}, {8400, 16747}, {22851, 16747}, {22930, 16747}} }, -- 少林
			{ FORCE_TYPE.QI_XIU   , {{8350, 16747}, {8401, 16747}, {22757, 16747}, {22758, 16747}} }, -- 七秀
			{ FORCE_TYPE.CANG_JIAN, {{8351, 16747}, {8402, 16747}, {22766, 16747}, {22767, 16747}} }, -- 藏剑
			{ FORCE_TYPE.WU_DU    , {{8352, 16747}, {8403, 16747}} }, -- 五毒
			{ FORCE_TYPE.TANG_MEN , {{8353, 16747}, {8404, 16747}} }, -- 唐门
			{ FORCE_TYPE.MING_JIAO, {{9796, 16747}, {9797, 16747}} }, -- 明教
			{ FORCE_TYPE.GAI_BANG , {{11245, 16747}, {11246, 16747}} }, -- 丐帮
			{ FORCE_TYPE.CANG_YUN , {{12701, 16747}, {12702, 16747}} }, -- 苍云
			{ FORCE_TYPE.CHANG_GE , {{14731, 16747}, {14732, 16747}} }, -- 长歌
			{ FORCE_TYPE.BA_DAO   , {{16205, 16747}, {16206, 16747}} }, -- 霸刀
			{ FORCE_TYPE.PENG_LAI , {{19225, 16747}, {19226, 16747}} }, -- 蓬莱
			{ FORCE_TYPE.LING_XUE , {{21067, 16747}, {21068, 16747}} }, -- 凌雪
			{ FORCE_TYPE.YAN_TIAN , {{22775, 16747}, {22776, 16747}} }, -- 衍天
		}),
		PICKING_FAIRY_GRASS = {{8332, 16747}},
		FIND_DRAGON_VEINS = {{13600, 16747}},
		SNEAK_ROUTINE = {{7669, 16747}},
		ILLUSTRATION_ROUTINE = {{8440, 15675}},
	},
	BUFF_INFO = {
		EXAM_SHENG = {{10936, 0}},
		EXAM_HUI = {{4125, 0}},
	},
	SKILL_TYPE = {
		[15054] = {
			[25] = 'HEAL', -- 梅花三弄
		},
	},
	MINI_MAP_POINT = {
		QUEST_REGION    = 1,
		TEAMMATE        = 2,
		SPARKING        = 3,
		DEATH           = 4,
		QUEST_NPC       = 5,
		DOODAD          = 6,
		MAP_MARK        = 7,
		FUNCTION_NPC    = 8,
		RED_NAME        = 9,
		NEW_PQ	        = 10,
		SPRINT_POINT    = 11,
		FAKE_FELLOW_PET = 12,
	},
	HOMELAND_RESULT_CODE = _G.HOMELAND_RESULT_CODE or {
		APPLY_COMMUNITY_INFO = 503,
	},
	FLOWERS_UIID = {
		[163810] = true, -- 黑玫瑰
		[163811] = true, -- 蓝玫瑰
		[163812] = true, -- 绿玫瑰
		[163813] = true, -- 黄玫瑰
		[163814] = true, -- 粉玫瑰
		[163815] = true, -- 红玫瑰
		[163816] = true, -- 紫玫瑰
		[163817] = true, -- 白玫瑰
		[163818] = true, -- 混色玫瑰
		[163819] = true, -- 橙玫瑰
		[163820] = true, -- 粉百合
		[163821] = true, -- 橙百合
		[163822] = true, -- 白百合
		[163823] = true, -- 黄百合
		[163824] = true, -- 绿百合
		[163825] = true, -- 蓝色绣球花
		[163826] = true, -- 粉色绣球花
		[163827] = true, -- 红色绣球花
		[163828] = true, -- 紫色绣球花
		[163829] = true, -- 白色绣球花
		[163830] = true, -- 黄色绣球花
		[163831] = true, -- 粉色郁金香
		[163832] = true, -- 混色郁金香
		[163833] = true, -- 红色郁金香
		[163834] = true, -- 白色郁金香
		[163835] = true, -- 金色郁金香
		[163836] = true, -- 蓝锦牵牛
		[163837] = true, -- 绯锦牵牛
		[163838] = true, -- 红锦牵牛
		[163839] = true, -- 紫锦牵牛
		[163840] = true, -- 黄锦牵牛
		[163841] = true, -- 荧光菌·蓝
		[163842] = true, -- 荧光菌·红
		[163843] = true, -- 荧光菌·紫
		[163844] = true, -- 荧光菌·白
		[163845] = true, -- 荧光菌·黄
		[250069] = true, -- 羽扇豆花·白
		[250070] = true, -- 羽扇豆花·红
		[250071] = true, -- 羽扇豆花·紫
		[250072] = true, -- 羽扇豆花·黄
		[250073] = true, -- 羽扇豆花·粉
		[250074] = true, -- 羽扇豆花·蓝
		[250075] = true, -- 羽扇豆花·蓝白
		[250076] = true, -- 羽扇豆花·黄粉
		[250510] = true, -- 白葫芦
		[250512] = true, -- 红葫芦
		[250513] = true, -- 橙葫芦
		[250514] = true, -- 黄葫芦
		[250515] = true, -- 绿葫芦
		[250516] = true, -- 青葫芦
		[250517] = true, -- 蓝葫芦
		[250518] = true, -- 紫葫芦
		[250519] = true, -- 普通麦子
		[250520] = true, -- 黑麦
		[250521] = true, -- 绿麦
		[250522] = true, -- 紫麦
		[250523] = true, -- 普通青菜
		[250524] = true, -- 紫冠青菜
		[250525] = true, -- 芜菁·白
		[250526] = true, -- 芜菁·青白
		[250527] = true, -- 芜菁·紫红
		[250528] = true, -- 嫩黄瓜
		[250529] = true, -- 老黄瓜
	},
	PLAYER_TALK_CHANNEL_TO_MSG_TYPE = KvpToObject({
		{ PLAYER_TALK_CHANNEL.WHISPER          , 'MSG_WHISPER'           },
		{ PLAYER_TALK_CHANNEL.NEARBY           , 'MSG_NORMAL'            },
		{ PLAYER_TALK_CHANNEL.TEAM             , 'MSG_PARTY'             },
		{ PLAYER_TALK_CHANNEL.TONG             , 'MSG_GUILD'             },
		{ PLAYER_TALK_CHANNEL.TONG_ALLIANCE    , 'MSG_GUILD_ALLIANCE'    },
		{ PLAYER_TALK_CHANNEL.TONG_SYS         , 'MSG_GUILD'             },
		{ PLAYER_TALK_CHANNEL.WORLD            , 'MSG_WORLD'             },
		{ PLAYER_TALK_CHANNEL.FORCE            , 'MSG_SCHOOL'            },
		{ PLAYER_TALK_CHANNEL.CAMP             , 'MSG_CAMP'              },
		{ PLAYER_TALK_CHANNEL.FRIENDS          , 'MSG_FRIEND'            },
		{ PLAYER_TALK_CHANNEL.RAID             , 'MSG_TEAM'              },
		{ PLAYER_TALK_CHANNEL.SENCE            , 'MSG_MAP'               },
		{ PLAYER_TALK_CHANNEL.BATTLE_FIELD     , 'MSG_BATTLE_FILED'      },
		{ PLAYER_TALK_CHANNEL.LOCAL_SYS        , 'MSG_SYS'               },
		{ PLAYER_TALK_CHANNEL.GM_MESSAGE       , 'MSG_SYS'               },
		{ PLAYER_TALK_CHANNEL.NPC_WHISPER      , 'MSG_NPC_WHISPER'       },
		{ PLAYER_TALK_CHANNEL.NPC_SAY_TO       , 'MSG_NPC_WHISPER'       },
		{ PLAYER_TALK_CHANNEL.NPC_NEARBY       , 'MSG_NPC_NEARBY'        },
		{ PLAYER_TALK_CHANNEL.NPC_PARTY        , 'MSG_NPC_PARTY'         },
		{ PLAYER_TALK_CHANNEL.NPC_SENCE        , 'MSG_NPC_YELL'          },
		{ PLAYER_TALK_CHANNEL.FACE             , 'MSG_FACE'              },
		{ PLAYER_TALK_CHANNEL.NPC_FACE         , 'MSG_NPC_FACE'          },
		{ PLAYER_TALK_CHANNEL.NPC_SAY_TO_CAMP  , 'MSG_CAMP'              },
		{ PLAYER_TALK_CHANNEL.IDENTITY         , 'MSG_IDENTITY'          },
		{ PLAYER_TALK_CHANNEL.BULLET_SCREEN    , 'MSG_JJC_BULLET_SCREEN' },
		{ PLAYER_TALK_CHANNEL.BATTLE_FIELD_SIDE, 'MSG_BATTLE_FIELD_SIDE' },
		{ PLAYER_TALK_CHANNEL.STORY_NPC        , 'MSG_STORY_NPC'         },
		{ PLAYER_TALK_CHANNEL.STORY_NPC_YELL   , 'MSG_STORY_NPC'         },
		{ PLAYER_TALK_CHANNEL.STORY_NPC_WHISPER, 'MSG_STORY_NPC'         },
		{ PLAYER_TALK_CHANNEL.STORY_NPC_YELL_TO, 'MSG_STORY_NPC'         },
		{ PLAYER_TALK_CHANNEL.STORY_PLAYER     , 'MSG_STORY_PLAYER'      },
	}),
	MSG_TYPE_MENU = {
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
	},
	INVENTORY_INDEX = INVENTORY_INDEX,
	INVENTORY_EQUIP_LIST = {
		INVENTORY_INDEX.EQUIP,
		INVENTORY_INDEX.EQUIP_BACKUP1,
		INVENTORY_INDEX.EQUIP_BACKUP2,
		X.IIf(bClassic, nil, INVENTORY_INDEX.EQUIP_BACKUP3),
	},
	INVENTORY_PACKAGE_LIST = {
		INVENTORY_INDEX.PACKAGE,
		INVENTORY_INDEX.PACKAGE1,
		INVENTORY_INDEX.PACKAGE2,
		INVENTORY_INDEX.PACKAGE3,
		INVENTORY_INDEX.PACKAGE4,
		INVENTORY_INDEX.PACKAGE_MIBAO,
	},
	INVENTORY_LIMITED_PACKAGE_LIST = {
		INVENTORY_INDEX.LIMITED_PACKAGE,
	},
	INVENTORY_BANK_LIST = {
		INVENTORY_INDEX.BANK,
		INVENTORY_INDEX.BANK_PACKAGE1,
		INVENTORY_INDEX.BANK_PACKAGE2,
		INVENTORY_INDEX.BANK_PACKAGE3,
		INVENTORY_INDEX.BANK_PACKAGE4,
		INVENTORY_INDEX.BANK_PACKAGE5,
	},
	INVENTORY_GUILD_BANK = INVENTORY_GUILD_BANK or INVENTORY_INDEX.TOTAL + 1, --帮会仓库界面虚拟一个背包位置
	INVENTORY_GUILD_PAGE_SIZE = INVENTORY_GUILD_PAGE_SIZE or 100,
	INVENTORY_GUILD_PAGE_BOX_COUNT = 98,
	AUCTION_ITEM_LIST_TYPE = _G.AUCTION_ITEM_LIST_TYPE or SetmetaReadonly({
		NORMAL_LOOK_UP = 0,
		PRICE_LOOK_UP  = 1,
		DETAIL_LOOK_UP = 2,
		SELL_LOOK_UP   = 3,
		AVG_LOOK_UP    = 4,
	}),
}

-- 更新最高玩家等级数据
RegisterEvent('PLAYER_ENTER_SCENE', function()
	CONSTANT.MAX_PLAYER_LEVEL = math.max(
		CONSTANT.MAX_PLAYER_LEVEL,
		GetClientPlayer().nMaxLevel
	)
end)

X.CONSTANT = setmetatable({}, { __index = CONSTANT, __newindex = function() end })
