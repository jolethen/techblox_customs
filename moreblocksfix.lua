-- Override to hide moreblocks stairs/slabs from creative inventory
minetest.register_on_mods_loaded(function()
    for name, def in pairs(minetest.registered_items) do
        -- Check if the item belongs to moreblocks and is a stair, slab, or panel
        if name:find("moreblocks:stair_") or name:find("moreblocks:slab_") or name:find("moreblocks:panel_") or name:find("moreblocks:micro_") then
            -- This removes it from the creative inventory/search
            minetest.override_item(name, {
                groups = {not_in_creative_inventory = 1}
            })
        end
    end
end)
