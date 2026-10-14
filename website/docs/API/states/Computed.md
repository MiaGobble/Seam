---
sidebar_position: 2
---

# Computed
A reactive state that updates based on when other values update

|Type|Since|Scoped|
|----|-----|------|
|State|0.0.1|Yes|

## Constructor
```lua
Computed(CalculationFunction : (Use : (Value : Value) -> Value.Value) -> nil)
```

## Properties
#### `Value : any`
The current value of the compute state. Read-only.

## Usage
`Computed` acts as a state that is updated every frame. For example, if you want the x-position of a frame instance to be based on a number value, then you can do:

```lua
local XPosition = Value(0)

New(MyFrame, {
    Position = Computed(function(Use) -- Updates when XPosition changes
        return UDim2.fromScale(Use(XPosition), 0)
    end)
})

XPosition.Value = 0.5 -- Updates x position to 0.5, meaning compute.value = UDim2.fromScale(0.5, 0)
```

Computeds can be created on their own, like this:

```lua
local MyComputation = Computed(function(Use)
    return UDim2.fromScale(Use(XPosition), 0)
end)
```

Or embedded like this:

```lua
New(MyFrame, {
    Position = Computed(function(Use)
        return UDim2.fromScale(Use(XPosition), 0)
    end)
})
```

When you get a state's value with `Use`, you are telling the `Computed` instance to update anytime that read value updates. `Computed` will *not* react to values that are not wrapped with `Use`.