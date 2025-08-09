--[=[
    The main framework module for Seam.

    NOT READY FOR PRODUCTION USE. USE WITH CAUTION.

    Some credits for internal modules:
    - iGottic (creator of this framework)
    - Elttob (UnpackType, PackType, Janitor)
    - Validark, pobammer, codesenseAye (Janitor)
    - bottosson (Oklab color space)

    @class Seam
    @author iGottic
]=]

local Seam = {}

-- Imports
local Constructors = script.Constructors
local Modules = script.Modules
local InitPresetComponents = require(Modules.InitPresetComponents)

local function Init()
    if not game:IsLoaded() then
        game.Loaded:Wait()

        -- There is this weird bug where, when loaded from ReplicatedFirst, the framework loads *too* fast and animations don't work on the frontend.
        -- This is a hacky workaround for this while I figure out a better solution.
    end

    InitPresetComponents()
end

-- Note: I opt for WaitForChild to load stuff; this helps prevent edge case errors where children don't load in time, particularly when loading from ReplicatedStorage

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

--[=[
    @prop Attribute Attribute
    @within Seam
]=]
Seam.Attribute = require(Constructors.Attribute)
Seam.attribute = Seam.Attribute

--[=[
    @prop OnAttributeChanged OnAttributeChanged
    @within Seam
]=]
Seam.OnAttributeChanged = require(Constructors.OnAttributeChanged)
Seam.onAttributeChanged = Seam.OnAttributeChanged

--[=[
    @prop Lifetime Lifetime
    @within Seam
]=]

Seam.Lifetime = require(Constructors.Lifetime)
Seam.lifetime = Seam.Lifetime

--[=[
    @prop Rendered Rendered
    @within Seam
]=]

Seam.Rendered = require(Constructors.Rendered)
Seam.rendered = Seam.Rendered

--[=[
    @prop FollowProperty FollowProperty
    @within Seam
]=]

Seam.FollowProperty = require(Constructors.FollowProperty)
Seam.followProperty = Seam.FollowProperty

--[=[
    @prop FollowAttribute FollowAttribute
    @within Seam
]=]

Seam.FollowAttribute = require(Constructors.FollowAttribute)
Seam.followAttribute = Seam.FollowAttribute

return Seam, Init() -- Weird syntax? Yeah.

-- DEV NOTES --

--[[
    I made this framework to be as simple as possible behind the scenes, so ideally it should be easy to understand when compared to other frameworks.
    I'm also trying to integrate this into new and experimental projects of mine to give it a spin, so along the way I'll add features that I think are useful to me.

    If you feel something needs more documentation, please let me know!
--]]