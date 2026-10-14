---
sidebar_position: 3
---

# IsState
Checks if a userdata value is a Seam state.

|Type|Since|Scoped|
|----|-----|------|
|Utility|0.3.3|No|

## Constructor
```lua
IsState(CheckedState : any)
```

## Usage
If you need to quickly check if a userdata is a state, use this. It can be used like so:

```lua
local Value = Seam.Value
local IsState = Seam.IsState

local Test1 = Value(100)
local Test2 = 200

print(IsState(Test1)) -- Prints true
print(IsState(Test2)) -- Prints false
```