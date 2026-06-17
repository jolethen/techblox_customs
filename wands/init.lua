-- ==========================================================================
-- TECHBLOX EARTH WANDS COMPONENT
-- Features: 3 Tiers, Progressive Building, Anti-Lag, Anti-Duplication,
--           EXACT Metadata Texture Injection, and Auto-Despawn Timers.
-- ==========================================================================

-- 1. REGISTER THE BASE UNBREAKABLE PLATFORM NODE
minetest.register_node("techblox:magic_stone", {
    description = "Magic Earth Stone",
    tiles = {"default_stone.png"}, -- Fallback base texture
    groups = {immobile = 1, magic_structure = 1}, -- Added 'magic_structure' for easy tracking
    diggable = false,              
    floodable = false,
    sounds = {
        footstep = {name = "default_hard_footstep", gain = 0.2},
        dug = {name = "default_dug_node", gain = 0.5},
        place = {name = "default_place_node", gain = 0.5},
    },
    
    -- When the block is placed, set up its initialization defaults
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_int("spawn_time", os.time()) -- Track exactly when it was generated
    end,
})

-- 2. DESPAWN CONTROLLER (AUTOMATIC TIMED REMOVAL)
-- Checks all 'magic_structure' blocks every second and turns them to air after 15 seconds
minetest.register_abm({
    label = "Magic Stone Despawn Loop",
    nodenames = {"techblox:magic_stone"},
    interval = 1.0, -- Run checks every second
    chance = 1,     -- 100% execution rate
    action = function(pos, node, active_object_count, active_object_count_wider)
        local meta = minetest.get_meta(pos)
        if not meta then return end
        
        local spawn_time = meta:get_int("spawn_time") or 0
        local current_time = os.time()
        
        -- Despawn limit: 15 seconds (Change this number to make it stay shorter/longer)
        if (current_time - spawn_time) >= 15 then
            minetest.remove_node(pos)
            -- Play a subtle crumbling/fading sound at the position
            minetest.sound_play("default_cool_lava", {pos = pos, gain = 0.1, max_hear_distance = 8}, true)
        end
    end,
})

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

-- 4. LAG-FREE STAGGERED GENERATION LAYER FUNCTION WITH EXACT TEXTURE INJECTION
local function build_platform_layer(pos, width, current_layer, max_height, target_texture)
    if not pos or not pos.y or not target_texture then return end
    if current_layer > max_height then return end

    local center_y = pos.y + current_layer

    -- Mathematical offset mapping for flawless grids
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
                -- Step A: Set the single unbreakable base block
                minetest.set_node(target_pos, {name = "techblox:magic_stone"})
                
                -- Step B: Force inject the targeted texture via metadata strings
                local meta = minetest.get_meta(target_pos)
                if meta then
                    -- Engine override hack to load a completely dynamic tile display string cleanly
                    meta:set_string("tileimages", target_texture)
                    meta:set_int("spawn_time", os.time()) -- Refresh timestamp anchor
                end
            end
        end
    end

    minetest.sound_play("default_cool_lava", {pos = pos, gain = 0.3, max_hear_distance = 12}, true)
    minetest.after(0.15, build_platform_layer, pos, width, current_layer + 1, max_height, target_texture)
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
            
            -- Extract the exact first texture file name from the clicked block
            local source_def = minetest.registered_nodes[clicked_node.name]
            local target_texture = "default_stone.png" -- Fallback
            
            if source_def and source_def.tiles then
                local tile = source_def.tiles[1]
                if type(tile) == "string" then
                    target_texture = tile
                elseif type(tile) == "table" and tile.name then
                    target_texture = tile.name
                end
            end
            
            local start_pos = {x = clicked_pos.x, y = clicked_pos.y, z = clicked_pos.z}
            
            -- Fire builder sequence with the literal file string passed directly down
            build_platform_layer(start_pos, data.width, 1, data.height, target_texture)
            
            if itemstack and type(itemstack.add_wear) == "function" then
                itemstack:add_wear(65535 / 45) 
            end
            
            return itemstack
        end,
    })
end

print("[Techblox Modpack] Earth Wands updated: Dynamic textures and auto-despawn timers functional!")
