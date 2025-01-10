
local Lang = require 'Lang'
local ui = require 'pigui'

local lui = Lang.GetResource("ui-core")
local syon_ui = Lang.GetResource("module-syon")
local le = Lang.GetResource("equipment-core")

local SystemPath = require 'SystemPath'
local msgbox = require 'pigui.libs.message-box'
local Character = require 'Character'
local Commodities = require 'Commodities'


local StartVariants = require 'pigui.modules.new-game-window.start-variants'

local Game = require 'Game'


local equipment2 = {
	computer_1     = "misc.autopilot",
	laser_front_s2 = "laser.pulsecannon_1mw",
	shield_s1_1    = "shield.basic_s1",
	shield_s1_2    = "shield.basic_s1",
	sensor         = "sensor.radar",
	hull_mod       = "hull.atmospheric_shielding",
	hyperdrive     = "hyperspace.hyperdrive_2",
	thruster       = "misc.thrusters_default",
	missile_bay_1  = "missile_bay.opli_internal_s2",
	missile_bay_2  = "missile_bay.opli_internal_s2",
}


-- Equipment item grouping by underlying slot kinds
local eqsec = {
	{ name = le.PROPULSION, types = { "engine", "thruster", "hyperdrive" } },
	{ name = le.WEAPONS, type = "weapon" },
	{ name = le.MISSILES, types = { "pylon", "missile_bay", "missile" } },
	{ name = le.SHIELDS, type = "shield" },
	{ name = le.SENSORS, type = "sensor", },
	{ name = le.COMPUTER_MODULES, type = "computer", },
	{ name = le.CABINS, types = { "cabin" } },
	{ name = le.HULL_MOUNTS, types = { "hull", "utility", "fuel_scoop", "structure" } },
}

StartVariants.register({
	name           = lui.START_AT_SYON,
	desc           = lui.START_AT_SYON_DESC,
	location       = SystemPath.New(4, 2, 5, 0, 3),
	logmsg         = lui.START_LOG_ENTRY_4,
	shipType       = 'syontrix',
	money          = 5000,
	hyperdrive     = true,
	equipment      = {
  		--{ equipment2.computer_1,      1 },
  		--{ equipment2.missile_bay_1,      1 },
-- 		{misc.atmospheric_shielding,1},
 		--{ "misc.autopilot",1},
 		--{ "sensor.radar",1}
	},
	cargo          = {
		--{ Commodities.hydrogen, 10 }
	},
	pattern    = 2,
-- 	colors     = { Color('000000'), Color('000000'), Color('000000') }

    colors = { Color('FF7F00'), Color('E0E0E0'), Color('0000FF') }
})
