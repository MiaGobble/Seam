---
sidebar_position: 4
---

# IsComponent
Checks if a userdata value is a Seam component.

|Type|Since|Scoped|
|----|-----|------|
|Utility|0.3.3|No|

## Constructor
```lua
IsComponent(CheckedObject : any)
```

## Usage
If you need to quickly check if a userdata is a component, use this. It can be used like so:

```lua
local IsComponent = Seam.IsComponent

local MyComponent = require(path.to.component) -- Assume this is a Seam component built with Component()
local NotComponent = {Foo = "Hi!"}

print(IsComponent(MyComponent)) -- Prints true
print(IsComponent(NotComponent)) -- Prints false
```