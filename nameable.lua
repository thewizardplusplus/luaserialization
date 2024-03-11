-- luacheck: no max comment line length

-- @classmod Nameable

local assertions = require("luatypechecks.assertions")

local Nameable = {}

function Nameable:included(class)
  assertions.is_table(class)
  assertions.has_properties(class, {"static"})
  assertions.has_properties(class.static, {"allocate"})

  local original_allocate = class.static.allocate
  class.static.allocate = function(class, ...)
    assertions.is_table(class)
    assertions.has_properties(class, {"name"})

    local instance = original_allocate(class, ...)
    local instance_metatable = getmetatable(instance)
    if instance_metatable ~= nil then
      instance_metatable.__name = class.name
    end

    return instance
  end
end

return Nameable
