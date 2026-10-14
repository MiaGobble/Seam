---
sidebar_position: 2
---

# OnEvent
Connects to a named Roblox instance event.

|Type|Since|Scoped|
|----|-----|------|
|Connection|0.0.1|Yes|

## Constructor
```lua
OnEvent(EventName : string) -> Binding

-- Embedded:
[OnEvent(EventName)] = (...any) -> ()

-- Standalone:
OnEvent(EventName)(Instance, Callback) -> RBXScriptConnection
```

## Methods (`Binding`)
#### `Destroy()`
Disconnects all active connections created by this binding.

## Usage
```lua
New("ImageButton", {
	[OnEvent "Activated"] = function()
		print("clicked")
	end,

	[OnEvent "MouseEnter"] = function()
		print("enter")
	end,
})
```

Equivalent to `Instance[EventName]:Connect(Callback)`. Rebinding the same event on the same instance replaces the previous connection. Call `Destroy()` on the binding to disconnect everything it owns.
