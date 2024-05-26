local luaunit = require("luaunit")
local filesystem = require("luaserialization.filesystem.filesystem")
local assertions = require("luatypechecks.assertions")

local Object = {}

function Object:new(id)
  assertions.is_integer(id)

  local object = setmetatable({}, self)
  object.id = id

  return object
end

function Object.__call() end

-- luacheck: globals TestFileSystem
TestFileSystem = {}

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
  TestFileSystem[data.name] = function()
    local result = filesystem.is_file_opening_mode(data.args.value)

    luaunit.assert_is_boolean(result)
    data.want(result)
  end
end

-- filesystem.is_file_system()
for _, data in ipairs({
  {
    name = "test_is_file_system/nil",
    args = {
      value = nil,
    },
    want = luaunit.assert_false,
  },
  {
    name = "test_is_file_system/boolean",
    args = {
      value = true,
    },
    want = luaunit.assert_false,
  },
  {
    name = "test_is_file_system/number/integer",
    args = {
      value = 23,
    },
    want = luaunit.assert_false,
  },
  {
    name = "test_is_file_system/number/float",
    args = {
      value = 2.3,
    },
    want = luaunit.assert_false,
  },
  {
    name = "test_is_file_system/string",
    args = {
      value = "test",
    },
    want = luaunit.assert_false,
  },
  {
    name = "test_is_file_system/function",
    args = {
      value = function() end,
    },
    want = luaunit.assert_false,
  },
  {
    name = "test_is_file_system/table/empty",
    args = {
      value = {},
    },
    want = luaunit.assert_false,
  },
  {
    name = "test_is_file_system/table/with_non-callable_value",
    args = {
      value = { open = 23 },
    },
    want = luaunit.assert_false,
  },
  {
    name = "test_is_file_system/table/with_callable_value/function",
    args = {
      value = { open = function() end },
    },
    want = luaunit.assert_true,
  },
  {
    name = "test_is_file_system/table/with_callable_value/table",
    args = {
      value = { open = Object:new(23) },
    },
    want = luaunit.assert_true,
  },
  {
    name = "test_is_file_system/table/with_missed_method",
    args = {
      value = { test = function() end },
    },
    want = luaunit.assert_false,
  },
}) do
  TestFileSystem[data.name] = function()
    local result = filesystem.is_file_system(data.args.value)

    luaunit.assert_is_boolean(result)
    data.want(result)
  end
end

-- filesystem.is_file()
for _, data in ipairs({
  {
    name = "test_is_file/nil",
    args = {
      value = nil,
    },
    want = luaunit.assert_false,
  },
  {
    name = "test_is_file/boolean",
    args = {
      value = true,
    },
    want = luaunit.assert_false,
  },
  {
    name = "test_is_file/number/integer",
    args = {
      value = 23,
    },
    want = luaunit.assert_false,
  },
  {
    name = "test_is_file/number/float",
    args = {
      value = 2.3,
    },
    want = luaunit.assert_false,
  },
  {
    name = "test_is_file/string",
    args = {
      value = "test",
    },
    want = luaunit.assert_false,
  },
  {
    name = "test_is_file/function",
    args = {
      value = function() end,
    },
    want = luaunit.assert_false,
  },
  {
    name = "test_is_file/table/empty",
    args = {
      value = {},
    },
    want = luaunit.assert_false,
  },
  {
    name = "test_is_file/table/with_non-callable_values",
    args = {
      value = { read_all = 12, write = 23, close = 42 },
    },
    want = luaunit.assert_false,
  },
  {
    name = "test_is_file/table/with_callable_values/functions",
    args = {
      value = {
        read_all = function() end,
        write = function() end,
        close = function() end,
      },
    },
    want = luaunit.assert_true,
  },
  {
    name = "test_is_file/table/with_callable_values/tables",
    args = {
      value = {
        read_all = Object:new(12),
        write = Object:new(23),
        close = Object:new(42),
      },
    },
    want = luaunit.assert_true,
  },
  {
    name = "test_is_file/table/with_missed_methods/all",
    args = {
      value = {
        test = function() end,
      },
    },
    want = luaunit.assert_false,
  },
  {
    name = "test_is_file/table/with_missed_methods/some",
    args = {
      value = {
        read_all = function() end,
        write = function() end,
      },
    },
    want = luaunit.assert_false,
  },
}) do
  TestFileSystem[data.name] = function()
    local result = filesystem.is_file(data.args.value)

    luaunit.assert_is_boolean(result)
    data.want(result)
  end
end
