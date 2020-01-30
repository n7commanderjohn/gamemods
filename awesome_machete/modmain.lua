--[[
    
***************************************************************
Created by: N7 Commander John
Date: January 30, 2020
Description: Cut the pesky grass with your wonderful machete! Save lots of time!
***************************************************************

]]

local function onhackedfn_grass(inst, target, hacksleft, from_shears)

    local fx = GLOBAL.SpawnPrefab("hacking_tall_grass_fx")
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
        inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds")
    end
end

local function onhackedfn_sapling(inst, target, hacksleft, from_shears)
    local fx = GLOBAL.SpawnPrefab("hacking_tall_grass_fx")
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
        inst.SoundEmitter:PlaySound("dontstarve/wilson/harvest_sticks")	
    end
    

end

local function onregenfn(inst)
    inst.AnimState:PlayAnimation("grow") 
    inst.AnimState:PushAnimation("idle", true)
    inst.components.hackable.hacksleft = inst.components.hackable.maxhacks
end

local function makeemptyfn_grass(inst)
    if inst.components.pickable and inst.components.pickable.withered then
        inst.AnimState:PlayAnimation("dead_to_empty")
        inst.AnimState:PushAnimation("picked")
    else
        inst.AnimState:PlayAnimation("picking") 
        inst.AnimState:PushAnimation("picked")
    end
    inst.components.hackable.hacksleft = 0
end

local function makeemptyfn_sapling(inst)
    if inst.components.pickable and inst.components.pickable.withered then
        inst.AnimState:PlayAnimation("dead_to_empty")
        inst.AnimState:PushAnimation("empty")
    else
        inst.AnimState:PlayAnimation("rustle") 
        inst.AnimState:PushAnimation("picked", false) 
        end
    inst.components.hackable.hacksleft = 0
end

local function makebarrenfn(inst)
    if inst.components.pickable and inst.components.pickable.withered then

        if not inst.components.pickable.hasbeenpicked then
            inst.AnimState:PlayAnimation("full_to_dead")
        else
            inst.AnimState:PlayAnimation("empty_to_dead")
        end
        inst.AnimState:PushAnimation("idle_dead")
    else
        inst.AnimState:PlayAnimation("idle_dead")
    end
    inst.components.hackable.hacksleft = 0
end

local function onpickedfn_grass(inst)
    --inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds") 
    inst.AnimState:PlayAnimation("picking") 

    if inst.components.pickable and inst.components.pickable:IsBarren() then
        inst.AnimState:PushAnimation("idle_dead")
    else
        inst.AnimState:PushAnimation("picked")
    end

    -- this should prevent hacking after grass and saplings have been picked by hand
    if inst.components.hackable then
        inst.components.hackable.hacksleft = 0
        inst.components.hackable:MakeEmpty()
    end
end

local function onpickedfn_sapling(inst)
	inst.AnimState:PlayAnimation("rustle") 
	inst.AnimState:PushAnimation("picked", false) 
    
    if inst.components.hackable then
        inst.components.hackable.hacksleft = 0
        inst.components.hackable:MakeEmpty()
    end
end


--special post-init function for a particular prefab: grass in this case
--not sure yet if local functions have to be reimported to work properly;
--they probably do, they are called local after all for a reason.
function cutGrassWithMachete_PostInit(inst)
    print("i can cut grass with machetes!")

    -- need to override the existing grass picking to include making hacking impossible after picking
    inst.components.pickable.onpickedfn = onpickedfn_grass

    inst:AddComponent("hackable")
    inst.components.hackable:SetUp("cutgrass", TUNING.GRASS_REGROW_TIME )
    inst.components.hackable.onregenfn = onregenfn
    inst.components.hackable.onhackedfn = onhackedfn_grass
    inst.components.hackable.makeemptyfn = makeemptyfn_grass
    inst.components.hackable.makebarrenfn = makebarrenfn
    inst.components.hackable.max_cycles = 20
    inst.components.hackable.cycles_left = 20
    inst.components.hackable.hacksleft = 1
    inst.components.hackable.maxhacks = 1
end

function cutSaplingWithMachete_PostInit(inst)
    print("i can cut saplings with machetes!")

    -- need to override the existing sappling picking to include making hacking impossible after picking
    inst.components.pickable.onpickedfn = onpickedfn_sapling

    inst:AddComponent("hackable")
    inst.components.hackable:SetUp("twigs", TUNING.SAPLING_REGROW_TIME )
    inst.components.hackable.onregenfn = onregenfn
    inst.components.hackable.onhackedfn = onhackedfn_sapling
    inst.components.hackable.makeemptyfn = makeemptyfn_sapling
    inst.components.hackable.makebarrenfn = makebarrenfn
    inst.components.hackable.max_cycles = 20
    inst.components.hackable.cycles_left = 20
    inst.components.hackable.hacksleft = 1
    inst.components.hackable.maxhacks = 1
end

--add a post init for the grass
AddPrefabPostInit("grass", cutGrassWithMachete_PostInit)
--add a post init for the sapling
AddPrefabPostInit("sapling", cutSaplingWithMachete_PostInit)
