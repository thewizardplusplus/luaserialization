-- luacheck: no max comment line length

---
-- @module json

local data_module = require("luaserialization.data")
local json_module = require("luaserialization.vendor.json")
local checks = require("luatypechecks.checks")
local assertions = require("luatypechecks.assertions")
local jsonschema = require("luaserialization.vendor.jsonschema")
local _ENV = require("compat53.module")
if _VERSION == "Lua 5.1" then
  setfenv(1, _ENV)
end

local json = {}

local function _write_file(path, data)
  local file, err = io.open(path, "w")
  if file == nil then
    return false, err
  end

  local ok, err = file:write(data)
  if not ok then
    file:close()

    return false, err
  end

  ok, err = file:close()
  if not ok then
    return false, err
  end

  return true
end

local function _read_file(path)
  local file, err = io.open(path, "r")
  if file == nil then
    return nil, err
  end

  local data, err = file:read("*a")
  file:close()
  if data == nil then
    return nil, err
  end

  return data
end

--- ⚠️. This function gets the value data with the @{data.to_data|data.to_data()} function. Then the function transforms this data into the JSON.
-- @tparam any value
-- @treturn string
-- @error error message
function json.to_json(value)
  local data = data_module.to_data(value)
  local encoded_data, err = json._catch_error(json_module.encode, data)
  if err ~= nil then
    return nil, "unable to encode the data: " .. err
  end

  return encoded_data
end

--- ⚠️. This function serializes the passed value to JSON and saves it via the callback.
-- @tparam string path
-- @tparam any value
-- @tparam[opt] func callback callback for saving JSON; the value should be `func(path: string, data: string): bool`; the default implementation uses the standard `io` package
-- @treturn bool
-- @error error message
function json.save_to_json(path, value, callback)
  assertions.is_string(path)
  if callback ~= nil then
    assertions.is_function(callback)
  else
    callback = _write_file
  end

  local data, err = json.to_json(value)
  if data == nil then
    return false, "unable to serialize data: " .. err
  end

  local ok, err = callback(path, data) -- luacheck: no redefined
  if not ok then
    return false, "unable to write data: " .. err
  end

  return true
end

--- ⚠️. This function transforms the text in the JSON to a data.
-- @tparam string text
-- @tparam[opt] tab schema JSON Schema
-- @tparam[optchain] {[string]=func,...} constructors constructors for tables with the `__name` property; the values should be `func(options: tab): tab`; the constructor can either return an error as the second result or throw it as an exception
-- @treturn any
-- @error error message
function json.from_json(text, schema, constructors)
  assertions.is_string(text)
  assertions.is_table_or_nil(schema)
  assertions.is_table_or_nil(constructors, checks.is_string, checks.is_callable)

  local decoded_data, err = json._catch_error(json_module.decode, text)
  if err ~= nil then
    return nil, "unable to decode the data: " .. err
  end

  if schema ~= nil then
    local validator, err = json._catch_error( -- luacheck: no redefined
      jsonschema.generate_validator,
      schema
    )
    if err ~= nil then
      return nil, "unable to generate the validator: " .. err
    end

    local _, err = validator(decoded_data) -- luacheck: no redefined
    if err ~= nil then
      return nil, "invalid data: " .. err
    end
  end

  if constructors ~= nil then
    decoded_data, err = json._apply_constructors(decoded_data, constructors)
    if err ~= nil then
      return nil, "unable to apply the constructors: " .. err
    end
  end

  return decoded_data
end

--- ⚠️. This function loads JSON via the callback and parses it.
-- @tparam string path
-- @tparam[opt] tab schema JSON Schema
-- @tparam[optchain] {[string]=func,...} constructors constructors for tables with the `__name` property; the values should be `func(options: tab): tab`; the constructor can either return an error as the second result or throw it as an exception
-- @tparam[opt] func callback callback for loading JSON; the value should be `func(path: string): string`; the default implementation uses the standard `io` package
-- @treturn any
-- @error error message
function json.load_from_json(path, schema, constructors, callback)
  assertions.is_string(path)
  assertions.is_table_or_nil(schema)
  assertions.is_table_or_nil(constructors, checks.is_string, checks.is_callable)
  if callback ~= nil then
    assertions.is_function(callback)
  else
    callback = _read_file
  end

  local data_in_json, err = callback(path)
  if data_in_json == nil then
    return nil, "unable to read data: " .. err
  end

  local data, err = json.from_json(data_in_json, schema, constructors) -- luacheck: no redefined
  if data == nil then
    return nil, "unable to parse data: " .. err
  end

  return data
end

function json._catch_error(handler, ...)
  assertions.is_function(handler)

  local arguments = table.pack(...)
  local ok, result, err = pcall(function()
    return handler(table.unpack(arguments))
  end)
  if not ok then
    return nil, result
  end
  if err ~= nil then
    return nil, err
  end

  return result
end

function json._apply_constructors(value, constructors)
  assertions.is_table(constructors, checks.is_string, checks.is_callable)

  if not checks.is_table(value) then
    return value
  end

  local transformed_value = {}
  for key, value in pairs(value) do -- luacheck: no redefined
    local err
    transformed_value[key], err = json._apply_constructors(value, constructors)
    if err ~= nil then
      return nil, "unable to apply the constructors: " .. err
    end
  end

  if not checks.is_sequence(transformed_value)
    and checks.has_properties(transformed_value, {"__name"})
    and checks.has_properties(constructors, {transformed_value.__name}) then
    local err
    local constructor = constructors[transformed_value.__name]
    transformed_value, err = json._catch_error(constructor, transformed_value)
    if err ~= nil then
      return nil, "unable to call the constructor: " .. err
    end
  end

  return transformed_value
end

return json
