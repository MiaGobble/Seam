---
sidebar_position: 1
---

# OnChanged
Used to track changes in states or instances

|Type|Since|Scoped|
|----|-----|------|
|Connection|0.0.1|Yes|

## Constructors
Embedded:

```lua
[OnChanged] = () -> nil
```

Standalone:

```lua
OnChanged(Object : Instance | State, () -> nil)
```

## Methods
#### `Disconnect`
Disconnects the signal

## Usage
`OnChanged` is an Seam index to be used in the `New` constructor. `OnChanged` detects when an instance changes, e.g. when it changes color or size.

You can use it like so:

```lua
local Object = New("Frame", {
    -- Properties

    [OnChanged] = function()
        -- When the frame changes, this function calls back
    end
})
```

In this use case, it's equivalent to connecting to `Instance.Changed`.

You can also track states, like so:

```lua
local MyValue = Value(0)

local MyChangedConnection = OnChanged(MyValue, function()
    print(MyValue.Value) -- Prints MyValue.Value when it changes
end)

MyValue.Value = 1 -- Change value, which fires the callback

MyChangedConnection:Disconnect() -- Disconnects the signal
```