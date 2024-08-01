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

--[=[
    @prop Tween Tween
    @within Sphi
]=]

Sphi.Tween = require(Components.Animation.Tween)
Sphi.tween = Sphi.Tween

--[=[
    @prop Scope Scope
    @within Sphi
]=]

Sphi.Scope = require(Components.Scope)
Sphi.scope = Sphi.Scope

--[=[
    @prop OnEvent OnEvent
    @within Sphi
]=]

Sphi.OnEvent = require(Components.OnEvent)
Sphi.onEvent = Sphi.OnEvent

--[=[
    @prop OnChange OnChanged
    @within Sphi
]=]

Sphi.OnChanged = require(Components.OnChanged)
Sphi.onChanged = Sphi.OnChanged

--[=[
    @prop DeclareComponent DeclareComponent
    @within Sphi
]=]

Sphi.DeclareComponent = require(Components.DeclareComponent)
Sphi.declareComponent = Sphi.DeclareComponent

--[=[
    @prop From From
    @within Sphi
]=]

Sphi.From = require(Components.From)
Sphi.from = Sphi.From

return Sphi