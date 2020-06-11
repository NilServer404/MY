--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : ��ƽѪ��UI������ ֻ��UI���� �����κ��߼��ж�
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
local Call, XpCall, GetTraceback, RandomChild = LIB.Call, LIB.XpCall, LIB.GetTraceback, LIB.RandomChild
local Get, Set, Clone, GetPatch, ApplyPatch = LIB.Get, LIB.Set, LIB.Clone, LIB.GetPatch, LIB.ApplyPatch
local EncodeLUAData, DecodeLUAData, CONSTANT = LIB.EncodeLUAData, LIB.DecodeLUAData, LIB.CONSTANT
-------------------------------------------------------------------------------------------------------
local PLUGIN_NAME = 'MY_LifeBar'
local PLUGIN_ROOT = PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_LifeBar'
local _L = LIB.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not LIB.AssertVersion(MODULE_NAME, _L[MODULE_NAME], 0x2013900) then
	return
end
--------------------------------------------------------------------------

local HP = class()
local CACHE = setmetatable({}, {__mode = 'v'})
local REQUIRE_SORT = false

function HP:ctor(dwType, dwID) -- KGobject
	local hList = UI.GetShadowHandle('MY_LifeBar')
	local szName = dwType .. '_' .. dwID
	self.szName = szName
	self.dwType = dwType
	self.dwID = dwID
	self.handle = hList:Lookup(self.szName)
	return self
end

function HP:IsHandleValid()
	return self.handle and self.handle:IsValid()
end

-- ����
function HP:Create()
	if not self:IsHandleValid() then
		local hList = UI.GetShadowHandle('MY_LifeBar')
		hList:AppendItemFromString(FormatHandle(format('name="%s"', self.szName)))
		local hItem = hList:Lookup(self.szName)
		hItem:AppendItemFromString('<shadow>name="hp_bg"</shadow>')
		hItem:AppendItemFromString('<shadow>name="hp_bg2"</shadow>')
		hItem:AppendItemFromString('<shadow>name="hp"</shadow>')
		hItem:AppendItemFromString('<shadow>name="lines"</shadow>')
		hItem:AppendItemFromString('<shadow>name="hp_title"</shadow>')
		hItem:AppendItemFromString('<sfx>name="sfx"</sfx>')
		REQUIRE_SORT = true
		self.handle = hItem
	end
	return self
end

-- ɾ��
function HP:Remove()
	if self:IsHandleValid() then
		local hList = UI.GetShadowHandle('MY_LifeBar')
		hList:RemoveItem(self.handle)
		self.handle = nil
	end
	return self
end

function HP:SetPriority(nPriority)
	if self:IsHandleValid() then
		self.handle:SetUserData(nPriority)
		REQUIRE_SORT = true
	end
	return self
end

function HP:ClearShadow(szShadowName)
	if self:IsHandleValid() then
		local sha = self.handle:Lookup(szShadowName)
		if sha then
			sha:ClearTriangleFanPoint()
		end
	end
	return self
end

-- ��������/���/�ƺ� �ȵ� ������
function HP:DrawTexts(aTexts, nY, nLineHeight, r, g, b, a, f, spacing, scale)
	if self:IsHandleValid() then
		local sha = self.handle:Lookup('lines')
		sha:SetTriangleFan(GEOMETRY_TYPE.TEXT)
		sha:ClearTriangleFanPoint()

		for _, szText in ipairs(aTexts) do
			if szText ~= '' then
				sha:AppendCharacterID(self.dwID, true, r, g, b, a, {0, 0, 0, 0, -nY}, f, szText, spacing, scale / LIB.GetFontScale() / LIB.GetUIScale())
				nY =  nY + nLineHeight
			end
		end
	end
	return self
end

-- ����Ѫ���ٷֱ����֣������ػ�������Ժ�Wordlines���룩
function HP:DrawLifeText(text, x, y, r, g, b, a, f, spacing, scale)
	if self:IsHandleValid() then
		local sha = self.handle:Lookup('hp_title')
		sha:SetTriangleFan(GEOMETRY_TYPE.TEXT)
		sha:ClearTriangleFanPoint()
		sha:AppendCharacterID(self.dwID, true, r, g, b, a, {0, 0, 0, x, -y}, f, text, spacing, scale / LIB.GetFontScale() / LIB.GetUIScale())
	end
	return self
end

function HP:ClearLifeText()
	return self:ClearShadow('hp_title')
end

-- ���߿� Ĭ��200��nAlpha
function HP:DrawBorder(szShadowName, szShadowName2, nWidth, nHeight, nOffsetX, nOffsetY, nBorder, nR, nG, nB, nAlpha)
	if self:IsHandleValid() then
		nAlpha = nAlpha or 200
		local handle = self.handle

		-- ������߿�
		local sha = handle:Lookup(szShadowName)
		sha:SetTriangleFan(GEOMETRY_TYPE.TRIANGLE)
		sha:SetD3DPT(D3DPT.TRIANGLEFAN)
		sha:ClearTriangleFanPoint()
		local bcX, bcY = -(nWidth / 2 + nBorder) + nOffsetX, -(nHeight / 2 + nBorder) - nOffsetY

		sha:AppendCharacterID(self.dwID, true, nR, nG, nB, nAlpha, {0, 0, 0, bcX, bcY})
		sha:AppendCharacterID(self.dwID, true, nR, nG, nB, nAlpha, {0, 0, 0, bcX + nWidth + nBorder * 2, bcY})
		sha:AppendCharacterID(self.dwID, true, nR, nG, nB, nAlpha, {0, 0, 0, bcX + nWidth + nBorder * 2, bcY + nHeight + nBorder * 2})
		sha:AppendCharacterID(self.dwID, true, nR, nG, nB, nAlpha, {0, 0, 0, bcX, bcY + nHeight + nBorder * 2})

		-- �����ڱ߿�
		local sha = handle:Lookup(szShadowName2)
		sha:SetTriangleFan(GEOMETRY_TYPE.TRIANGLE)
		sha:SetD3DPT(D3DPT.TRIANGLEFAN)
		sha:ClearTriangleFanPoint()
		local bcX, bcY = -nWidth / 2 + nOffsetX, -nHeight / 2 - nOffsetY

		sha:AppendCharacterID(self.dwID, true, 30, 30, 30, nAlpha, {0, 0, 0, bcX, bcY})
		sha:AppendCharacterID(self.dwID, true, 30, 30, 30, nAlpha, {0, 0, 0, bcX + nWidth, bcY})
		sha:AppendCharacterID(self.dwID, true, 30, 30, 30, nAlpha, {0, 0, 0, bcX + nWidth, bcY + nHeight})
		sha:AppendCharacterID(self.dwID, true, 30, 30, 30, nAlpha, {0, 0, 0, bcX, bcY + nHeight})
	end
	return self
end

-- ���Ѫ���߿� Ĭ��200��nAlpha
function HP:DrawLifeBorder(nWidth, nHeight, nOffsetX, nOffsetY, nBorder, nR, nG, nB, nAlpha)
	return self:DrawBorder('hp_bg', 'hp_bg2', nWidth, nHeight, nOffsetX, nOffsetY, nBorder, nR, nG, nB, nAlpha)
end
function HP:ClearLifeBorder()
	self:ClearShadow('hp_bg')
	self:ClearShadow('hp_bg2')
	return self
end

-- �����Σ�������/Ѫ����
-- rgbap: ��,��,��,͸����,����,���Ʒ���
function HP:DrawRect(szShadowName, nWidth, nHeight, nOffsetX, nOffsetY, nPadding, r, g, b, a, p, d)
	if self:IsHandleValid() then
		nWidth = max(0, nWidth - nPadding * 2)
		nHeight = max(0, nHeight - nPadding * 2)
		if not p or p > 1 then
			p = 1
		elseif p < 0 then
			p = 0
		end -- fix
		local sha = self.handle:Lookup(szShadowName)

		sha:SetTriangleFan(GEOMETRY_TYPE.TRIANGLE)
		sha:SetD3DPT(D3DPT.TRIANGLEFAN)
		sha:ClearTriangleFanPoint()

		-- ����ʵ�ʻ��ƿ�ȸ߶���ʼλ��
		local bcX, bcY = -nWidth / 2 + nOffsetX, -nHeight / 2 - nOffsetY
		if d == 'TOP_BOTTOM' then
			nWidth = nWidth
			nHeight = nHeight * p
		elseif d == 'BOTTOM_TOP' then
			bcY = bcY + nHeight * (1 - p)
			nWidth = nWidth
			nHeight = nHeight * p
		elseif d == 'RIGHT_LEFT' then
			bcX = bcX + nWidth * (1 - p)
			nWidth = nWidth * p
			nHeight = nHeight
		else -- if d == 'LEFT_RIGHT' then
			nWidth = nWidth * p
			nHeight = nHeight
		end

		sha:AppendCharacterID(self.dwID, true, r, g, b, a, {0, 0, 0, bcX, bcY})
		sha:AppendCharacterID(self.dwID, true, r, g, b, a, {0, 0, 0, bcX + nWidth, bcY})
		sha:AppendCharacterID(self.dwID, true, r, g, b, a, {0, 0, 0, bcX + nWidth, bcY + nHeight})
		sha:AppendCharacterID(self.dwID, true, r, g, b, a, {0, 0, 0, bcX, bcY + nHeight})
	end
	return self
end

-- ���Ѫ��
function HP:DrawLifeBar(nWidth, nHeight, nOffsetX, nOffsetY, nPadding, r, g, b, a, p, d)
	return self:DrawRect('hp', nWidth, nHeight, nOffsetX, nOffsetY, nPadding, r, g, b, a, p, d)
end

function HP:ClearLifeBar()
	return self:ClearShadow('hp')
end

-- ����ͷ����Ч
-- szFile ��Ч�ļ�
-- fScale ��Ч����
-- nWidth ���ź����ЧUI���
-- nHeight ���ź����ЧUI�߶�
function HP:SetSFX(szFile, fScale, nWidth, nHeight, nOffsetY)
	if self:IsHandleValid() then
		local sfx = self.handle:Lookup('sfx')
		local szKey = 'MY_LIFEBAR_HP_SFX_' .. self.dwType .. '_' .. self.dwID
		local dwCtcType = self.dwType == TARGET.DOODAD and CTCT.DOODAD_POS_2_SCREEN_POS or CTCT.CHARACTER_TOP_2_SCREEN_POS
		if szFile then
			sfx:LoadSFX(szFile)
			sfx:SetModelScale(fScale)
			sfx:Play(true)
			sfx:Show()
			LIB.RenderCall(szKey, function()
				if sfx and sfx:IsValid() then
					local nX, nY, bFront = LIB.CThreadCoor(dwCtcType, self.dwID)
					nX, nY = Station.AdjustToOriginalPos(nX, nY)
					sfx:SetAbsPos(nX, nY - nHeight / 2 - nOffsetY)
				else
					LIB.CThreadCoor(dwCtcType, self.dwID, szKey, false)
					LIB.RenderCall(szKey, false)
				end
			end)
			LIB.CThreadCoor(dwCtcType, self.dwID, szKey, true)
		else
			sfx:Hide()
			LIB.RenderCall(szKey, false)
			LIB.CThreadCoor(dwCtcType, self.dwID, szKey, false)
		end
	end
	return self
end

function HP:ClearSFX()
	return self:SetSFX()
end

function HP:SetBalloon(szMsg, nStartTick, nDuring, nOffsetY)
	if self:IsHandleValid() then
		local balloon = self.handle:Lookup('balloon')
		local szKey = 'MY_LIFEBAR_HP_BALLOON_' .. self.dwType .. '_' .. self.dwID
		local dwCtcType = self.dwType == TARGET.DOODAD and CTCT.DOODAD_POS_2_SCREEN_POS or CTCT.CHARACTER_TOP_2_SCREEN_POS
		if not IsEmpty(szMsg) then
			if not balloon then
				self.handle:AppendItemFromString('<handle>name="balloon" handletype=0 <image>name="Image_Bg1" path="ui\\Image\\UICommon\\CommonPanel.UITex" frame=21 postype=0 imagetype=10</image><image>name="Image_Bg2" path="ui\\Image\\Common\\CommonPanel.UITex" frame=71 postype=0 disablescale=1</image><handle>name="content" x=15 y=10 handletype=4 valign=2 </handle></handle>')
				balloon = self.handle:Lookup('balloon')
			end
			local hContent = balloon:Lookup('content')
			hContent:Clear()
			hContent:SetW(350)
			hContent:AppendItemFromString(szMsg)
			hContent:SetSizeByAllItemSize()
			balloon:SetSize(max(hContent:GetW() + 30, 50), hContent:GetH() + 20)
			balloon:Lookup('Image_Bg1'):SetSize(balloon:GetSize())
			balloon:Lookup('Image_Bg2'):SetRelPos(min(balloon:GetW() * 3 / 4, balloon:GetW() - balloon:Lookup('Image_Bg2'):GetW() - 10), balloon:GetH() - 3)
			balloon:FormatAllItemPos()
			local nEndTick = nStartTick + nDuring
			local nAnimationTime = min(nDuring / 5, 1000)
			balloon:Show()
			balloon:SetAlpha(0)
			local nTick, nX, nY, bFront, nAni
			LIB.RenderCall(szKey, function()
				nTick = GetTime()
				if balloon and balloon:IsValid() and nTick <= nEndTick then
					nX, nY, bFront = LIB.CThreadCoor(dwCtcType, self.dwID)
					nX, nY = Station.AdjustToOriginalPos(nX, nY)
					balloon:SetAbsPos(nX - balloon:GetW() / 2, nY - nOffsetY - balloon:GetH())
					nAni = min((nTick - nStartTick) * 2, nEndTick - nTick) -- ���ֱ���ʧ��һ���Ƚ����
					balloon:SetAlpha(nAni > nAnimationTime and 255 or nAni / nAnimationTime * 255)
				else
					if balloon and balloon:IsValid() then
						balloon:Hide()
					end
					LIB.CThreadCoor(dwCtcType, self.dwID, szKey, false)
					LIB.RenderCall(szKey, false)
				end
			end)
			LIB.CThreadCoor(dwCtcType, self.dwID, szKey, true)
		else
			if balloon and balloon:IsValid() then
				balloon:Hide()
			end
			LIB.RenderCall(szKey, false)
			LIB.CThreadCoor(dwCtcType, self.dwID, szKey, false)
		end
	end
	return self
end

function HP:ClearBalloon()
	return self:SetBalloon()
end

function MY_LifeBar_HP(dwType, dwID)
	if dwType == 'clear' then
		CACHE = {}
		UI.GetShadowHandle('MY_LifeBar'):Clear()
	else
		local szName = dwType .. '_' .. dwID
		if not CACHE[szName] then
			CACHE[szName] = HP.new(dwType, dwID)
		end
		return CACHE[szName]
	end
end

do local hList
local function onBreathe()
	if REQUIRE_SORT then
		if not (hList and hList:IsValid()) then
			hList = UI.GetShadowHandle('MY_LifeBar')
		end
		hList:Sort()
		REQUIRE_SORT = false
	end
end
LIB.BreatheCall('MY_LifeBar_HP', onBreathe)
end
