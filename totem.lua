-- Register the Totem Item
minetest.register_craftitem("techblox:totem_of_undying", {
    description = "Techblox Totem of Undying\nPrevents death when held in inventory",
    -- Using the techblox green/purple design
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
            
            -- ORB 1 Spawner
            minetest.add_particlespawner({
                amount = 40,
                time = 0.1,
                minpos = {x = pos.x - 0.5, y = pos.y + 1, z = pos.z - 0.5},
                maxpos = {x = pos.x + 0.5, y = pos.y + 1.5, z = pos.z + 0.5},
                minvel = {x = -3, y = 2, z = -3},
                maxvel = {x = 3, y = 5, z = 3},
                minacc = {x = 0, y = -5, z = 0},
                maxacc = {x = 0, y = -5, z = 0},
                minexptime = 1,
                maxexptime = 1.5,
                minsize = 1,
                maxsize = 2,
                texture = "orb1.png",
                glow = 14,
            })

            -- ORB 2 Spawner
            minetest.add_particlespawner({
                amount = 40,
                time = 0.1,
                minpos = {x = pos.x - 0.5, y = pos.y + 1, z = pos.z - 0.5},
                maxpos = {x = pos.x + 0.5, y = pos.y + 1.5, z = pos.z + 0.5},
                minvel = {x = -5, y = 3, z = -5},
                maxvel = {x = 5, y = 6, z = 5},
                minacc = {x = 0, y = -8, z = 0},
                maxacc = {x = 0, y = -8, z = 0},
                minexptime = 0.8,
                maxexptime = 1.2,
                minsize = 2,
                maxsize = 4,
                texture = "orb2.png",
                glow = 10,
            })

            -- 4. Set HP to max
            local hp_max = player:get_properties().hp_max or 20
            player:set_hp(hp_max)
            
            -- 5. HUD Feedback
            minetest.chat_send_player(player:get_player_name(), 
                " \n[Techblox] YOUR TOTEM HAS BEEN CONSUMED!\n ")

            -- 6. Cancel the fatal damage
            return 0
        end
    end
    
    return hp_change
end, true)
