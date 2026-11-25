-- name: [CS] Zonic
-- description: The world's most famous hedgehog!\n\nMade by: Zam Boni\n\n\\#ff7777\\This Pack requires Character Select\nto use as a Library!

--[[
    API Documentation for Character Select can be found below:
    https://github.com/Squishy6094/character-select-coop/wiki/API-Documentation

    Use this if you're curious on how anything here works >v<
]]

-- Replace Mod Name with your Character/Pack name.
local TEXT_MOD_NAME = "Sonic"

-- Stops mod from loading if Character Select isn't on, Does not need to be touched
if not _G.charSelectExists then
    djui_popup_create("\\#ffffdc\\\n"..TEXT_MOD_NAME.."\nRequires the Character Select Mod\nto use as a Library!\n\nPlease turn on the Character Select Mod\nand Restart the Room!", 6)
    return 0
end

--[[
    Everything from here down is character data, and is loaded at the end of the file

    Note that most things here are noted out via use of '--', if there is any
    functionality you'd want to use then remove the '--' in front of the functions.

    If needbe, Replace CHAR in the tables with your character's name
    Ex: E_MODEL_CHAR -> E_MODEL_SQUISHY

    Ensure all file naming is unique from other mods.
    Prefixing your files with your character's name should work fine
    Ex: life-icon.png -> squis
]]

local E_MODEL_ZBSONIC =      smlua_model_util_get_id("zbsonic_geo")      -- Located in "actors"
local E_MODEL_ZBSONICR =      smlua_model_util_get_id("zbsonic_r_geo")
-- local E_MODEL_CHAR_STAR = smlua_model_util_get_id("custom_model_star_geo") -- Located in "actors"

local TEX_ZBSONIC_LIFE_ICON = get_texture_info("exclamation-icon") -- Located in "textures"
-- local TEX_CHAR_STAR_ICON = get_texture_info("exclamation-icon") -- Located in "textures"

-- All sound files are located in "sound" folder
-- Remember to include the file extention in the name
local VOICETABLE_ZBSONIC = {
    [CHAR_SOUND_ATTACKED] = 's-hurt.ogg',
    [CHAR_SOUND_DROWNING] = 's-die.ogg',
    [CHAR_SOUND_DYING] = 's-die.ogg',
    [CHAR_SOUND_HAHA] = 's-haha.ogg',
    [CHAR_SOUND_HAHA_2] = 's-haha.ogg',
    [CHAR_SOUND_HERE_WE_GO] = {'s-chaching.ogg', 's-emerald.ogg'},
    [CHAR_SOUND_HOOHOO] = 's-jump.ogg',
    [CHAR_SOUND_MAMA_MIA] = 's-mamamia.ogg',
    [CHAR_SOUND_ON_FIRE] = 's-hurt.ogg',
    [CHAR_SOUND_OOOF] = 's-hurt.ogg',
    [CHAR_SOUND_OOOF2] = 's-hurt.ogg',
    [CHAR_SOUND_YAHOO] = 's-longjump.ogg',
    [CHAR_SOUND_YAHOO_WAHA_YIPPEE] = 's-jump.ogg',
    [CHAR_SOUND_YAH_WAH_HOO] = 's-jump.ogg',
}

-- All Located in "actors" folder
-- (Models do not exist in template)
--[[
local CAPTABLE_CHAR = {
    normal = smlua_model_util_get_id("FILENAME_geo"),
    wing = smlua_model_util_get_id("FILENAME_geo"),
    metal = smlua_model_util_get_id("FILENAME_geo"),
}
]]

local PALETTES_ZBSONICR = {
    {
        name = "Default",
        [PANTS]  = "FF0E00",
        [SHIRT]  = "000EFF",
        [GLOVES] = "ffffff",
        [SHOES]  = "FFFFFF",
        [SKIN]   = "FFBB88",
        [CAP]    = "000EFF",
        [EMBLEM] = "FFFFFF",
    },
    {
        name = "Tails",
        [PANTS]  = "FF0E00",
        [SHIRT]  = "FF8000",
        [GLOVES] = "ffffff",
        [SHOES]  = "FFFFFF",
        [SKIN]   = "FFFFFF",
        [CAP]    = "FF8000",
        [EMBLEM] = "FFFFFF",
    },
    {
        name = "Knuckles",
        [PANTS]  = "FF1608",
        [SHIRT]  = "FF1608",
        [GLOVES] = "ffffff",
        [SHOES]  = "FF9D25",
        [SKIN]   = "A45A32",
        [CAP]    = "FF1608",
        [EMBLEM] = "58FF32",
    },
    {
        name = "Sonic 1",
        [PANTS]  = "FC0000",
        [SHIRT]  = "6C6CD8",
        [GLOVES] = "ffffff",
        [SHOES]  = "FFFFFF",
        [SKIN]   = "FCB490",
        [CAP]    = "6C6CD8",
        [EMBLEM] = "FFFFFF",
    },
    {
        name = "Master System",
        [PANTS]  = "FFAA55",
        [SHIRT]  = "5555FF",
        [GLOVES] = "ffffff",
        [SHOES]  = "FFFFFF",
        [SKIN]   = "FFAA55",
        [CAP]    = "5555FF",
        [EMBLEM] = "FFFFFF",
    },
    {
        name = "Ristar",
        [PANTS]  = "FFFFFF",
        [SHIRT]  = "242448",
        [GLOVES] = "ffffff",
        [SHOES]  = "FCB400",
        [SKIN]   = "FCB400",
        [CAP]    = "FCB400",
        [EMBLEM] = "FFFFFF",
    },
    {
        name = "Flash",
        [PANTS]  = "FF1608",
        [SHIRT]  = "FF1608",
        [GLOVES] = "FF1608",
        [SHOES]  = "FFC50F",
        [SKIN]   = "FFBB88",
        [CAP]    = "FF1608",
        [EMBLEM] = "FFC50F",
    },
    {
        name = "Gex",
        [PANTS]  = "EEFF0A",
        [SHIRT]  = "00FF3A",
        [GLOVES] = "EEFF0A",
        [SHOES]  = "8157FF",
        [SKIN]   = "EEFF0A",
        [CAP]    = "8157FF",
        [EMBLEM] = "8157FF",
    },
}

-- All Located in "textures" folder
-- (Textures do not exist in template)
--[[
local HEALTH_METER_CHAR = {
    label = {
        left = get_texture_info("healthleft"),
        right = get_texture_info("healthright"),
    },
    pie = {
        [1] = get_texture_info("Pie1"),
        [2] = get_texture_info("Pie2"),
        [3] = get_texture_info("Pie3"),
        [4] = get_texture_info("Pie4"),
        [5] = get_texture_info("Pie5"),
        [6] = get_texture_info("Pie6"),
        [7] = get_texture_info("Pie7"),
        [8] = get_texture_info("Pie8"),
    }
}
]]

--[[
    Everything from here down where the data is applied

    Note that nothing here other than the 'character_add' function
    is required for a custom character, if you don't have the assets
    then feel free to remove the function from the functions below
]]

local ANIMS_ZBSONIC = {
    ---@param m MarioState
    [CHAR_ANIM_RUNNING] = function(m)
        local e = gZonicStates[m.playerIndex]
        --m.marioBodyState.torsoAngle.x = 0
        m.marioBodyState.torsoAngle.z = 0
        e.tiltAngleAnim = lerp_s16(e.tiltAngleAnim, (e.faceAngleAnim - m.faceAngle.y)*3, 0.2)
        m.marioObj.header.gfx.angle.z = e.tiltAngleAnim
        e.faceAngleAnim = m.faceAngle.y
    end
}

-- Adds the custom character to the Character Select Menu
CT_ZBSONIC = _G.charSelect.character_add(
    "Sonic", -- Character Name
    "The mechanical nemesis of Sonic the Hedgehog has arrived in the Mushroom Kingdom, sure to cause chaos wherever he goes.", -- Description
    "Zam Boni", -- Credits
    "202080",           -- Menu Color
    E_MODEL_ZBSONIC,       -- Character Model
    CT_ZBSONIC,           -- Override Character
    TEX_ZBSONIC_LIFE_ICON, -- Life Icon
    1,                  -- Camera Scale
    0                   -- Vertical Offset
)
_G.charSelect.character_add_costume(
    CT_ZBSONIC,
    "Sonic",
    "Sonic's mechanical nemesis, but fashionable!",
    "Zam Boni",
    "202080",
    E_MODEL_ZBSONICR
)

-- Adds cap models to your character
-- (Models do not exist in template)
-- _G.charSelect.character_add_caps(E_MODEL_CHAR, CAPTABLE_CHAR)

-- Adds a voice to your character
-- (Sounds do not exist in template)
_G.charSelect.character_add_voice(E_MODEL_ZBSONIC, VOICETABLE_ZBSONIC)
_G.charSelect.character_add_voice(E_MODEL_ZBSONICR, VOICETABLE_ZBSONIC)
_G.charSelect.character_add_animations(E_MODEL_ZBSONIC, ANIMS_ZBSONIC)
_G.charSelect.character_add_animations(E_MODEL_ZBSONICR, ANIMS_ZBSONIC)

-- Adds a celebration star to your character
-- (Models do not exist in template)
--_G.charSelect.character_add_celebration_star(E_MODEL_CHAR, E_MODEL_CHAR_STAR, TEX_CHAR_STAR_ICON)

-- Adds a palette to your character
for i = 1, #PALETTES_ZBSONICR do
    _G.charSelect.character_add_palette_preset(E_MODEL_ZBSONIC, PALETTES_ZBSONICR[i], PALETTES_ZBSONICR[i].name)
    _G.charSelect.character_add_palette_preset(E_MODEL_ZBSONICR, PALETTES_ZBSONICR[i], PALETTES_ZBSONICR[i].name)
end

-- Adds a health meter to your character
-- (Textures do not exist in template)
-- _G.charSelect.character_add_health_meter(CT_CHAR, HEALTH_METER_CHAR)

-- Adds credits to the credits menu
_G.charSelect.credit_add(TEXT_MOD_NAME, "Zam Boni", "Sonic")

-- Update Model based on palette (Code by Squishy6094)
local prevPalette = 1
local function update_model()
    local palette = _G.charSelect.character_get_current_palette_number(0)
    if prevPalette ~= palette then
        _G.charSelect.character_edit_costume(CT_ZBSONIC, 1, nil, nil, nil, nil, palette == 1 and E_MODEL_ZBSONIC or E_MODEL_ZBSONICR)
        --_G.charSelect.character_edit_costume(CT_ZBWEREHOG, 1, nil, nil, nil, nil, palette == 1 and E_MODEL_ZBWEREHOGS or E_MODEL_ZBWEREHOG)
        prevPalette = palette
    end
end

hook_event(HOOK_UPDATE, update_model)