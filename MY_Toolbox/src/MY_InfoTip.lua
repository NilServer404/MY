--------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.derzh.com/
-- @desc     : 信息条显示
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
local PLUGIN_NAME = 'MY_Toolbox'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_InfoTip'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^9.0.0') then
	return
end
--------------------------------------------------------------------------

local CONFIG_FILE_PATH = {'config/infotip.jx3dat', X.PATH_TYPE.ROLE}
local INFO_TIP_LIST = {
	-- 网络延迟
	{
		id = 'Ping',
		i18n = {
			name = _L['Ping monitor'], prefix = _L['Ping: '], content = '%d',
		},
		config = X.CreateUserSettingsModule('MY_InfoTip__Ping', _L['System'], {
			bEnable = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Boolean,
				xDefaultValue = false,
			},
			bShowBg = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Boolean,
				xDefaultValue = false,
			},
			bShowTitle = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Boolean,
				xDefaultValue = false,
			},
			rgb = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Tuple(X.Schema.Number, X.Schema.Number, X.Schema.Number),
				xDefaultValue = { 95, 255, 95 },
			},
			nFont = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Number,
				xDefaultValue = 48,
			},
			anchor = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.FrameAnchor,
				xDefaultValue = { x = -133, y = -111, s = 'BOTTOMCENTER', r = 'BOTTOMCENTER' },
			},
		}),
		options = {
			bPlaceholder = false,
		},
		cache = {},
		GetFormatString = function(data)
			return string.format(data.cache.formatString, GetPingValue() / 2)
		end,
	},
	-- 倍速显示（显示服务器有多卡……）
	{
		id = 'TimeMachine',
		i18n = {
			name = _L['Time machine'], prefix = _L['Rate: '], content = 'x%.2f',
		},
		config = X.CreateUserSettingsModule('MY_InfoTip__TimeMachine', _L['System'], {
			bEnable = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Boolean,
				xDefaultValue = false,
			},
			bShowBg = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Boolean,
				xDefaultValue = false,
			},
			bShowTitle = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Boolean,
				xDefaultValue = true,
			},
			rgb = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Tuple(X.Schema.Number, X.Schema.Number, X.Schema.Number),
				xDefaultValue = { 31, 255, 31 },
			},
			nFont = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Number,
				xDefaultValue = 0,
			},
			anchor = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.FrameAnchor,
				xDefaultValue = { x = -276, y = -111, s = 'BOTTOMCENTER', r = 'BOTTOMCENTER' },
			},
		}),
		options = {
			bPlaceholder = false,
		},
		cache = {
			tTimeMachineRec = {},
			nTimeMachineLFC = GetLogicFrameCount(),
		},
		GetFormatString = function(data)
			local s = 1
			if data.cache.nTimeMachineLFC ~= GetLogicFrameCount() then
				local tm = data.cache.tTimeMachineRec[GLOBAL.GAME_FPS] or {}
				tm.frame = GetLogicFrameCount()
				tm.tick  = GetTickCount()
				for i = GLOBAL.GAME_FPS, 1, -1 do
					data.cache.tTimeMachineRec[i] = data.cache.tTimeMachineRec[i - 1]
				end
				data.cache.tTimeMachineRec[1] = tm
				data.cache.nTimeMachineLFC = GetLogicFrameCount()
			end
			local tm = data.cache.tTimeMachineRec[GLOBAL.GAME_FPS]
			if tm then
				s = 1000 * (GetLogicFrameCount() - tm.frame) / GLOBAL.GAME_FPS / (GetTickCount() - tm.tick)
			end
			return string.format(data.cache.formatString, s)
		end,
	},
	-- 目标距离
	{
		id = 'Distance',
		i18n = {
			name = _L['Target distance'], prefix = _L['Distance: '], content = _L['%.1f Foot'],
		},
		config = X.CreateUserSettingsModule('MY_InfoTip__Distance', _L['System'], {
			bEnable = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Boolean,
				xDefaultValue = false,
			},
			bShowBg = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Boolean,
				xDefaultValue = false,
			},
			bShowTitle = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Boolean,
				xDefaultValue = false,
			},
			bPlaceholder = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Boolean,
				xDefaultValue = true,
			},
			rgb = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Tuple(X.Schema.Number, X.Schema.Number, X.Schema.Number),
				xDefaultValue = { 255, 255, 0 },
			},
			nFont = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Number,
				xDefaultValue = 209,
			},
			anchor = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.FrameAnchor,
				xDefaultValue = { x = 203, y = -106, s = 'CENTER', r = 'CENTER' },
			},
		}),
		options = {
			bPlaceholder = true,
		},
		cache = {},
		GetFormatString = function(data)
			local p, s = X.GetObject(X.GetTarget()), data.config.bPlaceholder and _L['No Target'] or ''
			if p then
				s = string.format(data.cache.formatString, X.GetDistance(p))
			end
			return s
		end,
	},
	-- 系统时间
	{
		id = 'SysTime',
		i18n = {
			name = _L['System time'], prefix = _L['Time: '], content = '%02d:%02d:%02d',
		},
		config = X.CreateUserSettingsModule('MY_InfoTip__SysTime', _L['System'], {
			bEnable = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Boolean,
				xDefaultValue = false,
			},
			bShowBg = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Boolean,
				xDefaultValue = true,
			},
			bShowTitle = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Boolean,
				xDefaultValue = true,
			},
			rgb = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Tuple(X.Schema.Number, X.Schema.Number, X.Schema.Number),
				xDefaultValue = { 255, 255, 255 },
			},
			nFont = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Number,
				xDefaultValue = 0,
			},
			anchor = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.FrameAnchor,
				xDefaultValue = { x = 285, y = -18, s = 'BOTTOMLEFT', r = 'BOTTOMLEFT' },
			},
		}),
		options = {
			bPlaceholder = false,
		},
		cache = {},
		GetFormatString = function(data)
			local tDateTime = TimeToDate(GetCurrentTime())
			return string.format(data.cache.formatString, tDateTime.hour, tDateTime.minute, tDateTime.second)
		end,
	},
	-- 战斗计时
	{
		id = 'FightTime',
		i18n = {
			name = _L['Fight clock'], prefix = _L['Fight Clock: '], content = '',
		},
		config = X.CreateUserSettingsModule('MY_InfoTip__FightTime', _L['System'], {
			bEnable = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Boolean,
				xDefaultValue = false,
			},
			bShowBg = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Boolean,
				xDefaultValue = false,
			},
			bShowTitle = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Boolean,
				xDefaultValue = false,
			},
			bPlaceholder = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Boolean,
				xDefaultValue = true,
			},
			rgb = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Tuple(X.Schema.Number, X.Schema.Number, X.Schema.Number),
				xDefaultValue = { 255, 0, 128 },
			},
			nFont = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Number,
				xDefaultValue = 199,
			},
			anchor = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.FrameAnchor,
				xDefaultValue = { x = 353, y = -117, s = 'BOTTOMCENTER', r = 'BOTTOMCENTER' },
			},
		}),
		options = {
			bPlaceholder = true,
		},
		cache = {},
		GetFormatString = function(data)
			if X.GetFightUUID() or X.GetLastFightUUID() then
				return data.cache.formatString .. X.GetFightTime('H:mm:ss')
			end
			return data.config.bPlaceholder and _L['Never Fight'] or ''
		end,
	},
	-- 莲花和藕倒计时
	{
		id = 'LotusTime',
		i18n = {
			name = _L['Lotus clock'], prefix = _L['Lotus Clock: '], content = '%d:%d:%d',
		},
		config = X.CreateUserSettingsModule('MY_InfoTip__LotusTime', _L['System'], {
			bEnable = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Boolean,
				xDefaultValue = false,
			},
			bShowBg = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Boolean,
				xDefaultValue = true,
			},
			bShowTitle = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Boolean,
				xDefaultValue = true,
			},
			rgb = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Tuple(X.Schema.Number, X.Schema.Number, X.Schema.Number),
				xDefaultValue = { 255, 255, 255 },
			},
			nFont = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Number,
				xDefaultValue = 0,
			},
			anchor = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.FrameAnchor,
				xDefaultValue = { x = -290, y = -38, s = 'BOTTOMRIGHT', r = 'BOTTOMRIGHT' },
			},
		}),
		options = {
			bPlaceholder = false,
		},
		cache = {},
		GetFormatString = function(data)
			local nTotal = 6 * 60 * 60 - GetLogicFrameCount() / 16 % (6 * 60 * 60)
			return string.format(data.cache.formatString, math.floor(nTotal / (60 * 60)), math.floor(nTotal / 60 % 60), math.floor(nTotal % 60))
		end,
	},
	-- 角色坐标
	{
		id = 'GPS',
		i18n = {
			name = _L['GPS'], prefix = _L['Location: '], content = '[%d]%d,%d,%d',
		},
		config = X.CreateUserSettingsModule('MY_InfoTip__GPS', _L['System'], {
			bEnable = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Boolean,
				xDefaultValue = false,
			},
			bShowBg = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Boolean,
				xDefaultValue = true,
			},
			bShowTitle = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Boolean,
				xDefaultValue = false,
			},
			rgb = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Tuple(X.Schema.Number, X.Schema.Number, X.Schema.Number),
				xDefaultValue = { 255, 255, 255 },
			},
			nFont = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Number,
				xDefaultValue = 0,
			},
			anchor = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.FrameAnchor,
				xDefaultValue = { x = -21, y = 250, s = 'TOPRIGHT', r = 'TOPRIGHT' },
			},
		}),
		options = {
			bPlaceholder = false,
		},
		cache = {},
		GetFormatString = function(data)
			local player, text = GetClientPlayer(), ''
			if player then
				text = string.format(data.cache.formatString, player.GetMapID(), player.nX, player.nY, player.nZ)
			end
			return text
		end,
	},
	-- 角色速度
	{
		id = 'Speedometer',
		i18n = {
			name = _L['Speedometer'], prefix = _L['Speed: '], content = _L['%.2f f/s'],
		},
		config = X.CreateUserSettingsModule('MY_InfoTip__Speedometer', _L['System'], {
			bEnable = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Boolean,
				xDefaultValue = false,
			},
			bShowBg = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Boolean,
				xDefaultValue = false,
			},
			bShowTitle = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Boolean,
				xDefaultValue = false,
			},
			rgb = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Tuple(X.Schema.Number, X.Schema.Number, X.Schema.Number),
				xDefaultValue = { 255, 255, 255 },
			},
			nFont = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.Number,
				xDefaultValue = 0,
			},
			anchor = {
				ePathType = X.PATH_TYPE.ROLE,
				szLabel = _L['MY_InfoTip'],
				xSchema = X.Schema.FrameAnchor,
				xDefaultValue = { x = -10, y = 210, s = 'TOPRIGHT', r = 'TOPRIGHT' },
			},
		}),
		options = {
			bPlaceholder = false,
		},
		cache = {
			tSpeedometerRec = {},
			nSpeedometerLFC = GetLogicFrameCount(),
		},
		GetFormatString = function(data)
			local s = 0
			local me = GetClientPlayer()
			if me and data.cache.nSpeedometerLFC ~= GetLogicFrameCount() then
				local sm = data.cache.tSpeedometerRec[GLOBAL.GAME_FPS] or {}
				sm.framecount = GetLogicFrameCount()
				sm.x, sm.y, sm.z = me.nX, me.nY, me.nZ
				for i = GLOBAL.GAME_FPS, 1, -1 do
					data.cache.tSpeedometerRec[i] = data.cache.tSpeedometerRec[i - 1]
				end
				data.cache.tSpeedometerRec[1] = sm
				data.cache.nSpeedometerLFC = GetLogicFrameCount()
			end
			local sm = data.cache.tSpeedometerRec[GLOBAL.GAME_FPS]
			if sm and me then
				s = math.sqrt(math.pow(me.nX - sm.x, 2) + math.pow(me.nY - sm.y, 2) + math.pow((me.nZ - sm.z) / 8, 2)) / 64
					/ (GetLogicFrameCount() - sm.framecount) * GLOBAL.GAME_FPS
			end
			return string.format(data.cache.formatString, s)
		end
	},
}
local D = {}

X.RegisterEvent('CUSTOM_UI_MODE_SET_DEFAULT', function()
	for _, v in ipairs(INFO_TIP_LIST) do
		v.config('reset', {'anchor'})
	end
	D.ReinitUI()
end)

-- 显示信息条
function D.ReinitUI()
	for _, data in ipairs(INFO_TIP_LIST) do
		local ui = UI('Normal/MY_InfoTip_' .. data.id)
		if data.config.bEnable then
			if ui:Count() == 0 then
				ui = UI.CreateFrame('MY_InfoTip_' .. data.id, { empty = true })
					:Size(220,30)
					:Event(
						'UI_SCALED',
						function()
							UI(this):Anchor(data.config.anchor)
						end)
					:CustomLayout(data.i18n.name)
					:CustomLayout(function(bEnter, anchor)
						if bEnter then
							UI(this):BringToTop()
						else
							data.config.anchor = anchor
						end
					end)
					:Drag(0, 0, 0, 0)
					:Drag(false)
					:Penetrable(true)
				ui:Append('Image', {
					name = 'Image_Default',
					w = 220, h = 30,
					alpha = 180,
					image = 'UI/Image/UICommon/Commonpanel.UITex', imageframe = 86,
				})
				local txt = ui:Append('Text', {
					name = 'Text_Default',
					w = 220, h = 30,
					text = data.i18n.name,
					font = 2, valign = 1, halign = 1,
				})
				ui:Breathe(function() txt:Text(data.GetFormatString(data)) end)
			end
			data.cache.formatString = data.config.bShowTitle
				and data.i18n.prefix .. data.i18n.content
				or data.i18n.content
			ui:Fetch('Image_Default'):Visible(data.config.bShowBg)
			ui:Fetch('Text_Default')
				:Font(data.config.nFont or 0)
				:Color(data.config.rgb or { 255, 255, 255 })
			ui:Anchor(data.config.anchor)
		else
			ui:Remove()
		end
	end
end

-- 注册INIT事件
X.RegisterUserSettingsUpdate('@@INIT@@', 'MY_INFOTIP', function()
	D.ReinitUI()
end)

local PS = {}

function PS.OnPanelActive(wnd)
	local ui = UI(wnd)
	local w, h = ui:Size()
	local x, y = 45, 40

	ui:Append('Text', {
		name = 'Text_InfoTip',
		x = x, y = y, w = 350,
		text = _L['Infomation tips'],
		color = {255, 255, 0},
	})
	y = y + 5

	for _, data in ipairs(INFO_TIP_LIST) do
		x, y = 60, y + 30

		ui:Append('WndCheckBox', {
			name = 'WndCheckBox_InfoTip_' .. data.id,
			x = x, y = y, w = 250,
			text = data.i18n.name,
			checked = data.config.bEnable or false,
			oncheck = function(bChecked)
				data.config.bEnable = bChecked
				D.ReinitUI()
			end,
		})
		x = x + 220

		if data.options.bPlaceholder then
			ui:Append('WndCheckBox', {
				name = 'WndCheckBox_InfoTipPlaceholder_' .. data.id,
				x = x, y = y, w = 100,
				text = _L['Placeholder'],
				checked = data.config.bPlaceholder or false,
				oncheck = function(bChecked)
					data.config.bPlaceholder = bChecked
					D.ReinitUI()
				end,
			})
		end
		x = x + 100

		ui:Append('WndCheckBox', {
			name = 'WndCheckBox_InfoTipTitle_' .. data.id,
			x = x, y = y, w = 60,
			text = _L['Title'],
			checked = data.config.bShowTitle or false,
			oncheck = function(bChecked)
				data.config.bShowTitle = bChecked
				D.ReinitUI()
			end,
		})
		x = x + 70

		ui:Append('WndCheckBox', {
			name = 'WndCheckBox_InfoTipBg_' .. data.id,
			x = x, y = y, w = 60,
			text = _L['Background'],
			checked = data.config.bShowBg or false,
			oncheck = function(bChecked)
				data.config.bShowBg = bChecked
				D.ReinitUI()
			end,
		})
		x = x + 70

		ui:Append('WndButton', {
			name = 'WndButton_InfoTipFont_' .. data.id,
			x = x, y = y, w = 50,
			text = _L['Font'],
			onclick = function()
				UI.OpenFontPicker(function(f)
					data.config.nFont = f
					D.ReinitUI()
				end)
			end,
		})
		x = x + 60

		ui:Append('Shadow', {
			name = 'Shadow_InfoTipColor_' .. data.id,
			x = x, y = y, w = 20, h = 20,
			color = data.config.rgb or {255, 255, 255},
			onclick = function()
				local el = this
				UI.OpenColorPicker(function(r, g, b)
					UI(el):Color(r, g, b)
					data.config.rgb = { r, g, b }
					D.ReinitUI()
				end)
			end,
		})
	end
end
X.RegisterPanel(_L['System'], 'MY_InfoTip', _L['MY_InfoTip'], 'ui/Image/UICommon/ActivePopularize2.UITex|22', PS)
