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
export type OnEvent = (EventName : string) -> (...any) -> RBXScriptConnection
export type Attribute = (AttributeName : string) -> (Object : Instance, AttributeValue : BaseState<any> | any) -> nil

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

return nil