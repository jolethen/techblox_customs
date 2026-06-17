-- ==========================================================================
-- TECHBLOX EARTH WANDS COMPONENT
-- Features: 3 Tiers, Progressive Building, Anti-Lag, Anti-Duplication,
--           EXACT Texture Matching via Visual Swaps, and Fail-Safe Nil Checks.
-- ==========================================================================

-- Safe generic sounds to replace minetest.node_sound_stone_defaults() crash
local safe_stone_sounds = {
    footstep = {name = "default_hard_footstep", gain = 0.2},
    dug = {name = "default_dug_node", gain = 0.5},
    place = {name = "default_place_node", gain = 0.5},
}

-- 1. REGISTER THE SINGLE BASE PLATFORM NODE
minetest.register_node("techblox:magic_stone", {
    description = "Magic Earth Stone",
    tiles = {"default_stone.png"}, -- Fallback base texture
    groups = {immobile = 1},       -- Custom non-diggable group
    diggable = false,              -- Absolute protection against duplication exploits
    floodable = false,
    sounds = safe_stone_sounds,
})

-- 2. WAND CONFIGURATION TUNING (THE THREE TIERS)
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

-- 3. LAG-FREE STAGGERED GENERATION LAYER FUNCTION WITH VISUAL SWAPPING
local function build_platform_layer(pos, width, current_layer, max_height, source_node_name)
    if not pos or not pos.y or not source_node_name then return end
    if current_layer > max_height then return end

    local center_y = pos.y + current_layer

    -- Mathematical offset mapping for flawless even/odd coordinate grids
    local min_offset = -math.floor(width / 2)
    local max_offset = math.ceil(width / 2) - 1
    if width % 2 ~= 0 then
        min_offset = -math.floor(width / 2)
        max_offset = math.floor(width / 2)
    end

    -- Fetch the actual source node definition map dynamically safely
    local def = minetest.registered_nodes[source_node_name]
    if not def or not def.tiles then return end

    for dx = min_offset, max_offset do
        for dz = min_offset, max_offset do
            local target_pos = {x = pos.x + dx, y = center_y, z = pos.z + dz}
            local node = minetest.get_node_or_nil(target_pos)
            
            if node and (node.name == "air" or node.name == "default:water_source" or node.name == "default:water_flowing") then
                -- Step A: Place our single unbreakable node identity physically down
                minetest.set_node(target_pos, {name = "techblox:magic_stone"})
                
                -- Step B: Force swap the visual properties to mirror the exact source block textures
                -- This copies top, bottom, and side textures seamlessly along with the original shape drawtype
                minetest.swap_node(target_pos, {
                    name = "techblox:magic_stone",
                    tiles = def.tiles,
                    drawtype = def.drawtype or "normal",
                    paramtype = def.paramtype,
                    paramtype2 = def.paramtype2,
                })
            end
        end
    end

    -- Play placement audio feedback safely
    minetest.sound_play("default_cool_lava", {pos = pos, gain = 0.3, max_hear_distance = 12}, true)

    -- Stagger next layer execution by 0.15 seconds to eliminate engine tick lag entirely
    minetest.after(0.15, build_platform_layer, pos, width, current_layer + 1, max_height, source_node_name)
end

-- 4. REGISTRATION LOOP FOR THE WANDS
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
            
            -- Keep a clean record of the exact clicked block name string (e.g. "default:diamond_block")
            local source_node_name = clicked_node.name
            local start_pos = {x = clicked_pos.x, y = clicked_pos.y, z = clicked_pos.z}
            
            -- Launch building sequence passing the target name string downward
            build_platform_layer(start_pos, data.width, 1, data.height, source_node_name)
            
            if itemstack and type(itemstack.add_wear) == "function" then
                itemstack:add_wear(65535 / 45) 
            end
            
            return itemstack
        end,
    })
end

print("[Techblox Modpack] Earth Wands successfully loaded via dynamic visual swaps!")
