---
sidebar_position: 6
---

# FollowAttribute
Tracks attribute changes and propagates updated userdata to states.

|Type|Since|Scoped|
|----|-----|------|
|Declaration|0.0.3|No|

## Constructor
```lua
[FollowAttribute(AttributeName : string)] = Value
```

## Usage
Similarly to `FollowProperty()`, it as a constructor index; declare `FollowAttribute()` with a string parameter matching the attribute name you want followed, and set the value to the value you want updated.

```lua
local NumApples = Value(0)

New(MyObject, {
   [FollowAttribute "Apples"] = NumApples, -- When the "Apples" attribute changes, NumApples updates
})

MyObject:SetAttribute("Apples", 5) -- Updates NumApples to 5 as well
```

Whenever the attached state changes, the attribute does not change. Instead, the way this works is that the attribute changes get reflected into the state value, meaning that using `Instance:SetAttribute()` will trigger the change and any reactivity to it.