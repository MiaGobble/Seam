## Computed
* Type: Object
* Since: 0.0.1
* Scopeable: Yes

## Construction
```
Computed(CalculationFunction : () -> nil)
```

## Properties
### `Value : any`
The current value of the computation.

## Usage
It's recommended that you import `Computed` from the Seam module so that you can use it later on:

```lua
local Seam = require(ReplicatedFirst.Seam)
local Computed = Seam.Computed
```

`Computed` acts as a state that is updated every frame. For example, if you want the x-position of a frame instance to be based on `math.sin(os.clock())`, then you can do:

```lua
New(MyFrame, {
    Position = Computed(function()
        return Udim2.fromScale(math.sin(os.clock()), 0.5)
    end)
})
```

Computeds can be created on their own, like this:

```lua
local MyComputation = Computed(function()
    return math.sin(os.clock())
end)
```

And/or embedded like this:

```lua
New("Object", {
    Position = Computed(function()
        return math.sin(os.clock())
    end)
})
```

*Documention TBD*