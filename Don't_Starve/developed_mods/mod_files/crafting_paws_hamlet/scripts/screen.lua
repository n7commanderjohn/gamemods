local Widget = require "widgets/widget"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local Spinner = require "widgets/spinner"
local Grid = require "widgets/grid"
local Screen = require "widgets/screen"

-- paws options screen for those that like dialogs
-- TODO  need non-mouse access to this.. some hardcoded keypress?
--       how do controllers select things?

--keep this in sync with optionsscreen.lua:22 or similar game spinners
local EnabledDisabled =
    { { text = STRINGS.UI.OPTIONS.DISABLED, data = false },
      { text = STRINGS.UI.OPTIONS.ENABLED,  data = true } }

return function(mod)

paws.Screen = Class(Screen,
  function(self)
    Screen._ctor(self, "Paws screen")

--    self.was_paused = IsPaused()
    SetPause(true, "Paws screen")

    TheInputProxy:SetCursorVisible(true)

    self:Setup()
    self.default_focus = self.grid

    self.active = true
  end
)

function paws.Screen:doClose()
    self.active = false
    TheFrontEnd:PopScreen(self)
--    if not self.was_paused then SetPause(false) end
SetPause(false);  -- probably better to assume repausing will occur?
    paws.UpdateSettings()
end

-- TODO see if this can go away safely yet
--[[
function paws.Screen:OnUpdate(dt)
    if self.active then
        SetPause(true)
    end
end
--]]
    
function paws.Screen:OnControl(control, down)
    if paws.Screen._base.OnControl(self, control, down) then return true end

    if ( not down and control == CONTROL_CANCEL ) then
        self:doClose()
        return true
    end
end

-- FIXME  positioning was haphazardly done by trial and error
-- FIXME cancel probably doesn't work right
function paws.Screen:Setup()
    self.proot = self:AddChild(Widget("Screen root"))
    self.proot:SetVAnchor(ANCHOR_MIDDLE)
    self.proot:SetHAnchor(ANCHOR_MIDDLE)
    self.proot:SetPosition(0,0,0)
    self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.bg = self.proot:AddChild(Image("images/globalpanels.xml", "small_dialog.tex"))
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetScale(1.5,1.2,1.2)

    self.title = self.proot:AddChild(Text(TITLEFONT, 50))
    self.title:SetPosition(0, 50, 0)
    self.title:SetString(paws.STRING_TITLE)

    self.grid = self.proot:AddChild(Grid())
    self.grid:InitSize(4, 2, 160, -50)
    self.grid:SetPosition(-(160*(4-1))/2, -15)

    self.mouse_text = self.grid:AddItem(Text(BUTTONFONT, 30, paws.STRING_MOUSE), 1, 1)
    self.mouse_spinner = self.grid:AddItem(Spinner(EnabledDisabled, 160), 1, 2)
    self.mouse_spinner:SetSelected(paws.setting.mousecraft)
    self.mouse_spinner:SetTextColour(0,0,0,1)  -- default seems to be white
    self.mouse_spinner:SetTooltip(paws.STRING_HELP_MOUSE)
    function self.mouse_spinner:OnChanged(data) paws.setting.mousecraft = data end

    self.controller_text = self.grid:AddItem(Text(BUTTONFONT, 30, paws.STRING_CONTROLLER), 2, 1)
    self.controller_spinner = self.grid:AddItem(Spinner(EnabledDisabled, 160), 2, 2)
    self.controller_spinner:SetSelected(paws.setting.controllercraft)
    self.controller_spinner:SetTextColour(0,0,0,1)
    self.controller_spinner:SetTooltip(paws.STRING_HELP_CONTROLLER)
    function self.controller_spinner:OnChanged(data) paws.setting.controllercraft = data end

    self.placement_text = self.grid:AddItem(Text(BUTTONFONT, 30, paws.STRING_PLACEMENT), 3, 1)
    self.placement_spinner = self.grid:AddItem(Spinner(EnabledDisabled, 160), 3, 2)
    self.placement_spinner:SetSelected(paws.setting.placement)
    self.placement_spinner:SetTextColour(0,0,0,1)
    self.placement_spinner:SetTooltip(paws.STRING_HELP_PLACEMENT)
    function self.placement_spinner:OnChanged(data) paws.setting.placement = data end

    self.close_button = self.grid:AddItem(ImageButton(), 4, 2)
--    self.close_button:SetColour( default should be fine
--    self.close_button:SetFont(BUTTONFONT
    self.close_button:SetText(STRINGS.UI.OPTIONS.CLOSE)
    self.close_button:SetOnClick(function(button) self:doClose() end)
end

end
-- vim: ts=4:sw=4:et
