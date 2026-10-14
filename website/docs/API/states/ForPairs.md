---
sidebar_position: 6
---

# ForPairs
A reactive state that updates based on when other values update, similar to computed, but only updating for specific key changes.

|Type|Since|Scoped|
|----|-----|------|
|State|0.4.3|Yes|

## Constructor
```lua
Computed(ReactiveValue : Value, CalculationFunction : (Use : (Value : Value) -> Value.Value, Index : any, Value: any) -> nil)
```

## Properties
#### `Value : any`
The current value of the ForPairs state. Read-only.

## Usage
`ForPairs` works just like computed behind the scenes, with the exception that only certain key changes will be triggered by index values in an array or dictionary value changes.

:::info 

`ForPairs` is a better altnerative to `Computed` when re-computing similar arrays or dictionaries of data. For example, an inventory grid of items would benefit from this state, since `Computed` would force-computed every key, regardless of what changed specifically.

:::

To construct, the first argument should be a value object that is always a table, with the second argument being a calculation similar to what you use in `Computed`. In addition to `Use`, this callback also passes `Index` and `Value`.

Rather than returning a final result calculation, you will only calculate on a per-value basis in the table.

Here is an example:

```lua
local MyValue = Value({1, 2, 3})

local TestState = ForPairs(MyValue, function(Use, Index, Value)
    return `{Index} = {Value * 2}`
end)

print(TestState.Value) -- Prints "1 = 2, 2 = 4, 3 = 6"

MyValue.Value = {4, 5, 6}

print(TestState.Value) -- Prints "1 = 8, 2 = 10, 3 = 12"
```