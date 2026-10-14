---
sidebar_position: 4
---

# Tween
An animation state using the tween method

|Type|Since|Scoped|
|----|-----|------|
|State|0.0.1|Yes|

## Constructor
```lua
Tween(Target : Value | any, TweenInfo : TweenInfo)
```

## Properties
#### `Value : any`
The current state of the tween.

#### `Target : Value | any`
The target that the tween should reach.

#### `TweenInfo : TweenInfo`
The TweenInfo associated with the tween object.

## Events
#### `Changed`
Fired when `.Value` changes.

## Usage
Tween is constructed and used in a similar way to `Spring`, but instead it uses Roblox-style interpolation methods.

Use it like so:

```lua
local Seam = require(ReplicatedFirst.Seam)
local Tween = Seam.Tween

local MyTween = Tween(0, TweenInfo.new(5))
```

Or as a property of a hydrated Seam object, like this:

```lua
local Seam = require(ReplicatedFirst.Seam)
local Tween = Seam.Tween

local Object = New("Object", {
    Position = Tween(0, TweenInfo.new(5))
})
```