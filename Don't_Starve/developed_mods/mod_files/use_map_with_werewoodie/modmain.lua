local GetPlayer = GLOBAL.GetPlayer
local GetWorld = GLOBAL.GetWorld
local TheFrontEnd = GLOBAL.TheFrontEnd
local Class = GLOBAL.Class

local Badge = require "widgets/badge"

local BeaverBadge = Class(Badge, function(self, owner)
	Badge._ctor(self, "beaver_meter", owner)
end)

local function SetHUDState(inst)
    if inst.HUD then
        if inst.components.beaverness:IsBeaver() and not inst.HUD.controls.beaverbadge then
            inst.HUD.controls.beaverbadge = GetPlayer().HUD.controls.sidepanel:AddChild(BeaverBadge(inst))
            inst.HUD.controls.beaverbadge:SetPosition(0,-100,0)
            inst.HUD.controls.beaverbadge:SetPercent(1)
            
            inst.HUD.controls.beaverbadge.inst:ListenForEvent("beavernessdelta", function(_, data) 
                inst.HUD.controls.beaverbadge:SetPercent(inst.components.beaverness:GetPercent(), inst.components.beaverness.max)
                if not data.overtime then
                    if data.newpercent > data.oldpercent then
                        inst.HUD.controls.beaverbadge:PulseGreen()
                        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/health_up")
                    elseif data.newpercent < data.oldpercent then
                        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/health_down")
                        inst.HUD.controls.beaverbadge:PulseRed()
                    end
                end
            end, inst)
            inst.HUD.controls.crafttabs:Hide()
            inst.HUD.controls.inv:Hide()
            inst.HUD.controls.status:Hide()
            -- inst.HUD.controls.mapcontrols.minimapBtn:Hide()

            inst.HUD.beaverOL = inst.HUD.under_root:AddChild(Image("images/woodie.xml", "beaver_vision_OL.tex"))
            inst.HUD.beaverOL:SetVRegPoint(ANCHOR_MIDDLE)
            inst.HUD.beaverOL:SetHRegPoint(ANCHOR_MIDDLE)
            inst.HUD.beaverOL:SetVAnchor(ANCHOR_MIDDLE)
            inst.HUD.beaverOL:SetHAnchor(ANCHOR_MIDDLE)
            inst.HUD.beaverOL:SetScaleMode(SCALEMODE_FILLSCREEN)
            inst.HUD.beaverOL:SetClickable(false)
        
        elseif not inst.components.beaverness:IsBeaver() and inst.HUD.controls.beaverbadge then
            if inst.HUD.controls.beaverbadge then
                inst.HUD.controls.beaverbadge:Kill()
                inst.HUD.controls.beaverbadge = nil
            end

            if inst.HUD.beaverOL then
                inst.HUD.beaverOL:Kill()
                inst.HUD.beaverOL = nil
            end

            inst.HUD.controls.crafttabs:Show()
            inst.HUD.controls.inv:Show()
            inst.HUD.controls.status:Show()
            -- inst.HUD.controls.mapcontrols.minimapBtn:Show()
        end
    end
end

local function BecomeWoodie(inst)
    
    inst.components.poisonable:SetBlockAll(nil)

    inst.beaver = false
    inst.ActionStringOverride = nil
    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("woodie")
    inst:SetStateGraph("SGwilson")
    inst:RemoveTag("beaver")
    
    inst:RemoveComponent("worker")
    inst.components.talker:StopIgnoringAll()
    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED
    inst.components.combat:SetDefaultDamage(TUNING.UNARMED_DAMAGE)
    
    inst.components.playercontroller.actionbuttonoverride = nil
    inst.components.playeractionpicker.leftclickoverride = nil
    inst.components.playeractionpicker.rightclickoverride = nil
    inst.components.eater:SetOmnivore()


    inst.components.hunger:Resume()
    inst.components.sanity.ignore = false
    inst.components.health.redirect = nil

    inst.components.beaverness:StartTimeEffect(2, -1)

    inst:RemoveEventCallback("oneatsomething", onbeavereat)
    inst.Light:Enable(false)
    inst.components.dynamicmusic:Enable()
    inst.SoundEmitter:KillSound("beavermusic")
    GetWorld().components.colourcubemanager:SetOverrideColourCube(nil)
    inst.components.temperature:SetTemp(nil)
    inst:DoTaskInTime(0, function() SetHUDState(inst) end)
    
end

local function BecomeBeaver(inst)

	inst.components.poisonable:SetBlockAll(true)

	inst.beaver = true
	inst.ActionStringOverride = beaveractionstring
	inst:AddTag("beaver")
	inst.AnimState:SetBuild("werebeaver_build")
	inst.AnimState:SetBank("werebeaver")
	inst:SetStateGraph("SGwerebeaver")
	inst.components.talker:IgnoreAll()
	inst.components.combat:SetDefaultDamage(TUNING.BEAVER_DAMAGE)

	inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED*1.1
	inst.components.inventory:DropEverything()
	
	inst.components.playercontroller.actionbuttonoverride = BeaverActionButton
	inst.components.playeractionpicker.leftclickoverride = LeftClickPicker
	inst.components.playeractionpicker.rightclickoverride = RightClickPicker
	inst.components.eater:SetBeaver()

	inst:AddComponent("worker")
	inst.components.worker:SetAction(ACTIONS.DIG, 1)
	inst.components.worker:SetAction(ACTIONS.CHOP, 4)
	inst.components.worker:SetAction(ACTIONS.MINE, 1)
	inst.components.worker:SetAction(ACTIONS.HAMMER, 1)
	inst.components.worker:SetAction(ACTIONS.HACK, 1)	
	inst:ListenForEvent("oneatsomething", onbeavereat)

	inst.components.sanity:SetPercent(1)
	inst.components.health:SetPercent(1)
	inst.components.hunger:SetPercent(1)

	inst.components.hunger:Pause()
	inst.components.sanity.ignore = true
	inst.components.health.redirect = beaverhurt
	inst.components.health.redirect_percent = .25

	local dt = 3
	local BEAVER_DRAIN_TIME = 120
	inst.components.beaverness:StartTimeEffect(dt, (-100/BEAVER_DRAIN_TIME)*dt)
	inst.Light:Enable(true)
    inst.components.dynamicmusic:Disable()
	inst.SoundEmitter:PlaySound("dontstarve/music/music_hoedown", "beavermusic")
    GetWorld().components.colourcubemanager:SetOverrideColourCube("images/colour_cubes/beaver_vision_cc.tex")
    inst.components.temperature:SetTemp(20)
	inst:DoTaskInTime(0, function() SetHUDState(inst) end)
    
	if inst:HasTag("lightsource") then       
	    inst:RemoveTag("lightsource")    
	end
end

local function OverrideBeaverMapStuff(inst)
    inst.components.beaverness.makeperson = BecomeWoodie
    inst.components.beaverness.makebeaver = BecomeBeaver
end


AddComponentPostInit("woodie", OverrideBeaverMapStuff)
