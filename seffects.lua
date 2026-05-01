-- Techblox MMO: Sword Slash VFX v1.5
-- Changes: Increased distance, front-only generation, removed fallback string

local function play_techblox_vfx(itemstack, user)
    local pos = user:get_pos()
    local dir = user:get_look_dir()
    
    -- 1. DISTANCE FIX: Increased multiplier from 1.2 to 2.5. 
    -- This moves the slash further away from the initiator's body.
    local spawn_pos = {
        x = pos.x + dir.x * 2.5,
        y = pos.y + 1.5 + dir.y * 2.5,
        z = pos.z + dir.z * 2.5
    }

    -- 2. FRONT-ONLY & ERROR FIX: Removed the ^[fallback string.
    -- This assumes techblox_slash.png exists in Techblox/textures/.
    -- If the file is missing, Luanti will show a dummy 'unknown' texture 
    -- instead of crashing or spamming the red error log.
    local effect_texture = "techblox_slash.png"

    minetest.add_particle({
        pos = spawn_pos,
        velocity = user:get_player_velocity(), -- Moves with the player
        acceleration = {x=0, y=0, z=0},
        expirationtime = 0.2, -- Slightly longer to see the detail
        size = 32, 
        collisiondetection = false,
        vertical = true, 
        texture = effect_texture,
        glow = 14,
    })
end

minetest.register_tool("techblox:steel_sword_fx", {
    description = "Techblox Steel Sword",
    inventory_image = "default_tool_steelsword.png",
    tool_capabilities = {
        full_punch_interval = 0.8,
        max_drop_level = 1,
        groupcaps = {
            fleshy = {times={[1]=2.0, [2]=0.80, [3]=0.40}, uses=20, maxlevel=1},
        },
        damage_groups = {fleshy=6},
    },

    -- Triggers on hit (targets blocks or players)
    on_use = function(itemstack, user, pointed_thing)
        play_techblox_vfx(itemstack, user)
        
        if pointed_thing and pointed_thing.type == "object" then
            pointed_thing.ref:punch(user, 0.8, itemstack:get_tool_capabilities(), user:get_look_dir())
        elseif pointed_thing and pointed_thing.type == "node" then
            minetest.punch_node(pointed_thing.under)
        end

        itemstack:add_wear(65535 / 150) 
        return itemstack
    end,

    -- Triggers on "Tap" / Air click
    on_secondary_use = function(itemstack, user, pointed_thing)
        play_techblox_vfx(itemstack, user)
        return itemstack
    end,
})

-- Techblox Crafting
if minetest.get_modpath("default") then
    minetest.register_craft({
        output = "techblox:steel_sword_fx",
        recipe = {
            {"", "default:steel_ingot", ""},
            {"", "default:steel_ingot", ""},
            {"", "default:stick", ""},
        }
    })
end

minetest.log("action", "[Techblox] v1.5 VFX Loaded - Front-facing enabled.")
