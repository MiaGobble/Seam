## New
* Type: Object
* Since: 0.0.1
* Scopeable: Yes

## Construction
```
New(Object : string | Instance, Properties : {[any] : any}, From : From?) -> Instance
```

## Usage
It's recommended that you import `New` from the Seam module so that you can use it later on:

```lua
local Seam = require(ReplicatedFirst.Seam)
local New = Seam.New
```

`New` is the heart of Seam, giving everything the framework functionality. It's a constructor to make new instances, or hydrate existing ones.

To make a brand new instance, use `New` like this:

```lua
local Object = New("Frame", {
    -- Properties here
})
```

Or alternatively, hydrate an existing instance by replacing the string with the instance you want, like this:

```lua
local Object = New(ExistingFrame, {
    -- Properties here
})
```

There are three parameters: **object** (as a string or instance), **properties** (as a dictionary), and optionally a common component (via `From`. Read more [here](./from.md)).

When you create a new object, it returns an instance.

In the properties, you can also use Seam "indexes", such as [OnChanged](./onchanged) and [Children](./children.md).

*Documention TBD*