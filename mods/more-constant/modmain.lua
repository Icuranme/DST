-- If you're trying to use this as an example for your mod, you should know that I learned from the game source code itself, as well as other mods
-- Do note that you should learn how to program in LUA. Let me put it this way, I'm glad LUA wasn't my first programming language. But that's subjective.
-- see C:\Apps\Steam\steamapps\common\Don't Starve Together\data\databundles\scripts.zip
--   components/regrowthmanager.lua
--   prefab/carrot.lua
-- I believe in documenting code ;) Please do.

--------------------------------------------------------------------------
--[[CONFIG]]
--------------------------------------------------------------------------
local LoggerFactory = require('common/logger').init("more_constant", true):enableTrace()
local Logger = LoggerFactory("modmain")

local ModMainConfig = require("model/ModMainConfig")
local controller = require('controller')

--------------------------------------------------------------------------
--[[MAIN]]
--------------------------------------------------------------------------

local function return1()
  return 1
end

local function isSpring()
  return GLOBAL.TheWorld.state.isspring
end

local function isSummer()
  return GLOBAL.TheWorld.state.issummer
end

local function isWinter()
  return GLOBAL.TheWorld.state.iswinter
end

local function isRaining()
  return GLOBAL.TheWorld.state.israining
end

local function hasSnow()
  return 0 < GLOBAL.TheWorld.state.snowlevel
end

local function plants()
  return (isRaining() and 2)
      or (isSpring() and 1.5)
      or ((isWinter() or isSummer()) and 0.2)
      or 1
end

local function mushrooms()
  return (hasSnow() and 0)
      or plants()
end

local configs = {}

local function config(prefab)
  local result = ModMainConfig:new(prefab)
  table.insert(configs, result)
  return result
end

----plants
config("berrybush"):SetDelay(GetModConfigData("berrybush")):SetDelayModifierFn(plants):FromInitialLocation():SetMembers({ "dug_berrybush" })
config("berrybush2"):SetDelay(GetModConfigData("berrybush2")):SetDelayModifierFn(plants):FromInitialLocation():SetMembers({ "dug_berrybush2" })
config("berrybush_juicy"):SetDelay(GetModConfigData("berrybush_juicy")):SetDelayModifierFn(plants):FromInitialLocation():SetMembers({ "dug_berrybush_juicy" })
config("cactus"):SetDelay(GetModConfigData("cactus")):SetDelayModifierFn(return1)
config("oasis_cactus"):SetDelay(GetModConfigData("oasis_cactus")):SetDelayModifierFn(return1)
config("evergreen_sparse"):SetDelay(GetModConfigData("evergreen_sparse")):SetDelayModifierFn(return1)
----config("flower"):SetDelay(30):SetDelayModifierFn(plants) -- already done by regrowthmanager
config("flower_evil"):SetDelay(GetModConfigData("flower_evil")):SetDelayModifierFn(return1)
config("grass"):SetDelay(GetModConfigData("grass")):SetDelayModifierFn(plants):SetMembers({ "dug_grass", "grassgekko", "grass_water" })
config("livingtree"):SetDelay(GetModConfigData("livingtree")):SetDelayModifierFn(return1)
config("mandrake_planted"):SetDelay(GetModConfigData("mandrake_planted")):SetDelayModifierFn(plants):FromInitialLocation():SetMembers({ "mandrake_active", "mandrake", "cookedmandrake", "mandrakesoup" })
config("marsh_bush"):SetDelay(GetModConfigData("marsh_bush")):SetDelayModifierFn(plants)
config("marsh_tree"):SetDelay(GetModConfigData("marsh_tree")):SetDelayModifierFn(plants)
config("blue_mushroom"):SetDelay(GetModConfigData("blue_mushroom")):SetDelayModifierFn(mushrooms)
config("red_mushroom"):SetDelay(GetModConfigData("red_mushroom")):SetDelayModifierFn(mushrooms)
config("green_mushroom"):SetDelay(GetModConfigData("green_mushroom")):SetDelayModifierFn(mushrooms)
config("mushtree_small"):SetDelay(GetModConfigData("mushtree_small")):SetDelayModifierFn(mushrooms)
config("mushtree_medium"):SetDelay(GetModConfigData("mushtree_medium")):SetDelayModifierFn(mushrooms)
config("mushtree_tall"):SetDelay(GetModConfigData("mushtree_tall")):SetDelayModifierFn(mushrooms)
config("mushtree_moon"):SetDelay(GetModConfigData("mushtree_moon")):SetDelayModifierFn(return1)
config("reeds"):SetDelay(GetModConfigData("reeds")):SetDelayModifierFn(plants)
config("rock_avocado_bush"):SetDelay(GetModConfigData("rock_avocado_bush")):SetDelayModifierFn(plants):SetMembers({ "dug_rock_avocado_bush" })
config("sapling"):SetDelay(GetModConfigData("sapling")):SetDelayModifierFn(plants):SetMembers({ "dug_sapling" })
--config("twiggytree"):SetDelay(30):SetDelayModifierFn(plants)
--
----bees
config("beehive"):SetDelay(GetModConfigData("beehive")):SetDelayModifierFn(return1)
config("wasphive"):SetDelay(GetModConfigData("wasphive")):SetDelayModifierFn(return1)
--
----chess
config("bishop"):SetDelay(GetModConfigData("bishop")):SetDelayModifierFn(return1)
config("knight"):SetDelay(GetModConfigData("knight")):SetDelayModifierFn(return1)
config("rook"):SetDelay(GetModConfigData("rook")):SetDelayModifierFn(return1)
--
----spawners
config("catcoonden"):SetDelay(GetModConfigData("catcoonden")):SetDelayModifierFn(return1)
config("houndmound"):SetDelay(GetModConfigData("houndmound")):SetDelayModifierFn(return1)
config("mermhouse"):SetDelay(GetModConfigData("mermhouse")):SetDelayModifierFn(return1)
config("molehill"):SetDelay(GetModConfigData("molehill")):SetDelayModifierFn(return1)
config("moonglass_wobster_den"):SetDelay(GetModConfigData("moonglass_wobster_den")):SetDelayModifierFn(return1)
config("moonspiderden"):SetDelay(GetModConfigData("moonspiderden")):SetDelayModifierFn(return1)
--config("rabbithole"):SetDelay(30):SetDelayModifierFn(return1)
config("tallbirdnest"):SetDelay(GetModConfigData("tallbirdnest")):SetDelayModifierFn(return1)
--
----monsters/animals
config("carrat"):SetDelay(GetModConfigData("carrat")):SetDelayModifierFn(return1)
config("fireflies"):SetDelay(GetModConfigData("fireflies")):SetDelayModifierFn(return1)
config("fruitdragon"):SetDelay(GetModConfigData("fruitdragon")):SetDelayModifierFn(return1)
config("grassgekko"):SetDelay(GetModConfigData("grassgekko")):SetDelayModifierFn(return1)
config("lightninggoat"):SetDelay(GetModConfigData("lightninggoat")):SetDelayModifierFn(return1)
config("tentacle"):SetDelay(GetModConfigData("tentacle")):SetDelayModifierFn(return1)
--
----mineable
config("grotto_pool_big"):SetDelay(GetModConfigData("grotto_pool_big")):SetDelayModifierFn(return1):SetMembers({ "grotto_pool_small" })
config("moonglass_rock"):SetDelay(GetModConfigData("moonglass_rock")):SetDelayModifierFn(return1)
config("rock1"):SetDelay(GetModConfigData("rock1")):SetDelayModifierFn(return1)
config("rock2"):SetDelay(GetModConfigData("rock2")):SetDelayModifierFn(return1)
config("rock_flintless"):SetDelay(GetModConfigData("rock_flintless")):SetDelayModifierFn(return1):SetMembers({ "rock_flintless_med", "rock_flintless_low" })
config("rock_moon"):SetDelay(GetModConfigData("rock_moon")):SetDelayModifierFn(return1)
config("stalagmite_full"):SetDelay(GetModConfigData("stalagmite_full")):SetDelayModifierFn(return1):SetMembers({ "stalagmite_med", "stalagmite_low" })
config("stalagmite_tall_full"):SetDelay(GetModConfigData("stalagmite_tall_full")):SetDelayModifierFn(return1):SetMembers({ "stalagmite_tall_med", "stalagmite_tall_low" })

-- main starts here

-- simple version where we don't track initial location. Just publish creation and removal events
local function setupSimple(cfg)
  local groupName = cfg.group.product
  local function __setupSimple_subroutine(prefab)
    AddPrefabPostInit(prefab, function(inst)
      if GLOBAL.TheWorld.ismastersim then
        if Logger:isDebugEnabled() then
          if groupName == inst.prefab then
            Logger:debug("Prefab spawned: " .. inst.prefab)
          else
            Logger:debug("Prefab spawned: %s in group %s", inst.prefab, groupName)
          end
        end
        controller.IncreaseGroupCount(groupName, 1)

        inst:ListenForEvent("onremove", function()
          if Logger:isDebugEnabled() then
            if groupName == inst.prefab then
              Logger:debug("Prefab removed: " .. inst.prefab)
            else
              Logger:debug("Prefab removed: %s in group %s", inst.prefab, groupName)
            end
          end
          controller.DecreaseGroupCount(groupName, 1)

          local x, y, z = inst.Transform:GetWorldPosition()
          controller.ScheduleRespawn(groupName, x, y, z)
        end)
      end
    end)
  end

  __setupSimple_subroutine(cfg.group.product)
  for _, member in ipairs(cfg.members) do
    __setupSimple_subroutine(member)
  end
end

local function setupFromInitialLocation(cfg)
  AddPrefabPostInit(cfg.group.product, function(inst)
    if GLOBAL.TheWorld.ismastersim then
      inst:AddComponent("renewable")
    end
  end)

  for _, member in ipairs(cfg.members) do
    AddPrefabPostInit(member, function(inst)
      if GLOBAL.TheWorld.ismastersim then
        inst:AddComponent("renewable")
      end
    end)
  end
end

-- Setup All the groups
--
for _, cfg in ipairs(configs) do
  local group = cfg.group
  controller.DefineGroup({
    product = group.product,
    members = cfg.members,
    delay = group.delay,
    timeModFn = cfg.timeModFn
  })

  if 0 <= group.delay then
    if group.fromInitialLocation then
      setupFromInitialLocation(cfg)
    else
      setupSimple(cfg)
    end
  end
end
Logger:debug("Done configuring groups")
configs = nil

-- Add the main component to either the forest or cave
--
for _, prefab in ipairs({ "forest", "cave" }) do
  local firstPrefab = nil
  AddPrefabPostInit(prefab, function(inst)
    if GLOBAL.TheWorld.ismastersim then

      if firstPrefab then
        Logger:error("%s is the second to init after %s", prefab, firstPrefab)
        return
      end
      firstPrefab = prefab

      Logger:debug("adding components to %s", prefab)
      inst:AddComponent("moreconstant")
    end
  end)
end

--------------------------------------------------------------------------
--[[END RENEWAL MOD]]
--------------------------------------------------------------------------
