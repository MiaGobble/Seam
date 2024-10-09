## Computed
* Type: Object
* Since: 0.0.1
* Scopeable: No

## Construction
```
Value(Value : any)
```

## Properties
### `Value : any`
The current value.

```lua
local Seam = require(ReplicatedFirst.Seam)
local Value = Seam.Value
```

`Value` is a flexible state that can be used in any of the following:
* `New`
* `Spring`
* `Tween`

Or, it can also be used by itself.

To make a new value, simply call `Value()`, and in the parameters enter a single value of any type. To change or read the value, use the property `Value.Value`.

For example:
```lua
local MyValue = Value("Foo")

MyValue.Value = "Bar"

print(MyValue.Value) -- Prints "bar"
```

In `New`, you can use it like so:

```lua
local MyObject = New("Frame", {
    Position = MyValue -- The value object
})
```

At this point, when you update `MyValue`, it will reflect those changes in the position for *MyObject*.

Similar behavior can be done for `Spring` and `Tween`, like so:

```lua
local MySpring = Spring(MyValue, 30, 1)
local MyTween = Tween(MyValue, TweenInfo.new(5))
```

In these two cases, changing `MyValue` will update the target of the animation states.

*Documention TBD*