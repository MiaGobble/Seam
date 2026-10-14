---
sidebar_position: 7
---

# Attribute
Sets an instance attribute, optionally bound to a Seam state.

|Type|Since|Scoped|
|----|-----|------|
|Declaration|0.0.3|No|

## Constructor
```lua
[Attribute(AttributeName : string)] = any | State
```

## Usage
```lua
New(MyObject, {
	[Attribute "Lemons"] = 5,
})

print(MyObject:GetAttribute("Lemons")) -- 5
```

Pass a state to keep the attribute in sync:

```lua
local Count = Value(0)

New(MyObject, {
	[Attribute "Lemons"] = Count,
})

Count.Value = 3 -- Attribute updates to 3
```

Returns a cleanup function that restores the previous attribute value. Connections disconnect when the instance is destroyed. The binding also exposes `Destroy()` to disconnect all active instances.
