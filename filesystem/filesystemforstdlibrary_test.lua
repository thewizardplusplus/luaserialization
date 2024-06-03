local luaunit = require("luaunit")
local FileSystemForStdLibrary = require("luaserialization.filesystem.filesystemforstdlibrary")
local filesystem = require("luaserialization.filesystem.filesystem")

-- luacheck: globals TestFileSystemForStdLibrary
TestFileSystemForStdLibrary = {}

function TestFileSystemForStdLibrary.test_interface()
  local file_system = FileSystemForStdLibrary:new()

  local result = filesystem.is_file_system(file_system)
  luaunit.assert_true(result)
end
