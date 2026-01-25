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
    Children : Children.Children,
    Value : Value.ValueConstructor<any>,
    Computed : Computed.ComputedConstructor<any>,
    Spring : Spring.SpringConstructor<any>,
    Tween : Tween.TweenConstructor<any>,
    Scope : Scope.ScopeConstructor,
    OnEvent : OnEvent.OnEvent,
    OnChanged : OnChanged.OnChanged,
    Attribute : Attribute.Attribute,
    OnAttributeChanged : OnAttributeChanged.OnAttributeChanged,
    Lifetime : Lifetime.Lifetime,
    Rendered : Rendered.RenderedConstructor<any>,
    FollowProperty : FollowProperty.FollowProperty,
    FollowAttribute : FollowAttribute.FollowAttribute,
    GetValue : GetValue.GetValue,
    Component : Component.Component,
    Tags : Tags.Tags,
    SetValue : SetValue.SetValue,
    IsState : IsState.IsState,
    IsComponent : IsComponent.IsComponent,
    LockValue : LockValue.LockValue,
    Inspect : Inspect.Inspect,
    OnAttached : OnAttached.OnAttached,
    Destroyed : Destroyed.Destroyed,
    EventSequence : EventSequence.EventSequence,
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

local function GetWrappedWarningCallback(Index : string, Constructor : () -> any?)
    return function(...)
        warn(`Seam.{Index} will soon only be available in PascalCase format. All camelCase variants will be removed in a future version`)
        return Constructor(...)
    end
end

local function Init()
    for Index : string, Constructor : () -> any? in Seam do
        local LowercaseName = Index:lower()
        Seam[LowercaseName] = GetWrappedWarningCallback(LowercaseName, Constructor)
    end

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

--[=[
    @method Children
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.Children = Children

--[=[
    @method Value
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.Value = Value

--[=[
    @method Computed
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.Computed = Computed

--[=[
    @method Spring
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.Spring = Spring

--[=[
    @method Tween
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.Tween = Tween

--[=[
    @method Scope
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.Scope = Scope

--[=[
    @method OnEvent
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.OnEvent = OnEvent

--[=[
    @method OnChange
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.OnChanged = OnChanged

--[=[
    @method Attribute
    @within Seam
]=]

Seam.Attribute = Attribute

--[=[
    @method OnAttributeChanged
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.OnAttributeChanged = OnAttributeChanged

--[=[
    @method Lifetime
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.Lifetime = Lifetime

--[=[
    @method Rendered
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.Rendered = Rendered

--[=[
    @method FollowProperty
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.FollowProperty = FollowProperty

--[=[
    @method FollowAttribute
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.FollowAttribute = FollowAttribute

--[=[
    @method GetValue
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.GetValue = GetValue

--[=[
    @method Component
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.Component = Component

--[=[
    @method Tags
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.Tags = Tags

--[=[
    @method SetValue
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.SetValue = SetValue

--[=[
    @method IsState
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.IsState = IsState

--[=[
    @method IsComponent
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.IsComponent = IsComponent

--[=[
    @method LockValue
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.LockValue = LockValue

--[=[
    @method Inspect
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.Inspect = Inspect

--[=[
    @method OnAttached
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.OnAttached = OnAttached

--[=[
    @method Destroyed
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.Destroyed = Destroyed

--[=[
    @method EventSequence
    @within Seam

    Visit https://seam.igottic.com/ for more info.
]=]

Seam.EventSequence = EventSequence

Init()

return Seam :: Seam

-- DEV NOTES --

--[[
    I made this framework to be as simple as possible behind the scenes, so ideally it should be easy to understand when compared to other frameworks.
    I'm also trying to integrate this into new and experimental projects of mine to give it a spin, so along the way I'll add features that I think are useful to me.

    If you feel something needs more documentation, please let me know! Find current documentation at https://www.seaminterface.com/
--]]