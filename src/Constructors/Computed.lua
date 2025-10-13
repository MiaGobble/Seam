-- Author: iGottic

--[=[
    @class Computed
    @since 0.0.1
]=]

local Computed = {}

-- Imports
local Modules = script.Parent.Parent.Modules
local DependenciesManager = require(Modules.DependenciesManager)
local Janitor = require(Modules.Janitor)
local Signal = require(Modules.Signal)
local Types = require(Modules.Types)
local Value = require(script.Parent.Value)
local GetValue = require(script.Parent.GetValue)

-- Types Extended
export type ComputedInstance<T> = {} & Types.BaseState<T>
export type ComputedConstructor<T> = (Callback : ((Value : Value.ValueInstance<T>) -> any) -> any?) -> ComputedInstance<T>

--[=[
    Constructs a Computed instance, which actively computes a value based on a given function.

    @param Callback (self : Instance, PropertyName : string) -> any? -- The function to compute the value
]=]

function Computed:__call(Callback : ((Value : Value.ValueInstance<any>) -> any) -> any?)
    local JanitorInstance = Janitor.new()
    local ChangedSignal = Signal.new()
    local UsedValues = {}
    local CurrentValue = nil
    local IsInitialized = false

    local function Use(Value : Value.ValueInstance<any>)
        if Value and typeof(Value) == "table" and Value.__SEAM_OBJECT then
            if UsedValues[Value] then
                return GetValue(UsedValues[Value])
            end

            UsedValues[Value] = Value

            JanitorInstance:Add(Value.Changed:Connect(function()
                CurrentValue = Callback(Use)
                ChangedSignal:Fire("Value")
            end))
        end

        return GetValue(Value)
    end

    local ActiveComputation; ActiveComputation = setmetatable({
        Destroy = function()
            JanitorInstance:Destroy()
        end,
    }, {
        __call = function(_, Object : Instance, Index : string)
            JanitorInstance:Add(DependenciesManager:AttachStateToObject(Object, {
                Value = function()
                    return CurrentValue
                end,

                PropertyName = Index
            }))

            return ActiveComputation
        end,

        __index = function(_, Index : string)
            if Index == "__SEAM_OBJECT" then
                return "ComputedInstance"
            elseif Index == "Value" then
                if not IsInitialized then
                    CurrentValue = Callback(Use)
                    IsInitialized = true
                end

                return CurrentValue
            elseif Index == "Changed" then
                return ChangedSignal
            end

            return nil
        end
    })

    return ActiveComputation :: ComputedInstance<any>
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

return Meta :: ComputedConstructor<any>