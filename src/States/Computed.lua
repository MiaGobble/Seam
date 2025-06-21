-- Author: iGottic

--[=[
    @class Computed
    @since 1.0.0
]=]

local Computed = {}

-- Types
type ComputedInstance = {
    get : (self : Instance, PropertyName : string) -> any?
}

type ComputedConstructor = (Callback : () -> any?) -> ComputedInstance

-- Imports
local Modules = script.Parent.Parent.Modules
local DependenciesManager = require(Modules.DependenciesManager)
local Janitor = require(Modules.Janitor)
local Value = require(script.Parent.Value)

--[=[
    Constructs a Computed instance, which actively computes a value based on a given function.

    @param Callback (self : Instance, PropertyName : string) -> any? -- The function to compute the value
]=]

function Computed:__call(Callback : ((Value : Value.ValueInstance) -> any) -> any?)
    local JanitorInstance = Janitor.new()
    local UsedValues = {}
    local CurrentValue = nil

    local function Use(Value : Value.ValueInstance)
        if UsedValues[Value] then
            return UsedValues[Value].Value
        end

        if not Value.Changed then
            print("no changed")
            return
        end

        UsedValues[Value] = Value

        JanitorInstance:Add(Value.Changed:Connect(function()
            CurrentValue = Callback(Use)
        end))

        return Value.Value
    end

    CurrentValue = Callback(Use)

    local ActiveComputation; ActiveComputation = setmetatable({
        Destroy = function()
            JanitorInstance:Destroy()
        end
    }, {
        __call = function(_, Object : Instance, Index : string)
            JanitorInstance:Add(DependenciesManager:AttachStateToObject(Object, {
                Value = function()
                    return CurrentValue
                end, --Callback,

                PropertyName = Index
            }))

            return ActiveComputation
        end,

        __index = function(_, Index : string)
            if Index == "__SEAM_OBJECT" then
                return "ComputedInstance"
            elseif Index == "Value" then
                return CurrentValue
            end

            return nil
        end
    })

    return ActiveComputation :: ComputedInstance
end

--[=[
    @ignore
]=]

function Computed:__index(Key : string)
    if Key == "__SEAM_INDEX" then
        return "Computed"
    elseif Key == "__SEAM_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

local Meta = setmetatable({}, Computed)

return Meta :: ComputedConstructor