---
sidebar_position: 4
---

# Lifetime
Forces new and hydrated instances to be temporary.

|Type|Since|Scoped|
|----|-----|------|
|Declaration|0.0.3|No|

## Constructor
```lua
[Lifetime] = number
```

## Usage
Usage is simple; when using `New()`, set an index to `[Lifetime]`, with a value equal to the lifetime in seconds.

```lua
New(MyObject, {
    [Lifetime] = 5 -- Delete after 5 seconds
})
```

Behind the scenes this is just using `Debris:AddItem()`, which will guarantee cleanup.