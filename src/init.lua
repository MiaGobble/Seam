--[=[
    The main framework module for Sphi.
    @class Sphi
]=]

local Sphi = {}

-- Variables
local Components = script.Components

--[=[
    @prop New New
    @within Sphi
]=]

Sphi.New = require(Components.New)
Sphi.new = Sphi.New

--[=[
    @prop Children Children
    @within Sphi
]=]

Sphi.Children = require(Components.Children)
Sphi.children = Sphi.Children

--[=[
    @prop Value Value
    @within Sphi
]=]

Sphi.Value = require(Components.Value)
Sphi.value = Sphi.Value

--[=[
    @prop Computed Computed
    @within Sphi
]=]

Sphi.Computed = require(Components.Computed)
Sphi.computed = Sphi.Computed

--[=[
    @prop Spring Spring
    @within Sphi
]=]

Sphi.Spring = require(Components.Animation.Spring)
Sphi.spring = Sphi.Spring

return Sphi