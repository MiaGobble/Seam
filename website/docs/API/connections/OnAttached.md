---
sidebar_position: 4
---

# OnAttached
Fires when a Seam state is bound to an instance property through `New`.

|Type|Since|Scoped|
|----|-----|------|
|Connection|0.3.3|Yes|

## Constructor
```lua
OnAttached(State : State, Callback : (AttachedInstance : Instance) -> ()) -> RBXScriptConnection
```

## Usage
Connects to the state's `AttachedToInstance` signal. Reading a state or using `OnChanged` does **not** fire this — only binding the state as a property in `New` does.

```lua
local MyState = Value(Color3.fromRGB(255, 0, 0))

OnAttached(MyState, function(AttachedInstance)
	print("Attached to:", AttachedInstance.Name)
end)

New("Part", {
	Color = MyState, -- Fires OnAttached
})
```
