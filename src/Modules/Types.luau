-- Author: iGottic

-- Primitives
export type BaseState<T> = {
    Value : T,
}

export type Child = Instance | BaseState<any> | {[unknown] : Child}
export type ConstructorDecompiled = {__CALLBACK : (...any) -> any} & {[string] : any}
export type ConstructorCompiled = typeof(setmetatable({}, {__call = function() end}))
export type ObjectDecompiled = {
    __CALLBACK : ((...any) -> any)?,
    __INDEX : ((self : any, index : string) -> any)?,
    __NEWINDEX : ((self : any, index : string, value : any) -> ())?,
} & {[string] : any}
export type ObjectCompiled = typeof(setmetatable({}, {__call = function() end})) & {[string] : any}

-- Connections
export type OnAttached = (Object : any, Callback : (AttachedInstance : Instance) -> nil) -> RBXScriptConnection
export type OnAttributeChanged = (AttributeName : string) -> (...any) -> RBXScriptConnection
export type OnChanged = (Object : any, Callback : (PropertyChanged : string, NewValue : any) -> nil) -> RBXScriptConnection
export type OnEvent = (EventName : string) -> (...any) -> RBXScriptConnection

-- Declarations
export type Attribute = (AttributeName : string) -> (Object : Instance, AttributeValue : BaseState<any> | any) -> nil
export type Children = (Object : Instance, Children : {Child} | Child) -> nil
export type Tags = (Object : Instance, AddedTags : {string}) -> nil
export type Lifetime = (Object : Instance, CleanupTime : number) -> nil
export type Destroyed = (Object : Instance, Callback : () -> nil) -> nil
export type FollowProperty = (PropertyName : string) -> (Object : Instance, ValueState : BaseState<any>) -> nil
export type FollowAttribute = (AttributeName : string) -> (Object : Instance, ValueState : BaseState<any>) -> nil
export type NewConstructor = (Class : string | Instance | (ScopeInstance?, {[any] : any}) -> any, Properties : {[any] : any}) -> Instance
export type Component = ({[any] : any}) -> (ScopeInstance?, {[string] : any}) -> any

export type SequenceKeyframe = {number | () -> nil}
export type EventSequenceInstance = {
    Play : (EventSequenceInstance) -> nil,
    Stop : (EventSequenceInstance) -> nil,
    Pause : (EventSequenceInstance) -> nil,
    Resume : (EventSequenceInstance) -> nil,
    Looped : boolean,
    LoopDelayTime : number,
}
export type EventSequence = ({SequenceKeyframe}) -> EventSequenceInstance

export type StyleRule = {
    Selector : string,
    Properties : { [any] : any },
}

export type StyleSheetInstance = {
    Style : (self : StyleSheetInstance, selector : string) -> ({ [any] : any }) -> (),
    Apply : (self : StyleSheetInstance, root : Instance) -> (),
    Unapply : (self : StyleSheetInstance, root : Instance) -> (),
    Destroy : (self : StyleSheetInstance) -> (),
} & typeof(setmetatable({}, {__call = function() end}))

export type StyleSheetGroup = typeof(setmetatable({}, {__call = function() end}))

export type StyleSheet = ((Object : Instance, ActiveStyleSheet : StyleSheetInstance | StyleSheetGroup | any) -> ()) & {
    new : () -> StyleSheetInstance,
    group : (stylesheets : { [any] : StyleSheetInstance }) -> StyleSheetGroup,
}

-- States
export type ValueInstance<T> = {
    Changed : RBXScriptSignal,
    TableInsert : (self : ValueInstance<T>, InsertedValue : any, Path : {any}?) -> (),
    TableRemove : (self : ValueInstance<T>, RemovedValueIndex : number, Path : {any}?) -> (),
    TableSet : (self : ValueInstance<T>, NewTargetValue : any, Path : {any}?) -> (),
} & BaseState<T>

export type ValueConstructor<T> = (Value : T) -> ValueInstance<T>

export type ComputedInstance<T> = {} & BaseState<T>
export type ComputedConstructor<T> = (Callback : ((Value : ValueInstance<T>) -> any) -> any?) -> ComputedInstance<T>

export type ResourceStatus = "Idle" | "Loading" | "Ready" | "Error"
export type ResourceInstance<T> = {
    Changed : RBXScriptSignal,
    Status : ResourceStatus,
    Error : any,
    Refresh : (self : ResourceInstance<T>) -> (),
} & BaseState<T>
export type ResourceConstructor<T> = (Callback : () -> T) -> ResourceInstance<T>

export type BezierInstance<T> = {
    Origin : any,
    Midpoint : any,
    Target : any,
    Alpha : any,
} & BaseState<T>
export type BezierConstructor<T> = (Alpha : any, Origin : any, Midpoint : any, Target : any) -> BezierInstance<T>

export type RenderedInstance<T> = {} & BaseState<T>
export type RenderedConstructor<T> = (Callback : (number) -> any?) -> RenderedInstance<T>

export type ForPairsInstance<T> = {} & BaseState<T>
export type ForPairsConstructor<T> = (TrackedValue : ValueInstance<any>, Callback : ((Value : ValueInstance<T>) -> any) -> any?) -> ForPairsInstance<T>

export type SpringInstance<T> = {
    Velocity : T,
    Target : T,
} & BaseState<T>
export type SpringConstructor<T> = (Value : BaseState<T> | any, Speed : BaseState<any> | number, Dampening : BaseState<any> | number) -> SpringInstance<T>

export type TweenInstance<T> = {
    Target : T,
} & BaseState<T>
export type TweenConstructor<T> = (Value : BaseState<T> | any, TweenInformation : BaseState<T> | TweenInfo) -> TweenInstance<T>

-- Memory
export type ScopeInstance = {
    New : (self : ScopeInstance, Class : string | Instance | {[string] : any?}, Properties : {[any] : any}, From : any?) -> Instance,
    Rendered : (self : ScopeInstance, Callback : (number) -> any?) -> RenderedInstance<any>,
    Value : (self : ScopeInstance, InitialValue : any) -> ValueInstance<any>,
    Spring : (self : ScopeInstance, Value : BaseState<any> | any, Speed : number, Dampening : number) -> SpringInstance<any>,
    Tween : (self : ScopeInstance, Value : BaseState<any> | any, TweenInformation : TweenInfo) -> TweenInstance<any>,
    Computed : (self : ScopeInstance, Callback : ((Value : ValueInstance<any>) -> any) -> any?) -> ComputedInstance<any>,
    ForPairs : (self : ScopeInstance, TrackedValue : ValueInstance<any>, Callback : ((Value : ValueInstance<any>) -> any) -> any?) -> ForPairsInstance<any>,
    Bezier : (self : ScopeInstance, Alpha : any, Origin : any, Midpoint : any, Target : any) -> BezierInstance<any>,
    Resource : (self : ScopeInstance, Callback : () -> any) -> ResourceInstance<any>,
    OnChanged : (self : ScopeInstance, Object : any, Callback : (PropertyChanged : string, NewValue : any) -> nil) -> RBXScriptConnection,
    OnAttributeChanged : (self : ScopeInstance, AttributeName : string) -> (...any) -> RBXScriptConnection,
    OnEvent : (self : ScopeInstance, EventName : string) -> (...any) -> RBXScriptConnection,
    OnAttached : (self : ScopeInstance, Object : any, Callback : (AttachedInstance : Instance) -> nil) -> RBXScriptConnection,

    InnerScope : (self : ScopeInstance, ScopedObjects : {[string] : any}?) -> ScopeInstance,
    AddObject : <T>(self : ScopeInstance, Object : T) -> (T),
    RemoveObject : (self : ScopeInstance, Object : any) -> (),
    Destroy : (self : ScopeInstance) -> (),
}

export type ScopeConstructor = (ScopedObjects : {[string] : (...any) -> ...any}) -> ScopeInstance

return nil
