
---------------------------------------------------------------------------------------------------
-- these global functions are accessed all the time by the event handler
-- so caching them is worth the effort
---------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local ipairs, pairs, next, pcall = ipairs, pairs, next, pcall
local sub, len, format, rep = string.sub, string.len, string.format, string.rep
local find, byte, char, gsub = string.find, string.byte, string.char, string.gsub
local type, tonumber, tostring = type, tonumber, tostring
local huge, pi, random = math.huge, math.pi, math.random
local min, max, floor, ceil = math.min, math.max, math.floor, math.ceil
local pow, sqrt, sin, cos, tan = math.pow, math.sqrt, math.sin, math.cos, math.tan
local insert, remove, concat, sort = table.insert, table.remove, table.concat, table.sort
local pack, unpack = table.pack or function(...) return {...} end, table.unpack or unpack
-- jx3 apis caching
local wsub, wlen, wfind = wstring.sub, wstring.len, wstring.find
local GetTime, GetLogicFrameCount = GetTime, GetLogicFrameCount
local GetClientTeam, UI_GetClientPlayerID = GetClientTeam, UI_GetClientPlayerID
local GetClientPlayer, GetPlayer, GetNpc, IsPlayer = GetClientPlayer, GetPlayer, GetNpc, IsPlayer
local IsNil, IsBoolean, IsEmpty, RandomChild = MY.IsNil, MY.IsBoolean, MY.IsEmpty, MY.RandomChild
local IsNumber, IsString, IsTable, IsFunction = MY.IsNumber, MY.IsString, MY.IsTable, MY.IsFunction
---------------------------------------------------------------------------------------------------
local _L = MY.LoadLangPack(MY.GetAddonInfo().szRoot .. 'MY_Cataclysm/lang/')
local CFG, PS = MY_Cataclysm.CFG, {}

function PS.OnPanelActive(frame)
	local ui = XGUI(frame)
	local X, Y = 20, 20
	local x, y = X, Y

	y = y + ui:append('Text', { x = x, y = y, text = _L['Grid Style'], font = 27 }, true):height()

	y = y + 5

	x = X + 10
	y = y + ui:append('WndCheckBox', {
		x = x, y = y, text = _L['Show AllGrid'],
		checked = CFG.bShowAllGrid,
		oncheck = function(bCheck)
			CFG.bShowAllGrid = bCheck
			MY_Cataclysm.ReloadCataclysmPanel()
		end,
	}, true):autoWidth():height() + 5

	x = X
	y = y + 10

	-- 名字、图标、内力和血量显示方案
	x = X
	y = y + ui:append('Text', { x = x, y = y, text = _L['Name/Icon/Mana/Life Display'], font = 27 }, true):height()

	-- 名字
	x = X + 10
	y = y + 5
	for _, p in ipairs({
		{ 1, _L['Name colored by force'] },
		{ 2, _L['Name colored by camp'] },
		{ 0, _L['Name without color'] },
	}) do
		x = x + ui:append('WndRadioBox', {
			x = x, y = y, text = p[2],
			group = 'namecolor', checked = CFG.nColoredName == p[1],
			oncheck = function()
				CFG.nColoredName = p[1]
				if MY_Cataclysm.GetFrame() then
					Grid_CTM:CallRefreshImages(true, false, false, nil, true)
					Grid_CTM:CallDrawHPMP(true ,true)
				end
			end,
		}, true):autoWidth():width() + 5
	end

	y = y + ui:append('WndSliderBox', {
		x = x, y = y - 1,
		value = CFG.fNameFontScale * 100,
		range = {1, 400},
		sliderstyle = MY_SLIDER_DISPTYPE.SHOW_VALUE,
		textfmt = function(val) return _L('Scale %d%%', val) end,
		onchange = function(val)
			CFG.fNameFontScale = val / 100
			if MY_Cataclysm.GetFrame() then
				Grid_CTM:CallRefreshImages(nil, nil, nil, nil, true)
			end
		end,
	}, true):height()

	x = X + 10
	for _, p in ipairs({
		{ 0, _L['Top'] },
		{ 1, _L['Middle'] },
		{ 2, _L['Bottom'] },
	}) do
		x = x + ui:append('WndRadioBox', {
			x = x, y = y, text = p[2],
			group = 'namevali', checked = CFG.nNameVAlignment == p[1],
			oncheck = function()
				CFG.nNameVAlignment = p[1]
				Grid_CTM:CallRefreshImages(true, false, true, nil, true)
			end,
		}, true):autoWidth():width() + 5
	end
	for _, p in ipairs({
		{ 0, _L['Left'] },
		{ 1, _L['Center'] },
		{ 2, _L['Right'] },
	}) do
		x = x + ui:append('WndRadioBox', {
			x = x, y = y, text = p[2],
			group = 'namehali', checked = CFG.nNameHAlignment == p[1],
			oncheck = function()
				CFG.nNameHAlignment = p[1]
				Grid_CTM:CallRefreshImages(true, false, true, nil, true)
			end,
		}, true):autoWidth():width() + 5
	end
	-- 名字字体修改
	x = x + ui:append('WndButton2', {
		x = x, y = y - 3, text = _L['Name font'],
		onclick = function()
			XGUI.OpenFontPicker(function(nFont)
				CFG.nNameFont = nFont
				if MY_Cataclysm.GetFrame() then
					Grid_CTM:CallRefreshImages(true, false, false, nil, true)
					Grid_CTM:CallDrawHPMP(true, true)
				end
			end)
		end,
	}, true):autoWidth():width() + 5
	y = y + 25

	-- 血量显示方式
	x = X + 10
	y = y + 10
	for _, p in ipairs({
		{ 2, g_tStrings.STR_RAID_LIFE_LEFT },
		{ 1, g_tStrings.STR_RAID_LIFE_LOSE },
		{ 0, g_tStrings.STR_RAID_LIFE_HIDE },
	}) do
		x = x + ui:append('WndRadioBox', {
			x = x, y = y, text = p[2],
			group = 'lifemode', checked = CFG.nHPShownMode2 == p[1],
			oncheck = function()
				CFG.nHPShownMode2 = p[1]
				if MY_Cataclysm.GetFrame() then
					Grid_CTM:CallDrawHPMP(true, true)
				end
			end,
		}, true):autoWidth():width() + 5
	end

	ui:append('WndSliderBox', {
		x = x, y = y - 1,
		value = CFG.fLifeFontScale * 100,
		range = {1, 400},
		sliderstyle = MY_SLIDER_DISPTYPE.SHOW_VALUE,
		textfmt = function(val) return _L('Scale %d%%', val) end,
		onchange = function(val)
			CFG.fLifeFontScale = val / 100
			if MY_Cataclysm.GetFrame() then
				Grid_CTM:CallDrawHPMP(true, true)
			end
		end,
		autoenable = function() return CFG.nHPShownMode2 ~= 0 end,
	}, true)
	y = y + 25

	-- 血量数值显示方案
	x = X + 10
	for _, p in ipairs({
		{ 1, _L['Show Format value'] },
		{ 2, _L['Show Percentage value'] },
		{ 3, _L['Show full value'] },
	}) do
		x = x + ui:append('WndRadioBox', {
			x = x, y = y, text = p[2],
			group = 'lifval', checked = CFG.nHPShownNumMode == p[1],
			autoenable = function() return CFG.nHPShownMode2 ~= 0 end,
			oncheck = function()
				CFG.nHPShownNumMode = p[1]
				if MY_Cataclysm.GetFrame() then
					Grid_CTM:CallDrawHPMP(true, true)
				end
			end,
		}, true):autoWidth():width() + 5
	end

	x = x + ui:append('WndCheckBox', {
		x = x, y = y, text = _L['Show Decimal'],
		checked = CFG.bShowHPDecimal,
		oncheck = function(bCheck)
			CFG.bShowHPDecimal = bCheck
			if MY_Cataclysm.GetFrame() then
				Grid_CTM:CallDrawHPMP(true, true)
			end
		end,
	}, true):autoWidth():width() + 5
	y = y + 25

	x = X + 10
	for _, p in ipairs({
		{ 0, _L['Top'] },
		{ 1, _L['Middle'] },
		{ 2, _L['Bottom'] },
	}) do
		x = x + ui:append('WndRadioBox', {
			x = x, y = y, text = p[2],
			group = 'lifvali', checked = CFG.nHPVAlignment == p[1],
			autoenable = function() return CFG.nHPShownMode2 ~= 0 end,
			oncheck = function()
				CFG.nHPVAlignment = p[1]
				Grid_CTM:CallRefreshImages(true, false, true, nil, true)
			end,
		}, true):autoWidth():width() + 5
	end
	for _, p in ipairs({
		{ 0, _L['Left'] },
		{ 1, _L['Center'] },
		{ 2, _L['Right'] },
	}) do
		x = x + ui:append('WndRadioBox', {
			x = x, y = y, text = p[2],
			group = 'lifhali', checked = CFG.nHPHAlignment == p[1],
			autoenable = function() return CFG.nHPShownMode2 ~= 0 end,
			oncheck = function()
				CFG.nHPHAlignment = p[1]
				Grid_CTM:CallRefreshImages(true, false, true, nil, true)
			end,
		}, true):autoWidth():width() + 5
	end
	ui:append('WndButton2', {
		x = x, y = y - 1, text = _L['Life font'],
		onclick = function()
			XGUI.OpenFontPicker(function(nFont)
				CFG.nLifeFont = nFont
				if MY_Cataclysm.GetFrame() then
					Grid_CTM:CallDrawHPMP(true, true)
				end
			end)
		end,
		autoenable = function() return CFG.nHPShownMode2 ~= 0 end,
	}, true):autoWidth()
	y = y + 25

	-- 图标显示方案
	x = X + 10
	y = y + 10
	for _, p in ipairs({
		{ 1, _L['Show Force Icon'] },
		{ 2, g_tStrings.STR_SHOW_KUNGFU },
		{ 3, _L['Show Camp Icon'] },
		{ 4, _L['Show Text Force'] },
	}) do
		x = x + ui:append('WndRadioBox', {
			x = x, y = y, text = p[2],
			group = 'icon', checked = CFG.nShowIcon == p[1],
			oncheck = function()
				CFG.nShowIcon = p[1]
				if MY_Cataclysm.GetFrame() then
					Grid_CTM:CallRefreshImages(true, false, true, nil, true)
					Grid_CTM:CallDrawHPMP(true, true)
				end
			end,
		}, true):autoWidth():width() + 5
	end
	y = y + 25

	-- 内力显示
	x = X + 10
	x = x + ui:append('WndCheckBox', {
		x = x, y = y, text = _L['Show ManaCount'],
		checked = CFG.nShowMP,
		oncheck = function(bCheck)
			CFG.nShowMP = bCheck
			if MY_Cataclysm.GetFrame() then
				Grid_CTM:CallDrawHPMP(true, true)
			end
		end,
	}, true):autoWidth():width() + 5

	x = x + ui:append('WndButton2', {
		x = x, y = y, text = g_tStrings.STR_SKILL_MANA .. g_tStrings.FONT,
		onclick = function()
			XGUI.OpenFontPicker(function(nFont)
				CFG.nManaFont = nFont
				if MY_Cataclysm.GetFrame() then
					Grid_CTM:CallDrawHPMP(true, true)
				end
			end)
		end,
		autoenable = function() return CFG.nShowMP end,
	}, true):width() + 5

	ui:append('WndSliderBox', {
		x = x, y = y - 1,
		value = CFG.fManaFontScale * 100,
		range = {1, 400},
		sliderstyle = MY_SLIDER_DISPTYPE.SHOW_VALUE,
		textfmt = function(val) return _L('Scale %d%%', val) end,
		onchange = function(val)
			CFG.fManaFontScale = val / 100
			if MY_Cataclysm.GetFrame() then
				Grid_CTM:CallDrawHPMP(true, true)
			end
		end,
		autoenable = function() return CFG.nShowMP end,
	}, true)
	y = y + 25
end
MY.RegisterPanel('MY_Cataclysm_GridStyle', _L['Grid Style'], _L['Raid'], 'ui/Image/UICommon/RaidTotal.uitex|68', {255, 255, 0}, PS)
