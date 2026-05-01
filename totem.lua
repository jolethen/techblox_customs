-- Register the Totem Item
minetest.register_craftitem("techblox:totem_of_undying", {
    description = "Techblox Totem of Undying\nPrevents death when held in inventory",
    inventory_image = "techblox_totem.png",
    stack_max = 1,
})

-- Death Prevention Logic
minetest.register_on_player_hpchange(function(player, hp_change, reason)
    -- 1. Only trigger if the change is DAMAGE (negative)
    if hp_change >= 0 then 
        return hp_change 
    end

    local current_hp = player:get_hp()
    
    -- 2. Check if the damage will kill the player
    if current_hp + hp_change <= 0 then
        local inv = player:get_inventory()
        
        -- 3. Check if totem is in the 'main' inventory
        if inv:contains_item("main", "techblox:totem_of_undying") then
            
            -- Remove one totem
            inv:remove_item("main", "techblox:totem_of_undying")
            
            -- Sound and Burst Particles
            local pos = player:get_pos()
            minetest.sound_play("default_recharge", {pos = pos, gain = 1.0, max_hear_distance = 16})
            
            minetest.add_particlespawner({
                amount = 60,
                time = 0.1, -- Explode almost instantly
                minpos = {x = pos.x - 0.5, y = pos.y + 1, z = pos.z - 0.5},
                maxpos = {x = pos.x + 0.5, y = pos.y + 1.5, z = pos.z + 0.5},
                minvel = {x = -4, y = 2, z = -4},
                maxvel = {x = 4, y = 6, z = 4},
                minacc = {x = 0, y = -9.8, z = 0}, -- Gravity makes shards fall
                maxacc = {x = 0, y = -9.8, z = 0},
                minexptime = 1,
                maxexptime = 2,
                minsize = 1,
                maxsize = 3,
                texture = "techblox_totem_particle.png",
                glow = 14,
            })

            -- 4. Set HP to max (prevents the 'Death' state)
            local hp_max = player:get_properties().hp_max or 20
            player:set_hp(hp_max)
            
            -- 5. HUD Feedback
            minetest.chat_send_player(player:get_player_name(), 
                " \n[Techblox] YOUR TOTEM HAS BEEN CONSUMED!\n ")

            -- 6. CRITICAL: Return 0 to cancel the fatal damage
            return 0
        end
    end
    
    return hp_change
end, true)
