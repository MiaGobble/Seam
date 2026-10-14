---
sidebar_position: 2
---

# Basic sprinting mechanic
Sprinting is a movement mechanic that belongs to many, many games. We can use Seam to take advantage of states and animation!

Below is what the result looks like:

![](../../static/img/examples/sprinting.gif)

This the entire script for it:

```lua
local WALK_SPEED = 16
local SPRINT_SPEED = 35

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ContextActionService = game:GetService("ContextActionService")
local PlayersService = game:GetService("Players")

local Seam = require(ReplicatedFirst.Seam)
local Scope = Seam.Scope(Seam)

local Player = PlayersService.LocalPlayer

local IsSprinting = Scope:Value(false) -- The value we changed

local SprintTargetSpeed = Scope:Computed(function(Use) -- The speed based on whether we are sprinting
	if Use(IsSprinting) then
		return SPRINT_SPEED
	else
		return WALK_SPEED
	end
end)

local function CharacterAdded(Character : Model)
	local Humanoid : Humanoid = Character:WaitForChild("Humanoid")
	
	Scope:New(Humanoid, {
		WalkSpeed = Scope:Spring(SprintTargetSpeed, 20, 1) -- We use a spring so that it's not a sudden change
	})
end

local function InitBinds()
	ContextActionService:BindAction("Sprint", function(_, InputState : Enum.UserInputState, InputObject : InputObject)
		if InputState == Enum.UserInputState.Begin then
			IsSprinting.Value = true -- Start sprinting
		elseif InputState == Enum.UserInputState.End then
			IsSprinting.Value = false -- Stop sprinting
		end
	end, true, Enum.KeyCode.LeftShift, Enum.KeyCode.ButtonL3)
end

if Player.Character then
	CharacterAdded(Player.Character)
end

Player.CharacterAdded:Connect(CharacterAdded)
InitBinds()
```