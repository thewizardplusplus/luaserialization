local luaunit = require("luaunit")
local json_module = require("luaserialization.json")
local assertions = require("luatypechecks.assertions")
local checks = require("luatypechecks.checks")

local function _handle_error(err, use_exception)
  assertions.is_string(err)
  assertions.is_boolean(use_exception)

  if use_exception then
    error("exception: " .. err)
  end

  return nil, "error: " .. err
end

local Object = {}

function Object.from_options(options, use_exception)
  use_exception = use_exception or false

  assertions.is_table(options)
  assertions.is_boolean(use_exception)

  if not checks.has_properties(options, {"name"}) then
    return _handle_error("the `name` option is missing", use_exception)
  end

  if not checks.is_string(options.name) then
    return _handle_error("the `name` option has an invalid type", use_exception)
  end

  local id_as_string = string.match(options.name, "^test%-(%d+)$")
  if id_as_string == nil then
    return _handle_error(
      "the `name` option has an invalid format",
      use_exception
    )
  end

  local id = tonumber(id_as_string)
  if id == nil then
    return _handle_error(
      "unable to extract an ID from the `name` option",
      use_exception
    )
  end

  return Object:new(id)
end

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

function ObjectWrapper.from_options(options, use_exception)
  use_exception = use_exception or false

  assertions.is_table(options)
  assertions.is_boolean(use_exception)

  if not checks.has_properties(options, {"object"}) then
    return _handle_error("the `object` option is missing", use_exception)
  end

  if not checks.has_properties(options.object, {"id"}) then
    return _handle_error(
      "the `id` property of the `object` option is missing",
      use_exception
    )
  end

  return ObjectWrapper:new(options.object.id)
end

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

-- json_module.from_json()
for _, data in ipairs({
  {
    name = "test_from_json/nil",
    args = { text = "null" },
    want = nil,
    want_err = nil,
  },
  {
    name = "test_from_json/boolean",
    args = { text = "true" },
    want = true,
    want_err = nil,
  },
  {
    name = "test_from_json/number/integer",
    args = { text = "23" },
    want = 23,
    want_err = nil,
  },
  {
    name = "test_from_json/number/float",
    args = { text = "2.3" },
    want = 2.3,
    want_err = nil,
  },
  {
    name = "test_from_json/string",
    args = { text = [["test"]] },
    want = "test",
    want_err = nil,
  },
  {
    name = "test_from_json/table/sequence",
    args = { text = [=[["one","two"]]=] },
    want = {"one", "two"},
    want_err = nil,
  },
  {
    name = "test_from_json/table/sequence/with_hierarchy",
    args = { text = [=[[{"one":1},{"two":2}]]=] },
    want = {{ one = 1 }, { two = 2 }},
    want_err = nil,
  },
  {
    name = "test_from_json/table/not_sequence",
    args = { text = [[{"one":1}]] },
    want = { one = 1 },
    want_err = nil,
  },
  {
    name = "test_from_json/table/not_sequence/with_hierarchy",
    args = { text = [[{"one":[1,2]}]] },
    want = { one = {1, 2} },
    want_err = nil,
  },
  {
    name = "test_from_json/table/not_sequence/with_schema",
    args = {
      text = [[{"one":[1,2]}]],
      schema = {
        type = "object",
        required = {"one"},
        properties = {
          one = {
            type = "array",
            items = { type = "number" },
            minItems = 2,
            maxItems = 2,
          },
        },
      },
    },
    want = { one = {1, 2} },
    want_err = nil,
  },
  {
    name = "test_from_json/table/not_sequence/with_constructors",
    args = {
      text = [[{"one":{"__name":"Object","name":"test-23"}}]],
      constructors = { Object = Object.from_options },
    },
    want = { one = Object:new(23) },
    want_err = nil,
  },
  {
    name = "test_from_json/table/not_sequence/with_constructors/with_hierarchy",
    args = {
      text = "{"
        .. [["one":{]]
        .. [["__name":"ObjectWrapper",]]
        .. [["object":{"__name":"Object","name":"test-23"}]]
        .. "}"
        .. "}",
      constructors = {
        Object = Object.from_options,
        ObjectWrapper = ObjectWrapper.from_options,
      },
    },
    want = { one = ObjectWrapper:new(23) },
    want_err = nil,
  },
  {
    name = "test_from_json/error/invalid_json",
    args = { text = "invalid-json" },
    want = nil,
    want_err = "^unable to decode the data: "
      .. ".+: "
      .. "unexpected character 'i' at line 1 col 1$",
  },
  {
    name = "test_from_json/error/invalid_schema",
    args = {
      text = [[{"one":[1,2]}]],
      schema = { type = "invalid-type" },
    },
    want = nil,
    want_err = "^unable to generate the validator: "
      .. ".+: "
      .. "invalid JSON type: "
      .. "invalid%-type$",
  },
  {
    name = "test_from_json/error/invalid_data",
    args = {
      text = [[{"one":[1,2,3]}]],
      schema = {
        type = "object",
        required = {"one"},
        properties = {
          one = {
            type = "array",
            items = { type = "number" },
            minItems = 2,
            maxItems = 2,
          },
        },
      },
    },
    want = nil,
    want_err = "^invalid data: "
      .. [[property "one" validation failed: ]]
      .. "expect array to have at least 2 items$",
  },
  {
    name = "test_from_json/error/with_constructors/without_error_throwing",
    args = {
      text = [[{"one":{"__name":"Object","name":"test"}}]],
      constructors = { Object = Object.from_options },
    },
    want = nil,
    want_err = "^unable to apply the constructors: "
      .. "unable to apply the constructors: "
      .. "unable to call the constructor: "
      .. "error: "
      .. "the `name` option has an invalid format",
  },
  {
    name = "test_from_json/error/with_constructors/with_error_throwing",
    args = {
      text = [[{"one":{"__name":"Object","name":"test"}}]],
      constructors = {
        Object = function(options)
          assertions.is_table(options)

          return Object.from_options(options, true)
        end,
      },
    },
    want = nil,
    want_err = "^unable to apply the constructors: "
      .. "unable to apply the constructors: "
      .. "unable to call the constructor: "
      .. ".+: "
      .. "exception: "
      .. "the `name` option has an invalid format",
  },
}) do
  TestJson[data.name] = function()
    local result, err = json_module.from_json(
      data.args.text,
      data.args.schema,
      data.args.constructors
    )

    luaunit.assert_equals(result, data.want)
    if data.want_err == nil then
        luaunit.assert_is_nil(err)
    else
        luaunit.assert_is_string(err)
        luaunit.assert_str_matches(err, data.want_err)
    end
  end
end
