--[=[
    Documentation: https://seam.igottic.com/

    @class Seam
]=]

-- Imports
-- Note: I opt for WaitForChild to load stuff; this helps prevent edge case errors where children don't load in time, particularly when loading from ReplicatedStorage
local RunService = game:GetService("RunService")

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
local Inspect = require(Utilities:WaitForChild("Inspect"))
local OnAttached = require(Connections:WaitForChild("OnAttached"))
local Destroyed = require(Declarations:WaitForChild("Destroyed"))
local EventSequence = require(Declarations:WaitForChild("EventSequence"))

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
    Inspect : Inspect.Inspect,
    inspect : Inspect.Inspect,
    OnAttached : OnAttached.OnAttached,
    onAttached : OnAttached.OnAttached,
    Destroyed : Destroyed.Destroyed,
    destroyed : Destroyed.Destroyed,
    EventSequence : EventSequence.EventSequence,
    eventSequence : EventSequence.EventSequence
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
export type Inspect = Inspect.Inspect
export type OnAttached = OnAttached.OnAttached
export type Destroyed = Destroyed.Destroyed
export type EventSequence = EventSequence.EventSequence

export type BaseState<T> = Types.BaseState<T>
export type Child = Types.Child

-- Declaration
local Seam : Seam = {} :: Seam

local function Init()
    if RunService:IsServer() then
        return -- Don't wait on server
    end

    if not game:IsLoaded() then
        game.Loaded:Wait()

        -- There is this weird bug where, when loaded from ReplicatedFirst, the framework loads *too* fast and animations don't work on the frontend.
        -- This is a hacky workaround for this while I figure out a better solution.
    end
end

--[=[
    @method New
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.New = New
Seam.new = New

--[=[
    @method Children
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.Children = Children
Seam.children = Children

--[=[
    @method Value
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.Value = Value
Seam.value = Value

--[=[
    @method Computed
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.Computed = Computed
Seam.computed = Computed

--[=[
    @method Spring
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.Spring = Spring
Seam.spring = Spring

--[=[
    @method Tween
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.Tween = Tween
Seam.tween = Tween

--[=[
    @method Scope
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.Scope = Scope
Seam.scope = Scope

--[=[
    @method OnEvent
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.OnEvent = OnEvent
Seam.onEvent = OnEvent

--[=[
    @method OnChange
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.OnChanged = OnChanged
Seam.onChanged = OnChanged

--[=[
    @method Attribute
    @within Seam
]=]
Seam.Attribute = Attribute
Seam.attribute = Attribute

--[=[
    @method OnAttributeChanged
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]
Seam.OnAttributeChanged = OnAttributeChanged
Seam.onAttributeChanged = OnAttributeChanged

--[=[
    @method Lifetime
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.Lifetime = Lifetime
Seam.lifetime = Lifetime

--[=[
    @method Rendered
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.Rendered = Rendered
Seam.rendered = Rendered

--[=[
    @method FollowProperty
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.FollowProperty = FollowProperty
Seam.followProperty = FollowProperty

--[=[
    @method FollowAttribute
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.FollowAttribute = FollowAttribute
Seam.followAttribute = FollowAttribute

--[=[
    @method GetValue
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.GetValue = GetValue
Seam.getValue = GetValue

--[=[
    @method Component
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.Component = Component
Seam.component = Component

--[=[
    @method Tags
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.Tags = Tags
Seam.tags = Tags

--[=[
    @method SetValue
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.SetValue = SetValue
Seam.setValue = SetValue

--[=[
    @method IsState
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.IsState = IsState
Seam.isState = IsState

--[=[
    @method IsComponent
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.IsComponent = IsComponent
Seam.isComponent = IsComponent

--[=[
    @method LockValue
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.LockValue = LockValue
Seam.lockValue = LockValue

--[=[
    @method Inspect
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.Inspect = Inspect
Seam.inspect = Inspect

--[=[
    @method OnAttached
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.OnAttached = OnAttached
Seam.onAttached = OnAttached

--[=[
    @method Destroyed
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.Destroyed = Destroyed
Seam.destroyed = Destroyed

--[=[
    @method EventSequence
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.EventSequence = EventSequence
Seam.eventSequence = EventSequence

Init()

return Seam :: Seam

-- DEV NOTES --

--[[
    I made this framework to be as simple as possible behind the scenes, so ideally it should be easy to understand when compared to other frameworks.
    I'm also trying to integrate this into new and experimental projects of mine to give it a spin, so along the way I'll add features that I think are useful to me.

    If you feel something needs more documentation, please let me know! Find current documentation at https://www.seaminterface.com/
--]]