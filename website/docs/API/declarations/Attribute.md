---
sidebar_position: 7
---

# Attribute
Sets an object's attribute to any value

|Type|Since|Scoped|
|----|-----|------|
|Declaration|0.0.3|No|

## Constructor
```lua
[Attribute(AttributeName : string)] = any
```

## Usage
When using `New()`, you can input property names and associate them with any values. However, if you want to set an attribute instead, you can use `Attribute()`, like so:

```lua
New(MyObject, {
   [Attribute "Lemons"] = 5, -- Sets attribute "Lemons" to 5
})

print(MyObject:GetAttribute("Lemons")) -- Prints "5"
```

This is equivalent to doing `Instance:SetAttribute()`, but with the added benefit to also attach states to the attribute.