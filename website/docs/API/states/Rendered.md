---
sidebar_position: 5
---

# Rendered
A state that recomputes every frame on Seam's pre-update signal.

|Type|Since|Scoped|
|----|-----|------|
|State|0.0.3|Yes|

## Constructor
```lua
Rendered(Callback : (DeltaTime : number) -> any) -> Rendered
```

## Properties
#### `Value : any`
Latest callback result. Read-only. The first read forces one compute if the frame loop has not run yet.

## Events
#### `Changed`
Fired each frame after the callback runs (when the value updates through the batching layer).

#### `AttachedToInstance`
Fired when bound to an instance property through `New`.

## Methods
#### `Destroy()`
Disconnects the frame listener and cleans up.

## Usage
Unlike `Computed`, `Rendered` is not dependency-driven. It runs every frame on Seam's pre-update loop (`PreRender` on the client, `Heartbeat` on the server). `DeltaTime` is measured with `os.clock()` between those callbacks.

```lua
local Angle = 0

New(MyPart, {
	CFrame = Rendered(function(DeltaTime)
		Angle += DeltaTime
		return CFrame.Angles(0, Angle, 0)
	end),
})
```

Use `Rendered` when you need continuous sampling of non-reactive data. Prefer `Computed` when updates should only happen because Seam states changed.
