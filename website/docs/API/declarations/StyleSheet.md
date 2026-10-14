---
sidebar_position: 8
---

# StyleSheet
A reversible declaration for applying style rules to instances and descendants.

|Type|Since|Scoped|
|----|-----|------|
|Declaration|v1.0.0|No|

## Constructors
```lua
StyleSheet.new() -> StyleSheetInstance
StyleSheet.group(Stylesheets : {[any]: StyleSheetInstance}) -> StyleSheetGroup
```

## Callable Form
```lua
[StyleSheet] = StyleSheetInstance | { { Selector : string, Properties : {[any] : any} }, ... }
[StyleSheetGroup] = Key
```

## Methods (`StyleSheetInstance`)
#### `Style(Selector : string)(Properties : {[any] : any})`
Adds a rule. Selector forms:
- `"Frame"` — class name
- `"@Name"` — exact instance name
- `"#Tag"` — CollectionService tag
- `"$Prefix"` — name starts with prefix
- `"Suffix$"` — name ends with suffix

#### `Apply(Root : Instance)`
Applies rules to `Root` and descendants. Replaces any previously active stylesheet on that root. Auto-unapplies when the root is destroyed. Tracks newly added descendants.

#### `Unapply(Root : Instance)`
Removes the stylesheet from the root and restores tracked property values.

#### `Destroy()`
Unapplies from every root and clears rules.

## Usage
Create reusable themes and attach them during `New`:

```lua
local Theme = Seam.StyleSheet.new()

Theme:Style("Frame")({
	BackgroundColor3 = Color3.fromRGB(30, 30, 30),
	BorderSizePixel = 0,
})

Theme:Style("@Title")({
	TextColor3 = Color3.fromRGB(255, 255, 255),
})

local ScreenGui = New("ScreenGui", {
	Parent = PlayerGui,
	[Seam.StyleSheet] = Theme,
})
```

Inline rule arrays also work:

```lua
New("ScreenGui", {
	[Seam.StyleSheet] = {
		{
			Selector = "TextLabel",
			Properties = {
				TextColor3 = Color3.new(1, 1, 1),
			},
		},
	},
})
```

Groups require an explicit key — do not pass a group through `[Seam.StyleSheet]`:

```lua
local ThemeGroup = Seam.StyleSheet.group({
	Base = BaseTheme,
	Accent = AccentTheme,
})

New(ScreenGui, {
	[ThemeGroup] = "Base", -- Key must exist in the group table
})
```

Rule `Properties` may include declaration keys (`Attribute`, `Children`, etc.). `Apply` can also be called later on an existing tree; only one stylesheet is active per root at a time.
