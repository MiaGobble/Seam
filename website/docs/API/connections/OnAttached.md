---
sidebar_position: 4
---

# OnAttached
Used to track attribute changes in states or instances

|Type|Since|Scoped|
|----|-----|------|
|Connection|0.3.3|Yes|

## Constructor
```lua
OnAttached(State : any, Callback : (AttachedInstance : Instance) -> nil)
```

## Usage
`OnAttached` is a highly specific connection that allows you to connect to when states attach to instances with `New`.

It works like this:

```lua
local New = Seam.New
local Value = Seam.Value
local OnAttached = Seam.OnAttached

local MyState = Value(Color3.fromRGB(255, 0, 0))

OnAttached(MyState, function(AttachedInstance)
	print("Attached to: " .. AttachedInstance.Name)
end)

local MyInstance = New("Part", {
	Color = MyState -- Because we set Color to MyState, OnAttached triggers and prints "Attached to: Part"
})
```

More specifically, `OnAttached` only uses the callback function when the associated state is used by something else in a reactive way. For example, reading a state value or using `OnChanged` will *not* trigger `OnAttached`, but using a state in `New` *will* trigger it.