---
sidebar_position: 3
---

# Spring
An animation state that approaches a target using spring physics.

|Type|Since|Scoped|
|----|-----|------|
|State|0.0.1|Yes|

## Constructor
```lua
Spring(
	Target : Value | any,
	Speed : Value | number,
	Dampening : Value | number
) -> Spring
```

If `Target` is a Seam state, its changes automatically retarget the spring. `Speed` and `Dampening` may also be states and are read each frame.

## Properties
#### `Value : any`
Current spring position. Writable; assigning snaps the start position while keeping current velocity.

#### `Velocity : any`
Current spring velocity. Readable and writable.

#### `Target : any`
Write-only target. Assign to retarget; reading `.Target` is not supported.

#### `Speed : number | Value`
Spring frequency. Readable and writable.

#### `Dampening : number | Value`
Damping ratio. Readable and writable.
- `0` — undamped
- Between `0` and `1` — underdamped (bouncy)
- `1` — critically damped
- Greater than `1` — overdamped

## Events
#### `Changed`
Fired when `.Value` changes during simulation.

#### `AttachedToInstance`
Fired when bound to an instance property through `New`.

## Methods
#### `Destroy()`
Stops simulation and cleans up.

## Usage
```lua
local Goal = Value(0)
local Motion = Spring(Goal, 30, 0.8)

Goal.Value = 1 -- Retargets the spring

-- Or set the target directly:
Motion.Target = 0
```

Bind to properties:

```lua
New("Frame", {
	Position = Spring(Goal, 25, 1),
})
```

Multi-component types such as `Vector3`, `UDim2`, and `Color3` are unpacked into per-channel springs. When settled within a small epsilon, the spring sleeps until the target or parameters change.
