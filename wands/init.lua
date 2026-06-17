-- ==========================================================================
-- TECHBLOX EARTH WANDS COMPONENT
-- Features: 3 Tiers, Progressive Building, Anti-Lag, Anti-Duplication,
--           EXACT Texture Clones, and Top-to-Bottom Staggered Despawning.
-- ==========================================================================

local safe_stone_sounds = {
    footstep = {name = "default_hard_footstep", gain = 0.2},
    dug = {name = "default_dug_node", gain = 0.5},
    place = {name = "default_place_node", gain = 0.5},
}

-- 1. BASE PLATFORM FALLBACK
minetest.register_node("techblox:magic_stone", {
    description = "Magic Earth Stone",
    tiles = {"default_stone.png"}, 
    groups = {immobile = 1, magic_wand_block = 1},       
    diggable = false,              
    floodable = false,
    sounds = safe_stone_sounds,
})

-- 2. DYNAMIC REGISTRY: FILTERED EXACT CLONE GENERATOR
-- Safely registers custom unbreakable facades for actual map blocks only
local facade_registry = {}

minetest.register_on_mods_loaded(function()
    for node_name, def in pairs(minetest.registered_nodes) do
        -- STRICT FILTER: Only clone normal solid blocks that have valid textures
        if def and type(def) == "table" and def.tiles and type(def.tiles) == "table" 
           and node_name ~= "air" and node_name ~= "ignore" 
           and not node_name:find("liquid") and not node_name:find("water") 
           and not node_name:find("lava") and not node_name:find("fire") then
            
            -- Strip out colons/symbols completely to stop prefix convention crashes
            local ultra_clean = node_name:lower():gsub("[^a-z0-9]", "")
            local facade_name = "techblox:magic_" .. ultra_clean
            
            if not minetest.registered_nodes[facade_name] then
                minetest.register_node(facade_name, {
                    description = "Magic " .. (def.description or "Block"),
                    tiles = def.tiles, -- EXACT visual match
                    drawtype = def.drawtype or "normal",
                    paramtype = def.paramtype,
                    paramtype2 = def.paramtype2,
                    groups = {immobile = 1, magic_wand_block = 1}, -- Grouped for deletion tracker
                    diggable = false, 
                    floodable = false,
                    sounds = safe_stone_sounds,
                })
                
                facade_registry[node_name] = facade_name
            end
        end
    end
end)

-- 3. WAND CONFIGURATION TUNING (THE THREE TIERS)
local wand_tiers = {
    [1] = {
        name = "techblox:earth_wand_t1",
        description = "Techblox Earth Wand (Tier 1)",
        texture = "techblox_wand_earth_t1.png",
        width = 2,  
        height = 5, 
    },
    [2] = {
        name = "techblox:earth_wand_t2",
        description = "Techblox Earth Wand (Tier 2)",
        texture = "techblox_wand_earth_t2.png",
        width = 3,  
        height = 4, 
    },
    [3] = {
        name = "techblox:earth_wand_t3",
        description = "Techblox Earth Wand (Tier 3)",
        texture = "techblox_wand_earth_t3.png",
        width = 5,  
        height = 5, 
    },
}

-- 4. REVERSE STAGGERED TOP-TO-BOTTOM DESPAWN FUNCTION
local function despawn_platform_layer(layer_map, current_layer)
    if current_layer < 1 then return end -- Done dissolving

    local blocks_to_remove = layer_map[current_layer]
    if blocks_to_remove then
        for _, pos in ipairs(blocks_to_remove) do
            local current_node = minetest.get_node(pos)
            -- Verify it's still one of our magic structure blocks before clearing
            if minetest.get_item_group(current_node.name, "magic_wand_block") > 0 then
                minetest.remove_node(pos)
            end
        end
        -- Optional: Play a quiet fading sound per layer collapse
        if #blocks_to_remove > 0 then
            minetest.sound_play("default_cool_lava", {pos = blocks_to_remove[1], gain = 0.1, max_hear_distance = 10}, true)
        end
    end

    -- Wait 0.25 seconds, then dissolve the next layer down
    minetest.after(0.25, despawn_platform_layer, layer_map, current_layer - 1)
end

-- 5. PROGRESSIVE BUILDING LAYER FUNCTION
local function build_platform_layer(pos, width, current_layer, max_height, facade_node, layer_map)
    if not pos or not pos.y then return end
    if current_layer > max_height then
        -- Structure building complete! Wait 10 seconds, then start top-to-bottom removal
        minetest.after(10.0, despawn_platform_layer, layer_map, max_height)
        return 
    end

    local center_y = pos.y + current_layer
    layer_map[current_layer] = {} -- Track nodes for this exact height row

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
                minetest.set_node(target_pos, {name = facade_node})
                -- Log coordinates into our tier structure tracker
                table.insert(layer_map[current_layer], target_pos)
            end
        end
    end

    minetest.sound_play("default_cool_lava", {pos = pos, gain = 0.3, max_hear_distance = 12}, true)
    
    -- Keep building upward row by row
    minetest.after(0.15, build_platform_layer, pos, width, current_layer + 1, max_height, facade_node, layer_map)
end

-- 6. TOOL REGISTRATION LOOP
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
            
            -- Identify visual facade or use base magic stone fallback
            local facade_node = facade_registry[clicked_node.name] or "techblox:magic_stone"
            local start_pos = {x = clicked_pos.x, y = clicked_pos.y, z = clicked_pos.z}
            
            -- Initialize tracking table to isolate this specific platform setup
            local layer_map = {}
            
            build_platform_layer(start_pos, data.width, 1, data.height, facade_node, layer_map)
            
            if itemstack and type(itemstack.add_wear) == "function" then
                itemstack:add_wear(65535 / 45) 
            end
            
            return itemstack
        end,
    })
end

print("[Techblox Modpack] Earth Wands optimized: Exact textures matching with top-to-bottom decay!")
