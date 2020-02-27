--[[

***************************************************************
Created by: N7 Commander John
Date: February 7th, 2020
Description: Cut the pesky plants with your wonderful machete! Save lots of time!
***************************************************************

]]

local require = GLOBAL.require
local SpawnPrefab = GLOBAL.SpawnPrefab
local Hackable = require "components/hackable"
-- require('debugkeys')
-- GLOBAL.CHEATS_ENABLED = true

--override Hack to have it give the product immediately instead of dropping it.
function Hackable:Hack(hacker, numworks, shear_mult, from_shears)
    if self.canbehacked and self.caninteractwith then
        self.hacksleft = self.hacksleft - numworks 
        --Check work left here and fire callback and early out if there's still more work to do 
            if self.onhackedfn then
            self.onhackedfn(self.inst, hacker, self.hacksleft, from_shears)
        end

        if(self.hacksleft <= 0) then         
            if self.transplanted then
                if self.cycles_left ~= nil then
                    self.cycles_left = self.cycles_left - 1
                end
            end

            if self.shouldwither then
                if self.protected_cycles ~= nil then
                    self.protected_cycles = self.protected_cycles - 1
                end
            end
            
            self.canbehacked = false
            self.inst:AddTag("stump")
            self.hasbeenhacked = true
            
            if not self.paused and not self.withered and self.baseregentime and (self.cycles_left == nil or self.cycles_left > 0) then
                self.regentime = self.baseregentime * self:GetGrowthMod()
                self.task = self.inst:DoTaskInTime(self.regentime, OnHackableRegen, "regen")
                self.targettime = GLOBAL.GetTime() + self.regentime
            end
            
            local loot = nil
            if self.product == "cutgrass" or self.product == "cutreeds" or self.product == "twigs" then
                if hacker and hacker.components.inventory and self.product then        	
                    loot = SpawnPrefab(self.product)
                    
                    if loot then
                        shear_mult = shear_mult or 1
                        if shear_mult >= 1 and loot.components.stackable then
                            loot.components.stackable:SetStackSize(shear_mult)	            	
                        end
        
                        self.inst:ApplyInheritedMoisture(loot)
                        
                        -- hacker:PushEvent("picksomething", {object = self.inst, loot= loot})
                        hacker.components.inventory:GiveItem(loot, nil, GLOBAL.Vector3(TheSim:GetScreenPos(self.inst.Transform:GetWorldPosition())))
                    end
                end
            else
                loot = self:DropProduct(shear_mult)
            end
            
            self.inst:PushEvent("hacked", {hacker = hacker, loot = loot, plant = self.inst})
        end
    end
end

local function onpickedfn_grass(inst)
    -- this should prevent hacking after grass and saplings have been picked by hand
    if inst.components.hackable then
        inst.components.hackable:MakeEmpty()
    end

    inst.AnimState:PlayAnimation("picking") 

    if inst.components.pickable and inst.components.pickable:IsBarren() then
        inst.AnimState:PushAnimation("idle_dead")
    else
        inst.AnimState:PushAnimation("picked")
        if inst.inwater then 
            inst.Physics:SetCollides(false)

            inst.AnimState:SetLayer(GLOBAL.LAYER_BACKGROUND )
            inst.AnimState:SetSortOrder( 3 )
        end
    end
end

local function onpickedfn_spikybush(inst, picker)
    -- this should prevent hacking after grass and saplings have been picked by hand
    if inst.components.hackable then
        inst.components.hackable:MakeEmpty()
    end

    inst.AnimState:PlayAnimation("picking") 
    inst.AnimState:PushAnimation("picked", false)
    if picker.components.combat then
        picker.components.combat:GetAttacked(inst, TUNING.MARSHBUSH_DAMAGE)
        picker:PushEvent("thorns")
    end     
end

local function onpickedfn_sapling(inst)
    if inst.components.hackable then
        inst.components.hackable:MakeEmpty()
    end

    inst.AnimState:PlayAnimation("rustle") 
    inst.AnimState:PushAnimation("picked", false) 
    
end

local function onhackedfn_grass(inst, target, hacksleft, from_shears)

    local fx = SpawnPrefab("hacking_tall_grass_fx")
    local x, y, z= inst.Transform:GetWorldPosition()
    fx.Transform:SetPosition(x,y + math.random()*2,z)

    if inst.components.hackable and inst.components.hackable.hacksleft <= 0 then
        if inst.SoundEmitter == nil then
            inst.entity:AddSoundEmitter() --failsafe but probably unnecessary
        end
        -- inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds")
    else
        inst.AnimState:PlayAnimation("chop") 
        inst.AnimState:PushAnimation("idle", true)
    end

    if inst.components.pickable then
        inst.components.pickable:MakeEmpty()
    end

    if not from_shears then	
        -- inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/harvested/grass_tall/machete")
        inst.AnimState:PlayAnimation("picking")
        inst.AnimState:PushAnimation("picked")
        inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds")
    end
end

local function onhackedfn_spikybush(inst, target, hacksleft, from_shears)

    local fx = SpawnPrefab("hacking_tall_grass_fx")
    local x, y, z= inst.Transform:GetWorldPosition()
    fx.Transform:SetPosition(x,y + math.random()*2,z)

    if inst.components.hackable and inst.components.hackable.hacksleft <= 0 then
        if inst.SoundEmitter == nil then
            inst.entity:AddSoundEmitter() --failsafe but probably unnecessary
        end
    else
        inst.AnimState:PlayAnimation("chop") 
        inst.AnimState:PushAnimation("idle", true)
    end

    if inst.components.pickable then
        inst.components.pickable:MakeEmpty()
    end

    if not from_shears then	
        inst.AnimState:PlayAnimation("picking")
        inst.AnimState:PushAnimation("picked")
        inst.SoundEmitter:PlaySound("dontstarve/wilson/harvest_sticks")
    end
end

local function onhackedfn_sapling(inst, target, hacksleft, from_shears)
    local fx = SpawnPrefab("hacking_tall_grass_fx")
    local x, y, z= inst.Transform:GetWorldPosition()
    fx.Transform:SetPosition(x,y + math.random()*2,z)

    if inst.components.hackable and inst.components.hackable.hacksleft <= 0 then
        if inst.SoundEmitter == nil then
            inst.entity:AddSoundEmitter() --this will add it for saplings
        end
        -- inst.SoundEmitter:PlaySound("dontstarve/wilson/harvest_sticks")	
    else
        inst.AnimState:PlayAnimation("chop") 
        inst.AnimState:PushAnimation("idle", true)
    end

    if inst.components.pickable then
        inst.components.pickable:MakeEmpty()
    end

    if not from_shears then	
        -- inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/harvested/grass_tall/machete")
        inst.AnimState:PlayAnimation("rustle") 
        inst.AnimState:PushAnimation("picked", false) 
        inst.SoundEmitter:PlaySound("dontstarve/wilson/harvest_sticks")	
    end
end

local function makebarrenfn_hack(inst)
    if inst.components.hackable and inst.components.hackable.withered then

        if inst.inwater then 
            inst.Physics:SetCollides(true)
            inst.AnimState:SetLayer(GLOBAL.LAYER_WORLD)
            inst.AnimState:SetSortOrder(0)
        end 

        if not inst.components.hackable.hasbeenhacked then
            inst.AnimState:PlayAnimation("full_to_dead")
        else
            inst.AnimState:PlayAnimation("empty_to_dead")
        end
        inst.AnimState:PushAnimation("idle_dead")
    else
        inst.AnimState:PlayAnimation("idle_dead")
    end
end



local GROUND = GLOBAL.GROUND;
local function ontransplantfn_grass(inst)
    if inst.components.pickable then
        inst.components.pickable:MakeBarren()
    end
    if inst.components.hackable then
        inst.components.hackable:MakeBarren()
    end
    -- checks to turn into Tall Grass if on the right terrain
    local pt = GLOBAL.Vector3(inst.Transform:GetWorldPosition())
    local tiletype = GLOBAL.GetGroundTypeAtPosition(pt)
    if tiletype == GROUND.PLAINS or tiletype == GROUND.RAINFOREST or tiletype == GROUND.DEEPRAINFOREST or tiletype == GROUND.DEEPRAINFOREST_NOCANOPY then	
        local newgrass = SpawnPrefab("grass_tall")
        newgrass.Transform:SetPosition(pt:Get())
        -- need to make it new grass here.. 
        inst:Remove()
    end
end

local function ontransplantfn_sapling(inst)
    inst.components.pickable:MakeEmpty()
    inst.components.hackable:MakeEmpty()
end

--special post-init function for a particular prefab: grass in this case
--not sure yet if local functions have to be reimported to work properly;
--they probably do, they are called local after all for a reason.
function cutGrassWithMachete_PostInit(inst)
    print("i can cut grass with machetes!")

    -- need to override the existing grass picking to include making hacking impossible after picking
    local pickableInst = inst.components.pickable
    pickableInst.onpickedfn = onpickedfn_grass
    pickableInst.ontransplantfn = ontransplantfn_grass

    inst:AddComponent("hackable")
    local hackableInst = inst.components.hackable
    hackableInst:SetUp("cutgrass", TUNING.GRASS_REGROW_TIME )
    hackableInst.onregenfn = pickableInst.onregenfn
    hackableInst.onhackedfn = onhackedfn_grass
    hackableInst.makeemptyfn = pickableInst.makeemptyfn
    hackableInst.makebarrenfn = makebarrenfn_hack
    hackableInst.ontransplantfn = ontransplantfn_grass
    hackableInst.max_cycles = 20
    hackableInst.cycles_left = 20
    hackableInst.hacksleft = 1
    hackableInst.maxhacks = 1

    MakeNoGrowInWinter_Hackable(inst)
end

function cutReedsWithMachete_PostInit(inst)
    print("i can cut reeds with machetes!")

    -- need to override the existing grass picking to include making hacking impossible after picking
    local pickableInst = inst.components.pickable
    pickableInst.onpickedfn = onpickedfn_grass

    inst:AddComponent("hackable")
    local hackableInst = inst.components.hackable
    hackableInst:SetUp("cutreeds", TUNING.REEDS_REGROW_TIME )
    hackableInst.onregenfn = pickableInst.onregenfn
    hackableInst.onhackedfn = onhackedfn_grass
    hackableInst.makeemptyfn = pickableInst.makeemptyfn
    hackableInst.max_cycles = 20
    hackableInst.cycles_left = 20
    hackableInst.hacksleft = 1
    hackableInst.maxhacks = 1

    MakeNoGrowInWinter_Hackable(inst)
end

function cutSpikyBushWithMachete_PostInit(inst)
    print("i can cut spikybush with machetes!")

    -- need to override the existing grass picking to include making hacking impossible after picking
    local pickableInst = inst.components.pickable
    pickableInst.onpickedfn = onpickedfn_spikybush
    pickableInst.ontransplantfn = ontransplantfn_sapling

    inst:AddComponent("hackable")
    local hackableInst = inst.components.hackable
    hackableInst:SetUp("twigs", TUNING.MARSHBUSH_REGROW_TIME )
    hackableInst.onregenfn = pickableInst.onregenfn
    hackableInst.onhackedfn = onhackedfn_spikybush
    hackableInst.makeemptyfn = pickableInst.makeemptyfn
    hackableInst.ontransplantfn = ontransplantfn_sapling
    hackableInst.max_cycles = 20
    hackableInst.cycles_left = 20
    hackableInst.hacksleft = 1
    hackableInst.maxhacks = 1
end

function cutSaplingWithMachete_PostInit(inst)
    print("i can cut saplings with machetes!")

    -- need to override the existing sappling picking to include making hacking impossible after picking
    local pickableInst = inst.components.pickable
    pickableInst.onpickedfn = onpickedfn_sapling
    pickableInst.ontransplantfn = ontransplantfn_sapling

    inst:AddComponent("hackable")
    local hackableInst = inst.components.hackable
    hackableInst:SetUp("twigs", TUNING.SAPLING_REGROW_TIME )
    hackableInst.onregenfn = pickableInst.onregenfn
    hackableInst.onhackedfn = onhackedfn_sapling
    hackableInst.makeemptyfn = pickableInst.makeemptyfn
    hackableInst.makebarrenfn = makebarrenfn_hack
    hackableInst.ontransplantfn = ontransplantfn_sapling
    hackableInst.max_cycles = 20
    hackableInst.cycles_left = 20
    hackableInst.hacksleft = 1
    hackableInst.maxhacks = 1

    MakeNoGrowInWinter_Hackable(inst)
end

-- local Simutil = require "simutil"
local GetSeasonManager = GLOBAL.GetSeasonManager

local function OnGrowSeasonChange(inst)
    if not GetSeasonManager() then return end
    
    if inst.components.hackable then
        if GetSeasonManager():IsWinter() then
            inst.components.hackable:Pause()
        elseif not inst.components.hackable.dontunpauseafterwinter then     
            inst.components.hackable:Resume()
        end
    end
end

function MakeNoGrowInWinter_Hackable(inst)
    if not GetSeasonManager() then return end
    
    inst:ListenForEvent("seasonChange", function() OnGrowSeasonChange(inst) end, GLOBAL.GetWorld())
    if GetSeasonManager():IsWinter() then
        OnGrowSeasonChange(inst)
    end
end

--add a post init for the grass
AddPrefabPostInit("grass", cutGrassWithMachete_PostInit)
--add a post init for the sapling
AddPrefabPostInit("sapling", cutSaplingWithMachete_PostInit)
--add a post init for the reeds
AddPrefabPostInit("reeds", cutReedsWithMachete_PostInit)
--add a post init for the spiky bush
AddPrefabPostInit("marsh_bush", cutSpikyBushWithMachete_PostInit)
