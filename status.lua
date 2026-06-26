minetest.override_chatcommand("status", {
    params = "",
    description = "Shows server status",
    func = function(name, param)
        -- 1. Static Configuration
        local version = "1.6.7"
        local game_name = "Techblox Indev"
        
        -- 2. Fast Uptime Calculation
        local uptime_sec = math.floor(minetest.get_server_uptime())
        local hours = math.floor(uptime_sec / 3600)
        local minutes = math.floor((uptime_sec % 3600) / 60)
        local seconds = uptime_sec % 60
        local uptime_str = string.format("%dh %dm %ds", hours, minutes, seconds)
        
        -- 3. Fetch Real-time Max Lag (FIXED)
        -- Pulls the engine's default status string and extracts max_lag via pattern match
        local server_status = minetest.get_server_status() or ""
        local max_lag_raw = string.match(server_status, "max_lag%s*=%s*([%d%.]+)")
        local max_lag = tonumber(max_lag_raw) or 0.00
        local lag_str = string.format("%.2fs", max_lag)

        -- 4. Efficient Player Name Extraction
        local players = minetest.get_connected_players()
        local player_list = {}
        
        for i = 1, #players do
            player_list[i] = players[i]:get_player_name()
        end
        
        -- Fast table join instead of repetitive string concatenation
        local player_names = #player_list > 0 and table.concat(player_list, " ") or "None"

        -- 5. Constructing Output (Matching your layout)
        local line1 = string.format("# Server: version: %s | game: %s | uptime: %s | max lag: %s | clients: %s", 
                                    version, game_name, uptime_str, lag_str, player_names)
        local line2 = "# Server: Server by FREE Server Hosting from Walker for Members of the Minetest-Forum"
        
        return true, line1 .. "\n" .. line2
    end,
})
