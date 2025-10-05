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
local Value = require(script.Parent.Value)
local Types = require(Modules.Types)

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

    local function Use(Value : Value.ValueInstance<any>)
        if not Value then
            return nil
        end

        if UsedValues[Value] then
            return UsedValues[Value].Value
        end

        if not Value.Changed then
            return
        end

        UsedValues[Value] = Value

        JanitorInstance:Add(Value.Changed:Connect(function()
            CurrentValue = Callback(Use)
            ChangedSignal:Fire()
        end))

        return Value.Value
    end

    CurrentValue = Callback(Use)

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