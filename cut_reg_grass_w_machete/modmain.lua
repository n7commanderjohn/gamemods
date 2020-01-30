--[[
    
***************************************************************
Created by: N7 Commander John
Date: January 30, 2020
Description: Cut the pesky grass with your wonderful machete! Save lots of time!
***************************************************************

]]

local function onhackedfn(inst, target, hacksleft, from_shears)

    local fx = SpawnPrefab("hacking_tall_grass_fx")
    local x, y, z= inst.Transform:GetWorldPosition()
    fx.Transform:SetPosition(x,y + math.random()*2,z)

    if inst:HasTag("weevole_infested")then
        spawnweevole(inst, target)
    end

    if inst.components.hackable and inst.components.hackable.hacksleft <= 0 then		
        inst.AnimState:PlayAnimation("fall")			
        inst.AnimState:PushAnimation("picked",true)			
        inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/vine_drop")	
        if inst:HasTag("weevole_infested")then	
            removeweevoleden(inst)
        end
    else
        inst.AnimState:PlayAnimation("chop") 
        inst.AnimState:PushAnimation("idle",true)
    end

    if inst.components.pickable then
        inst.components.pickable:MakeEmpty()
    end

    if not from_shears then	
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/harvested/grass_tall/machete")
    end
    

    --[[
    if inst.components.pickable and inst.components.pickable:IsBarren() then
        inst.AnimState:PushAnimation("idle_dead")
    else
        inst.AnimState:PushAnimation("picked")
        if inst.inwater then 
            inst.Physics:SetCollides(false)

            inst.AnimState:SetLayer( LAYER_BACKGROUND )
            inst.AnimState:SetSortOrder( 3 )
        end 
    end
    ]]
end

local function onregenfn(inst)
    inst.AnimState:PlayAnimation("grow") 
    inst.AnimState:PushAnimation("idle", true)
    if inst.inwater then 
        inst.Physics:SetCollides(true)
        inst.AnimState:SetLayer( LAYER_WORLD)
        inst.AnimState:SetSortOrder(0)
    end 
end

local function makeemptyfn(inst)
    if inst.components.pickable and inst.components.pickable.withered then
        inst.AnimState:PlayAnimation("dead_to_empty")
        inst.AnimState:PushAnimation("picked")
    else
        inst.AnimState:PlayAnimation("picked")
    end
    if inst.inwater then 
        inst.Physics:SetCollides(false)

        inst.AnimState:SetLayer( LAYER_BACKGROUND )
        inst.AnimState:SetSortOrder( 3 )
    end 
end

local function makebarrenfn(inst)
    if inst.components.pickable and inst.components.pickable.withered then

        if inst.inwater then 
            inst.Physics:SetCollides(true)
            inst.AnimState:SetLayer( LAYER_WORLD)
            inst.AnimState:SetSortOrder(0)
        end 

        if not inst.components.pickable.hasbeenpicked then
            inst.AnimState:PlayAnimation("full_to_dead")
        else
            inst.AnimState:PlayAnimation("empty_to_dead")
        end
        inst.AnimState:PushAnimation("idle_dead")
    else
        inst.AnimState:PlayAnimation("idle_dead")
    end
end

--special post-init function for a particular prefab: grass in this case
--not sure yet if local functions have to be reimported to work properly;
--they probably do, they are called local after all for a reason.
function cutGrassWithMachete_PostInit(inst)
    print("i can cut grass with machetes!")

    inst:AddComponent("hackable")
    inst.components.hackable:SetUp(product, TUNING.GRASS_REGROW_TIME )  
    inst.components.hackable.onregenfn = onregenfn
    inst.components.hackable.onhackedfn = onhackedfn
    inst.components.hackable.makeemptyfn = makeemptyfn
    inst.components.hackable.makebarrenfn = makebarrenfn
    inst.components.hackable.max_cycles = 20
    inst.components.hackable.cycles_left = 20
    inst.components.hackable.hacksleft = 1
    inst.components.hackable.maxhacks = 1
end

--add a post init for the grass
AddPrefabPostInit("grass", cutGrassWithMachete_PostInit)
