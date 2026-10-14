---
sidebar_position: 3
---

# Using states and connections
The heart of Seam is designed around reactive states. States take an input, and extract an output. The most basic form of a state in Seam is `Value`. A value does one thing: hold a value.

Here is an example of a value in action:

```lua
local Seam = require(ReplicatedFirst.Seam)
local Value = Seam.Value

local MyValue = Value("Kiwi")

task.wait(1)

MyValue.Value = "Orange"
```

`MyValue` is initialized with the value "Kiwi", and it will remain that way until it's manually changed. This means if you were to print `MyValue.Value`, you would get "Kiwi". In the example code, we wait one second and change it to "Orange". Once changed, it remains that way until changed again, meaning that reading it until then will give you "Orange".

You can connect to these changes by using `OnChanged` from Seam. This means you can have a basic reaction -- changing `MyValue` will do something!

We can use the same example as above, but now introduce `OnChanged`:

```lua
local Seam = require(ReplicatedFirst.Seam)
local Value = Seam.Value
local OnChanged = Seam.OnChanged

local MyValue = Value("Kiwi")

OnChanged(MyValue, function(PropertyChanged : string, NewValue : string)
	print(`My value changed! It's now: {NewValue}`)
end)

task.wait(1)

MyValue.Value = "Orange"
```

`OnChanged` takes two parameters: the value being tracked (`MyValue`, in this case), and the function to be called back when reacting (and that will always give you the name of the property that changed, and the new value). When using it in this example, we print "My value changed, it's now xyz", where *xyz* is whatever the value is. In this case, it will print "My value changed! It's now Orange". It won't print Kiwi because it was connected *after* the value was created.

`OnChanged` isn't a state, rather a connection. But what if we wanted one state to react to another? Say hi to `Computed`, a state that takes one or more other states and spits out one resulting value.

Creating a computed value works like this:

```lua
local Bar = Value("abc")
local Where = Value("xyz")

local MyComputed = Computed(function(Use)
    local Foo = Use(Bar)
    local What = Use(Where)

    return Foo .. What -- Concatenate the two
end)

print(MyComputed.Value) -- Prints "abcxyz"

Where.Value = "lmnop"

print(MyComputed.Value) -- Prints "abclmnop"
```

When creating a computed state, you input a function, which has a `Use` parameter (and that is a function). That function returns a resulting value.

Think of `Use` as a declaration of you're, well, using. In the above example, we want to react to `Bar` and `Where`, and produce a new value that concatenates the two. So for example, we can have `Bar` be a value that is equal to `"abcd"`, and have `Where` be `"wxyz"`.

Calling `Use` on a state will return the value of that state, so `Foo` is `Bar`'s value, and `What` is `Where`'s value.

So, as a result, by doing `return Foo .. What`, we are returning `"abcd" .. "wxyz"`. This means that if you were to read `MyComputed.Value`, you would get `"abcdwxyz"`.

`OnChanged` also works on computed states, so let's do that in the context of our initial example:

```lua
local Seam = require(ReplicatedFirst.Seam)
local Value = Seam.Value
local OnChanged = Seam.OnChanged
local Computed = Seam.Computed

local MyValue = Value("Kiwi")

local MyComputed = Computed(function(Use)
	local CurrentValue = Use(MyValue)
	
	return `The current value is: {CurrentValue}`
end)

OnChanged(MyComputed, function(PropertyChanged : string, NewValue : string)
	print(NewValue)
end)

task.wait(1)

print("changed")
MyValue.Value = "Orange"
```

In this case, we are taking `MyValue.Value` and turning it into a final string to be printed, which is printed from `OnChanged`. This means that the initial value of `MyComputed` is "The current value is Kiwi" (which is not printed), and the new value is "The current value is Orange" (which is printed).

It works with any data type, including numbers, like this for example:

```lua
local Seam = require(ReplicatedFirst.Seam)
local Value = Seam.Value
local OnChanged = Seam.OnChanged
local Computed = Seam.Computed

local MyValue = Value(0)

local MyComputed = Computed(function(Use)
	local CurrentValue = Use(MyValue)
	
	return `Current value: {CurrentValue}`
end)

OnChanged(MyComputed, function(PropertyChanged : string, NewValue : string)
	print(NewValue)
end)

task.wait(1)

MyValue.Value = 1
```

But what if we didn't want to just set a value, and instead wanted to animate it with a tween or spring? In this case, we can use `Tween` or `Spring` states, respectively.

Both animation states are super simple to use. If we, in this example, represent `MyValue` as a static value that is only what you set it to (0 or 1 in this case), then we can have a tween state be the animated version of it, like this:

```lua
local TweenedValue = Tween(MyValue, TweenInfo.new(1, Enum.EasingStyle.Linear))
```

You don't need to keep calling `Tween` to keep animating it; it will automatically animate any changes to `MyValue` when `MyValue` is changed. You can read this animated value at any time like any other state, such as checking `TweenedValue.Value` for example.

We can implment this into our previous example, and call `Use` in a computed value to instead react to the animated value:

```lua
local Seam = require(ReplicatedFirst.Seam)
local Value = Seam.Value
local OnChanged = Seam.OnChanged
local Computed = Seam.Computed
local Tween = Seam.Tween

local MyValue = Value(0)

local TweenedValue = Tween(MyValue, TweenInfo.new(1, Enum.EasingStyle.Linear))

local MyComputed = Computed(function(Use)
	local CurrentValue = Use(TweenedValue)

	return `Current value: {CurrentValue}`
end)

OnChanged(MyComputed, function(PropertyChanged : string, NewValue : string)
	print(NewValue)
end)

task.wait(1)

MyValue.Value = 1
```

It works exactly the same way for `Spring`, which is a different animation type. Here is example using `Spring` as the animator:

```lua
local Seam = require(ReplicatedFirst.Seam)
local Value = Seam.Value
local OnChanged = Seam.OnChanged
local Computed = Seam.Computed
local Spring = Seam.Spring

local MyValue = Value(0)

local SpringedValue = Spring(MyValue, 30, 1) -- 30 speed, 1 dampening

local MyComputed = Computed(function(Use)
	local CurrentValue = Use(SpringedValue)

	return `Current value: {CurrentValue}`
end)

OnChanged(MyComputed, function(PropertyChanged : string, NewValue : string)
	print(NewValue)
end)

task.wait(1)

MyValue.Value = 1
```

You can read more about the specifics of animation states in their respective documentation pages.

That's the basics of states and connections! Use this knowledge when reading the next page about using declarations.