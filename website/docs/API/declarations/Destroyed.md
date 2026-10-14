---
sidebar_position: 11
---

# Destroyed
Runs a callback when an instance created or hydrated with `New` is destroyed.

|Type|Since|Scoped|
|----|-----|------|
|Declaration|0.3.3|No|

## Constructor
```lua
[Destroyed] = () -> ()
```

## Usage
```lua
local Object = New("ScreenGui", {
	[Destroyed] = function()
		print("I've been destroyed!")
	end,
})

Object:Destroy() -- Prints once
```

Implemented with `Instance.Destroying:Once`, so the callback runs once when destruction begins.
