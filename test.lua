local luaunit = require("luaunit")

for _, module in ipairs({
  "data",
  "string",
  "stringifiable",
}) do
  require("luaserialization." .. module .. "_test")
end

os.exit(luaunit.run())
