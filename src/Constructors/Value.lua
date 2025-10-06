-- Author: iGottic

--[=[
    @class Value
    @since 0.0.1
]=]

local Value = {}

-- Imports
local Modules = script.Parent.Parent.Modules
local DependenciesManager = require(Modules.DependenciesManager)
local Janitor = require(Modules.Janitor)
local Signal = require(Modules.Signal)
local Types = require(Modules.Types)
local IsValueChanged = require(Modules.IsValueChanged)

-- Types Extended
export type ValueInstance<T> = {
    Changed : RBXScriptSignal,
} & Types.BaseState<T>

export type ValueConstructor<T> = (Value : T) -> ValueInstance<T>

--[=[
    Creates a new value object. Enforces type checking based on initial value type.

    @param Value any -- The initial value
    @return {Value : any} -- The value object
]=]

function Value:__call(... : any)
    local JanitorInstance = Janitor.new()
    local ChangedSignal = Signal.new()
    local ThisValue = ...

    --[[
        local This = Value(...)
        This.Value = x OR x = This.Value
        This.Changed -> As rbxscriptsignal
    --]]

    local ActiveValue = setmetatable({
        Destroy = function(self)
            JanitorInstance:Destroy()
        end
    }, {
        __index = function(self, Index : string)
            if Index == "__SEAM_OBJECT" then
                return "Value"
            elseif Index == "Value" then
                return ThisValue
            elseif Index == "Changed" then
                return ChangedSignal
            end

            return nil
        end,

        __newindex = function(self, Index : string, NewValue : any)
            if Index == "Value" and typeof(NewValue) == typeof(ThisValue) then
                if not IsValueChanged(ThisValue, NewValue) then
                    return
                end

                ThisValue = NewValue
                ChangedSignal:Fire("Value")
            else
                error("Invalid value type! Expected " .. typeof(ThisValue) .. ", got " .. typeof(NewValue))
            end
        end,

        __call = function(self, Object, Index : string)
            if not Object then
                return
            end

            if not Index then
                return
            end

            Object[Index] = ThisValue

            JanitorInstance:Add(DependenciesManager:AttachStateToObject(Object, {
                Value = function()
                    return ThisValue
                end,
                
                PropertyName = Index
            }))
        end
    })

    return ActiveValue :: ValueInstance<any>
end

--[=[
    @ignore
]=]

function Value:__index(Index : string)
    if Index == "__SEAM_INDEX" then
        return "Value"
    elseif Index == "__SEAM_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

local Meta = setmetatable({}, Value)

return Meta :: ValueConstructor<any>