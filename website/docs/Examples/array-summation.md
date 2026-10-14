---
sidebar_position: 4
---

# Array summation
This is a simple example where we have a `Computed` represent a total value between a table of numbers. This state changes whenever the table changes!

It looks like this:

```lua
local Array = Scope:Value({})

local TotalValue = Scope:Computed(function(Use)
	local Total = 0
	
	for _, Value : number in Use(Array) do
		Total += Value
	end
	
	return Total
end)

print(TotalValue.Value) -- 0

Array.Value = {1, 2, 3}

print(TotalValue.Value) -- 6

Array.Value = {5, 5}

print(TotalValue.Value) -- 10

Array.Value = {2.5, 3.5, 7, 11}

print(TotalValue.Value) -- 25
```