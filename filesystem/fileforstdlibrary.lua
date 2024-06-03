-- luacheck: no max comment line length

---
-- @classmod FileForStdLibrary

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")

---
-- @table instance
-- @tfield tab _inner_file file handle from the standard library

local FileForStdLibrary = middleclass("FileForStdLibrary")

---
-- @function new
-- @tparam tab inner_file file handle from the standard library
-- @treturn FileForStdLibrary
function FileForStdLibrary:initialize(inner_file)
  assertions.is_table(inner_file)

  self._inner_file = inner_file
end

---
-- @treturn string
-- @error error message
function FileForStdLibrary:read_all()
  local data = self._inner_file:read("*a")
  if data == nil then
    return nil, "unable to read the data"
  end

  return data
end

---
-- @tparam string data
function FileForStdLibrary:write(data)
  assertions.is_string(data)

  self._inner_file:write(data)
  self._inner_file:flush()
end

---
-- @function close
function FileForStdLibrary:close()
  self._inner_file:close()
end

return FileForStdLibrary
