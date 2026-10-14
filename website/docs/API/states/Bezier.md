---
sidebar_position: 7
---

# Bezier
A reactive state that evaluates a quadratic Bezier curve from four driving inputs.

|Type|Since|Scoped|
|----|-----|------|
|State|v1.0.0|Yes|

## Constructor
```lua
Bezier(
	Alpha : Value | any,
	Origin : Value | any,
	Midpoint : Value | any,
	Target : Value | any
) -> Bezier
```

`Alpha` must resolve to a number (clamped to `0`–`1`). `Origin`, `Midpoint`, and `Target` must resolve to the same type.

## Properties
#### `Value : any`
Current point on the curve. Read-only for the computed result. Assigning `.Value` sets `Origin`, `Midpoint`, and `Target` to the same input.

#### `Alpha : any`
Interpolation progress. Readable as the original input; assignable to rebind a constant or state.

#### `Origin : any`
Curve start. Readable as the original input; assignable to rebind.

#### `Midpoint : any`
Control point. Readable as the original input; assignable to rebind.

#### `Target : any`
Curve end. Readable as the original input; assignable to rebind.

## Events
#### `Changed`
Fired when the computed curve value changes.

#### `AttachedToInstance`
Fired when bound to an instance property through `New`.

## Methods
#### `Destroy()`
Disconnects input listeners and cleans up.

## Usage
```lua
local Progress = Value(0)
local Start = Vector2.new(0, 0)
local Control = Vector2.new(0.5, 1)
local Finish = Vector2.new(1, 0)

local Curve = Bezier(Progress, Start, Control, Finish)

Progress.Value = 0.5
print(Curve.Value)
```

Pass Seam states for any of the four inputs to keep the curve live. Multi-component types are evaluated per channel through Seam's value packer.
