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
local Batch = require(Modules:WaitForChild("Batch"))
local New = require(Declarations:WaitForChild("New"))
local Children = require(Declarations:WaitForChild("Children"))
local Value = require(States:WaitForChild("Value"))
local Computed = require(States:WaitForChild("Computed"))
local Resource = require(States:WaitForChild("Resource"))
local Bezier = require(States:WaitForChild("Bezier"))
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
local StyleSheet = require(Declarations:WaitForChild("StyleSheet"))
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
    Batch : Batch.Batch,
    New : Types.NewConstructor,
    Children : Types.Children,
    Value : Types.ValueConstructor<any>,
    Computed : Types.ComputedConstructor<any>,
    Resource : Types.ResourceConstructor<any>,
    Bezier : Types.BezierConstructor<any>,
    Spring : Types.SpringConstructor<any>,
    Tween : Types.TweenConstructor<any>,
    Scope : Types.ScopeConstructor,
    OnEvent : Types.OnEvent,
    OnChanged : Types.OnChanged,
    Attribute : Types.Attribute,
    OnAttributeChanged : Types.OnAttributeChanged,
    Lifetime : Types.Lifetime,
    Rendered : Types.RenderedConstructor<any>,
    FollowProperty : Types.FollowProperty,
    FollowAttribute : Types.FollowAttribute,
    GetValue : Types.GetValue,
    Component : Types.Component,
    Tags : Types.Tags,
    StyleSheet : Types.StyleSheet,
    SetValue : Types.SetValue,
    IsState : Types.IsState,
    IsComponent : Types.IsComponent,
    LockValue : Types.LockValue,
    Inspect : Types.Inspect,
    OnAttached : Types.OnAttached,
    Destroyed : Types.Destroyed,
    EventSequence : Types.EventSequence,
    ForPairs : Types.ForPairsConstructor<any>
}

export type BaseState<T> = Types.BaseState<T>
export type Batch = Batch.Batch
export type Child = Types.Child
export type NewConstructor = Types.NewConstructor
export type Children = Types.Children
export type Value<T> = Types.ValueInstance<T>
export type ValueConstructor<T> = Types.ValueConstructor<T>
export type Computed<T> = Types.ComputedInstance<T>
export type ComputedConstructor<T> = Types.ComputedConstructor<T>
export type Resource<T> = Types.ResourceInstance<T>
export type ResourceConstructor<T> = Types.ResourceConstructor<T>
export type Bezier<T> = Types.BezierInstance<T>
export type BezierConstructor<T> = Types.BezierConstructor<T>
export type Spring<T> = Types.SpringInstance<T>
export type SpringConstructor<T> = Types.SpringConstructor<T>
export type Tween<T> = Types.TweenInstance<T>
export type TweenConstructor<T> = Types.TweenConstructor<T>
export type Scope = Types.ScopeInstance
export type ScopeConstructor = Types.ScopeConstructor
export type OnEvent = Types.OnEvent
export type OnChanged = Types.OnChanged
export type Attribute = Types.Attribute
export type OnAttributeChanged = Types.OnAttributeChanged
export type Lifetime = Types.Lifetime
export type Rendered<T> = Types.RenderedInstance<T>
export type RenderedConstructor<T> = Types.RenderedConstructor<T>
export type FollowProperty = Types.FollowProperty
export type FollowAttribute = Types.FollowAttribute
export type GetValue = Types.GetValue
export type Component = Types.Component
export type Tags = Types.Tags
export type StyleSheet = Types.StyleSheet
export type SetValue = Types.SetValue
export type IsState = Types.IsState
export type IsComponent = Types.IsComponent
export type LockValue = Types.LockValue
export type Inspect = Types.Inspect
export type OnAttached = Types.OnAttached
export type Destroyed = Types.Destroyed
export type EventSequence = Types.EventSequence
export type ForPairs<T> = Types.ForPairsInstance<T>
export type ForPairsInstance<T> = Types.ForPairsInstance<T>

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
Seam.Batch = Batch
Seam.Children = Children
Seam.Value = Value
Seam.Computed = Computed
Seam.Resource = Resource
Seam.Bezier = Bezier
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
Seam.StyleSheet = StyleSheet
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
