-- functions for finding a place to respawn an entity
local Logger = require('common/logger')('spawn')
local tostring = require('common/tostring')
local stack = require('common/stack')

local MIN_PLAYER_DISTANCE = 64 * 1.2 -- this is our 'outer' sleep radius
local BASE_RADIUS = 20
local BASE_STRUCTURE_TAGS = { 'structure', 'wall' }
local EXCLUDE_RADIUS = 3
local INITIAL_RESPAWN_JITTER = 3
local MAX_RESPAWN_DISTANCE = MIN_PLAYER_DISTANCE * 1.2
local MAX_FIND_POINT_ATTEMPTS = 20
local RESPAWN_JITTER_INCREMENT = (MAX_RESPAWN_DISTANCE - INITIAL_RESPAWN_JITTER) / MAX_FIND_POINT_ATTEMPTS

local spawn = {}

local function spawnAt(product, x, y, z)
  Logger:enter('spawnAt(%s, %d, %d, %d)', product, x, y, z)
  local inst = SpawnPrefab(product)
  if inst then
    inst.Transform:SetPosition(x, y, z)
    return true
  else
    Logger:exit('spawnAt(%s, %d, %d, %d) => failed!', product, x, y, z)
    return false
  end
end

local function testForRegrow(x, y, z, origTile)
  Logger:enter('testForRegrow(%d, %d, %d, %d)', x, y, z, origTile)
  -- keep things in their biome (more or less)
  -- try to avoid roads
  if TheWorld.Map:GetTileAtPoint(x, y, z) ~= origTile or
      not TheWorld.Map:CanPlantAtPoint(x, y, z) or
      (RoadManager ~= nil and RoadManager:IsOnRoad(x, 0, z)) then
    Logger:exit('testForRegrow(%d, %d, %d) => Failed due to origTile', x, y, z)
    return false
  end

  local ents = TheSim:FindEntities(x,y,z, EXCLUDE_RADIUS)
  if #ents > 0 then
    -- Too dense
    Logger:exit('testForRegrow(%d, %d, %d) => Failed due to density', x, y, z)
    return false
  end

  if IsAnyPlayerInRange(x,y,z, MIN_PLAYER_DISTANCE, nil) then
    -- No regrowth around players
    Logger:exit('testForRegrow(%d, %d, %d) => Failed due to player in range', x, y, z)
    return false
  end

  local baseEnts = TheSim:FindEntities(x,y,z, BASE_RADIUS, nil, nil, BASE_STRUCTURE_TAGS)
  if #baseEnts > 0 then
    -- No regrowth around bases
    Logger:exit('testForRegrow(%d, %d, %d) => Failed due to player in base entities', x, y, z)
    return false
  end

  Logger:exit('testForRegrow(%d, %d, %d) => success', x, y, z)
  return true
end

function spawn.near(product, x, y, z)
  Logger:enter('near(%s, %d, %d, %d)', product, x, y, z)
  local origTile = TheWorld.Map:GetTileAtPoint(x, y, z)

  -- pick a random point within <maxRespawnDistance> from x,y,z
  -- if we shouldn't spawn in that location, then increase the <maxRespawnDistance> by <respawnIncrement>
  -- keep doing this until <maxRespawnDistance> exceeds the hard-coded limit <MAX_RESPAWN_DISTANCE>
  -- we will limit the attempts to find a valid respawn point to <MAX_FIND_POINT_ATTEMPTS>
  local maxRespawnDistance = INITIAL_RESPAWN_JITTER
  local validPoint
  repeat
    local theta = math.random() * 2 * PI
    local radius = math.random() * maxRespawnDistance
    local x2 = x + radius * math.cos(theta)
    local z2 = z - radius * math.sin(theta)

    if testForRegrow(x2, y, z2, origTile) then
      validPoint = Point(x2, y, z2)
    else
      maxRespawnDistance = maxRespawnDistance + RESPAWN_JITTER_INCREMENT
    end
  until MAX_RESPAWN_DISTANCE < maxRespawnDistance or validPoint ~= nil

  if validPoint then
    -- you have a valid point
    local x2, y2, z2 = validPoint:Get()
    local result = spawnAt(product, x2, y2, z2)
    Logger:exit('near(%s, %d, %d, %d) => %s', product, x, y, z, tostring(result))
    return result;
  else
    Logger:exit('near => failed')
    return false
  end
end

local function tryToFindPointInTileTypes(tileTypes)
  Logger:enter('tryToFindPointInTileTypes(tileTypes)')
  local remainingAttempts = 20
  repeat
    local pt = Point(math.random(-1000, 1000), 0, math.random(-1000, 1000))
    local tile = TheWorld.Map:GetTileAtPoint(pt.x, pt.y, pt.z)
    if stack.contains(tileTypes, tile) and testForRegrow(pt.x, pt.y, pt.z, tile) then
      Logger:enter('tryToFindPointInTileTypes(tileTypes) => %s', tostring.point(pt))
      return pt
    else
      remainingAttempts = remainingAttempts - 1
    end
  until remainingAttempts <= 0
  Logger:enter('tryToFindPointInTileTypes(tileTypes) => nil')
  return nil
end

function spawn.inTile(product, tileTypes)
  Logger:enter('inTile(%s, tileTypes)', product)
  local pt = tryToFindPointInTileTypes(tileTypes)
  if pt then
    local x, y, z = pt:Get()
    local result = spawnAt(product, x, y, z)
    Logger:exit('inTile(%s, tileTypes) => %s', product, tostring.any(result))
    return result;
  else
    Logger:exit('inTile(%s, tileTypes) => failed to find point in tile types', product)
    return false
  end
end

return spawn
