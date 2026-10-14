---
sidebar_position: 2
---

# GetValue
Reads `.Value` from a Seam state, or returns the input as-is.

|Type|Since|Scoped|
|----|-----|------|
|Utility|0.2.2|No|

## Constructor
```lua
GetValue(Input : any?) -> any?
```

## Usage
```lua
local MyValue = Value(5)

print(GetValue(MyValue)) -- 5
print(GetValue("Banana")) -- "Banana"
print(GetValue(nil)) -- nil
```

Safe when the input might be either a state or a plain value.
