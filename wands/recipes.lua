-- Clear any pre-existing wand recipes

-- Earth Wand Tier 1
minetest.register_craft({
    output = "techblox:earth_wand_t1",
    recipe = {
        {"", "magic_materials:earth_core", ""},
        {"default:gold_block", "default:diamond", "default:gold_block"},
        {"", "magic_materials:earth_core", ""}
    }
})

-- Earth Wand Tier 2
minetest.register_craft({
    output = "techblox:earth_wand_t2",
    recipe = {
        {"default:gold_block", "magic_materials:earth_core", "default:gold_block"},
        {"default:gold_block", "techblox:earth_wand_t1", "default:gold_block"},
        {"default:gold_block", "magic_materials:earth_core", "default:gold_block"}
    }
})

-- Earth Wand Tier 3
minetest.register_craft({
    output = "techblox:earth_wand_t3",
    recipe = {
        {"default:gold_block", "magic_materials:earth_core", "default:gold_block"},
        {"magic_materials:earth_core", "techblox:earth_wand_t2", "magic_materials:earth_core"},
        {"default:gold_block", "magic_materials:earth_core", "default:gold_block"}
    }
})
-- DEBUG LOGGERS
core.log("warning", "my mod overrides T1: " .. dump(core.get_all_craft_recipes("techblox:earth_wand_t1")))
core.log("warning", "my mod overrides T2: " .. dump(core.get_all_craft_recipes("techblox:earth_wand_t2")))
core.log("warning", "my mod overrides T3: " .. dump(core.get_all_craft_recipes("techblox:earth_wand_t3")))
