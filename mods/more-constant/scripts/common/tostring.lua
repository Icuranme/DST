local default_tostring = tostring

local tostring = {}

function tostring.point(point)
  if point and point.x and point.y and point.z then
    return string.format('(%d, %d, %d)', point.x, point.y, point.z)
  else
    return tostring.any(point)
  end
end

local function __formatTable(prefix, tbl, set)
  set[tbl] = true
  local indent = prefix .. '  '
  local r = default_tostring(tbl) .. '{\n'
  for k, v in pairs(tbl) do
    if set[v] ~= nil then
      -- this won't protect us from infinite loops if a contains b and b contains a
      r = r .. string.format('%s%s = ^%s^\n', indent, default_tostring(k), default_tostring(v))
    elseif 'table' == type(v) then
      set[v] = true
      r = r .. string.format('%s%s = %s\n', indent, default_tostring(k), __formatTable(indent, v, set))
    else
      r = r .. string.format('%s%s = %s\n', indent, default_tostring(k), tostring.any(v))
    end
  end
  r = r .. prefix .. '}'
  return r
end

function tostring.table(tbl)
  assert('table' == type(tbl), 'expected table but found ' .. type(tbl))
  return __formatTable('', tbl, {})
end

function tostring.any(obj)
  if nil == obj then
    return 'nil'
  elseif 'string' == type(obj) then
    return '"' .. obj .. '"'
  elseif 'table' == type(obj) then
    return __formatTable('', obj, {})
  else
    return default_tostring(obj)
  end
end

setmetatable(tostring, {
  __call = default_tostring
})

return tostring
