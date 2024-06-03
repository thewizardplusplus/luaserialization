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

-- luacheck: globals TestFileSystemForStdLibraryIntegration
TestFileSystemForStdLibraryIntegration = {}

function TestFileSystemForStdLibraryIntegration:setUp()
  self.tmp_filename = os.tmpname()
  -- self.tmp_filename = string.format("/tmp/%d.%d", os.time(), math.random(1e9))
  print(string.format("created temporary file %q", self.tmp_filename))
end

function TestFileSystemForStdLibraryIntegration:tearDown()
  local ok, err = os.remove(self.tmp_filename)
  if err ~= nil then
    print(string.format("unable to remove temporary file %q: %s", self.tmp_filename, err))
  end
end

function TestFileSystemForStdLibraryIntegration:test_reading()
  local expected_content = "line #1\nline#2\n"

  local tmp_file = assert(io.open(self.tmp_filename, "w"))
  tmp_file:write(expected_content)
  tmp_file:flush()
  tmp_file:close()

  local file_system = FileSystemForStdLibrary:new()
  local file = assert(file_system:open(self.tmp_filename, "r"))
  local actual_content = assert(file:read_all())
  file:close()

  luaunit.assert_equals(actual_content, expected_content)
end

function TestFileSystemForStdLibraryIntegration:test_writing()
  local expected_content = "line #1\nline#2\n"

  local file_system = FileSystemForStdLibrary:new()
  local file = assert(file_system:open(self.tmp_filename, "w"))
  file:write(expected_content)
  file:close()

  local tmp_file = assert(io.open(self.tmp_filename, "r"))
  local actual_content = assert(tmp_file:read("*a"))
  tmp_file:close()

  luaunit.assert_equals(actual_content, expected_content)
end
