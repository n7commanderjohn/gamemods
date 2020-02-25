name = "Crafting Paws (Hamlet Compatiblity)"
description = "Pause while crafting or placing items.\n"..
              "(based on Relaxed Crafting by noobler and Crafting Pause by hmaarrfk)"

author = "Dimblemace; N7 Commander John (Hamlet Compatibility)"
forumthread = ""

version = "0.9"
api_version = 6
--priority = ?

icon_atlas = "modicon.xml"
icon = "modicon.tex"

dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true
porkland_compatible = true
hamlet_compatible = true

--[[
configuration_options =
{
    {
        name = "controllercraft",
        label = "Controller crafting",
        options =
        {
            { description = "paused", data = true },
            { description = "not paused", data = false },
            { description = "unset", data = nil },
        },
        default = nil,
    },
    {
        name = "mousecraft",
        label = "Mouse crafting",
        options =
        {
            { description = "paused", data = true },
            { description = "not paused", data = false },
            { description = "unset", data = nil },
        },
        default = nil,
    },
    {
        name = "placement",
        label = "Item Placement",
        options =
        {
            { description = "paused", data = true },
            { description = "not paused", data = false },
            { description = "unset", data = nil },
        },
        default = nil,
    },
    {
        name = "collapse delay",
        label = "Seconds before the bar auto-collapses.",
        options =
        {
            however number range(s) work
        },
        default = 5,
    }
}
--]]
