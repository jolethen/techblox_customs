-- ==========================================================================
-- TECHBLOX EARTH WANDS COMPONENT
-- Features: 3 Tiers, Progressive Building, Anti-Lag, Anti-Duplication,
--           EXACT Texture Matching (Dynamic Node Facades), Fail-Safe Nil Checks.
-- ==========================================================================

-- Safe generic sounds to replace minetest.node_sound_stone_defaults() crash
local safe_stone_sounds = {
    footstep = {name = "default_hard_footstep", gain = 0.2},
    dug = {name = "default_dug_node", gain = 0.5},
    place = {name = "default_place_node", gain = 0.5},
}

-- 1. REGISTER THE BASE FALLBACK UNBREAKABLE PLATFORM NODE
minetest.register_node("techblox:magic_stone", {
    description = "Magic Earth Stone",
    tiles = {"default_stone.png"}, 
    groups = {immobile = 1},       
    diggable = false,              -- Absolute dupe protection
    floodable = false,
    sounds = safe_stone_sounds,
})

-- 2. DYNAMIC REGISTRY: GENERATE UNBREAKABLE CLONES OF ALL KNOWN NODES AT STARTUP
-- This maps every block texture to an unbreakable "techblox:magic_stone_..." variant.
local facade_registry = {}

minetest.register_on_mods_loaded(function()
    for node_name, def in pairs(minetest.registered_nodes) do
        if node_name ~= "air" and node_name ~= "ignore" and def.tiles then
            local facade_name = "techblox:magic_" .. node_name:gsub(":", "_")
            
            -- Clone original visuals but strip out all drops, mining groups, and diggability
            minetest.register_node(facade_name, {
                description = "Magic " .. (def.description or "Stone"),
                tiles = def.tiles, -- EXACT texture match (Top, bottom, sides all mirror perfectly)
                drawtype = def.drawtype or "normal",
                paramtype = def.paramtype,
                paramtype2 = def.paramtype2,
                groups = {immobile = 1},
                diggable = false, -- Locked down so players cannot break or dupe it
                floodable = false,
                sounds = safe_stone_sounds,
            })
            
            facade_registry[node_name] = facade_name
        end
    end
end)

-- 3. WAND CONFIGURATION TUNING (THE THREE TIERS)
local wand_tiers = {
    [1] = {
        name = "techblox:earth_wand_t1",
        description = "Techblox Earth Wand (Tier 1)",
        texture = "techblox_wand_earth_t1.png",
        width = 2,  -- 2x2 platform
        height = 5, -- Rises 5 blocks
    },
    [2] = {
        name = "techblox:earth_wand_t2",
        description = "Techblox Earth Wand (Tier 2)",
        texture = "techblox_wand_earth_t2.png",
        width = 3,  -- 3x3 platform
        height = 4, -- Rises 4 blocks
    },
    [3] = {
        name = "techblox:earth_wand_t3",
        description = "Techblox Earth Wand (Tier 3)",
        texture = "techblox_wand_earth_t3.png",
        width = 5,  -- 5x5 platform
        height = 5, -- Rises 5 blocks
    },
}

-- 4. LAG-FREE STAGGERED GENERATION LAYER FUNCTION
local function build_platform_layer(pos, width, current_layer, max_height, facade_node)
    if not pos or not pos.y then return end
    if current_layer > max_height then return end

    local center_y = pos.y + current_layer

    -- Mathematical offset mapping for flawless even/odd coordinate grids
    local min_offset = -math.floor(width / 2)
    local max_offset = math.ceil(width / 2) - 1
    if width % 2 ~= 0 then
        min_offset = -math.floor(width / 2)
        max_offset = math.floor(width / 2)
    end

    for dx = min_offset, max_offset do
        for dz = min_offset, max_offset do
            local target_pos = {x = pos.x + dx, y = center_y, z = pos.z + dz}
            local node = minetest.get_node_or_nil(target_pos)
            
            if node and (node.name == "air" or node.name == "default:water_source" or node.name == "default:water_flowing") then
                -- Places the EXACT custom texture matched facade node
                minetest.set_node(target_pos, {name = facade_node})
            end
        end
    end

    -- Play placement audio feedback safely
    minetest.sound_play("default_cool_lava", {pos = pos, gain = 0.3, max_hear_distance = 12}, true)

    -- Stagger next layer execution by 0.15 seconds to completely eliminate server tick lag
    minetest.after(0.15, build_platform_layer, pos, width, current_layer + 1, max_height, facade_node)
end

-- 5. REGISTRATION LOOP FOR THE WANDS
for tier, data in ipairs(wand_tiers) do
    minetest.register_tool(data.name, {
        description = data.description,
        inventory_image = data.texture,
        stack_max = 1,
        
        on_use = function(itemstack, user, pointed_thing)
            if not pointed_thing or pointed_thing.type ~= "node" then
                return itemstack
            end
            
            local clicked_pos = pointed_thing.under
            if not clicked_pos then return itemstack end
            
            local clicked_node = minetest.get_node_or_nil(clicked_pos)
            if not clicked_node or clicked_node.name == "ignore" then 
                return itemstack 
            end
            
            if not user or not user:is_player() then 
                return itemstack 
            end
            
            -- Find the exact facade node from our registry map, fall back to default magic stone if missing
            local facade_node = facade_registry[clicked_node.name] or "techblox:magic_stone"
            
            local start_pos = {x = clicked_pos.x, y = clicked_pos.y, z = clicked_pos.z}
            
            -- Run builder with the target texture facade
            build_platform_layer(start_pos, data.width, 1, data.height, facade_node)
            
            if itemstack and type(itemstack.add_wear) == "function" then
                itemstack:add_wear(65535 / 45) 
            end
            
            return itemstack
        end,
    })
end

print("[Techblox Modpack] Earth Wands initialized with exact texture mirroring facades!")
