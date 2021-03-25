local subtable = {}

function subtable.getOrCreateSubtable(base, key)
  local bucket = base[key]
  if not bucket then
    bucket = {}
    base[key] = bucket
  end
  return bucket
end

return subtable
