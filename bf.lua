minetest.register_on_mods_loaded(function()
    for name, def in pairs(minetest.registered_items) do
        -- Check if the item belongs to the banner mod
        if name:find("^banners:") then
            -- Keep the base banners, but hide any pattern variants
            if name:find("_pattern") or name:find("_design") or name:find("_stripe") or name:find("_cross") then
                local new_groups = table.copy(def.groups or {})
                new_groups.not_in_creative_inventory = 1
                
                minetest.override_item(name, {
                    groups = new_groups
                })
            end
        end
    end
end)
