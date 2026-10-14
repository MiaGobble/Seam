---
sidebar_position: 1
---

# OnChanged
Connects to property changes on instances or Seam states.

|Type|Since|Scoped|
|----|-----|------|
|Connection|0.0.1|Yes|

## Constructors
Embedded in `New`:

```lua
[OnChanged] = (PropertyName : string, NewValue : any) -> ()
```

Standalone:

```lua
OnChanged(Object : Instance | State, Callback : (PropertyName : string, NewValue : any) -> ()) -> RBXScriptConnection
```

## Usage
Works with anything that exposes a `.Changed` signal and readable properties — including Seam states.

```lua
New("Frame", {
	[OnChanged] = function(PropertyName, NewValue)
		print(PropertyName, NewValue)
	end,
})
```

Standalone on a state:

```lua
local MyValue = Value(0)

local Connection = OnChanged(MyValue, function(PropertyName, NewValue)
	print(PropertyName, NewValue) -- "Value", 1
end)

MyValue.Value = 1
Connection:Disconnect()
```

For instances, this is equivalent to `Instance.Changed` with the new property value passed as the second argument.
