---
sidebar_position: 3
---

# IsState
Returns whether a value is a recognized Seam state.

|Type|Since|Scoped|
|----|-----|------|
|Utility|0.3.3|No|

## Constructor
```lua
IsState(CheckedValue : any?) -> boolean
```

## Usage
Recognized symbols: `Value`, `Spring`, `Tween`, `Bezier`, `Resource`, `ComputedInstance`, `RenderedInstance`.

`ForPairs` instances are `ComputedInstance` under the hood, so they return `true`.

```lua
print(IsState(Value(100))) -- true
print(IsState(200)) -- false
```
