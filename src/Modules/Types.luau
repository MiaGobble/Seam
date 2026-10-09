-- Author: iGottic

-- Primitives
export type BaseState<T> = {
    Value : T,
}

export type Child = Instance | BaseState<any> | {[unknown] : Child}
export type ConstructorDecompiled = {__CALLBACK : (...any) -> any} & {[string] : any}
export type ConstructorCompiled = typeof(setmetatable({}, {__call = function() end}))
export type ObjectDecompiled = {__CALLBACK : (...any) -> any} & {[string] : any}
export type ObjectCompiled = typeof(setmetatable({}, {__call = function() end})) & {[string] : any}

-- Constructors
export type OnAttached = (Object : any, Callback : (AttachedInstance : Instance) -> nil) -> RBXScriptConnection
export type OnAttributeChanged = (AttributeName : string) -> (...any) -> RBXScriptConnection
export type OnChanged = (Object : any, Callback : (PropertyChanged : string, NewValue : any) -> nil) -> RBXScriptConnection

return nil