## OnEvent
* Type: Index
* Since: 0.0.1
* Scopeable: No

## Usage
It's recommended that you import `OnEvent` from the Seam module so that you can use it later on:

```lua
local Seam = require(ReplicatedFirst.Seam)
local OnEvent = Seam.OnEvent
```

`OnEvent` is an Seam index to be used in the `New` constructor. `OnEvent` detects a specified rbx event that could be fired.

You can use it like so:

```lua
local Object = New("ImageButton", {
    -- Properties

    [OnEvent "Activated"] = function()
        -- When the button is clicked, this function is called
    end,

    [OnEvent "MouseEnter"] = function()
        -- When the mouse enters, this function is called
    end,

    [OnEvent "MouseLeave"] = function()
        -- When the mouse leaves, this function is called
    end,
})
```

*Documention TBD*