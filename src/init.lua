--[=[
    The main framework module for Seam.
    @class Seam
]=]

local Seam = {}

-- Variables
local Components = script.Components

--[=[
    @prop New New
    @within Seam
]=]

Seam.New = require(Components.New)
Seam.new = Seam.New

--[=[
    @prop Children Children
    @within Seam
]=]

Seam.Children = require(Components.Children)
Seam.children = Seam.Children

--[=[
    @prop Value Value
    @within Seam
]=]

Seam.Value = require(Components.Value)
Seam.value = Seam.Value

--[=[
    @prop Computed Computed
    @within Seam
]=]

Seam.Computed = require(Components.Computed)
Seam.computed = Seam.Computed

--[=[
    @prop Spring Spring
    @within Seam
]=]

Seam.Spring = require(Components.Animation.Spring)
Seam.spring = Seam.Spring

--[=[
    @prop Tween Tween
    @within Seam
]=]

Seam.Tween = require(Components.Animation.Tween)
Seam.tween = Seam.Tween

--[=[
    @prop Scope Scope
    @within Seam
]=]

Seam.Scope = require(Components.Scope)
Seam.scope = Seam.Scope

--[=[
    @prop OnEvent OnEvent
    @within Seam
]=]

Seam.OnEvent = require(Components.OnEvent)
Seam.onEvent = Seam.OnEvent

--[=[
    @prop OnChange OnChanged
    @within Seam
]=]

Seam.OnChanged = require(Components.OnChanged)
Seam.onChanged = Seam.OnChanged

--[=[
    @prop DeclareComponent DeclareComponent
    @within Seam
]=]

Seam.DeclareComponent = require(Components.DeclareComponent)
Seam.declareComponent = Seam.DeclareComponent

--[=[
    @prop From From
    @within Seam
]=]

Seam.From = require(Components.From)
Seam.from = Seam.From

return Seam