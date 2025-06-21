-- Author: iGottic

--[=[
    @class Value
    @since 1.0.0
]=]

local Value = {}

-- Types
export type ValueInstance = {
    Value : any,
    Changed : RBXScriptSignal,
}

type ValueConstructor = (Value : any) -> ValueInstance

-- Imports
local Modules = script.Parent.Parent.Modules
local DependenciesManager = require(Modules.DependenciesManager)
local Janitor = require(Modules.Janitor)
local Signal = require(Modules.Signal)

--[=[
    Creates a new value object. Enforces type checking based on initial value type.

    @param Value any -- The initial value
    @return {Value : any} -- The value object
]=]

function Value:__call(Value : any)
    local JanitorInstance = Janitor.new()
    local ChangedSignal = Signal.new()

    local ActiveValue = setmetatable({
        Destroy = function(self)
            JanitorInstance:Destroy()
        end
    }, {
        __index = function(self, Index : string)
            if Index == "__SEAM_OBJECT" then
                return "Value"
            elseif Index == "Value" then
                return Value
            elseif Index == "Changed" then
                return ChangedSignal
            end

            return nil
        end,

        __newindex = function(self, Index : string, NewValue : any)
            if Index == "Value" and typeof(NewValue) == typeof(Value)  then
                Value = NewValue
                ChangedSignal:Fire("Value")
            else
                error("Invalid value type! Expected " .. typeof(Value) .. ", got " .. typeof(NewValue))
            end
        end,

        __call = function(self, Object, Index : string)
            if not Object then
                return
            end

            if not Index then
                return
            end

            Object[Index] = Value

            JanitorInstance:Add(DependenciesManager:AttachStateToObject(Object, {
                Value = function()
                    return Value
                end,
                
                PropertyName = Index
            }))
        end
    })

    return ActiveValue :: ValueInstance
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

return Meta :: ValueConstructor