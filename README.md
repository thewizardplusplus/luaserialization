# luaserialization

[![doc:build](https://github.com/thewizardplusplus/luaserialization/actions/workflows/doc.yaml/badge.svg)](https://github.com/thewizardplusplus/luaserialization/actions/workflows/doc.yaml)
[![doc:link](https://img.shields.io/badge/doc%3Alink-link-blue?logo=github)](https://thewizardplusplus.github.io/luaserialization/)
[![lint](https://github.com/thewizardplusplus/luaserialization/actions/workflows/lint.yaml/badge.svg)](https://github.com/thewizardplusplus/luaserialization/actions/workflows/lint.yaml)
[![test](https://github.com/thewizardplusplus/luaserialization/actions/workflows/test.yaml/badge.svg)](https://github.com/thewizardplusplus/luaserialization/actions/workflows/test.yaml)
[![luarocks](https://img.shields.io/badge/luarocks-link-blue?logo=lua)](https://luarocks.org/modules/thewizardplusplus/luaserialization)

The library that implements various auxiliary functions for serialization.

_**Disclaimer:** this library was written directly on an Android smartphone with the [QLua](https://play.google.com/store/apps/details?id=com.quseit.qlua5pro2) IDE._

## Features

- `data.to_data()` function &mdash; this function recursively calls the `__data()` metamethod if it exists:
  - supports for enhancing tables with the `__name` metaproperty;
- `Nameable` mixin &mdash; this mixin adds the `__name` metaproperty to a class created by library [middleclass](https://github.com/kikito/middleclass); this metaproperty equals to the `name` property of the mix target class;
- serialization to string:
  - `string.to_string()` function &mdash; this function calls the `data.to_data()` function and then applies library [inspect.lua](https://github.com/kikito/inspect.lua);
  - `Stringifiable` mixin &mdash; this mixin adds the `__tostring()` metamethod that calls the `string.to_string()` function;
- serialization to JSON:
  - `json.to_json()` function &mdash; this function calls the `data.to_data()` function and then transforms the data into the JSON;
  - `json.from_json()` function &mdash; this function transforms the text in the JSON to a data:
    - optionally, it can validate the data against a JSON Schema;
    - optionally, it can recreate tables with the `__name` property with the passed constructors.

## Installation

```
$ luarocks install luaserialization
```

## License

The MIT License (MIT)

Copyright &copy; 2024 thewizardplusplus
