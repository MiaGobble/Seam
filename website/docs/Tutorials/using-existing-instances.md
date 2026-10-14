---
sidebar_position: 5
---

# Using existing instances
Using the `New` constructor, you can construct instances by passing in a string representing the type of instance. For example, doing `New("Part", {})` will make a new part.

However, having to make new instances for everything is really annoying sometimes! Fortunately, you can also pass in an instance to `New`, like in this example to change a baseplate color:

```lua
local Baseplate = New(workspace.Baseplate, {
	Color = Color3.fromRGB(255, 0, 0)
})
```

Everything else remains the exact same, so you can use animations and other states as well! This makes it easy to do a lot of things. For example, if you're making UI, you can pre-design all of your UI assets rather than having to make them in code.

This tutorial is short because it's here to just let you know you can use existing instances with Seam. Keep learning and see how to use scopes!