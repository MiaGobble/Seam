## DeclareComponent
* Type: Other
* Since: 0.0.1
* Scopeable: No

## Construction
```lua
DeclareComponent(ComponentName : string, Constructor : (HydratedInstance : Instance, ...any) -> Instance)
```

## Usage
It's recommended that you import `DeclareComponent` from the Seam module so that you can use it later on:

```lua
local Seam = require(ReplicatedFirst.Seam)
local DeclareComponent = Seam.DeclareComponent
```

`DeclareComponent` is used to declare components that you can later use. Components declared with this function can be called back to by using `From`.

Let's assume we want to declare a component that turns a frame into a blue one. We can declare this component by typing:

```lua
DeclareComponent("BlueFrame", function(Frame : Instance)
    Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
    return Frame
end)
```

To use this, we can later use `From`, like so:

```lua
local MyFrame = New("Frame", {
    --... Properties here
}, From "BlueFrame")
```

*Documentation TBD*