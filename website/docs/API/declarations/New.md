---
sidebar_position: 1
---

# New
Constructs a Roblox instance, hydrates an existing one, or builds a Seam component.

|Type|Since|Scoped|
|----|-----|------|
|Declaration|0.0.1|Yes|

## Constructor
```lua
New(
	Class : string | Instance | Component,
	Properties : {[any] : any},
	Scope : Scope? -- Passed automatically by Scope:New
) -> Instance | any
```

## Usage
`New` is Seam's instance constructor. It can create instances, hydrate existing ones, or invoke components.

### Create or hydrate

```lua
local Frame = New("Frame", {
	Size = UDim2.fromScale(0.5, 0.5),
})

local Existing = Gui:FindFirstChild("Frame")

New(Existing, {
	Size = UDim2.fromScale(0.5, 0.5),
})
```

### Property table rules

| Key / value shape | Behavior |
|-------------------|----------|
| String key + plain value | Assigns `instance[key] = value` |
| String key + Seam state | Binds the state to that property (Value, Computed, Spring, etc.) |
| Table key with `__SEAM_INDEX` | Runs a declaration such as `Children`, `Attribute`, `OnEvent`, `StyleSheet`, `Lifetime` |
| Numeric key | Treated as an implicit child (`Children`) |

```lua
New("TextButton", {
	-- Plain assignment
	Text = "Click",

	-- State binding
	BackgroundColor3 = Spring(HoverColor, 25, 1),

	-- Declaration
	[Attribute "Id"] = "Primary",
	[OnEvent "Activated"] = function()
		print("clicked")
	end,

	-- Implicit child
	New("UICorner", {
		CornerRadius = UDim.new(0, 8),
	}),
})
```

### Components

If the first argument is a component (from `Component(...)`), `New` calls it with the optional scope and the properties table:

```lua
local Button = require(Path.To.ButtonComponent)

New(Button, {
	Text = "Save",
})
```

When created through `Scope:New`, that scope is passed into the component's `Init` / `Construct` methods.

### Scoped usage

```lua
local MyScope = Scope(Seam)

local Gui = MyScope:New("ScreenGui", {
	Parent = PlayerGui,
})
```

Anything returned from `Scope:New` is registered on the scope for cleanup.
