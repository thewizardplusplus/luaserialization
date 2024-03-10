local luaunit = require("luaunit")
local data_module = require("luaserialization.data")
local checks = require("luatypechecks.checks")
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

-- luacheck: globals TestData
TestData = {}

-- data.to_data()
for _, data in ipairs({
  {
    name = "test_to_data/nil",
    args = { value = nil },
    want = nil,
  },
  {
    name = "test_to_data/boolean",
    args = { value = true },
    want = true,
  },
  {
    name = "test_to_data/number/integer",
    args = { value = 23 },
    want = 23,
  },
  {
    name = "test_to_data/number/float",
    args = { value = 2.3 },
    want = 2.3,
  },
  {
    name = "test_to_data/string",
    args = { value = "test" },
    want = "test",
  },
  {
    name = "test_to_data/function",
    args = { value = function() end },
    want = function() end,
  },
  {
    name = "test_to_data/table/sequence",
    args = { value = {"one", "two"} },
    want = {"one", "two"},
  },
  {
    name = "test_to_data/table/sequence/with_hierarchy",
    args = { value = {{ one = 1, two = 2 }, { three = 3, four = 4 }} },
    want = {{ one = 1, two = 2 }, { three = 3, four = 4 }},
  },
  {
    name = "test_to_data/table/sequence/with_name_metaproperty",
    args = { value = setmetatable({"one", "two"}, { __name = "name" }) },
    want = {"one", "two"},
  },
  {
    name = "test_to_data/table/not_sequence",
    args = { value = { one = 1, two = 2 } },
    want = { one = 1, two = 2 },
  },
  {
    name = "test_to_data/table/not_sequence/with_hierarchy",
    args = { value = { one = {1, 2}, two = {3, 4} } },
    want = { one = {1, 2}, two = {3, 4} },
  },
  {
    name = "test_to_data/table/not_sequence/with_data_metamethod",
    args = { value = Object:new(23) },
    want = { field_1 = 123, field_2 = "test-23" },
  },
  {
    name = "test_to_data"
      .. "/table/not_sequence"
      .. "/with_data_metamethod/with_hierarchy",
    args = { value = { one = Object:new(12), two = Object:new(23) } },
    want = {
      one = { field_1 = 112, field_2 = "test-12" },
      two = { field_1 = 123, field_2 = "test-23" },
    },
  },
  {
    name = "test_to_data/table/not_sequence/with_data_metamethod/with_wrapper",
    args = { value = ObjectWrapper:new(12, 23) },
    want = {
      object_1 = { field_1 = 112, field_2 = "test-12" },
      object_2 = { field_1 = 123, field_2 = "test-23" },
    },
  },
  {
    name = "test_to_data/table/not_sequence/with_name_metaproperty",
    args = { value = setmetatable({ one = 1, two = 2 }, { __name = "name" }) },
    want = { __name = "name", one = 1, two = 2 },
  },
  {
    name = "test_to_data"
      .. "/table/not_sequence"
      .. "/with_name_metaproperty/invalid_type",
    args = { value = setmetatable({ one = 1, two = 2 }, { __name = 23 }) },
    want = { one = 1, two = 2 },
  },
  {
    name = "test_to_data/table/not_sequence/with_name_metaproperty/overriding",
    args = {
      value = setmetatable(
        { __name = "name-one", one = 1, two = 2 },
        { __name = "name-two" }
      ),
    },
    want = { __name = "name-two", one = 1, two = 2 },
  },
  {
    name = "test_to_data"
      .. "/table/not_sequence"
      .. "/with_name_metaproperty/with_data_metamethod",
    args = {
      value = setmetatable(
        { one = 1, two = 2 },
        {
          __name = "name",
          __data = function()
            return { one = 1, two = 2 }
          end,
        }
      ),
    },
    want = { __name = "name", one = 1, two = 2 },
  },
}) do
  TestData[data.name] = function()
    local result = data_module.to_data(data.args.value)

    if checks.is_function(data.want) then
      luaunit.assert_is_function(result)
    else
      luaunit.assert_equals(result, data.want)
    end
  end
end
