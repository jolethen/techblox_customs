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
