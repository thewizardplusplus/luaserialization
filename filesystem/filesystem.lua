-- luacheck: no max comment line length

---
-- @module filesystem

local checks = require("luatypechecks.checks")

local filesystem = {}

--- ⚠️. Checks that the value is "r" or "w".
-- @tparam any value
-- @treturn bool
function filesystem.is_file_opening_mode(value)
  return checks.is_enumeration(value, {"r", "w"})
end

--- ⚠️. Checks that the value has the method `open()`.
-- @tparam any value
-- @treturn bool
function filesystem.is_file_system(value)
  return checks.has_methods(value, {"open"})
end

--- ⚠️. Checks that the value has the methods `read_all()`, `write()`, and `close()`.
-- @tparam any value
-- @treturn bool
function filesystem.is_file(value)
  return checks.has_methods(value, {"read_all", "write", "close"})
end

return filesystem
