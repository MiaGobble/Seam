---
sidebar_position: 7
---

# Bezier
A reactive state that evaluates a quadratic Bezier curve from four driving values.

|Type|Since|Scoped|
|----|-----|------|
|State|v1.0.0|Yes|

## Constructor
```lua
Bezier(Alpha : Value | any, Origin : Value | any, Midpoint : Value | any, Target : Value | any) -> BezierState
```

## Properties
#### `Value : any`
The current value of the Bezier curve. Read-only.

#### `Changed`
Fired when the computed value changes.

#### `Origin : any`
The starting value for the curve.

#### `Midpoint : any`
The control point for the curve.

#### `Target : any`
The target value for the curve.

#### `Alpha : any`
The interpolation value for the curve.

## Usage
`Bezier` computes a quadratic curve from the four driving values. `Alpha` controls how far the state is along the curve, `Origin` is the start, `Midpoint` is the control point, and `Target` is the end.

`Bezier` is useful when you want curved motion that still reacts to live inputs.

```lua
local Progress = Value(0)
local Start = Vector2.new(0, 0)
local Control = Vector2.new(0.5, 1)
local Finish = Vector2.new(1, 0)

local Curve = Bezier(Progress, Start, Control, Finish)

Progress.Value = 0.5
print(Curve.Value)
```