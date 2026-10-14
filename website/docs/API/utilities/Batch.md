---
sidebar_position: 6
---

# Batch
Groups changed-signal emissions into a transaction window.

|Type|Since|Scoped|
|----|-----|------|
|Utility|v1.0.0|No|

## Callable Form
```lua
Batch(Function : (...any) -> ...any, ...any) -> ...any
```

## Methods
#### `Begin()`
Starts a batch transaction.

#### `End()`
Ends the current batch transaction and flushes queued emissions when the outermost transaction closes.

## Usage
`Batch` supports nested transactions. While a batch is active, changed emissions are queued and the last queued arguments for each signal win when the outermost transaction ends. The callable form wraps `Begin()` and `End()` around a function so you can batch a block without manual cleanup.

Wrap multiple state writes in a batch when you want them to flush as one signal window.

```lua
Batch(function()
	MyValue1.Value = 10
	MyValue2.Value = 20
end)
```