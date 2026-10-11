-- Author: iGottic

const InstanceTypeMap = require("./InstanceTypeMap")

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
export type Component = ({[any] : any}) -> (ScopeInstance?, {[string] : any}) -> any

-- Aliases to allow usage in UDTF
type fnIndex<T, U> = index<T, U>
type fnKeyOf<T> = keyof<T>

type Classes = InstanceTypeMap.Classes
type InstanceAlias = Instance
type function ResolveNewClass(class: type): (type)
	const tag = class.tag
	if tag == "extern" then
		return class
	elseif tag == "singleton" then
		const exists, classType = pcall(fnIndex, Classes, class)
		if exists then
			return classType
		end

		print(`{class} isn't a registered class and can't be checked (is the type map outdated?)\nAnnotate the class type to silence.`)
		return InstanceAlias
	elseif tag == "string" then
		print(`Can't resolve class from string primitive, did you mean to use a string literal?\nAnnotate as \`any\` to silence.`)
		return InstanceAlias
	elseif class:issubtypeof(ScopeInstanceNewConstructor) then
		print(`Can't resolve class from a \`ScopeInstance\` constructor, consider annotating the argument.`)
		return InstanceAlias
	elseif tag == "any" then
		return InstanceAlias
	else
		print(`Can't resolve class from {tag}type.`)
		return InstanceAlias
	end
end

type function writableMembersOf(tbl: type): (type)
	const EXCLUDE = {
		["ClassName"] = true,
		["RobloxLocked"] = true,
		["AbsolutePosition"] = true,
		["AbsoluteRotation"] = true,
		["AbsoluteSize"] = true,
		["Localize"] = true,
	}

	const props = types.newtable()
	local node = tbl
	while node do
		for keyType, rwType in node:properties() do
			if EXCLUDE[keyType:value()] then continue end

			const writeType = rwType.write

			-- Filter out read-only members
			-- LUAU FIXME: This doesn't work right now because there is no serialized distinction
			-- between read-only and other members. Both read and write are set to the same type.
			if not writeType then continue end

			-- Filter out methods
			if writeType.tag == "function" then continue end

			-- Account for overloads too
			if writeType.tag == "intersection" and writeType:components()[1].tag == "function" then continue end

			-- Filter out signals
			if writeType.tag == "table" or writeType.tag == "extern" then
				const exists = pcall(fnIndex, writeType, types.singleton("Connect"))
				if exists then continue end
			end

			-- LUAU FIXME: subtyping doesn't work if we don't make it read-only
			props:setproperty(types.optional(writeType))
		end

		node = node:readparent()
	end

	return props
end

type ScopeInstanceNewConstructor = (ScopeInstance?, {[any]: any}) -> (any)
export type NewConstructor = <T>(
	Class: T & (keyof<Classes> | "" | string | Instance | ScopeInstanceNewConstructor),
	Properties: writableMembersOf<ResolveNewClass<T>>
) -> (ResolveNewClass<T>)

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

-- Utilities
export type GetValue = (State : any?) -> any?
export type SetValue = (State : any?, NewValue : any?) -> any?
export type LockValue = (LockedValue : ValueInstance<any>) -> nil
export type IsState = (CheckedValue : any?) -> boolean
export type IsComponent = (CheckedValue : any?) -> boolean
export type Inspect = (Object : any, DebugName : string) -> RBXScriptConnection

return nil
