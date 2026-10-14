---
sidebar_position: 1
---

# New
Constructs a Roblox instance, or hydrates an existing one with Seam states

|Type|Since|Scoped|
|----|-----|------|
|Declaration|0.0.1|Yes|

## Constructor
```lua
New(Object : string | Instance | CustomComponent, Properties : {[any] : any}, From : From?) -> Instance
```

## Usage
`New` is the heart of Seam, giving everything the framework functionality. It’s a constructor to make new instances, or hydrate existing ones.

To make a brand new instance, use `New` like this:

```lua
local Object = New("Frame", {
    -- Properties here
    Size = UDim2.fromScale(0.5, 0.5), -- Example
})
```

Or alternatively, use an existing instance by replacing the string with the instance you want, like this:

```lua
local ExistingFrame = Gui:FindFirstChild("Frame")

local Object = New(ExistingFrame, {
    -- Properties here
    Size = UDim2.fromScale(0.5, 0.5), -- Example
})
```

There are two parameters: object (as a string, instance, or custom component module), and properties (as a dictionary).

If you are using a custom component, you can use the `Component()` declaration at the end of that module, and then use that module as the first parameter to `New`:

```lua
local MyFrameComponent = require(Path.To.Component)

local Object = New(MyFrameComponent, {
    -- Properties here
    Size = UDim2.fromScale(0.5, 0.5), -- Example
})
```

You can learn more about components under the `Component` page. Use states and other declarations with `New`. Read more about it in the rest of the documentation!