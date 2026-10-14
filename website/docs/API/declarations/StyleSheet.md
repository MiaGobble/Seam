---
sidebar_position: 8
---

# StyleSheet
A reversible declaration for applying style rules to instances and descendants.

`StyleSheet` gives Seam a native way to describe visual rules separately from instance creation. You define selectors, assign properties to each selector, and then pass the stylesheet into `New` with `[Seam.StyleSheet] = Theme` when the tree is being created. Seam applies the rules while building the instance tree and restores the original property values later if the stylesheet is unapplied.

|Type|Since|Scoped|
|----|-----|------|
|Declaration|v1.0.0|No|

## Constructors
```lua
StyleSheet.new() -> StyleSheetInstance
StyleSheet.group(Stylesheets : {[any]: StyleSheetInstance}) -> StyleSheetGroup
```

## Methods
#### `Style(selector : string)(properties : {[any] : any})`
Adds a style rule to the stylesheet. The selector decides which instances match, and the properties table defines what gets changed on each match.

#### `Apply(root : Instance)`
Applies the stylesheet to the given instance tree. Existing matching instances are updated immediately, and descendants added later are also tracked.

#### `Unapply(root : Instance)`
Removes the stylesheet from the given instance tree and restores tracked values to what they were before the stylesheet touched them.

#### `Destroy()`
Releases the stylesheet and any tracked connections.

## Usage
Create a stylesheet when you want a reusable set of visual rules that can be applied as part of `New`.

```lua
-- Create a stylesheet object that can store multiple selector rules.
local Theme = Seam.StyleSheet.new()

-- Match every Frame in the tree and apply shared base styling.
Theme:Style("Frame")({
	BackgroundColor3 = Color3.fromRGB(30, 30, 30), -- Dark background for all frames.
	BorderSizePixel = 0, -- Remove the default border.
})

-- Match a specific instance name and override just that target.
Theme:Style("@Title")({
	TextColor3 = Color3.fromRGB(255, 255, 255), -- Make the title readable on the dark theme.
})

-- Apply the stylesheet during construction.
local ScreenGui = New("ScreenGui", {
	Parent = PlayerGui,
	[Seam.StyleSheet] = Theme,
})
```

Use `Seam.StyleSheet.group(...)` when you want several stylesheets to behave like one declaration target inside `New`.

```lua
-- Create two separate stylesheets for different concerns.
local BaseTheme = Seam.StyleSheet.new()
local AccentTheme = Seam.StyleSheet.new()

-- Group them so one declaration key can reference both.
local ThemeGroup = Seam.StyleSheet.group({
	Base = BaseTheme,
	Accent = AccentTheme,
})

New(ScreenGui, {
	-- Attach the grouped stylesheets using a single declaration key.
	[ThemeGroup] = "Base",
})
```

`Theme:Apply(root)` still exists for applying a stylesheet after the fact, especially when the root instance tree already exists. `Unapply(root)` removes it again and restores the previous values.

`StyleSheet` selectors match against instances using these forms:
- `"Frame"` matches by class name
- `"@Name"` matches an exact instance name
- `"#Tag"` matches a CollectionService tag
- `"$Prefix"` matches names that start with the prefix
- `"Suffix$"` matches names that end with the suffix

`StyleSheet` tracks original property values and restores them on unapply. It also watches descendants added or removed while it is applied, and it invokes declaration keys inside `Properties` when a key exposes `__SEAM_INDEX`.