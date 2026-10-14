---
sidebar_position: 1
---

# Value
A core state representing a single mutable value.

|Type|Since|Scoped|
|----|-----|------|
|State|0.0.1|Yes|

## Constructor
```lua
Value(InitialValue : any) -> Value
```

Tables passed in are cloned before storage.

## Properties
#### `Value : any`
The current value. Readable and writable. After the first non-nil write, the value's type is locked; assigning a different type errors. Assignments that do not change the value do not fire `Changed`.

## Events
#### `Changed`
Fired when `.Value` changes. Listeners receive `"Value"` and the new value (through Seam's batching layer).

#### `AttachedToInstance`
Fired when this state is bound to an instance property through `New`.

## Methods
#### `TableSet(NewTargetValue : any, Path : {any}?)`
Replaces a nested table entry by cloning the path to that entry, then assigning. An empty or omitted path replaces the entire `.Value`.

#### `TableInsert(InsertedValue : any, Path : {any}?)`
Inserts into a nested table after cloning the path.

#### `TableRemove(Index : number, Path : {any}?)`
Removes an array index from a nested table after cloning the path.

#### `Destroy()`
Cleans up the value and its bindings.

## Usage
```lua
local MyValue = Value(0)
print(MyValue.Value) -- 0

MyValue.Value = 1 -- Fires Changed
```

Pass a `Value` into animation states so updates retarget automatically:

```lua
local Goal = Value(0)
local Motion = Spring(Goal, 20, 1)

Goal.Value = 1 -- Spring retargets
```

Use table helpers for immutable nested updates:

```lua
local Inventory = Value({
	Weapons = {"Sword"},
})

Inventory:TableInsert("Shield", {"Weapons"})
print(Inventory.Value.Weapons[2]) -- "Shield"

Inventory:TableSet("Bow", {"Weapons", 1})
Inventory:TableRemove(2, {"Weapons"})
```

When bound through `New`, table values are cloned onto the instance so consumers do not share the internal table reference.

`LockValue(MyValue)` permanently freezes writes and destroys the reactive backend for that value.
