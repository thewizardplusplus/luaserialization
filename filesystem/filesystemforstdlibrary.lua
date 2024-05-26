-- luacheck: no max comment line length

---
-- @classmod FileSystemForStdLibrary

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local filesystem = require("luaserialization.filesystem.filesystem")
local FileForStdLibrary = require("luaserialization.filesystem.fileforstdlibrary")

---
-- @table instance

local FileSystemForStdLibrary = middleclass("FileSystemForStdLibrary")

---
-- @function new
-- @treturn FileSystemForStdLibrary

---
-- @tparam string file_name
-- @tparam "r"|"w" file_opening_mode
-- @treturn FileForStdLibrary
function FileSystemForStdLibrary:open(file_name, file_opening_mode)
  assertions.is_string(file_name)
  assertions.is_true(filesystem.is_file_opening_mode(file_opening_mode))

  local file, err = io.open(file_name, file_opening_mode)
  if err ~= nil then
    return nil, "unable to open the file: " .. err
  end

  return FileForStdLibrary:new(file)
end

return FileSystemForStdLibrary
