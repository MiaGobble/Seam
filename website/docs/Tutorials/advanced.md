---
sidebar_position: 8
---

# Advanced
This tutorial is a guided tour of Seam's higher-level tools. Each section stands on its own, so the examples stay focused instead of forcing everything into one long flow.

## StyleSheet
`StyleSheet` lets you define reusable visual rules and apply them as a declaration. The declaration form is the primary way to use a theme in `New`.

```lua
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")

local Seam = require(ReplicatedFirst.Seam)
local New = Seam.New

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Create a reusable theme.
local Theme = Seam.StyleSheet.new()

-- Frames share the same base look.
Theme:Style("Frame")({
	BackgroundColor3 = Color3.fromRGB(24, 24, 28),
	BorderSizePixel = 0,
})

-- Labels use a lighter text color.
Theme:Style("TextLabel")({
	BackgroundTransparency = 1,
	TextColor3 = Color3.fromRGB(245, 245, 245),
})

local ScreenGui = New("ScreenGui", {
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	Parent = PlayerGui,

	-- Apply the stylesheet as part of construction.
	[Seam.StyleSheet] = Theme,
})
```

That declaration form is the normal way to theme something new. `Theme:Apply(root)` is still useful when the instance tree already exists and you want to style it after construction.

```lua
-- Apply the same theme later to an existing root.
Theme:Apply(ScreenGui)
```

`Unapply(root)` removes the theme and restores the original values that were changed.

## Resource
`Resource` is for async values that should expose a clear lifecycle. It starts in `Loading`, then moves to `Ready` or `Error`, and it ignores stale completions if a newer refresh happens first.

This example uses an HTTP request to fetch JSON data.

```lua
local HttpService = game:GetService("HttpService")
local Seam = require(game:GetService("ReplicatedFirst").Seam)

local Profile = Seam.Resource(function()
	local response = HttpService:RequestAsync({
		Url = "https://example.com/profile.json",
		Method = "GET",
	})

	if not response.Success then
		error(response.StatusCode)
	end

	return HttpService:JSONDecode(response.Body)
end)

-- Print the loaded data whenever it changes.
Seam.Inspect(Profile, "Profile Resource")
```

`Inspect` is a debugging aid here. It prints the state's changes for you, which is useful while you are checking that the request succeeds, the decoded value looks right, and later updates still behave correctly.

## OnAttached
`OnAttached` runs when a state is actually consumed by a reactive `New` usage. A plain read of the value does not count. That makes it good for lazy setup, telemetry, or one-time work that should only happen when something really uses the state.

```lua
local Seam = require(game:GetService("ReplicatedFirst").Seam)

local OnAttached = Seam.OnAttached
local Highlight = Seam.Value(Color3.fromRGB(255, 120, 120))

-- This callback runs only when Highlight is consumed by a reactive New call.
OnAttached(Highlight, function(AttachedInstance)
	print("Highlight was attached to", AttachedInstance.Name)
end)

local Button = Seam.New("TextButton", {
	Parent = script.Parent,
	Text = "Launch",
	TextColor3 = Highlight,
})
```

The callback receives the instance that triggered the attachment, so you can react to the actual consumer instead of the state object alone. If nothing uses the state in `New`, the callback never runs.

## Batch
`Batch` groups changed emissions so several state writes behave like one transaction window. That matters when multiple values should update together.

```lua
local Seam = require(game:GetService("ReplicatedFirst").Seam)

local Batch = Seam.Batch
local NameText = Seam.Value("Loading")
local RankText = Seam.Value("Please wait")

Batch(function()
	NameText.Value = "Astra"
	RankText.Value = "Explorer"
end)
```

Use the callable form when you want the shortest version. `Begin()` and `End()` are the manual form when you need to span a larger block.

## LockValue
`LockValue` is for a value that should stop being writable after setup. It disconnects the reactive backend and makes later writes error.

```lua
local Seam = require(game:GetService("ReplicatedFirst").Seam)

local LockValue = Seam.LockValue
local LayoutMode = Seam.Value("Compact")

-- Set the configuration once.
LayoutMode.Value = "Compact"

-- Freeze it after initialization.
LockValue(LayoutMode)
```

This is useful for configuration values that should not drift after startup.

## Inspect
`Inspect` is best thought of as a temporary trace hook. It does not change the state or make it reactive on its own. It only watches the state and prints when the value changes, which makes it easier to debug reactive behavior without adding custom print logic everywhere.

```lua
local Seam = require(game:GetService("ReplicatedFirst").Seam)

local Value = Seam.Value
local Inspect = Seam.Inspect

local Counter = Value(0)

Inspect(Counter, "Counter")

Counter.Value = 1
Counter.Value = 2
```

Use it while you are checking whether a state is changing too early, not changing at all, or resolving to the wrong value. When you are done debugging, remove the `Inspect` call and keep the state logic itself.

## Takeaway
The main pattern is separation of concerns:
- `StyleSheet` handles reusable presentation
- `Resource` handles async loading and lifecycle
- `OnAttached` tells you when a state is actually consumed
- `Batch` groups related state updates
- `LockValue` freezes a finalized configuration value
- `Inspect` helps you watch what the state system is doing

These features are usually more useful when they stay separate, and you combine them only where the behavior really needs it.
