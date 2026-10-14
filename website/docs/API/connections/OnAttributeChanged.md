---
sidebar_position: 3
---

# OnAttributeChanged
Used to track attribute changes in states or instances

|Type|Since|Scoped|
|----|-----|------|
|Connection|0.0.3|Yes|

## Constructor
```lua
[OnAttributeChanged(AttributeName : string)] = () -> nil
```

## Usage
`OnChanged` is an Seam index to be used in the `New` constructor. `OnChanged` detects when an instance changes, e.g. when it changes color or size. Similarly, `OnAttributeChanged` tracks changes from attributes, with a key difference being that you can declare what attribute should be tracked.

You can use it like so:

```lua
New(MyObject, {
  [OnAttributeChanged "Lemons"] = function()
      -- The following prints when the "lemons" property changes
      print("Lemonssssss! We now have " .. MyObject:GetAttribute("Lemons") .. " lemons!")
  end
})

MyObject:SetAttribute("Lemons", 5)
```

This is equivalent to connecting to `Instance:GetAttributeChangedSignal()`