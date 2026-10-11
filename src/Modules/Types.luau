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
export type OnAttached = (object : any, callback : (attachedInstance : Instance) -> nil) -> RBXScriptConnection
export type OnAttributeChanged = (attributeName : string) -> (...any) -> RBXScriptConnection
export type OnChanged = (object : any, callback : (propertyChanged : string, newValue : any) -> nil) -> RBXScriptConnection
export type OnEvent = (eventName : string) -> (...any) -> RBXScriptConnection

-- Declarations
export type Attribute = (attributeName : string) -> (object : Instance, attributeValue : BaseState<any> | any) -> nil
export type Children = (object : Instance, children : {Child} | Child) -> nil
export type Tags = (object : Instance, addedTags : {string}) -> nil
export type Lifetime = (object : Instance, cleanupTime : number) -> nil
export type Destroyed = (object : Instance, callback : () -> nil) -> nil
export type FollowProperty = (propertyName : string) -> (object : Instance, valueState : BaseState<any>) -> nil
export type FollowAttribute = (attributeName : string) -> (object : Instance, valueState : BaseState<any>) -> nil
export type NewConstructor = (class : string | Instance | (ScopeInstance?, {[any] : any}) -> any, properties : {[any] : any}) -> Instance
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
	Properties : {[any] : any},
}

export type StyleSheetInstance = {
	Style : (self : StyleSheetInstance, selector : string) -> ({[any] : any}) -> (),
	Apply : (self : StyleSheetInstance, root : Instance) -> (),
	Unapply : (self : StyleSheetInstance, root : Instance) -> (),
	Destroy : (self : StyleSheetInstance) -> (),
} & typeof(setmetatable({}, {__call = function() end}))

export type StyleSheetGroup = typeof(setmetatable({}, {__call = function() end}))

export type StyleSheet = ((object : Instance, activeStyleSheet : StyleSheetInstance | StyleSheetGroup | any) -> ()) & {
	new : () -> StyleSheetInstance,
	group : (stylesheets : {[any] : StyleSheetInstance}) -> StyleSheetGroup,
}

-- States
export type ValueInstance<T> = {
	Changed : RBXScriptSignal,
	TableInsert : (self : ValueInstance<T>, insertedValue : any, path : {any}?) -> (),
	TableRemove : (self : ValueInstance<T>, removedValueIndex : number, path : {any}?) -> (),
	TableSet : (self : ValueInstance<T>, newTargetValue : any, path : {any}?) -> (),
} & BaseState<T>

export type ValueConstructor<T> = (value : T) -> ValueInstance<T>

export type ComputedInstance<T> = {} & BaseState<T>
export type ComputedConstructor<T> = (callback : ((value : ValueInstance<T>) -> any) -> any?) -> ComputedInstance<T>

export type ResourceStatus = "Idle" | "Loading" | "Ready" | "Error"
export type ResourceInstance<T> = {
	Changed : RBXScriptSignal,
	Status : ResourceStatus,
	Error : any,
	Refresh : (self : ResourceInstance<T>) -> (),
} & BaseState<T>
export type ResourceConstructor<T> = (callback : () -> T) -> ResourceInstance<T>

export type BezierInstance<T> = {
	Origin : any,
	Midpoint : any,
	Target : any,
	Alpha : any,
} & BaseState<T>
export type BezierConstructor<T> = (alpha : any, origin : any, midpoint : any, target : any) -> BezierInstance<T>

export type RenderedInstance<T> = {} & BaseState<T>
export type RenderedConstructor<T> = (callback : (number) -> any?) -> RenderedInstance<T>

export type ForPairsInstance<T> = {} & BaseState<T>
export type ForPairsConstructor<T> = (trackedValue : ValueInstance<any>, callback : ((value : ValueInstance<T>) -> any) -> any?) -> ForPairsInstance<T>

export type SpringInstance<T> = {
	Velocity : T,
	Target : T,
} & BaseState<T>
export type SpringConstructor<T> = (value : BaseState<T> | any, speed : BaseState<any> | number, dampening : BaseState<any> | number) -> SpringInstance<T>

export type TweenInstance<T> = {
	Target : T,
} & BaseState<T>
export type TweenConstructor<T> = (value : BaseState<T> | any, tweenInformation : BaseState<T> | TweenInfo) -> TweenInstance<T>

-- Memory
export type ScopeInstance = {
	New : (self : ScopeInstance, class : string | Instance | {[string] : any?}, properties : {[any] : any}, from : any?) -> Instance,
	Rendered : (self : ScopeInstance, callback : (number) -> any?) -> RenderedInstance<any>,
	Value : (self : ScopeInstance, initialValue : any) -> ValueInstance<any>,
	Spring : (self : ScopeInstance, value : BaseState<any> | any, speed : number, dampening : number) -> SpringInstance<any>,
	Tween : (self : ScopeInstance, value : BaseState<any> | any, tweenInformation : TweenInfo) -> TweenInstance<any>,
	Computed : (self : ScopeInstance, callback : ((value : ValueInstance<any>) -> any) -> any?) -> ComputedInstance<any>,
	ForPairs : (self : ScopeInstance, trackedValue : ValueInstance<any>, callback : ((value : ValueInstance<any>) -> any) -> any?) -> ForPairsInstance<any>,
	Bezier : (self : ScopeInstance, alpha : any, origin : any, midpoint : any, target : any) -> BezierInstance<any>,
	Resource : (self : ScopeInstance, callback : () -> any) -> ResourceInstance<any>,
	OnChanged : (self : ScopeInstance, object : any, callback : (propertyChanged : string, newValue : any) -> nil) -> RBXScriptConnection,
	OnAttributeChanged : (self : ScopeInstance, attributeName : string) -> (...any) -> RBXScriptConnection,
	OnEvent : (self : ScopeInstance, eventName : string) -> (...any) -> RBXScriptConnection,
	OnAttached : (self : ScopeInstance, object : any, callback : (attachedInstance : Instance) -> nil) -> RBXScriptConnection,

	InnerScope : (self : ScopeInstance, scopedObjects : {[string] : any}?) -> ScopeInstance,
	AddObject : <T>(self : ScopeInstance, object : T) -> (T),
	RemoveObject : (self : ScopeInstance, object : any) -> (),
	Destroy : (self : ScopeInstance) -> (),
}

export type ScopeConstructor = (scopedObjects : {[string] : (...any) -> ...any}) -> ScopeInstance

-- Utilities
export type GetValue = (state : any?) -> any?
export type SetValue = (state : any?, newValue : any?) -> any?
export type LockValue = (lockedValue : ValueInstance<any>) -> nil
export type IsState = (checkedValue : any?) -> boolean
export type IsComponent = (checkedValue : any?) -> boolean
export type Inspect = (object : any, debugName : string) -> RBXScriptConnection

return nil
