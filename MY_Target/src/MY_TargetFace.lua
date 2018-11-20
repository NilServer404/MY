--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : 目标面向显示 （台服用）
-- @ref      : 参考海鳗插件：目标面向显示
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@derzh.com)
-- @copyright: Copyright (c) 2013 EMZ Kingsoft Co., Ltd.
--------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- these global functions are accessed all the time by the event handler
-- so caching them is worth the effort
---------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local ipairs, pairs, next, pcall = ipairs, pairs, next, pcall
local sub, len, format, rep = string.sub, string.len, string.format, string.rep
local find, byte, char, gsub = string.find, string.byte, string.char, string.gsub
local type, tonumber, tostring = type, tonumber, tostring
local huge, pi, random, abs = math.huge, math.pi, math.random, math.abs
local min, max, floor, ceil = math.min, math.max, math.floor, math.ceil
local pow, sqrt, sin, cos, tan = math.pow, math.sqrt, math.sin, math.cos, math.tan
local insert, remove, concat, sort = table.insert, table.remove, table.concat, table.sort
local pack, unpack = table.pack or function(...) return {...} end, table.unpack or unpack
-- jx3 apis caching
local wsub, wlen, wfind = wstring.sub, wstring.len, wstring.find
local GetTime, GetLogicFrameCount = GetTime, GetLogicFrameCount
local GetClientTeam, UI_GetClientPlayerID = GetClientTeam, UI_GetClientPlayerID
local GetClientPlayer, GetPlayer, GetNpc, IsPlayer = GetClientPlayer, GetPlayer, GetNpc, IsPlayer
local UI, Get, RandomChild = MY.UI, MY.Get, MY.RandomChild
local IsNil, IsBoolean, IsNumber, IsFunction = MY.IsNil, MY.IsBoolean, MY.IsNumber, MY.IsFunction
local IsEmpty, IsString, IsTable, IsUserdata = MY.IsEmpty, MY.IsString, MY.IsTable, MY.IsUserdata
---------------------------------------------------------------------------------------------------
local _L = MY.LoadLangPack(MY.GetAddonInfo().szRoot .. 'MY_Target/lang/')
if not MY.AssertVersion('MY_TargetFace', _L['MY_TargetFace'], 0x2011800) then
	return
end

local O = {
	bTargetFace        = false,           -- 是否画出目标面向
	bTTargetFace       = false,           -- 是否画出目标的目标的面向
	nSectorDegree      = 110,             -- 扇形角度
	nSectorRadius      = 6,               -- 扇形半径（尺）
	nSectorAlpha       = 80,              -- 扇形透明度
	tTargetFaceColor   = { 255, 0, 128 }, -- 目标面向颜色
	tTTargetFaceColor  = { 0, 128, 255 }, -- 目标的目标面向颜色
	bTargetShape       = false,           -- 目标脚底圈圈
	bTTargetShape      = false,           -- 目标的目标脚底圈圈
	nShapeRadius       = 2,               -- 脚底圈圈半径
	nShapeAlpha        = 100,             -- 脚底圈圈透明度
	tTargetShapeColor  = { 255, 0, 0 },   -- 目标脚底圈圈颜色
	tTTargetShapeColor = { 0, 0, 255 },   -- 目标的目标脚底圈圈颜色
}
local C, D = {}, {}

RegisterCustomData('MY_TargetFace.bTargetFace')
RegisterCustomData('MY_TargetFace.bTTargetFace')
RegisterCustomData('MY_TargetFace.nSectorDegree')
RegisterCustomData('MY_TargetFace.nSectorRadius')
RegisterCustomData('MY_TargetFace.nSectorAlpha')
RegisterCustomData('MY_TargetFace.tTargetFaceColor')
RegisterCustomData('MY_TargetFace.tTTargetFaceColor')
RegisterCustomData('MY_TargetFace.bTargetShape')
RegisterCustomData('MY_TargetFace.bTTargetShape')
RegisterCustomData('MY_TargetFace.nShapeRadius')
RegisterCustomData('MY_TargetFace.nShapeAlpha')
RegisterCustomData('MY_TargetFace.tTargetShapeColor')
RegisterCustomData('MY_TargetFace.tTTargetShapeColor')

function D.RequireRerender()
	C.bReRender = true
end

do
local function DrawShape(tar, sha, nDegree, nRadius, nAlpha, col)
	nRadius = nRadius * 64
	local nFace = math.ceil(128 * nDegree / 360)
	local dwRad1 = math.pi * (tar.nFaceDirection - nFace) / 128
	if tar.nFaceDirection > (256 - nFace) then
		dwRad1 = dwRad1 - math.pi - math.pi
	end
	local dwRad2 = dwRad1 + (nDegree / 180 * math.pi)
	local nAlpha2 = 0
	if nDegree == 360 then
		nAlpha, nAlpha2 = nAlpha2, nAlpha
		dwRad2 = dwRad2 + math.pi / 16
	end
	-- orgina point
	sha:SetTriangleFan(GEOMETRY_TYPE.TRIANGLE)
	sha:SetD3DPT(D3DPT.TRIANGLEFAN)
	sha:ClearTriangleFanPoint()
	sha:AppendCharacterID(tar.dwID, false, col[1], col[2], col[3], nAlpha)
	sha:Show()
	-- relative points
	local sX, sZ = Scene_PlaneGameWorldPosToScene(tar.nX, tar.nY)
	repeat
		local sX_, sZ_ = Scene_PlaneGameWorldPosToScene(tar.nX + math.cos(dwRad1) * nRadius, tar.nY + math.sin(dwRad1) * nRadius)
		sha:AppendCharacterID(tar.dwID, false, col[1], col[2], col[3], nAlpha2, { sX_ - sX, 0, sZ_ - sZ })
		dwRad1 = dwRad1 + math.pi / 16
	until dwRad1 >= dwRad2
end

local function onBreathe()
	-- target face
	local dwTarType, dwTarID = MY.GetTarget()
	local tar = MY.GetObject(dwTarType, dwTarID)
	if O.bTargetFace and tar then
		DrawShape(tar, C.shaTargetFace, O.nSectorDegree, O.nSectorRadius, O.nSectorAlpha, O.tTargetFaceColor)
	else
		C.shaTargetFace:Hide()
	end
	-- foot shape
	if C.bReRender then
		if O.bTargetShape and tar then
			DrawShape(tar, C.shaTargetShape, 360, O.nShapeRadius / 2, O.nShapeAlpha, O.tTargetShapeColor)
		else
			C.shaTargetShape:Hide()
		end
	end
	-- target target face
	local dwTTarType, dwTTarID = MY.GetTarget(tar)
	local ttar = MY.GetObject(dwTTarType, dwTTarID)
	local bIsTarget = tar and dwTarID == dwTTarID
	if O.bTTargetFace and ttar and (not O.bTargetFace or not bIsTarget) then
		DrawShape(ttar, C.shaTTargetFace, O.nSectorDegree, O.nSectorRadius, O.nSectorAlpha, O.tTTargetFaceColor)
	else
		C.shaTTargetFace:Hide()
	end
	-- target target shape
	if C.bReRender then
		if O.bTTargetShape and ttar and (not O.bTargetShape or not bIsTarget) then
			DrawShape(ttar, C.shaTTargetShape, 360, O.nShapeRadius / 2, O.nShapeAlpha, O.tTTargetShapeColor)
		else
			C.shaTTargetShape:Hide()
		end
	end
	C.bReRender = false
end

function D.CheckEnable()
	if not MY.IsShieldedVersion() and (O.bTargetFace or O.bTTargetFace or O.bTargetShape or O.bTTargetShape) then
		local hShaList = UI.GetShadowHandle('MY_TargetFace')
		for _, v in ipairs({ "TargetFace", "TargetShape", "TTargetFace", "TTargetShape" }) do
			local sha = hShaList:Lookup(v)
			if not sha then
				hShaList:AppendItemFromString('<shadow>name="' .. v .. '"</shadow>')
				sha = hShaList:Lookup(v)
			end
			C["sha" .. v] = sha
		end
		MY.BreatheCall('MY_TargetFace', onBreathe)
	else
		for _, v in ipairs({ "TargetFace", "TargetShape", "TTargetFace", "TTargetShape" }) do
			local sha = C["sha" .. v]
			if sha and sha:IsValid() then
				sha:Hide()
			end
			C["sha" .. v] = nil
		end
		MY.BreatheCall('MY_TargetFace', false)
	end
	D.RequireRerender()
end

MY.RegisterInit('MY_TargetFace', D.CheckEnable)
MY.RegisterEvent('MY_SHIELDED_VERSION.MY_TargetFace', D.CheckEnable)
end

do
local PS = { bShielded = true }
function PS.OnPanelActive(wnd)
	local ui = UI(wnd)
	local X, Y = 20, 20
	local x, y = X, Y
	local deltaY = 32
	ui:append("Text", { x = x, y = y, text = _L["Options"], font = 27 })

	-- target face
	x, y = X + 10, y + deltaY
	x = x + ui:append("WndCheckBox", {
		x = x, y = y,
		text = _L["Display the sector of target facing, change color"],
		checked = MY_TargetFace.bTargetFace,
		oncheck = function(bChecked)
			MY_TargetFace.bTargetFace = bChecked
		end,
	}, true):autoWidth():width()

	ui:append("Shadow", {
		x = x + 2, y = y + 4, w = 18, h = 18,
		color = MY_TargetFace.tTargetFaceColor,
		onclick = function()
			local ui = UI(this)
			UI.OpenColorPicker(function(r, g, b)
				ui:color(r, g, b)
				MY_TargetFace.tTargetFaceColor = { r, g, b }
			end)
		end,
	})

	-- target target face
	x, y = X + 10, y + deltaY
	x = x + ui:append("WndCheckBox", {
		x = x, y = y,
		text = _L["Display the sector of target target facing, change color"],
		checked = MY_TargetFace.bTTargetFace,
		oncheck = function(bChecked)
			MY_TargetFace.bTTargetFace = bChecked
		end,
	}, true):autoWidth():width()

	ui:append("Shadow", {
		x = x + 2, y = y + 4, w = 18, h = 18,
		color = MY_TargetFace.tTTargetFaceColor,
		onclick = function()
			local ui = UI(this)
			UI.OpenColorPicker(function(r, g, b)
				ui:color(r, g, b)
				MY_TargetFace.tTTargetFaceColor = { r, g, b }
			end)
		end,
	})

	x, y = X + 37, y + deltaY
	x = x + ui:append("Text", { text = _L["The sector angle"], x = x, y = y }, true):autoWidth():width()

	ui:append("WndSliderBox", {
		x = x + 2, y = y + 4,
		value = MY_TargetFace.nSectorDegree,
		range = {30, 180},
		sliderstyle = MY_SLIDER_DISPTYPE.SHOW_VALUE,
		textfmt = function(val) return _L('%d degree', val) end,
		onchange = function(val) MY_TargetFace.nSectorDegree = val end,
	})

	x, y = X + 37, y + deltaY
	x = x + ui:append("Text", { text = _L["The sector radius"], x = x, y = y }, true):autoWidth():width()

	ui:append("WndSliderBox", {
		x = x + 2, y = y + 4,
		value = MY_TargetFace.nSectorRadius,
		range = {1, 26},
		sliderstyle = MY_SLIDER_DISPTYPE.SHOW_VALUE,
		textfmt = function(val) return _L('%d feet', val) end,
		onchange = function(val) MY_TargetFace.nSectorRadius = val end,
	})

	x, y = X + 37, y + deltaY
	x = x + ui:append("Text", { text = _L["The sector transparency"], x = x, y = y }, true):autoWidth():width()

	ui:append("WndSliderBox", {
		x = x + 2, y = y + 4,
		value = ceil((200 - MY_TargetFace.nSectorAlpha) / 2),
		range = {0, 100},
		sliderstyle = MY_SLIDER_DISPTYPE.SHOW_VALUE,
		textfmt = function(val) return _L('%d %%', val) end,
		onchange = function(val) MY_TargetFace.nSectorAlpha = (100 - val) * 2 end,
	})

	-- foot shape
	x, y = X, y + deltaY
	x = x + ui:append("WndCheckBox", {
		x = x, y = y,
		text = _L["Display the foot shape of target, change color"],
		checked = MY_TargetFace.bTargetShape,
		oncheck = function(bChecked) MY_TargetFace.bTargetShape = bChecked end,
	}, true):autoWidth():width()

	ui:append("Shadow", {
		x = x + 2, y = y + 4, w = 18, h = 18,
		color = MY_TargetFace.tTargetShapeColor,
		onclick = function()
			local ui = UI(this)
			UI.OpenColorPicker(function(r, g, b)
				ui:color(r, g, b)
				MY_TargetFace.tTargetShapeColor = { r, g, b }
			end)
		end,
	})

	x, y = X, y + deltaY
	x = x + ui:append("WndCheckBox", {
		x = x, y = y,
		text = _L["Display the foot shape of target target, change color"],
		checked = MY_TargetFace.bTTargetShape,
		oncheck = function(bChecked) MY_TargetFace.bTTargetShape = bChecked end,
	}, true):autoWidth():width()

	ui:append("Shadow", {
		x = x + 2, y = y + 4, w = 18, h = 18,
		color = MY_TargetFace.tTTargetShapeColor,
		onclick = function()
			local ui = UI(this)
			UI.OpenColorPicker(function(r, g, b)
				ui:color(r, g, b)
				MY_TargetFace.tTTargetShapeColor = { r, g, b }
			end)
		end,
	})

	x, y = X + 37, y + deltaY
	x = x + ui:append("Text", { text = _L["The foot shape radius"], x = x, y = y }, true):autoWidth():width()

	ui:append("WndSliderBox", {
		x = x + 2, y = y + 4,
		value = MY_TargetFace.nShapeRadius,
		range = {1, 26},
		sliderstyle = MY_SLIDER_DISPTYPE.SHOW_VALUE,
		textfmt = function(val) return _L('%.1f feet', val / 2) end,
		onchange = function(val) MY_TargetFace.nShapeRadius = val end,
	})

	x, y = X + 37, y + deltaY
	x = x + ui:append("Text", { text = _L["The foot shape transparency"], x = x, y = y }, true):autoWidth():width()

	ui:append("WndSliderBox", {
		x = x + 2, y = y + 4,
		value = ceil((200 - MY_TargetFace.nShapeAlpha) / 2),
		range = {0, 100},
		sliderstyle = MY_SLIDER_DISPTYPE.SHOW_VALUE,
		textfmt = function(val) return _L('%d %%', val) end,
		onchange = function(val) MY_TargetFace.nShapeAlpha = (100 - val) * 2 end,
	})
end
MY.RegisterPanel('MY_TargetFace', _L['MY_TargetFace'], _L['Target'], 2136, PS)
end

-- Global exports
do
local settings = {
	exports = {
		{
			fields = {
				bTargetFace        = true,
				bTTargetFace       = true,
				nSectorDegree      = true,
				nSectorRadius      = true,
				nSectorAlpha       = true,
				tTargetFaceColor   = true,
				tTTargetFaceColor  = true,
				bTargetShape       = true,
				bTTargetShape      = true,
				nShapeRadius       = true,
				nShapeAlpha        = true,
				tTargetShapeColor  = true,
				tTTargetShapeColor = true,
			},
			root = O,
		},
	},
	imports = {
		{
			fields = {
				bTargetFace        = true,
				bTTargetFace       = true,
				nSectorDegree      = true,
				nSectorRadius      = true,
				nSectorAlpha       = true,
				tTargetFaceColor   = true,
				tTTargetFaceColor  = true,
				bTargetShape       = true,
				bTTargetShape      = true,
				nShapeRadius       = true,
				nShapeAlpha        = true,
				tTargetShapeColor  = true,
				tTTargetShapeColor = true,
			},
			triggers = {
				bTargetFace        = D.CheckEnable,
				bTTargetFace       = D.CheckEnable,
				nSectorDegree      = D.RequireRerender,
				nSectorRadius      = D.RequireRerender,
				nSectorAlpha       = D.RequireRerender,
				tTargetFaceColor   = D.RequireRerender,
				tTTargetFaceColor  = D.RequireRerender,
				bTargetShape       = D.CheckEnable,
				bTTargetShape      = D.CheckEnable,
				nShapeRadius       = D.RequireRerender,
				nShapeAlpha        = D.RequireRerender,
				tTargetShapeColor  = D.RequireRerender,
				tTTargetShapeColor = D.RequireRerender,
			},
			root = O,
		},
	},
}
MY_TargetFace = MY.GeneGlobalNS(settings)
end
