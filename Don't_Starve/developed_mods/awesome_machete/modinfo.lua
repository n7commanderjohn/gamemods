-- This information tells other players more about the mod
name = "Awesome Machete! Extra Hacking"
version = "1.7"
description = [[Tired of taking forever picking your grass, reeds, spiky bushes and saplings by hand?
No worries, cut them down fast today with your trusty machete! Works with all machetes.

Version: ]]..version
author = "N7 Commander John"

-- This is the URL name of the mod's thread on the forum; the part after the index.php? and before the first & in the URL
-- Example:
-- http://forums.kleientertainment.com/index.php?/files/file/202-sample-mods/
-- becomes
-- /files/file/202-sample-mods/
forumthread = "files/file/1990-awesome-machete-extra-hacking/"

-- This lets other players know if your mod is out of date, update it to match the current version in the game
local forDST = false
if forDST then
    api_version = 10
else
    api_version = 6
end

dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = true
hamlet_compatible = true

--This lets the clients know that they need to download the mod before they can join a server that is using it.
all_clients_require_mod = false

--This let's the game know that this mod doesn't need to be listed in the server's mod listing
client_only_mod = true

--Let the mod system know that this mod is functional with Don't Starve Together
dst_compatible = true

--These tags allow the server running this mod to be found with filters from the server listing screen
server_filter_tags = {"awesome machete", "awesome", "machete"}

-- Can specify a custom icon for this mod!
icon_atlas = "machete_grass_preview.xml"
icon = "machete_grass_preview.tex"

-- local keyslist = {}
-- local string = ""

-- local FIRST_NUMBER = 48
-- for i = 1, 10 do
--   local ch = string.char(FIRST_NUMBER + i - 1)
--   keyslist[i] = {description = ch, data = ch}
-- end

-- local FIRST_LETTER = 65
-- for i = 11, 36 do
--   local ch = string.char(FIRST_LETTER + i - 11)
--   keyslist[i] = {description = ch, data = ch}
-- end

-- keyslist[37] = {description = "DISABLED / 禁用", data = false}

-- numbers = {}
-- for i = 0, 5 do
--   numbers[i+1] = {description = i, data = i}
-- end

configuration_options = {
    -- {
    --     name = "Key_Inv",
    --     label = "Place into Inventory after Hacking",
    --     default = "1",
    --     options = keyslist
    -- },
    {
        name = "Place_Inv",
        label = "Place Into Inv",
        hover = [[After hacking is completed, place the items into your inventory.
        
        ]],
        default = false,
        options = {
            {description = "NO", data = false, hover = "Items will drop on the ground as usual."},
            {description = "YES", data = true, hover = "Items will be placed directly into your inventory."}
        }
    },
}
