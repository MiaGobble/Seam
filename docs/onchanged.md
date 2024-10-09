## OnChanged
* Type: Index
* Since: 0.0.1
* Scopeable: No

## Usage
It's recommended that you import `OnChanged` from the Seam module so that you can use it later on:

```lua
local Seam = require(ReplicatedFirst.Seam)
local OnChanged = Seam.OnChanged
```

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

*Documention TBD*