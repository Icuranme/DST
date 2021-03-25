local stack = {}

stack.push = table.insert

function stack.remove(tbl, value)
    for i, v in ipairs(tbl) do
      if v == value then
        table.remove(tbl, i)
        return v
      end
    end
end

function stack.pop(tbl)
  local size = stack.size(tbl)
  if 0 < size then
    local r = tbl[size]
    table.remove(tbl)
    return r
  else
    return nil
  end
end

function stack.contains(tbl, value)
  for _, v in ipairs(tbl) do
    if v == value then
      return true
    end
  end
  return false
end

function stack.size(tbl)
  return (tbl and #tbl) or 0
end

function stack.isEmpty(tbl)
  return (0 == stack.size(tbl) and true) or false
end

return stack
