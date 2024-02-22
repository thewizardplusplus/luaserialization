-- luacheck: no max comment line length

---
-- @module data

local checks = require("luatypechecks.checks")

local data = {}

--- ⚠️. This function checks if the value has the `__data()` metamethod. If it has, the function replaces the value with the result of this metamethod. Otherwise, the function leaves it with no changes. Then this action is applied recursively to the elements of the value, if they exist (i.e., the value is a sequence or table).
-- @tparam any value
-- @treturn any
function data.to_data(value)
  if checks.has_metamethods(value, {"__data"}) then
    local value_metatable = getmetatable(value)
    value = value_metatable.__data(value)
  end

  if not checks.is_table(value) then
    return value
  end

  local transformed_value = {}
  for key, value in pairs(value) do -- luacheck: no redefined
    transformed_value[key] = data.to_data(value)
  end

  return transformed_value
end

return data
