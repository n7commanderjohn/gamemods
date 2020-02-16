local KEY_WEAPON = GetModConfigData("Key_Weapon")
local KEY_AXE = GetModConfigData("Key_Axe")
local KEY_PICKAXE = GetModConfigData("Key_Pickaxe")
local KEY_SHOVEL = GetModConfigData("Key_Shovel")
local KEY_HAMMER = GetModConfigData("Key_Hammer")
local KEY_PITCHFORK = GetModConfigData("Key_Pitchfork")
local KEY_LIGHT = GetModConfigData("Key_Light")
local KEY_ARMOR = GetModConfigData("Key_Armor")
local KEY_HELMET = GetModConfigData("Key_Helmet")
local KEY_CANE = GetModConfigData("Key_Cane")
local KEY_MACHETE = GetModConfigData("Key_Machete")
local LETTERS = GetModConfigData("Letters")
local DISABLE_KEYS = GetModConfigData("Disable_Keys")
local DISABLE_BUTTONS = GetModConfigData("Disable_Buttons")
local SUPPORT_ARCHERY = GetModConfigData("Support_Archery")
local SUPPORT_SCYTHES = GetModConfigData("Support_Scythes")
local KEY_SCYTHE = GetModConfigData("Key_Scythe")
local VERTICAL_OFFSET = GetModConfigData("Vertical_Offset")
local KEY_REFRESH = GetModConfigData("Key_Refresh")


local KEYS = {
	KEY_WEAPON,
	KEY_AXE,
	KEY_PICKAXE,
	KEY_SHOVEL,
	KEY_HAMMER,
	KEY_PITCHFORK,
	KEY_LIGHT,
	KEY_ARMOR,
	KEY_HELMET,
	KEY_CANE,
	KEY_MACHETE,
	KEY_SCYTHE
}
local require = GLOBAL.require
-- require('debugkeys')
-- GLOBAL.CHEATS_ENABLED = true

local Player = GLOBAL.GetPlayer
local World = GLOBAL.GetWorld
local Widget = require("widgets/widget")
local Image = require("widgets/image")
local ImageButton = require("widgets/imagebutton")
local Button = require("widgets/button")

local cantButtons = 12

local button = {}
local icon_button = {}
local actual_item = {}
local letter = {}

local button_order = {2,1,2,3,4,5,6,3,4,1}
local button_order_boat = {2,1,3,4,5,6,7,3,4,1,2}
local button_order_scythe = {2,1,3,4,5,6,7,3,4,1,2,2}
local button_order_boat_scythe = {2,1,4,5,6,7,8,3,4,1,2,3}
local button_side = {1,0,0,0,0,0,0,1,1,1}
local button_side_boat = {1,0,0,0,0,0,0,1,1,1,0}
local button_side_scythe = {1,0,0,0,0,0,0,1,1,1,0,0}
local button_side_boat_scythe = {1,0,0,0,0,0,0,1,1,1,0,0}


local original_button_pos = {}
local boat_button_pos = {}

local tools_back
local equip_back
local boat_back

local IsDLCEnabled = GLOBAL.IsDLCEnabled

local vanilla_enabled = IsDLCEnabled(GLOBAL.MAIN_GAME)
local rog_enabled = IsDLCEnabled(GLOBAL.REIGN_OF_GIANTS)
local shipwrecked_enabled = IsDLCEnabled(GLOBAL.CAPY_DLC)
local hamlet_enabled = IsDLCEnabled(GLOBAL.PORKLAND_DLC)

local shipwrecked_world
local hamlet_world

local finish_init = false

local offset_archery = 0
if (SUPPORT_ARCHERY) then
	offset_archery = -96
end

local default_icon = {
	"spear",
	"axe",
	"pickaxe",
	"shovel",
	"hammer",
	"pitchfork",
	"torch",
	"armorwood",
	"footballhat",
	"cane",
	"machete",
	"scythe"
}

local weapons = {
	"zmagicbow",
	"zmusket",
	"zcrossbow",
	"zbow",
	"cutlass",
	"nightsword",
	"ruins_bat",
	"hambat",
	"spear_obsidian",
	"mace_sting",
	"tentaclespike",
	"batbat",
	"mace_gear",
	"spear_wathgrithr",
	"staff_gear",
	"sword_rock",
	"spear_poison",
	"spear",
	"peg_leg",
	"trident",
	"whip",
	"needlespear",
	"bug_swatter"
}

local axes = {
	"lucy",
	"multitool",
	"multitool_axe_pickaxe",
	"obsidianaxe",
	"goldenaxe",
	"axe"
}

local pickaxes = {
	"multitool",
	"multitool_axe_pickaxe",
	"goldenpickaxe",
	"pickaxe"
}

local shovels = {
	"goldenshovel",
	"shovel"
}

local machetes = {
	"obsidianmachete",
	"goldenmachete",
	"machete"
}

local scythes = {
	"golden_scythe",
	"scythe"
}

local armors = {
	"armorruins",
	"armordragonfly",
	"armorobsidian",
	"armorsnurtleshell",
	"armormarble",
	"armorlimestone",
	"armor_sanity",
	"armor_rock",
	"armorseashell",
	"armorcactus",
	"armor_bone",
	"armor_stone",
	"armorwood",
	"armorgrass"
}

local helmets = {
	"ruinshat",
	"hivehat",
	"hat_marble",
	"slurtlehat",
	"hat_rock",
	"wathgrithrhat",
	"oxhat",
	"hat_wood",
	"footballhat"
}

local backpacks = {
	"backpack",
	"piggypack",
	"krampus_sack",
	"icepack",
	"thatchpack",
	"piratepack",
	"spicepack",
	"seasack",
	"bunnyback",
	"wolfyback"
}

local lights = {
	"hat_goggles",
	"molehat",
	"bottlelantern",
	"lantern",
	"minerhat",
	"tarlamp",
	"lighter",
	"torch"
}

Assets = {
	Asset("ATLAS", "images/basic_back.xml"),
	Asset("IMAGE", "images/basic_back.tex"),
	Asset("ATLAS", "images/boat_back.xml"),
	Asset("IMAGE", "images/boat_back.tex"),
	Asset("ATLAS", "images/button_large.xml"),
	Asset("IMAGE", "images/button_large.tex")
}

local info_buttons = {}
local info_stack = {last=0}
local info_names = {last=0}
local info_back_button
local info_actual_button
local base_position = { x =-600, y = -100}
local col = 0
local row = 0
local offset_x = 120
local offset_y = 55

local function ClearInfoTable()
	info_stack = {last=0}
	info_names = {last=0}
	
	if (info_back_button) then
		info_back_button:Kill()
	end
		
	if (info_actual_button) then
		info_actual_button:Kill()
	end
	
	info_back_button = nil
	info_actual_button = nil
	
	for i,v in pairs(info_buttons) do
		v:Kill()
	end
	info_buttons = {}
end

local function InfoTable(inst, info, last_info, init)
	local info_root = inst.HUD.controls.top_root
	col = 0
	row = 0
	
	if (init) then
		info_stack = {last=0}
		info_names = {last=0}
	end
	
	if (info_back_button) then
		info_back_button:Kill()	
	end
	
	if (info_actual_button) then
		info_actual_button:Kill()
	end
	
	if (last_info) then
		info_stack.last = info_stack.last + 1
		info_stack[info_stack.last] = last_info
	end
	
	info_back_button = info_root:AddChild(ImageButton())
	info_back_button:SetText("<-")
	info_back_button:UpdatePosition(base_position.x+(col*offset_x),base_position.y-(row*offset_y),0)
	info_back_button:SetScale(0.7,0.7,0.7)
	info_back_button:Disable()
	
	info_actual_button = info_root:AddChild(ImageButton("images/button_large.xml","normal.tex","focus.tex","disabled.tex"))
	local dir = ""
	for i=1, info_names.last do
		dir = dir.."/"..info_names[i]
	end
	info_actual_button:SetText(dir)
	info_actual_button:UpdatePosition(base_position.x+(3*offset_x),base_position.y-(row*offset_y),0)
	info_actual_button:SetScale(0.5,0.5,0.5)
	info_actual_button:Disable()
	row = row + 1
	
	if (info_stack.last ~= 0) then
		info_back_button:Enable()
		local back_info = info_stack[info_stack.last]
		info_back_button:SetOnClick(function()
			info_stack.last = info_stack.last - 1
			info_names.last = info_names.last - 1
			InfoTable(inst, back_info, nil, false)
		end)
	end
	
	for i,v in pairs(info_buttons) do
		v:Kill()
	end
	info_buttons = {}
	for i,v in pairs(info) do
		info_buttons[i] = info_root:AddChild(ImageButton())
		info_buttons[i]:UpdatePosition(base_position.x+(col*offset_x),base_position.y-(row*offset_y),0)
		info_buttons[i]:SetScale(0.7,0.7,0.7)
		info_buttons[i]:SetTextFocusColour(1,0,0,1)
		if (type(v) == "table") then
			info_buttons[i].image:SetTint(0,0.8,0.8,1)
			info_buttons[i]:SetText(tostring(i))
			info_buttons[i]:SetOnClick(function() 
				info_names.last = info_names.last + 1
				info_names[info_names.last] = tostring(i)
				InfoTable(inst, v, info, false) 
			end)
		else
			info_buttons[i]:SetText("["..tostring(i).."]\n"..tostring(v))
		end
		col = col + 1
		if (col == 10) then
			row = row + 1
			col = 0
		end
	end
end

local function EquipItem(index)
	if (actual_item[index]) then
		local equiped_item
		if (index == 7) then
			equiped_item = Player().components.inventory:GetEquippedItem("hands")
			if (not equiped_item or equiped_item.prefab ~= actual_item[index].prefab) then
				equiped_item = Player().components.inventory:GetEquippedItem("head")
			end
		elseif (index == 8) then
			equiped_item = Player().components.inventory:GetEquippedItem("body")
		elseif (index == 9) then
			equiped_item = Player().components.inventory:GetEquippedItem("head")
		else
			equiped_item = Player().components.inventory:GetEquippedItem("hands")
		end
		if (not equiped_item or actual_item[index].prefab ~= equiped_item.prefab) then
			--Player().components.inventory:UseItemFromInvTile(actual_item[index])
			Player().components.inventory:Equip(actual_item[index],nil)
		elseif (actual_item[index].prefab == equiped_item.prefab) then
			local active_item = Player().components.inventory:GetActiveItem()
			if (not(index == 8 and active_item and active_item.prefab == "torch")) then
				Player().components.inventory:UseItemFromInvTile(equiped_item)
			end
		end
	end
end

local function IsInGroup(item,group)
	if (item) then
		for i,v in pairs(group) do
			if (v == item.prefab) then
				return true
			end
		end
	end
	return false
end

local function CompareItems(item1,item2)
	if (not item1 and item2) then
		return item2
	elseif (not item2 and item1) then
		return item1
	elseif (not item1 and not item2) then
		return nil
	end
	
	local uses1, uses2
	if (item1.components.inventoryitem.inst.components.finiteuses) then
		uses1 = item1.components.inventoryitem.inst.components.finiteuses:GetPercent()
	end
	if (item2.components.inventoryitem.inst.components.finiteuses) then
		uses2 = item2.components.inventoryitem.inst.components.finiteuses:GetPercent()
	end
	
	if (not uses1 and not uses2) then
		if (item1.components.inventoryitem.inst.components.fueled) then
			uses1 = item1.components.inventoryitem.inst.components.fueled:GetPercent()
		end
		if (item2.components.inventoryitem.inst.components.fueled) then
			uses2 = item2.components.inventoryitem.inst.components.fueled:GetPercent()
		end
	end
	
	if (not uses1 and not uses2) then
		if (item1.components.inventoryitem.inst.components.armor) then
			uses1 = item1.components.inventoryitem.inst.components.armor:GetPercent()
		end
		if (item2.components.inventoryitem.inst.components.armor) then
			uses2 = item2.components.inventoryitem.inst.components.armor:GetPercent()
		end
	end
	
	if (not uses1 and uses2) then
		return item2
	elseif (not uses2 and uses1) then
		return item1
	elseif (not uses1 and not uses2) then
		return nil
	end
		
	--print("COMPARE USES","1:",uses1,"2:",uses2)
	
	if (uses1 > uses2) then
		return item2
	elseif (uses2 > uses1) then
		return item1
	else
		return nil
	end
end

local function GetBestItem(item1,item2,group)
	if (not item1 and item2) then
		return item2
	elseif (not item2 and item1) then
		return item1
	elseif (not item1 and not item2) then
		return nil
	else
		local prefitem1, prefitem2
		for i,v in pairs(group) do
			if (v == item1.prefab) then
				prefitem1 = i
			end
			if (v == item2.prefab) then
				prefitem2 = i
			end
		end
		if (prefitem1 < prefitem2) then
			return item1
		elseif (prefitem1 > prefitem2) then
			return item2
		else
			local winner_item = CompareItems(item1,item2)
			if (winner_item) then
				return winner_item
			else
				return item1
			end
		end
	end
end

local function GetBestItemNoGroup(item1,item2)
	if (not item1 and item2) then
		return item2
	elseif (not item2 and item1) then
		return item1
	elseif (not item1 and not item2) then
		return nil
	else
		local winner_item = CompareItems(item1,item2)
		if (winner_item) then
			return winner_item
		else
			return item1
		end
	end
end

local function ChangeButtonIcon(index,item)
	if (item) then
		if (icon_button[index] and button[index]) then 
			button[index]:RemoveChild(icon_button[index])
			icon_button[index]:Kill()
			
			icon_button[index] = Image(item.components.inventoryitem:GetAtlas(),item.components.inventoryitem:GetImage())
			icon_button[index]:SetScale(0.8,0.8,0.8)
			button[index]:AddChild(icon_button[index])
			
			if (DISABLE_BUTTONS) then
				button[index]:Hide()
				icon_button[index]:Hide()
			end
		end
		if (letter[index]) then
			letter[index]:MoveToFront()
			
			if (DISABLE_BUTTONS) then
				letter[index]:Hide()
			end
		end
	end
end

local function CheckButtonItem(item)
	if (item.prefab == "multitool_axe_pickaxe" or item.prefab == "multitool") then
		actual_item[2] = GetBestItem(actual_item[2],item,axes)
		ChangeButtonIcon(2,actual_item[2])
		actual_item[3] = GetBestItem(actual_item[3],item,pickaxes)
		ChangeButtonIcon(3,actual_item[3])
	elseif (IsInGroup(item,axes)) then
		actual_item[2] = GetBestItem(actual_item[2],item,axes)
		ChangeButtonIcon(2,actual_item[2])
	elseif (IsInGroup(item,machetes)) then
		actual_item[11] = GetBestItem(actual_item[11],item,machetes)
		ChangeButtonIcon(11,actual_item[11])
	elseif (IsInGroup(item,scythes)) then
		actual_item[12] = GetBestItem(actual_item[12],item,scythes)
		ChangeButtonIcon(12,actual_item[12])
	elseif (IsInGroup(item,pickaxes)) then
		actual_item[3] = GetBestItem(actual_item[3],item,pickaxes)
		ChangeButtonIcon(3,actual_item[3])
	elseif (IsInGroup(item,shovels)) then
		actual_item[4] = GetBestItem(actual_item[4],item,shovels)
		ChangeButtonIcon(4,actual_item[4])
	elseif (item.prefab == "hammer") then
		actual_item[5] = GetBestItemNoGroup(actual_item[5],item)
		ChangeButtonIcon(5,actual_item[5])
	elseif (item.prefab == "pitchfork") then
		actual_item[6] = GetBestItemNoGroup(actual_item[6],item)
		ChangeButtonIcon(6,actual_item[6])
	elseif (IsInGroup(item,lights)) then
		actual_item[7] = GetBestItem(actual_item[7],item,lights)
		ChangeButtonIcon(7,actual_item[7])
	elseif (item.prefab == "cane") then
		actual_item[10] = GetBestItemNoGroup(actual_item[10],item)
		ChangeButtonIcon(10,actual_item[10])
	elseif (IsInGroup(item,weapons)) then
		actual_item[1] = GetBestItem(actual_item[1],item,weapons)
		ChangeButtonIcon(1,actual_item[1])
	elseif (IsInGroup(item,armors)) then
		actual_item[8] = GetBestItem(actual_item[8],item,armors)
		ChangeButtonIcon(8,actual_item[8])
	elseif (IsInGroup(item,helmets)) then
		actual_item[9] = GetBestItem(actual_item[9],item,helmets)
		ChangeButtonIcon(9,actual_item[9])
	end
end

local function ClearButtonItem(index)
	actual_item[index] = nil
	if (icon_button[index] and button[index]) then 
		button[index]:RemoveChild(icon_button[index])
		icon_button[index]:Kill()
		
		if (default_icon[index]) then
			if (SUPPORT_SCYTHES and index == 12) then
				icon_button[index] = Image("images/inventoryimages/scythe.xml",default_icon[index]..".tex")
			else
				icon_button[index] = Image("images/inventoryimages.xml",default_icon[index]..".tex")
			end
		else
			icon_button[index] = Image("images/inventoryimages.xml","spear.tex")
		end
		icon_button[index]:SetScale(0.8,0.8,0.8)
		icon_button[index]:SetTint(0,0,0,0.7)
		button[index]:AddChild(icon_button[index])
		letter[index]:MoveToFront()
		
		if (DISABLE_BUTTONS) then
			button[index]:Hide()
			icon_button[index]:Hide()
			letter[index]:Hide()
		end
	end
end

local function ClearAllButtonItem()
	for i=1, cantButtons do
		ClearButtonItem(i)
	end
end

local function CheckAllButtonItem()
	if (finish_init) then
		ClearAllButtonItem()
		for i,v in pairs(Player().components.inventory:FindItems(function(inst) return true end)) do
			CheckButtonItem(v)
		end
		for i,v in pairs(Player().components.inventory.equipslots) do
			CheckButtonItem(v)
		end
		if (Player().components.inventory:GetActiveItem()) then
			CheckButtonItem(Player().components.inventory:GetActiveItem())
		end
		if (shipwrecked_world and Player().components.driver.vehicle) then
			for i,v in pairs(Player().components.driver.vehicle.components.container:FindItems(function(inst) return true end)) do
				CheckButtonItem(v)
			end
		end
	end
end

local function ContainerEvents(self)
	--CONTAINER ITEM GET EVENT--
	self.inst:ListenForEvent("itemget", function(inst, data)
		--print("CONTAINER ITEMGET")
		if (finish_init and self.opener == Player()) then
			--print("CONTAINER TYPE",self.type)
			if (self.type == "pack" or (self.type == "boat" and Player().components.driver.vehicle)) then
				if (not IsInGroup(data.item,backpacks)) then
					CheckButtonItem(data.item)
				end
			end
		end
	end)
	--CONTAINER ITEM LOSE EVENT--
	self.inst:ListenForEvent("itemlose", function(inst, data)
		--print("CONTAINER ITEMLOSE")
		if (finish_init and self.opener == Player()) then
			--print("CONTAINER TYPE",self.type)
			if (self.type == "pack" or (self.type == "boat" and Player().components.driver.vehicle)) then
				CheckAllButtonItem()
			end
		end
	end)
	--CONTAINER OPEN EVENT--
	self.inst:ListenForEvent("onopen", function(inst, data)
		--print("CONTAINER OPEN")
		if (self.type == "boat" and self.opener == Player()) then
			if (shipwrecked_world and Player().components.driver.vehicle) then
				--print("BOATCONTAINEROPEN ON MOUNT")
				CheckAllButtonItem()
			end
		end
	end)
	--CONTAINER CLOSE EVENT--
	self.inst:ListenForEvent("onclose", function(inst, data)
		--print("CONTAINER CLOSE")
		if (self.type == "boat" and self.opener == Player()) then
			if (shipwrecked_world and Player().components.driver.vehicle) then
				--print("BOATCONTAINERCLOSE ON DISMOUNT")
				CheckAllButtonItem()
			end
		end
	end)
end
AddComponentPostInit("container", ContainerEvents)

local function InventoryEvents(inst)
	--NEW ACTIVE ITEM EVENT--
	inst:ListenForEvent("newactiveitem", function(inst, data)
		--print("NEWACTIVEITEM",data.item)
		if (finish_init) then
			if (data.item) then
				if (not IsInGroup(data.item,backpacks)) then
					CheckButtonItem(data.item)
				end
			end
		end
	end)
	--ITEM GET EVENT--
	inst:ListenForEvent("itemget", function(inst, data)
		--print("ITEMGET",data.item)
		if (finish_init) then
			if (not IsInGroup(data.item,backpacks)) then
				CheckButtonItem(data.item)
			end
		end
	end)
	--EQUIP EVENT--
	inst:ListenForEvent("equip", function(inst, data)
		--print("EQUIP",data.item)
		if (finish_init) then
			if (not IsInGroup(data.item,backpacks)) then
				CheckButtonItem(data.item)
			end
		end
	end)
	--UNEQUIP EVENT--
	inst:ListenForEvent("unequip", function(inst, data)
		--print("UNEQUIP",data.item)
		CheckAllButtonItem()
	end)
	--DROP ITEM EVENT--
	inst:ListenForEvent("dropitem", function(inst, data)
		--print("DROPITEM")
		CheckAllButtonItem()
	end)
	--ITEM LOSE EVENT--
	inst:ListenForEvent("itemlose", function(inst, data)
		--print("ITEMLOSE")
		CheckAllButtonItem()
	end)
	--CONTAINER EQUIPED EVENT--
	inst:ListenForEvent("setoverflow", function(inst, data)
		--print("SETOVERFLOW")
		CheckAllButtonItem()
	end)
end

local function LoadBasicInterface()
	if (finish_init) then
		for i=1, cantButtons do
			if (button[i]) then
				button[i]:UpdatePosition(original_button_pos[i][1],original_button_pos[i][2])
				button[i].o_pos = nil
			end
		end
		if (not DISABLE_BUTTONS) then
			tools_back:Show()
			equip_back:Show()
			boat_back:Hide()
		end
	end
end

local function LoadBoatInterface()
	if (finish_init) then
		for i=1, cantButtons do
			if (button[i]) then
				button[i]:UpdatePosition(boat_button_pos[i][1],boat_button_pos[i][2])
				button[i].o_pos = nil
			end
		end
		if (not DISABLE_BUTTONS) then
			tools_back:Hide()
			equip_back:Hide()
			boat_back:Show()
		end
	end
end

local function BoatEvents(inst)
	--ON MOUNT BOAT--
	inst:ListenForEvent("mountboat", function(inst, data)
		--print("MOUNTED ON BOAT")
		LoadBoatInterface()
	end)
	--ON DISMOUNT BOAT--
	inst:ListenForEvent("dismountboat", function(inst, data)
		--print("DISMOUNTED OF BOAT")
		LoadBasicInterface()
	end)
end

local function AddKeybindButton(self,index)
	button[index] = self:AddChild(ImageButton("images/hud.xml","inv_slot_spoiled.tex","inv_slot.tex","inv_slot_spoiled.tex","inv_slot_spoiled.tex","inv_slot_spoiled.tex"))
	
	local x
	local xBoat
	if (shipwrecked_world) then
		if (SUPPORT_SCYTHES) then
			if (button_side_boat_scythe[index] == 0) then
				x = 68*(button_order_boat_scythe[index]-5)-30+offset_archery
				xBoat = 68*(button_order_boat_scythe[index]-11)-70-50
			elseif (button_side_boat_scythe[index] == 1) then
				x = 68*button_order_boat_scythe[index]+425-(12*(4-button_order_boat_scythe[index]))+offset_archery
				xBoat = 68*(button_order_boat_scythe[index]-11+8)-70-50
			end
		else
			if (button_side_boat[index] == 0) then
				x = 68*(button_order_boat[index]-5)+offset_archery
				xBoat = 68*(button_order_boat[index]-11)-50
			elseif (button_side_boat[index] == 1) then
				x = 68*button_order_boat[index]+425-(12*(4-button_order_boat[index]))+offset_archery
				xBoat = 68*(button_order_boat[index]-11+7)-50
			end
		end
	elseif (hamlet_enabled) then
		if (SUPPORT_SCYTHES) then
			if (button_side_boat_scythe[index] == 0) then
				x = 68*(button_order_boat_scythe[index]-5)-30+offset_archery
				xBoat = 68*(button_order_boat_scythe[index]-11)-70-50
			elseif (button_side_boat_scythe[index] == 1) then
				x = 68*button_order_boat_scythe[index]+425-(12*(4-button_order_boat_scythe[index]))+offset_archery
				xBoat = 68*(button_order_boat_scythe[index]-11+8)-70-50
			end
		else
			if (button_side_boat[index] == 0) then
				x = 68*(button_order_boat[index]-5)+offset_archery
				xBoat = 68*(button_order_boat[index]-11)-50
			elseif (button_side_boat[index] == 1) then
				x = 68*button_order_boat[index]+425-(12*(4-button_order_boat[index]))+offset_archery
				xBoat = 68*(button_order_boat[index]-11+7)-50
			end
		end
	else
		if (SUPPORT_SCYTHES) then
			if (button_side_scythe[index] == 0) then
				x = 68*(button_order_scythe[index]-5)+offset_archery
			elseif (button_side_scythe[index] == 1) then
				x = 68*button_order_scythe[index]+425-(12*(4-button_order_scythe[index]))+offset_archery
			end
		else
			if (button_side[index] == 0) then
				x = 68*(button_order[index]-4)+offset_archery
			elseif (button_side[index] == 1) then
				x = 68*button_order[index]+425-(12*(4-button_order[index]))+offset_archery
			end
		end
		xBoat = x
	end
	
	button[index]:SetPosition(x,160+(67*VERTICAL_OFFSET),0)
	button[index]:SetOnClick(function(inst) return EquipItem(index) end)
	button[index]:MoveToFront()
	
	
	original_button_pos[index] = {x,160+(67*VERTICAL_OFFSET)}
	boat_button_pos[index] = {xBoat,160+(67*VERTICAL_OFFSET)}
	
	if (default_icon[index]) then
		if (SUPPORT_SCYTHES and index == 12) then
			icon_button[index] = Image("images/inventoryimages/scythe.xml",default_icon[index]..".tex")
		else
			icon_button[index] = Image("images/inventoryimages.xml",default_icon[index]..".tex")
		end
	else
		icon_button[index] = Image("images/inventoryimages.xml","spear.tex")
	end
	icon_button[index]:SetScale(0.8,0.8,0.8)
	icon_button[index]:SetTint(0,0,0,0.7)
	button[index]:AddChild(icon_button[index])
	
	letter[index] = button[index]:AddChild(Button())
	if (LETTERS and KEYS[index] ~= false) then
		letter[index]:SetText(KEYS[index])
	end
	letter[index]:SetPosition(5,0,0)
	letter[index]:SetFont("stint-ucr")
	letter[index]:SetTextColour(1,1,1,1)
	letter[index]:SetTextFocusColour(1,1,1,1)
	letter[index]:SetTextSize(40)
	letter[index]:Disable()
	letter[index]:MoveToFront()
	
	if (DISABLE_BUTTONS) then
		button[index]:Hide()
		icon_button[index]:Hide()
		letter[index]:Hide()
	end
end

local function InitKeybindButtons(self)
	shipwrecked_world = (World().prefab == "shipwrecked")
	porkland_world = (World().prefab == "porkland")
	hamlet_world = (World().prefab == "hamlet")
	
	--print("SHIPWRECKED WORLD", shipwrecked_world)
	print("PORKLAND WORLD", porkland_world)
	print("HAMLET WORLD", hamlet_world)
	print("HAMLET ENABLED", hamlet_enabled)

	local xml_boatback = "images/boat_back.xml"
	local xml_basicback = "images/basic_back.xml"

	local tex_toolsback = "tools_back.tex"
	local tex_toolsbackbig = "tools_back_big.tex"
	local tex_toolsbackship = "tools_back_ship.tex"
	local tex_equipback = "equip_back.tex"
	local tex_boatbackbig = "boat_back_big.tex"
	local tex_boatback = "boat_back.tex"
	
	if (shipwrecked_world) then
		if (SUPPORT_SCYTHES) then
			tools_back = self:AddChild(Image(xml_boatback, tex_toolsbackbig))
			tools_back:SetPosition(-67+offset_archery,170+(67*VERTICAL_OFFSET),0)
		else
			tools_back = self:AddChild(Image(xml_basicback, tex_toolsbackship))
			tools_back:SetPosition(-67+offset_archery,170+(67*VERTICAL_OFFSET),0)
		end
	elseif (hamlet_enabled) then
		if (SUPPORT_SCYTHES) then
			tools_back = self:AddChild(Image(xml_basicback, tex_toolsbackbig))
			tools_back:SetPosition(-67+offset_archery,170+(67*VERTICAL_OFFSET),0)
		else
			tools_back = self:AddChild(Image(xml_basicback, tex_toolsbackship))
			tools_back:SetPosition(-67+offset_archery,170+(67*VERTICAL_OFFSET),0)
		end
	elseif (SUPPORT_SCYTHES) then
		tools_back = self:AddChild(Image(xml_basicback, tex_toolsbackship))
		tools_back:SetPosition(-67+offset_archery,170+(67*VERTICAL_OFFSET),0)
	else 
		tools_back = self:AddChild(Image(xml_basicback, tex_toolsback))
		tools_back:SetPosition(-34+offset_archery,170+(67*VERTICAL_OFFSET),0)
	end
	
	tools_back:MoveToBack()
	tools_back:Hide()
	
	equip_back = self:AddChild(Image(xml_basicback, tex_equipback))
	equip_back:SetPosition(460+158-42+offset_archery,170+(67*VERTICAL_OFFSET),0)
	equip_back:MoveToBack()
	equip_back:Hide()
	if (SUPPORT_SCYTHES) then
		boat_back = self:AddChild(Image(xml_boatback, tex_boatbackbig))
		boat_back:SetPosition(-378-50,170+(67*VERTICAL_OFFSET),0)
	else
		boat_back = self:AddChild(Image(xml_boatback, tex_boatback))
		boat_back:SetPosition(-378-10,170+(67*VERTICAL_OFFSET),0)
	end
	--boat_back:MoveToBack()
	boat_back:Hide()
	
	for i=1, cantButtons do
		icon_button[i] = nil
		actual_item[i] = nil
	end
	AddKeybindButton(self,1)
	AddKeybindButton(self,2)
	AddKeybindButton(self,3)
	AddKeybindButton(self,4)
	AddKeybindButton(self,5)
	AddKeybindButton(self,6)
	AddKeybindButton(self,7)
	AddKeybindButton(self,8)
	AddKeybindButton(self,9)
	AddKeybindButton(self,10)
	if (shipwrecked_world or hamlet_enabled) then
		AddKeybindButton(self,11)
	end
	if (SUPPORT_SCYTHES) then
		AddKeybindButton(self,12)
	end
	
	finish_init = true
end
AddClassPostConstruct("widgets/inventorybar", InitKeybindButtons)

local function Init(inst)
	inst:DoTaskInTime(0.1,function()
		
		InventoryEvents(inst)
		
		if (shipwrecked_world) then
			BoatEvents(inst)
		end
		
		if (shipwrecked_world and Player().components.driver.vehicle) then
			LoadBoatInterface()
		else
			LoadBasicInterface()
		end
		
		CheckAllButtonItem()
	end)
end
AddPlayerPostInit(Init)

local function IsDefaultScreen()
	if GLOBAL.TheFrontEnd:GetActiveScreen() and GLOBAL.TheFrontEnd:GetActiveScreen().name and type(GLOBAL.TheFrontEnd:GetActiveScreen().name) == "string" and GLOBAL.TheFrontEnd:GetActiveScreen().name == "HUD" then
		return true
	else
		return false
	end
end

if (not DISABLE_KEYS) then
	for i,key in pairs(KEYS) do
		if (key ~= false) then
			GLOBAL.TheInput:AddKeyUpHandler(
				key:lower():byte(), 
				function()
					if not GLOBAL.IsPaused() and IsDefaultScreen() then
						EquipItem(i)
					end
				end
			)
		end
	end
end

if (KEY_REFRESH ~= false) then
	GLOBAL.TheInput:AddKeyUpHandler(
		KEY_REFRESH:lower():byte(), 
		function()
			if not GLOBAL.IsPaused() and IsDefaultScreen() then
				CheckAllButtonItem()
			end
		end
	)
end

--[[
local info_flag = false
GLOBAL.TheInput:AddKeyUpHandler(
	289, 
	function()
		if not GLOBAL.IsPaused() and IsDefaultScreen() then
			if (not info_flag) then
				InfoTable(Player(),Player(),nil,true)
				info_flag = true
			else
				ClearInfoTable()
				info_flag = false
			end
		end
	end
)
]]--
