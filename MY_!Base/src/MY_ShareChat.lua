--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : ����NPC�Ի���
-- @author   : ���� @˫���� @׷����Ӱ
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
local PLUGIN_NAME = 'MY_!Base'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_!Base'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '*') then
	return
end
--------------------------------------------------------------------------
local SHARE_NPC_CHAT_FILE = {'temporary/share-npc-chat.jx3dat', X.PATH_TYPE.GLOBAL}
local SHARE_NPC_CHAT = X.LoadLUAData(SHARE_NPC_CHAT_FILE) -- NPC�ϱ��Ի�ģ���Զ�̣�

X.RegisterInit('MY_ShareChat__Npc', function()
	if not SHARE_NPC_CHAT then
		X.Ajax({
			driver = 'auto', mode = 'auto', method = 'auto',
			url = 'https://pull.j3cx.com/config/npc-chat'
				.. '?l=' .. AnsiToUTF8(GLOBAL.GAME_LANG)
				.. '&L=' .. AnsiToUTF8(GLOBAL.GAME_EDITION)
				.. '&_=' .. GetCurrentTime(),
			success = function(html, status)
				local data = X.JsonDecode(html)
				if X.IsTable(data) then
					SHARE_NPC_CHAT = {}
					for _, dwTemplateID in ipairs(data) do
						SHARE_NPC_CHAT[dwTemplateID] = true
					end
					X.SaveLUAData(SHARE_NPC_CHAT_FILE, SHARE_NPC_CHAT)
				end
			end,
		})
	end
end)

X.RegisterEvent('OPEN_WINDOW', 'MY_ShareChat__Npc', function()
	if not MY_Serendipity.bEnable then
		return
	end
	local me = GetClientPlayer()
	if not me then
		return
	end
	local dwTargetID = arg3
	local npc = GetNpc(dwTargetID)
	local bShare = npc and SHARE_NPC_CHAT and SHARE_NPC_CHAT[npc.dwTemplateID]
	if not bShare then
		return
	end
	local szContent = arg1
	local map = X.GetMapInfo(me.GetMapID())
	local szDelayID
	local function fnAction(line)
		X.EnsureAjax({
			url = 'https://push.j3cx.com/api/npc-chat?'
				.. X.EncodePostData(X.UrlEncode(X.SignPostData({
					l = AnsiToUTF8(GLOBAL.GAME_LANG),
					L = AnsiToUTF8(GLOBAL.GAME_EDITION),
					r = AnsiToUTF8(X.GetRealServer(1)), -- Region
					s = AnsiToUTF8(X.GetRealServer(2)), -- Server
					c = AnsiToUTF8(szContent), -- Content
					t = GetCurrentTime(), -- Time
					cn = line and AnsiToUTF8(line.szCenterName) or '', -- Center Name
					ci = line and line.dwCenterID or -1, -- Center ID
					li = line and line.nLineIndex or -1, -- Line Index
					mi = map and map.dwID, -- Map ID
					mn = map and AnsiToUTF8(map.szName), -- Map Name
					nt = npc.dwTemplateID, -- NPC Template ID
					nn = X.GetObjectName(npc), -- NPC Name
				}, CONSTANT.SECRET.NPC_CHAT)))
			})
		X.DelayCall(szDelayID, false)
	end
	szDelayID = X.DelayCall(5000, fnAction)
	X.GetHLLineInfo({ dwMapID = me.GetMapID(), nCopyIndex = me.GetScene().nCopyIndex }, fnAction)
end)

--------------------------------------------------------------------------
local SHARE_SYSMSG_FILE = {'temporary/share-sysmsg.jx3dat', X.PATH_TYPE.GLOBAL} -- ϵͳ��Ϣ�ϱ�ģ���Զ�̣�
local SHARE_SYSMSG = X.LoadLUAData(SHARE_SYSMSG_FILE) -- ϵͳ��Ϣ�ϱ�ģ���Զ�̣�

X.RegisterInit('MY_ShareChat__Sysmsg', function()
	if not SHARE_SYSMSG then
		X.Ajax({
			driver = 'auto', mode = 'auto', method = 'auto',
			url = 'https://pull.j3cx.com/config/share-sysmsg'
				.. '?l=' .. AnsiToUTF8(GLOBAL.GAME_LANG)
				.. '&L=' .. AnsiToUTF8(GLOBAL.GAME_EDITION)
				.. '&_=' .. GetCurrentTime(),
			success = function(html, status)
				local data = X.JsonDecode(html)
				if X.IsTable(data) then
					SHARE_SYSMSG = {}
					for _, szPattern in ipairs(data) do
						if X.IsString(szPattern) then
							table.insert(SHARE_SYSMSG, szPattern)
						end
					end
					X.SaveLUAData(SHARE_SYSMSG_FILE, SHARE_SYSMSG)
				end
			end,
		})
	end
end)

X.RegisterMsgMonitor('MSG_SYS', 'MY_ShareChat__Sysmsg', function(szChannel, szMsg, nFont, bRich, r, g, b)
	if not MY_Serendipity.bEnable then
		return
	end
	local me = GetClientPlayer()
	if not me then
		return
	end
	if not SHARE_SYSMSG then
		return
	end
	-- ����������
	if IsRemotePlayer(me.dwID) then
		return
	end
	-- ȷ������ʵϵͳ��Ϣ
	if X.ContainsEchoMsgHeader(szMsg) then
		return
	end
	-- OutputMessage('MSG_SYS', "<image>path=\"UI/Image/Minimap/Minimap.UITex\" frame=184</image><text>text=\"��һֻ���ܶܡ���ʿ����Ϊ�˴�����������䴥��������ѩɽ���𡿣����ǣ��������У�ƫ����֢����ѩ�����ˣ�ȴ�������Ե��\" font=10 r=255 g=255 b=0 </text><text>text=\"\\\n\"</text>", true)
	-- �����ֹս����ʿ��Ե��ǳ�������������������硿����ǧ����Ե�������������������������������
	-- ��ϲ��ʿ��������25��Ӣ�ۻ�ս�����л��ϡ�е���[ҹ��������]��
	if bRich then
		szMsg = GetPureText(szMsg)
	end
	for _, szPattern in ipairs(SHARE_SYSMSG) do
		if string.find(szMsg, szPattern) then
			X.EnsureAjax({
				url = 'https://push.j3cx.com/api/share-sysmsg?'
					.. X.EncodePostData(X.UrlEncode(X.SignPostData({
						l = AnsiToUTF8(GLOBAL.GAME_LANG),
						L = AnsiToUTF8(GLOBAL.GAME_EDITION),
						region = AnsiToUTF8(X.GetRealServer(1)), -- Region
						server = AnsiToUTF8(X.GetRealServer(2)), -- Server
						content = AnsiToUTF8(szMsg), -- Content
						time = GetCurrentTime(), -- Time
					}, CONSTANT.SECRET.SHARE_SYSMSG)))
				})
			return
		end
	end
end)
