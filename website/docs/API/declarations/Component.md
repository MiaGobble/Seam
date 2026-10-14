---
sidebar_position: 3
---

# Component
Turns a module table into a Seam component usable with `New`.

|Type|Since|Scoped|
|----|-----|------|
|Declaration|0.3.0|No|

## Constructor
```lua
Component(Module : {
	Init : (self, Scope : Scope?, Properties : {[string] : any}) -> (),
	Construct : (self, Scope : Scope?, Properties : {[string] : any}) -> any,
	...
}) -> Component
```

`Init` and `Construct` are required.

## Usage
```lua
local ButtonComponent = {}

function ButtonComponent:Init(Scope, Properties)
	self.Clicks = 0
end

function ButtonComponent:Construct(Scope, Properties)
	return Scope:New("TextButton", {
		Text = Properties.Text,

		[OnEvent "Activated"] = function()
			self:Click()
		end,
	})
end

function ButtonComponent:Click()
	self.Clicks += 1
end

return Component(ButtonComponent)
```

Use the returned component with `New`:

```lua
local Button = require(Path.To.ButtonComponent)

New(Button, {
	Text = "Save",
})
```

When created through `Scope:New`, that scope is passed as the first argument to `Init` and `Construct`. When created with global `New`, `Scope` may be `nil` — design components accordingly, or always construct them through a scope.
