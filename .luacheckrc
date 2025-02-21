ignore = {".*"}
max_line_length	= 150

globals = {
	"MY",
	"LM",
	"this",
	"arg0",
	"arg1",
	"arg2",
	"arg3",
	"arg4",
	"arg5",
	"arg6",
	"arg7",
	"arg8",
	"arg9",
	"arg10",
	"arg11",

	"WND_BASIC_STATUS",
	"ITEM_BASIC_STATUS",
	"WNDSIDE",
	"ALW",
	"ALIGNMENT",
	"ITEM_POSITION",
	"CURSOR",
	"MOVIE",
	"SOUND",
	"LOAD_LOGIN_REASON",
	"IMAGE",
	"FILE_OPEN_MODE",
	"ANIMATE",
	"D3DPT",
	"GEOMETRY_TYPE",
	"ANI_ACTION",
	"ADDON_STATUS",
	"BOX_STATE",
	"ITEM_EVENT",
	"SQLITE3",
	"UNQLITE",
	"BUTTON_STATUS",
	"BUTTON_RUN_STATUS",
	"CHECKBOX_STATUS",
	"CHECKBOX_RUN_STATUS",
	"CODE_PAGE",
	"WNDEVENT_FIRETYPE",
	"YG_DIRECTION",
	"YG_FLEX_DIRECTION",
	"YG_FLEX_WRAP",
	"YG_JUSTIFY",
	"YG_ALIGN",
	"GESTURE_STATE",
	"GLOBAL",
	"PATROL",
	"TARGET",
	"ATTRIBUTE_TYPE",
	"ATTRIBUTE_EFFECT_MODE",
	"ITEM_TABLE_TYPE",
	"SKILL_EFFECT_TYPE",
	"SKILL_CAST_EFFECT_TYPE",
	"ADD_ITEM_RESULT_CODE",
	"DIAMOND_RESULT_CODE",
	"BREAK_EQUIP_RESULT_CODE",
	"RESET_EQUIP_MAGIC_RESULT_CODE",
	"CHANGE_EQUIP_MAGIC_RESULT_CODE",
	"SKILL_RESULT_CODE",
	"SKILL_FUNCTION_TYPE",
	"SKILL_KIND_TYPE",
	"SKILL_RESULT_TYPE",
	"SKILL_COMPARE_FLAG",
	"BUFF_COMPARE_FLAG",
	"ROLE_TYPE",
	"QUEST_STATE",
	"QUEST_RESULT",
	"QUEST_EVENT_TYPE",
	"QUEST_DIFFICULTY_LEVEL",
	"ROLL_ITEM_CHOICE",
	"QUEST_COUNT",
	"ALL_CRAFT_TYPE",
	"MINI_RADAR_TYPE",
	"INVENTORY_INDEX",
	"CRAFT_RESULT_CODE",
	"CHARACTER_ACTION_TYPE",
	"CHARACTER_OTACTION_TYPE",
	"ITEM_GENRE",
	"EQUIPMENT_SUB",
	"WEAPON_DETAIL",
	"BULLET_DETAIL",
	"COMPARE",
	"DIAMOND_SLOT_CHANGE_SUB_TYPE",
	"FULL_LEVEL",
	"MATERIAL_SUB_TYPE",
	"DOMESTICATE_CUB_SUB_TYPE",
	"DOMESTICATE_FODDER_SUB_TYPE",
	"INVENTORY_TYPE",
	"ITEM_BIND",
	"ITEM_IGNORE_BIND_TYPE",
	"ITEM_USE_TARGET_TYPE",
	"BOX_SUB_TYPE",
	"QUANTITY_LIMIT_ITEM_SUB_TYPE",
	"EQUIPMENT_INVENTORY",
	"EQUIPMENT_REPRESENT",
	"ITEM_RESULT_CODE",
	"USE_ITEM_RESULT_CODE",
	"SKILL_CAST_MODE",
	"PARTY_NOTIFY_CODE",
	"TEAM_AUTHORITY_TYPE",
	"PARTY_LOOT_MODE",
	"DOODAD_KIND",
	"CHARACTER_KIND",
	"RELATION_TYPE",
	"CAMP",
	"CLEAR_TITLE_POINT_REASON",
	"SHOP_SYSTEM_RESPOND_CODE",
	"TRADING_RESPOND_CODE",
	"LOOT_ITEM_RESULT_CODE",
	"LOGIN",
	"NPC_SPECIES_TYPE",
	"MOVE_STATE",
	"REVIVE_TYPE",
	"PLAYER_TALK_CHANNEL",
	"ANNOUNCE_SHOW_TYPE",
	"PLAYER_TALK_ERROR",
	"MAIL_RESPOND_CODE",
	"PLAYER_FELLOWSHIP_RESPOND",
	"PLAYER_PREPARE_FELLOWSHIP_RESULT",
	"DATE_FORMAT",
	"SKILL_ATTACK_WEAK_POS",
	"ERROR_CODE_TYPE",
	"PEEK_OTHER_PLAYER_RESPOND",
	"PK_STATE",
	"PK_RESPOND",
	"PK_ENDCODE",
	"AI_ACTION",
	"AI_EVENT",
	"AI_THREAT_TYPE",
	"AI_TARGET_TYPE",
	"AI_FILTER_TYPE",
	"PREEMPTIVE_ATTACK",
	"FAKE_NAME_STATE",
	"SWITCH_MAP",
	"BATTLE_FIELD_NOTIFY_TYPE",
	"TONG_BATTLE_FIELD_NOTIFY_TYPE",
	"ARENA_NOTIFY_TYPE",
	"CORPS_OPERATION_TYPE",
	"BATTLE_FIELD_RESULT_CODE",
	"TONG_BATTLE_FIELD_RESULT_CODE",
	"ARENA_RESULT_CODE",
	"CORPS_OPERATION_RESULT_CODE",
	"SHARE_QUEST",
	"SKILL_RECIPE_RESULT_CODE",
	"ARENA_TYPE",
	"NEW_CAMP_FIGHT_VALUE_TYPE",
	"BANISH_CODE",
	"ITEM_INFO_TYPE",
	"PQ_STATISTICS_INDEX",
	"TONG_OPERATION_INDEX",
	"TONG_EVENT_CODE",
	"TONG_HISTORY_TYPE",
	"TONG_HISTORY_JOIN_OR_LEAVE_DESC",
	"TONG_STATE",
	"AUCTION_SALE_STATE",
	"AUCTION_ORDER_TYPE",
	"AUCTION_RESPOND_CODE",
	"AUCTION_MESSAGE_CODE",
	"GAME_CARD_TYPE",
	"GAME_CARD_RESPOND_CODE",
	"GAME_CARD_ORDER_TYPE",
	"CAMP_RESULT_CODE",
	"CHARGE_LIMIT_CODE",
	"REMOTE_PLAYER_LIMIT_CODE",
	"AUCTION_COOL_DOWN_ERROR_CODE",
	"TONG_CHANGE_REASON",
	"MAP_TYPE",
	"MAP_CAMP_TYPE",
	"ACHIEVEMENT_ANNOUNCE_TYPE",
	"DESIGNATION_ANNOUNCE_TYPE",
	"DESIGNATION_NOTIFY_CODE",
	"ENCHANT_RESULT_CODE",
	"ENCHANT_INDEX",
	"HORSE_DETAIL_TYPE",
	"HORSE_ENCHANT_DETAIL_TYPE",
	"MAIL_TYPE",
	"MENTOR_RECORD_STATE",
	"DIRECT_MENTOR_RECORD_STATE",
	"CHARACTER_GENDER",
	"ITEM_EXIST_TYPE",
	"CHARGE_MODE",
	"PQ_OWNER_TYPE",
	"DESIGNATION_PREFIX_TYPE",
	"ACTIVITY_STATE",
	"CAMP_NPC_TYPE",
	"SYSTEM_PUNISH_RESULT_CODE",
	"KICK_ACCOUNT_REASON_CODE",
	"SKILL_RECIPE_TYPE",
	"TONG_DIPLOMACY_RELATION_TYPE",
	"TONG_DIPLOMACY_CW_SCRIPT_TYPE",
	"TONG_DIPLOMACY_ALLY_SCRIPT_TYPE",
	"TONG_DIPLOMACY_RELATION_RESULT_CODE",
	"TONG_PUBLICITY_RESULT_CODE",
	"TONG_APPLY_JOININ_RESULT_CODE",
	"TONG_TECH_NODE_TAG_TYPE",
	"HAIR_SHOP_RESPOND_CODE",
	"SAFE_LOCK_EFFECT_TYPE",
	"HAIR_CHANGE_RESPOND_CODE",
	"HAIR_STYLE",
	"EXTERIOR_BUY_RESPOND_CODE",
	"EXTERIOR_APPLY_RESPOND_CODE",
	"EXTERIOR_COLLECT_RESULT_CODE",
	"EXTERIOR_PAY_TYPE",
	"EXTERIOR_TIME_TYPE",
	"EXTERIOR_GENRE",
	"EXTERIOR_BUY_SOURCE",
	"EXTERIOR_COLLECTION_EXTERIOR_TYPE",
	"EXTERIOR_COLLECTION_METHORD",
	"EXTERIOR_INDEX_TYPE",
	"EXTERIOR_APPLY_FLAG",
	"WEAPON_EXTERIOR_BOX_INDEX_TYPE",
	"QUEST_TEAM_REQUIRE_MODE",
	"FOLLOW_RESULT_CODE",
	"FOLLOW_STOP_TYPE",
	"FOLLOW_TYPE",
	"INVITE_FOLLOW_TYPE",
	"DOMESTICATE_OPERATION_RESULT_CODE",
	"BUY_CUB_PACKAGE_RESULT_CODE",
	"PASSPOD_MODE",
	"REWARDS_SHOP_RESPOND_CODE",
	"REAL_TIME_RANK_LIST_TYPE",
	"WANTED_MAN_RESULT_CODE",
	"COIN_BUY_RESPOND_CODE",
	"RESET_MAP_RESULT",
	"RESTORE_ITEM_RESULT",
	"PEER_PAY_TYPE",
	"PEER_PAY_STATE",
	"PEER_PAY_RESULT_CODE",
	"PEER_PAY_PANEL_TYPE",
	"COIN_SHOP_PAY_TYPE",
	"COIN_SHOP_TIME_LIMIT_TYPE",
	"COIN_SHOP_GOODS_TYPE",
	"COIN_SHOP_OWN_TYPE",
	"COIN_SHOP_DISCOUNT_TYPE",
	"COIN_SHOP_FAULT_REASON",
	"COIN_SHOP_ERROR_CODE",
	"FACE_LIFT_BONE_TYPE",
	"FACE_LIFT_DECAL_TYPE",
	"FACE_LIFT_ERROR_CODE",
	"SELECT_TALENT_RESULT",
	"VERIFY_CAPTCHA_RET_CODE",
	"ACCOUNT_SECURITY_STATE",
	"ACCOUNT_SECURITY_SEND_SMS_RET_CODE",
	"TEAM_BIDDING_START_RESULT",
	"TEAM_BIDDING_END_RESULT",
	"TEAM_BIDDING_RISE_MONEY_RESULT",
	"CUSTOM_RECORDING_TYPE",
	"VIP_TYPE",
	"BUY_VIP_RESULT",
	"SNS_BIND_TYPE",
	"WEIBO_TYPE",
	"WEIBO_NOTIFY_CODE",
	"DIAMOND_SLOT_CHANGE_RESULT_CODE",
	"TEAM_PUSH_NOTIFY_CODE",
	"GIFT_CURRENCY_TYPE",
	"GIFT_GET_LIMIT",
	"CREATE_GIFT_ERROR_CODE",
	"GET_GIFT_ERROR_CODE",
	"RELEASE_GIFT_ERROR_CODE",
	"EMOTION_ACTION_RESULT",
	"BUY_ITEM_ORDER_STATE",
	"BUY_ITEM_ORDER_NOTIFY_CODE",
	"PLAYER_IDENTITY_TYPE",
	"SKILL_BULLET_TYPE",
	"SCENE_SFX_ERROR_CODE",
	"SELECTABLE_TYPE",
	"ADVANCED_DYNAMIC_OBSTACLE_TYPE",
	"PLAYER_ARENA_TYPE",
	"COIN_SHOP_GOODS_SOURCE",
	"COIN_SHOP_LOGIC_BOX_INDEX",
	"COIN_SHOP_PRESET_ERROR_CODE",
	"COIN_SHOP_CART_ERROR_CODE",
	"BULLETSCREEN_SHOWMODE_TYPE",
	"REAL_NAME_LIMIT_CODE",
	"REAL_NAME_VERIFY_CODE",
	"FREEZE_PLAYER_CODE",
	"TRADE_MALL_CODE",
	"SERVER_TYPE",
	"MAP_QUEUE_TYPE",
	"FORCE_FIGHT_PLAYER_TYPE",
	"BF_MAP_ROLE_INFO_TYPE",
	"PEEK_OTHER_PLAYER_TYPE",
	"RELATIONSHIP_TYPE",
	"RELATIONSHIP_EVENT_CODE",
	"RELATIONSHIP_FINISH_STATE",
	"ASSIST_NEWBIE_TYPE",
	"ASSIST_NEWBIE_FAVOR_LEVEL_TYPE",
	"ASSIST_NEWBIE_EVENT_CODE",
	"ASP_RESULT_CODE",
	"ACCOUNT_SHARED_PACKAGE_SOURCE",
	"ACCOUNT_SHARED_PACKAGE_BOX",
	"CHAT_GVOICE_TOKEN_TYPE",
	"BATTLEFIELD_RANK_TYPE",
	"BF_ROLE_DATA_TYPE",
	"COIN_SHOP_RECOMMENDATION_DATA_TYPE",
	"COIN_SHOP_RECOMMENDATION_ERROR_CODE",
	"DUNGEON_SERVER_EVENT_CODE",
	"KPENDENT_TYPE",
	"QUEST_REWARD_LOOKUP_TYPE",
	"QUEST_REWARD_STATE",
	"QUEST_REWARD_RESPOND_CODE",
	"COIN_SHOP_GROUPON_MEMBER_STATE",
	"COIN_SHOP_GROUPON_STATE",
	"COIN_SHOP_GROUPON_ERROR_CODE",
	"CUSTOM_RECORDING_PLAYER_DATA_TYPE",
	"REMOTE_DATA_MANUAL_TYPE",
	"DOMESTICATE_EMOTION_TYPE",
	"QUIT_MAP_QUEUE_CODE",
	"UNION_ACCOUNT_CHANNEL",
	"BIDDING_INFO_STATE",
	"BIDDING_OPERATION_TYPE",
	"BIDDING_INFO_TYPE",
	"STREAMING_POST_EVENT_TYPE",
	"STREAMING_NETWORK_TYPE",
	"PSIMAGE_FILTER",
	"CHARACTER_LIGHT",
	"CHARACTER_LIGHT_BINDING",
	"TRANSFORM",
	"TARGET_EX",
	"CTCT",
	"TIME_PRIORITY",
	"WEBURL_TYPE",
	"COLOR_DIAMOND_MAX_LEVEL",
	"MAIN_SCENE_DOF_DIST_MIN",
	"COINSHOP_RECOMMEND_SOURCE",
	"COLOR_DIAMOND_MAX_STRENGTHEN_LEVEL",
	"FACELIFT_INDEX_START",
	"REWARDS_CLASS",
	"CASTING_MIN_LEVEL",
	"EXTERIOR_SUB_NUMBER",
	"RIDE_BOX_COUNT",
	"MAX_BAG_PENDANT_SIZE",
	"CALENDER_EVENT_START",
	"UI_ITEM_SHADOW_POS_TYPE",
	"MAX_BACK_CLOAK_SIZE",
	"POSE_TYPE",
	"COINSHOP_MPAK_ID",
	"UI_OBJECT",
	"COINSHOP_RIDE_BOX_INDEX",
	"UILayer",
	"LEVEL_CAN_JOIN_CAMP",
	"CAMP_AUCTION",
	"EMPTY_TABLE",
	"INVENTORY_GUILD_BANK",
	"UI_OBJECT_ENCHANT",
	"STREAM_GAME",
	"INVENTORY_GUILD_PAGE_SIZE",
	"UI_OBJECT_SHOP_ITEM",
	"UI_OBJECT_SYS_BTN",
	"UI_OBJECT_OTER_PLAYER_ITEM",
	"HOME_TYPE",
	"CALENDER_EVENT_LONG",
	"UI_OBJECT_EXTERIOR",
	"GLOBAL_HEAD",
	"UI_OBJECT_ITEM",
	"UI_OBJECT_TRAIN",
	"FB_TYPE",
	"MAX_L_SHOULDER_SIZE",
	"DIAMOND_MAX_LEVEL",
	"UI_OBJECT_MOBA_ITEM",
	"HORSE_ADORNMENT_COUNT",
	"UI_OBJECT_EXTERIOR_WEAPON",
	"PARTY_TITLE_MARK_EFFECT_LIST",
	"UI_OBJECT_SKILL_RECIPE",
	"TYPE_ID_OF_CAR",
	"UI_OBJECT_SKILL",
	"UI_OBJECT_BUFF",
	"UI_OBJECT_MACRO",
	"SOCIALPANEL_NAME_DISPLAY",
	"UI_OBJECT_PET",
	"COINSHOP_TITLE_CLASS",
	"UI_OBJECT_MONEY",
	"MAIN_SCENE_DOF_AWAY_MIN",
	"PARTY_MARK_ICON_PATH",
	"LIMIT_SALE_AD_SHOW",
	"CALENDER_EVENT_ALLDAY",
	"ACTIVITY_UI",
	"REPORT_FROM_WHERE",
	"COINSHOP_CAN_OPEN_EXP",
	"ROAD_CHIVALROUS_SUBMODULE_STATE",
	"UI_OBJECT_ITEM_INFO_PLAYER",
	"UI_OBJECT_CRAFT",
	"UI_OBJECT_MOUNT",
	"UI_OBJECT_NOT_NEED_KNOWN",
	"UI_OBJECT_ITEM_ONLY_ID",
	"CAMP_OB_CONSTANT",
	"UI_OBJECT_NONE",
	"PARTY_MARK_ICON_FRAME_LIST",
	"TITLE_EFFECT_NONE",
	"OT_CSS",
	"FREEZE_TYPE",
	"UI_OBJECT_PENDANT",
	"FREE_TRYON_AD_OPERATION",
	"SNS_BINDED_CODE",
	"LOGIN_LOGO",
	"EXTERIOR_CLASS",
	"INVITE_FILTER",
	"QUEST_PHASE",
	"COMMAND_MODE_PLAYER_ROLE",
	"MAX_WAIST_SIZE",
	"DIAMOND_MAX_STRENGTHEN_LEVEL",
	"UI_OBJECT_MEDAL",
	"COMMAND_BOARD",
	"ENUM_MAP_WND_TYPE",
	"FORCE_TYPE",
	"MAX_R_SHOULDER_SIZE",
	"UI_OBJECT_EMOTION_ACTION",
	"MAIN_SCENE_DOF_AWAY_MAX",
	"OPERACT_ID",
	"MAX_FACE_SIZE",
	"CAN_APPLY_JOIN_LEVEL",
	"MAX_BACK_SIZE",
	"SPEAKER_STATE",
	"ROAD_CHIVALROUS_MODULE_STATE",
	"HOME_CLASS",
	"CALENDER_EVENT_RESET",
	"MAIN_SCENE_DOF_NEAR_MIN",
	"MIC_STATE",
	"ACTIVITY_ID",
	"WEB_RQST",
	"ARENA_UI_TYPE",
	"ONE_PHOTO_ACTVITY_TYPE",
	"ROAD_CHIVALROUS_SHARE_ONE_BILLION_AWARD_STATE",
	"ROAD_CHIVALROUS_AWARD_STATE",
	"ROAD_CHIVALROUS_MODULE_TYPE",
	"CALENDER_EVENT_DYNAMIC",
	"MAIN_SCENE_DOF_DIST_MAX",
	"EXTERIOR_OPEN_SOURCE",
	"CRAFT_MIN_LEVEL",
	"KUNGFU_TYPE",
	"EXTERIOR_LABEL",
	"GANPEI_MONEY",
	"WEB_DATA_SIGN_RQST",
	"GET_STATUS",
	"COINSHOP_BOX_INDEX",
	"ACTIVITY_STATE",
	"OPERACT_REWARD_STATE",
	"ARENA_HIGH_LEVEL_DIVIDE",
	"XML_LINE_BREAKER",
	"UI_OBJECT_ITEM_INFO",
	"MENU_DIVIDER",
	"ARG_STR",
	"GetStateString",
	"string",
	"IsUILockedMode",
	"tostring",
	"print",
	"GetGuildBankBagPos",
	"GetGuildBankPagePos",
	"Item_Layout",
	"table",
	"math",
	"_M",
	"GetSelfStateString",
	"FORMAT_WMSG_RET",
	"type",
	"pairs",
	"next",
	"IsObjectItem",
	"g_bDebugMode",
	"SHOW_TARGET_LEVEL_LIMITS",
	"ipairs",
	"SetImage",
	"SetParyMarkImage",
	"_NAME",
	"GetCampImageFrame",
	"UI_BOX_TYPE",
	"Wnd",
	"Station",
	"_PACKAGE",
	"Table_IsSkillShow",
	"Table_GetPlayerMiniAvatarsFromType",
	"Table_GetShopPanelInfo",
	"Table_GetCalenderOfDay",
	"Table_GetDungeonClass",
	"RegisterUITable",
	"Table_GetBookSubSort",
	"Table_GetSimpleTipInfo",
	"Table_IsMobaBattleFieldMap",
	"Table_GetBuffDesc",
	"GetAdjustTabPath",
	"Table_DoesMapHaveTreasure",
	"Table_GetPlayerAwardRemind",
	"Table_GetCareerInfo",
	"Table_GetBookPageID",
	"Table_GetBattleFieldGroupInfo",
	"Table_GetServerName",
	"Table_GetFieldPQList",
	"GetCubAttributeIndex",
	"Table_GetCareerMap",
	"Table_GetTongActivityList",
	"Table_GetPlayerMiniAvatarsFromTypeAndKindID",
	"Table_GetChaptersInfo",
	"Table_IsTongBattleFieldMap",
	"Table_GetMasterBonusRank",
	"Table_GetBattlePassRewardInfo",
	"Table_GetFellowPet",
	"Table_GetCountComboInfo",
	"Table_GetWantedRoleavatar",
	"Table_IsShowByRelayOnNot",
	"Table_BuffNeedShow",
	"Table_GetActiviyTipDesc",
	"Table_GetMiddleMapCommandNpc",
	"Table_GetCreateRoleParam",
	"Table_GetMapGroup",
	"Table_GetTrolltechHorse",
	"Table_GetOperatActFRecall",
	"Table_GetBattleFieldDesc",
	"Table_GetBookDesc",
	"Table_GetQuestSuggest",
	"Table_GetPVPMapInfo",
	"Table_GetKungfuSkillList",
	"Table_GetServantAllCommonActionInfos",
	"Table_GetDailyQuestList",
	"Table_GetJX3LibraryList",
	"Table_IsSpecialItem",
	"Table_IsDomesticatePet",
	"Table_GetDomesticatePetModel",
	"Table_GetDungeonBoss_StepSkill",
	"Tagle_IsExitCareerEvent",
	"print",
	"Table_LoadSceneQuest",
	"Table_GetMKungfuBg",
	"Table_GetNpcRecoverHP",
	"Table_GetAllKBWeekReward",
	"Table_GetMiddleMapCommandInfo",
	"Table_GetAchievementProgress",
	"Table_GetNpcTemplateName",
	"Table_GetOperationActUserData",
	"Table_GetSegmentName",
	"Table_GetAdventureTask",
	"Table_GetPanelForbidMap",
	"Table_GetCustomBuffList",
	"Table_GetSkillEffectBySkill",
	"Table_GetTongTechNodeList",
	"Table_GetHorseChildAttr",
	"Table_IsBattleFieldMap",
	"Table_GetRequireAttributeInfo",
	"Table_GetPVPLinkDate",
	"Table_GetSpecailGift",
	"Table_GetWulinShenghuiDuizhenNpcInfo",
	"GetJoinLevel",
	"Table_GetJX3LibraryContent",
	"Table_GetMobaShopItemInfos",
	"Table_GetCyclopaediaSkill",
	"Table_GetRecipeNameVer2",
	"Table_GetNewPQ_NPC_Template",
	"Table_OpenSkillLevel",
	"Table_GetCraftID",
	"Table_GetExteriorSubGenreName",
	"Table_GetRecipeList",
	"Table_GetMobaBattleNonPlayerInfo",
	"TableGetMobaShopPrePurchase",
	"Table_GetCalenderActivityQuest",
	"Table_GetMobaShopItemInfo",
	"Table_GetCareerEvent",
	"Table_GetCalenderActivity",
	"Table_GetAchievementInfo",
	"math",
	"Table_GetMobaShopItemUIInfoByID",
	"Table_GetDoodadTemplateBarText",
	"Table_GetBoss",
	"Table_GetFaceDecalsClass",
	"Table_GetSkillTeachQixueRecommend",
	"Table_GetAutoOpenPanelInfo",
	"Table_GetCareerTab",
	"Table_GetCampSkill",
	"Table_GetActivityList",
	"Table_GetChannelInfo",
	"Table_GetFAQList",
	"Table_GetMapGroupID",
	"Table_GetSoundSetting",
	"Table_GetBuffName",
	"g_SkillNameToID",
	"Table_GetPetAvatar",
	"Wnd",
	"Table_IsActivityPanelQuest",
	"Table_GetPersonLabel",
	"Table_GetOperationActCounterID",
	"Table_FindBoss",
	"Table_GetAllSceneQuest",
	"Table_GetCampBossInfo",
	"Table_GetCastleImgInfo",
	"Table_GetBookPageNumber",
	"Table_GetDLCAchievementInfo",
	"Table_GetGuideSoultion",
	"Table_GetCanExteriorDesc",
	"Table_GetPLActionBarSkill",
	"Table_GetServantInfo",
	"Table_GetDLCQuestMapInfo",
	"Table_GetMagicAttriStrengthValue",
	"Table_GetDLCMainPanelMapInfo",
	"Table_GetDecalsAdjust",
	"Table_GetLocalActionBarParam",
	"Table_GetDLCInfo",
	"Table_GetCareerLinkNpcInfo",
	"Table_GetDLCMapID",
	"Table_GetQuestRpg",
	"Table_GetCmdHistoryData",
	"Table_GetVoiceTypeData",
	"Table_GetMultiStageSkill",
	"Table_GetNPCSpeechSounds",
	"Table_GetServantSpecialActionInfoByNpcIndex",
	"Table_GetMiniAvatarID",
	"Table_GetServantCommonActionInfoByActionID",
	"CorrectSkillName",
	"Table_GetPuppetSkill",
	"Table_GetAllReputationRewardItemInfo",
	"Table_GetForceUI",
	"Table_GetMapBalloonShieldLevel",
	"Table_GetChanelList",
	"Table_GetSkillPracticeID",
	"Table_GetReputationForceMaps",
	"Table_GetReputationForceInfo",
	"Table_GetIdentityPetWord",
	"Table_GetNewPQId",
	"Table_GetIdentityInfo",
	"Table_GetMapInfoIdxByMapID",
	"string",
	"Table_GetAllRepuForceGroupInfo",
	"Table_GetItemIconID",
	"Table_GetGrouponTemplate",
	"Table_GetAllPersonLabel",
	"Table_GetAutoCorpsNameList",
	"Table_GetNewMovieIDByProtocolID",
	"Table_GetActivityOfPeriod",
	"Table_GetSkillExtCDID",
	"Table_GetMapTip",
	"Table_GetTypeDecalList",
	"Table_GetNewMovieInfo",
	"Table_GetRideModelInfo",
	"Table_GetPresentExamPrint",
	"g_tTable",
	"Table_GetParentSkill",
	"Table_GetMoviePath",
	"Table_GetSkillGuideNext",
	"Table_GetSkillSchoolName",
	"Table_GetPlayerZombieLevel",
	"Table_GetFaceMeshInfo",
	"Table_GetProfessionName",
	"Table_GetFellowPetIconID",
	"Table_BeFliped",
	"Table_GetActivitySymbol",
	"Table_GetPQStage",
	"Table_GetDungeonBossModel",
	"Table_GetRoadChivalrousInfo",
	"Table_GetDecorationList",
	"Table_GetBigKungfuInfo",
	"Table_GetTeamInfoByQuestID",
	"StringParse_Numbers",
	"Table_IsShowOnNewSkill",
	"Table_GetCareerTabTitle",
	"Table_GetReputationLevelInfo",
	"Table_GetRecommendID",
	"Table_GetHuaZhaoJieImagePath",
	"ilines",
	"Table_GetNPCSpeechSoundsBg",
	"Table_GetNextTitleRankPoint",
	"Table_GettDecoration",
	"Table_GetSkillLimitList",
	"Table_GetDLCRewardQuestIDs",
	"next",
	"Table_GetBattleMarkState",
	"Table_GetTreasureTeamInfoTitle",
	"Table_GetTreasureInfoTitle",
	"Table_GetVideoSetting",
	"Table_IsArtistWriteExist",
	"Table_GetTongActivityContent",
	"Table_AutoQuestList",
	"Table_GetTeachingAim",
	"Table_GetSelfieFilterParamsByLogicIndex",
	"Table_GetFaceBoneList",
	"Table_BuffIsVisible",
	"Table_GetFellowPetSkill",
	"Table_GetFBCDBossAvatar",
	"Table_GetAllSelfieFilterParams",
	"Table_GetFellowPet_SearchList",
	"Table_GetSkillDesc",
	"Table_GetShopPanelSelector",
	"Table_GetSkillIconID",
	"Table_GetSelfieResolution",
	"Table_GetAllSelfieLightParams",
	"Table_GetCraftIconID",
	"Table_GetDomesticateEvent",
	"Table_GetEnchantQuality",
	"Table_GetForceSmallIcon",
	"Table_GetArenaLiveMap",
	"_M",
	"Table_GetCraftBelongName",
	"Table_GetDanmakuColor",
	"Table_GetBattleFieldHelpInfo",
	"Table_GetCubInfo",
	"Table_GetMiddleMap",
	"Table_GetAllMasterBunusItem",
	"Table_GetOneIdentityInfo",
	"Table_GetReputationRewardItemInfoByForceID",
	"Table_GetPlayerReturnBoxInfo",
	"Table_GetMapListByKungfu",
	"Table_GetCharInfoMainAttrShow",
	"Table_GetFellowPet_Class",
	"Table_GetPlayerMiniAvatarsFromKindID",
	"Table_GetSmartDialog",
	"Table_GetPlayerReturnShowTable",
	"Table_GetDesignationGeneration",
	"Table_GetFilterInviteInfo",
	"Table_GetOfficalFaceList",
	"Table_GetUpSkillEffect",
	"Table_GetDungeonBoss",
	"Table_GetEnchantIconID",
	"Table_GetLogoInfo",
	"Table_GetSpecialTimeToItemCount",
	"tostring",
	"Table_GetFirstLoginSkill",
	"Table_GetQuestIdentityExp",
	"Table_GetActivityOfDay",
	"Table_GetCommonEnchantDesc",
	"Table_GetMapFontID",
	"Table_GetHorseBasicAttributeInfo",
	"Table_ViewReplace",
	"Table_IsNewcomerBattleFieldMap",
	"Table_GetSkillSchoolKungfu",
	"Table_GetCopyMap",
	"Table_GetActivityHome",
	"Table_GetMapMovieID",
	"Table_GetCubAttribute",
	"ParseNumbers",
	"Table_GetFAQContent",
	"Table_GetFireBookTypeName",
	"Table_GetKungfuData",
	"Table_GetSkillGuideList",
	"Table_GetCalenderActivityAward",
	"ParseCareerEventTab",
	"Table_GetFBCountDown",
	"Table_GetSkill",
	"Table_GetCareerAllEventTitle",
	"Table_GetSkillRecipeMirrorSrc",
	"Table_GetFellowPet_Medal",
	"GetAttribute",
	"Table_GetMagicAttributeInfo",
	"Table_GetEnchantName",
	"Table_GetZhenPaiLinesInfo",
	"Table_GetBuffIconID",
	"Table_GetFBCountNum",
	"Table_GetMinMaxReputationLevel",
	"Table_GetArtistReward",
	"Table_IsSimplePlayer",
	"Table_GetGrowthEquitLevel",
	"Table_IsSkillShieldLevelUp",
	"Table_GetQixueTeachByList",
	"Table_GetChooseStep",
	"Table_GetTeamSpecialBuff",
	"Table_GetMapGuideCity",
	"Table_GetHorseTuJianAttr",
	"Table_GetSkillName",
	"Table_GetSkillShortDesc",
	"Table_GetCharInfoShow",
	"Table_GetMapType",
	"Table_GetCubEmotion",
	"Table_GetSkillEffectByBuff",
	"Table_GetTaskToAdvID",
	"Table_FindAchievementProgress",
	"Table_GetFireBookInfoInfo",
	"Table_IsInForbidMap",
	"Table_GetAdventure",
	"Table_GetGrowInfo",
	"Table_GetBidNpcName",
	"Table_BuffNeedSparking",
	"Table_GetLearnSkillInfo",
	"Station",
	"Table_GetCampAuctionInfo",
	"Table_GetReadMailPanelInfo",
	"Table_GetTitleRankTip",
	"Table_GetBattleFieldPQOptionInfo",
	"Table_GetSkillRecipe",
	"Table_GetSkillKungfuDesc",
	"Table_GetCDProcessBoss",
	"Table_GetCastleInfo",
	"Table_GetAllFellowPet",
	"Table_GetDungeonEnterTip",
	"Table_GetCategoryByAttributeID",
	"Table_GetMentorPanelInfo",
	"table",
	"Table_GetTopmenuButton",
	"Table_GetComboSkillInfo",
	"Table_GetMKungfuList",
	"Table_GetLinkCount",
	"Table_GetHorseAttrs",
	"Table_GetOneKindAdventure",
	"Table_GetNewPQ_AllPos",
	"Table_GetNewPQ_ByNPCTemplate",
	"Table_GetRecipeName",
	"Table_GetExteriorSet",
	"Table_GetProgressBar",
	"ipairs",
	"Table_BuffNeedShowTime",
	"Table_GetOperatFRecallImg",
	"Table_GetShareOneBillionRoadChivalrousQuestInfo",
	"Table_GetChongXiaoMonthlyByMonth",
	"Table_GetOperaionActUrl",
	"Table_GetBattleFieldRewardIconInfo",
	"Table_GetFieldPQ",
	"Table_GetOperationActCard",
	"Table_GetOperActyDes",
	"Table_GetSceneFieldPQ",
	"Table_GetBattlePassQuestInfo",
	"Table_GetCurrentCareer",
	"Table_IsAutoSearchShield",
	"Table_GetDungeonList",
	"GetAttributeIndex",
	"Table_GetDisCoupon",
	"Table_GetDungeonInfo",
	"ilines_r",
	"IsUITableRegister",
	"Table_GetVideoSettingSM",
	"Table_GetDialogBtn",
	"Table_GetOperationActivity",
	"Table_GetTeamPosition_KungFu",
	"Table_GetTeamRecruitMask",
	"Table_GetTeamRecruitForceMask",
	"type",
	"Table_GetMap",
	"Table_GetBookNumber",
	"Table_GetChannelKey",
	"Table_GetCraftName",
	"Table_GetTeamInfoByMapID",
	"Table_GetExteriorGenreName",
	"Table_GetAnimalAction",
	"Table_GetNewPQ_Npc",
	"Table_GetTeamInfo",
	"Debug_TableSkillCache",
	"Table_GetTeamRecruit",
	"Table_GetBuffTime",
	"Table_GetActivityNoneML",
	"LoadExteriorMap",
	"Table_GetHorseMagicAttributeInfo",
	"Table_IsPVPArenaLiveBan",
	"Table_GetSkillSortOrder",
	"Table_GetSkillTeach",
	"Table_GetOperActyInfo",
	"Table_GetItemSoundID",
	"Table_GetLandscapeCfg",
	"Table_GetBookContent",
	"Table_GetPetSkillChange",
	"Table_GetCastleByMapID",
	"Table_GetMiddleMapSelectNpc",
	"Table_GetNpcGuild",
	"Table_GetNpcTypeInfoMap",
	"Table_GetEquipRecommendKungfus",
	"Table_GetDoodadName",
	"Table_GetExteriorHome",
	"Table_GetAllKBSeasonReward",
	"Table_GetAssassinationTaskScrollInfo",
	"Table_GetQuestClass",
	"Table_GetSkillQixueName",
	"Table_GetBookItemIndex",
	"Table_GetActivityContent",
	"Table_GetLocalActionBarData",
	"GetAttributeString",
	"Table_GetBookMark",
	"Table_GetBattleFieldSubMapID",
	"Table_GetRideSubDisplay",
	"Table_GetPetSkill",
	"Table_GetWantedLimitMap",
	"Table_GetHelpSoundName",
	"Table_GetTeamRecruitPosMask",
	"Table_IsTreasureBattleFieldMap",
	"Table_GetSkillRecipeMirror",
	"Table_GetDungeonNpcCV",
	"Table_GetAllReputationGainDesc",
	"Table_GetChanelName",
	"GetBinTableTitle",
	"Table_GetArtistSkillsInfo",
	"Table_GetSfxSize",
	"Table_GetDefaultLine",
	"Table_IsLegalSkill",
	"Table_IsBlackListSkill",
	"Table_GetDungeonSkillIcon",
	"Table_GetMapMarkForIdentity",
	"Table_GetPath",
	"pairs",
	"Table_GetCraftDesc",
	"Table_GetCareerTabName",
	"Table_GetSkillSchoolIconID",
	"Table_GetIdentityOtherInfo",
	"Table_GetBattleFieldSuggest",
	"Table_GetShowWord",
	"Table_GetDungeonBossNpcListByBossIndex",
	"Table_GetReputationGainDescByForceID",
	"Table_GetDailyQuestContent",
	"Table_GetEnchantDesc",
	"Table_GetNewKungfuSkill",
	"Table_GetRecipeTip",
	"Table_GetNewDungeonList",
	"Table_GetFellowPet_Achievement",
	"Table_GetFAQClassName",
	"Table_IsSkillCombatShow",
	"Table_GetFieldPQString",
	"Table_IsShowRelayOn",
	"GetRequireIndex",
	"Table_GetProtocolToAviPath",
	"GetRequire",
	"Table_GetZhenPaiLinesName",
	"Table_GetZhenPaiLines",
	"Table_GetDecal",
	"Table_IsShieldedNpc",
	"Table_GetCopySuggest",
	"Table_GetBattleFieldName",
	"Table_GetScriptFromCommonTab",
	"Table_GetCurrencyList",
	"Table_GetAchievement",
	"Table_GetSortedDlcList",
	"Table_GetStructTypeList",
	"Table_GetWarningType",
	"Table_GetEnchantTipShow",
	"Table_GetBaseAttributeInfo",
	"Table_GetAllOutsideFilterParams",
	"Table_GetSkillSchoolInfo",
	"_PACKAGE",
	"Table_GetBookName",
	"Table_GetAnnounceImage",
	"Table_GetExteriorSetName",
	"Table_GetMobaBattleVoiceFilePath",
	"Table_IsSkillFormationCaster",
	"Table_GetDoodadTemplateType",
	"Table_GetSuggestMap",
	"Table_GetBranchName",
	"Table_GetRewardLevelInfo",
	"Table_GetQuestPosInfo",
	"Table_GetPlayerMiniAvatars",
	"Table_GetItemName",
	"Table_GetKungFuName",
	"Table_GetCGList",
	"Table_GetChongXiaoMonthly",
	"Table_LoadSceneFieldPQ",
	"Table_GetCalenderActivityAwardIcon",
	"Table_GetMapName",
	"Table_GetItemDesc",
	"Table_GetExteriorArray",
	"Table_IsFBBattleFieldMap",
	"Table_GetCraftHoleIcon",
	"Table_GetActiviyTimeDesc",
	"dwQuestID",
	"Table_ParseCalenderActivity",
	"Table_GetDoodadTemplateName",
	"Table_ForceToSchool",
	"Table_GetBookSort",
	"Table_GetAllDanmakuColor",
	"Table_GetQuestStringInfo",
	"Table_GetNewPQ",
	"Table_SchoolToForce",
	"Table_GetCraft",
	"Table_IsZombieBattleFieldMap",
	"Table_GetTongTechTreeNodeInfo",
	"Table_GetBuff",
	"Table_MKungfuIsSection",
	"Table_GetAllMapIDsWithTreasure",
	"_NAME",
	"Table_GetForceImageName",
	"Debug_TableBuffCache",
	"Table_IsSkillFormation",
	"Table_GetSkillSpecialDesc",
	"Table_GetSFXInfo",
	"SKILL_SELECT_POINT_UNNORMAL",
	"string",
	"QUEST_OPERATION_FINISH",
	"ROLE_TYPE_LITTLEGIRL",
	"tostring",
	"print",
	"QUEST_STATE_YELLOW_EXCLAMATION",
	"MAX_SKILL_REICPE_COUNT",
	"QUEST_WHITE_LEVEL",
	"ROLE_TYPE_SEXYFEMALE",
	"MAX_USABLE_MENTOR",
	"GetQuestIndex",
	"QUEST_STATE_NO_MARK",
	"QUEST_HIDE_LEVEL",
	"pairs",
	"_PACKAGE",
	"QUEST_STATE_YELLOW_QUESTION",
	"ipairs",
	"MAX_BATTLE_FIELD_OVERTIME",
	"RIDE_FULL_MEASURE",
	"BUFF_ON_HORSE",
	"MAX_CAMP_PRIZE",
	"ROLE_TYPE_INVALID",
	"IsPlayerManaHide",
	"ROLE_TYPE_STRONGMALE",
	"ROLE_TYPE_STANDARDFEMALE",
	"QIXUE_TYPE",
	"ROLE_TYPE_STANDARDMALE",
	"MAX_TONG_BATTLE_FIELD_OVERTIME",
	"QUEST_STATE_WHITE_QUESTION",
	"QUEST_STATE_BLUE_EXCLAMATION",
	"QUEST_STATE_BLUE_QUESTION",
	"MAX_QUEST_COUNT",
	"QUEST_STATE_WHITE_EXCLAMATION",
	"MAX_DAILY_QUEST_COUNT",
	"MAX_CAMP_PRESTIGE",
	"ROLE_TYPE_LITTLEBOY",
	"math",
	"_M",
	"MAGIC_ATTRI_DEF",
	"ITEM_SUBTYPE_DIAMOND_REPAIRE",
	"ITEM_SUBTYPE_RECIPE",
	"type",
	"MAX_BATTLE_FIELD_SIDE_COUNT",
	"ITEM_SUBTYPE_SKILL_RECIPE",
	"QUEST_STATE_DUN_DIA",
	"CONVERT_RAID_PLAYER_MIN_LEVEL",
	"table",
	"FINAL_TYPE",
	"next",
	"QUEST_STATE_HIDE",
	"_NAME",
	"QUEST_OPERATION_ACCEPT",
	"MAX_CAMP_LEVEL",
	"Wnd",
	"Station",
	"GetQuestState",

	"math",
	"select",
	"string",
	"table",
	"print",
	"ipairs",
	"pairs",
	"tostring",
	"tonumber",
	"type",
	"next",
	"assert",
	"collectgarbage",
	"error",
	"unpack",
	"pcall",
	"xpcall",
	"setmetatable",
	"count_c",
	"pairs_c",
	"ipairs_c",
	"SetmetaReadonly",
	"CAMP",
	"GLOBAL",
	"FORCE_TYPE",
	"KUNGFU_TYPE",
	"ITEM_TABLE_TYPE",
	"EQUIPMENT_REPRESENT",
	"INVENTORY_INDEX",
	"INVENTORY_GUILD_BANK",
	"INVENTORY_GUILD_PAGE_SIZE",
	"GetGuildBankBagPos",
	"TARGET",
	"ITEM_GENRE",
	"ITEM_BIND",
	"PLAYER_TALK_CHANNEL",
	"ADDON_CATEGORY",
	"EQUIPMENT_SUB",
	"EQUIPMENT_INVENTORY",
	"WEAPON_DETAIL",
	"BULLET_DETAIL",
	"INVENTORY_TYPE",
	"PARTY_LOOT_MODE",
	"MOVE_STATE",
	"SKILL_EFFECT_TYPE",
	"SKILL_CAST_EFFECT_TYPE",
	"SKILL_RESULT_CODE",
	"SKILL_RECIPE_TYPE",
	"SKILL_RESULT_TYPE",
	"ROLE_TYPE",
	"QUEST_STATE",
	"RELATION_TYPE",
	"TEAM_AUTHORITY_TYPE",
	"REVIVE_TYPE",
	"DOODAD_KIND",
	"MAP_TYPE",
	"MAP_CAMP_TYPE",
	"MAIL_TYPE",
	"ITEM_EXIST_TYPE",
	"CHARACTER_OTACTION_TYPE",
	"ARENA_TYPE",
	"POSE_TYPE",
	"GetVersion",
	"GetLogicFrameCount",
	"TimeToDate",
	"DateToTime",
	"GetCurrentTime",
	"FormatString",
	"LootMoney",
	"LootItem",
	"RollItem",
	"GetMapList",
	"GetSkillInfo",
	"RegisterCastSkillFun",
	"UnRegisterCastSkillFun",
	"IsParty",
	"Random",
	"RepairAllItems",
	"GlobelRecipeID2BookID",
	"BookID2GlobelRecipeID",
	"GetSkillRecipeBaseInfo",
	"GetMasterRecipeList",
	"Lock_State",
	"GetShopItemID",
	"GetShopItemBuyOtherInfo",
	"GetShopItemReputeLevel",
	"GetShopItemRepairPrice",
	"GetShopItemSellPrice",
	"GetBuyLimitItemCDLeftFrames",
	"SellItem",
	"BuyItem",
	"GetRepairAllItemsPrice",
	"GetItemMagicAttrib",
	"GetItemSetAttrib",
	"GetDesignationPrefixInfo",
	"GetItemCoolDown",
	"GetColorDiamondInfoFromEnchantID",
	"GetItemEnchantAttrib",
	"IsRemotePlayer",
	"PeekOtherPlayerBook",
	"ApplyAchievementData",
	"GetBattleFieldPQInfo",
	"GetEquipItemCompaireItem",
	"GetCorpsInfo",
	"GetBFRoleData",
	"GetArenaStatistics",
	"GetBattleFieldStatistics",
	"CharInfoMore_GetShowValue",
	"GetCharInfoShowSetting",
	"IsPlayerExist",
	"GetMapParams",
	"IsPlayer",
	"IsEnemy",
	"IsSelf",
	"GetLevelUpData",
	"GetReputeLimit",
	"GetPingValue",
	"GetUserPreferences",
	"StorageServer_GetData",
	"GetBuffInfo",
	"GetBuffTime",
	"GetCharacterDistance",
	"ApplyCharacterThreatRankList",
	"IsNpcExist",
	"SetTarget",
	"IsNeutrality",
	"IsCommonSkill",
	"IsAlly",
	"SetTeamMark",
	"GetFEAInfoByEnchantID",
	"GetDiamondInfoFromEnchantID",
	"GetCorpsID",
	"GetCorpsRoleInfo",
	"GetCorpsMemberInfo",
	"SyncCorpsBaseData",
	"SyncCorpsMemberData",
	"ViewInviteToPlayer",
	"ViewOtherPlayerChannels",
	"ViewOtherZhenPaiSkill",
	"GetPeekPlayerID",
	"PeekOtherPlayerTalent",
	"SetAddonAreaCastMode",
	"MD5",
	"ApplyDungeonRoleProgress",
	"GetDungeonRoleProgress",
	"SendGMCommand",
	"GetPlayerItem",
	"GetItem",
	"GetItemInfo",
	"GetItemAdvanceBoxKeyInfo",
	"GetAuctionClient",
	"GetClientPlayer",
	"GetControlPlayer",
	"GetPlayer",
	"GetNpc",
	"GetDoodad",
	"GetSkill",
	"GetQuestInfo",
	"GetClientTeam",
	"GetTongClient",
	"GetFellowshipCardClient",
	"GetMailClient",
	"GetScene",
	"GetDoodadTemplate",
	"GetNpcTemplate",
	"GetRecipe",
	"GetProfession",
	"class",
	"tweenlite",
	"Output",
	"UILog",
	"BigIntAdd",
	"BigIntSub",
	"IsOptionOrOptionChildPanelOpened",
	"RegisterScrollEvent",
	"UnRegisterScrollAllControl",
	"RegisterScrollControl",
	"GetTargetHandle",
	"GetTargetMaxLife",
	"GetAttributeString",
	"FireUIEvent",
	"FireEvent",
	"FireHelpEvent",
	"DelayCall",
	"BreatheCall",
	"FrameCall",
	"RenderCall",
	"BuffMgr",
	"RegisterEvent",
	"UnRegisterEvent",
	"RegisterCustomData",
	"PopupMenu",
	"PopupMenu_ProcessHotkey",
	"IsPopupMenuOpened",
	"GetPopupMenu",
	"PopupMenuEx",
	"InitFrameAutoPosInfo",
	"GetLocalTimeText",
	"GetWorldMapScale",
	"GetTimeText",
	"clone",
	"var2str",
	"SplitString",
	"GetFormatText",
	"FormatHandle",
	"GetFormatImage",
	"KeepOneByteFloat",
	"KeepTwoByteFloat",
	"FixFloat",
	"GetIntergerBit",
	"Conversion2ChineseNumber",
	"IsTableEmpty",
	"IsEmpty",
	"GetMoneyTipText",
	"GetGoldText",
	"GetMoneyText",
	"GetMoneyPureText",
	"GetTimeToHourMinuteSecond",
	"UI_GetPlayerMountKungfuID",
	"OutputBuffTip",
	"GetBuffDesc",
	"GetBindBuffDesc",
	"FormatLinkString",
	"OutputTeamMemberTip",
	"OutputActivityTip",
	"OutputFieldPQTip",
	"OutputQuestTip",
	"ColorText",
	"UI_GetClientPlayerID",
	"GetControlPlayerID",
	"OnUseCraft",
	"OnBreakEquip",
	"BreakEquip",
	"OnUpdateCraftState",
	"OutputCraftTip",
	"OutputBookTipByID",
	"GetBookTipByItem",
	"GetBookTipByItemInfo",
	"OutputRecipeLink",
	"OutputEnchantTip",
	"OutputEnchantLink",
	"OutputDoodadTip",
	"GetDoodadQuestTip",
	"CheckDistanceAndDirection",
	"OpenDoodad",
	"InteractDoodad",
	"CanSelectDoodad",
	"GetQuestState",
	"Hand_IsEmpty",
	"Hand_Clear",
	"Hand_Get",
	"Hand_Pick",
	"Hand_DropHandObj",
	"IsCursorInExclusiveMode",
	"GetKeyValue",
	"GetKeyName",
	"IsShiftKeyDown",
	"IsCtrlKeyDown",
	"IsAltKeyDown",
	"IsKeyDown",
	"GetKeyShow",
	"AddUILockItem",
	"RemoveUILockItem",
	"RefreshUILockItem",
	"GetUIItemBox",
	"g_tReputation",
	"GetNpcQuestTip",
	"GetNpcQuestState",
	"CThreadCoor_Register",
	"CThreadCoor_Unregister",
	"CThreadCoor_Get",
	"RegisterGlobalEsc",
	"UnRegisterGlobalEsc",
	"UpdateSkillRecipeBoxObject",
	"UpdataItemInfoBoxObject",
	"UpdataItemBoxObject",
	"UpdateItemBoxExtend",
	"UpdateMountBoxObject",
	"UpdateBoxObject",
	"OnSplitBoxItem",
	"OnExchangeItem",
	"UpdataItemCDProgress",
	"OnUseItem",
	"OnDestroyItem",
	"OnDestroyItemTable",
	"GetItemFontColorByQuality",
	"GetWeapenType",
	"GetItemNameByUIID",
	"GetItemPosByItemTypeIndex",
	"GetItemPosInPackage",
	"PlayItemSound",
	"FormatAttributeValue",
	"OutputPendantTip",
	"GetItemTip",
	"GetItemNameByItem",
	"GetItemInfoTip",
	"GetItemNameByItemInfo",
	"OutputItemTip",
	"MessageBox",
	"CloseLastMessageBox",
	"CloseMessageBox",
	"OutputMessage",
	"IsMonitorMsg",
	"RegisterMsgMonitor",
	"UnRegisterMsgMonitor",
	"GetMsgFontString",
	"GetMsgFont",
	"SetMsgFontColor",
	"OnItemLinkDown",
	"OpenHotkeyPanel",
	"ParseEmotionCommand",
	"LootList_AddonClosePickupAll",
	"Addon_AutoRefineDiamond",
	"Addon_RegisterPlayerMenu",
	"Addon_RegisterTargetMenu",
	"Addon_RegisterTraceButtonMenu",
	"Addon_RegisterPanel",
	"Addon_UnregisterPanel",
	"Addon_SwitchCategroy",
	"Addon_SwitchTab",
	"Addon_OpenPanel",
	"Addon_ClosePanel",
	"Addon_TogglePanel",
	"Addon_ExteriorViewByItemInfo",
	"SaveLUAData",
	"LoadLUAData",
	"LoadLangPack",
	"IsMystiqueRecipeRead",
	"IsMystiqueSkillRead",
	"GetNpcIntensity",
	"HideTip",
	"OutputTip",
	"OutputSkillTip",
	"OutputSkillLink",
	"OutputSkillRecipeTip",
	"UpdataSkillCDProgress",
	"UpdateCustomModeWindow",
	"GetForceImage",
	"GetForceTitle",
	"GetFrameAnchor",
	"GetFrameAnchorCorner",
	"GetFrameAnchorEdge",
	"SearchTarget_IsOldVerion",
	"SearchTarget_SetOtherSettting",
	"SearchTarget_SetAreaSettting",
	"GetNpcHeadImage",
	"GetHeadTextForceFontColor",
	"Target_GetTargetData",
	"GetUserInput",
	"GetUserInputNumber",
	"GetUserPercentage",
	"GetUserSetPrice",
	"OpenColorTablePanel",
	"OutputWarningMessage",
	"GetMsgFontColor",
	"EditBox_GetChannel",
	"OpenArenaCorpsPanel",
	"IsBuffDispel",
	"Buffer_IsDispel",
	"SetCombatTargetToMeSetting",
	"SetCombatMeToTargetSetting",
	"PlayerChangeSuit",
	"SwitchChatChannel",
	"Chat_GetMonitorMsg",
	"Chat_AddMonitorMsg",
	"Chat_RemoveMonitorMsg",
	"InsertMarkMenu",
	"InsertPlayerMenu",
	"InsertEquipOptMenu",
	"InsertPlayerCommonMenu",
	"InsertDistributeMenu",
	"InsertPlayerCampMenu",
	"InsertPlayerKungfuMenu",
	"InsertTeammateLeaderMenu",
	"InsertTeammateMenu",
	"InsertInviteTeamMenu",
	"InsertTargetMenu",
	"Target_AppendAddonMenu",
	"Target_GetAddonMenu",
	"Player_AppendAddonMenu",
	"Player_GetAddonMenu",
	"TraceButton_AppendAddonMenu",
	"TraceButton_GetAddonMenu",
	"OutputAchievementTip",
	"OutputDesignationTip",
	"TargetPanel_SetOpenState",
	"TargetPanel_GetOpenState",
	"MoneyToGoldSilverAndCopper",
	"GoldSilverAndCopperToMoney",
	"SelectMainActionBarPage",
	"GetPartyMemberFontColor",
	"GetForceFontColor",
	"GetKungfuSchoolColor",
	"Send_RaidReadyConfirm",
	"ApplyMapEnterInfo",
	"ApplyMapSaveCopy",
	"Raid_SetBufftimeParam",
	"Raid_MonitorBuffs",
	"Raid_GetConfig",
	"Raid_SetConfig",
	"Raid_GetMemberHandle",
	"OpenRaidPanel",
	"CloseRaidPanel",
	"OpenUISettingPanel",
	"IsBagInSort",
	"IsBankInSort",
	"FormatMoneyTab",
	"MoneyOptCmp",
	"MoneyOptAdd",
	"MoneyOptSub",
	"MoneyOptDiv",
	"MoneyOptMult",
	"UnpackMoney",
	"PackMoney",
	"Scene_GetSceneID",
	"g_sound",
	"UserSelect",
	"g_tTable",
	"g_tStrings",
	"Arena_GetCompetitionIndex",
	"BattleField_MatchPlayer",
	"ForceIDToKungfuIDs",
	"IsActivated",
	"GetCenterID",
	"GVoiceBase_IsOpen",
	"GVoiceBase_GetMicState",
	"GVoiceBase_SwitchMicState",
	"GVoiceBase_CheckMicState",
	"GVoiceBase_GetSpeakerState",
	"GVoiceBase_SwitchSpeakerState",
	"GVoiceBase_GetSaying",
	"GVoiceBase_IsMemberSaying",
	"GVoiceBase_IsMemberForbid",
	"GVoiceBase_ForbidMember",
	"ViewEquip_IsAddOnVersionActivated",
	"ViewEquip_SetAddOnVersionActiveState",
	"AuctionPanel",
	"BigBagPanel",
	"CraftReadManagePanel",
	"CraftReadComparePanel",
	"MainMessageLine",
	"MiddleMap",
	"OpenMiddleMap",
	"IsMiddleMapOpened",
	"CloseMiddleMap",
	"ZhenPaiSkill",
	"Player_GetFrame",
	"PostThreadCall",
	"Table_GetItemIconID",
	"Table_GetItemName",
	"Table_GetItemDesc",
	"Table_GetSkillRecipe",
	"Table_GetRecipeList",
	"Table_GetSkill",
	"Table_GetSkillIconID",
	"Table_GetSkillSchoolName",
	"Table_GetSkillSchoolIconID",
	"Table_IsSkillFormation",
	"Table_IsSkillFormationCaster",
	"Table_GetSkillName",
	"Table_GetSkillDesc",
	"Table_GetSkillShortDesc",
	"Table_GetSkillSpecialDesc",
	"Table_GetSkillSortOrder",
	"Table_IsSkillShow",
	"Table_IsSkillCombatShow",
	"Table_GetSkillPracticeID",
	"Table_GetLearnSkillInfo",
	"Table_GetBuff",
	"Table_GetBuffIconID",
	"Table_GetBuffName",
	"Table_GetBuffDesc",
	"Table_BuffNeedSparking",
	"Table_BuffNeedShowTime",
	"Table_BuffNeedShow",
	"Table_BuffIsVisible",
	"Table_GetForceImageName",
	"Table_GetNpcTemplateName",
	"Table_GetPetSkill",
	"Table_GetPetAvatar",
	"Table_GetMapName",
	"Table_GetQuestPoint",
	"Table_GetMagicAttributeInfo",
	"Table_IsTreasureBattleFieldMap",
	"Table_IsZombieBattleFieldMap",
	"Table_IsMobaBattleFieldMap",
	"GetBattleFieldFatherID",
	"IsAddonBanMap",
	"Table_GetCDProcessBoss",
	"Table_GetBoss",
	"Table_IsShieldedNpc",
	"Table_GetDoodadTemplateName",
	"Table_GetMKungfuBg",
	"Table_GetMKungfuList",
	"Table_GetKungfuSkillList",
	"Table_GetNewKungfuSkill",
	"Table_GetComboSkillInfo",
	"Table_OpenSkillLevel",
	"Table_GetSkillTeach",
	"Table_GetSkillTeachQixueRecommend",
	"Table_GetGuideSoultion",
	"Table_SchoolToForce",
	"Table_ForceToSchool",
	"Trace",
	"Log",
	"GetRootPath",
	"ScreenShot",
	"GetSystemCScreen",
	"NumberToChinese",
	"PlaySound",
	"StopSound",
	"EncodeComponentsString",
	"StringEnerW",
	"StringReplaceW",
	"StringFindW",
	"wstring",
	"GetFPS",
	"StringLowerW",
	"FormatTime",
	"GetTime",
	"GetTickCount",
	"ReInitUI",
	"IsFileExist",
	"IsLocalFileExist",
	"GetPureText",
	"FlashTaskBar",
	"GetUIIconPath",
	"KG_Table",
	"Hotkey",
	"Station",
	"Font",
	"Wnd",
	"Cursor",
	"CPath",
	"UI_OBJECT_ITEM",
	"UI_OBJECT_SHOP_ITEM",
	"UI_OBJECT_OTER_PLAYER_ITEM",
	"UI_OBJECT_ITEM_ONLY_ID",
	"UI_OBJECT_ITEM_INFO",
	"UI_OBJECT_SKILL",
	"UI_OBJECT_CRAFT",
	"UI_OBJECT_SKILL_RECIPE",
	"UI_OBJECT_SYS_BTN",
	"UI_OBJECT_MACRO",
	"UI_OBJECT_MOUNT",
	"UI_OBJECT_ENCHANT",
	"UI_OBJECT_NOT_NEED_KNOWN",
	"rlcmd",
	"ccmd",
	"k3dcmd",
	"SetGlobalTopHeadFlag",
	"GetGlobalTopHeadFlag",
	"SetGlobalTopIntelligenceLife",
	"GetGlobalTopIntelligenceLife",
	"Scene_GetCharacterTopScreenPos",
	"Scene_GetCharacterTop",
	"Scene_ScenePointToScreenPoint",
	"Scene_GameWorldPositionToScenePosition",
	"Scene_ScenePositionToGameWorldPosition",
	"Scene_GameWorldPositionToScreenPoint",
	"SceneObject_SetBrightness",
	"Scene_SelectObject",
	"Scene_PlaneGameWorldPosToScene",
	"SceneObject_SetTitleEffect",
	"Player_GetAnimationResource",
	"Player_GetEquipResource",
	"Player_GetRidesEquipResource",
	"Player_GetRidesAnimationResource",
	"PlayerEnergyUI_Update",
	"PlayerEnergyUI_GetUpdateFunc",
	"PlayerEnergyUI_ChangeStyle",
	"NPC_GetProtrait",
	"NPC_GetHeadImageFile",
	"TargetSelection_AttachSceneObject",
	"TargetSelection_DetachSceneObject",
	"Camera_GetRTParams",
	"Camera_GetParams",
	"Navigator_SetID",
	"Navigator_SetPoint",
	"Navigator_Remove",
	"ReloadUIAddon",
	"EnableDebugEnv",
	"OpenDebug",
	"IsMultiThread",
	"GetOpenFileName",
	"SetDataToClip",
	"GetOnlineFrameAnchor",
	"SetOnlineFrameAnchor",
	"GetAddonCustomData",
	"SetAddonCustomData",
	"CURL_HttpPostEx",
	"AnsiToUTF8",
	"UTF8ToAnsi",
	"ConvertCodePage",
	"GetGameCodePage",
	"GetAnsiCodePage",
	"UrlEncode",
	"UrlDecode",
	"JsonEncode",
	"JsonDecode",
	"GetFileCRC",
	"GetStringCRC",
	"SQLite3_Open",
	"UnQLite_Open",
	"LoadDataFromFile",
	"SaveDataToFile",
	"IsEncodedData",
	"EncodeData",
	"DecodeData",
	"EncryptAES",
	"DecryptAES",
	"RegisterTalkFilter",
	"UnRegisterTalkFilter",
	"RegisterMsgFilter",
	"UnRegisterMsgFilter",
	"HookTableFunc",
	"UnhookTableFunc",
	"GetCurrentProcessID",
	"__libexport",
	"GetInsideEnv",
	"debug",
	"_reserve_fun",
	"GetUserServer",
	"GetUserRoleName",
	"IsDebugClient",
	"GetServerIP",
	"GetServerPort",
	"GetUserAccount",
	"Login_GetAccount",
	"GetGatewayServer",
	"GetInterworkingServers",
	"OpenBrowser",
	"KGUIEncrypt",
	"OpenGoldTeam",
	"GetUserDataFolder",
	"AchievementPanel",
}

read_globals = {}