local luaunit = require("luaunit")

for _, module in ipairs({
}) do
  require("luaserialization." .. module .. "_test")
end

os.exit(luaunit.run())
