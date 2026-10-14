---
sidebar_position: 1
---

# Value
A core state representing a single value that can be set or read at any time

|Type|Since|Scoped|
|----|-----|------|
|State|0.0.1|Yes|

## Constructor
```lua
Value(Value : any)
```

## Properties
#### `Value : any`
The current state of the value object. Can be either set or read.

## Events
#### `Changed`
Fired when `.Value` changes.

## Methods
#### `TableSet(NewTargetValue : any, Path : {any}?)`
Replaces a table value by cloning the path to the target before mutating it.

#### `TableInsert(InsertedValue : any, Path : {any}?)`
Inserts a value into a table by cloning the path to the target before mutating it.

#### `TableRemove(Index : number, Path : {any}?)`
Removes a value from a table by cloning the path to the target before mutating it.

## Usage
To create a value object, simply call `Value()`, passing in any value type. In this case, we will be doing a number.

```lua
local MyValue = Value(0)
```

Value objects can lead to a reaction in another state. For example, in either springs or tweens, you can pass a value object in the first parameter. If you do, updating the value updates the animation.

```lua
local MyValue = Value(0)

local MySpring = Spring(MyValue, 20, 1) -- Updates whenever MyValue.Value changes
```

Values can also be used in computeds to update computations, like so:

```lua
New(MyFrame, {
    Position = Computed(function(Use)
        return UDim2.fromScale(Use(XPosition), 0)
    end)
})
```

You can read a value any time by reading the `.Value` property:

```lua
local MyValue = Value(0)

print(MyValue.Value) -- Prints 0
```

The table helpers create immutable updates by cloning the path to the changed entry before mutating it.

```lua
local Inventory = Value({
    Weapons = {"Sword"},
})

Inventory:TableInsert("Shield", {"Weapons"})
print(Inventory.Value.Weapons[2]) -- "Shield"
```