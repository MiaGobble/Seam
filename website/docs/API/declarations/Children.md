---
sidebar_position: 2
---

# Children
Declares children of an instance when paired with `New`.

|Type|Since|Scoped|
|----|-----|------|
|Declaration|0.0.1|No|

## Constructor
```lua
[Children] = Instance | {Instance} | Computed
```

## Usage
```lua
New("Frame", {
	[Children] = {
		New("TextLabel", {
			Text = "Hello",
		}),
	},
})
```

A single child can be passed without wrapping it in a table:

```lua
New("Frame", {
	[Children] = New("UICorner", {}),
})
```

Numeric keys in `New`'s property table are treated as implicit children with the same behavior:

```lua
New("Frame", {
	Size = UDim2.fromScale(1, 1),

	New("TextLabel", {
		Text = "Hello",
	}),
})
```

### Reactive children

Pass a `Computed` that returns a table of instances. When the computed updates, removed children are destroyed and new ones are parented. Cleanup also runs when the parent is destroyed.

```lua
local Names = Value({"Bob", "Rob", "Billy"})

New(ExistingFrame, {
	[Children] = Computed(function(Use)
		local Labels = {}

		for _, Name in Use(Names) do
			table.insert(Labels, New("TextLabel", {
				Text = Name,
			}))
		end

		return Labels
	end),
})

Names.Value = {"Jon"} -- Old labels destroyed; one new label created
```

Only `Computed` instances are treated as reactive children (not arbitrary states). Prefer `ForPairs` when mapping keyed collections, then wrap or compose as needed for child tables.
