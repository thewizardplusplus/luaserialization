local luaunit = require("luaunit")

for _, module in ipairs({
  "data",
  "nameable",
  "string",
  "stringifiable",
  "json",
  "filesystem.filesystem",
  "filesystem.filesystemforstdlibrary",
}) do
  require("luaserialization." .. module .. "_test")
end

os.exit(luaunit.run())
