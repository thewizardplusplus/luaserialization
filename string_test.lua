local luaunit = require("luaunit")
local string_module = require("luaserialization.string")
local assertions = require("luatypechecks.assertions")

local Object = {}

function Object:new(id)
  assertions.is_integer(id)

  local object = setmetatable({}, self)
  object.id = id

  return object
end

function Object:__data()
  return {
    field_1 = self.id + 100,
    field_2 = string.format("test-%d", self.id),
  }
end

local ObjectWrapper = {}

function ObjectWrapper:new(id1, id2)
  assertions.is_integer(id1)
  assertions.is_integer(id2)

  local wrapper = setmetatable({}, self)
  wrapper.id1 = id1
  wrapper.id2 = id2

  return wrapper
end

function ObjectWrapper:__data()
  return {
    object_1 = Object:new(self.id1),
    object_2 = Object:new(self.id2),
  }
end

-- luacheck: globals TestString
TestString = {}

-- string.to_string()
for _, data in ipairs({
  {
    name = "test_to_string/nil",
    args = { value = nil },
    want = "nil",
  },
  {
    name = "test_to_string/boolean",
    args = { value = true },
    want = "true",
  },
  {
    name = "test_to_string/number/integer",
    args = { value = 23 },
    want = "23",
  },
  {
    name = "test_to_string/number/float",
    args = { value = 2.3 },
    want = "2.3",
  },
  {
    name = "test_to_string/string",
    args = { value = "test" },
    want = [["test"]],
  },
  {
    name = "test_to_string/function",
    args = { value = function() end },
    want = "<function 1>",
  },
  {
    name = "test_to_string/table/sequence",
    args = { value = {"one", "two"} },
    want = [[{ "one", "two" }]],
  },
  {
    name = "test_to_string/table/sequence/with_hierarchy",
    args = { value = {{ one = 1, two = 2 }, { three = 3, four = 4 }} },
    want = "{ {one = 1,two = 2}, {four = 4,three = 3} }",
  },
  {
    name = "test_to_string/table/not_sequence",
    args = { value = { one = 1, two = 2 } },
    want = "{one = 1,two = 2}",
  },
  {
    name = "test_to_string/table/not_sequence/with_hierarchy",
    args = { value = { one = {1, 2}, two = {3, 4} } },
    want = "{one = { 1, 2 },two = { 3, 4 }}",
  },
  {
    name = "test_to_string/table/not_sequence/with_data_metamethod",
    args = { value = Object:new(23) },
    want = [[{field_1 = 123,field_2 = "test-23"}]],
  },
  {
    name = "test_to_string"
      .. "/table/not_sequence"
      .. "/with_data_metamethod/with_hierarchy",
    args = { value = { one = Object:new(12), two = Object:new(23) } },
    want = "{"
      .. [[one = {field_1 = 112,field_2 = "test-12"},]]
      .. [[two = {field_1 = 123,field_2 = "test-23"}]]
      .. "}",
  },
  {
    name = "test_to_string"
      .. "/table/not_sequence"
      .. "/with_data_metamethod/with_wrapper",
    args = { value = ObjectWrapper:new(12, 23) },
    want = "{"
      .. [[object_1 = {field_1 = 112,field_2 = "test-12"},]]
      .. [[object_2 = {field_1 = 123,field_2 = "test-23"}]]
      .. "}",
  },
}) do
  TestString[data.name] = function()
    local result = string_module.to_string(data.args.value)

    luaunit.assert_equals(result, data.want)
  end
end
