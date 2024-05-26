local luaunit = require("luaunit")
local filesystem = require("luaserialization.filesystem.filesystem")

-- luacheck: globals TestFilesystem
TestFilesystem = {}

-- filesystem.is_file_opening_mode()
for _, data in ipairs({
  {
    name = "test_is_file_opening_mode/nil",
    args = { value = nil },
    want = luaunit.assert_false,
  },
  {
    name = "test_is_file_opening_mode/boolean",
    args = { value = true },
    want = luaunit.assert_false,
  },
  {
    name = "test_is_file_opening_mode/number/integer",
    args = { value = 23 },
    want = luaunit.assert_false,
  },
  {
    name = "test_is_file_opening_mode/number/float",
    args = { value = 2.3 },
    want = luaunit.assert_false,
  },
  {
    name = "test_is_file_opening_mode/string",
    args = { value = "test" },
    want = luaunit.assert_false,
  },
  {
    name = "test_is_file_opening_mode/string/file_opening_mode/r",
    args = { value = "r" },
    want = luaunit.assert_true,
  },
  {
    name = "test_is_file_opening_mode/string/file_opening_mode/w",
    args = { value = "w" },
    want = luaunit.assert_true,
  },
  {
    name = "test_is_file_opening_mode/function",
    args = { value = function() end },
    want = luaunit.assert_false,
  },
  {
    name = "test_is_file_opening_mode/table",
    args = { value = {} },
    want = luaunit.assert_false,
  },
}) do
  TestFilesystem[data.name] = function()
    local result = filesystem.is_file_opening_mode(data.args.value)

    luaunit.assert_is_boolean(result)
    data.want(result)
  end
end
