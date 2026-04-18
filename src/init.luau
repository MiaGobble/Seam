-- Author: iGottic
-- Documentation: https://seam.igottic.com/

-- Services
local RunService = game:GetService("RunService")

-- Imports
-- Note: I opt for WaitForChild to load stuff; this helps prevent edge case errors where children don't load in time, particularly when loading from ReplicatedStorage in a script located in ReplicatedFirst
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
local ForPairs = require(States:WaitForChild("ForPairs"))

-- Types extended
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
    ForPairs : ForPairs.ForPairsConstructor<any>
}

export type BaseState<T> = Types.BaseState<T>
export type Child = Types.Child
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
export type ForPairs<T> = ForPairs.ForPairsInstance<T>
export type ForPairsInstance<T> = ForPairs.ForPairsInstance<T>

-- Declaration
local Seam : Seam = {} :: Seam

local function Init()
    if RunService:IsServer() then
        return -- Don't wait for game.Loaded on server
    end

    if not game:IsLoaded() then
        game.Loaded:Wait()

        -- There is this weird bug where, when loaded from ReplicatedFirst, the framework loads *too* fast and animations don't work on the frontend.
        -- This is a hacky workaround for this while I figure out a better solution.
    end
end

Seam.New = New
Seam.Children = Children
Seam.Value = Value
Seam.Computed = Computed
Seam.Spring = Spring
Seam.Tween = Tween
Seam.Scope = Scope
Seam.OnEvent = OnEvent
Seam.OnChanged = OnChanged
Seam.Attribute = Attribute
Seam.OnAttributeChanged = OnAttributeChanged
Seam.Lifetime = Lifetime
Seam.Rendered = Rendered
Seam.FollowProperty = FollowProperty
Seam.FollowAttribute = FollowAttribute
Seam.GetValue = GetValue
Seam.Component = Component
Seam.Tags = Tags
Seam.SetValue = SetValue
Seam.IsState = IsState
Seam.IsComponent = IsComponent
Seam.LockValue = LockValue
Seam.Inspect = Inspect
Seam.OnAttached = OnAttached
Seam.Destroyed = Destroyed
Seam.EventSequence = EventSequence
Seam.ForPairs = ForPairs

Init()

return Seam :: Seam