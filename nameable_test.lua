local luaunit = require("luaunit")
local middleclass = require("middleclass")
local checks = require("luatypechecks.checks")
local assertions = require("luatypechecks.assertions")
local Nameable = require("luaserialization.nameable")
local Stringifiable = require("luaserialization.stringifiable")

local MiddleclassObject = middleclass("MiddleclassObject")
MiddleclassObject:include(Nameable)
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

-- luacheck: globals TestNameable
TestNameable = {}

function TestNameable.test_name_metaproperty()
  local object = MiddleclassObject:new(23)
  luaunit.assert_true(checks.is_instance(object, MiddleclassObject))

  local object_metatable = getmetatable(object)
  luaunit.assert_not_nil(object_metatable)

  luaunit.assert_equals(object_metatable.__name, "MiddleclassObject")
end

function TestNameable.test_tostring()
  local object = MiddleclassObject:new(23)
  luaunit.assert_true(checks.is_instance(object, MiddleclassObject))

  local result = tostring(object)

  luaunit.assert_equals(
    result,
    "{"
      .. [[__name = "MiddleclassObject",]]
      .. "field_1 = 123,"
      .. [[field_2 = "test-23"]]
      .. "}"
  )
end
