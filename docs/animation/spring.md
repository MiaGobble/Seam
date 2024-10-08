## Spring
| Type   | Since | Scopeable |
|--------|-------|-----------|
| Object | 0.0.1 | Yes       |

### Construction
```
Spring(Value : Value | any, Speed : number, Dampening : number)
```

### Usage
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

[^1]: https://en.wikipedia.org/wiki/Hooke%27s_law
[^2]: https://en.wikipedia.org/wiki/Damping