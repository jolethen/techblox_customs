local modname = minetest.get_current_modname() or "techblox"

-- 1. Lightning Orb
minetest.register_craftitem(modname .. ":lightning_orb", {
    description = "Lightning Orb",
    inventory_image = "l_orb.png",
    stack_max = 20,
    on_use = function(itemstack, user, pointed_thing)
        minetest.chat_send_player(user:get_player_name(), "You used the Lightning Orb!")
        return itemstack
    end,
})

-- 2. Fire Orb
minetest.register_craftitem(modname .. ":fire_orb", {
    description = "Fire Orb",
    inventory_image = "f_orb.png",
    stack_max = 20,
    on_use = function(itemstack, user, pointed_thing)
        minetest.chat_send_player(user:get_player_name(), "You used the Fire Orb!")
        return itemstack
    end,
})

-- 3. Void Orb
minetest.register_craftitem(modname .. ":void_orb", {
    description = "Void Orb",
    inventory_image = "v_orb.png",
    stack_max = 20,
    on_use = function(itemstack, user, pointed_thing)
        minetest.chat_send_player(user:get_player_name(), "You used the Void Orb!")
        return itemstack
    end,
})

-- 4. Water Orb
minetest.register_craftitem(modname .. ":water_orb", {
    description = "Water Orb",
    inventory_image = "w_orb.png",
    stack_max = 20,
    on_use = function(itemstack, user, pointed_thing)
        minetest.chat_send_player(user:get_player_name(), "You used the Water Orb!")
        return itemstack
    end,
})

-- 5. Earth Orb
minetest.register_craftitem(modname .. ":earth_orb", {
    description = "Earth Orb",
    inventory_image = "e_orb.png",
    stack_max = 20,
    on_use = function(itemstack, user, pointed_thing)
        minetest.chat_send_player(user:get_player_name(), "You used the Earth Orb!")
        return itemstack
    end,
})

-- 6. Ice Orb
minetest.register_craftitem(modname .. ":ice_orb", {
    description = "Ice Orb",
    inventory_image = "i_orb.png",
    stack_max = 20,
    on_use = function(itemstack, user, pointed_thing)
        minetest.chat_send_player(user:get_player_name(), "You used the Ice Orb!")
        return itemstack
    end,
})
