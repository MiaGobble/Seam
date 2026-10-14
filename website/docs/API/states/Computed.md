---
sidebar_position: 2
---

# Computed
A reactive state that recomputes when dependencies used inside its callback change.

|Type|Since|Scoped|
|----|-----|------|
|State|0.0.1|Yes|

## Constructor
```lua
Computed(Callback : (Use : (State | any) -> any) -> any) -> Computed
```

## Properties
#### `Value : any`
The latest computed result. Read-only. The first read runs the callback if it has not run yet.

## Events
#### `Changed`
Fired when the computed result changes. Connecting to `Changed` also triggers the first computation if needed.

#### `AttachedToInstance`
Fired when this state is bound to an instance property through `New`.

## Methods
#### `Destroy()`
Disconnects dependency listeners and cleans up the state.

## Usage
`Computed` does **not** update every frame. It recomputes when a dependency you read through `Use` fires `Changed`.

`Use(state)` both reads the current value and subscribes to that state. Passing a non-state through `Use` returns the value via `GetValue` without subscribing.

```lua
local XPosition = Value(0)

local Position = Computed(function(Use)
	return UDim2.fromScale(Use(XPosition), 0)
end)

print(Position.Value) -- UDim2.fromScale(0, 0)

XPosition.Value = 0.5 -- Position recomputes
print(Position.Value) -- UDim2.fromScale(0.5, 0)
```

Bind it directly in `New`:

```lua
New(MyFrame, {
	Position = Computed(function(Use)
		return UDim2.fromScale(Use(XPosition), 0)
	end),
})
```

Dependencies are tracked per recompute. If a branch stops calling `Use` on a state, that subscription is dropped.

Only values wrapped in `Use` create reactivity. Reading `SomeState.Value` inside the callback does not subscribe.
