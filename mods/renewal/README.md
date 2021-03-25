# About the Mod
The purpose of this Don't Starve Together (DST) mod is to re-spawn certain entities which are highly difficult or impossible to replace. Mandrakes and moonglass rocks are great examples.  
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

