-- luacheck: no max comment line length

---
-- @classmod FileSystemForLoveFramework

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local filesystem = require("luaserialization.filesystem.filesystem")
local FileForLoveFramework = require("luaserialization.filesystem.fileforloveframework")

---
-- @table instance

local FileSystemForLoveFramework = middleclass("FileSystemForLoveFramework")

---
-- @function new
-- @treturn FileSystemForLoveFramework

---
-- @tparam string file_name
-- @tparam "r"|"w" file_opening_mode
-- @treturn FileForLoveFramework
-- @error error message
function FileSystemForLoveFramework:open(file_name, file_opening_mode)
  assertions.is_string(file_name)
  assertions.is_true(filesystem.is_file_opening_mode(file_opening_mode))

  local file, err = love.filesystem.newFile(file_name, file_opening_mode)
  if err ~= nil then
    return nil, "unable to open the file: " .. err
  end

  return FileForLoveFramework:new(file)
end

return FileSystemForLoveFramework
