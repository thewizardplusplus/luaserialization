rockspec_format = "3.0"
package = "luaserialization"
version = "1.0.0-1"
description = {
  summary = "The library that implements various auxiliary functions for serialization.",
  license = "MIT",
  maintainer = "thewizardplusplus <thewizardplusplus@yandex.ru>",
  homepage = "https://github.com/thewizardplusplus/luaserialization",
}
source = {
  url = "git+https://github.com/thewizardplusplus/luaserialization.git",
  tag = "v1.0.0",
}
dependencies = {
  "lua >= 5.1",
}
test_dependencies = {
  "luaunit >= 3.4, < 4.0",
}
build = {
  type = "builtin",
  modules = {
  },
  copy_directories = {
    "doc",
  },
}
