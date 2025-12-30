-- Author: iGottic

--[=[
    @class Computed
    @since 0.0.1
]=]

local Computed = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local StateManager = require(Modules.StateManager)
local Janitor = require(Modules.Janitor)
local Signal = require(Modules.Signal)
local Types = require(Modules.Types)
local Symbol = require(Modules.Symbol)
local Value = require(script.Parent.Value)
local GetValue = require(script.Parent.Parent.Utilities.GetValue)

-- Variables
local ClassSymbol = Symbol.new("Computed")

-- Types Extended
export type ComputedInstance<T> = {} & Types.BaseState<T>
export type ComputedConstructor<T> = (Callback : ((Value : Value.ValueInstance<T>) -> any) -> any?) -> ComputedInstance<T>

--[=[
    Constructs a Computed instance, which actively computes a value based on a given function.

    @param Callback (self : Instance, PropertyName : string) -> any? -- The function to compute the value
]=]

function Computed:__call(Callback : ((Value : Value.ValueInstance<any>) -> any) -> any?)
    -- This shit has caused me so much pain
    local JanitorInstance = Janitor.new()
    local ChangedSignal = Signal.new()
    local UsedValues = {}
    local CurrentValue = nil
    local IsInitialized = false
    local InstanceSymbol = Symbol.new("ComputedInstance")

    local function Use(ThisValue : Value.ValueInstance<any>)
        -- Is Use connecting to a state? If not, just get the value

        if ThisValue ~= nil and typeof(ThisValue) == "table" and ThisValue.__SEAM_OBJECT then
            if UsedValues[ThisValue] ~= nil then
                return GetValue(UsedValues[ThisValue])
            end

            UsedValues[ThisValue] = ThisValue

            JanitorInstance:Add(ThisValue.Changed:Connect(function()
                CurrentValue = Callback(Use)
                ChangedSignal:Fire("Value", CurrentValue) -- When the state changes, fire the changed signal for computed
            end))
        end

        return GetValue(ThisValue)
    end

    local ActiveComputation; ActiveComputation = setmetatable({
        Destroy = function()
            JanitorInstance:Destroy()
        end,
    }, {
        __call = function(_, Object : Instance, Index : string)
            JanitorInstance:Add(StateManager:AttachStateToObject(Object, {
                Value = function()
                    -- We don't want to re-calculate the computed when the states haven't changed,
                    -- so let's just force-calculate only when it's first checked

                    if not IsInitialized then
                        CurrentValue = Callback(Use)
                        IsInitialized = true
                    end
                    
                    return CurrentValue
                end,

                PropertyName = Index
            }))

            return ActiveComputation
        end,

        __index = function(_, Index : string)
            if Index == "__SEAM_OBJECT" then
                return InstanceSymbol
            elseif Index == "Value" then
                -- Same as above, let's not re-calculate

                if not IsInitialized then
                    CurrentValue = Callback(Use)
                    IsInitialized = true
                end

                return CurrentValue
            elseif Index == "Changed" then
                -- We need to connect the Use() functions here to track changes

                if not IsInitialized then
                    CurrentValue = Callback(Use)
                    IsInitialized = true
                end

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
        return ClassSymbol
    elseif Key == "__SEAM_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

local Meta = setmetatable({}, Computed)

return Meta :: ComputedConstructor<any>