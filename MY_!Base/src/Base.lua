--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : 茗伊插件主界面
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@derzh.com)
-- @copyright: Copyright (c) 2013 EMZ Kingsoft Co., Ltd.
--------------------------------------------------------
-- ###################################################################################################################################################### --
-- : :,,,,,,.,.,.,.,.,......   ;jXFPqq5kFUL2r:.: . ..,.,..... :;iiii:ii7;..........,...,,,,,,:,:,,,:::,:::,:::::::::,:::::::::,:::,:,:::::::::::::::::::. --
-- ,                         ,uXSSS1S2U2Uuuuu7i,::.           ........:::                         . . . . . . . . . . . . . . . . . . . . . . . . . . ..  --
-- : :.,.,.,.,.,.....,...  :q@M0Pq555F5515u2u2UuYj7:         :,,,:,::::i:: ........,...,.,.,.,,,,,.,,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:. --
-- , ,,.,.,.............  7OMEPF515u2u2UULJJujJYY7v7r.  . ....,,,.,,:,:,,.................,.,.,.,.,.,,:,,.,,,,:,:,:,:,:.,,,,,,,.,.,.,.,,,.,,,,:,,,,,,,:,. --
-- , ,.,...............  uBEkSU2U1u2uUJuvjuuLL7v77r;ri,.,,..   . ..,,,,..,.................,.,.,.,.,.,.,.,.,.,.,.,.,,,.,.,..           ....,,,.,,,,,.,,,  --
-- , ,,.,...............v5XXF21U1uFU2JUUuJjvvr7rriii:::.            ..:.. . ..................,...,.,.,.,.,,,.,.,.,.,....   :,;i7YLv7:.    ...,.,.,.,,,,  --
-- , ,................ :Uk1q2Pk5u11uJ55uvuYYv7rrii::,,.              ...    ...................,.,.,.,.,.,.,,,.,.,.,..: ..iO@@BMB@B@B@MMqui  ..,.,.,.,.:  --
-- . .,..............  iPFuUXXX2jJuLJJJvL7v7v7rii::,.                 ...    .................,...,.,.,.,.,.,.,.,.,. 2;iPFNXNE08kYGUSO@B@@@k:  ...,.,.,,. --
-- , ,.,.............. rS1jU1FF1U12jvL7vv7r777ii::...                  ...   . ....................,.,.,.,.,...:,...:5EZL7uE1r   j@P   :7NB@Bq, .,.,.,,:  --
-- . ...,............  iSLYuuU11qXX5122jY7rii::.::,..                   ,,    ........................,.,.,.. ,L,. rEJUi:5S,   :BBJ::.    .S@BM: .,.,.,,. --
-- , ,.,.,............ ;UYvuYjUF555FkSuY7i::.....:.,.                   .:.    . ..................,.,.,.....i7,:..OJr:.Lk  7SB@u. .L@BF    r@Br ..,.,.,  --
-- . ...,............. :SYLY5U1uuLv77ri:,.,.. . .....                   .,,    ................ .......... ,Y,  :.,vi,. rLr,1B2E@BX...O@r:   2@O  ..,.,.  --
-- , ,................  71LUFFSJ7r:,.,......         .                   ,,:.  . ......... ....i:. ... . i;Zr  . ruL. ,.::,7:.:@BB::ri,:X@q. ,B@  .....,  --
-- . ..................  JkFX1jiii:,,.......  ....    .                 ..:::::, .......  :.. .7,1  r7:.,ii@v rrL5.k .70;ri:71@0: .iMB@8r.,, .MB: ......  --
-- , ,..................  u817:,.:::.....,,::i::,,.   .                ..,:iiiir  ..... ,NJ . ::iLvu rL7JFiv::..E7 S8: :jL :5PUr,rjS1::PB@Bu ;PBi ,F7v ,  --
-- . .................... :X0,..755J7ri:::::::i....   .               ..,::i7777i ..... vOr  ivurvPr SUrjL:,20ii;r,uJr:rGPv : :r..:u@X   i,  8PX. .FL:.,. --
-- , ,...................  :E7 :vLriirr7i..:i7r:..   .               ..,:r,  ,ivL, ......:.  .Ui7ULY:r ;2jvu1B2JiL;v571vuikr7 i:rq7ii7i,    7B1, .,r...,  --
-- . .,..................   r5.:irvvu::iL   .::..       .           ..,::      .ii....... .,ii750i.i12,1iLv:v1O@8B8LJU:i, iNSiqJkviiru@@Br 1Ev. ......,.  --
-- , ,.....................  rr.:;i;:..iv.     ...   . .,.       ..,.:::i.   .   ..........,::i: .::i::,,.,:...,.....,,,:5UNur:,.:::..  :0BO:. ..,...,.,  --
-- . .,.,.................... :..::...:7:..   .,,.......:,......:::::,,:i:  . . ...........       ..  ..  .. ..   ..  . .::.. . .  .i7j0@Pi. .,.,.,.,.,,. --
-- , ,.,......................  .i:...ir.:. :, .,,.... ,ri::::.:::,:,::i,. ..........................,.,.,...,.,.,.,,,.....:i7rUX55qGP7:   ....,.,.,.,.:  --
-- . .,......................   .,ri:,LvjU;,,.  ..,.... rri::::::,:::::i, ..........................,.....,.....,.,.,.,...... . ..      ....,.,.,.,.,.,,. --
-- , ,.....,.................  78:.rii;7;r::.:,::,.. :i ,viiii:i:i:i:iir  .........................,.,.....,.,.,...,.,...,.,....... .,.....,.,.,.,.,.,.,  --
-- . ...,.....................UMMOr.:ir7vvvri:::,.. :5:  77iri;iiiiiii7i  ............................,.,.,.,.,...,.,...,.,.,.,....i F,::.,.,.,.,.,.,.,,  --
-- , ,.,...,.,.,.,...........i75ZMBkiii7LLii:i,. . :52   :jLrr;ri;;r7LJ: . ........................,.,.,.,.,.,.,.,.,.,.,.,.,.,.,..,N 5 Lv .....,.,.,.,.,  --
-- , .,.,...,.,........       ,7BOMMGuriiii::.. ..:Yq: .  .i7LuYL7vrrii. ...........................,...,...,.,.,.,...,...,.,...,.,0.山Uv ..,.,.,.,.,..,  --
-- , ,.....,.,......   ..,,.rLL77OM8N0Fu7ri::::::irPu. .,,   .:,,uq:    ...........................,.,.....,.,.....,.,...,.,.......:::,i...,.,.,.....,.,  --
-- . .,.,.,...... ..:iu2v7juEFurrrMO0SSSkuUJJ77iirkq: .,,......  .Y:  . ..........................,...,.,...,.,...,.,.,.,.,.,.,....:,,,::...,.,.,.....,.. --
-- , ,.,.......::;71FkU7jZZM5r;rP:rBOEXXSS2j7;ii71U: ,,:...,.:::,...   . ............................,.,...,.,.,.,.,.,.,.,.,.,....,7;Y71r .,.,.,.......,  --
-- . ...,....,:i7LY7rirL5SE5::;kj;iiSPFuuuL77i:iv;,.,,:.,,:,:,,,::::::,   ........................,.,.,.,...,.,.,.,.,.,...,.,.,....rJ河vi ....,.,.,.,.,,. --
-- , ,.,....,::7ri:ir7Jv7u1r;iiSrv2kv7:.rr  :v7Lr .:,:,,,,,:,::::::::::::,  .........................,.,.,.,.,...,.,...,.,.,...,...5.::S:....,.,.....,.,  --
-- . .,.,...:::ir;7777YirLJrvr:iiuE;i:  v:. ,iru. ,,,,:,:::,:::,:::::,::::: ..............................,.,.,.,.,.,.........,.,..   ........,.,.,...,.  --
-- , ,.,...:rvr:r7ir;J7iivr;r7i:ivX  i  :. ...vJ.,,:::::,,::::,:i:,:,::::::: ........................,.,.,...,.,...... .   ....,...:FL:..............,.,  --
-- . .... .rvLS:ir;iru7:riiirri:7q@.....,:. ..Br .::::,.::::,,ii:,::ii::::i:. ....................,.,.,.........,.....rFrYu:........0:k: .............,,  --
-- , ,... iuvL07:;iir57iir;rrrii78i .:i.:r:...v,..::,,,::::::ii:,::iir,::i:i, .............................,.......,..vq華0: ..... rU九r7........,.....,  --
-- . ... .LYuL05riii7Lurrrr;7;riYS .;rv::::..   ..::,,:::,:,ii:i::;:ri,::i::: ......................,.............,...JjN1Si..... ,r  ,r; ..,.........,.  --
-- , ,.. 7uLjuS0ri:r7Lvr;rir;rii1Z :rri7:::,......::,:::,:,ii:ir,iiir:::ii:i:  ......................,.......,.,.,....,.i:.:...,.. ,. ,. ............,.,  --
-- . .. :LYjjJPM7:ir7vv;rr7rrrirZMJ::iirr,:.......::::::::ii::7i:;ii;:::i::ii ..................,.,.,...,.......,.....  ,   ..... :GS7EGr ..,.....,.,.,,  --
-- , .. vv7jj11@u:i7rv7rr7rri7iL088v:iiiri,,.....::::::::ii:::Yi:r:r:::i:::;:. ......................,.,...,.,...,.,..v U:,7 .... :Ok轉0v .,.,...,...,.,  --
-- . . .227vjSFO0,irr77irrri;r7r20OO7:;;r;:,.....:i:::::ii:::i2:ii7i::iri:iii ..............,...,.......,.,.,...,.,...0 山iu .,.,..uv:v5r ....,.,.,...,.  --
-- , . i7XJvJPFEMr:rrrr7r;iiirir7S0MMU:iirr:.,.. :7i:r:::iii:YL::r7::rriii:i:  ................,...,...,...,.....,....Si57JJ ..,..     . ..........,.,.,  --
-- . ..;rjXvjkqX@O;r7rrii:iiri;i77YJ8BZ7,:ii,....:Y,iriiiii:i27:ivLr7ri:i::i: ................,.........,...,........  .. , .......v7777 ...,.,...,.....  --
-- . . 7rvkuuPqkO@YvLL77vuu7i;irvr;iYG8Bj,:rr:,..:.,:irriii:rSi:rLrvriii:i:i: .....................,.,.....,......... i::7ir ..,...FL風1 ..,...,.,.,...,  --
-- . ..7r7FFUkZ58BkrFU1UUFkriirrur7rrFNN@2,:Lr,,::::::irrii:uu:ivv7;i:::::ii: ..............................,.....,...GJ絕Nv .... :FLk1Si ....,...,.,.,.  --
-- . .,Li72kUkqXN@B7LUJujkur:irv7ivYiFjFE@87i,,:::::::,irr:ik7:7v7i:,,,::::i.  ........................,.,.....,.... ,FukL72 .....::.,.7L .......,...,.,  --
-- . .:LrrUk55EPqM@Pvuuu1FJriivv7:vu;uL7FSG7irr::::::::::7755:7SL;rrrrrri:ii. ..............................,...,.,..,i.r::r....,....  . ...,.....,.....  --
-- . .:L;rYk2FPEqMBE71U1USvr:rL7;rr1v1L7Uui7ri7vi:::::::::2ZriYvir77rr;rriii ....................,.,.......,.....,.,.... ........ :MqUuk: .......,.....,  --
-- . .;LrrL5F2PZOB7.Uj5J12rrirYr7rrj2Fj1EEGYv7r7jri::::::.vU71krii::i:iirri:......................,.,.,.,.,.....,.,...U77k27 .... ,uL飄P: ..,.,.,.......  --
-- . iiJrr7151SOM8 rNu1jS1i7:7vrr7i7F05FPZ8@1YJvvjvri;i:::,,:SEi,i,::iiiiri: ..........................,.,.....,...,. i:頂uF ..,..,5LYrFu .,.,.,.,...,.,  --
--   riv7irYFFk8@U FOYUF0vr7i;v77r7i2Zu1kk0M@kYYLLF7rri::::,:.U0u7i,,:iiii;: ...........................,.........,...U:uvuu .,.....    ,.....,.,...,...  --
--  .riLvii7YkXMB: GZ5j05;rLiii777rruMLLJjuFB@XjuLuUi;i::i:::::7USFUr:::::r: ................,.......,.,.........,.,.,: .  :...,.. L7iiri..,.,.,...,...,  --
-- :LLr7LiLLJ2qOq  ZOS5Pj;LYrirrL77iuMLrYLu75O@01LvYJr2vi;i::::,:iFUU7::iir. .................,.......,.,.,.,...,.,.. ..:.: ..,.,..uP絮7i ,.,...,.,...,.  --
-- rrL;rLr7Y1EO@r  XBONFr7L1;iir7Yri7@j777uJ;Y0@ZFuL7vqSrvrr:iii::UOLi:iiri. ..............................,.,.,.,.,..2u坐ki...... 7GSY5...,...,.....,.,  --
-- ::;;;7ir7vJZ;   vME5777J1J:ri7J7iiMXiLL2UJrv0@G1LivE7iYvr;irr::,7M5i,iir ..............,.....,...,...,.,...,.,.,...7i01;:.......7rL:vi.....,.,.,...,.  --
-- ,.::1SL:rv1X.   jkXvLLYJUFvr;iYvi:SOirLj11uvL0@Mui2E;.Yv7riiL:i:.iPFr:ii .........................,...,.,.......,..iivrii.......  .  ...,.....,.,...,  --
-- v:iFXZOFi,,     kFUujUJuYU12virLii7Mii;vJ15uYjX@@1v82.;7i7rLji:iii7rUv:: ............,.....,.............,.,.,.....  . ....,.............,.,.,.,.,,,,. --
-- Yi7JLuNOEJ:,:  .XNkY1uuYjvJLuri7riiZr:7rLUXuuYu18BGUN17iirvjYLri7:777qL ..................,...,...,...,...,.,.,.,..u7rrii.,.,...,.,.,.,.,.,...,...,.,  --
-- 7i;JY7ivuFXPGO.70ZZ2YUu2UuJYvY;rrr:PLi7v7YuFUUJJj5GMqPku;iLuLSvrrr;7LU1 ...............,.,...,.,.,...,.,.,...,.,.. 7L忘r,..,.,...,...,.,.,...,.....,.. --
-- ::7;7rirYj2UNOuMMXE5juuuuu12Yr7r7rij5::r7rvLUu221uJuEZk5ur77uS177;rruLr ..............,.,.,.,.,.....,.,.,.,.,.....:LY;7Lv...,.....,...,.,...,.,.....,  --
--  :1Liiirir7L7PXO@OSujuJuYYLJJ7rvrrirOi:ii77vvju55k51YU5X5U7rJk5LLrivJ7  .................,.,.....,...,...,.,.,..... ,::. ..,.,.,.,.....,.,.....,...,.. --
-- . LL7;ririrr71FYGBBNFuuJuJjLuv;r7rr:O1.:iirrvvJjU5XqNS2uFSFvLU1LY;rYv. ...............,.,.,.....,.,.,...,.,...,.,. :.,:ii...,...,...,...,.,...,...,.,  --
-- . iJ777ri;rvLU1,v2EBOZSSUujuuurrir;iL@i::ii;irrvLuu5XE0q221X1Ujv7Li.  .................,.,.,...,.,.,.,.,.....,.,...0L經17 .,...,.,.,...,...,.,.,.,.,.. --
-- , .7LLYr;r7;rrX::ivY5FXSP52UUuLr;i;iiqG.::iiiii;77LLjukPqS12NEFL0Bi  .............,.....,.,...,.,.............,....S57Ju; ..,...,.,.,.,.,...,...,.,.,  --
-- , .:vY7i;ririiMGr:::irrvL2U1uuJY7rii:iMr:iii:i:::i;77LLu1Pkkk1.M@@B@E: ............,.,...........,.,...,...,...,..:vr;Yj:......,.,.,.....,.,...,...,.  --
-- : . irii7iri:i@B@Yi:,,,,::i;v7LLjLL77i55irrrriiii:i:iir7YUP2F: B@B@2  ........................,.,.,...,...,.,.,.,..  ...,...,.,.,.,...,.,.,.,.,.,.,.,  --
-- , ...Y7v77rr:i1@BB5NFYvv777rirvLLYLjJu5krv7YJjLjJUjJvj1k1Yr7i  @B@Br ..................,.........,.,.,.,.,.,.,.,.,.,.............,.,.,.,.,.,.,.,.,.,,. --
-- : ,..:vLLvL7riiu@BZO@B@BBOMOMOOGEE8GMB@PJ2SU1kq2Lv2qPuv:,...   B@B@J .........................,.,.,.,.,.,.,.,.,.,.,....     :::,.  ...,.,,,.,,,.,.,.,  --
-- , ,,..rX2uvr;r:,jGLvvuSGM@MBGZ0NSS112ZMk7Lu2v;vSqXvi:      .   kB@M  ..............,.........,.,.,.,.,,,,,.,,,.,.,... .ir7U5uJJuUu7: ..,.,.,.,.,.,.,,. --
-- : ,.. ,FquLLvii::77::,:,:irvFXqXkUUYYLFSL77LSS;::i.    .. .... 7@BE  .......................,.,.,,,,,,,,,,,.,,,,,.. ,vuF:M@.     .7k1, ...,.,.,.,.,.:  --
-- , .,.. :uYvv77ii::i::i...i   .:rLU5YJLiY::.       ,  . .. .... 7B@O  ..........................,.,.,.,.,.,.,,,.,.. v1LFZS@  .,2XUL  rEF. ..,.,,,.,.:,. --
-- : :.,.. 7ujvv7rir:ii:,:.r7..:.. ....vLLi77LYLJ   .......,....  ;@BB  .........................,.,.,.,.,.,.,.,.,.. 5Ui05LMS . E@1@B@L..PM,...,.,.,,,.,  --
-- , ,,.,...LYv77rri;:i:.  ,:.,:....:.18kii7J7.rMU  ,.:..,,   ... iB@B  ......................,.,.,.,.,.,.,.,.,.,., 7P:Mv7JMM ..:jUi .q7:.PO....,.,.,.,,. --
-- , ,,,.,. :Y7L7riiiiiUZF7:  :ii:::::207.,.   .58.......   ...   :@B@  .....................,.,.,.,.,.,.,.,.,.,....E,kki.5LBS.........;i;:@v..,.,.,.,,,  --
-- ,.,,.,....rLvv7L77:,.i7Lu7   . ,.::JGkri:::.i8Y..  .   ...     :B@B  ..........,.........,...,.,.,.,.,.,.,.,.,..:q.@L: :NYO@8L:,ii::irr:q0:..,.,.,.,,. --
-- : :,,.,., .LXPq0u7rii::,,,i.        iYF1vi:;7,  ...        ..   @B@  .........,.,.........,.,.,.,.,.,.,.,.,.,.. rP.BL,. .7uv2M@0i:rii;7:1Zi...,.,.,.,  --
-- ,.::,,,,.. ::..2k1L7rLLvri,:.          .        .,....   ..,..  @@@. ..................,.....,.,.,.,.,.,.,.,.,..:Z PS.  ivuMOY;B@ui77r: 5Gi,.,.,.,.,,. --
-- :.:,,,,,,..     uX1L77JuXkL::.  . .            .. ....,,:,.     8@@. ...,.....,...,...,.,.,.,.,.,.,.,.,.,.,.,... 8;.@: LGrUviMO uBJrJv, @ui...,.,.,,,  --
-- :.,:,:,,.,.....  i,.    .72urri        .       ....,,,..     .. v@B, ....,.,.....,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.. iB,rM.vPrO@P.q, B@rL7:OO7:..,,,.,.,,. --
-- :.:,,,,,,,,.,.,  .:....   :SPYv:      ..    . ..,,,.... .    .. rB@: .,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,,,,,,,.,,,.. rBjvZjkk5OM:iri0@i7jB8L:,.,.,.,.,,:  --
-- :.::,:,:,,.,.,.....:::,.   .r5jv,  ...,. . ..,.... ..      ...  i@B: ,.,.,,,.,,,.,,,,,,,,,.,,,,,,,,,.,,,,,.,,,,,,. :OM11u2257vLvL@UJG@Xvi,.,.,,,,,,:,. --
-- :.:::::,,,:,,.,....,:,,,.     ::......: ... . .   ... .   ... . :@@i .,.,.,.,,,.,,,,,,,,:,:,:,:,:,:,,,,,:,:,:,:,:,...rZMOX1u1FkE@B8MZJ7:..,,:,,,:,,,:. --
-- :.::,:,,,:,,,,,,....::,,,,...  ..... ,,  ... . ..... ... ..     r@Br ,.,,,.,.,.,,,,,,,,:,:,:,:,:,:,:,,,:,,,:,:,:,,,,...iJPEO8OZ011uvi:.,.,,:,:,:,:,::. --
-- :.:::,:,,,,,:,,,.,..:::::,..  . ......,...... ..,.      .   .   rB@7 .,.,.,,,.,,,,,,,,:,:,:::,:,:,:,:,:,:,,,,,,,:,:,,.....::iii::,:.....,,:,:,:,:,:,:. --
-- :.::::,:,,,:,,,,.:,ri:::::::.........,.... .....   . ...   .    :@@7  .,.,,,,,,,,:,,,,,:,:,:,:,,,:,,,,,,,:,:,:,,,:,::,,,...........,.,,:,:,:,:,:,:,:,. --
-- :.:::,:,:,:,:,,,.:i:77;:,,:,,...,,:,:::...,..     . . . ... .   rB@7 i: ,,:,,,,,,,:,,,,,:,:,:,:,:,:,:,:,:,:,:,,,:,:,:,:,:,:,,.,,,,:,,::,:,:,,,:,:,,,:. --
-- :.::::,:,:,:,,,,,,ii:irL77r7rri:,,,i7LJZL:.                  .. v@BMu@u .,,:,,,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,. --
-- :.:::::::::::,:::.:ii:iirrr;7rr7rirr7ii7Err::,:,:::,,,:::,..,.. UBM@@B@. .:,:,:::,:,:,:,:,:,:,:::::::::::::::::::::::::::::::::::::::::::::,:::::::::. --
-- : ............ ... ,,,.,..         .:;i:rir7rr;rii::..          k@BF :O@J. . ........................................................................  --
-- ###################################################################################################################################################### --

---------------------------------------------------------------------------------------------
-- these global functions are accessed all the time by the event handler
-- so caching them is worth the effort
---------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local ipairs, pairs, next, pcall = ipairs, pairs, next, pcall
local sub, len, format, rep = string.sub, string.len, string.format, string.rep
local find, byte, char, gsub = string.find, string.byte, string.char, string.gsub
local type, tonumber, tostring = type, tonumber, tostring
local HUGE, PI, random = math.huge, math.pi, math.random
local min, max, floor, ceil = math.min, math.max, math.floor, math.ceil
local pow, sqrt, sin, cos, tan = math.pow, math.sqrt, math.sin, math.cos, math.tan
local insert, remove, concat, sort = table.insert, table.remove, table.concat, table.sort
local pack, unpack = table.pack or function(...) return {...} end, table.unpack or unpack
-- jx3 apis caching
local wsub, wlen, wfind = wstring.sub, wstring.len, wstring.find
local GetTime, GetLogicFrameCount = GetTime, GetLogicFrameCount
local GetClientPlayer, GetPlayer, GetNpc = GetClientPlayer, GetPlayer, GetNpc
local GetClientTeam, UI_GetClientPlayerID = GetClientTeam, UI_GetClientPlayerID
---------------------------------------------------------------------------------------------
-- 本地函数变量
---------------------------------------------------------------------------------------------
local _BUILD_                = '20191024'
local _VERSION_              = 0x2014500
local _MENU_COLOR_           = {255, 165, 79}
local _MAX_PLAYER_LEVEL_     = 100
local _INTERFACE_ROOT_       = './Interface/'
local _NAME_SPACE_           = 'MY'
local _ADDON_ROOT_           = _INTERFACE_ROOT_ .. 'MY/'
local _DATA_ROOT_            = _INTERFACE_ROOT_ .. 'MY#DATA/'
local _FRAMEWORK_ROOT_       = _INTERFACE_ROOT_ .. 'MY/MY_!Base/'
local _PSS_ST_               = _FRAMEWORK_ROOT_ .. 'img/ST.pss'
local _UITEX_ST_             = _FRAMEWORK_ROOT_ .. 'img/ST_UI.UITex'
local _UITEX_COMMON_         = _FRAMEWORK_ROOT_ .. 'img/UICommon.UITex'
local _UICOMPONENT_ROOT_     = _FRAMEWORK_ROOT_ .. 'ui/components/'
local _UITEX_POSTER_         = _ADDON_ROOT_ .. 'MY_Resource/img/Poster.UITex'
local _MAINICON_FRAME_       = 15
local _MENUICON_FRAME_       = 14
local _MENUICON_HOVER_FRAME_ = 14
local _DEBUG_LEVEL_          = tonumber(LoadLUAData(_DATA_ROOT_ .. 'debug.level.jx3dat') or nil) or 4
local _DELOG_LEVEL_          = tonumber(LoadLUAData(_DATA_ROOT_ .. 'delog.level.jx3dat') or nil) or 4
local _NORESTIME_            = tonumber(LoadLUAData(_DATA_ROOT_ .. 'nrtim.level.jx3dat') or nil) or -1
-----------------------------------------------
-- 加载语言包
-----------------------------------------------
local function LoadLangPack(szLangFolder)
	local _, _, szLang = GetVersion()
	local t0 = LoadLUAData(_FRAMEWORK_ROOT_..'lang/default') or {}
	local t1 = LoadLUAData(_FRAMEWORK_ROOT_..'lang/' .. szLang) or {}
	for k, v in pairs(t1) do
		t0[k] = v
	end
	if type(szLangFolder)=='string' then
		szLangFolder = string.gsub(szLangFolder,'[/\\]+$','')
		local t2 = LoadLUAData(szLangFolder..'/default') or {}
		for k, v in pairs(t2) do
			t0[k] = v
		end
		local t3 = LoadLUAData(szLangFolder..'/' .. szLang) or {}
		for k, v in pairs(t3) do
			t0[k] = v
		end
	end
	setmetatable(t0, {
		__index = function(t, k) return k end,
		__call = function(t, k, ...) return string.format(t[k], ...) end,
	})
	return t0
end
local _L = LoadLangPack()
local _NAME_             = _L.PLUGIN_NAME
local _SHORT_NAME_       = _L.PLUGIN_SHORT_NAME
local _AUTHOR_           = _L.PLUGIN_AUTHOR
local _AUTHOR_WEIBO_     = _L.PLUGIN_AUTHOR_WEIBO
local _AUTHOR_WEIBO_URL_ = 'https://weibo.com/zymah'
local _AUTHOR_SIGNATURE_ = _L.PLUGIN_AUTHOR_SIGNATURE
local _AUTHOR_ROLES_     = {
	[43567   ] = string.char( 0xDC, 0xF8, 0xD2, 0xC1 ), -- 体服
	[3007396 ] = string.char( 0xDC, 0xF8, 0xD2, 0xC1 ), -- 枫泾古镇
	[1600498 ] = string.char( 0xDC, 0xF8, 0xD2, 0xC1 ), -- 追风蹑影
	[4664780 ] = string.char( 0xDC, 0xF8, 0xD2, 0xC1 ), -- 日月明尊
	[17796954] = string.char( 0xDC, 0xF8, 0xD2, 0xC1, 0x40, 0xB0, 0xD7, 0xB5, 0xDB, 0xB3, 0xC7 ), -- 唯我独尊->枫泾古镇
	[385183  ] = string.char( 0xE8, 0x8C, 0x97, 0xE4, 0xBC, 0x8A ), -- 傲血戰意
	[1452025 ] = string.char( 0xE8, 0x8C, 0x97, 0xE4, 0xBC, 0x8A, 0xE4, 0xBC, 0x8A ), -- 巔峰再起
	[3627405 ] = string.char( 0xC1, 0xFA, 0xB5, 0xA8, 0xC9, 0xDF, 0x40, 0xDD, 0xB6, 0xBB, 0xA8, 0xB9, 0xAC ), -- 白帝
	-- [4662931] = string.char( 0xBE, 0xCD, 0xCA, 0xC7, 0xB8, 0xF6, 0xD5, 0xF3, 0xD1, 0xDB ), -- 日月明尊
	-- [3438030] = string.char( 0xB4, 0xE5, 0xBF, 0xDA, 0xB5, 0xC4, 0xCD, 0xF5, 0xCA, 0xA6, 0xB8, 0xB5 ), -- 枫泾古镇
}
Log('[' .. _NAME_SPACE_ .. '] Debug level ' .. _DEBUG_LEVEL_ .. ' / delog level ' .. _DELOG_LEVEL_)
---------------------------------------------------------------------------------------------
-- 通用函数
---------------------------------------------------------------------------------------------
-----------------------------------------------
-- 克隆数据
-----------------------------------------------
local Clone = clone
-----------------------------------------------
-- 数据设为只读
-----------------------------------------------
local SetmetaReadonly = SetmetaReadonly or function(t)
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
-----------------------------------------------
-- Lua数据序列化
-----------------------------------------------
local EncodeLUAData = var2str
-----------------------------------------------
-- Lua数据反序列化
-----------------------------------------------
local DecodeLUAData = str2var
if not DecodeLUAData then
local szTempLog = 'interface/temp.log'
local szTempJx3dat = 'interface/temp.jx3dat'
function DecodeLUAData(szText)
	Log(szTempLog, szText, 'clear close')
	CPath.Move(szTempLog, szTempJx3dat)
	local data = LoadLUAData(szTempJx3dat)
	CPath.DelFile(szTempJx3dat)
	return data
end
end
-----------------------------------------------
-- 读取数据
-----------------------------------------------
local function Get(var, keys, dft)
	local res = false
	if type(keys) == 'string' then
		local ks = {}
		for k in string.gmatch(keys, '[^%.]+') do
			insert(ks, k)
		end
		keys = ks
	end
	if type(keys) == 'table' then
		for _, k in ipairs(keys) do
			if type(var) == 'table' then
				var, res = var[k], true
			else
				var, res = dft, false
				break
			end
		end
	end
	if var == nil then
		var, res = dft, false
	end
	return var, res
end
-----------------------------------------------
-- 设置数据
-----------------------------------------------
local function Set(var, keys, val)
	local res = false
	if type(keys) == 'string' then
		local ks = {}
		for k in string.gmatch(keys, '[^%.]+') do
			insert(ks, k)
		end
		keys = ks
	end
	if type(keys) == 'table' then
		local n = #keys
		for i = 1, n do
			local k = keys[i]
			if type(var) == 'table' then
				if i == n then
					var[k], res = val, true
				else
					if var[k] == nil then
						var[k] = {}
					end
					var = var[k]
				end
			else
				break
			end
		end
	end
	return res
end
-----------------------------------------------
-- 判断是否为空
-----------------------------------------------
local function IsEmpty(var)
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
-----------------------------------------------
-- 深度判断相等
-----------------------------------------------
local function IsEquals(o1, o2)
	if o1 == o2 then
		return true
	elseif type(o1) ~= type(o2) then
		return false
	elseif type(o1) == 'table' then
		local t = {}
		for k, v in pairs(o1) do
			if IsEquals(o1[k], o2[k]) then
				t[k] = true
			else
				return false
			end
		end
		for k, v in pairs(o2) do
			if not t[k] then
				return false
			end
		end
		return true
	end
	return false
end
-----------------------------------------------
-- 数组随机
-----------------------------------------------
local function RandomChild(var)
	if type(var) == 'table' and #var > 0 then
		return var[random(1, #var)]
	end
end
-----------------------------------------------
-- 基础类型判断
-----------------------------------------------
local function IsArray(var)
	if type(var) ~= 'table' then
		return false
	end
	local i = 1
	for k, _ in pairs(var) do
		if k ~= i then
			return false
		end
		i = i + 1
	end
	return true
end
local function IsDictionary(var)
	if type(var) ~= 'table' then
		return false
	end
	local i = 1
	for k, _ in pairs(var) do
		if k ~= i then
			return true
		end
		i = i + 1
	end
	return false
end
local function IsNil     (var) return type(var) == 'nil'      end
local function IsTable   (var) return type(var) == 'table'    end
local function IsNumber  (var) return type(var) == 'number'   end
local function IsString  (var) return type(var) == 'string'   end
local function IsBoolean (var) return type(var) == 'boolean'  end
local function IsFunction(var) return type(var) == 'function' end
local function IsUserdata(var) return type(var) == 'userdata' end
local function IsHugeNumber(var) return IsNumber(var) and not (var < HUGE) end
-----------------------------------------------
-- 创建数据补丁
-----------------------------------------------
local function GetPatch(oBase, oData)
	-- dictionary patch
	if IsDictionary(oData) or (IsDictionary(oBase) and IsTable(oData) and IsEmpty(oData)) then
		-- dictionary raw value patch
		if not IsTable(oBase) then
			return { v = oData }
		end
		-- dictionary children patch
		local tKeys, bDiff = {}, false
		local oPatch = {}
		for k, v in pairs(oData) do
			local patch = GetPatch(oBase[k], v)
			if not IsNil(patch) then
				bDiff = true
				insert(oPatch, { k = k, v = patch })
			end
			tKeys[k] = true
		end
		for k, v in pairs(oBase) do
			if not tKeys[k] then
				bDiff = true
				insert(oPatch, { k = k, v = nil })
			end
		end
		if not bDiff then
			return nil
		end
		return oPatch
	end
	if not IsEquals(oBase, oData) then
		-- nil value patch
		if IsNil(oData) then
			return { t = 'nil' }
		end
		-- other patch value
		return { v= oData }
	end
	-- empty patch
	return nil
end
-----------------------------------------------
-- 数据应用补丁
-----------------------------------------------
local function ApplyPatch(oBase, oPatch, bNew)
	if bNew ~= false then
		oBase = Clone(oBase)
		oPatch = Clone(oPatch)
	end
	-- patch in dictionary type can only be a special value patch
	if IsDictionary(oPatch) then
		-- nil value patch
		if oPatch.t == 'nil' then
			return nil
		end
		-- raw value patch
		if oPatch.v then
			return oPatch.v
		end
	end
	-- dictionary patch
	if IsTable(oPatch) and IsDictionary(oPatch[1]) then
		if not IsTable(oBase) then
			oBase = {}
		end
		for _, patch in ipairs(oPatch) do
			if IsNil(patch.v) then
				oBase[patch.k] = nil
			else
				oBase[patch.k] = ApplyPatch(oBase[patch.k], patch.v, false)
			end
		end
		return oBase
	end
	-- empty patch
	if IsNil(oPatch) then
		return oBase
	end
	-- other patch value
	return oPatch
end
-----------------------------------------------
-- 选代器 倒序
-----------------------------------------------
local ipairs_r
do
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
-----------------------------------------------
-- 只读表选代器
-----------------------------------------------
-- -- 只读表字典枚举
-- local pairs_c = pairs_c or function(t, ...)
-- 	if type(t) == 'table' then
-- 		local metatable = getmetatable(t)
-- 		if type(metatable) == 'table' and metatable.const_table then
-- 			return pairs(metatable.const_table, ...)
-- 		end
-- 	end
-- 	return pairs(t, ...)
-- end
-- -- 只读表数组枚举
-- local ipairs_c = ipairs_c or function(t, ...)
-- 	if type(t) == 'table' then
-- 		local metatable = getmetatable(t)
-- 		if type(metatable) == 'table' and metatable.const_table then
-- 			return ipairs(metatable.const_table, ...)
-- 		end
-- 	end
-- 	return ipairs(t, ...)
-- end
-----------------------------------------------
-- 类型安全选代器
-----------------------------------------------
local spairs, sipairs, spairs_r, sipairs_r
do
local function SafeIter(a, i)
	i = i + 1
	if a[i] then
		return i, a[i][1], a[i][2], a[i][3]
	end
end
function sipairs(...)
	local argc = select('#', ...)
	local argv = {...}
	local iters = {}
	for i = 1, argc do
		if IsTable(argv[i]) then
			for j, v in ipairs(argv[i]) do
				insert(iters, {v, argv[i], j})
			end
		end
	end
	return SafeIter, iters, 0
end
function spairs(...)
	local argc = select('#', ...)
	local argv = {...}
	local iters = {}
	for i = 1, argc do
		if IsTable(argv[i]) then
			for j, v in pairs(argv[i]) do
				insert(iters, {v, argv[i], j})
			end
		end
	end
	return SafeIter, iters, 0
end
local function SafeIterR(a, i)
	i = i - 1
	if i > 0 then
		return i, a[i][1], a[i][2], a[i][3]
	end
end
function sipairs_r(...)
	local argc = select('#', ...)
	local argv = {...}
	local iters = {}
	for i = 1, argc do
		if IsTable(argv[i]) then
			for j, v in ipairs(argv[i]) do
				insert(iters, {v, argv[i], j})
			end
		end
	end
	return SafeIterR, iters, 0
end
function spairs_r(...)
	local argc = select('#', ...)
	local argv = {...}
	local iters = {}
	for i = 1, argc do
		if IsTable(argv[i]) then
			for j, v in pairs(argv[i]) do
				insert(iters, {v, argv[i], j})
			end
		end
	end
	return SafeIterR, iters, 0
end
end
-----------------------------------------------
-- 类
-----------------------------------------------
local Class
do
local function createInstance(c, ins, ...)
	if not ins then
		ins = c
	end
	if c.ctor then
		c.ctor(ins, ...)
	end
	return c
end
function Class(className, super)
	if type(super) == 'string' then
		className, super = super
	end
	if not className then
		className = 'Unnamed Class'
	end
	local classPrototype = (function ()
		local proxys = {}
		if super then
			proxys.super = super
			setmetatable(proxys, { __index = super })
		end
		return setmetatable({}, {
			__index = proxys,
			__tostring = function(t) return className .. ' (class prototype)' end,
			__call = function (...)
				return createInstance(setmetatable({}, {
					__index = classPrototype,
					__tostring = function(t) return className .. ' (class instance)' end,
				}), nil, ...)
			end,
		})
	end)()
	return classPrototype
end
end
-----------------------------------------------
-- 获取调用栈
-----------------------------------------------
local TRACEBACK_DEL = ('\n[^\n]*' .. _NAME_SPACE_ .. '%.lua:%d+:%sin%sfunction%s\'GetTraceback\'[^\n]*'):gsub("(%%?)(.)", function(percent, letter)
    if percent ~= "" or not letter:match("%a") then
		-- if the '%' matched, or `letter` is not a letter, return "as is"
		return percent .. letter
    else
		-- else, return a case-insensitive character class of the matched letter
		return string.format("[%s%s]", letter:lower(), letter:upper())
    end
end)
local function GetTraceback(str)
	local traceback = debug and debug.traceback and debug.traceback():gsub(TRACEBACK_DEL, '')
	if traceback then
		if str then
			str = str .. '\n' .. traceback
		else
			str = traceback
		end
	end
	return str or ''
end
-----------------------------------------------
-- 安全调用
-----------------------------------------------
local Call, XpCall
do
local xpAction, xpArgs, xpErrMsg, xpTraceback
local function CallHandler()
	return xpAction(unpack(xpArgs))
end
local function CallErrorHandler(errMsg)
	xpErrMsg = errMsg
	xpTraceback = GetTraceback()
	FireUIEvent("CALL_LUA_ERROR", GetTraceback(errMsg) .. '\n')
end
local function XpCallErrorHandler(errMsg)
	xpErrMsg = errMsg
	xpTraceback = GetTraceback()
end
function Call(arg0, ...)
	xpAction, xpArgs, xpErrMsg, xpTraceback = arg0, {...}
	local res = {xpcall(CallHandler, ErrorHandler)}
	if not res[1] then
		res[2] = xpErrMsg
		res[3] = xpTraceback
	end
	xpAction, xpArgs, xpErrMsg, xpTraceback = nil
	return unpack(res)
end
function XpCall(arg0, ...)
	xpAction, xpArgs, xpErrMsg, xpTraceback = arg0, {...}
	local res = {xpcall(CallHandler, XpCallErrorHandler)}
	if not res[1] then
		res[2] = xpErrMsg
		res[3] = xpTraceback
	end
	xpAction, xpArgs, xpErrMsg, xpTraceback = nil
	return unpack(res)
end
end
-----------------------------------------------
-- 插件集信息
-----------------------------------------------
local PACKET_INFO
do
local tInfo = {
	NAME                 = _NAME_                ,
	SHORT_NAME           = _SHORT_NAME_          ,
	UITEX_COMMON         = _UITEX_COMMON_        ,
	UITEX_POSTER         = _UITEX_POSTER_        ,
	UITEX_ST             = _UITEX_ST_            ,
	MAINICON_FRAME       = _MAINICON_FRAME_      ,
	MENUICON_FRAME       = _MENUICON_FRAME_      ,
	MENUICON_HOVER_FRAME = _MENUICON_HOVER_FRAME_,
	UICOMPONENT_ROOT     = _UICOMPONENT_ROOT_    ,
	VERSION              = _VERSION_             ,
	BUILD                = _BUILD_               ,
	NAME_SPACE           = _NAME_SPACE_          ,
	DEBUG_LEVEL          = _DEBUG_LEVEL_         ,
	DELOG_LEVEL          = _DELOG_LEVEL_         ,
	INTERFACE_ROOT       = _INTERFACE_ROOT_      ,
	ROOT                 = _ADDON_ROOT_          ,
	DATA_ROOT            = _DATA_ROOT_           ,
	FRAMEWORK_ROOT       = _FRAMEWORK_ROOT_      ,
	AUTHOR               = _AUTHOR_              ,
	AUTHOR_WEIBO         = _AUTHOR_WEIBO_        ,
	AUTHOR_WEIBO_URL     = _AUTHOR_WEIBO_URL_    ,
	AUTHOR_SIGNATURE     = _AUTHOR_SIGNATURE_    ,
	AUTHOR_ROLES         = _AUTHOR_ROLES_        ,
	MENU_COLOR           = _MENU_COLOR_          ,
	MAX_PLAYER_LEVEL     = _MAX_PLAYER_LEVEL_    ,
}
PACKET_INFO = SetmetaReadonly(tInfo)
-- 更新最高玩家等级数据
local function onPlayerEnterScene()
	_MAX_PLAYER_LEVEL_ = max(_MAX_PLAYER_LEVEL_, GetClientPlayer().nMaxLevel)
	tInfo.MAX_PLAYER_LEVEL = _MAX_PLAYER_LEVEL_
end
RegisterEvent('PLAYER_ENTER_SCENE', onPlayerEnterScene)
end
-----------------------------------------------
-- 枚举
-----------------------------------------------
local DEBUG_LEVEL = SetmetaReadonly({
	PMLOG   = 0,
	LOG     = 1,
	WARNING = 2,
	ERROR   = 3,
	DEBUG   = 3,
})
local PATH_TYPE = SetmetaReadonly({
	NORMAL = 0,
	DATA   = 1,
	ROLE   = 2,
	GLOBAL = 3,
	SERVER = 4,
})
local CONSTANT = setmetatable({}, {
	__index = {
		MENU_DIVIDER = SetmetaReadonly({ bDevide = true }),
		EMPTY_TABLE = SetmetaReadonly({}),
		XML_LINE_BREAKER = GetFormatText('\n'),
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
		FORCE_TYPE = FORCE_TYPE or SetmetaReadonly({
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
		}),
		KUNGFU_TYPE = KUNGFU_TYPE or SetmetaReadonly({
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
		}),
		PEEK_OTHER_PLAYER_RESPOND = PEEK_OTHER_PLAYER_RESPOND or SetmetaReadonly({
			INVALID             = 0,
			SUCCESS             = 1,
			FAILED              = 2,
			CAN_NOT_FIND_PLAYER = 3,
			TOO_FAR             = 4,
		}),
		WND_CONTAINER_STYLE = WND_CONTAINER_STYLE or SetmetaReadonly({
			WND_CONTAINER_STYLE_CUSTOM       = 0,
			WND_CONTAINER_STYLE_LEFT_TOP     = 1,
			WND_CONTAINER_STYLE_LEFT_BOTTOM  = 2,
			WND_CONTAINER_STYLE_RIGHT_TOP    = 3,
			WND_CONTAINER_STYLE_RIGHT_BOTTOM = 4,
			WND_CONTAINER_STYLE_END          = 5,
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
		-- skillid, uitex, frame
		KUNGFU_LIST = {
			-- MT
			{ dwID = 10062, szUITex = 'ui/Image/icon/skill_tiance01.UITex',     nFrame = 0 }, -- 铁牢
			{ dwID = 10243, szUITex = 'ui/Image/icon/mingjiao_taolu_7.UITex',   nFrame = 0 }, -- 明尊
			{ dwID = 10389, szUITex = 'ui/Image/icon/Skill_CangY_33.UITex',     nFrame = 0 }, -- 铁骨
			{ dwID = 10002, szUITex = 'ui/Image/icon/skill_shaolin14.UITex',    nFrame = 0 }, -- 少林
			-- 治疗
			{ dwID = 10080, szUITex = 'ui/Image/icon/skill_qixiu02.UITex',      nFrame = 0 }, -- 云裳
			{ dwID = 10176, szUITex = 'ui/Image/icon/wudu_neigong_2.UITex',     nFrame = 0 }, -- 补天
			{ dwID = 10028, szUITex = 'ui/Image/icon/skill_wanhua23.UITex',     nFrame = 0 }, -- 离经
			{ dwID = 10448, szUITex = 'ui/Image/icon/skill_0514_23.UITex',      nFrame = 0 }, -- 相知
			-- 内功
			{ dwID = 10225, szUITex = 'ui/Image/icon/skill_tangm_20.UITex',     nFrame = 0 }, -- 天罗
			{ dwID = 10081, szUITex = 'ui/Image/icon/skill_qixiu03.UITex',      nFrame = 0 }, -- 冰心
			{ dwID = 10175, szUITex = 'ui/Image/icon/wudu_neigong_1.UITex',     nFrame = 0 }, -- 毒经
			{ dwID = 10242, szUITex = 'ui/Image/icon/mingjiao_taolu_8.UITex',   nFrame = 0 }, -- 焚影
			{ dwID = 10014, szUITex = 'ui/Image/icon/skill_chunyang21.UITex',   nFrame = 0 }, -- 紫霞
			{ dwID = 10021, szUITex = 'ui/Image/icon/skill_wanhua17.UITex',     nFrame = 0 }, -- 花间
			{ dwID = 10003, szUITex = 'ui/Image/icon/skill_shaolin10.UITex',    nFrame = 0 }, -- 易经
			{ dwID = 10447, szUITex = 'ui/Image/icon/skill_0514_27.UITex',      nFrame = 0 }, -- 莫问
			-- 外功
			{ dwID = 10390, szUITex = 'ui/Image/icon/Skill_CangY_32.UITex',     nFrame = 0 }, -- 分山
			{ dwID = 10224, szUITex = 'ui/Image/icon/skill_tangm_01.UITex',     nFrame = 0 }, -- 鲸鱼
			{ dwID = 10144, szUITex = 'ui/Image/icon/cangjian_neigong_1.UITex', nFrame = 0 }, -- 问水
			{ dwID = 10145, szUITex = 'ui/Image/icon/cangjian_neigong_2.UITex', nFrame = 0 }, -- 山居
			{ dwID = 10015, szUITex = 'ui/Image/icon/skill_chunyang13.UITex',   nFrame = 0 }, -- 剑纯
			{ dwID = 10026, szUITex = 'ui/Image/icon/skill_tiance02.UITex',     nFrame = 0 }, -- 傲雪
			{ dwID = 10268, szUITex = 'ui/Image/icon/skill_GB_30.UITex',        nFrame = 0 }, -- 笑尘
			{ dwID = 10464, szUITex = 'ui/Image/icon/daoj_16_8_25_16.UITex',    nFrame = 0 }, -- 霸刀
			{ dwID = 10533, szUITex = 'ui/image/icon/jnpl_18_10_30_27.uitex',   nFrame = 45 }, -- 蓬莱
			{ dwID = 10533, szUITex = 'ui/image/icon/jnlxg_19_10_21_9.uitex',   nFrame = 74 }, -- 凌雪
		},
		EQUIPMENT_SUIT_COUNT = EQUIPMENT_SUIT_COUNT or 4,
		INVENTORY_GUILD_BANK = INVENTORY_GUILD_BANK or INVENTORY_INDEX.TOTAL + 1, --帮会仓库界面虚拟一个背包位置
		INVENTORY_GUILD_PAGE_SIZE = INVENTORY_GUILD_PAGE_SIZE or 100,
	},
	__newindex = function() end,
})
---------------------------------------------------------------------------------------------
local LIB = {
	count_c          = count_c         ,
	pairs_c          = pairs_c         ,
	ipairs_c         = ipairs_c        ,
	ipairs_r         = ipairs_r        ,
	spairs           = spairs          ,
	spairs_r         = spairs_r        ,
	sipairs          = sipairs         ,
	sipairs_r        = sipairs_r       ,
	IsArray          = IsArray         ,
	IsDictionary     = IsDictionary    ,
	IsEquals         = IsEquals        ,
	IsNil            = IsNil           ,
	IsBoolean        = IsBoolean       ,
	IsNumber         = IsNumber        ,
	IsUserdata       = IsUserdata      ,
	IsHugeNumber     = IsHugeNumber    ,
	IsEmpty          = IsEmpty         ,
	IsString         = IsString        ,
	IsTable          = IsTable         ,
	IsFunction       = IsFunction      ,
	Clone            = Clone           ,
	Call             = Call            ,
	XpCall           = XpCall          ,
	SetmetaReadonly  = SetmetaReadonly ,
	Set              = Set             ,
	Get              = Get             ,
	Class            = Class           ,
	GetPatch         = GetPatch        ,
	ApplyPatch       = ApplyPatch      ,
	EncodeLUAData    = EncodeLUAData   ,
	DecodeLUAData    = DecodeLUAData   ,
	RandomChild      = RandomChild     ,
	GetTraceback     = GetTraceback    ,
	LoadLangPack     = LoadLangPack    ,
	CONSTANT         = CONSTANT        ,
	PATH_TYPE        = PATH_TYPE       ,
	DEBUG_LEVEL      = DEBUG_LEVEL     ,
	PACKET_INFO      = PACKET_INFO     ,
}
_G[_NAME_SPACE_] = LIB
---------------------------------------------------------------------------------------------

-----------------------------------------------
-- 基础函数
-----------------------------------------------

-- (string, number) LIB.GetVersion()
function LIB.GetVersion(dwVersion)
	local dwVersion = dwVersion or _VERSION_
	local szVersion = string.format('%X.%X.%02X', dwVersion / 0x1000000,
		math.floor(dwVersion / 0x10000) % 0x100, math.floor(dwVersion / 0x100) % 0x100)
	if  dwVersion % 0x100 ~= 0 then
		szVersion = szVersion .. 'b' .. tostring(dwVersion % 0x100)
	end
	return szVersion, dwVersion
end

function LIB.AssertVersion(szKey, szCaption, dwMinVersion)
	if _VERSION_ < dwMinVersion then
		LIB.Sysmsg({
			_L('%s requires base library version upper than v%s, current at v%s.',
			szCaption, LIB.GetVersion(dwMinVersion), LIB.GetVersion()
		)})
		if not IsDebugClient() then
			return false
		end
	end
	return true
end

-----------------------------------------------
-- HOOK 全局声音表
-----------------------------------------------
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

---------------------------------------------------
-- 事件、快捷键、菜单注册
---------------------------------------------------
if _DEBUG_LEVEL_ <= DEBUG_LEVEL.DEBUG then
	if not ECHO_LUA_ERROR then
		ECHO_LUA_ERROR = { ID = PACKET_INFO.NAME_SPACE }
	elseif IsTable(ECHO_LUA_ERROR) then
		ECHO_LUA_ERROR.ID = PACKET_INFO.NAME_SPACE
	end
	RegisterEvent('CALL_LUA_ERROR', function()
		if ECHO_LUA_ERROR and ECHO_LUA_ERROR.ID == PACKET_INFO.NAME_SPACE then
			print(arg0)
			OutputMessage('MSG_SYS', arg0)
		end
	end)
	TraceButton_AppendAddonMenu({{
		szOption = 'ReloadUIAddon',
		fnAction = function()
			ReloadUIAddon()
		end,
	}})
end

if _NORESTIME_ >= 0 then
	local time = GetTime()

	local function OnExit()
		debug.sethook()
	end
	RegisterEvent('RELOAD_UI_ADDON_BEGIN', OnExit)

	local function OnBreathe()
		time = GetTime()
	end
	BreatheCall('_NORESTIME_', OnBreathe)

	local function trace_line(event, line)
		local delay = GetTime() - time
		if delay < _NORESTIME_ then
			return
		end
		Log('Response over ' .. delay .. ', ' .. debug.getinfo(2).short_src .. ':' .. line)
	end
	debug.sethook(trace_line, 'l')
end
