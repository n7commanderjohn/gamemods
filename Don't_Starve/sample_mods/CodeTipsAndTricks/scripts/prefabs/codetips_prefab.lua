-- In a prefab file, you need to list all the assets it requires.
-- These can be either standard assets, or custom ones in your mod
-- folder.
local Assets =
{
	Asset("ANIM", "anim/twigs.zip"),
	Asset("SOUND", "sound/common.fsb"),
}

local Prefabs =
{
    "explode_small"
}

local function OnIgniteFn(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_fuse_LP", "hiss")
    inst:PushEvent("death")
end

local function OnExplodeFn(inst)
    inst.SoundEmitter:KillSound("hiss")
    inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")

    local explode = SpawnPrefab("explode_small")
    local pos = inst:GetPosition()
    explode.Transform:SetPosition(pos.x, pos.y, pos.z)

    explode.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
    explode.AnimState:SetLightOverride(1)
end

-- Write a local function that creates, customizes, and returns an instance of the prefab.
local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

    inst.AnimState:SetBank("twigs")
    inst.AnimState:SetBuild("twigs")
    inst.AnimState:PlayAnimation("idle")

	inst:AddComponent("inspectable")

	MakeSmallBurnable(inst, 3+math.random()*3)

    inst:AddComponent("explosive")
    inst.components.explosive:SetOnExplodeFn(OnExplodeFn)
    inst.components.explosive:SetOnIgniteFn(OnIgniteFn)
    inst.components.explosive.explosivedamage = 0

    print("codetips_prefab fn: inst.Transform:GetWorldPosition() =", inst.Transform:GetWorldPosition())

    inst:DoTaskInTime(0, function()
    	print("codetips_prefab task: inst.Transform:GetWorldPosition() =", inst.Transform:GetWorldPosition())

    	if inst:GetCurrentTileType() == GROUND.GRASS then
    		inst.components.burnable:Ignite()
    	end
    end)

    return inst
end

-- Add some strings for this item
STRINGS.NAMES.CODETIPS_PREFAB = "Test Object"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.CODETIPS_PREFAB = "Explodes if spawned on grass."

-- Finally, return a new prefab with the construction function and assets.
return Prefab( "common/objects/codetips_prefab", fn, Assets, Prefabs)