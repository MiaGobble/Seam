---
sidebar_position: 8
---

# Resource
A reactive state for async-loaded values with explicit load status.

|Type|Since|Scoped|
|----|-----|------|
|State|v1.0.0|Yes|

## Constructor
```lua
Resource(Callback : () -> T) -> ResourceState
```

## Properties
#### `Value : any`
The current loaded value. Read-only while loading.

#### `Status : "Idle" | "Loading" | "Ready" | "Error"`
The current load status.

#### `Error : any`
The last error produced by the callback, if any.

#### `Changed`
Fired when the resource transitions or resolves.

## Methods
#### `Refresh()`
Starts a new load and invalidates any stale async completions.

## Usage
Use `Resource` when the value depends on an async workflow such as fetching data or waiting on another task.

`Resource` starts loading automatically on creation. While the callback is running, `Status` is `"Loading"`; if it resolves, `Status` becomes `"Ready"`, and if it throws, `Status` becomes `"Error"`. A newer refresh invalidates older async results, so stale completions do not overwrite the latest value.

```lua
local ProfileResource = Resource(function()
	return ReplicatedStorage.GetSecret:InvokeServer()
end)

print(ProfileResource.Status) -- "Loading" at first

OnChanged(ProfileResource, function()
	print(ProfileResource.Value) -- Prints the new
end)

task.delay(5, function()
    ProfileResource:Refresh() -- Update the state with the new secret
end)
```