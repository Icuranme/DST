ModMainConfig = {}

function ModMainConfig:new(groupName)
  assert(groupName, 'require groupName - should be a prefab')
  local o = {
    group = {
      product = groupName,
      currentCount = 0,
      initialCount = 0,
      initialTiles = {},
      simTime = 0,
      delay = 0,
      fromInitialLocation = false
    },
    members = {},
  }
  setmetatable(o, self)
  self.__index = self
  self.__tostring = self.ToString
  return o
end

function ModMainConfig:SetDelay(delay)
  self.group.delay = delay
  return self
end

function ModMainConfig:FromInitialLocation()
  self.group.fromInitialLocation = true
  return self
end

function ModMainConfig:SetDelayModifierFn(timeModFn)
  self.timeModFn = timeModFn
  return self
end

function ModMainConfig:SetMembers(members)
  self.members = members
  return self
end

return ModMainConfig
