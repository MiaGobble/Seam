---
sidebar_position: 3
---

# Spring
An animation state using the spring method

|Type|Since|Scoped|
|----|-----|------|
|State|0.0.1|Yes|

## Constructor
```lua
Spring(Target : Value | any, Speed : number, Dampening : number)
```

## Properties
#### `Value : any`
The position of the spring.

#### `Velocity : any`
The velocity of the spring.

#### `Target : Value | any`
The target value that the spring position should reach.

#### `Dampening : number`
A value between 0 and 1 describing the friction of the spring. Going over 1 applies overdamping.

#### `Speed : number`
The speed of the spring.

## Events
#### `Changed`
Fired when `.Value` changes.

## Usage
Springs are animation objects that simulate hooke’s law in any Roblox type. There are four types of springs:- Undamped (dampening = 0)
- Underdamped (1 > dampening > 0)
- Critically damped (dampening = 1)
- Overdamped (dampening > 1)Each of these provide different levels of simulated friction, with undampended being the least and overdamped being the most. Critically damped springs create just enough friction to have no “bounce”.Springs can be created on their own, like this:

```lua
local Seam = require(ReplicatedFirst.Seam)
local Spring = Seam.Spring

local MySpring = Spring(0, 30, 0.8)
```

Or as a property of a hydrated Seam object, like this:

```lua
local Seam = require(ReplicatedFirst.Seam)
local Spring = Seam.Spring

local Object = New("Object", {
    Position = Spring(0, 30, 0.8)
})
```

Springs are a great way to do either bouncy or smooth animation, without having to declare a tween.