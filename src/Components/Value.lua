-- Author: iGottic

--[=[
    @class Value
    @since 1.0.0
]=]

local Value = {}

-- Types
type ValueInstance = {
    Value : any
}

type ValueConstructor = (Value : any) -> ValueInstance

-- Imports
local Modules = script.Parent.Parent.Modules
local DependenciesManager = require(Modules.DependenciesManager)
local Maid = require(Modules.Maid)

--[=[
    Creates a new value object. Enforces type checking based on initial value type.

    @param Value any -- The initial value
    @return {Value : any} -- The value object
]=]

function Value:__call(Value : any)
    local MaidInstance = Maid.new()

    local ActiveValue = setmetatable({
        Destroy = function(self)
            MaidInstance:Destroy()
            MaidInstance = nil
        end
    }, {
        __index = function(self, Index : string)
            if Index == "__SPHI_OBJECT" then
                return "Value"
            elseif Index == "Value" then
                return Value
            end

            return nil
        end,

        __newindex = function(self, Index : string, NewValue : any)
            if Index == "Value" and typeof(NewValue) == typeof(Value)  then
                Value = NewValue
            else
                error("Invalid value type! Expected " .. typeof(Value) .. ", got " .. typeof(NewValue))
            end
        end,

        __call = function(self, Object, Index : string)
            Object[Index] = Value

            MaidInstance:GiveTask(MaidInstance[DependenciesManager:AttachStateToObject(Object, {
                Value = function()
                    return Value
                end,
                
                PropertyName = Index
            })])
        end
    })

    return ActiveValue :: ValueInstance
end

local Meta = setmetatable({}, Value)

return Meta :: ValueConstructor