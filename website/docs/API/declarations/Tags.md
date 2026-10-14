---
sidebar_position: 10
---

# Tags
Adds CollectionService tags to an instance.

|Type|Since|Scoped|
|----|-----|------|
|Declaration|0.3.1|No|

## Constructor
```lua
[Tags] = {string}
```

## Usage
```lua
New(Object, {
	[Tags] = {"X", "Y", "Z"},
})
```

Equivalent to calling `Instance:AddTag` for each string. Returns a cleanup function that removes those tags again when hydration/scope teardown runs the returned cleanup.
