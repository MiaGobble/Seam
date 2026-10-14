---
sidebar_position: 1
---

# Scope
A core memory manager in Seam

|Type|Since|Scoped|
|----|-----|------|
|Memory|0.0.1|Yes|

## Constructor
```lua
Scope {[ObjectName : string] = Object : SeamScopableObject}
```

## Methods
#### `InnerScope() -> Scope`
Returns an inner scope, which a sub-scope derived from the main scope.

#### `Destroy() -> nil`
Destroys the scope and cleans up all descendants.

## Usage
`Scope` is a janitor-like organization object that groups instances together. Anything created with a Scope-declared Seam object will be cleaned up when the scope itself is destroyed.To make a scope, you declare what Seam objects you want to include. Be weary that an object must be marked as scopable, otherwise you will get an error.

```lua
local MyScope = Scope {
    New = New,
    Spring = Spring,
    Computed = Computed,
    -- etc
}
```

You can also create a generic scope, inheriting all methods, like this:

```lua
local MyScope = Scope(Seam)
```

In this example, you can make an object with the scope by calling `Scope:New`:

```lua
local MyGui = MyScope:New("ScreenGui", {
    -- Properties like normal
})
```

Let’s continue this example. Let’s say we want to create a child group of frames. To do so, we can call `InnerScope()`:

```lua
local FramesScope = MyScope:InnerScope()
```

And we can use it the same way:

```lua
local MyNewFrame = FramesScope:New("Frame", {
    --- Properties like normal
})
```

If we want to clean up the frames in this example, we can call `FramesScope:Destroy()`. Alternatively, or in addition, we can also call `MyScope:Destroy()`.