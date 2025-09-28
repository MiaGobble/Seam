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

-- Imports
-- Note: I opt for WaitForChild to load stuff; this helps prevent edge case errors where children don't load in time, particularly when loading from ReplicatedStorage
local Constructors = script:WaitForChild("Constructors")
local Modules = script:WaitForChild("Modules")
local InitPresetComponents = require(Modules:WaitForChild("InitPresetComponents"))
local New = require(Constructors:WaitForChild("New"))
local Children = require(Constructors:WaitForChild("Children"))
local Value = require(Constructors:WaitForChild("Value"))
local Computed = require(Constructors:WaitForChild("Computed"))
local Spring = require(Constructors.Animation:WaitForChild("Spring"))
local Tween = require(Constructors.Animation:WaitForChild("Tween"))
local Scope = require(Constructors:WaitForChild("Scope"))
local OnEvent = require(Constructors:WaitForChild("OnEvent"))
local OnChanged = require(Constructors:WaitForChild("OnChanged"))
local DeclareComponent = require(Constructors:WaitForChild("DeclareComponent"))
local From = require(Constructors:WaitForChild("From"))
local Attribute = require(Constructors:WaitForChild("Attribute"))
local OnAttributeChanged = require(Constructors:WaitForChild("OnAttributeChanged"))
local Lifetime = require(Constructors:WaitForChild("Lifetime"))
local Rendered = require(Constructors:WaitForChild("Rendered"))
local FollowProperty = require(Constructors:WaitForChild("FollowProperty"))
local FollowAttribute = require(Constructors:WaitForChild("FollowAttribute"))

-- Types extended
export type Seam = {
    -- Constructor types
    New : New.NewConstructor,
    new : New.NewConstructor,
    Children : Children.Children,
    children : Children.Children,
    Value : Value.ValueConstructor,
    value : Value.ValueConstructor,
    Computed : Computed.ComputedConstructor,
    computed : Computed.ComputedConstructor,
    Spring : Spring.SpringConstructor,
    spring : Spring.SpringConstructor,
    Tween : Tween.TweenConstructor,
    tween : Tween.TweenConstructor,
    Scope : Scope.ScopeConstructor,
    scope : Scope.ScopeConstructor,
    OnEvent : OnEvent.OnEvent,
    onEvent : OnEvent.OnEvent,
    OnChanged : OnChanged.OnChanged,
    onChanged : OnChanged.OnChanged,
    DeclareComponent : DeclareComponent.DeclareComponent,
    declareComponent : DeclareComponent.DeclareComponent,
    From : From.From,
    from : From.From,
    Attribute : Attribute.Attribute,
    attribute : Attribute.Attribute,
    OnAttributeChanged : OnAttributeChanged.OnAttributeChanged,
    onAttributeChanged : OnAttributeChanged.OnAttributeChanged,
    Lifetime : Lifetime.Lifetime,
    lifetime : Lifetime.Lifetime,
    Rendered : Rendered.RenderedConstructor,
    rendered : Rendered.RenderedConstructor,
    FollowProperty : FollowProperty.FollowProperty,
    followProperty : FollowProperty.FollowProperty,
    FollowAttribute : FollowAttribute.FollowAttribute,
    followAttribute : FollowAttribute.FollowAttribute,

    -- Instance types
    ValueInstance : Value.ValueInstance,
    ComputedInstance : Computed.ComputedInstance,
    SpringInstance : Spring.SpringInstance,
    TweenInstance : Tween.TweenInstance,
    ScopeInstance : Scope.ScopeInstance,
    RenderedInstance : Rendered.RenderedInstance,
}

local Seam : Seam = {} :: Seam

local function Init()
    if not game:IsLoaded() then
        game.Loaded:Wait()

        -- There is this weird bug where, when loaded from ReplicatedFirst, the framework loads *too* fast and animations don't work on the frontend.
        -- This is a hacky workaround for this while I figure out a better solution.
    end

    InitPresetComponents()
end

--[=[
    @prop New New
    @within Seam
]=]

Seam.New = New
Seam.new = New

--[=[
    @prop Children Children
    @within Seam
]=]

Seam.Children = Children
Seam.children = Children

--[=[
    @prop Value Value
    @within Seam
]=]

Seam.Value = Value
Seam.value = Value

--[=[
    @prop Computed Computed
    @within Seam
]=]

Seam.Computed = Computed
Seam.computed = Computed

--[=[
    @prop Spring Spring
    @within Seam
]=]

Seam.Spring = Spring
Seam.spring = Spring

--[=[
    @prop Tween Tween
    @within Seam
]=]

Seam.Tween = Tween
Seam.tween = Tween

--[=[
    @prop Scope Scope
    @within Seam
]=]

Seam.Scope = Scope
Seam.scope = Scope

--[=[
    @prop OnEvent OnEvent
    @within Seam
]=]

Seam.OnEvent = OnEvent
Seam.onEvent = OnEvent

--[=[
    @prop OnChange OnChanged
    @within Seam
]=]

Seam.OnChanged = OnChanged
Seam.onChanged = OnChanged

--[=[
    @prop DeclareComponent DeclareComponent
    @within Seam
]=]

Seam.DeclareComponent = DeclareComponent
Seam.declareComponent = DeclareComponent

--[=[
    @prop From From
    @within Seam
]=]

Seam.From = From
Seam.from = From

--[=[
    @prop Attribute Attribute
    @within Seam
]=]
Seam.Attribute = Attribute
Seam.attribute = Attribute

--[=[
    @prop OnAttributeChanged OnAttributeChanged
    @within Seam
]=]
Seam.OnAttributeChanged = OnAttributeChanged
Seam.onAttributeChanged = OnAttributeChanged

--[=[
    @prop Lifetime Lifetime
    @within Seam
]=]

Seam.Lifetime = Lifetime
Seam.lifetime = Lifetime

--[=[
    @prop Rendered Rendered
    @within Seam
]=]

Seam.Rendered = Rendered
Seam.rendered = Rendered

--[=[
    @prop FollowProperty FollowProperty
    @within Seam
]=]

Seam.FollowProperty = FollowProperty
Seam.followProperty = FollowProperty

--[=[
    @prop FollowAttribute FollowAttribute
    @within Seam
]=]

Seam.FollowAttribute = FollowAttribute
Seam.followAttribute = FollowAttribute

return Seam, Init() -- Weird syntax? Yeah.

-- DEV NOTES --

--[[
    I made this framework to be as simple as possible behind the scenes, so ideally it should be easy to understand when compared to other frameworks.
    I'm also trying to integrate this into new and experimental projects of mine to give it a spin, so along the way I'll add features that I think are useful to me.

    If you feel something needs more documentation, please let me know!
--]]