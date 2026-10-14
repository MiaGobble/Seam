---
sidebar_position: 10
---

# Tags
Adds `CollectionService` tags to an instance.

|Type|Since|Scoped|
|----|-----|------|
|Declaration|0.3.1|No|

## Constructor
```lua
[Tags] = {string}
```

## Usage
`Tags` is an easy way of adding `CollectionService` tags to an instance you are creating or hydrating with `New`.

It must be an index in `New`'s properties, like so:

```lua
local NewObject = New(Object, {
    [Tags] = {"X", "Y", "Z"} -- Adds "X", "Y", and "Z" CollectionService tags to Object

    -- Other properties, etc...
})
```

An equivalent to the above example would be to call `Instance:AddTag()` for each of the provided strings.