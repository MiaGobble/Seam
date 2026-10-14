---
sidebar_position: 5
---

# LockValue
Permanently locks a `Value` state against future writes.

|Type|Since|Scoped|
|----|-----|------|
|Utility|0.3.3|No|

## Constructor
```lua
LockValue(Value : Value)
```

Only `Value` states can be locked. Locking is irreversible.

## Usage
Sets an internal lock flag and destroys the value's reactive backend. Afterward, assigning `.Value` errors.

```lua
local MyValue = Value("Peach")

MyValue.Value = "Starfruit" -- Ok

LockValue(MyValue)

MyValue.Value = "Kiwi" -- Errors: locked
```
