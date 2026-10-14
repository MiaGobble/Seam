---
sidebar_position: 5
---

# LockValue
Locks a Seam value state, disconnecting it from the reactive backend and preventing future writes.

|Type|Since|Scoped|
|----|-----|------|
|Utility|0.3.3|No|

## Constructor
```lua
LockValue(Value : Seam.ValueInstance)
```

## Usage
This utility locks a Seam value state. Upon doing so, the following happen:
* All reactivity relating to the value is removed
* All future writes to `Value.Value` will throw an error

Here is an example of this in action:

```lua
local Value = Seam.Value
local LockValue = Seam.LockValue

local MyTestValue = Value("Peach")

MyTestValue.Value = "Starfruit" -- No error

LockValue(MyTestValue)

MyTestValue.Value = "Kiwi" -- Throws an error, it's locked
```