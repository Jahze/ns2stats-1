-- NS2Stats client-side plugin

last_round_url = "http://ns2stats.org"
last_round_color = Color(240/255, 240/255, 240/255)

awards = { }

-- Network message hooks
RespondToNetworkMessage("NS2S_ServerInfo", function(message)
    return { ip = address, password = password }
end)

RespondToNetworkMessage("NS2S_ModsInfo", function(message)
    local mods_string = ""
    for s = 1, Client.GetNumMods() do

        local state = Client.GetModState(s)
        local state_string = kModStateNames[state]
        if state_string == nil then
            state_string = "??"
        end
        local name = Client.GetModTitle(s)
        local active = Client.GetIsModActive(s) and "YES" or "NO"
        local subscribed = Client.GetIsSubscribedToMod(s) and "YES" or "NO"
        local percent = "100%"
        if active == "NO" and subscribed == "NO" then
            if name and name ~= "" then
                mods_string = Format("%s%s,", mods_string, name)
            end
        end

    end
    
    return { mods = mods_string }
end)

HookNetworkMessage("NS2S_LastRound", function(message)
    if message.url ~= "" then --TODO: send blank url when NotEnoughPlayers
        last_round_url = message.url

        SparkMod.PrintToScreen(0.5, 0.83, "Round stats at " .. last_round_url, 24, last_round_color, "last_round")
        SparkMod.PrintToScreen(0.5, 0.89, "Type check in chat or console to open browser.", 24, last_round_color, "last_round_help")
    else
        last_round_url = "http://ns2stats.org"

        SparkMod.PrintToScreen(0.5, 0.83, "Game did not have enough players for stats to be saved.", 12, last_round_color, "last_round_not_enough_players")
    end
end)

HookNetworkMessage("NS2S_Awards", function(message)
    table.insert(awards, message.award)
end)

HookNetworkMessage("NS2S_ShowAwards", function(message)
    --RBPS:clientShowAwards(message)
end)