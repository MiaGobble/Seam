## Children
* Type: Index
* Since: 0.0.1
* Scopeable: No

## Usage
It's recommended that you import `Children` from the Seam module so that you can use it later on:

```lua
local Seam = require(ReplicatedFirst.Seam)
local Children = Seam.Children
```

`Children` is used as in index in the `New` constructor to declare the children of said instance. It's used like this:

```lua
local Object = New("Object", {
    Property = Value,
    Property2 = Value2,

    [Children] = {
        ...
    }
})
```

*Documention TBD*