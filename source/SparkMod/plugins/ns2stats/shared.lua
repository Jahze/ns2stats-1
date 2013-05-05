info = {
    name = "NS2 Stats",
    author = "bawNg",
    description = "NS2Stats implemented using SparkMod",
    version = "0.1",
    url = "http://ns2stats.org"
}

default_config = {
    test_value = 1
}

-- NS2Stats network messages
NetworkMessageField("NS2S_ServerInfo", "ip", "string (16)", "")
NetworkMessageField("NS2S_ServerInfo", "password", "string (32)", "")

NetworkMessageField("NS2S_ModsInfo", "mods", "string (256)", "")

NetworkMessageField("NS2S_LastRound", "url", "string (128)", "")

NetworkMessageField("NS2S_Awards", "award", "string (128)", "")

-- Network message extensions
NetworkMessageField("Scores", "assists", Format("integer (0 to %d)", kMaxScore), 0)
NetworkMessageField("Scores", "badge", "enum kBadges", kBadges.None)