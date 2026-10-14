---
sidebar_position: 8
---

# Inspect
Used for debugging changes to Seam states.

|Type|Since|Scoped|
|----|-----|------|
|Utility|0.3.3|No|

## Constructor
```lua
Inspect(State : any, DebugName : string)
```

## Usage
`Inspect` is a utility function that prints whenever the associated state changes. It's best used for debugging.

Example usage:

```lua
local Value = Seam.Value
local Inspect = Seam.Inspect

local Test = Value("Started")

Inspect(Test, "Test Value")

Test.Value = "Ended" -- Prints "SEAM_INSPECT | Test Value | Value changed to Ended"
```