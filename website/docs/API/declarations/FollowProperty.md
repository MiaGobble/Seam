---
sidebar_position: 5
---

# FollowProperty
Tracks property changes and propagates updated userdata to states.

|Type|Since|Scoped|
|----|-----|------|
|Declaration|0.0.3|No|

## Constructor
```lua
[FollowProperty(PropertyName : string)] = Value
```

## Usage
Using it as a constructor index, declare `FollowProperty()` with a string parameter matching the property name you want followed, and set the value to the value you want updated.

```lua
local CurrentColor = Value(Color3.fromRGB(255, 255, 255))

New(MyObject, {
   [FollowProperty "Color3"] = CurrentColor, -- When Color3 property updates, it will set CurrentColor to the new value
})

MyObject.Color3 = Color3.fromRGB(50, 50, 50) -- This will be reflected in CurrentColor
```

Whenever the attached state changes, the property does not change. Instead, the way this works is that the property changes get reflected into the state value, meaning that using `Instance.xyz = abc` will trigger the change and any reactivity to it.