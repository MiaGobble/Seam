## Tween
* Type: Object
* Since: 0.0.1
* Scopeable: Yes

## Construction
```
Tween(Target : Value | any, TweenInfo : TweenInfo)
```

## Properties
### `Value : any`
The position of the tween. 

### `Target : Value | any`
The target that the tween should reach.

### `TweenInfo : TweenInfo`
The TweenInfo associated with the tween object.


## Events
### `Changed`
Fired when the value of the spring changes

## Usage
It's recommended that you import `Tween` from the Seam module so that you can use it later on:

```lua
local Seam = require(ReplicatedFirst.Seam)
local Tween = Seam.Tween
```

Tweens can be created on their own, like this:

```lua
local MyTween = Tween(0, TweenInfo.new(5))
```

And/or as a property of a hydrated Seam object, like this:

```lua
local Object = New("Object", {
    Position = Tween(0, TweenInfo.new(5))
})
```

*Documention TBD*

[^1]: https://en.wikipedia.org/wiki/Hooke%27s_law
[^2]: https://en.wikipedia.org/wiki/Damping