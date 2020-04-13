-- debugging stuffz, don't load a game you care about with these enabled
-- GLOBAL.CHEATS_ENABLED = true
-- GLOBAL.require("debugkeys")

--[[
Much inspiration came from:
    noobler - Relaxed Crafting
    hmaarrfk - Crafting Pause Staging
    hounds - Eternal hatred

    This mod occasionally checks whether to pause or unpause rather than trying to reliably catch all possible triggers for pausing and unpausing.  While that plays better (immediate effect) it results in too many edge cases of wrong pausing or unpausing.
--]]

local require = GLOBAL.require

Assets = {
         Asset("ATLAS", "images/smallpaw.xml"),
         Asset("ATLAS", "images/controlicon.xml"),
         Asset("ATLAS", "images/mouseicon1.xml"),
         Asset("ATLAS", "images/placeicon.xml"),
         }

setting = {
          mousecraft = true,
          controllercraft = true,
          placement = true,

          -- a low value for this (0.1 or so) is close to immediate and should have minimal impact, but using a higher default given our relative unimportance
          update_time = 0.9,

          -- Any reasonble icon size can be used, but roughly matching the inventory slots for a consistent appearance.
          -- TODO  if the size is not set, use the actual size & scale from an actual inventory slot on the HUD.
          icon_width = 45,
          icon_height = 45,
          icon_scale = 0.6
          }

GLOBAL.paws = {
              setting                = setting,
              m_crafting             = false,
              c_crafting             = false,
              placing                = false,
              STRING_TITLE           = "Paws Crafting for...",
              STRING_MOUSE           = "Mouse Bar",
              STRING_CONTROLLER      = "Controller Bar",
              STRING_PLACEMENT       = "Placement",
              STRING_HELP_MOUSE      = "Pause crafting while using the mouse-activated crafting bar.  (left side of the screen)",
              STRING_HELP_CONTROLLER = "Pause crafting while using the keyboard or controller-activated crafting bar.  (horizontal bar on the top)",
              STRING_HELP_PLACEMENT  = "Pause the game while placing an item, whether crafted or items like saplings, grass stalks, pinecones, etc."
              }

local paws = GLOBAL.paws

function paws.Update()
    -- Attempt a general check for 'are we on the main game screen'
    --not GLOBAL.GetWorld().minimap.MiniMap:IsVisible()
    if ( #GLOBAL.TheFrontEnd.screenstack ~= 1 ) then return end

    local m_crafting = paws.setting.mousecraft and paws.m_crafting
    local c_crafting = paws.setting.controllercraft and paws.c_crafting
    local placing = paws.setting.placement and paws.placing
    local player = GLOBAL.GetPlayer()

    if ( GLOBAL.IsPaused() ) then
--print("paws.Update() p: " .. tostring(m_crafting or c_crafting or placing))
        if ( (not m_crafting and not c_crafting and not placing) ) then
            GLOBAL.SetPause(false)
        end
    else
--print("paws.Update() np: " .. tostring(m_crafting or c_crafting or placing) .. " and " .. tostring(not player.components.locomotor.bufferedaction) .. " and " .. tostring(player.components.playercontroller.inst.sg:HasStateTag("idle")))
        if ( (m_crafting or c_crafting or placing) and
             not player.components.locomotor.bufferedaction and
             player.components.playercontroller.inst.sg:HasStateTag("idle") ) then
            GLOBAL.SetPause(true, "Crafting Paws")
else
        end
    end
end

function paws.UpdateSettings()
    paws.bar:CheckSettings()
    paws.Update()
end

require("screen")(env)
require("bar")(env)
require("paws")(env)

-- If desired, uncomment and set to your preferred key
--[[
    TheInput:AddKeyDownHandler(KEY_P,
        function()
            if not paws.Screen.active then
                TheFrontEnd:PushScreen(paws.Screen())
            end
        end)
--]]

--[[
TODO
    - save state to some file, with mod config acting as overriding values
        ? can mod config options be 'unset'
        - when this is working well enough, add a mod config to not use the bar at all
    - option to wait extra time before pausing for each type
    - correct behavior with a controller.
    - add a second dialog for deployables that can be excluded from pausing, e.g. tree seeds, hound traps, etc
    - more polishing of actions that work while paused
    ? translation strings work how?  (if any get submitted)
        - also, borrow existing strings for short messages like buttons etc.
    - configurable keys to open the paws screen and toggle options
        ? copy the way the main control screen assigns keys

FIXME
    - any remaining bugs that unpause during the pause screen, map screen, etc.
    - failure to unpause if the paws screen was opened while crafting is paused
    - does not pause if controller crafting is opened while moving
        - might not be easily fixable, this seems to be a result of the bufferedaction state not getting cleared when the player stops
    - unknown unknowns
--]]

-- vim: ts=4:sw=4:et
