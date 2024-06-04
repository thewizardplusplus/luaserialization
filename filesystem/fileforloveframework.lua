-- luacheck: no max comment line length

---
-- @classmod FileForLoveFramework

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")

---
-- @table instance
-- @tfield tab _inner_file file handle from the [Love framework](https://love2d.org/)

local FileForLoveFramework = middleclass("FileForLoveFramework")

---
-- @function new
-- @tparam tab inner_file file handle from the [Love framework](https://love2d.org/)
-- @treturn FileForLoveFramework
function FileForLoveFramework:initialize(inner_file)
  assertions.is_table(inner_file)

  self._inner_file = inner_file
end

---
-- @treturn string
function FileForLoveFramework:read_all()
  local data, _ = self._inner_file:read()
  return data
end

---
-- @tparam string data
-- @error error message
function FileForLoveFramework:write(data)
  assertions.is_string(data)

  local ok, err = self._inner_file:write(data)
  if err ~= nil then
    return nil, "unable to write the data: " .. err
  end

  local ok, err = self._inner_file:flush()
  if err ~= nil then
    return nil, "unable to flush the file: " .. err
  end
end

---
-- @function close
-- @error error message
function FileForLoveFramework:close()
  local ok = self._inner_file:close()
  if not ok then
    return nil, "unable to close the file"
  end
end

return FileForLoveFramework
