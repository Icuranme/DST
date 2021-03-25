local Logger = require('common/logger')('controller')
local tostring = require('common/tostring')
local Set = require('common/set')
local Stack = require('common/stack')
local Spawn = require('api/spawn')

--------------------------------------------------------------------------------
-- MODEL
--------------------------------------------------------------------------------
-- Welcome new comer. These notes are for you. Little bit of regex in them, but I can only take you so far.
-- Key:
-- alias means the left-hand-side is another name for the data type on the right-hand-side
-- transient means isn't not saved (like the Java keyword), this is usually b/c it's setup by modmain
-- function<returnType, [parameterName: dataType]*>
-- table<[keyName:] keyDataType, [valueName:] valueDataType>
-- int is a non-fractional number

-- alias prefab string
-- alias groupName prefab
-- alias guid int -- assigned by DST Sim
-- alias timeModFn function<number>
-- alias point (x, y, z)

-- boolean
local loaded = false

-- transient array<string>
local groupNames = {}

-- transient table<prefab, groupName>
local group_ForPrefab = {}

-- transient table<groupName, int>
local group_currentCount = {}

-- table<groupName, int>
local group_initialCount = {}

-- table<groupName, array<int>>
local group_initialTiles = {}

-- table<groupName, int>
local group_delay = {}

-- table<groupName, int>
local group_simTime = {}

-- transient table<timeModFn, array<groupName>>
local time_functions = {}

-- table<guid, point>
local trackable_initialLocations = {}

-- transient table<groupName, stack<function<void, guid>>>
local trackable_waitingForGUID = {}

-- table<groupName, array<guid>>
local trackable_unclaimedGUIDs = {}

-- table<groupName, array<point>>
local respawn_failedRespawn = {}

-- table<simTime, array<(groupName, x, y, z)>
local respawn_future = {}

-- this is the "name-space" for this lua file
local Controller = {}

--------------------------------------------------------------------------------
-- locals
--------------------------------------------------------------------------------

local function removeByKey(t, k)
  local v = t[k]
  if v then
    t[k] = nil
  end
  return v
end

local function recountEnts()
  Logger:enter('recountEnts()')
  group_currentCount = {}
  for _, entity in pairs(Ents) do
    if entity then
      local group = group_ForPrefab[entity.prefab]
      if group then
        local count = (entity.components and entity.components.stackable and entity.components.stackable:StackSize()) or 1
        group_currentCount[group] = (group_currentCount[group] or 0) + count
      end
    end
  end
  Logger:exit('recountEnts()')
end

local function recountEntities()
  if next(Ents) == nil then
    TheWorld:DoTaskInTime(1, recountEntities)
  else
    recountEnts()
  end
end

local function RecordInitialCountsAndTiles()
  Logger:enter('RecordInitialCountsAndTiles()')
  for _, entity in pairs(Ents) do
    local group = group_ForPrefab[entity.prefab]
    if group then
      group_initialCount[group] = group_initialCount[group] + 1
      local x, y, z = entity.Transform:GetWorldPosition()
      local tileTypeId = TheWorld.Map:GetTileAtPoint(x, y, z)

      -- mimic a set by inserting keys instead of values
      local tileTypes = group_initialTiles[group]
      if not tileTypes then
        tileTypes = {}
        group_initialTiles[group] = tileTypes
      end
      Set.add(tileTypes, tileTypeId)
    end
  end

  for group, tileTypeSet in pairs(group_initialTiles) do
    local tileTypeArray = {}
    for value in Set.values(tileTypeSet) do
      table.insert(tileTypeArray, value)
    end
    table.sort(tileTypeArray)
    group_initialTiles[group] = tileTypeArray
  end
  Logger:exit("RecordInitialCountsAndTiles()")
end

local function SanityCheckAfterLoad()
  local newGroupAdded = false
  for groupName in Set.values(groupNames) do
    local initialCount = group_initialCount[groupName]
    if not initialCount then
      Logger:warn("missing initial count for %s", groupName)
      group_initialCount[groupName] = 0
    elseif initialCount <= 0 then
      local currentCount = group_currentCount[groupName] or 0
      Logger:warn("%s have no initial count: %d", groupName, currentCount)
      -- if currentCount is 0 after a full recount, it's marked as -1 on the assumption it won't be added after world-gen. The full recount does happen some times though, so ...
      if currentCount >= 0 then
        newGroupAdded = true
        Logger:warn("%s has current count: %d", groupName, currentCount)
      end
    end
  end

  if true == newGroupAdded then
    TheWorld:DoTaskInTime(1, function()
      recountEntities()

      for groupName in Set.values(groupNames) do
        if group_currentCount[groupName] == 0 then
          group_currentCount[groupName] = -1
        else
          Logger:warn('updated missing { product = "%s", initialCount = %d, currentCount = %d }', (groupName or "<nil>"), (group_initialCount[groupName] or -999), (group_currentCount[groupName] or -999))
          group_initialCount[groupName] = group_currentCount[groupName]
        end
      end
    end)
  end
end

local function CompatibilityOnLoad(data)
  if data.setup then
    loaded = (data.setup.loaded ~= nil and data.setup.loaded) or loaded
  end

  if data.groups then
    for prefab, savedGroupData in pairs(data.groups) do
      group_initialCount[prefab] = savedGroupData.initialCount
      group_initialTiles[prefab] = savedGroupData.initialTiles
      group_simTime[prefab] = savedGroupData.simTime
    end
  end

  if data.renewables then
    local renewables = data.renewables
    if renewables.initialLocations then
      trackable_initialLocations = renewables.initialLocations
    elseif renewables.saved then
      trackable_initialLocations = renewables.saved
    end

    if renewables.unclaimed then
      trackable_unclaimedGUIDs = renewables.unclaimed
    end
  end

  if data.respawnTrackers then
    if data then
      respawn_future = data.respawnTrackers or respawn_future
      respawn_failedRespawn = data.onremoveLocationTracker or respawn_failedRespawn
    end
  end
end

local function scheduleRespawnByGUID(groupName, guid)
  local point = trackable_initialLocations[guid]
  if point then
    Controller.ScheduleRespawn(groupName, point.x, point.y, point.z)
  else
    Logger:error("ScheduleRespawnByGUID(%s, %s)", tostring(groupName), tostring(guid))
  end
end

local function fixGroupData()

end

--------------------------------------------------------------------------------

function Controller.OnSave()
  Logger:enter('OnSave()')
  local data = {
    loaded = loaded,
    group_initialCount = group_initialCount,
    group_initialTiles = group_initialTiles,
    group_delay = group_delay,
    group_simTime = group_simTime,
    trackable_initialLocations = trackable_initialLocations,
    trackable_unclaimedGUIDs = trackable_unclaimedGUIDs,
    respawn_failedRespawn = respawn_failedRespawn,
    respawn_future = respawn_future,
  }
  if Logger:isTraceEnabled() then
    -- TODO: print by group
    Logger:trace('OnSave() => loaded = %s', tostring.any(data))
    Logger:trace('OnSave() => group_initialCount = %s', tostring.table(group_initialCount))
    Logger:trace('OnSave() => group_initialTiles = %s', tostring.table(group_initialTiles))
    Logger:trace('OnSave() => group_delay = %s', tostring.table(group_delay))
    Logger:trace('OnSave() => group_simTime = %s', tostring.table(group_simTime))
    Logger:trace('OnSave() => trackable_initialLocations = %s', tostring.table(trackable_initialLocations))
    Logger:trace('OnSave() => trackable_unclaimedGUIDs = %s', tostring.table(trackable_unclaimedGUIDs))
    Logger:trace('OnSave() => respawn_failedRespawn = %s', tostring.table(respawn_failedRespawn))
    Logger:trace('OnSave() => respawn_future = %s', tostring.table(respawn_future))
  end
  Logger:exit('OnSave()')
  return data
end

function Controller.OnLoad(data)
  Logger:enter('OnLoad(%s)', tostring(data))
  if data then
    loaded = (data.loaded ~= nil and data.loaded) or loaded
    group_initialCount = data.group_initialCount or group_initialCount
    group_initialTiles = data.group_initialTiles or group_initialTiles
    group_delay = data.group_delay or group_delay
    group_simTime = data.group_simTime or group_simTime
    trackable_initialLocations = data.trackable_initialLocations or trackable_initialLocations
    trackable_unclaimedGUIDs = data.trackable_unclaimedGUIDs or trackable_unclaimedGUIDs
    respawn_failedRespawn = data.respawn_failedRespawn or respawn_failedRespawn
    respawn_future = data.respawn_future or respawn_future

    CompatibilityOnLoad(data)
    SanityCheckAfterLoad()
    Logger:trace('OnLoad() => loaded = %s', tostring.any(data))
    Logger:trace('OnLoad() => group_initialCount = %s', tostring.table(group_initialCount))
    Logger:trace('OnLoad() => group_initialTiles = %s', tostring.table(group_initialTiles))
    Logger:trace('OnLoad() => group_delay = %s', tostring.table(group_delay))
    Logger:trace('OnLoad() => group_simTime = %s', tostring.table(group_simTime))
    Logger:trace('OnLoad() => trackable_initialLocations = %s', tostring.table(trackable_initialLocations))
    Logger:trace('OnLoad() => trackable_unclaimedGUIDs = %s', tostring.table(trackable_unclaimedGUIDs))
    Logger:trace('OnLoad() => respawn_failedRespawn = %s', tostring.table(respawn_failedRespawn))
    Logger:trace('OnLoad() => respawn_future = %s', tostring.table(respawn_future))
  end
  Logger:exit('OnLoad(%s)', tostring(data))
end

function Controller.DefineGroup(data)
  local product = assert(data.product)
  assert('string' == type(product))
  local delay = assert(data.delay)
  assert('number' == type(delay))
  local timeModFn = assert(data.timeModFn)
  assert('function' == type(timeModFn))

  Set.add(groupNames, product)
  group_ForPrefab[product] = product
  if data.members then
    for _, member in ipairs(data.members) do
      group_ForPrefab[member] = product
    end
  end
  group_currentCount[product] = group_currentCount[product] or 0
  group_initialCount[product] = group_initialCount[product] or 0
  group_initialTiles[product] = group_initialTiles[product] or {}
  group_delay[product] = delay
  group_simTime[product] = group_simTime[product] or 0
  time_functions[timeModFn] = time_functions[timeModFn] or {}
  trackable_waitingForGUID[product] = trackable_waitingForGUID[product] or {}
  trackable_unclaimedGUIDs[product] = trackable_unclaimedGUIDs[product] or {}
  respawn_failedRespawn[product] = respawn_failedRespawn[product] or {}
  table.insert(time_functions[timeModFn], product)
end

function Controller.GroupForMember(prefab)
  return group_ForPrefab[prefab]
end

function Controller.Init()
  if loaded == false then
    RecordInitialCountsAndTiles()
    loaded = true
  end
end

function Controller.UpdateTime(deltaGameTime)
  Logger:enter('UpdateTime(%d)', deltaGameTime)
  for gameTimeModFn, arrayOfGroup in pairs(time_functions) do
    local deltaSimTime = deltaGameTime * gameTimeModFn()
    for _, group in ipairs(arrayOfGroup) do
      group_simTime[group] = group_simTime[group] + deltaSimTime
    end
  end
  Logger:exit('UpdateTime(%d)', deltaGameTime)
end

function Controller.DoRespawns()
  Logger:enter('DoRespawns()')
  for simTime, array in pairs(respawn_future) do
    local newArray = {}
    for _, respawn in ipairs(array) do
      Logger:trace("DoRespawns() { simTime = %s, respawn = %s }", tostring.any(simTime), tostring.any(respawn))
      local groupName = respawn.productName
      local respawnTime = (group_simTime[groupName] or simTime)
      Logger:debug("if (%s < %s) then respawn a %s", tostring.any(group_simTime[groupName]), tostring.any(simTime), tostring.any(groupName))
      if respawnTime < simTime or true ~= Spawn.near(groupName, respawn.x, respawn.y, respawn.z) then
        table.insert(newArray, respawn)
      end
    end
    respawn_future[simTime] = newArray
  end

  for groupName, guidArray in pairs(trackable_unclaimedGUIDs) do
    for _, guid in ipairs(guidArray) do
      scheduleRespawnByGUID(groupName, guid)
    end
    trackable_unclaimedGUIDs[groupName] = {}
  end

  Logger:exit('DoRespawns()')
end

function Controller.TryToRestoreEntityCounts()
  Logger:enter('TryToRestoreEntityCounts()')
  recountEntities()
  for groupName in Set.values(groupNames) do
    local curr = group_currentCount[groupName]
    local targ = group_initialCount[groupName]
    if not groupName or not targ or not curr then
      Logger:info('missing curr and/or targ for %s (%s, %s)', tostring(groupName), tostring(targ), tostring(curr))
    elseif targ <= curr then
      Logger:info('increasing world-count for %s from %d to %d', groupName, targ, curr)
      group_initialCount[groupName] = curr
    else
      while curr < targ do
        curr = curr + 1
        -- consider peeking top and only popping if spawn is successful
        local failedRespawn = Stack.pop(respawn_failedRespawn[groupName])
        if failedRespawn then
          if Spawn.near(groupName, failedRespawn.x, failedRespawn.y, failedRespawn.z) then
            group_currentCount[groupName] = group_currentCount[groupName] + 1
          else
            Stack.push(respawn_failedRespawn[groupName], failedRespawn)
          end
        elseif Spawn.inTile(groupName, group_initialTiles[groupName]) then
          group_currentCount[groupName] = group_currentCount[groupName] + 1
        end
      end
    end
  end
end

function Controller.GiveGUID(groupName, guid)
  local functions = trackable_waitingForGUID[groupName]

  local function findAny()
    local k, fn = next(functions)
    functions[k] = nil
    return fn
  end

  local guidConsumerFn = removeByKey(functions, guid) or findAny()
  if guidConsumerFn then
    guidConsumerFn(guid)
  else
    Stack.push(trackable_unclaimedGUIDs[groupName], guid)
  end
end

function Controller.TakeGUID(groupName, guid, array)
  local unclaimedGUID = Stack.pop(trackable_unclaimedGUIDs[groupName])
  if unclaimedGUID then
    table.insert(array, unclaimedGUID)
  else
    -- save a function that will insert the guid later
    local waitingFunctions = trackable_waitingForGUID[groupName]
    if not waitingFunctions then
      waitingFunctions = {}
      trackable_waitingForGUID[groupName] = waitingFunctions
    end
    waitingFunctions[guid] = function(givenGUID)
      table.insert(array, givenGUID)
    end
  end
end

function Controller.SetInitialLocation(groupName, guid, x, y, z)
  trackable_initialLocations[guid] = { x = x, y = y, z = z }
  local fn = trackable_waitingForGUID[groupName][guid]
  trackable_waitingForGUID[groupName][guid] = nil
  fn(guid)
end

function Controller.IncreaseGroupCount(groupName, count)
  group_currentCount[groupName] = group_currentCount[groupName] + count
end

function Controller.DecreaseGroupCount(groupName, count)
  local newCount = group_currentCount[groupName] - count
  group_currentCount[groupName] = (0 <= newCount and newCount) or 0
end

function Controller.ScheduleRespawn(groupName, x, y, z)
  local currTime = group_simTime[groupName]
  local delay = group_delay[groupName]
  local simTime = currTime + delay
  local array = respawn_future[simTime]
  if not array then
    array = {}
    respawn_future[simTime] = array
  end
  table.insert(array, { productName = groupName, x = x, y = y, z = z })
end

return Controller
