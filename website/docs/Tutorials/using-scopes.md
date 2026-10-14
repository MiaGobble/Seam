---
sidebar_position: 6
---

# Using scopes
As you begin to use Seam, you might be wondering if there is a built-in way to manage memory and instances. Guess what, there is!

This concept is presented in Seam using "scopes". A scope allows you to group instances that should be cleaned up with each other.

To start, let's make a new script declaring Seam's scope declaration:

```lua
local Seam = require(Path.To.Seam)
local Scope = Seam.Scope
```

Making a scope is super easy. By default, you could call `Scope`, inputting the entirety of Seam's library to use under a cleanup group.

You do it like so:

```lua
local MainScope = Scope(Seam)
```

Now, you can use Seam stuff in a special environment!

Let's use scopes from a previous example. Remember when we did the floating block in a previous tutorial? We can do the same thing, but under a scope:

```lua
local MainScope = Scope(Seam)

local PartPosition = MainScope:Value(Vector3.new(0, 5, 0))
local AnimatedPartPosition = MainScope:Spring(PartPosition, 2, 0.1)

local MyPart = MainScope:New("Part", {
	Size = Vector3.new(5, 5, 5),
	Anchored = true,
	Position = AnimatedPartPosition,
	Parent = workspace,
	Color = Color3.fromRGB(255, 100, 100),

	[Children] = {
		MainScope:New("Decal", {
			Texture = "rbxassetid://32012505",
			Face = "Front",
		})
	}
})

while true do
	task.wait(2)
	PartPosition.Value = Vector3.new(0, 6, 0)
	task.wait(2)
	PartPosition.Value = Vector3.new(0, 5, 0)
end
```

Notice that we put `MainScope:` prior to anything that makes something. This is important, since it allows us to later destroy everything at once by just destroying the scope.

For example, we could make 10 parts in a `for` loop:

```lua
for _ = 1, 10 do
	local MyPart = MainScope:New("Part", {
		Size = Vector3.new(5, 5, 5),
		Anchored = true,
		Position = AnimatedPartPosition,
		Parent = workspace,
		Color = Color3.fromRGB(255, 100, 100),

		[Children] = {
			MainScope:New("Decal", {
				Texture = "rbxassetid://32012505",
				Face = "Front",
			})
		}
	})
end
```

And then destroy them all with this:

```lua
MainScope:Destroy() -- Destroys all 10 parts made, as well as the value and spring
```

We can also create "inner scopes" to each scope for a sort of branching. In our example, inner scopes would be great if we wanted to clean up the decals separately from the parts.

Create an inner scope like this:

```lua
local MainScope = Scope(Seam)

-- Making a branch of the main scope
local DecalsScope = MainScope:InnerScope()
```

We can then edit the 10 part creator to use the decals inner scope for only the decals:

```lua
for _ = 1, 10 do
	local MyPart = MainScope:New("Part", {
		Size = Vector3.new(5, 5, 5),
		Anchored = true,
		Position = AnimatedPartPosition,
		Parent = workspace,
		Color = Color3.fromRGB(255, 100, 100),

		[Children] = {
			-- We changed the below scope from MainScope to DecalsScope
			
			DecalsScope:New("Decal", { -- ❗
				Texture = "rbxassetid://32012505",
				Face = "Front",
			})
		}
	})
end
```

And we can also destroy the inner scope separately from the main scope:

```lua
-- Destroys the decals, but not the parts
DecalsScope:Destroy()
```

Or, if we wanted, we can *still* destroy everything at once:

```lua
-- Destroys the parts AND the decals
MainScope:Destroy()
```

Destroying a parent scope destroys all inner scopes, but not vice-versa.

We can also create custom scopes by declaring a table instead of inputting Seam, like so:

```lua
local function MakeSomething(Scope)
	return New("Frame", {
		-- Properties...
	})
end

local MainScope = Scope({
	MakeSomething = MakeSomething
})
```

Anything made with functions in these scopes, if they return the instance created, will be automatically cleaned up:

```lua
for _ = 1, 100 do
	MainScope:MakeSomething() -- Makes our thing by calling the function
end

MainScope:Destroy() -- Destroys all things made
```

And that's all scopes are! Now, that you've learned this and everything before, it's time to finally try components.