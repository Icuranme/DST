local Set = {}

function Set.add(table, value)
  table[value] = true
end

function Set.remove(table, value)
  table[value] = nil
end

function Set.contains(table, value)
  return true == table[value]
end

local function set_pairs(table, key)
  local nextKey, v = next(table, key)
  if true == v then
    return nextKey
  end
end

function Set.values(table)
  -- this isn't really needed. You can do `for k in pairs(myset) do`
  -- although given how unstructured LUA is, there may be some bug this avoids
  return set_pairs, table, nil
end

return Set
