---
sidebar_position: 7
---

# Making a component
Seam components exist to create reusable constructors and code surrounding instances. Examples of components could be buttons, moving parts, or lighting effects!

Below is an example script constructing a component.

```lua
local MyComponent = require(script.MyComponent)

local TestInstance = Scope:New(MyComponent, {
	Color = Color3.fromRGB(255, 0, 0),
})

local OtherInstance = Scope:New(MyComponent, {
	Color = Color3.fromRGB(0, 255, 0),
})
```

Previously, you learned you can input a string or instance into the first parameter of `New`. However, there is compatibility for a third option, that being a component you design.

The above example is using a module called *MyComponent*, which is a colored part. It looks like this:

```lua
local MyComponent = {}

local ReplicatedFirst = game:GetService("ReplicatedFirst")

local Seam = require(ReplicatedFirst.Seam)

function MyComponent:Init(Scope, Properties)
	
end

function MyComponent:Construct(Scope, Properties)
	return Scope:New("Part", {
		Color = Properties.Color,
		-- ...
	})
end

return Seam.Component(MyComponent)
```

All component modules have the following requirements:
* They must have an `:Init()` method
* They must have a `:Construct()` method
* The module must return the module table wrapped in `Seam.Component()`
* `Construct()` must return an Instance

And, when using components, the following happen in order:
* Seam converts the component module to be OOP, meaning you can use `self.xyz` properties
* Seam calls `Component:Init()`, passing the scope and properties
* Seam calls `Component:Construct()`, passing the scope and properties

You can also add in other component methods, and as long as they take in `self` or use `:`, it auto-formats those methods to the generated OOP class.

We can modify *MyComponent* to define a size for the created part in `Init()`, like so:

```lua
function MyComponent:Init(Scope, Properties)
	self.Size = Vector3.one
end

function MyComponent:Construct(Scope, Properties)
	return Scope:New("Part", {
		Color = Properties.Color,
		Size = self.Size, -- Declared in Init()
		-- ...
	})
end
```

But that's not all! We can also pass in custom properties for the two methods.

For example, let's say we modify the component `Construct` function to print a secret number passed in through properties:

```lua
function MyComponent:Construct(Scope, Properties)
	print(`My secret number is {Properties.SecretNumber}`)
	
	return Scope:New("Part", {
		Color = Properties.Color,
		Size = self.Size,
		-- ...
	})
end
```

This will work as long as we pass in a `SecretNumber` value in the properties dictionary in the parent script!

```lua
local TestInstance = Scope:New(MyComponent, {
	Color = Color3.fromRGB(255, 0, 0),
	SecretNumber = 5,
}) -- Prints "My secret number is 5!"

local OtherInstance = Scope:New(MyComponent, {
	Color = Color3.fromRGB(0, 255, 0),
	SecretNumber = 10,
}) -- Prints "My secret number is 10!"
```

And that's about it with components! You can read more in the API docs regarding `New` and `Component`.