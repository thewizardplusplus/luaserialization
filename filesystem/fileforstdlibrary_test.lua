local luaunit = require("luaunit")
local FileForStdLibrary = require("luaserialization.filesystem.fileforstdlibrary")
local filesystem = require("luaserialization.filesystem.filesystem")

-- luacheck: globals TestFileForStdLibrary
TestFileForStdLibrary = {}

function TestFileForStdLibrary.test_interface()
  local dummy_inner_file = io.output()
  local file = FileForStdLibrary:new(dummy_inner_file)

  local result = filesystem.is_file(file)
  luaunit.assert_true(result)

  luaunit.assert_equals(file._inner_file, dummy_inner_file)
end
