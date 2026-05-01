-- Techblox MMO: Sword Slash VFX v1.4
-- Fixed: Fallback syntax and Air-swing triggers

local function play_techblox_vfx(itemstack, user)
    local pos = user:get_pos()
    local dir = user:get_look_dir()
    
    -- Position slightly in front of the player
    local spawn_pos = {
        x = pos.x + dir.x * 1.2,
        y = pos.y + 1.5 + dir.y * 1.2,
        z = pos.z + dir.z * 1.2
    }

    -- FIXED TEXTURE STRING:
    -- We use a simpler colorized fallback to avoid the "Invalid modification" error.
    local effect_texture = "techblox_slash.png^[fallback:default_cloud.png^[colorize:#00ffff:150"

    minetest.add_particle({
        pos = spawn_pos,
        velocity = user:get_player_velocity(), -- Inherit player speed so it doesn't lag behind
        acceleration = {x=0, y=0, z=0},
        expirationtime = 0.15, 
        size = 30, 
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

    -- Triggers when hitting something
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

    -- Triggers when tapping the air (Mobile/PC)
    on_secondary_use = function(itemstack, user, pointed_thing)
        play_techblox_vfx(itemstack, user)
        return itemstack
    end,
})

-- Safe Crafting for Techblox
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

minetest.log("action", "[Techblox] Fixed Sword VFX Loaded!")
