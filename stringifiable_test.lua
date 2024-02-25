local luaunit = require("luaunit")
local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local Stringifiable = require("luaserialization.stringifiable")

local MiddleclassObject = middleclass("MiddleclassObject")
MiddleclassObject:include(Stringifiable)

function MiddleclassObject:initialize(id)
  assertions.is_integer(id)

  self.id = id
end

function MiddleclassObject:__data()
  return {
    field_1 = self.id + 100,
    field_2 = string.format("test-%d", self.id),
  }
end

-- luacheck: globals TestStringifiable
TestStringifiable = {}

function TestStringifiable.test_tostring()
  local object = MiddleclassObject:new(23)
  local result = tostring(object)

  luaunit.assert_equals(result, [[{field_1 = 123,field_2 = "test-23"}]])
end
