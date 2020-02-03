local _G = GLOBAL
local isDST = _G.TheSim:GetGameID() == 'DST'

--[ highlighting when active item is changed

local Highlight = _G.require 'components/highlight'
local __Highlight_ApplyColour = Highlight.ApplyColour
local __Highlight_UnHighlight = Highlight.UnHighlight

-- additional highlight of found container objects
local c = {r = 0, g = .25, b = 0}

-- this maintains colour when the game unhighlights our object
local function custom_ApplyColour(self, ...)
  local r, g, b =
  (self.base_add_colour_red   or 0),
  (self.base_add_colour_green or 0),
  (self.base_add_colour_blue  or 0)

  self.base_add_colour_red,
  self.base_add_colour_green,
  self.base_add_colour_blue =
  r + c.r, g + c.g, b + c.b

  local result = __Highlight_ApplyColour(self, ...)

  self.base_add_colour_red,
  self.base_add_colour_green,
  self.base_add_colour_blue = r, g, b

  return result
end

-- prevents removal of the whole component on UnHighlight
local function custom_UnHighlight(self, ...)
  local flashing = self.flashing
  self.flashing = true
  local result = __Highlight_UnHighlight(self, ...)
  self.flashing = flashing

  if isDST and not self.flashing then
    local r, g, b =
    (self.highlight_add_colour_red   or 0),
    (self.highlight_add_colour_green or 0),
    (self.highlight_add_colour_blue  or 0)

    self.highlight_add_colour_red,
    self.highlight_add_colour_green,
    self.highlight_add_colour_blue =
    0, 0, 0

    self:ApplyColour()

    self.highlight_add_colour_red,
    self.highlight_add_colour_green,
    self.highlight_add_colour_blue = r, g, b
  end

  return result
end

local function filter(chest, item)
  return chest.components.container and item and
         chest.components.container:Has(item, 1)
end

local function unhighlight(highlit)
  while #highlit > 0 do
    local v = table.remove(highlit)
    if v and v.components.highlight then
      -- both keys will point to their original metatable values
      -- unless they were overwritten by other mods

      if v.components.highlight.ApplyColour == custom_ApplyColour then
        v.components.highlight.ApplyColour = nil
      end

      if v.components.highlight.UnHighlight == custom_UnHighlight then
        v.components.highlight.UnHighlight = nil
      end

      v.components.highlight:UnHighlight()
    end
  end
end

local function highlight(e, highlit, filter, item)
  for k, v in pairs(e) do
    if v and v:IsValid() and v.entity:IsVisible() and filter(v, item.prefab) then
      if not v.components.highlight then
        v:AddComponent('highlight')
      end

      if v.components.highlight then
        v.components.highlight.ApplyColour = custom_ApplyColour
        v.components.highlight.UnHighlight = custom_UnHighlight
        v.components.highlight:Highlight(0, 0, 0)
        table.insert(highlit, v)
      end
    end
  end
end

local highlit = {}
local function onactiveitem(owner, data)
  unhighlight(highlit)

  if owner and data and data.item then
    local x, y, z = owner.Transform:GetWorldPosition()
    local e = _G.TheSim:FindEntities(x, y, z, 30, nil, {'NOBLOCK', 'player', 'FX'}) or {}

    highlight(e, highlit, filter, data.item)
  end
end

local function init(owner)
  if not owner then return end

  owner:ListenForEvent('newactiveitem', onactiveitem)
end

if isDST then
  -- Kam297's approach
  AddPrefabPostInit('world', function(w)
    w:ListenForEvent('playeractivated', function(w, owner)
      if owner == _G.ThePlayer then
        init(owner)
      end
    end)
  end)
else
  AddPlayerPostInit(function (owner)
    init(owner)
  end)
end
--]]

--[ highlighting when ingredient in recipepopup is hovered
local IngredientUI = _G.require 'widgets/ingredientui'
local __IngredientUI_OnGainFocus = IngredientUI.OnGainFocus
local sw_remap

function IngredientUI:OnGainFocus (...)
  local tex   = self.ing and self.ing.texture and self.ing.texture:match('[^/]+$'):gsub('%.tex$', '')
  local owner = self.parent and self.parent.parent and self.parent.parent.owner

  if tex and owner then
    if _G.SaveGameIndex and _G.SaveGameIndex.IsModeShipwrecked and
       _G.SaveGameIndex:IsModeShipwrecked() and _G.SW_ICONS then
      if not sw_remap then
        sw_remap = {}
        for i, v in pairs(_G.SW_ICONS) do
          sw_remap[v] = i
        end
      end

      if sw_remap[tex] then
        tex = sw_remap[tex]
      end
    end

    onactiveitem(owner, { item = { prefab = tex } })
  end

  if __IngredientUI_OnGainFocus then
    return __IngredientUI_OnGainFocus(self, ...)
  end
end

local TabGroup = _G.require 'widgets/tabgroup'
local __TabGroup_DeselectAll = TabGroup.DeselectAll
function TabGroup:DeselectAll(...)
  unhighlight(highlit)
  return __TabGroup_DeselectAll(self, ...)
end
--]]
