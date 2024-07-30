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
    local AttachedObjects = {}
    local MaidInstance = Maid.new()

    local ActiveValue = setmetatable({}, {
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

                -- for _, AttachedObject in AttachedObjects do -- Update all attached objects
                --     if not AttachedObject[1] then
                --         table.remove(AttachedObjects, table.find(AttachedObjects, AttachedObject))
                --         continue
                --     end

                --     if typeof(AttachedObject) == "Instance" and not AttachedObject[1]:IsDescendantOf(game) then
                --         table.remove(AttachedObjects, table.find(AttachedObjects, AttachedObject))
                --         continue
                --     end

                --     AttachedObject[1][AttachedObject[2]] = NewValue
                -- end
            else
                error("Invalid value type! Expected " .. typeof(Value) .. ", got " .. typeof(NewValue))
            end
        end,

        __call = function(self, Object, Index : string)
            table.insert(AttachedObjects, {
                Object, Index
            })

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