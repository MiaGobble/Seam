## Spring
* Type: Object
* Since: 0.0.1
* Scopeable: Yes

## Construction
```
Spring(Target : Value | any, Speed : number, Dampening : number)
```

## Properties
### `Value : any`
The position of the spring. 

### `Velocity : any`
The velocity of the spring.

### `Target : Value | any`
The target that the spring should reach.

### `Dampening : number`
A value between 0 and 1 describing the friction of the spring. Going over 1 applies overdamping.

### `Speed : number`
The speed of the spring.

## Events
### `Changed`
Fired when the value of the spring changes

## Usage
It's recommended that you import `Spring` from the Seam module so that you can use it later on:

```lua
local Seam = require(ReplicatedFirst.Seam)
local Spring = Seam.Spring
```

Springs are [animation](./index.md) objects that simulate hooke's law[^1] in any Roblox type. There are four types of springs:[^2]
* Undamped (dampening = 0)
* Underdamped (1 > dampening > 0)
* Critically damped (dampening = 1)
* Overdamped (dampening > 1)

Each of these provide different levels of simulated frictino, with undampended being the least and overdamped being the most. Critically damped springs create just enough friction to have no "bounce".

Springs can be created on their own, like this:

```lua
local MySpring = Spring(0, 30, 0.8)
```

And/or as a property of a hydrated Seam object, like this:

```lua
local Object = New("Object", {
    Position = Spring(0, 30, 0.8)
})
```

*Documention TBD*

[^1]: https://en.wikipedia.org/wiki/Hooke%27s_law
[^2]: https://en.wikipedia.org/wiki/Damping