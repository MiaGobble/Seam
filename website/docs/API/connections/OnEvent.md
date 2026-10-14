---
sidebar_position: 2
---

# OnEvent
Used to track any events in a Roblox instance

|Type|Since|Scoped|
|----|-----|------|
|Connection|0.0.1|Yes|

## Constructor
```lua
[OnEvent(EventName : string)] = () -> nil
```

## Usage
`OnEvent` is an Seam index to be used in the New constructor. `OnEvent` detects a specified rbx event that could be fired.

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

`OnEvent` essentially gets the event from the instance and connects to it. For example, `OnEvent "Activated` is equivalent to `Instance.Activated:Connect()`.