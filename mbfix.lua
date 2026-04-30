-- ==========================================
-- TECHBLOX: MOREBLOCKS INVENTORY CLEANER (mbfix)
-- ==========================================

-- 1. REGISTER THE SPECIAL PRIVILEGE
-- Only players with this priv will see the sub-blocks (slabs/stairs/etc)
minetest.register_privilege("moreblocks", {
    description = "Allows player to see moreblocks, slabs, and stairs in the inventory.",
    give_to_singleplayer = true,
})

-- 2. HIDE SUB-BLOCKS FROM THE CREATIVE INVENTORY
-- This runs after all mods are loaded to catch every registered node
minetest.register_on_mods_loaded(function()
    for name, def in pairs(minetest.registered_nodes) do
        -- Pattern matching to find stairs, slabs, slopes, panels, and microblocks
        if name:find("stairs:") or 
           name:find("slabs:") or 
           name:find(":stair_") or 
           name:find(":slab_") or 
           name:find(":slope_") or 
           name:find(":panel_") or 
           name:find(":micro_") then
            
            -- Keep the block but hide it from the search/creative menu
            local groups = table.copy(def.groups or {})
            groups.not_in_creative_inventory = 1
            
            minetest.override_item(name, {
                groups = groups,
            })
        end
    end
end)

-- 3. UNIFIED INVENTORY OVERRIDE
-- If the player has the 'moreblocks' priv, bypass the hidden group
if minetest.get_modpath("unified_inventory") then
    -- We wait for UI to initialize its functions
    minetest.after(0, function()
        local old_filter = unified_inventory.get_filter
        
        unified_inventory.get_filter = function(player)
            local name = player:get_player_name()
            local privs = minetest.get_priv_list(name)
            
            -- If the player HAS the privilege, show everything (even hidden items)
            if privs.moreblocks then
                return function(item_name)
                    -- Returns true for everything, ignoring 'not_in_creative_inventory'
                    return true 
                end
            end
            
            -- Default behavior for players without the privilege
            return old_filter(player)
        end
    end)
end
