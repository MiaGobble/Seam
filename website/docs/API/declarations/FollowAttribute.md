---
sidebar_position: 6
---

# FollowAttribute
One-way sync from an instance attribute into a Seam value state.

|Type|Since|Scoped|
|----|-----|------|
|Declaration|0.0.3|No|

## Constructor
```lua
[FollowAttribute(AttributeName : string)] = Value
```

## Usage
When the named attribute changes, the provided `Value` is updated. Changes to the state do **not** write back to the attribute.

```lua
local NumApples = Value(0)

New(MyObject, {
	[FollowAttribute "Apples"] = NumApples,
})

MyObject:SetAttribute("Apples", 5) -- NumApples becomes 5
```

There is no initial sync on attach — only subsequent attribute-changed signals update the state. Returns a cleanup function; the binding also has `Destroy()`.
