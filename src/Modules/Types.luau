-- Author: iGottic

--[=[
    @since 0.1.3
]=]

export type BaseState<T> = {
    Value : T,
}

export type Child = Instance | BaseState<any> | {[unknown] : Child}

return nil