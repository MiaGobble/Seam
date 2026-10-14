---
sidebar_position: 6
---

# Batch
Groups Seam changed-signal emissions into a transaction window.

|Type|Since|Scoped|
|----|-----|------|
|Utility|v1.0.0|No|

## Callable Form
```lua
Batch(Callback : (...any) -> ...any, ...any) -> ...any
```

Wraps `Begin` / `End` around the callback. Errors are re-raised after the batch ends.

## Methods
#### `Begin()`
Starts (or nests) a batch transaction.

#### `End()`
Ends the current transaction. When the outermost batch closes, queued emissions flush. Calling `End` without a matching `Begin` errors.

## Usage
While a batch is active, Seam state `Changed` emissions are queued. Nested batches are supported. For each signal, the last queued arguments win when the outermost batch ends.

```lua
Batch(function()
	MyValue1.Value = 10
	MyValue2.Value = 20
end)
```

Or manually:

```lua
Batch.Begin()
MyValue1.Value = 10
MyValue2.Value = 20
Batch.End()
```

Use `Batch` when updating many dependent states at once to avoid intermediate recomputes.
