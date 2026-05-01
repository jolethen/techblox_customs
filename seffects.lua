-- Techblox MMO: Sword Slash VFX v1.3
-- Optimized for 128x128+ textures

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

    on_use = function(itemstack, user, pointed_thing)
        local pos = user:get_pos()
        local dir = user:get_look_dir()
        
        -- Positioning logic
        local spawn_pos = {
            x = pos.x + dir.x * 1.2,
            y = pos.y + 1.5 + dir.y * 1.2,
            z = pos.z + dir.z * 1.2
        }

        -- Updated Texture Name for Techblox folder
        -- Using a procedural fallback if techblox_slash.png isn't found
        local effect_texture = "techblox_slash.png^[fallback:([inventorycube{00ffff66{00ffff66{00ffff66)"

        minetest.add_particle({
            pos = spawn_pos,
            velocity = {x=0, y=0, z=0},
            acceleration = {x=0, y=0, z=0},
            expirationtime = 0.15, 
            
            -- SIZE FIX: Increased to 30 to fill more of the screen
            size = 30, 
            
            collisiondetection = false,
            
            -- ALIGNMENT FIX: vertical = true keeps the slash standing up 
            -- so it doesn't look like a flat block on the ground.
            vertical = true, 
            
            texture = effect_texture,
            glow = 14,
        })

        -- Combat Logic
        if pointed_thing and pointed_thing.type == "object" then
            pointed_thing.ref:punch(user, 0.8, itemstack:get_tool_capabilities(), dir)
        elseif pointed_thing and pointed_thing.type == "node" then
            minetest.punch_node(pointed_thing.under)
        end

        itemstack:add_wear(65535 / 150) 
        return itemstack
    end,
})

-- Techblox Crafting Recipe
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

minetest.log("action", "[Techblox] Sword VFX Loaded - Using techblox_slash.png")
