-- luacheck: no max comment line length

---
-- @module json

local data_module = require("luaserialization.data")
local json_module = require("luaserialization.vendor.json")
local assertions = require("luatypechecks.assertions")

local json = {}

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

--- ⚠️. This function transforms the text in the JSON to a data.
-- @tparam string text
-- @treturn any
-- @error error message
function json.from_json(text)
  assertions.is_string(text)

  local decoded_data, err = json._catch_error(json_module.decode, text)
  if err ~= nil then
    return nil, "unable to decode the data: " .. err
  end

  return decoded_data
end

function json._catch_error(handler, ...)
  assertions.is_function(handler)

  local arguments = table.pack(...)
  local ok, result = pcall(function()
    return handler(table.unpack(arguments))
  end)
  if not ok then
    return nil, result
  end

  return result
end

return json
