---
sidebar_position: 1
---

# SetValue
Assigns `.Value` on a state-like table when possible, and returns the new value.

|Type|Since|Scoped|
|----|-----|------|
|Utility|0.3.1|No|

## Constructor
```lua
SetValue(State : any?, NewValue : any?) -> any?
```

## Usage
```lua
local MyValue = Value(1000)

local Result = SetValue(MyValue, 1001)
-- Result == 1001, MyValue.Value == 1001
```

If `State` is `nil`, returns `NewValue` unchanged. If `State` is a table with a `.Value` field, that field is assigned. Non-state userdata is left alone and `NewValue` is still returned.
