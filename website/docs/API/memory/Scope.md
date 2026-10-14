---
sidebar_position: 1
---

# Scope
A memory manager that owns Seam objects and cleans them up together.

|Type|Since|Scoped|
|----|-----|------|
|Memory|0.0.1|Yes|

## Constructor
```lua
Scope(ScopedObjects : {[string] : SeamScopableObject}) -> Scope
```

Pass a table of Seam constructors (or the whole `Seam` module) to make those APIs available on the scope as methods. Only objects marked as scopable can be included.

## Methods
#### `New(Class, Properties) -> Instance`
Scoped version of `New`. The scope is passed into components as their first argument.

#### `Value(InitialValue) -> Value`
#### `Computed(Callback) -> Computed`
#### `ForPairs(TrackedValue, Callback) -> ForPairs`
#### `Resource(Callback) -> Resource`
#### `Bezier(Alpha, Origin, Midpoint, Target) -> Bezier`
#### `Spring(Target, Speed, Dampening) -> Spring`
#### `Tween(Target, TweenInfo) -> Tween`
#### `Rendered(Callback) -> Rendered`
#### `OnChanged(Object, Callback) -> RBXScriptConnection`
#### `OnAttributeChanged(AttributeName) -> Binding`
#### `OnEvent(EventName) -> Binding`
#### `OnAttached(Object, Callback) -> RBXScriptConnection`

Each of the above mirrors the global API. Return values are registered on the scope and destroyed with it.

#### `InnerScope(ScopedObjects?) -> Scope`
Creates a child scope. If `ScopedObjects` is omitted, the child inherits the parent's scoped constructors. Extra keys in `ScopedObjects` override parent keys. The child is owned by the parent bucket.

#### `AddObject(Object) -> Object`
Manually registers an object (instance, connection, Seam object, etc.) for cleanup.

#### `RemoveObject(Object)`
Removes an object from the scope bucket without destroying the scope.

#### `CleanInnerScopes()`
Destroys every nested scope created with `InnerScope` and removes them from the bucket.

#### `Destroy()`
Destroys the scope and cleans up everything in its bucket. Destroying an inner scope also removes it from its parent. Calling methods on a destroyed scope warns and no-ops.

## Usage
Create a scope with the constructors you need:

```lua
local MyScope = Scope {
	New = New,
	Value = Value,
	Computed = Computed,
	Spring = Spring,
}
```

Or inherit everything from Seam:

```lua
local MyScope = Scope(Seam)
```

Anything created through the scope is cleaned up when the scope is destroyed:

```lua
local Gui = MyScope:New("ScreenGui", {
	Parent = PlayerGui,
})

local Position = MyScope:Value(0)
local Springed = MyScope:Spring(Position, 20, 1)

MyScope:New("Frame", {
	Parent = Gui,
	Position = Computed(function(Use)
		return UDim2.fromScale(Use(Springed), 0)
	end),
})

-- Later:
MyScope:Destroy() -- Gui, Position, Springed, and connections are cleaned up
```

Use `InnerScope` for temporary subgroups:

```lua
local FramesScope = MyScope:InnerScope()

FramesScope:New("Frame", {
	Parent = Gui,
})

FramesScope:Destroy() -- Only cleans the inner group
-- Or:
MyScope:CleanInnerScopes() -- Destroys all inner scopes
```

Plain functions placed in the scope table receive the scope as their first argument. Manual ownership is available when something was not created through a scoped method:

```lua
MyScope:AddObject(SomeConnection)
MyScope:RemoveObject(SomeConnection)
```
