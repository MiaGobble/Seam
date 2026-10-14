---
sidebar_position: 2
---

# Children
Declares children of an instance when paired with `New()`

|Type|Since|Scoped|
|----|-----|------|
|Declaration|0.0.1|No|

## Constuctor
```lua
[Children] = {Instance} | Computed
```

## Usage
Children is used as in index in the `New` constructor to declare the children of said instance. It’s used like this:

```lua
local Object = New("Object", {
    Property = Value,
    Property2 = Value2,

    [Children] = {
        ... -- Array of other objects. Supports usage of New() in here as well
    }
})
```

Or alternatively, you can input a single child without a table:

```lua
local Object = New("Object", {
    Property = Value,
    Property2 = Value2,

    [Children] = ... -- Single child
})
```

You can achieve similar results by parenting all children of the instance with `Instance.Parent`, but this is quicker.

If you wanted children to be more reactive/dynamic, you can alternatively pass in a `Computed() `state. When the computed instance updates, it will update the children. For this to work, `Computed()` must return a table of instances every time.

```lua
local Names = Value({"Bob", "Rob", "Billy", "Bobby"})

local DynamicChildren = Computed(function(Use)
    local CreatedChildren = {}
    
    for Index, Name in Use(Names) do
      table.insert(CreatedChildren, New("TextLabel", {
            Text = Name,
            -- And let's pretend there are properties
      }))
    end
    
    return CreatedChildren
end)

New(ExistingFrame, {
    [Children] = DynamicChildren
})

-- At first, there will be four children, each a text label that corresponds to each value in the Names state
-- Then, we change the value, doing the same thing and deleting the old children

Names.Value = {"Jon"} -- When we call this, there will now only be a singular text label, with the text "Jon"
```

Seam also supports implicit children, meaning you can make them without the `Children` declaration. To do so, just put them directly in the properties table, like so:

```lua
local Object = New("Object", {
    -- Properties
    Property = Value,
    Property2 = Value2,

    -- Children
    New("Object", {

    }),

    New("Object", {

    }),
})
```

Implicit children have the same functionality, meaning it also supports dynamic children with states.