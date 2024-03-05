local luaunit = require("luaunit")
local json_module = require("luaserialization.json")
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
    name = string.format("test-%d", self.id),
  }
end

local ObjectWrapper = {}

function ObjectWrapper:new(id)
  assertions.is_integer(id)

  local wrapper = setmetatable({}, self)
  wrapper.id = id

  return wrapper
end

function ObjectWrapper:__data()
  return {
    object = Object:new(self.id),
  }
end

-- luacheck: globals TestJson
TestJson = {}

-- json_module.to_json()
for _, data in ipairs({
  {
    name = "test_to_json/nil",
    args = { value = nil },
    want = "null",
    want_err = nil,
  },
  {
    name = "test_to_json/boolean",
    args = { value = true },
    want = "true",
    want_err = nil,
  },
  {
    name = "test_to_json/number/integer",
    args = { value = 23 },
    want = "23",
    want_err = nil,
  },
  {
    name = "test_to_json/number/float",
    args = { value = 2.3 },
    want = "2.3",
    want_err = nil,
  },
  {
    name = "test_to_json/string",
    args = { value = "test" },
    want = [["test"]],
    want_err = nil,
  },
  {
    name = "test_to_json/function",
    args = { value = function() end },
    want = nil,
    want_err = "^unable to encode the data: .+: unexpected type 'function'$",
  },
  {
    name = "test_to_json/table/sequence",
    args = { value = {"one", "two"} },
    want = [=[["one","two"]]=],
    want_err = nil,
  },
  {
    name = "test_to_json/table/sequence/with_hierarchy",
    args = { value = {{ one = 1 }, { two = 2 }} },
    want = [=[[{"one":1},{"two":2}]]=],
    want_err = nil,
  },
  {
    name = "test_to_json/table/not_sequence",
    args = { value = { one = 1 } },
    want = [[{"one":1}]],
    want_err = nil,
  },
  {
    name = "test_to_json/table/not_sequence/with_hierarchy",
    args = { value = { one = {1, 2} } },
    want = [[{"one":[1,2]}]],
    want_err = nil,
  },
  {
    name = "test_to_json/table/not_sequence/with_data_metamethod",
    args = { value = Object:new(23) },
    want = [[{"name":"test-23"}]],
    want_err = nil,
  },
  {
    name = "test_to_json"
      .. "/table/not_sequence"
      .. "/with_data_metamethod/with_hierarchy",
    args = { value = { one = Object:new(23) } },
    want = [[{"one":{"name":"test-23"}}]],
    want_err = nil,
  },
  {
    name = "test_to_json/table/not_sequence/with_data_metamethod/with_wrapper",
    args = { value = ObjectWrapper:new(23) },
    want = [[{"object":{"name":"test-23"}}]],
    want_err = nil,
  },
}) do
  TestJson[data.name] = function()
    local result, err = json_module.to_json(data.args.value)

    luaunit.assert_equals(result, data.want)
    if data.want_err == nil then
        luaunit.assert_is_nil(err)
    else
        luaunit.assert_is_string(err)
        luaunit.assert_str_matches(err, data.want_err)
    end
  end
end
