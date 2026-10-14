---
sidebar_position: 11
---

# Destroyed
Fires a callback function when an instance hydrated or created with `New` gets destroyed.

|Type|Since|Scoped|
|----|-----|------|
|Declaration|0.3.3|No|

## Constructor
```lua
[Destroyed] = () -> nil
```

## Usage
`Destroyed` allows you to attach a callback function to an instance when it destroyed.

It works like this:

```lua
local New = Seam.New
local Destroyed = Seam.Destroyed

local Object = New("ScreenGui", {
	[Destroyed]  = function()
		print("I've been destroyed!")
	end,
})

Object:Destroy() -- Prints "I've been destroyed!"
```

This is equivalent to connecting to `Instance.Destroying`