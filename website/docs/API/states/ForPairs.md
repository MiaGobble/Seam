---
sidebar_position: 6
---

# ForPairs
A reactive map over a table value that only recomputes entries whose keys changed.

|Type|Since|Scoped|
|----|-----|------|
|State|0.4.3|Yes|

## Constructor
```lua
ForPairs(
	TrackedValue : Value,
	Callback : (Use : (State | any) -> any, Index : any, EntryValue : any) -> any
) -> ForPairs
```

`TrackedValue` must resolve to a table.

## Properties
#### `Value : {[any] : any}`
A table of per-key results. Read-only. Unchanged keys reuse their previous outputs.

## Events
#### `Changed`
Fired when the mapped table changes. Inherited from the inner `Computed`.

#### `AttachedToInstance`
Fired when bound to an instance property through `New`.

## Methods
#### `Destroy()`
Cleans up the underlying computed state.

## Usage
`ForPairs` is built on `Computed`, but only re-runs the callback for indices whose source values changed. That makes it a better fit than a full `Computed` rebuild for inventories, grids, and other keyed collections.

```lua
local Numbers = Value({1, 2, 3})

local Doubled = ForPairs(Numbers, function(Use, Index, EntryValue)
	return `{Index} = {EntryValue * 2}`
end)

print(Doubled.Value)
-- {
--   [1] = "1 = 2",
--   [2] = "2 = 4",
--   [3] = "3 = 6",
-- }

Numbers.Value = {4, 5, 6}

print(Doubled.Value)
-- {
--   [1] = "1 = 8",
--   [2] = "2 = 10",
--   [3] = "3 = 12",
-- }
```

:::info

Prefer `ForPairs` over `Computed` when only some keys in a table change. A plain `Computed` rebuilds every entry on each update.

:::

The callback receives `Use` (same semantics as `Computed`), plus the current `Index` and `EntryValue` for that key.
