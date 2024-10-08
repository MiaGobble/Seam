--[=[
    The main framework module for Seam.
    @class Seam
]=]

local Seam = {}

-- Imports
local States = script.States
local Modules = script.Modules
local InitPresetComponents = require(Modules.InitPresetComponents)

local function Init()
    InitPresetComponents()
end

-- Note: I opt for WaitForChild to load stuff; this helps prevent edge case errors where children don't load in time.

--[=[
    @prop New New
    @within Seam
]=]

Seam.New = require(States:WaitForChild("New"))
Seam.new = Seam.New

--[=[
    @prop Children Children
    @within Seam
]=]

Seam.Children = require(States:WaitForChild("Children"))
Seam.children = Seam.Children

--[=[
    @prop Value Value
    @within Seam
]=]

Seam.Value = require(States:WaitForChild("Value"))
Seam.value = Seam.Value

--[=[
    @prop Computed Computed
    @within Seam
]=]

Seam.Computed = require(States:WaitForChild("Computed"))
Seam.computed = Seam.Computed

--[=[
    @prop Spring Spring
    @within Seam
]=]

Seam.Spring = require(States.Animation:WaitForChild("Spring"))
Seam.spring = Seam.Spring

--[=[
    @prop Tween Tween
    @within Seam
]=]

Seam.Tween = require(States.Animation:WaitForChild("Tween"))
Seam.tween = Seam.Tween

--[=[
    @prop Scope Scope
    @within Seam
]=]

Seam.Scope = require(States.Scope)
Seam.scope = Seam.Scope

--[=[
    @prop OnEvent OnEvent
    @within Seam
]=]

Seam.OnEvent = require(States.OnEvent)
Seam.onEvent = Seam.OnEvent

--[=[
    @prop OnChange OnChanged
    @within Seam
]=]

Seam.OnChanged = require(States.OnChanged)
Seam.onChanged = Seam.OnChanged

--[=[
    @prop DeclareComponent DeclareComponent
    @within Seam
]=]

Seam.DeclareComponent = require(States.DeclareComponent)
Seam.declareComponent = Seam.DeclareComponent

--[=[
    @prop From From
    @within Seam
]=]

Seam.From = require(States.From)
Seam.from = Seam.From

return Seam, Init()