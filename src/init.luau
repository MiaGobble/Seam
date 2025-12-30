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
local Connections = Constructors:WaitForChild("Connections")
local Declarations = Constructors:WaitForChild("Declarations")
local Memory = Constructors:WaitForChild("Memory")
local States = Constructors:WaitForChild("States")
local Utilities = Constructors:WaitForChild("Utilities")
local Modules = script:WaitForChild("Modules")
local Types = require(Modules:WaitForChild("Types"))

local New = require(Declarations:WaitForChild("New"))
local Children = require(Declarations:WaitForChild("Children"))
local Value = require(States:WaitForChild("Value"))
local Computed = require(States:WaitForChild("Computed"))
local Spring = require(States.Animation:WaitForChild("Spring"))
local Tween = require(States.Animation:WaitForChild("Tween"))
local Scope = require(Memory:WaitForChild("Scope"))
local OnEvent = require(Connections:WaitForChild("OnEvent"))
local OnChanged = require(Connections:WaitForChild("OnChanged"))
local Attribute = require(Declarations:WaitForChild("Attribute"))
local OnAttributeChanged = require(Connections:WaitForChild("OnAttributeChanged"))
local Lifetime = require(Declarations:WaitForChild("Lifetime"))
local Rendered = require(States:WaitForChild("Rendered"))
local FollowProperty = require(Declarations:WaitForChild("FollowProperty"))
local FollowAttribute = require(Declarations:WaitForChild("FollowAttribute"))
local GetValue = require(Utilities:WaitForChild("GetValue"))
local Component = require(Declarations:WaitForChild("Component"))
local Tags = require(Declarations:WaitForChild("Tags"))
local SetValue = require(Utilities:WaitForChild("SetValue"))
local IsState = require(Utilities:WaitForChild("IsState"))
local IsComponent = require(Utilities:WaitForChild("IsComponent"))
local LockValue = require(Utilities:WaitForChild("LockValue"))

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
    Tags : Tags.Tags,
    tags : Tags.Tags,
    SetValue : SetValue.SetValue,
    setValue : SetValue.SetValue,
    IsState : IsState.IsState,
    isState : IsState.IsState,
    IsComponent : IsComponent.IsComponent,
    isComponent : IsComponent.IsComponent,
    LockValue : LockValue.LockValue,
    lockValue : LockValue.LockValue,
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
export type Component = Component.Component
export type Tags = Tags.Tags
export type SetValue = SetValue.SetValue
export type IsState = IsState.IsState
export type IsComponent = IsComponent.IsComponent
export type LockValue = LockValue.LockValue

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

--[=[
    @prop Tags Tags
    @within Seam
]=]

Seam.Tags = Tags
Seam.tags = Tags

--[=[
    @prop SetValue SetValue
    @within Seam
]=]

Seam.SetValue = SetValue
Seam.setValue = SetValue

--[=[
    @prop IsState IsState
    @within Seam
]=]

Seam.IsState = IsState
Seam.isState = IsState

--[=[
    @prop IsComponent IsComponent
    @within Seam
]=]

Seam.IsComponent = IsComponent
Seam.isComponent = IsComponent

--[=[
    @prop LockValue LockValue
    @within Seam
]=]

Seam.LockValue = LockValue
Seam.lockValue = LockValue

Init()

return Seam :: Seam

-- DEV NOTES --

--[[
    I made this framework to be as simple as possible behind the scenes, so ideally it should be easy to understand when compared to other frameworks.
    I'm also trying to integrate this into new and experimental projects of mine to give it a spin, so along the way I'll add features that I think are useful to me.

    If you feel something needs more documentation, please let me know! Find current documentation at https://www.seaminterface.com/
--]]