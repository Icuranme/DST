https://guides.github.com/features/mastering-markdown/

# About the Mod
The purpose of this DST mod is to re-spawn certain entities which are highly difficult or impossible to replace. Mandrakes and moonglass rocks are great examples.  
Because the author prefers resources to be as difficult to get in the end-game as they were in the beginning game.

Although this document is targeted at those who already have a basic understanding of the DST api, others who know LUA might learn about DST api from this.

Some concepts in this document are interlinked, so it might take a couple readings to put the concepts together.

# Use-Cases

1) An immobile entity is removed from the game
<br/>If there are fewer entities of that kind in the game now than when worldgen finished, then queue a future respawn event for that kind of entity at the location it is currently.

2) A mobile entity is removed from the game
<br/>If there are fewer entities of that kind in the game now than when worldgen finished, then queue a future respawn even for that kind of entity at the location worldgen originally spawned it.

3) We failed to respawn an entity when we should have
<br/>Periodically check if ((the current number of entities of each kind) + (the number queued to respawn later)) is less than (the number of that kind of entity existed immediately after worldgen finished spawning entities). If the count is below the initial count, then look for a suitable location to respawn it.

# Event Driven

To accomplish the goals, we listen for a few events:

Event |code
----- | ----
Entity Creation | AddPrefabPostInit
Entity Removal | inst:ListenForEvent("onremove", function() ... end)
Stack Size Change | inst:ListenForEvent("stacksizechange", function(...) ... end)
Periodic | inst:DoTaskInTime(1, function() ... end)

# File Breakdown
There isn't necessarily a reason for the directory structure, other than the components directory of course.
api/spawn.lua is used to spawn new entities. It finds a suitable location.
common/ this folder is filled with common code that's easily reused, even outside DST
components/moreconstant.lua added to either forest or cave entity, and is used to save all the static data and orchestrate events
components/renewable.lua added to entities that can be moved but should respawn at the location worldgen created them
model/ModMainConfig.lua is a data structure for initial configuration (used in mod-main only). This mod would probably be better off w/out this file, but it would be a pain to remove at this point.
controller.lua has all of the data saved and loaded by the moreconstant component. It provides global methods to manipulate this data w/out needing a reference to the moreconstant component.

# Known Issues

* When logging is turned too high, the game slows down way too much, especially when it saves data each morning.
* Noticed a lot of cases where things are unexpectedly being added to the world post-gen, like saplings for example. Haven't figured that one out.
* Taking an item (like a mandrake or dug_sapling) from the caves to forest or vice-versa will cause the game to think it's been removed, even though it hasn't. Need to both track the initial shard something came from and data sharing among server shards.

