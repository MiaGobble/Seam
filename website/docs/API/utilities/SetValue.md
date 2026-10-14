---
sidebar_position: 1
---

# SetValue
Safely sets a value for a state, then returns it.

|Type|Since|Scoped|
|----|-----|------|
|Utility|0.3.1|No|

## Constructor
```lua
SetValue(Value : ValueObject, NewValue : any?)
```

## Usage
`SetValue` is an alternative to setting `Value.Value` that returns the value you set. It also does not error if you try to set another userdata, but it will not change random userdata.

Below is an example usage:

```lua
local MyValue = Value(1000)

local NewValue = SetValue(MyValue, 1001) -- NewValue is 1001, and MyValue.Value is also equal to 1001
```