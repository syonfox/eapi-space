-- Copyright © 2008-2025 Pioneer Developers. See AUTHORS.txt for details
-- Licensed under the terms of the GPL v3. See licenses/GPL-3.txt

--local EquipTypes = require 'Equipment/Types'

local EquipType = require 'EquipType'


local Equipment  = require 'Equipment'
local Slot      = require 'HullConfig'.Slot
local EquipTypes = require '.Types'

local LaserType = EquipTypes.LaserType

--===============================================
-- Mining Cannons
--===============================================
--
Equipment.Register("laser.syoncannon_5mw", LaserType.New {
	l10n_key="SYONCANNON_5MW",
	price=13700, purchasable=true, tech_level=5,
	mass=6, volume=6, capabilities={},
	slot = { type="weapon.mining", size=2, hardpoint=true },
	laser_stats = {
		lifespan=8, speed=1500, damage=5500, rechargeTime=0.75, length=60,
		width=8, beam=0, dual=0, mining=1, rgba_r = 45, rgba_g = 232, rgba_b = 10, rgba_a = 200
	},
	icon_name="equip_mining_laser"
})

--
-- Equipment.Register("laser.miningcannon_5mw", LaserType.New {
-- 	l10n_key="MININGCANNON_5MW",
-- 	price=3700, purchasable=true, tech_level=5,
-- 	mass=6, volume=6, capabilities={},
-- 	slot = { type="weapon.mining", size=2, hardpoint=true },
-- 	laser_stats = {
-- 		lifespan=8, speed=1000, damage=5000, rechargeTime=1.5, length=30,
-- 		width=5, beam=0, dual=0, mining=1, rgba_r = 51, rgba_g = 127, rgba_b = 0, rgba_a = 255
-- 	},
-- 	icon_name="equip_mining_laser"
-- })
--
--Equipment.Register("laser.miningcannon_17mw", LaserType.New {
--	l10n_key="MININGCANNON_17MW",
--	price=10600, purchasable=true, tech_level=8,
--	mass=10, volume=10, capabilities={},
--	slot = { type="weapon.mining", size=4, hardpoint=true },
--	laser_stats = {
--		lifespan=8, speed=1000, damage=17000, rechargeTime=2, length=30,
--		width=5, beam=0, dual=0, mining=1, rgba_r = 51, rgba_g = 127, rgba_b = 0, rgba_a = 255
--	},
--	icon_name="equip_mining_laser"
--})

--===============================================
-- Missiles
--===============================================

------ Approximately equivalent in size to an R73 / AA-11 'Archer'
--Equipment.Register("missile.foxi_s2", EquipType.New {
--	l10n_key="MISSILE_GUIDED",
--	price=90, purchasable=true, tech_level=4,
--	missile_type="missile_smart",
--	volume=0, mass=0.150,
--	slot = { type="missile", size=2, hardpoint=true },
--	icon_name="equip_missile_smart"
--})


--===============================================
-- Internal Missile Bays
--===============================================
--/home/user/git/pioneer/data/lang/equipment-core/en.json
Equipment.Register("missile_bay.foxi_internal_s2", EquipType.New {
	l10n_key="FOXI_INTERNAL_MISSILE_RACK_S2",
	price=350, purchasable=true, tech_level=2,
	volume=5.0, mass=0.4,
	slot = { type = "missile_bay.opli_internal", size=2, hardpoint=true },
	provides_slots = {
		Slot:clone { id = "1", type = "missile", size = 2, hardpoint = true },
		Slot:clone { id = "2", type = "missile", size = 2, hardpoint = true },
		Slot:clone { id = "3", type = "missile", size = 2, hardpoint = true },
		Slot:clone { id = "4", type = "missile", size = 2, hardpoint = true },
		Slot:clone { id = "5", type = "missile", size = 2, hardpoint = true },
        Slot:clone { id = "6", type = "missile", size = 2, hardpoint = true },
		Slot:clone { id = "7", type = "missile", size = 2, hardpoint = true },
		Slot:clone { id = "8", type = "missile", size = 2, hardpoint = true },
	},
	icon_name="equip_missile_unguided"
})
