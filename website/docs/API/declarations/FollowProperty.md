---
sidebar_position: 5
---

# FollowProperty
One-way sync from an instance property into a Seam value state.

|Type|Since|Scoped|
|----|-----|------|
|Declaration|0.0.3|No|

## Constructor
```lua
[FollowProperty(PropertyName : string)] = Value
```

## Usage
When the named property changes on the instance, the provided `Value` is updated. Changes to the state do **not** write back to the property.

```lua
local CurrentColor = Value(Color3.fromRGB(255, 255, 255))

New(MyPart, {
	[FollowProperty "Color"] = CurrentColor,
})

MyPart.Color = Color3.fromRGB(50, 50, 50) -- CurrentColor updates
```

There is no initial sync on attach — only subsequent property-changed signals update the state. Returns a cleanup function; the binding also has `Destroy()` to disconnect all tracked instances.
