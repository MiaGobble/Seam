---
sidebar_position: 3
---

# Component
Used to declare a module as a Seam component class.

|Type|Since|Scoped|
|----|-----|------|
|Declaration|0.3.0|No|

## Usage
Components in Seam are modified modules that are converted from functional dictionaries to a mock-OOP setup.

Somewhere in your script, declare `Component` as a variable:

```lua
local Component = Seam.Component
```

All components require `Init()` and `Construct()` methods (both passing in scope and properties, respectively), and then returns `Component(Module)`.
`Init()` can be used to initialize the object of the class, while `Construct()` returns the class instance.

Below is an example of a button component module:

```lua
local ButtonComponent = {}

local Seam = require(Path.To.Seam)
local Component = Seam.Component
local New = Seam.New
local OnEvent = Seam.OnEvent

function ButtonComponent:Init(Scope, Properties)
    self.Clicks = 0
end

function ButtonComponent:Construct(Scope, Properties)
    return Scope:New("TextButton", {
        -- Other properties, etc...
        Text = Properties.Text,

        [OnEvent "Activated"] = function()
            self:Click()
        end,
    })
end

function ButtonComponent:Click()
    self.Clicks += 1
    print("Clicked! Total clicks: " .. self.Clicks)
end

return Component(ButtonComponent)
```

Components are a great way to create reusable parts in your UI code. In the above example, the button component can be used to create buttons anywhere, all with the same behavior.