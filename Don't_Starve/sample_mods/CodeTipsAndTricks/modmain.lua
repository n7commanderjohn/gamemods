--[[
=======================================================================================
 'require' is required
=======================================================================================

The require function of Lua is an extremely handy tool if taken advantage of. Whenever 
it loads a file, it stores the result (whatever the file returns) in a table 
(package.loaded), and any subsequent require calls with the same module name (you 
can think of module name as filename for now if you're unfamiliar with Lua modules) 
will give you a reference to the previous result.

This becomes very useful specifically for components, screens, widgets, and basically 
anything that defines a Class (because they will almost always return the Class at the 
end of the file). Since require caches its results and gives you a reference to that 
cached result, if you retrieve the result and modify it, you then also modify the 
result of any future require calls (and Don't Starve will usually use require to 
load these files).

Note: This is way faster than using AddComponentPostInit, as instead of overwriting 
function(s) for each and every component that comes into existence, this just does 
that modification one time up front and that's it. As far as I'm concerned, this 
should be the preferred method of extending/overwriting any Don't Starve Class 
definition.

References: 
  require: http://www.lua.org/manual/5.1/manual.html#pdf-require
  modules: http://lua-users.org/wiki/ModulesTutorial
]]--

-- if in the mod environment (modmain.lua), you need to get require from the global environment
local require = GLOBAL.require
-- if in the mod environment, this stuff is needed for our custom code
local Point = GLOBAL.Point -- note: Point is an alias of Vector3
local GetPlayer = GLOBAL.GetPlayer
local distsq = GLOBAL.distsq
local TILE_SCALE = GLOBAL.TILE_SCALE

-- Deployable becomes a reference to the cached result stored in package.loaded["components/deployable"]
local Deployable = require "components/deployable"

-- Store the existing function if it exists, otherwise store a dummy function as a fail-safe
local Deployable_CanDeploy_base = Deployable.CanDeploy or function() return true end
function Deployable:CanDeploy( pt )
	-- Get the result of the base CanDeploy function
	-- Note: Deployable_CanDeploy_base is called with the self parameter because x:fn() is simply a shortcut for x.fn(x) with an implied self parameter
	local can_deploy = Deployable_CanDeploy_base( self, pt )

	-- Add in our own deployment requirement
	-- this will never allow you to deploy something more than 2 tiles away from your current position
	local max_deploy_dist = TILE_SCALE*2
	can_deploy = can_deploy and distsq( GetPlayer():GetPosition(), pt ) <= max_deploy_dist*max_deploy_dist 

	return can_deploy
end


--[[
=======================================================================================
 Adding a component to all player prefabs
=======================================================================================
credit to simplex for this workaround

If you add a component to a player prefab using AddSimPostInit, OnSave and OnLoad for 
that component will simply not work (Note: this is only the case for SimPostInit, not 
PrefabPostInit). I have not investigated the reason why, but to work around it you 
should use the following workaround:
]]--

-- need to add the component in here, otherwise OnSave doesn't work right
AddPrefabPostInit("world", function(inst)
	GLOBAL.assert( GLOBAL.GetPlayer() == nil )
	local player_prefab = GLOBAL.SaveGameIndex:GetSlotCharacter()

	-- Unfortunately, we can't add new postinits by now. So we have to do
	-- it the hard way...

	GLOBAL.TheSim:LoadPrefabs( {player_prefab} )
	local oldfn = GLOBAL.Prefabs[player_prefab].fn
	GLOBAL.Prefabs[player_prefab].fn = function()
		local inst = oldfn()

		-- Add components here.
		-- this will make codetips_prefab's spawn out of all players
		inst:AddComponent("childspawner")
		inst.components.childspawner.childname = "codetips_prefab"
		inst.components.childspawner:SetRegenPeriod(1)
		inst.components.childspawner:SetSpawnPeriod(10)
		inst.components.childspawner:SetMaxChildren(5)
		inst.components.childspawner:StartRegen()
		inst.components.childspawner:StartSpawning()

		return inst
	end
end)


--[[
=======================================================================================
 Utilizing zero-time schedules
=======================================================================================

Sometimes you may need access to something that doesn't quite exist yet. For example, 
a prefab's Transform will not yet be initialized in a PrefabPostInit function or a 
prefab's [font=monospace]fn[/font] constructor function. So, let's say you wanted to 
do something based on what tile type something spawned on. The easy way to do this is 
to create a task that will be executed in 0 time, which essentially waits one frame 
before executing the callback function you provide it (usually enough for what you 
want to start existing).
]]--

local GROUND = GLOBAL.GROUND
local SpawnPrefab = GLOBAL.SpawnPrefab
local DidPrintBerryBushPostInitTransform = false
local DidPrintBerryBushPostInitTaskTransform = false

AddPrefabPostInit( "berrybush", function( inst )
	-- inst.Transform doesn't exist yet, print the transform of one berrybush to confirm
	if not DidPrintBerryBushPostInitTransform then
		print("berrybush PostInit: inst.Transform:GetWorldPosition() =", inst.Transform:GetWorldPosition())
		DidPrintBerryBushPostInitTransform = true
	end

	-- this will wait one frame, which is enough time to have inst.Transform initialized
	inst:DoTaskInTime( 0, function()
		-- print the position once here as well to confirm that its actually set now
		if not DidPrintBerryBushPostInitTaskTransform then
			print("berrybush PostInit task: inst.Transform:GetWorldPosition() =", inst.Transform:GetWorldPosition())
			DidPrintBerryBushPostInitTaskTransform = true
		end

		-- if a berrybush spawns on a savanna tile, create an explosion effect
		if inst:GetCurrentTileType() == GROUND.SAVANNA then
			local explode = SpawnPrefab("explode_small")
			local pos = inst:GetPosition()
			explode.Transform:SetPosition(pos.x, pos.y, pos.z)
			explode.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
			explode.AnimState:SetLightOverride(1)
		end
	end )
end )

-- See also: scripts/prefabs/testprefab.lua
PrefabFiles = {
	"codetips_prefab"
}
