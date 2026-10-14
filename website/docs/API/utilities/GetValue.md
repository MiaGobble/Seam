---
sidebar_position: 2
---

# GetValue
Safely retrieves a value from any userdata, including states.

|Type|Since|Scoped|
|----|-----|------|
|Utility|0.2.2|No|

## Constructor
```lua
GetValue(Value : any)
```

## Usage
`GetValue` is an alternative to reading `Value.Value`, since it allows you to safely read it in case you're using a different userdata type.

To get a value from a value object, do something like this:

```lua
local MyValue = Value(5)

local MyNumber = GetValue(MyValue) -- Equals 5
```

In the below example, both variables sourced from `GetValue` will equate to "Banana":

```lua
local MyValue = Value("Banana")

local X = GetValue(MyValue) -- Equals "Banana"
local Y = GetValue("Banana") -- Equals "Banana"
```