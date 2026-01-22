

-- this module / class allows the storage of equipment on

-- It is logical that this is stored eather in the system or in the player.

-- player.ec = {system_path: EquipmentCache

-- if stored in the system then it may be hard to lookup all the caches for a player ui.

-- if stored in the ship what happens when the player changes ship.


-- Todo

-- Restaurateur = a person who owns or manages a restaurant.
--
-- A BaseStructue has a
--
-- location::OBJECT
--     - system::SYSTEM
--     - body::BODY
--     - pos::LATLON
--
-- storage::OBJECT
--     - CAPACITY::INT
--     - ITEMS::ARRAY
--
-- owner::PLAYER
--     - player
