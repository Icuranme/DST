name = "Simplified Shard Configuration"
description = "Allows admin to set up shard connections."
author = "icuranme"
version = "1.0.0"
forumthread = "https://forums.kleientertainment.com/forums/topic/59174-understanding-shards-and-migration-portals/"

api_version = 10

icon_atlas = "modicon.xml"
icon = "modicon.tex"

dst_compatible = true
reign_of_giants_compatible = true

server_only_mod = true
all_clients_require_mod = false
client_only_mod = false

configuration_options =
{
	{
		name = "DeleteUnused",
		description = "Mod will delete unused portals instead just plugging them.",
		default = false
	},
	{
		name = "Connections",
		description = "List of bidirectional connections between shards.",
		default = { }
	}
}


