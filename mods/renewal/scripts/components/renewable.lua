local Logger = require('common/logger')('Renewable')
local tostring = require('common/tostring')
local stack = require('common/stack')
local controller = require('controller')

local Renewable = Class(function(component, inst)
  assert(TheWorld.ismastersim, 'Renewable should not exist on client')

  -- if we ever remove a tracked renewable, this code will have to change
  local groupName = assert(controller.GroupForMember(inst.prefab))
  local guids = {}
  local size = 0

  local function ClaimId()
    Logger:trace('%s[%s]:ClaimId()', inst.prefab, inst.GUID)
    size = size + 1
    controller.TakeGUID(groupName, inst.GUID, guids)
  end

  local function ReleaseId()
    Logger:trace('%s[%d]:ReleaseId()', inst.prefab, inst.GUID)
    local guid = stack.pop(guids)
    if guid then
      size = size - 1
      controller.GiveGUID(groupName, guid)
    end
  end

  function component:OnSave()
    return {
      guids = guids,
      size = size
    }
  end

  function component:OnLoad(data)
    if data then
      -- legacy
      guids = data.guids or data.GUIDs or guids
      size = data.size or size

      -- in case something strange happens during save/load
      -- the controller doesn't save the table with functions that save guids to our internal array
      while size < #guids do
        ClaimId()
      end
    end
  end

  -- main
  --
  --
  -- try to get an ID for this entity instance
  ClaimId()

  inst:ListenForEvent('onremove', function()
    Logger:debug('OnRemoved(%s[%d])', inst.prefab, inst.GUID)
    while not stack.isEmpty(guids) do
      controller.GiveGUID(groupName, stack.pop(guids))
    end
  end)

  -- manage guids for stackable entities (such as mandrakes or grass tufts)
  local stackable = inst.components.stackable
  if stackable then
    -- taken from scripts/stackable.lua (when 2 instances of stackable are combined or split):
    -- item:PushEvent("stacksizechange", {stacksize = item.components.stackable.stacksize, oldstacksize=num_to_add, src_pos = source_pos })
    -- self.inst:PushEvent("stacksizechange", {stacksize = self.stacksize, oldstacksize=oldsize, src_pos = source_pos})
    inst:ListenForEvent("stacksizechange", function(_, data)
      Logger:enter("stacksizechange(%s[%d]): %d => %d", inst.prefab, inst.GUID, data.oldstacksize, data.stacksize)
      local delta = data.stacksize - data.oldstacksize
      if delta > 0 then
        controller.IncreaseGroupCount(groupName, delta)
        while delta > 0 do
          ClaimId()
          delta = delta - 1
        end
      elseif delta < 0 then
        controller.DecreaseGroupCount(groupName, delta)
        while delta < 0 do
          ReleaseId()
          delta = delta + 1
        end
      end
    end)
  end

  -- if we don't have a guid at the end of the current sim clock tick, then permanently save our location
  inst:DoTaskInTime(0, function()
    if true == stack.isEmpty(guids) then
      Logger:debug('%s[%d] claimed its own id (%s)', inst.prefab, inst.GUID, tostring.any(guids))
      if groupName == inst.prefab then
        local x, y, z = inst.Transform:GetWorldPosition()
        controller.SetInitialLocation(groupName, inst.GUID, x, y, z)
      else
        Logger:error('orphaned %s[%d] in group %s has no tracked GUID!', inst.prefab, inst.GUID, groupName)
      end
    end
  end)
end)

return Renewable
