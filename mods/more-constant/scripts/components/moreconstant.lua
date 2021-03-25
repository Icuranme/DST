--------------------------------------------------------------------------------
--[[component]]
--------------------------------------------------------------------------------

local Logger = require('common/logger')('moreconstant')
local controller = require('controller')

local MoreConstant = Class(function(component, world)
  assert(TheWorld.ismastersim, 'Renewal should not exist on client')

  local UPDATE_PERIOD = 29
  world:DoPeriodicTask(UPDATE_PERIOD, function()
    controller.UpdateTime(UPDATE_PERIOD)
    controller.DoRespawns()
  end)

  local RECOUNT_PERIOD = 961
  world:DoPeriodicTask(RECOUNT_PERIOD, function()
    Logger:enter('DoPeriodicTask(RECOUNT_PERIOD = %d)', RECOUNT_PERIOD)
    -- TODO: check how needed this is by comparing before and after
    controller.TryToRestoreEntityCounts()
  end)

  function component:OnSave()
    return controller.OnSave()
  end

  function component:OnLoad(data)
    controller.OnLoad(data)
  end

  world:DoTaskInTime(2, function()
    controller.Init()
  end)

  Logger:info('Renewal Created')
end)

return MoreConstant
