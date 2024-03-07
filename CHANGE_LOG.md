# Change Log

## [v1.1.0](https://github.com/thewizardplusplus/luaserialization/tree/v1.1.0) (2024-03-07)

Support for serialization to JSON.

- serialization to JSON:
  - `json.to_json()` function &mdash; this function calls the `data.to_data()` function and then transforms the data into the JSON;
  - `json.from_json()` function &mdash; this function transforms the text in the JSON to a data:
    - optionally, it can validate the data against a JSON Schema.

## [v1.0.0](https://github.com/thewizardplusplus/luaserialization/tree/v1.0.0) (2024-02-26)

Major version. Implemented the `data.to_data()` function and serialization to string.
