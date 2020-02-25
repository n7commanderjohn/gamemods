-- Most of the Pause/Unpause handling

-- Force updates of placers during mouse movement  (doesn't happen while paused)
local function UpdatePlacer()
    if not IsPaused() then return end

    local pcont = GetPlayer().components.playercontroller
    if not pcont then return end

    if ( pcont.placer ) then
        if ( pcont.placer.components.placer ) then
            pcont.placer.components.placer:OnUpdate(0)
            --pcont:OnUpdate(0)
        end
    end

    if ( pcont.deployplacer ) then
        if ( pcont.deployplacer.components.placer ) then
            pcont.deployplacer.components.placer:OnUpdate(0)
            pcont:OnUpdate(0)  -- FIXME determine if this is needed here
        end
    end

    if ( not pcont.placer and not pcont.deployplacer ) then
        TheInput.position:RemoveHandler(paws.placement_handler)
        paws.placement_handler = nil
    end
end

local function PeriodicUpdate()
    local player = GetPlayer()
    local pcomp = player.components
    local pcont = pcomp.playercontroller

    if ( (pcont.placer and pcont.placer_recipe) or
         (pcont.deployplacer and pcont.deployplacer.components.placer) ) then

        if ( not paws.placement_handler and
             paws.setting.placement ) then
            paws.placement_handler = TheInput:AddMoveHandler(UpdatePlacer)
        end

--local dirty = false
        if ( not paws.placing ) then
--print("pu placing: T") dirty = true
            paws.placing = true
        end
    else
        if ( paws.placing ) then
--print("pu placing: f") dirty = true
            paws.placing = false
        end
    end

    if ( player.HUD.controls.crafttabs.crafting.open ) then
        if ( not paws.m_crafting ) then
--print("pu m_crafting: T") dirty = true
            paws.m_crafting = true
        end
    else
        if ( paws.m_crafting ) then
--print("pu m_crafting: f") dirty = true
            paws.m_crafting = false
        end
    end

    if ( player.HUD.controls.crafttabs.controllercrafting.open ) then
        if ( not paws.c_crafting ) then
--print("pu c_crafting: T") dirty = true
            paws.c_crafting = true
        end
    else 
        if ( paws.c_crafting ) then
--print("pu c_crafting: f") dirty = true
            paws.c_crafting = false
        end
    end

    paws.Update()
--if(dirty) then print("pu mc:"..tostring(paws.m_crafting).." cc:"..tostring(paws.c_crafting).." pl:"..tostring(paws.placing)) end

    if ( IsPaused() ) then
        -- not sure where to best put this
        -- TODO try SetActiveItem, maybe only needed once?
        if ( pcont.deployplacer and pcont.deployplacer.components.placer ) then
            pcont.LMBaction, pcont.RMBaction = pcont.inst.components.playeractionpicker:DoGetMouseActions()
        end
    end
end

------------------------------------------------------------------------------

return function(env)

env.AddSimPostInit(function(player)
    local pcomp = player.components

-- doesn't work while paused, which is kinda necessary for this mod
--    paws.update_task = paws.bar:DoPeriodicTask(paws.setting.update_time, PeriodicUpdate)
    paws.bar.OnUpdate = function(bar, dt)
        bar.update_time = bar.update_time - dt
        if ( bar.update_time < 0 ) then
            PeriodicUpdate()
            bar.update_time = paws.setting.update_time
        end
    end
    paws.bar.update_time = 2 + paws.setting.update_time
    paws.bar:StartUpdating()

    pcomp.builder.inst:ListenForEvent("makerecipe",
        function()
            paws.m_crafting, paws.c_crafting = false, false
            paws.Update()
        end
    )

    local base_SetActiveItem = pcomp.inventory.SetActiveItem
    pcomp.inventory.SetActiveItem =
        function(inv, item)
            base_SetActiveItem(inv, item)
            if ( paws.placement and
                 not (item and item ~= inv.activeitem and item.components.deployable) ) then
                paws.placing = false
                paws.Update()
            end
        end

    local base_CancelPlacement = pcomp.playercontroller.CancelPlacement
    pcomp.playercontroller.CancelPlacement =
        function(pcont)
            base_CancelPlacement(pcont)
            if ( paws.placing ) then
                paws.placing = false
                paws.Update()
            end
        end

    local base_OnControl = pcomp.playercontroller.OnControl
    pcomp.playercontroller.OnControl =
    function(pcont, control, down)
        if ( not IsPaused() or
             -- same check as paws.Update() uses; should be more general
--(             GetWorld().minimap.MiniMap:IsVisible() ) then
             #TheFrontEnd.screenstack > 1 ) then
            base_OnControl(pcont, control, down)
            return
        end

        -- cancel pause temporarily for these
        if ( control == CONTROL_CANCEL or
             control == CONTROL_PRIMARY or
             control == CONTROL_SECONDARY or 
-- ???           control == CONTROL_CONTROLLER_ACTION or
-- ???           control == CONTROL_CONTROLLER_ALTACTION or
             control == CONTROL_ACTION ) then
            SetPause(false)
        elseif ( down and (control == CONTROL_MOVE_UP or control == CONTROL_MOVE_DOWN or control == CONTROL_MOVE_LEFT or control == CONTROL_MOVE_RIGHT) ) then
            -- controller crafting uses these controls
            if ( not GetPlayer().HUD.controls.crafttabs.controllercraftingopen ) then
                -- FIXME  we should not be messing with this tag: figure out what to override to allow paused movement
                pcont.inst.sg:RemoveStateTag("idle")
                SetPause(false)
            end
        end

        base_OnControl(pcont, control, down)
    
        -- player is now moving to place something, unpause to make sure the move begins
        if ( pcont.inst.components.locomotor.bufferedaction ) then
--           should be ok to run the bufferedaction regardless of why we are paused
--           (and paws.placing and not paws.c_crafting)
            SetPause(false)
        end

        if ( down ) then
            if ( control == CONTROL_ROTATE_LEFT or control == CONTROL_ROTATE_RIGHT ) then
                TheCamera:SetHeadingTarget(TheCamera:GetHeadingTarget() +
                    (control == CONTROL_ROTATE_LEFT and  -45 or 45))
                TheCamera:Snap()
                if ( paws.placement_handler ) then
                    UpdatePlacer()
                end
              -- graphically you can zoom in/out while crafting, but the zoom controls are used by the crafting bars
            elseif ( paws.placing ) then
--            elseif ( (pcont.placer and pcont.placer_recipe) or
--                     (pcont.deployplacer and pcont.deployplacer.components.placer) ) then
                -- The normal zoom is animated over time, so we need to force it
                
                if ( not paws.m_crafting and not paws.c_crafting ) then
                    if ( control == CONTROL_ZOOM_IN ) then
                        TheCamera:ZoomIn()
                        TheCamera:Update(1)
                    elseif ( control == CONTROL_ZOOM_OUT ) then
                        TheCamera:ZoomOut()
                        TheCamera:Update(1)
                    end
                end
            end
        end
    end  -- pcomp.playercontroller.OnControl
end)  -- env.AddSimPostInit

-- override for an immediate unpause
env.AddClassPostConstruct("widgets/controllercrafting", function(widget)
    local cc_base_Close = widget.Close
    function widget:Close(fn)
        if ( cc_base_Close ) then cc_base_Close(widget, fn)
        else widget._base.Close(widget, fn) end
        if ( paws.c_crafting ) then
            paws.c_crafting = false
            paws.Update()
        end
    end
end)

--[[
FIXME  something is wrong with this override -- it messes up the bar
-- override for an immediate unpause
env.AddClassPostConstruct("widgets/mousecrafting", function(widget)
    local mc_base_Close = widget.Close
    function widget:Close(fn)
        if ( mc_base_Close ) then mc_base_Close(widget, fn)
        else widget._base.Close(widget, fn) end
        if ( paws.m_crafting ) then
            paws.m_crafting = false
            paws.Update()
        end
    end
end)
--]]

env.AddClassPostConstruct("widgets/crafting", function(class)
    local player = class.owner

    local function doScrollWorkaround(fn)
        if ( IsPaused() ) then
            SetPause(false)
            fn(class)
            SetPause(true, "Crafting Paws")
        else
            fn(class)
        end
    end

    -- TODO try copying the normal implementation without the pause check
    local base_ScrollUp   = class.ScrollUp
    local base_ScrollDown = class.ScrollDown
    function class:ScrollUp()   doScrollWorkaround(base_ScrollUp) end
    function class:ScrollDown() doScrollWorkaround(base_ScrollDown) end
end)

end  -- return function(env)

-- vim: ts=4:sw=4:et
