---
sidebar_position: 8
---

# Inspect
Prints whenever a Seam state with a `Changed` signal updates.

|Type|Since|Scoped|
|----|-----|------|
|Utility|0.3.3|Yes|

## Constructor
```lua
Inspect(State : State, DebugName : string) -> RBXScriptConnection
```

`DebugName` is required.

## Usage
```lua
local Test = Value("Started")

local Connection = Inspect(Test, "Test")

Test.Value = "Ended"
-- Prints: SEAM_Test.Value = Ended

Connection:Disconnect()
```
