## Scope
* Type: Other
* Since: 0.0.1
* Scopeable: No

## Construction
```lua
Scope {
    [ObjectName : string] = Object : SeamScopableObject
}
```

## Methods
### `InnerScope() -> Scope`
Returns an inner scope.

### `Destroy() -> nil`
Destroys the scope and cleans up all descendants.

## Usage
It's recommended that you import `Scope` from the Seam module so that you can use it later on:

```lua
local Seam = require(ReplicatedFirst.Seam)
local Scope = Seam.Scope
```

`Scope` is a janitor-like organization object that groups instances together. Anything created with a Scope-declared Seam object will be cleaned up when the scope itself is destroyed.

To make a scope, you declare what Seam objects you want to include. Be weary that an object must be marked as scopable, otherwise you will get an error.

```lua
local MyScope = Scope {
    New = New,
    Spring = Spring,
    Computed = Computed,
    -- etc
}
```

In this example, you can make an object with the scope by calling Scope:New:

```lua
local MyGui = MyScope:New("ScreenGui", {
    -- Properties like normal
})
```

Let's continue this example. Let's say we want to create a child group of frames. To do so, we can call `InnerScope()`:

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

*Documention TBD*