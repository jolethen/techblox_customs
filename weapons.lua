-- ==========================================
-- ICE WEAPONS
-- ==========================================

-- 1. Ice Dagger (Very fast attack, lower damage)
minetest.register_tool("techblox:ice_dagger", {
    description = "Ice Dagger",
    inventory_image = "ice_dagger.png", -- Replace with your friend's exact texture name
    tool_capabilities = {
        full_punch_interval = 0.5, -- Super fast
        max_drop_level = 1,
        groupcaps = {
            fleshy = {times={[1]=2.0, [2]=0.8, [3]=0.4}, uses=100, maxlevel=1},
        },
        damage_groups = {fleshy=4}, -- Deals 4 damage (2 hearts)
    },
    sound = {breaks = "tool_breaks"},
})

-- 2. Ice Sword (Standard speed, good damage)
minetest.register_tool("techblox:ice_sword", {
    description = "Ice Sword",
    inventory_image = "ice_sword.png", -- Replace with your friend's exact texture name
    tool_capabilities = {
        full_punch_interval = 0.8, -- Normal sword speed
        max_drop_level = 1,
        groupcaps = {
            fleshy = {times={[1]=2.5, [2]=1.2, [3]=0.6}, uses=150, maxlevel=2},
        },
        damage_groups = {fleshy=7}, -- Deals 7 damage (3.5 hearts)
    },
    sound = {breaks = "tool_breaks"},
})

-- 3. Ice Scythe (Slow attack, high damage, can chop plants)
minetest.register_tool("techblox:ice_scythe", {
    description = "Ice Scythe",
    inventory_image = "ice_scythe.png", -- Replace with your friend's exact texture name
    tool_capabilities = {
        full_punch_interval = 1.3, -- Slower to swing
        max_drop_level = 1,
        groupcaps = {
            fleshy = {times={[1]=3.0, [2]=1.5, [3]=0.8}, uses=200, maxlevel=2},
            snappy = {times={[1]=1.0, [2]=0.5, [3]=0.2}, uses=200, maxlevel=3}, -- Good for breaking leaves/grass
        },
        damage_groups = {fleshy=10}, -- Deals 10 damage (5 hearts)
    },
    sound = {breaks = "tool_breaks"},
})

-- 4. Ice Bow (Basic item registration)
minetest.register_tool("techblox:ice_bow", {
    description = "Ice Bow",
    inventory_image = "ice_bow.png", -- Replace with your friend's exact texture name
    -- Bows require extra logic to actually shoot, see note below!
})
-- ==========================================
-- TECHBLOX: DIAMOND PULSE STAFF
-- ==========================================

minetest.register_tool("techblox:diamond_pulse_staff", {
    description = "Diamond Pulse Staff (Use on Diamond Block)",
    inventory_image = "diamond_pulse_staff.png", -- Ensure the texture exists in techblox/textures/
    on_place = function(itemstack, user, pointed_thing)
        -- 1. Ensure we are clicking a block
        if pointed_thing.type ~= "node" then return end
        
        local pos = pointed_thing.under
        local node = minetest.get_node(pos)
        
        -- 2. Requirement: Target must be a Diamond Block
        if node.name ~= "default:diamondblock" then
            return
        end

        local center = pointed_thing.above
        local max_height = 5
        local delay = 0.3 -- Speed of the "rising" effect

        -- Helper function to build or remove a 3x3 layer
        local function set_layer(layer_pos, node_name)
            for x = -1, 1 do
                for z = -1, 1 do
                    local p = {x=layer_pos.x+x, y=layer_pos.y, z=layer_pos.z+z}
                    -- Safety: Only replace air so we don't break the environment
                    if node_name == "air" or minetest.get_node(p).name == "air" then
                        minetest.set_node(p, {name = node_name})
                    end
                end
            end
        end

        -- ANIMATION: Moving Up (1 block at a time)
        for h = 0, max_height - 1 do
            minetest.after(h * delay, function()
                set_layer({x=center.x, y=center.y + h, z=center.z}, "default:glass")
                minetest.sound_play("default_place_node", {pos = center, gain = 0.5})
            end)
        end

        -- ANIMATION: Removing from Top to Down
        -- Wait for the full rise + 2 seconds of stationary time
        local start_removal = (max_height * delay) + 2 
        
        for h = max_height - 1, 0, -1 do
            -- Calculate removal delay based on height (top-down)
            local removal_delay = start_removal + ((max_height - 1 - h) * delay)
            
            minetest.after(removal_delay, function()
                set_layer({x=center.x, y=center.y + h, z=center.z}, "air")
                minetest.sound_play("default_dig_cracky", {pos = center, gain = 0.3})
            end)
        end

        -- Use up durability
        itemstack:add_wear(65535 / 20) -- 20 uses before breaking
        return itemstack
    end,
})
