--[=[
    Documentation: https://www.seaminterface.com/

    The main framework module for Seam.

    Some credits for internal modules:
    - iGottic (creator of this framework)
    - Elttob (UnpackType, PackType)
    - Validark, pobammer, codesenseAye (Janitor)
    - bottosson (Oklab color space)

    @class Seam
    @author iGottic
]=]

-- Imports
-- Note: I opt for WaitForChild to load stuff; this helps prevent edge case errors where children don't load in time, particularly when loading from ReplicatedStorage
local Constructors = script:WaitForChild("Constructors")
local Modules = script:WaitForChild("Modules")
local Types = require(Modules:WaitForChild("Types"))

local New = require(Constructors:WaitForChild("New"))
local Children = require(Constructors:WaitForChild("Children"))
local Value = require(Constructors:WaitForChild("Value"))
local Computed = require(Constructors:WaitForChild("Computed"))
local Spring = require(Constructors.Animation:WaitForChild("Spring"))
local Tween = require(Constructors.Animation:WaitForChild("Tween"))
local Scope = require(Constructors:WaitForChild("Scope"))
local OnEvent = require(Constructors:WaitForChild("OnEvent"))
local OnChanged = require(Constructors:WaitForChild("OnChanged"))
local Attribute = require(Constructors:WaitForChild("Attribute"))
local OnAttributeChanged = require(Constructors:WaitForChild("OnAttributeChanged"))
local Lifetime = require(Constructors:WaitForChild("Lifetime"))
local Rendered = require(Constructors:WaitForChild("Rendered"))
local FollowProperty = require(Constructors:WaitForChild("FollowProperty"))
local FollowAttribute = require(Constructors:WaitForChild("FollowAttribute"))
local GetValue = require(Constructors:WaitForChild("GetValue"))
local Component = require(Constructors:WaitForChild("Component"))

-- Types extended (private)
type Seam = {
    New : New.NewConstructor,
    new : New.NewConstructor,
    Children : Children.Children,
    children : Children.Children,
    Value : Value.ValueConstructor<any>,
    value : Value.ValueConstructor<any>,
    Computed : Computed.ComputedConstructor<any>,
    computed : Computed.ComputedConstructor<any>,
    Spring : Spring.SpringConstructor<any>,
    spring : Spring.SpringConstructor<any>,
    Tween : Tween.TweenConstructor<any>,
    tween : Tween.TweenConstructor<any>,
    Scope : Scope.ScopeConstructor,
    scope : Scope.ScopeConstructor,
    OnEvent : OnEvent.OnEvent,
    onEvent : OnEvent.OnEvent,
    OnChanged : OnChanged.OnChanged,
    onChanged : OnChanged.OnChanged,
    Attribute : Attribute.Attribute,
    attribute : Attribute.Attribute,
    OnAttributeChanged : OnAttributeChanged.OnAttributeChanged,
    onAttributeChanged : OnAttributeChanged.OnAttributeChanged,
    Lifetime : Lifetime.Lifetime,
    lifetime : Lifetime.Lifetime,
    Rendered : Rendered.RenderedConstructor<any>,
    rendered : Rendered.RenderedConstructor<any>,
    FollowProperty : FollowProperty.FollowProperty,
    followProperty : FollowProperty.FollowProperty,
    FollowAttribute : FollowAttribute.FollowAttribute,
    followAttribute : FollowAttribute.FollowAttribute,
    GetValue : GetValue.GetValue,
    getValue : GetValue.GetValue,
    Component : Component.Component,
    component : Component.Component,
}

-- Types exported (public)
export type NewConstructor = New.NewConstructor
export type Children = Children.Children
export type Value<T> = Value.ValueInstance<T>
export type ValueConstructor<T> = Value.ValueConstructor<T>
export type Computed<T> = Computed.ComputedInstance<T>
export type ComputedConstructor<T> = Computed.ComputedConstructor<T>
export type Spring<T> = Spring.SpringInstance<T>
export type SpringConstructor<T> = Spring.SpringConstructor<T>
export type Tween<T> = Tween.TweenInstance<T>
export type TweenConstructor<T> = Tween.TweenConstructor<T>
export type Scope = Scope.ScopeInstance
export type ScopeConstructor = Scope.ScopeConstructor
export type OnEvent = OnEvent.OnEvent
export type OnChanged = OnChanged.OnChanged
export type Attribute = Attribute.Attribute
export type OnAttributeChanged = OnAttributeChanged.OnAttributeChanged
export type Lifetime = Lifetime.Lifetime
export type Rendered<T> = Rendered.RenderedInstance<T>
export type RenderedConstructor<T> = Rendered.RenderedConstructor<T>
export type FollowProperty = FollowProperty.FollowProperty
export type FollowAttribute = FollowAttribute.FollowAttribute
export type GetValue = GetValue.GetValue

export type BaseState<T> = Types.BaseState<T>
export type Child = Types.Child

-- Declaration
local Seam : Seam = {} :: Seam

local function Init()
    if not game:IsLoaded() then
        game.Loaded:Wait()

        -- There is this weird bug where, when loaded from ReplicatedFirst, the framework loads *too* fast and animations don't work on the frontend.
        -- This is a hacky workaround for this while I figure out a better solution.
    end
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

Seam.DeclareComponent = function()
    error("DeclareComponent has been removed in favor of the new component system. See documentation for more details.")
end

Seam.declareComponent = Seam.DeclareComponent

--[=[
    @prop From From
    @within Seam
]=]

Seam.From = function()
    error("From has been removed in favor of the new component system. See documentation for more details.")
end

Seam.from = Seam.From

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

--[=[
    @prop GetValue GetValue
    @within Seam
]=]

Seam.GetValue = GetValue
Seam.getValue = GetValue

--[=[
    @prop Component Component
    @within Seam
]=]

Seam.Component = Component
Seam.component = Component

Init()

return Seam :: Seam

-- DEV NOTES --

--[[
    I made this framework to be as simple as possible behind the scenes, so ideally it should be easy to understand when compared to other frameworks.
    I'm also trying to integrate this into new and experimental projects of mine to give it a spin, so along the way I'll add features that I think are useful to me.

    If you feel something needs more documentation, please let me know! Find current documentation at https://www.seaminterface.com/
--]]