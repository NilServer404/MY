--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : 喊话辅助
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@derzh.com)
-- @copyright: Copyright (c) 2013 EMZ Kingsoft Co., Ltd.
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
local PLUGIN_NAME = 'MY_Chat'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_TalkEx'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^9.0.0') then
	return
end
--------------------------------------------------------------------------
local D = {
	dwTalkTick = 0,
	dwTalkCDTime = 0,
}
local O = X.CreateUserSettingsModule('MY_TalkEx', _L['Chat'], {
	szTalkText = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_TalkEx'],
		xSchema = X.Schema.String,
		xDefaultValue = '',
	},
	aTalkChannel = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_TalkEx'],
		xSchema = X.Schema.Collection(X.Schema.Number),
		xDefaultValue = {},
	},
	nTrickChannel = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_TalkEx'],
		xSchema = X.Schema.Number,
		xDefaultValue = PLAYER_TALK_CHANNEL.RAID,
	},
	szTrickFilter = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_TalkEx'],
		xSchema = X.Schema.String,
		xDefaultValue = 'RAID',
	},
	nTrickForce = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_TalkEx'],
		xSchema = X.Schema.Number,
		xDefaultValue = CONSTANT.FORCE_TYPE.CHUN_YANG,
	},
	szTrickTextBegin = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_TalkEx'],
		xSchema = X.Schema.String,
		xDefaultValue = _L['$zj look around and have a little thought.'],
	},
	szTrickText = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_TalkEx'],
		xSchema = X.Schema.String,
		xDefaultValue = _L['$zj epilate $mb\'s feather clearly.'],
	},
	szTrickTextEnd = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_TalkEx'],
		xSchema = X.Schema.String,
		xDefaultValue = _L['$zj collected the feather epilated just now and wanted it sold well.'],
	},
})

--------------------------------------------------------------------------

local TALK_CHANNEL_LIST = {
	{ nChannel = PLAYER_TALK_CHANNEL.NEARBY       , szID = 'MSG_NORMAL'         },
	{ nChannel = PLAYER_TALK_CHANNEL.TEAM         , szID = 'MSG_PARTY'          },
	{ nChannel = PLAYER_TALK_CHANNEL.RAID         , szID = 'MSG_TEAM'           },
	{ nChannel = PLAYER_TALK_CHANNEL.TONG         , szID = 'MSG_GUILD'          },
	{ nChannel = PLAYER_TALK_CHANNEL.TONG_ALLIANCE, szID = 'MSG_GUILD_ALLIANCE' },
}

local FORCE_LIST = {
	-- { dwForceID = -1, szLabel = _L['Everyone'] },
}
for i, v in pairs(g_tStrings.tForceTitle) do
	table.insert(FORCE_LIST, { dwForceID = i, szLabel = v })
end
table.sort(FORCE_LIST, function(a, b) return a.dwForceID < b.dwForceID end)

local TRICK_FILTER_LIST = {
	-- { szKey = 'NEARBY', szLabel = _L['Nearby players where'] },
	{ szKey = 'RAID'  , szLabel = _L['Teammates where'     ] },
}

local TRICK_CHANNEL_LIST = {
	{ nChannel = PLAYER_TALK_CHANNEL.TEAM         , szName = _L['PTC_TEAM_CHANNEL' ], tCol = GetMsgFontColor('MSG_TEAM'          , true) },
	{ nChannel = PLAYER_TALK_CHANNEL.RAID         , szName = _L['PTC_RAID_CHANNEL' ], tCol = GetMsgFontColor('MSG_TEAM'          , true) },
	{ nChannel = PLAYER_TALK_CHANNEL.TONG         , szName = _L['PTC_TONG_CHANNEL' ], tCol = GetMsgFontColor('MSG_GUILD'         , true) },
	{ nChannel = PLAYER_TALK_CHANNEL.TONG_ALLIANCE, szName = _L['PTC_TONG_ALLIANCE'], tCol = GetMsgFontColor('MSG_GUILD_ALLIANCE', true) },
}

--------------------------------------------------------------------------

function D.Talk()
	if #O.szTalkText == 0 then
		return X.Systopmsg(_L['Please input something.'], CONSTANT.MSG_THEME.ERROR)
	end
	-- 调试工具
	if X.ProcessCommand and string.sub(O.szTalkText, 1, 8) == '/script ' then
		local szCommand = string.sub(O.szTalkText, 9)
		return X.ProcessCommand(szCommand)
	end
	-- 防止刷屏
	if GetTime() - D.dwTalkTick < 1000 then
		return OutputMessage('MSG_ANNOUNCE_YELLOW', _L['You are talking too quick!'])
	end
	D.dwTalkTick = GetTime()
	-- 近聊不放在第一个会导致发不出去
	if lodash.includes(O.aTalkChannel, PLAYER_TALK_CHANNEL.NEARBY) then
		X.SendChat(PLAYER_TALK_CHANNEL.NEARBY, O.szTalkText)
	end
	-- 遍历发送队列
	for _, nChannel in ipairs(O.aTalkChannel) do
		if nChannel ~= PLAYER_TALK_CHANNEL.NEARBY then
			X.SendChat(nChannel, O.szTalkText)
		end
	end
end
X.RegisterHotKey('MY_TalkEx_Talk', _L['TalkEx Talk'], D.Talk, nil)

function D.Trick()
	if #O.szTrickText == 0 then
		return X.Sysmsg(_L['Please input something.'], CONSTANT.MSG_THEME.ERROR)
	end
	local t = {}
	local me = GetClientPlayer()
	if not me then
		return
	end
	if O.szTrickFilter == 'RAID' then
		local team = GetClientTeam()
		if team and (me.IsInParty() or me.IsInRaid()) then
			for _, dwID in ipairs(team.GetTeamMemberList()) do
				local info = team.GetMemberInfo(dwID)
				if info and (O.nTrickForce == -1 or O.nTrickForce == info.dwForceID) then
					table.insert(t, info.szName)
				end
			end
		end
	elseif O.szTrickFilter == 'NEARBY' then
		for _, p in ipairs(X.GetNearPlayer()) do
			if O.nTrickForce == -1 or O.nTrickForce == p.dwForceID then
				table.insert(t, p.szName)
			end
		end
	end
	-- 去掉自己 _(:з」∠)_调侃自己是闹哪样
	for i = #t, 1, -1 do
		if t[i] == me.szName then
			table.remove(t, i)
		end
	end
	-- none target
	if #t == 0 then
		return X.Systopmsg(_L['No trick target found.'], CONSTANT.MSG_THEME.ERROR)
	end
	-- start tricking
	if #O.szTrickTextBegin > 0 then
		X.SendChat(O.nTrickChannel, O.szTrickTextBegin)
	end
	-- for _, szName in ipairs(t) do
	-- 	X.SendChat(O.nTrickChannel, (O.szTrickText:gsub('%$mb', '[' .. szName .. ']')))
	-- end
	for i, szName in ipairs(t) do
		t[i] = '[' .. szName .. ']'
	end
	X.SendChat(O.nTrickChannel, (O.szTrickText:gsub('%$mb', table.concat(t, _L.SLIGHT_PAUSE_MARK))))
	if #O.szTrickTextEnd > 0 then
		X.SendChat(O.nTrickChannel, O.szTrickTextEnd)
	end
	D.dwTalkCDTime = GetTime()
end

local PS = {}
function PS.OnPanelActive(wnd)
	local ui = UI(wnd)
	local w, h = ui:Size()
	local nPaddingX, nPaddingY, LH = 25, 20, 30
	local nX, nY, nLFY = nPaddingX, nPaddingY, nPaddingY

	-------------------------------------
	-- 喊话部分
	-------------------------------------
	-- 喊话输入框
	ui:Append('WndEditBox', {
		x = nX, y = nY,
		w = w - 136, h = 148, multiline = true,
		text = O.szTalkText,
		onchange = function(text)
			O.szTalkText = text
		end,
	})
	-- 喊话频道
	nY = nPaddingY
	local nChannelCount = #TALK_CHANNEL_LIST
	for i, p in ipairs(TALK_CHANNEL_LIST) do
		ui:Append('WndCheckBox', {
			x = w - 110, y = nY + (i - 1) * 120 / nChannelCount,
			text = g_tStrings.tChannelName[p.szID],
			color = GetMsgFontColor(p.szID, true),
			checked = lodash.includes(O.aTalkChannel, p.nChannel),
			oncheck = function(bCheck)
				for i, v in X.ipairs_r(O.aTalkChannel) do
					if v == p.nChannel then
						table.remove(O.aTalkChannel, i)
					end
				end
				if bCheck then
					table.insert(O.aTalkChannel, p.nChannel)
				end
				O.aTalkChannel = O.aTalkChannel
			end,
		})
	end
	-- 喊话按钮
	nY = nY + 122
	ui:Append('WndButton', {
		x = w - 110, y = nY, w = 90,
		text = _L['Send'],
		onlclick = function()
			if IsCtrlKeyDown() or IsAltKeyDown() or IsShiftKeyDown() then
				X.SetChatInput(O.szTalkText)
				X.FocusChatInput()
			else
				D.Talk()
			end
		end,
		onrclick = function()
			X.SetChatInput(O.szTalkText)
			X.FocusChatInput()
		end,
	})

	-------------------------------------
	-- 骚话部分
	-------------------------------------
	-- <hr />
	nX = nPaddingX
	nY = nY + 40
	ui:Append('Shadow', { x = nPaddingX, y = nY, w = w - nPaddingX * 2, h = 1, color = {255, 255, 255}, alpha = 128 })
	-- 文本标题
	nY = nY + 5
	nX = nX + ui:Append('Text', { x = nX, y = nY, w = 'auto', h = 25, text = _L['Joke talk'] }):Width() + 5
	-- 骚话内容搜索输入框
	nX = nPaddingX
	nY = nY + LH
	nX = ui:Append('WndEditBox', {
		x = nX, y = nY,
		w = 150, h = 25,
		text = D.szJokeSearch,
		onchange = function(szText)
			D.szJokeSearch = szText
		end,
	}):Pos('BOTTOMRIGHT') + 5
	-- 骚话内容搜索按钮
	nX = nX + ui:Append('WndButton', {
		x = nX, y = nY,
		w = 50, h = 25,
		text = _L['Search'],
		onclick = function()
			X.Ajax({
				driver = 'auto', mode = 'auto', method = 'auto',
				url = 'https://pull.j3cx.com/joke/random?'
					.. X.EncodePostData(X.UrlEncode(X.SignPostData({
						l = AnsiToUTF8(GLOBAL.GAME_LANG),
						L = AnsiToUTF8(GLOBAL.GAME_EDITION),
						q = AnsiToUTF8(D.szJokeSearch or ''),
					}, X.SECRET.JOKE_RANDOM))),
				success = function(html, status)
					local res = X.JsonDecode(html)
					if X.IsTable(res) then
						ui:Fetch('WndEditBox_JokeText'):Text(res.data.content)
					end
				end,
			})
		end,
		tip = _L['Click to search jokes.'],
		tippostype = UI.TIP_POSITION.TOP_BOTTOM,
	}):Width() + 5
	-- 骚话复制按钮
	nX = ui:Append('WndButton', {
		x = nX, y = nY,
		w = 50, h = 25,
		text = _L['Copy'],
		onclick = function()
			X.SetChatInput(D.szJokeText)
			X.FocusChatInput()
		end,
		autoenable = function() return not X.IsEmpty(D.szJokeText) end,
		tip = _L['Click to copy joke to chat panel.'],
		tippostype = UI.TIP_POSITION.TOP_BOTTOM,
	}):Pos('BOTTOMRIGHT') + 5
	-- 骚话分享按钮
	nX = ui:Append('WndButton', {
		x = nX, y = nY,
		w = 50, h = 25,
		text = _L['Share'],
		onclick = function()
			local function fnAction(bAnonymous)
				X.Ajax({
					driver = 'auto', mode = 'auto', method = 'auto',
					url = 'https://push.j3cx.com/joke?'
						.. X.EncodePostData(X.UrlEncode(X.SignPostData({
							l = AnsiToUTF8(GLOBAL.GAME_LANG),
							L = AnsiToUTF8(GLOBAL.GAME_EDITION),
							content = AnsiToUTF8(D.szJokeText or ''),
							server = AnsiToUTF8(X.GetRealServer(2)),
							role = bAnonymous and '' or AnsiToUTF8(X.GetUserRoleName()),
							id = bAnonymous and '' or AnsiToUTF8(UI_GetClientPlayerID()),
							jx3id = bAnonymous and '' or AnsiToUTF8(X.GetClientUUID()),
						}, X.SECRET.JOKE))),
					success = function(html, status)
						local res = X.JsonDecode(html)
						if X.IsTable(res) then
							X.Alert(X.ReplaceSensitiveWord(res.msg))
						else
							X.Systopmsg(_L['Share error: server error.'], CONSTANT.MSG_THEME.ERROR)
						end
					end,
				})
			end
			local nW, nH = Station.GetClientSize()
			local tMsg = {
				x = nW / 2, y = nH / 3,
				szName = 'MY_TalkEx_Joke',
				szMessage = _L['Confirm share joke:'] .. '\n\n' .. D.szJokeText,
				szAlignment = 'CENTER',
				{ szOption = _L['Share onymously'], fnAction = function() fnAction(false) end },
				{ szOption = _L['Share anonymously'], fnAction = function() fnAction(true) end },
				{ szOption = g_tStrings.STR_HOTKEY_CANCEL },
			}
			MessageBox(tMsg)
		end,
		autoenable = function() return not X.IsEmpty(D.szJokeText) end,
		tip = _L['Click to share your joke to remote.'],
		tippostype = UI.TIP_POSITION.TOP_BOTTOM,
	}):Pos('BOTTOMRIGHT') + 5
	-- 骚话输入框
	nX = nPaddingX
	nY = nY + LH
	nX = nX + ui:Append('WndEditBox', {
		name = 'WndEditBox_JokeText',
		x = nX, y = nY,
		w = w - nPaddingX * 2, h = 75,
		multiline = true,
		text = D.szJokeText,
		onchange = function(szText)
			D.szJokeText = szText
		end,
	}):Width() + 5
	nY = nY + 75

	nY = nY + 10

	-------------------------------------
	-- 调侃部分
	-------------------------------------
	-- <hr />
	nX = nPaddingX
	ui:Append('Shadow', { x = nPaddingX, y = nY, w = w - nPaddingX * 2, h = 1, color = {255, 255, 255}, alpha = 128 })
	-- 文本标题
	nY = nY + 10
	nX = nX + ui:Append('Text', { x = nX, y = nY, w = 'auto', h = 25, text = _L['Have a trick with'] }):Width() + 5
	-- 调侃对象范围过滤器
	nX = nX + ui:Append('WndComboBox', {
		x = nX, y = nY, w = 100, h = 25,
		text = X.Get(lodash.find(TRICK_FILTER_LIST, function(p) return p.szKey == O.szTrickFilter end), 'szLabel', '???'),
		menu = function()
			local ui = UI(this)
			local t = {}
			for _, p in ipairs(TRICK_FILTER_LIST) do
				table.insert(t, {
					szOption = p.szLabel,
					fnAction = function()
						ui:Text(p.szLabel)
						O.szTrickFilter = p.szKey
						UI.ClosePopupMenu()
					end,
				})
			end
			return t
		end,
	}):Width() + 5
	-- 调侃门派过滤器
	nX = nX + ui:Append('WndComboBox', {
		x = nX, y = nY, w = 80, h = 25,
		text = X.Get(lodash.find(FORCE_LIST, function(p) return p.dwForceID == O.nTrickForce end), 'szLabel', '???'),
		menu = function()
			local ui = UI(this)
			local t = {}
			for _, p in ipairs(FORCE_LIST) do
				table.insert(t, {
					szOption = p.szLabel,
					fnAction = function()
						ui:Text(p.szLabel)
						O.nTrickForce = p.dwForceID
						UI.ClosePopupMenu()
					end,
				})
			end
			return t
		end,
	}):Width() + 5
	nX = nPaddingX
	nY = nY + LH

	-- 调侃内容输入框：第一句
	nY = nY + ui:Append('WndEditBox', {
		x = nX, y = nY,
		w = w - nPaddingX * 2, h = 25,
		text = O.szTrickTextBegin,
		onchange = function(szText)
			O.szTrickTextBegin = szText
		end,
	}):Height() + 5
	-- 调侃内容输入框：调侃内容
	nY = nY + ui:Append('WndEditBox', {
		x = nX, y = nY, w = w - nPaddingX * 2, h = 55,
		multiline = true, text = O.szTrickText,
		onchange = function(szText)
			O.szTrickText = szText
		end,
	}):Height() + 5
	-- 调侃内容输入框：最后一句
	nY = nY + ui:Append('WndEditBox', {
		x = nX, y = nY, w = w - nPaddingX * 2, h = 25,
		text = O.szTrickTextEnd,
		onchange = function(szText)
			O.szTrickTextEnd = szText
		end,
	}):Height() + 5
	-- 调侃发送频道提示框
	nX = nX + ui:Append('Text', { x = nX, y = nY, w = 'auto', h = 25, text = _L['Send to'] }):Width() + 5
	-- 调侃发送频道
	nX = nX + ui:Append('WndComboBox', {
		x = nX, y = nY, w = 100, h = 25,
		text = X.Get(lodash.find(TRICK_CHANNEL_LIST, function(p) return p.nChannel == O.nTrickChannel end), 'szName', '???'),
		color = X.Get(lodash.find(TRICK_CHANNEL_LIST, function(p) return p.nChannel == O.nTrickChannel end), 'tCol'),
		menu = function()
			local ui = UI(this)
			local t = {}
			for _, p in ipairs(TRICK_CHANNEL_LIST) do
				table.insert(t, {
					rgb = p.tCol,
					szOption = p.szName,
					fnAction = function()
						O.nTrickChannel = p.nChannel
						ui:Text(p.szName)
						ui:Color(p.tCol)
						UI.ClosePopupMenu()
					end,
				})
			end
			return t
		end,
	}):Width() + 5
	-- 调侃按钮
	local uiBtn = ui:Append('WndButton', {
		x = w - nPaddingX - 100, y = nY, w = 100,
		color = {255, 255, 255},
		text = _L['Trick'],
		onclick = D.Trick,
	})
	X.BreatheCall('MY_TalkEx__Enable', function()
		local dwTime = GetTime() - D.dwTalkCDTime
		if dwTime > 10000 then
			uiBtn:Enable(true)
			uiBtn:Text(_L['Trick'])
		else
			uiBtn:Enable(false)
			uiBtn:Text(_L['Trick'] .. '(' .. math.ceil((10000 - dwTime) / 1000) .. ')')
		end
	end)
end

function PS.OnPanelDeactive()
	X.BreatheCall('MY_TalkEx__Enable', false)
end

X.RegisterPanel(_L['Chat'], 'TalkEx', _L['MY_TalkEx'], 'UI/Image/UICommon/ScienceTreeNode.UITex|123', PS)
