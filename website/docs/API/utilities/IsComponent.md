---
sidebar_position: 4
---

# IsComponent
Returns whether a value is a Seam component created with `Component`.

|Type|Since|Scoped|
|----|-----|------|
|Utility|0.3.3|No|

## Constructor
```lua
IsComponent(CheckedValue : any?) -> boolean
```

## Usage
```lua
local MyComponent = require(Path.To.Component) -- returned from Component(...)
local NotComponent = {Foo = "Hi!"}

print(IsComponent(MyComponent)) -- true
print(IsComponent(NotComponent)) -- false
```
