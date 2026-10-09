-- Author: iGottic

-- Primitives
export type BaseState<T> = {
    Value : T,
}

export type Child = Instance | BaseState<any> | {[unknown] : Child}
export type ConstructorDecompiled = {Callback : (...any) -> any} & {[string] : any}
export type ConstructorCompiled = typeof(setmetatable({}, {__call = function() end}))

return nil