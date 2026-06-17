-- ==========================================================================
-- TECHBLOX EARTH WANDS COMPONENT
-- Features: 3 Tiers, Progressive Building, Default Stone Blocks,
--           Top-to-Bottom Staggered Despawning, and Personal Cooldown Timers.
-- ==========================================================================

-- Global tables for security tracking
local active_magic_blocks = {}
local player_cooldowns = {} -- Tracks username -> os.time() expiration stamp

-- 1. PROTECTION HOOK: Stop players from mining the temporary structure blocks
minetest.register_on_dignode(function(pos, oldnode, oldmetadata, digger)
    if not pos then return end
    local pos_key = pos.x .. "," .. pos.y .. "," .. pos.z
    
    if active_magic_blocks[pos_key] then
        return true -- Cancel digging event completely
    end
end)

-- 2. WAND CONFIGURATION TUNING (THE THREE TIERS)
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

-- 3. REVERSE STAGGERED TOP-TO-BOTTOM DESPAWN FUNCTION
local function despawn_platform_layer(layer_map, current_layer)
    if current_layer < 1 then return end 

    local blocks_to_remove = layer_map[current_layer]
    if blocks_to_remove then
        for _, pos in ipairs(blocks_to_remove) do
            local pos_key = pos.x .. "," .. pos.y .. "," .. pos.z
            
            if active_magic_blocks[pos_key] then
                minetest.remove_node(pos)
                active_magic_blocks[pos_key] = nil 
            end
        end
        
        if #blocks_to_remove > 0 then
            minetest.sound_play("default_cool_lava", {pos = blocks_to_remove[1], gain = 0.1, max_hear_distance = 10}, true)
        end
    end

    -- Drop down to dissolve the next layer below after 0.25 seconds
    minetest.after(0.25, despawn_platform_layer, layer_map, current_layer - 1)
end

-- 4. PROGRESSIVE BUILDING LAYER FUNCTION (Forcing default:stone)
local function build_platform_layer(pos, width, current_layer, max_height, layer_map)
    if not pos or not pos.y then return end
    if current_layer > max_height then
        -- Complete! Hold structure for 10 seconds before crumbling top-to-bottom
        minetest.after(10.0, despawn_platform_layer, layer_map, max_height)
        return 
    end

    local center_y = pos.y + current_layer
    layer_map[current_layer] = {} 

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
                -- Place regular stone
                minetest.set_node(target_pos, {name = "default:stone"})
                
                local pos_key = target_pos.x .. "," .. target_pos.y .. "," .. target_pos.z
                active_magic_blocks[pos_key] = true
                
                table.insert(layer_map[current_layer], target_pos)
            end
        end
    end

    minetest.sound_play("default_cool_lava", {pos = pos, gain = 0.3, max_hear_distance = 12}, true)
    
    -- Stagger upward row-by-row
    minetest.after(0.15, build_platform_layer, pos, width, current_layer + 1, max_height, layer_map)
end

-- 5. TOOL REGISTRATION LOOP
for tier, data in ipairs(wand_tiers) do
    minetest.register_tool(data.name, {
        description = data.description,
        inventory_image = data.texture,
        stack_max = 1,
        
        on_use = function(itemstack, user, pointed_thing)
            if not pointed_thing or pointed_thing.type ~= "node" then
                return itemstack
            end
            
            if not user or not user:is_player() then 
                return itemstack 
            end
            
            local player_name = user:get_player_name()
            local current_time = os.time()
            
            -- COOLDOWN ENFORCEMENT CHECK
            if player_cooldowns[player_name] and current_time < player_cooldowns[player_name] then
                local time_left = player_cooldowns[player_name] - current_time
                minetest.chat_send_player(player_name, "Wand on cooldown. Try again in " .. time_left .. " seconds.")
                return itemstack
            end
            
            local clicked_pos = pointed_thing.under
            if not clicked_pos then return itemstack end
            
            local clicked_node = minetest.get_node_or_nil(clicked_pos)
            if not clicked_node or clicked_node.name == "ignore" or clicked_node.name == "air" then 
                return itemstack 
            end
            
            -- TRIGGER COOLDOWN: 20 seconds from now
            player_cooldowns[player_name] = current_time + 20
            
            local start_pos = {x = clicked_pos.x, y = clicked_pos.y, z = clicked_pos.z}
            local layer_map = {}
            
            build_platform_layer(start_pos, data.width, 1, data.height, layer_map)
            
            if itemstack and type(itemstack.add_wear) == "function" then
                itemstack:add_wear(65535 / 45) 
            end
            
            return itemstack
        end,
    })
end

print("[Techblox Modpack] Earth Wands loaded: Default stone with 20s player cooldowns initialized.")
