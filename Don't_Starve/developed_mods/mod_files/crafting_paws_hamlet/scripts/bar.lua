local Widget = require "widgets/widget"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"

local PawsBar = Class(Widget,
 function(self)
    Widget._ctor(self, "Paws Bar")

    -- Defaults
    local bar_x = -(1.5 * paws.setting.icon_width)
    local bar_y = 70 + (1.5 * paws.setting.icon_height) -- (70 is the y position of MapControls)
    self.orientation = 2

    if ( paws.setting.bar_x ) then bar_x = paws.setting.bar_x end
    if ( paws.setting.bar_y ) then bar_y = paws.setting.bar_y end
    if ( paws.setting.bar_orientation ) then self.orientation = paws.setting.bar_orientation end

    self:SetPosition(bar_x, bar_y)
 end)

function PawsBar:Expand()
    if self.task_collapse then
        self.task_collapse:Cancel()
        self.task_collapse = nil
    end
    self.ImageBG:Show()
    self.BtnCrafting:Show()
    self.BtnControllerCrafting:Show()
    self.BtnPlacement:Show()
end

function PawsBar:Collapse()
    -- TODO fadeout and/or some cute animation
    self.BtnPlacement:Hide()
    self.BtnControllerCrafting:Hide()
    self.BtnCrafting:Hide()
    self.ImageBG:Hide()
end

-- TODO 2x2 square of icons

-- orientation options  1:left to right  2:right to left 
--                      3:top to bottom  4:bottom to top
-- (assumes bottom/right anchor)
function PawsBar:Recalculating()
    local pos = { 0, 0 }  -- position of the next button
    local index = (self.orientation <= 2) and  1 or 2  -- add to x or y?
    local add  -- how much to add to the next position
    local bg_w, bg_h = self.ImageBG:GetSize()

    index = (self.orientation <= 2) and  1 or 2
    add = (self.orientation == 1 or self.orientation == 3) and  1 or -1
    -- (setting ImageBG here rather than repeating the conditionals)
    if ( index == 1 ) then
        add = paws.setting.icon_width * add
        pos[index] = (self.orientation == 1) and  self.border or -self.border
        self.ImageBG:SetScale((4*paws.setting.icon_width + 2*self.border) / bg_w, paws.setting.icon_height / bg_h, 1)
        self.ImageBG:SetPosition(add + add/2, 0)
    else -- index == 2
        add = paws.setting.icon_height * add
        pos[index] = (self.orientation == 3) and  self.border or -self.border
        self.ImageBG:SetScale(paws.setting.icon_width / bg_w, (4*paws.setting.icon_height + 2*self.border) / bg_h, 1)
        self.ImageBG:SetPosition(0, add + add/2)
    end

-- o_pos is used internally by Button and not cleared like it should be
self.BtnMain.o_pos = nil
    self.BtnMain:SetPosition(pos[1], pos[2])

self.BtnCrafting.o_pos = nil
    pos[index] = pos[index] + add
    self.BtnCrafting:SetPosition(pos[1], pos[2])

self.BtnControllerCrafting.o_pos = nil
    pos[index] = pos[index] + add
    self.BtnControllerCrafting:SetPosition(pos[1], pos[2])

self.BtnPlacement.o_pos = nil
    pos[index] = pos[index] + add
    self.BtnPlacement:SetPosition(pos[1], pos[2])
end

function PawsBar:CheckSettings()
    self.BtnCrafting.CheckSetting()
    self.BtnControllerCrafting.CheckSetting()
    self.BtnPlacement.CheckSetting()
end

-- As far as I can tell this logic is correct but Don't Starve's proportional scaling is wrong.  After window resizing the position of widgets are wrong the greater distance from the origin.  (including base game widgets)

-- Convert screen position to a (hopefully) bottom-right scaled position.  ..Does the game not have this function?
-- TODO generalize for the parent root widget
local function SetLocalPositionBR(widget, x, y)
    if type(x) == "table" then
        x, y = x.x, x.y
    end
--print("upbr x,y("..x..","..y..")")
    local scale = GetPlayer().HUD.controls.bottomright_root:GetScale()
--print("upbr scale("..scale.x..","..scale.y..")")
    local width, height = TheSim:GetScreenSize()
--print("upbr w,h("..width..","..height..")")
--print("upbr rx,ry("..(-((width - x) / scale.x))..","..(y / scale.y)..")")
    widget:SetPosition(-((width - x) / scale.x), y / scale.y, 0)
end

-- Note: Widget.FollowMouse uses direct screen position, but paws.bar is in a scaled root thing.
function PawsBar:FollerMouse(update_fn)
    if not self.followhandler then
        self.followhandler = TheInput:AddMoveHandler(function(x,y) update_fn(self, x, y) end)
        local x, y, _ = TheInput:GetScreenPosition()
        update_fn(self, x, y)
    end
end

function PawsBar:StopFolleringMouse()
    if self.followhandler then
        self.followhandler:Remove()
        self.followhandler = nil
    end
end

--------------------------------------------------------------------------------

local PawsButton = Class(ImageButton,
 function(self, atlas, normal, focus, disabled)
    ImageButton._ctor(self, atlas, normal, focus, disabled)
    self.name = "Paws Button"

    --self.image:ScaleToSize(paws.setting.icon_width, paws.setting.icon_height);
    local w, h = self:GetSize()
    self:SetScale(paws.setting.icon_width / w * paws.setting.icon_scale, paws.setting.icon_height / h * paws.setting.icon_scale, 1)
 end)

function PawsButton:CheckTint(enabled)
    if enabled then
        self.image:SetTint(1, 1, 1, 1)
    else
        self.image:SetTint(.33, .33, .33, 1)
    end
end

function PawsButton:OnGainFocus()
    PawsButton._base.OnGainFocus(self)

    paws.bar:Expand()
end

function PawsButton:OnLoseFocus()
    PawsButton._base.OnLoseFocus(self)

    if not paws.bar.followhandler then
        paws.bar.task_collapse = self.inst:DoTaskInTime(5,
            function()
                paws.bar:Collapse()
                paws.bar.task_collapse = nil
            end)
    end
end

--------------------------------------------------------------------------------

local PawsIcon = Class(PawsButton,
 function(self)
    PawsButton._ctor(self, "images/smallpaw.xml", "smallpaw.tex")
    self.name = "Paws Icon"
 end)

-- FIXME  remove the paws.bar.XXX refs and step through children instead

-- TODO see if CONTROL_CANCEL can be used to go back to the original position
function PawsIcon:OnControl(control, down)
    if down and control == CONTROL_ACCEPT then
        if paws.bar.followhandler then
            paws.bar:StopFolleringMouse()
            return true
        elseif TheInput:IsControlPressed(CONTROL_FORCE_STACK) then
            paws.bar:FollerMouse(SetLocalPositionBR)
            return true
        end
    elseif down and control == CONTROL_SECONDARY then
        paws.bar.orientation = (paws.bar.orientation >= 4) and
                               1 or paws.bar.orientation + 1
        paws.bar:Recalculating()
    end
    return ImageButton.OnControl(self, control, down)
end

--------------------------------------------------------------------------------

return function(env)
    env.AddSimPostInit(function(player)
--        Initialize()
        paws.bar = player.HUD.controls.bottomright_root:AddChild(PawsBar())

    --- Main icon button
        paws.bar.BtnMain = paws.bar:AddChild(PawsIcon())
        paws.bar.BtnMain:SetOnClick(function() TheFrontEnd:PushScreen(paws.Screen()) end)

    --- Crafting toggle
        paws.bar.BtnCrafting = paws.bar:AddChild(PawsButton("images/mouseicon1.xml", "mouseicon1.tex"))
        paws.bar.BtnCrafting.CheckSetting =
            function() paws.bar.BtnCrafting:CheckTint(paws.setting.mousecraft) end
        paws.bar.BtnCrafting:SetOnClick(
            function() paws.setting.mousecraft = not paws.setting.mousecraft
                       paws.bar.BtnCrafting:CheckSetting() end)

    --- Controller crafting toggle
        paws.bar.BtnControllerCrafting = paws.bar:AddChild(PawsButton("images/controlicon.xml", "controlicon.tex"))
        paws.bar.BtnControllerCrafting.CheckSetting =
            function() paws.bar.BtnControllerCrafting:CheckTint(paws.setting.controllercraft) end
        paws.bar.BtnControllerCrafting:SetOnClick(
            function() paws.setting.controllercraft = not paws.setting.controllercraft
                       paws.bar.BtnControllerCrafting:CheckSetting() end)

    --- Placement toggle
        paws.bar.BtnPlacement = paws.bar:AddChild(PawsButton("images/placeicon.xml", "placeicon.tex"))
        paws.bar.BtnPlacement.CheckSetting =
            function() paws.bar.BtnPlacement:CheckTint(paws.setting.placement) end
        paws.bar.BtnPlacement:SetOnClick(
            function() paws.setting.placement = not paws.setting.placement
                       paws.bar.BtnPlacement:CheckSetting() end)

    --- Background image of bar
        paws.bar.ImageBG = paws.bar:AddChild(Image("images/hud.xml", "craft_slot.tex"))
        paws.bar.border = 5  -- seems to work about right for craft_slot
        -- inv_slot.tex is also a good option for this
        paws.bar.ImageBG:SetTint(1,1,1, 0.66)
        paws.bar.ImageBG:MoveToBack()
        paws.bar.ImageBG:SetClickable(false)

        paws.bar:CheckSettings()
        paws.bar:Recalculating()
    end)  -- AddSimPostInit
end

