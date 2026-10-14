---
sidebar_position: 8
---

# Resource
A reactive state for asynchronously loaded values with an explicit load status.

|Type|Since|Scoped|
|----|-----|------|
|State|v1.0.0|Yes|

## Constructor
```lua
Resource(Callback : () -> T) -> Resource
```

Starts loading immediately on construction.

## Properties
#### `Value : any`
The loaded value. Writable; assigning sets `Status` to `"Ready"` and clears `Error`.

#### `Status : "Idle" | "Loading" | "Ready" | "Error"`
Current load status. Writable for manual overrides.

#### `Error : any`
Error from the last failed callback, if any. Writable for manual overrides.

## Events
#### `Changed`
Fired when `Value`, `Status`, or `Error` transitions.

#### `AttachedToInstance`
Fired when bound to an instance property through `New`.

## Methods
#### `Refresh()`
Starts a new load. Increments an internal request id so stale async completions are ignored.

#### `Destroy()`
Cleans up the resource.

## Usage
```lua
local Profile = Resource(function()
	return ReplicatedStorage.GetProfile:InvokeServer()
end)

print(Profile.Status) -- "Loading"

OnChanged(Profile, function()
	if Profile.Status == "Ready" then
		print(Profile.Value)
	elseif Profile.Status == "Error" then
		warn(Profile.Error)
	end
end)

task.delay(5, function()
	Profile:Refresh()
end)
```

Flow: construct → `"Loading"` → `"Ready"` or `"Error"`. `"Idle"` is only present briefly before the first refresh begins.
