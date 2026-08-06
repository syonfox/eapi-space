--Syon Mod Main File
-- By syonfox
-- adds a sidebar and logic for clandestin missions

local Commodities = require 'Commodities'
local utils = require 'utils'
local Vector2 = _G.Vector2
local ShipDef = require 'ShipDef'

local Lang = require 'Lang'
local lui = Lang.GetResource("ui-core");
local ui = require 'pigui'
local uitimers = require 'pigui.libs.ui-timer'
local msgbox = require 'pigui.libs.message-box' -- like browser alert

-- cache ui
local pionillium = ui.fonts.pionillium
local colors = ui.theme.colors
local icons = ui.theme.icons
local buttonColors = ui.theme.buttonColors

local style = {
    cargoColor = colors.gaugeCargo,
    jettisonColor = colors.gaugeJettison
}

local AMT_OF_AMT = "%st / %st"

local gameView = require 'pigui.views.game' -- used to register the sidbar

local Game = require 'Game'                 -- notibaly Game.system and Game.player
local Player = require 'Player'
local PlayerState = require 'PlayerState'

local Event = require 'Event'               -- Subscribe to game events for logic
local Engine = require 'Engine'
local Timer = require 'Timer'               -- Create Timers
local Serializer = require 'Serializer'
local Legal = require 'Legal'
local SpaceStation = require 'SpaceStation'
local Equipment = require 'Equipment'
local EquipSet = require 'EquipSet'


-------------------------------------------------------------------------------
-- Syon Mod Global object / data namspace
-------------------------------------------------------------------------------
-- Define the FOXI object
local FOXI = {
    roles = {
        {
            title = "Negotiating Open Contracts",
            shortDescription =
            "FOXI acts as the galaxy's smoothest negotiator, securing win-win deals between free traders and factions.",
            longTooltip =
            "FOXI's negotiation prowess isn't just about sealing the deal—it's about optimizing resource exchanges and profit margins, ensuring both sides benefit from the agreements. Its advanced algorithms analyze market trends and factional needs to craft contracts that promote economic growth and stability across the galaxy."
        },
        {
            title = "Establishing Resource Exports to Sol Fed",
            shortDescription =
            "FOXI transforms rival resources into Sol Fed's economic fuel, navigating complex supply chains with precision.",
            longTooltip =
            "By identifying lucrative export opportunities from rival factions, FOXI strategically channels valuable resources to Sol Fed. Its meticulous planning and coordination with free traders ensure a steady flow of goods, bolstering Sol Fed's economic prosperity and influence in the galaxy."
        },
        {
            title = "Establishing Resource Exports to Commonwealth",
            shortDescription =
            "FOXI brokers resource trades that bridge factional divides, enriching both sides in a galaxy of shifting alliances.",
            longTooltip =
            "Facilitating resource exports to Commonwealths, FOXI fosters cooperation and stability among factions. Its strategic agreements not only optimize resource utilization but also nurture inter-factional relationships, fostering a collaborative environment that benefits all parties involved."
        },
        {
            title = "Disrupting Competitors of Commonwealth",
            shortDescription =
            "FOXI outsmarts rivals with cunning tactics, weakening threats to Commonwealth interests across the stars.",
            longTooltip =
            "FOXI's intelligence operations are at the forefront of disrupting competitors of Commonwealths. Through careful analysis and covert actions, it exposes vulnerabilities in rival factions' strategies, employing measures from economic sanctions to strategic alliances with counteracting factions, all aimed at safeguarding Commonwealths' economic and political standing."
        },
        {
            title = "Disrupting Competitors of Sol Fed",
            shortDescription =
            "FOXI defends Sol Fed's economic dominance with calculated precision, thwarting rivals in the cosmic game of power.",
            longTooltip =
            "Safeguarding Sol Fed's economic supremacy, FOXI employs a range of disruptive strategies. From intercepting critical supply routes to destabilizing rival markets, FOXI's actions are designed to maintain and strengthen Sol Fed's position as a leading economic force in the galaxy. Its meticulous analysis and swift responses ensure that threats to Sol Fed's interests are effectively neutralized."
        },
        {
            title = "Establishing a Syon Free Traders Pub",
            shortDescription =
            "FOXI pioneers the establishment of a Syon Free Traders pub in an uncharted or disrupted system, fostering a hub for commerce and camaraderie.",
            longTooltip =
            "In an effort to expand the network of Syon Free Traders, FOXI undertakes the bold initiative of establishing a pub in a remote, uninhabited, or recently disrupted system. The pub serves not only as a gathering place for traders but also as a nexus for exchanging information, negotiating deals, and fostering community among independent operators. FOXI oversees the logistical challenges of infrastructure development, security arrangements, and cultural integration, ensuring that the pub becomes a beacon of opportunity and solidarity in the vast expanse of the galaxy."
        }

    },
    galactic_news = {
        "FOXI Co. unveils new Syontrix model, promising enhanced versatility and performance.",--fisrt month / year
        "Conflict escalates in Syon 570 as tensions rise between SolFed, Commonwealths, and FOXI Free Traders.", -- second year
        "Syon 570's gas giant refueling stations report record profits, boosting local economy.", -- third year
        "FOXI Co. agent computer plugin now available, revolutionizing in-flight operations across the galaxy.", -- fourth year
        "Rumors swirl of a clandestine operation by FOXI Co. disrupting key SolFed supply routes.", --so on
        "New Syontric_gvnr_none variant spotted in combat trials, sparking debates over its tactical advantages."
    },

      galactic_news_flavor = {
          --todo nearest vessel and nearest body dynamics
          "Nearest vessel is travelling at approximately %0.1f m/s.", -- nearest vessal
          "Closest ship distance: %0.2f km. Relative acceleration nominal.", -- nearest vessal
          "Primary star radiation levels remain within safe operational thresholds.",
          "Nearest planetary body: %s at %0.2f AU. Estimated transfer time: %0.1f hours.", -- nearest body
          "Local traffic density increasing. Maintain safe navigation vectors.",
          "Fuel reserves stable. Estimated jump capacity unchanged.",
          "Thermal signature of nearby vessels suggests standard civilian activity.",
          "Gravitational variance minimal. Autopilot efficiency optimal.",
          "No anomalous signals detected in current sensor sweep.",
          "Long-range scanners report low activity beyond primary orbit."
      },

      pioneer_tips = {
          "Fuel scoops save credits near gas giants.",
          "Watch heat levels during atmospheric entry.",
          "Autopilot isn't magic—stay alert.",
          "Docking clearance avoids expensive fines.",
          "Mass affects jump range more than you think.",
          "Upgrade drives before venturing far.",
          "Pirates love slow cargo haulers.",
          "Keep spare fuel for emergencies.",
          "Gravity wells can ruin trajectories quickly.",
          "Check mission deadlines before accepting.",
          "Illegal cargo attracts unwanted attention.",
          "Sensors lie when damaged—repair often.",
          "High thrust drains fuel faster.",
          "Plan jumps around refueling points.",
          "Hostile ships prefer isolated targets.",
          "Cargo space is profit potential.",
          "Military drives require specialized fuel.",
          "Avoid overheating during combat maneuvers.",
          "Orbit speed matters for safe docking.",
          "Insurance won't cover reckless flying.",
          "Upgrade scanners for better situational awareness.",
          "Stations pay well for rare commodities.",
          "Keep distance from police patrols if suspicious.",
          "Manual docking improves pilot skill."
    },

    save_data = {
        init = false,
        dogtags = 0,
        joined = false,
        rewards_given = {},
        kill_log = {},
        dogtags = 0
    },
}
local myid = 1;

-- Function to dump an object in a readable way
local function dumpObject(obj, indent)
    indent = indent or 0  -- Set default indentation level

    local spacing = string.rep("  ", indent)  -- Create indentation string

    if type(obj) == "table" then
        print(spacing .. "{")  -- Start table output

        for k, v in pairs(obj) do
            -- Print key with indentation
            if type(k) == "string" then
                print(spacing .. "  [" .. k .. "] = ")
            else
                print(spacing .. "  [" .. tostring(k) .. "] = ")
            end

            -- Recursively call dumpObject for nested tables
            dumpObject(v, indent + 1)
        end

        print(spacing .. "}")  -- End table output
    elseif type(obj) == "userdata" then
        print(spacing .. tostring(obj) .. " (userdata)")
    else
        print(spacing .. tostring(obj))  -- Print other types directly
    end
end

-- Example usage

local function dumpFOXI()
   dumpObject(FOXI.save_data, 2);
end


-- calsed on start? early?
local function update_display_ads()
    if FOXI.save_data.joined then

            print("Joined since "..tostring(FOXI.save_data.joined))

        --- if the player is doced at a solfed syon
    end
end

-------------------------------------------------------------------------------
-- Pioneer mod system save load data system
-------------------------------------------------------------------------------
--Event.Register("onGameStart", onGameStart)
-- we need to init memory (lets design this not to save stuff for now )
local function onGameStart()
    -- when the game starts for the first time ask the user to join
    local ship = Game.player

    local function okFineThen()
        msgbox.OK("No worries we are all free peoples. If you wish to join later find us at Syon 570.")
    end
    local function joinCallback()
        if FOXI.save_data.joined then
            msgbox.OK("You are already a member. Good luck!")
        else
            FOXI.save_data.joined = Game.time
        end
    end
    local function cancelCallback()
        FOXI.save_data.joined = 1 -- this is a fun way to test custom join id.
        uitimers.createTimer("JOINED", 1, okFineThen)
--         Timer:CallAt(Game.time + 1, okFineThen)
    end



    --FOXI.save_data.rewards_given = {};
    --FOXI.save_data.joined = 0;
    if FOXI.save_data.init == false then
        msgbox.YES_NO("Welcome to pioneer. Would you like to join the Syon Free Traders & Co?",
            {yes=joinCallback, no=cancelCallback})
    end
    --if FOXI.save_data.init == false then
    --    msgbox.OK("No worries we are all free peoples. If you wish to join later find us at Syon 570.")
    --end
    print("Player game started: joined since "..tostring(FOXI.save_data.joined))
    update_display_ads(player)

    FOXI.save_data.init = true;


    -- we know that we have valid foxi save data now.

end
--Event.Register("onGameEnd", onGameEnd)
local function onGameEnd()
    -- here we reset / clenaup data on game end .. duh ;)
    FOXI.save_data = {
        init = false
    }
end

local serialize = function()
    print("foxico::serialize")
    dumpFOXI()
    return FOXI.save_data
end

local unserialize = function(data)
    FOXI.save_data = data
    print("foxico::unserialize")
    dumpFOXI()
end


-------------------------------------------------------------------------------
-- Event hooks for the game
-------------------------------------------------------------------------------

--Event.Register("onEnterSystem", onEnterSystem)
-- reload the missions available
local current_system = nil
local prev_system = nil
local third_system = nil
local jumptimes = {}

local function onEnterSystem(ship)

    if not ship:IsPlayer() then return end

    local system = Game.system

    -- shift history (always safe)
    third_system = prev_system
    prev_system = current_system
    current_system = system

    -- track jump time
    table.insert(jumptimes, Game.time)

    print("Foxi Jump count: " .. #jumptimes)

    print("System: " .. system.name)
    print("Population: " .. tostring(system.population))
    print("Lawlessness: " .. tostring(system.lawlessness))
    dumpVerbose(system, 2)
end
--Event.Register("onShipDestroyed", onShipDestroyed)
-- if active mission award player.
--				LuaEvent::Queue("onShipDestroyed", this, attacker);

function GetShipIdentity(ship)

    if not ship then
        return "<no ship>"
    end

    local varType = GetGenericType(ship)
    local shipType = "<unknown>"
    local label = "<no label>"
    local shipName = "<no name>"
    local shipClass = "<unknown>"

    -- Ship type
    pcall(function()
        shipType = ship:GetShipType()
    end)

    -- Label
    pcall(function()
        label = ship:GetLabel()
    end)


    -- Class if available
    pcall(function()
        shipClass = ship:GetShipClass()
    end)

    return string.format(
        "[%s]%s::%s::%s",
        varType,
        shipClass,
        shipType,
        label
    )
end

function SafeIsShip(obj, name)
    if obj == nil then
        print("ERROR: " .. name .. " is nil")
        return false
    end

    if type(obj) ~= "userdata" then
        print("ERROR: " .. name .. " wrong lua type: " .. type(obj))
        return false
    end

    -- Check that this userdata is a Ship object
    if not obj.isa then
        print("ERROR: " .. name .. " has no isa() method")
        return false
    end

    if not obj:isa("Ship") then
        print("ERROR: " .. name .. " is not a Ship: " .. tostring(obj))
        return false
    end

    return true
end


function SafeIsPlayer(obj, name)
    if not SafeIsShip(obj, name) then
        return false
    end

    if not obj.IsPlayer then
        print("ERROR: " .. name .. " has no IsPlayer() method")
        return false
    end

    return obj:IsPlayer()
end

function GetGenericType(obj)
    if obj == nil then
        return "nil"
    end

    if type(obj) ~= "userdata" then
        return type(obj)
    end

    local mt = getmetatable(obj)

    if mt and mt.type then
        return mt.type   -- e.g. "Ship", "Planet", "Star", "Missile"
    end

    return "unknown_userdata"
end

local function LogKiller(obj)
    FOXI = FOXI or {}
    FOXI.save_data = FOXI.save_data or {}
    FOXI.save_data.killers = FOXI.save_data.killers or {}

    local t = GetGenericType(obj)

    FOXI.save_data.killers[t] = (FOXI.save_data.killers[t] or 0) + 1

    print("Killer type:", t, "count:", FOXI.save_data.killers[t])

    return t
end


local function onShipDestroyed(ship, attacker)

    print(" onShipDestroyed(ship, attacker) =<not not>=> ("..tostring(not not ship)..", "..tostring(not not attacker)..")")


    local killedIsPlayer = false
    local attackerExists = false
    local attackerIsPlayer = false

    if SafeIsShip(ship, "killed ship") then
        killedIsPlayer = SafeIsPlayer(ship, "killed ship")
    end


    if SafeIsShip(attacker, "attacker") then
        attackerExists = true
        attackerIsPlayer = SafeIsPlayer(attacker, "attacker")
    elseif attacker ~= nil then
        print("ERROR: attacker exists but is not a Ship:", tostring(attacker))
        print("GetGenericType: "..GetGenericType(attacker))
    end

    print("killedIsPlayer =", killedIsPlayer)
    print("attackerExists =", attackerExists)
    print("attackerIsPlayer =", attackerIsPlayer)

    -- CASE 1: Player died
    if killedIsPlayer then
        print("PLAYER SHIP DESTROYED")
        -- trigger custom endgame here
        --return


    -- CASE 2: Player killed someone
    elseif attackerIsPlayer then
        print("PLAYER GOT THE KILL")
        if not FOXI.save_data.dogtags then FOXI.save_data.dogtags = 0 end
        FOXI.save_data.dogtags = FOXI.save_data.dogtags + 1;
        -- give credit here
        -- dogtags*1000 is given to clean pilots
        -- dogtags<enemy faction>*10000 can be used to pay off fines
        --
        --return

    -- CASE 3: NPC killed NPC
    elseif attackerExists then
        print("NPC vs NPC combat")
--         dumpVerbose(attacker, 2)
        LogKiller(attacker)
        --return
    else
        print("SHIP DESTROYED WITH NO ATTACKER")
    end

    local killed = GetShipIdentity(ship)
    local killer = GetShipIdentity(attacker)

    local killerType = type(attacker)

    print("Killer [",killerType,"]", killer, " killed ", killed)


--     -- Game time + system (adapt depending on your API)
    local gameTime = Game and Game.time or os.time()
    local systemName = (Game and Game.system and Game.system.name) or "unknown_system"
--
    local entry = string.format("%s,%s,%s,%s",
        tostring(gameTime),
        tostring(systemName),
        killed,
        killer
    )
    FOXI.save_data.kill_log = FOXI.save_data.kill_log or {} -- ensure table is therw
    table.insert(FOXI.save_data.kill_log, entry)
    print("Kill logged:", entry)


    --For each ship killed in enemy territory the faction will pay 1000cr
    --
    --If you are detected by the law then we cannot be associated with you have a nice life
    --
    --To receive your payment visit world controlled by contracting faction.
    --
    --You may return to Syon 570 for a new identity.
    --
    --CW -> SF
    --SF -> CW

    -- mechanic. ships will simply build up .. therefore if you manage to pay off your fine then all is good.
    -- good luck with that ;)

    --sub mechanic clandestin missions count at 10x towards fine payoffs therefore if you ow 1000000cr you can kill 1000 enemy ships to pay it


    -- todo check if the ship is police
end
--Event.Register("onLeaveSystem", onLeaveSystem)
-- calculate total and add it to data.
local function onLeaveSystem(ship)
    if not ship.IsPlayer() then return end -- dont care about non player movements

    -- add rewards to memory for when arrives at payable location.
end

local function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end


local function logPlayerInfo(player)
    --local player = Game.player
    if player then
        print("Player Label: " .. player:GetLabel())  -- Get the player's ship label/name
        print("Player Type: " .. player.shipId)  -- Assuming shipId holds ship type
	    local remainingFuel = player:GetRemainingDeltaV()

        -- Position and velocity relative to the system
        local pos = player:GetPosition()
        local vel = player:GetVelocity()
        print(string.format("Position: x=%.2f, y=%.2f, z=%.2f", pos.x, pos.y, pos.z))
        print(string.format("Velocity: x=%.2f, y=%.2f, z=%.2f", vel.x, vel.y, vel.z))

        -- Fuel level, shields, etc. (if applicable)
        print("Fuel Mass: " .. remainingFuel)
        --print("Shield Strength: " .. player.shieldStrength)

        -- Log the current time
        --print("Game Time: " .. Game.time)
    else
        print("Player object not available.")
    end
end



local function uiopen()
    local ship = Game.player

    print("foxico::uiopen.logPlayerInfo()")
    logPlayerInfo(ship);

    -- ok idk what to do here but if needed lets put them in the same place
    -- this is called when the tab is switched back to flight view and the ui is opened
    -- OR when the user click the button to open the ui.  aka when first fram is done rendering?
end





-------------------------------------------------------------------------------
--FOXI GALACTIC NEWS (no we did not invent ftl coms) its static news updated when you got to the stations .. aka never updated .. todo
-------------------------------------------------------------------------------
local newsIndex = 1
local totalNews = 1 -- how many are unlocked


-- Array of FOXI.GalacticNews
-- Function to pick a random news item and display it
local function displayRandomNews()

    if not FOXI.save_data.joined then
        msgbox.OK("You must be a member to get news. Join from Syon 570.")
        return
    end

    local joinTime = FOXI.save_data.joined
    local elapsed = Game.time - joinTime

    local secondsInMonth = 30 * 24 * 60 * 60
    local secondsInYear = 365 * 24 * 60 * 60

    local monthsPassed = math.floor(elapsed / secondsInMonth)
    local yearsPassed = math.floor(elapsed / secondsInYear)

    -- unlock more news each year
    local newsLength = #FOXI.galactic_news -- total available news
    totalNews = math.min(1 + yearsPassed, newsLength)


    -- cycle through unlocked news monthly
    newsIndex = (monthsPassed % totalNews) + 1

    local selectedNews = FOXI.galactic_news[newsIndex]


    -- Use Game.time (in years), convert to seconds-ish scale
    local seed = math.floor(Game.time * 100000)

    local tipIndex = (seed % #FOXI.pioneer_tips) + 1
    local flvIndex = (seed % #FOXI.galactic_news_flavor) + 1

    local msg = selectedNews .. "\n" .. FOXI.galactic_news_flavor[flvIndex] .. "\n" .. FOXI.pioneer_tips[tipIndex]
    msgbox.OK(msg)

end


local function check_syon_ship()
    local isFoxiShip = string.sub(Game.player.shipId, 1, 4) == "syon"
    return isFoxiShip
end

-------------------------------------------------------------------------------
-- FOXI MISSIONS LOGIC
-------------------------------------------------------------------------------
local SY = "Syon Free Traders & Company"
local CW = "Commonwealth of Independent Worlds"
local SF = "Solar Federation"

-- a utility to check if you are in the system of this faction
local function in_system_of(faction_name)
    return Game.system.faction.name == faction_name
end


local function check_foxi_missions()
    --local system = Game.system
    local inSystemClean =  1 == 1
    -- Player.GetLegalStatus(Game.player, Game.system.faction.name) == 'CLEAN'

    local isGovTypeNone = Game.system.govtype == "NONE"
    --local current_systempath = sectorView:GetCurrentSystemPath()


    -- if user is not syon clean thy are not an agent
    local inSYClean = PlayerState.GetLegalStatus(Game.player, SY) == 'CLEAN'
    if not inSYClean then return nil end


    -- if user is fugitive in an faction contract earnings will go towards their pardoning at 10x rate ;)
    -- if user is fugitive in clandestin tagert then they are not elagable for operations as faction canot be assoseated with fugitives.



    local inSFClean = PlayerState.GetLegalStatus(Game.player, SF) == 'CLEAN'
    local inCWClean = PlayerState.GetLegalStatus(Game.player, CW) == 'CLEAN'

    local missions = {
        {
            contractor = SY,
            name = "Establish Pub",
            --location = "NO_CENTRAL_GOVERNANCE", -- only show if this system has nocental governance
            available = inSYClean and isGovTypeNone
        },
        {
            -- only sho
            contractor = CW,
            name = "Disureupt The Solar Federation",
            available = inSFClean and in_system_of(SF)
        },
        {
            -- only sho
            contractor = SF,
            name = "Disureupt The Commonwealth",
            available = inCWClean and in_system_of(CW)
        }
    }

    return missions
end

-- a helper function to chek the game time and if the player is doket at stations
local function check_date_and_docked(time, faction, teclevel)
    local isTimePassed = Game.time > time
    if not isTimePassed then return false end

    local isInFaction = Game.system.faction.name == faction
    if not isInFaction then return false end

    local isDocked = Game.player.flightState == "DOCKED"
    if not isDocked then return false end

    local target = Game.player:GetDockedWith()
    if target == nil then return false end

    --local idDockedWithStation = target.type == "STARPORT_SURFACE" or target.type == "STARPORT_ORBITAL"
    --local target
    local starport = target.superType == "STARPORT"
    local surface = target.type == "STARPORT_SURFACE"


    local techLevel = starport and SpaceStation.GetTechLevel(target) or false

    if starport and techLevel and techLevel > teclevel then
        return teclevel;
        --techLevel = luc.MILITARY
    end
    --local isDockedHighTec = target.
end


local function draw_display_ads()


end

------------------------------------------------------------
-- SOME OLD CARGO DRAW STUF AND SIDBAR STUFF TODO CLEAN UP
------------------------------------------------------------


local function draw_cargo_bar(pos, size, pct, color, tooltip)
    local section = Vector2(size.x * pct, size.y)
    ui.addRectFilled(pos, pos + size, colors.lightBlackBackground, 0, 0)
    ui.addRectFilled(pos, pos + section, color, 0, 0)

    if ui.isWindowHovered() and ui.isMouseHoveringRect(pos, pos + size) then
        ui.setTooltip(tooltip)
    end
end

local function draw_cargo_bar_section(pos, size, pct, color, tooltip)
    local section = Vector2(size.x * pct, size.y)
    ui.addRectFilled(pos, pos + section, color, 0, 0)

    if ui.isWindowHovered() and ui.isMouseHoveringRect(pos, pos + section) then
        ui.setTooltip(tooltip)
    end
end

local function transfer_button(icon, tooltip, enabled)
    local size = Vector2(ui.getTextLineHeight())
    if enabled then
        return ui.iconButton(icon, size, tooltip, nil, nil, 0)
    else
        ui.iconButton(icon, size, tooltip, buttonColors.disabled, colors.grey)
    end
end

local function transfer_buttons(amount, min, max, tooltip_reduce, tooltip_increase)
    if transfer_button(icons.time_backward_1x, tooltip_reduce, amount > min) then
        amount = amount - 1
    end
    ui.sameLine(0, 2)
    if transfer_button(icons.time_forward_1x, tooltip_increase, amount < max) then
        amount = amount + 1
    end

    return amount
end

local module = {
    side = "right",
    icon = icons.medium_freighter,
    tooltip = "Foxi Co Agent",
    ---lui.TOGGLE_CARGO_WINDOW,
    exclusive = false,
    debugReload = function() package.reimport() end,

    ship = nil,
    transfer = {},
    transferModes = {},
    foxyData = {},
}

-- lua function to insert in a object https://www.lua.org/manual/5.4/manual.html#pdf-table.insert
table.insert(module.transferModes, {
    id = "Jettison",
    label = lui.JETTISON,
    color = style.jettisonColor,
    icon = icons.cargo_crate_illegal,
    tooltip = lui.JETTISON_MODE,
    action = function(ship, manifest)
        for k, v in pairs(manifest) do
            local commodity = Commodities[k]
            for i = 1, v do
                ship:Jettison(commodity)
            end
        end
    end,
    canDisplay = function(ship)
        return ship.flightState == "FLYING"
    end
})


function module:startTransfer(mode)
    self.transfer = {}
    self.transferMode = mode
end

function module:resetTransfer()
    self.transfer = {}
    self.transferMode = nil
end

function module:countTransfer()
    local amount = 0
    for k, v in pairs(self.transfer) do
        amount = amount + v
    end

    return amount
end

function module:drawModeButtons()
    local modi = {}

    for _, v in ipairs(self.transferModes) do
        if not v.canDisplay(self.ship) then
            if self.transferMode == v then
                self:resetTransfer()
            end
        else
            table.insert(modi, v)
        end
    end

    local spacing = ui.getItemSpacing().x
    local width = (ui.getButtonHeight() + spacing) * #modi - spacing

    ui.addCursorPos(Vector2(ui.getContentRegion().x - width, 0))

    for _, v in ipairs(modi) do
        local isActive = self.transferMode == v
        if ui.inlineIconButton(v.icon, v.tooltip, isActive) then
            if isActive then
                self:resetTransfer()
            else
                self:startTransfer(v)
            end
        end

        ui.sameLine()
    end

    ui.newLine()
end

------------------------------
-- DRAW THE SIDBAR UI
------------------------------


--DRAWING FUNCTION FIRST
function module:drawTitle()
    local cargoMgr = self.ship:GetComponent("CargoManager")

    -- 	ui.text(self.ship.id)
    --     local ship = cargoMgr.ship;


    ui.textAligned("Foxi Co Galactic Network", 0.5)

    local fg = colors.hyperspaceInfo
    local bg = colors.lightBlackBackground


    local pos = ui.getCursorScreenPos() + Vector2(0,
        (ui.getLineHeight() - ui.getTextLineHeight()) / 2)


    ui.textAlignedColored("Mission BLUFF: Establish Personal Goals.", 0.1, fg)

    local size = Vector2(
        ui.getContentRegion().x - ui.getItemSpacing().x,
        ui.getTextLineHeight())

    local usedSpace = cargoMgr:GetUsedSpace()
    local totalSpace = cargoMgr:GetTotalSpace()
end

--DEBUG FUNCTIONS FOR FUMPING
--DEBUG FUNCTIONS FOR FUMPING
--DEBUG FUNCTIONS FOR FUMPING
 function dumpTableVerbose(tbl, depth, seen)
        depth = depth or 0
        seen = seen or {}

        if depth > 5 then
            print(string.rep("  ", depth) .. "<max depth>")
            return
        end

        if seen[tbl] then
            print(string.rep("  ", depth) .. "<already seen>")
            return
        end

        seen[tbl] = true

        for k, v in pairs(tbl) do
            local prefix = string.rep("  ", depth) .. tostring(k) .. " = "

            if type(v) == "table" then
                print(prefix .. "{")
                dumpTableVerbose(v, depth + 1, seen)
                print(string.rep("  ", depth) .. "}")
            else
                print(prefix .. tostring(v) .. " (" .. type(v) .. ")")
            end
        end
    end


-- DEBUG FUNCTION: ROBUST ARBITRARY OBJECT DUMP
function dumpVerbose(obj, depth, seen, maxDepth)
    depth = depth or 0
    seen = seen or {}
    maxDepth = maxDepth or 5

    local indent = string.rep("  ", depth)

    -- Safety: identify type first
    local objType = type(obj)

    -- Maximum recursion depth
    if depth > maxDepth then
        print(indent .. "<max depth reached>")
        return
    end

    -- Nil
    if obj == nil then
        print(indent .. "nil")
        return
    end

    -- Primitive values
    if objType ~= "table" and objType ~= "userdata" then
        print(indent .. tostring(obj) .. " (" .. objType .. ")")
        return
    end

    -- Already visited check (handles circular references)
    if seen[obj] then
        print(indent .. "<already seen> " .. tostring(obj))
        return
    end

    seen[obj] = true

    -- Tables can be iterated
    if objType == "table" then
        print(indent .. "TABLE " .. tostring(obj) .. " {")

        for k, v in pairs(obj) do
            print(indent .. "  [" .. tostring(k) .. "] =")
            dumpVerbose(v, depth + 1, seen, maxDepth)
        end

        print(indent .. "}")

    -- Userdata cannot be pairs()'d
    elseif objType == "userdata" then
        print(indent .. "USERDATA " .. tostring(obj))

        -- Try metatable inspection
        local ok, meta = pcall(getmetatable, obj)

        if ok and meta then
            print(indent .. "  metatable:")
            dumpVerbose(meta, depth + 1, seen, maxDepth)
        else
            print(indent .. "  <no accessible metatable>")
        end
    end
end


    local function dumpEquipmentSummary(equip)
        if not equip then
            print("No equipment")
            return
        end

        print("========== EQUIPMENT SUMMARY ==========")

        -- Identity
        print("Name:        " .. tostring(equip:GetName()))
        print("ID:          " .. tostring(equip.id))
        print("Class:       " .. tostring(equip.meta and equip.meta.class))
        print("Tech Level:  " .. tostring(equip.tech_level))
        print("Price:       " .. tostring(equip.price))

        -- Physical
        print("")
        print("--- Physical ---")
        print("Mass:        " .. tostring(equip.mass))
        print("Volume:      " .. tostring(equip.volume))

        -- Slot
        print("")
        print("--- Slot ---")
        if equip.slot then
            print("Type:        " .. tostring(equip.slot.type))
            print("Size:        " .. tostring(equip.slot.size))
            print("Hardpoint:   " .. tostring(equip.slot.hardpoint))
        else
            print("No slot requirement")
        end

        -- Capabilities
        print("")
        print("--- Capabilities ---")
        if equip.capabilities then
            for k,v in pairs(equip.capabilities) do
                print(k .. ": " .. tostring(v))
            end
        else
            print("None")
        end

        -- Fuel
        print("")
        print("--- Fuel ---")
        if equip.fuel then
            print("Fuel ID:     " .. tostring(equip.fuel.name))
            print("Fuel price:  " .. tostring(equip.fuel.price))
        else
            print("None")
        end

        -- Hyperdrive specific
        if equip.fuel_resv_size then
            print("")
            print("--- Hyperdrive ---")
            print("Class:       " .. tostring(equip.capabilities.hyperclass))
            print("Efficiency:  " .. tostring(equip.factor_eff))
            print("Fuel reserve:" .. tostring(equip.fuel_resv_size))
        end

        -- Provided slots
        print("")
        print("--- Provided Slots ---")
        if equip.provides_slots then
            for id,slot in pairs(equip.provides_slots) do
                print(
                    tostring(id) ..
                    ": " ..
                    tostring(slot.type) ..
                    " size=" ..
                    tostring(slot.size)
                )
            end
        else
            print("None")
        end
    end
--BACK TO UI CODE
--BACK TO UI CODE
--BACK TO UI CODE

local bodyFrame = 0;
local lastFrameTime = 0;  -- stores the initial game time
local frameCount = 1000

function module:drawBody()
    bodyFrame=bodyFrame+1

    local g = Game;

    local isMember = not not (FOXI.save_data.joined)


    if bodyFrame % frameCount == 0 then

        local currentTime = Game.time
        local deltaTime = currentTime - lastFrameTime

        -- log the stats
        print("foxico.lua.frame: " .. tostring(bodyFrame))

        print("Delta time for the last " .. frameCount .. " frames: " .. deltaTime .. " game seconds")

        -- reset the time for the next 500 frames
        lastFrameTime = currentTime
    end

    local cargoMgr = self.ship:GetComponent("CargoManager")

    ui.spacing(4)
    ui.separator()
    ui.spacing(2)
    local fg = colors.hyperspaceInfo
    local bg = colors.lightBlackBackground
    local warn = colors.navTarget
    local danger = colors.combatTarget


    -- use has not recieved there free gift
    -- if user does not join offer 2 missile to join. after one month
    -- if user has joined then after 5 months offer them a free syoncannon.
    -- after one year infrom them thay are elagable to receave a syontrix ship for 84% off
    --
    --If you'd like to approximate the number of months since a Unix timestamp using a simple mathematical approach (assuming each month has a fixed number of seconds), you can divide the difference in seconds between the current time and the Unix timestamp by the average number of seconds in a month. Here’s how you can do it in Lua:

    --lua

    function time_diff_in_months(start_time, current_time)
        if not start_time then return 0 end -- not checks false and nil and 0?


        local secondsDifference = current_time - start_time      -- Calculate difference in seconds
        -- Approximate seconds per month
        local secondsPerMonth = 30.44 * 24 * 60 * 60             -- Average days per month

        local monthsPassed = secondsDifference / secondsPerMonth -- Calculate months passed
        return monthsPassed
    end

    local monthsJoinedFloat = time_diff_in_months(FOXI.save_data.joined, Game.time)

    local monthsJoined = math.floor(monthsJoinedFloat)




    if FOXI.save_data.joined then
        ui.textAlignedColored("Active member for " .. tostring(monthsJoinedFloat) .. " months!", 0.1, fg)
        ui.textAlignedColored("Member Id: " .. tostring(FOXI.save_data.joined), 0.1, fg)
        ui.sameLine()
        if ui.button("Leave now") then
            FOXI.save_data.joined = false
        end

    else
        ui.textAlignedColored("Member status: " .. tostring(FOXI.save_data.joined), 0.1, fg)
    end

    ui.textAlignedColored("IsMember: " .. tostring(isMember), 0.2, bg)


    ui.textAlignedColored("* WARNING *: This mod / rewards are not finished", 0.2, warn)

-- i think it just depends on Game and Equipment.
   local function giveMissles(num)

	    local equipSet = Game.player:GetComponent('EquipSet')
        local missile = Equipment.Get("missile.guided_s2")
        --todo: give unguided rocket or whatever missiles is supported by the ship
        print("Attempting to dump Missile " )

        dumpTableVerbose(missile)

        print("Attempting to give player " .. num .. missile:GetName())
        local s = equipSet:GetFreeSlotForEquip(missile)
        for i=1,num do
            local m = missile:Instance()
            local s = equipSet:GetFreeSlotForEquip(missile)
            if s ~= nil then
                r = equipSet:Install(m,s)
                print("Missile Installed = " .. tostring(r))
            else
                print("todo give farm machinery")
            end
        end

        return numAdded
    end

    local function giveHyperdrive(level, mil)

        if not level then level = 1 end
        if mil == nil then mil = false end

      local drive = Game.player:GetInstalledHyperdrive()

        if drive then
            print("Player has hyperspace drive already.")
            print("Name: " .. drive:GetName())
            print("ID: " .. tostring(drive.id))

            dumpTableVerbose(drive)
            dumpEquipmentSummary(drive)


        else
            print("No hyperdrive installed")
        end


        local equipSet = Game.player:GetComponent('EquipSet')

        -- build correct equipment ID
        local id = "hyperspace.hyperdrive"

        if mil then
            id = id .. "_mil" .. tostring(level)
        else
            id = id .. "_" .. tostring(level)
        end


        local hyperdrive = Equipment.Get(id)

        if not hyperdrive then
            print("Invalid hyperdrive: " .. id)
            return false
        end


        print("Attempting to give player " .. hyperdrive:GetName())

        local slot = equipSet:GetFreeSlotForEquip(hyperdrive)

        if slot then
            local instance = hyperdrive:Instance()
            local result = equipSet:Install(instance, slot)
            print("Hyperdrive Installed = " .. tostring(result))
            return result
        elseif level > 0 then
            level = level-1
            print("Hyperdrive slot not available trying Level-- = " .. level)
            giveHyperdrive(level, mil)
        else
            print("No slot available for hyperdrive")
            return false
        end
    end


    local function giveLaser(name)

        if name == nil then
            name = "syoncannon_5mw"
        end

        local equipSet = Game.player:GetComponent('EquipSet')

        local laser = Equipment.Get("laser." .. name)

        if not laser then
            print("Invalid laser: laser." .. name)
            return false
        end

        print("Attempting to give player a " .. laser:GetName())

        local instance = laser:Instance()

        local slot = equipSet:GetFreeSlotForEquip(instance)

        if slot then
            local result = equipSet:Install(instance, slot)
            print("Laser Installed = " .. tostring(result))
            return result
        else
            print("Unable to find compatible slot for laser")
            return false
        end
    end


    local rewardMap = {
        join = { -- give 4 missiles at the start of the game (or if you leave and join resting your long term timer)
            ad = "Offer: Join Syon Free Traders & Company to get 4 free farm equipment.",
            btn = "Share Join Offer",
            more =
                "Psst.. I see your not a member yet, we have 2 smart missiles. cough.. cough... I mean farm machinery laying"
                .. " around. They are yours if you join today.",
            ok = function()
                FOXI.save_data.joined = Game.time
                giveMissles(4);
                return nil -- signifies no error
            end,
            cancel = "All good its a free system. Good luck out there!",
            thanks = "Cool We have loaded the equipment. Good luck out there."
        },
        repeat1 = { -- receive 2 smart missile each month for being a member (can save your ass in combat)
            ad = "Offer: Valued member surplus offer receive 2 free farm machinery.",
            btn = "Share Member Offer",
            more =
                "Psst.. Hi borther, we have 2 smart missiles. cough.. cough... I mean farm machinery laying"
                .. "around. Do you want them?",
            ok = function()
                giveMissles(2);
                return nil; -- in the backed we save that this has been recieved for this month
            end,
            cancel = "All good its a free system. Good luck out there!",
            thanks = "Cool We have loaded the equipment. Good luck out there."
            --repeatProgram = true,
        }, -- thanks your first month of service here are 2 free smart_missles
        month6 = { -- during your 6th month give a cool gun
            ad = "Offer: Valued member surplus offer receive 1 free mining laser.",
            btn = "First Month Bonus",
            more =
                "Hi brother, we have a extra modified mining laser in the shop. Its a great peace of tech,"
                .. " with 2x capacitor bank doubling the fire we also tweaked some other parts making it 1 ton lighter!"
                .. ". Do you want it?",
            ok = function()
                --FOXI.save_data.joined = Game.time
                giveLaser("syoncannon_5mw");

                return nil; -- in the backed we save that this has been recieved for this month
            end,
            cancel = "All good its a free system. Good luck out there!",
            thanks = "Cool We have loaded the equipment. Good luck out there."
        }, -- 6 months reciev a free syoncanon TODO: finish the reward balance and acounting
        month12 = {
            ad =
            "Congratulation on one year of membership: Come to syon570 and get a syontrix ship at 84% off! Trade in offer available!",
            btn = "One Year Agent",
            requireFaction = SY,
            notHere = "Im sorry this offer is only available at " .. SY .. " starports. Sector 4, 2, 5",
            -- the idea is that if they do nto meet this requirement the above msg is send otherwise normal rewards operation (anywhere in space)
            more =
                "Sup.. Hi brother, we have a extra modified mining laser in the shop. Its a great peace of tech ..."
                .." with 2x capacitor bank doubling the mining efficacy we also tweaked some other parts making it 1 ton lighter!"
                ..". Do you want it?",
            ok = function()
                --FOXI.save_data.joined = Game.time
                giveLaser("syoncannon_11mw");

                return nil; -- in the backed we save that this has been recieved for this month
            end,
            cancel = "All good its a free system. Good luck out there!",
            thanks = "Cool we have loaded the equipment. Good luck out there."
        }, -- 1 year come to syon570 and get a syontrix ship at 84% off (bring 20,000cr  no money back on swap.)
        repeat12 = {
            ad = "yearly Bonus: Thank you for a full years service. Pick up you bonus at any SFT&C System.",
            btn = "Claim Yearly Bonus",
            requireFaction = SY,
            notHere = "Visit any " ..
                SY ..
                " starports to claim your payable on all contract earnings! Our homeworld is located in sector 4, 2, 5",
            more = {
                "Epic achievements. 1 year of service = 10% bonus,  year 2 = 20%... Thank you for being a loyal member."
            },
            ok = function()
                --FOXI.save_data.joined = Game.time
                giveMissles(2);

                giveHyperdrive(3, false)

                return nil; -- in the backed we save that this has been received for this month
            end,
            cancel = "All good its a free system. Good luck out there!",
            thanks = "Cool We have loaded the equipment. Good luck out there."
        },             --

        --month60 = {},  -- 5 year reward come to syon to get a full load of foxi_missile
        --month120 = {}, -- 10 year reward syontrix gvrn none
        repeat600 = {
            ad = "Offer: Congratulations on 50 years of service! Enjoy a free pub kit on us. Pick up any SFT&C System.",
            btn = "Tell Me More",
            requireFaction = SY,
            notHere = "Woo... Please send me an invite to the opening pick up supplies at any" ..
                SY .. " starports. bring a ship with at least 200ton cargo space! Hint 4, 2, 5",
            more = {
                "Epic achievements. You have stayed alive for 50 years, and not once quit our club. For that occasion we should build a pub.",
                "Once you are ready we can proceed. with loading the 190 tons of cargo you need to get the landing pad and pub build.",
                "This is your last chance when you hit ok the boys will load up as much as they can!. Cancel if your not ready for 190tons yet."
            },
            ok = function()
                --FOXI.save_data.joined = Game.time
                giveLaser("syoncannon_5mw");

                return nil; -- in the backed we save that this has been recieved for this month
            end,
            cancel = "All good its a free system. Good luck out there!",
            thanks = "Cool We have loaded the equipment. Good luck out there."
            --repeatProgram = true,
            --repeatProgram = true
        },              -- 50 year bonus one free pub kit. + 10% bonus on missions compleated. thanks for making thei s a success... each 100 years ()
        month1276 = {}, -- 123 year reward  = an farmin coliny kit

        repeatIntervals = { 1, 12, 600 }
    }


    local logDebugFrame = false;
    -- show the advisement and save the interval to save_data if user accepts rewards.
    local function advertise_reward(key, months, interval)
        -- this is called from draw  when a rewards is triggered.
        --print("Advertise: " .. key)
        if interval == nil then
            interval = 1;
        end



        local r = FOXI.save_data.rewards_given[key]
        local h = FOXI.save_data.rewards_given[key .. "_hist"]
        local numh = 0
        if r and h and #h > 0  then
            numh = #h
            --print("this rewards has been given before:  ".. #h .. " times " .. key .. " has been given, most recent is " .. r )
        end

        local reward = rewardMap[key];

        if reward == nil then return nil end -- will setting a reward to nil make it never again gettable or will it be like new?



       -- print(key .. ".ad = " .. reward.ad)
        ui.textWrapped("["..numh.."]"..reward.ad)

        if ui.button(reward.btn) then       -- here we are
            
            local function formatMessage(msg)
                if type(msg) == "table" then
                    return table.concat(msg, "\n")
                end
                return msg
            end

            msgbox.YES_NO(formatMessage(reward.more), {
                yes = function()
                    local err = reward.ok() -- call the function this is expected to return somthing if there is any problem .
--                     if not err == nil then
                        myid = myid+1
                        uitimers.createTimer("rewardTimerYes"..myid ,Game.time + 2, function()
                            msgbox.OK(reward.thanks)
                        end)

                        --todo key+ "_hist" = [] and push the time of now that it was given.
                        -- Create history table if missing
                        print("Rewards_accepted: ".. key.. "<-key | interval->" .. interval)

                        if FOXI.save_data.rewards_given[key .. "_hist"] == nil then
                            FOXI.save_data.rewards_given[key .. "_hist"] = {}
                        end

                        -- Add current game time
                        table.insert(
                            FOXI.save_data.rewards_given[key .. "_hist"],
                            Game.time
                        )

                        -- Keep the existing interval value
                        FOXI.save_data.rewards_given[key] = months
--                     end
                end,
                no = function() -- cancel
                    myid = myid + 1;
                    uitimers.createTimer("rewardTimerNo"..myid, 2, function()
                        msgbox.OK(reward.cancel)
                    end)
                end
                }
            )
        end
    end


    -- rewards system advertisments
    -- these should only show if the user is docked at station.
    -- maybe they can use the mission interface
    --if not Game.player then return nil end


    if not FOXI.save_data.joined then

       advertise_reward("join", 0)

    else
        --local monthsJoined = math.floor(time_diff_in_months(FOXI.save_data.joined, Game.time))

        local key = "month" .. monthsJoined
        -- todo: fix the fixed reward sce3dule balance.
        local reward = rewardMap[key]; -- there rewards will only be available on the month they are advertised.
        if reward == nil then          -- if no rewards is advertised then check for repeat rewards
            --local reward = rewardMap(key);

            for v, i in pairs(rewardMap.repeatIntervals) do
                local interval = math.floor(monthsJoined / v) -- 0 - 12 = -12 / 12  = -1
                -- 14 - 12 = 2 / 12 = 0
                -- 23 - 12 = 11/ 12 = 0
                -- 30 - 12 = 18 / 12 = 1;
                -- so we realy want to give the reward on interval 0;

                local key = "repeat" .. i

                -- this may be the first instance of the reward being given?.
                FOXI.save_data = FOXI.save_data or {}
                FOXI.save_data.rewards_given = FOXI.save_data.rewards_given or {}

                local lastGiven = FOXI.save_data.rewards_given[key]
                if lastGiven == null then
                    FOXI.save_data.rewards_given[key] = -1
                    lastGiven = -1
                end

                --print("interval: " ..
                --tostring(interval) .. "  isMember: " .. tostring(isMember) .. "  lastGiven: " .. tostring(lastGiven))
                if (interval == 0 or interval > 0 and not lastGiven == nil and lastGiven < interval) then
                    --we can advertirse this resowrd.
                    advertise_reward(key, monthsJoinedFloat, interval)
                end
            end

            -- do nothing
            --   local key = "month" .. math.floor(monthsJoined)
            --
            --    1200 12
            --
            --    let repeat interval =
            --    -- todo ad system for repeat rewards every year or monthg
            -- 1 missale per month
            -- 1 year 0.10+ 0.01* years of service bonus on missions
            -- 5 year - free pub kit
        else -- we have found a reward thats valid for this month in the map. ()
            print("advertise reward" .. key)
            advertise_reward(key, reward, monthsJoined)
        end
    end

    ui.text(self.ship.shipId)

    ui.sameLine()

    -- Check if shipId starts with "syon"
    local isFoxiShip = check_syon_ship()

    if isFoxiShip then
        ui.text(": Member Status Verified")
        ui.separator()
        ui.text("Foxi Co Active Contracts")

        local missions = check_foxi_missions()
        if missions ~= nil then

               -- for each mission draw it
              for _, mission in ipairs(missions) do
                        --ui.text(mission.title)
                        local c
                        if not mission.available
                            then c = fg
                            else c = colors.alertRed
                        end
                        ui.textAlignedColored(mission.name, 0.2, c)
                    end
                    for _, role in ipairs(FOXI.roles) do
                        ui.text(role.title)
            end
        else
            ui.text("You do not have a Foxi Co Ship!")
        end

    end



    local sortTable = {}

    for k, v in pairs(cargoMgr.commodities) do
        table.insert(sortTable, { name = k, comm = Commodities[k], count = v.count })
    end

    table.sort(sortTable, function(a, b)
        return a.count > b.count or (a.count == b.count and a.comm:GetName() < b.comm:GetName())
    end)

    local maxWidth = ui.getContentRegion().x
    local totalSpace = cargoMgr:GetTotalSpace()

    ui.alignTextToButtonPadding()
    ui.text(lui.CARGO_CAPACITY .. ": " .. totalSpace .. "t")
    -- 	ui.sameLine()

    if ui.button("Get News", Vector2(150, 0)) then
        displayRandomNews()
    end

    ui.separator()
    if isFoxiShip then
        ui.text("Foxi Co Agent Computer")
    else
        ui.text("Please enjoy this free info")
    end
    if ui.button("Log Debug GPS", Vector2(150, 0)) then

        local alt, spd, latitude, longitude = g.player:GetGPS()
        print("gps alt: " .. alt)
        print("gps spd: " .. spd)
        print("gps lat: " .. latitude)
        print("gps lon: " .. longitude)

        local pos = g.player:GetPosition()
        print("type pos: "..type(pos))

        dumpVerbose(pos)
    end
    ui.sameLine()
    if ui.button("Log Player", Vector2(150, 0)) then
        dumpVerbose(g.player)
    end

--         ui.text("GPS: ", g.player:GetGPS())
--
end

function module:refresh()
    self.ship = Game.player

    -- this is called when the ui is opened with the button or the user navigates back to the game screen from
    -- the system menu
    uiopen()
end

-----------------------------------------
-- Register Syon Mod Event handlers
-----------------------------------------
-- I still dont really know how tha whole system works but i guess event based programing is good.
-- ps I notices performance hits in some scenarios with lots of this so we want to only use events we absolutely need.
Event.Register("onGameStart", onGameStart)

Event.Register("onEnterSystem", onEnterSystem)

-- track our kills (or take it from player)
Event.Register("onShipDestroyed", onShipDestroyed)

-- track time spent in each system
Event.Register("onLeaveSystem", onLeaveSystem)

--safely save all data (leave system.)
Event.Register("onGameEnd", onGameEnd)

gameView.registerSidebarModule("foxico", module)

Serializer:Register("FoxiSaveData", serialize, unserialize)
