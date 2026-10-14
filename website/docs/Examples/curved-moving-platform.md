---
sidebar_position: 3
---

# Curved moving platform
Let's make a moving platform, similar to what you see in platformer games!

It looks like this:

![](../../static/img/examples/moving-platform.gif)

And this is the code for it:

```lua
local PLATFORM_MOVE_TIME = 3

local ReplicatedFirst = game:GetService("ReplicatedFirst")

local Seam = require(ReplicatedFirst.Seam)
local Scope = Seam.Scope(Seam)
local EventSequence = Seam.EventSequence

local StartPoint = workspace:WaitForChild("StartPoint") -- An existing part in workspace
local MidPoint = workspace:WaitForChild("MidPoint") -- An existing part in workspace
local EndPoint = workspace:WaitForChild("EndPoint") -- An existing part in workspace

local AlphaTarget = Scope:Value(0)
local AnimatedAlpha = Scope:Tween(AlphaTarget, TweenInfo.new(PLATFORM_MOVE_TIME))
local Bezier = Scope:Bezier(AnimatedAlpha, StartPoint.Position, MidPoint.Position, EndPoint.Position)

local Platform = Scope:New(workspace:WaitForChild("Platform"), {
	Position = Bezier,
}) -- An existing part in workspace

local Animation = EventSequence({
	{5, function()
		AlphaTarget.Value = 1
	end},

	{5, function()
		AlphaTarget.Value = 0
	end},
})

Animation.Looped = true
Animation:Play()
```