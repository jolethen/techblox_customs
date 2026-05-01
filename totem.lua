-- Register the Totem Item
minetest.register_craftitem("techblox:totem_of_undying", {
    description = "Techblox Totem of Undying\nPrevents death when held in inventory",
    inventory_image = "techblox_totem.png", -- Ensure you have this texture
    stack_max = 1,
})

-- Death Prevention Logic
minetest.register_on_player_hpchange(function(player, hp_change, reason)
    -- Only trigger if the damage is enough to kill the player
    local current_hp = player:get_hp()
    if current_hp + hp_change <= 0 then
        local inv = player:get_inventory()
        
        -- Check if the player has the totem in their main inventory
        if inv:contains_item("main", "techblox:totem_of_undying") then
            
            -- 1. Remove one totem
            inv:remove_item("main", "techblox:totem_of_undying")
            
            -- 2. Play a sound and add particles for the "Save" effect
            local pos = player:get_pos()
            minetest.sound_play("default_recharge", {pos = pos, gain = 1.0})
            
            minetest.add_particlespawner({
                amount = 50,
                time = 0.5,
                minpos = {x = pos.x - 1, y = pos.y, z = pos.z - 1},
                maxpos = {x = pos.x + 1, y = pos.y + 2, z = pos.z + 1},
                minvel = {x = -1, y = 2, z = -1},
                maxvel = {x = 1, y = 5, z = 1},
                texture = "techblox_totem_particle.png", -- Small sparkle or totem icon
            })

            -- 3. Heal the player to full (usually 20)
            player:set_hp(player:get_properties().hp_max)
            
            -- 4. Inform the player
            minetest.chat_send_player(player:get_player_name(), 
                "*** THE TOTEM SAVED YOU! ***")

            -- Return 0 to cancel the original fatal damage
            return 0
        end
    end
    
    -- Otherwise, proceed with normal damage
    return hp_change
end, true) -- The 'true' modifier makes this a modifier function
