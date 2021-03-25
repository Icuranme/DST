-- don't print anything
local logger_level_off = 0

-- unrecoverable failure
local logger_level_error = 1

-- some code probably to be fixed
local logger_level_warn = 2

-- useful information that doesn't get printed often
local logger_level_info = 3

-- information to help determine what's wrong with the code, if anything
local logger_level_debug = 4

-- information that would otherwise get printed far too often but helps you see everything going on in the system
local logger_level_trace = 5

if not unpack then
  function unpack(t, i)
    if not t then
      return ''
    end
    i = i or 1
    if t[i] ~= nil then
      return t[i], unpack(t, i + 1)
    end
  end
end

-- returned from this file, is like the static version of the class
local static = {}
local logger = {}

local function errorHandler(err)
  print("Recovered[ERROR]: ", err)
end

local function log(self, levelStr, format, ...)
  local prefix = string.format('[%s][%s][%s] ', static.name, levelStr, self.name)
  if ... then
    local saveArgs = {...}
    local function f()
      print(prefix .. string.format(format, unpack(saveArgs)))
    end
    if not xpcall(f, errorHandler) then
      print(prefix .. tostring(format))
    end
  else
    print(prefix .. tostring(format))
  end
end

function logger:isErrorEnabled()
  return logger_level_error <= self.level and true or false
end

function logger:isWarnEnabled()
  return logger_level_warn <= self.level and true or false
end

function logger:isInfoEnabled()
  return logger_level_info <= self.level and true or false
end

function logger:isDebugEnabled()
  return logger_level_debug <= self.level and true or false
end

function logger:isTraceEnabled()
  return logger_level_trace <= self.level and true or false
end

function logger:enter(format, ...)
  if static.enterexit == true then
    log(self, 'ENTER', ">>>>" .. format, ...)
  end
end

function logger:exit(format, ...)
  if static.enterexit == true then
    log(self, 'EXIT ', "<<<<" .. format, ...)
  end
end

function logger:error(format, ...)
  if logger_level_error <= self.level then
    log(self, 'ERROR', format, ...)
  end
end

function logger:warn(format, ...)
  if logger_level_warn <= self.level then
    log(self, 'WARN', format, ...)
  end
end

function logger:info(format, ...)
  if logger_level_info <= self.level then
    log(self, 'INFO', format, ...)
  end
end

function logger:debug(format, ...)
  if logger_level_debug <= self.level then
    log(self, 'DEBUG', format, ...)
  end
end

function logger:trace(format, ...)
  if logger_level_trace <= self.level then
    log(self, 'TRACE', format, ...)
  end
end

function logger:disable()
  self.level = logger_level_off
  return self
end

function logger:enableError()
  self.level = logger_level_error
  return self
end

function logger:enableWarn()
  self.level = logger_level_warn
  return self
end

function logger:enableInfo()
  self.level = logger_level_info
  return self
end

function logger:enableDebug()
  self.level = logger_level_debug
  return self
end

function logger:enableTrace()
  self.level = logger_level_trace
  return self
end

local function newInstance(name)
  assert(static.name, 'You forgot to initialize loggers with `require("logger").init(name: string, enterexit: bool):enableInfo()` in modmain')
  assert('string' == type(name), 'name must be a string. Make sure you called this with a . instead of a :')
  local r = {
    name = name,
    level = static.level
  }
  setmetatable(r, {
    __index = logger
  })
  return r
end

local loggerByName = {}
function static.getLogger(self, name)
  assert('string' == type(name), 'name must be a string. Make sure you called this with a : instead of a .')
  local r = loggerByName[name]
  if nil == r then
    r = newInstance(name)
    loggerByName[name] = r
    print('created logger for ' .. name)
  else
    print('got logger for ' .. name)
  end
  return r
end

function static.init(name, enterexit)
  assert('string' == type(name), 'name must be a string. Make sure you called this with a . instead of a :')
  static.name = name
  static.level = logger_level_info
  static.enterexit = enterexit or false
  return static
end

setmetatable(static, {
  __index = logger,
  __call = static.getLogger
})

return static
