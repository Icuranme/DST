name = "More Constant"
version = "2021.0214.01"
desc_variant = ("Mod version: " .. version ..
    "\nRegrow delay is measured from the time you pick, burn, mine, caught, etc the thing being respawned." ..
    "\nEntities only regrow if there are fewer of that entity than when the world was generated." ..
    "\nIf you shutdown the server and change the config, it will have no effect on things queued for regrowth, but future things it will."
)
description = desc_variant
author = "icuranme"
forumthread = ""
api_version = 10
dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
all_clients_require_mod = false
client_only_mod = false
server_only_mod = true
icon_atlas = "renewalmodicon.xml"
icon = "renewalmodicon.tex"

-- 480 (seconds / day) = 8 (min / day) * 60 (seconds / min)
local standard_options = {
  { description = "Off", data = -1, hover = "Will not respawn" },
  { description = "30 seconds", data = 30, hover = "" },
  { description = "1/4 Day", data = 120, hover = "2 minutes IRL time" },
  { description = "1/2 Day", data = 240, hover = "4 minutes IRL time" },
  { description = "1 Day", data = 480, hover = "8 minutes IRL time" },
  { description = "2 Days", data = 960, hover = "" },
  { description = "3 Days", data = 1440, hover = "" },
  { description = "4 Days", data = 1920, hover = "" },
  { description = "5 Days", data = 2400, hover = "" },
  { description = "10 Days", data = 4800, hover = "" },
  { description = "15 Days", data = 7200, hover = "" },
  { description = "20 Days", data = 9600, hover = "" },
  { description = "25 Days", data = 12000, hover = "" },
  { description = "30 Days", data = 14400, hover = "" },
  { description = "40 Days", data = 19200, hover = "" },
  { description = "50 Days", data = 24000, hover = "" },
  { description = "70 Days (1 yr)", data = 33600, hover = "1 standard year" },
  { description = "140 Days (2 yr)", data = 67200, hover = "2 standard years" },
  { description = "210 Days (3 yr)", data = 100800, hover = "3 standard years" }
}

local no_options = { { description = "", data = false } }

configuration_options = {
  { options = no_options, default = false, name = "Plants", label = "Plants", hover = "Various plants" },
  { options = standard_options, default = 33600, name = "berrybush", label = "Respawn delay for berrybush", hover = "berrybush will respawn after being removed from the game" },
  { options = standard_options, default = 33600, name = "berrybush2", label = "Respawn delay for berrybush2", hover = "berrybush2 will respawn after being removed from the game" },
  { options = standard_options, default = 33600, name = "berrybush_juicy", label = "Respawn delay for berrybush_juicy", hover = "berrybush_juicy will respawn after being removed from the game" },
  { options = standard_options, default = 14400, name = "cactus", label = "Respawn delay for cactus", hover = "cactus will respawn after being removed from the game" },
  { options = standard_options, default = 14400, name = "oasis_cactus", label = "Respawn delay for oasis_cactus", hover = "oasis_cactus will respawn after being removed from the game" },
  { options = standard_options, default = 33600, name = "evergreen_sparse", label = "Respawn delay for evergreen_sparse", hover = "evergreen_sparse will respawn after being removed from the game" },
  { options = standard_options, default = 4800, name = "flower_evil", label = "Respawn delay for evil flowers", hover = "evil flowers will respawn after being removed from the game" },
  { options = standard_options, default = 100800, name = "grass", label = "Respawn delay for grass", hover = "grass will respawn after being removed from the game\nIf planted or dug grass is burned." },
  { options = standard_options, default = -1, name = "livingtree", label = "Respawn delay for livingtree", hover = "livingtrees will respawn after being removed from the game" },
  { options = standard_options, default = 100800, name = "mandrake_planted", label = "Respawn delay for mandrakes", hover = "mandrakes will respawn after being removed from the game\neg: eaten, burned, etc; not after being picked" },
  { options = standard_options, default = 4800, name = "marsh_bush", label = "Respawn delay for spiky bushes", hover = "spiky bushes will respawn after being removed from the game" },
  { options = standard_options, default = 24000, name = "marsh_tree", label = "Respawn delay for spiky trees", hover = "spiky trees will respawn after being removed from the game" },
  { options = standard_options, default = 9600, name = "blue_mushroom", label = "Respawn delay for blue mushrooms", hover = "blue mushrooms will respawn after being removed from the game (the planted kind that regrows a mushroom when you pick it)" },
  { options = standard_options, default = 9600, name = "red_mushroom", label = "Respawn delay for red mushrooms", hover = "red mushrooms will respawn after being removed from the game (the planted kind that regrows a mushroom when you pick it)" },
  { options = standard_options, default = 9600, name = "green_mushroom", label = "Respawn delay for green mushrooms", hover = "green mushrooms will respawn after being removed from the game (the planted kind that regrows a mushroom when you pick it)" },
  { options = standard_options, default = 33600, name = "mushtree_small", label = "Respawn delay for green mushtrees", hover = "mushtrees will respawn after being removed from the game" },
  { options = standard_options, default = 33600, name = "mushtree_medium", label = "Respawn delay for red mushtrees", hover = "mushtrees will respawn after being removed from the game" },
  { options = standard_options, default = 33600, name = "mushtree_tall", label = "Respawn delay for blue mushtrees", hover = "mushtrees will respawn after being removed from the game" },
  { options = standard_options, default = 14400, name = "mushtree_moon", label = "Respawn delay for moon trees", hover = "moon trees will respawn after being removed from the game" },
  { options = standard_options, default = 9600, name = "reeds", label = "Respawn delay for reeds", hover = "reeds will respawn after being removed from the game" },
  { options = standard_options, default = 33600, name = "rock_avocado_bush", label = "Respawn delay for rock fruit bush", hover = "rock fruit bush will respawn after being removed from the game" },
  { options = standard_options, default = 14400, name = "sapling", label = "Respawn delay for sapling", hover = "sapling will respawn after being removed from the game" },

  { options = no_options, default = false, name = "Spawners", label = "Spawners", hover = "Various Spawners" },
  { options = standard_options, default = 14400, name = "catcoonden", label = "Respawn delay for catcoonden", hover = "catcoonden will respawn after being removed from the game" },
  { options = standard_options, default = 33600, name = "houndmound", label = "Respawn delay for houndmound", hover = "houndmound will respawn after being removed from the game" },
  { options = standard_options, default = 14400, name = "mermhouse", label = "Respawn delay for mermhouse", hover = "mermhouse will respawn after being removed from the game" },
  { options = standard_options, default = 1920, name = "molehill", label = "Respawn delay for molehill", hover = "molehill will respawn after being removed from the game" },
  { options = standard_options, default = 7200, name = "moonglass_wobster_den", label = "Respawn delay for moonglass_wobster_den", hover = "moonglass_wobster_den will respawn after being removed from the game" },
  { options = standard_options, default = 7200, name = "moonspiderden", label = "Respawn delay for moonspiderden", hover = "moonspiderden will respawn after being removed from the game" },
  { options = standard_options, default = 4800, name = "rabbithole", label = "Respawn delay for rabbithole", hover = "rabbithole will respawn after being removed from the game" },
  { options = standard_options, default = 14400, name = "tallbirdnest", label = "Respawn delay for tallbirdnest", hover = "tallbirdnest will respawn after being removed from the game" },
  { options = standard_options, default = -1, name = "beehive", label = "Respawn delay for beehive", hover = "beehive will respawn after being removed from the game" },
  { options = standard_options, default = -1, name = "wasphive", label = "Respawn delay for wasphive", hover = "wasphive will respawn after being removed from the game" },

  { options = no_options, default = false, name = "monstersnanimals", label = "Monsters / Animals", hover = "Monsters and Animals" },
  { options = standard_options, default = 33600, name = "carrat", label = "Respawn delay for carrat", hover = "carrat will respawn after being removed from the game" },
  { options = standard_options, default = 33600, name = "fireflies", label = "Respawn delay for fireflies", hover = "fireflies will respawn after being removed from the game" },
  { options = standard_options, default = 33600, name = "fruitdragon", label = "Respawn delay for fruitdragon", hover = "fruitdragon will respawn after being removed from the game" },
  { options = standard_options, default = 33600, name = "grassgekko", label = "Respawn delay for grassgekko", hover = "grassgekko will respawn after being removed from the game" },
  { options = standard_options, default = 33600, name = "lightninggoat", label = "Respawn delay for lightninggoat", hover = "lightninggoat will respawn after being removed from the game" },
  { options = standard_options, default = 100800, name = "tentacle", label = "Respawn delay for tentacle", hover = "tentacle will respawn after being removed from the game" },

  { options = no_options, default = false, name = "Chess", label = "Chess", hover = "Various Chess Pieces" },
  { options = standard_options, default = -1, name = "bishop", label = "Respawn delay for bishop", hover = "bishop will respawn after being removed from the game" },
  { options = standard_options, default = -1, name = "knight", label = "Respawn delay for knight", hover = "knight will respawn after being removed from the game" },
  { options = standard_options, default = -1, name = "rook", label = "Respawn delay for rook", hover = "rook will respawn after being removed from the game" },

  { options = no_options, default = false, name = "mineable", label = "Minables", hover = "Minable" },
  { options = standard_options, default = 33600, name = "grotto_pool_big", label = "Respawn delay for grotto pools", hover = "grotto pools will respawn after being removed from the game" },
  { options = standard_options, default = 33600, name = "moonglass_rock", label = "Respawn delay for moonglass rock", hover = "moonglass rock will respawn after being removed from the game" },
  { options = standard_options, default = 67200, name = "rock1", label = "Respawn delay for flint boulders", hover = "flint boulders  will respawn after being removed from the game" },
  { options = standard_options, default = 67200, name = "rock2", label = "Respawn delay for gold boulders", hover = "gold boulders will respawn after being removed from the game" },
  { options = standard_options, default = 67200, name = "rock_flintless", label = "Respawn delay for desert boulders", hover = "desert boulders will respawn after being removed from the game" },
  { options = standard_options, default = 67200, name = "rock_moon", label = "Respawn delay for moon rock boulders", hover = "moon rock boulders will respawn after being removed from the game" },
  { options = standard_options, default = 100800, name = "stalagmite_full", label = "Respawn delay for stalagmites ", hover = "stalagmites 1 will respawn after being removed from the game" },
  { options = standard_options, default = 100800, name = "stalagmite_tall_full", label = "Respawn delay for stalagmites 2", hover = "stalagmites 2 will respawn after being removed from the game" },
}
