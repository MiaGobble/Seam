--[=[
    The main framework module for Seam.
    @class Seam
]=]

local Seam = {}

-- Imports
local Constructors = script.Constructors
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

Seam.New = require(Constructors:WaitForChild("New"))
Seam.new = Seam.New

--[=[
    @prop Children Children
    @within Seam
]=]

Seam.Children = require(Constructors:WaitForChild("Children"))
Seam.children = Seam.Children

--[=[
    @prop Value Value
    @within Seam
]=]

Seam.Value = require(Constructors:WaitForChild("Value"))
Seam.value = Seam.Value

--[=[
    @prop Computed Computed
    @within Seam
]=]

Seam.Computed = require(Constructors:WaitForChild("Computed"))
Seam.computed = Seam.Computed

--[=[
    @prop Spring Spring
    @within Seam
]=]

Seam.Spring = require(Constructors.Animation:WaitForChild("Spring"))
Seam.spring = Seam.Spring

--[=[
    @prop Tween Tween
    @within Seam
]=]

Seam.Tween = require(Constructors.Animation:WaitForChild("Tween"))
Seam.tween = Seam.Tween

--[=[
    @prop Scope Scope
    @within Seam
]=]

Seam.Scope = require(Constructors.Scope)
Seam.scope = Seam.Scope

--[=[
    @prop OnEvent OnEvent
    @within Seam
]=]

Seam.OnEvent = require(Constructors.OnEvent)
Seam.onEvent = Seam.OnEvent

--[=[
    @prop OnChange OnChanged
    @within Seam
]=]

Seam.OnChanged = require(Constructors.OnChanged)
Seam.onChanged = Seam.OnChanged

--[=[
    @prop DeclareComponent DeclareComponent
    @within Seam
]=]

Seam.DeclareComponent = require(Constructors.DeclareComponent)
Seam.declareComponent = Seam.DeclareComponent

--[=[
    @prop From From
    @within Seam
]=]

Seam.From = require(Constructors.From)
Seam.from = Seam.From

return Seam, Init()