---
sidebar_position: 4
---

# Lifetime
Schedules automatic destruction of an instance after a delay.

|Type|Since|Scoped|
|----|-----|------|
|Declaration|0.0.3|No|

## Constructor
```lua
[Lifetime] = number
```

## Usage
```lua
New(MyObject, {
	[Lifetime] = 5, -- Destroy after 5 seconds
})
```

Uses `Debris:AddItem` internally.
