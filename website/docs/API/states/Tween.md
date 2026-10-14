---
sidebar_position: 4
---

# Tween
An animation state that interpolates toward a target using `TweenInfo`.

|Type|Since|Scoped|
|----|-----|------|
|State|0.0.1|Yes|

## Constructor
```lua
Tween(
	Target : Value | any,
	TweenInfo : Value | TweenInfo
) -> Tween
```

If `Target` is a Seam state, its changes automatically retarget the tween. `TweenInfo` may also be a state and is read each frame.

## Properties
#### `Value : any`
Current interpolated value. Writable; assigning snaps both ends of the tween to that value.

#### `Target : any`
Write-only target. Assign to start a new tween from the current position; reading `.Target` is not supported.

#### `TweenInfo : TweenInfo | Value`
The active tween information. Readable and writable.

## Events
#### `Changed`
Fired when `.Value` changes during interpolation.

#### `AttachedToInstance`
Fired when bound to an instance property through `New`.

## Methods
#### `Destroy()`
Stops simulation and cleans up.

## Usage
```lua
local Goal = Value(0)
local Motion = Tween(Goal, TweenInfo.new(0.5, Enum.EasingStyle.Quad))

Goal.Value = 1 -- Retargets the tween

Motion.Target = 0
Motion.TweenInfo = TweenInfo.new(1)
```

Bind to properties:

```lua
New("Frame", {
	BackgroundTransparency = Tween(Goal, TweenInfo.new(0.3)),
})
```

Like springs, multi-component types are unpacked per channel. When the tween settles, it sleeps until retargeted.
