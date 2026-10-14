---
sidebar_position: 3
---

# OnAttributeChanged
Connects to changes of a specific instance attribute.

|Type|Since|Scoped|
|----|-----|------|
|Connection|0.0.3|Yes|

## Constructor
```lua
OnAttributeChanged(AttributeName : string) -> Binding

-- Embedded:
[OnAttributeChanged(AttributeName)] = () -> ()

-- Standalone:
OnAttributeChanged(AttributeName)(Instance, Callback) -> ()
```

## Methods (`Binding`)
#### `Destroy()`
Disconnects all active connections created by this binding.

## Usage
```lua
New(MyObject, {
	[OnAttributeChanged "Lemons"] = function()
		print(MyObject:GetAttribute("Lemons"))
	end,
})

MyObject:SetAttribute("Lemons", 5)
```

Equivalent to `Instance:GetAttributeChangedSignal(AttributeName):Connect(Callback)`.
