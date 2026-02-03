-- Author: iGottic

local Computed = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local StateManager = require(Modules.StateManager)
local Trove = require(Modules.Trove)
local Signal = require(Modules.Signal)
local Types = require(Modules.Types)
local Symbol = require(Modules.Symbol)
local Value = require(script.Parent.Value)
local GetValue = require(script.Parent.Parent.Utilities.GetValue)
local IsState = require(script.Parent.Parent.Utilities.IsState)

-- Variables
local ClassSymbol = Symbol.new("Computed")

-- Types Extended
export type ComputedInstance<T> = {} & Types.BaseState<T>
export type ComputedConstructor<T> = (Callback : ((Value : Value.ValueInstance<T>) -> any) -> any?) -> ComputedInstance<T>

function Computed:__call(Callback : ((Value : Value.ValueInstance<any>) -> any) -> any?)
    -- This shit has caused me so much pain
    local TroveInstance = Trove.new()
    local ChangedSignal = Signal.new()
    local UsedValues = {}
    local CurrentValue = nil
    local IsInitialized = false
    local AttachedSignal = Signal.new()
    local InstanceSymbol = Symbol.new("ComputedInstance")

    local function Use(ThisValue : Value.ValueInstance<any>)
        -- Is Use connecting to a state? If not, just get the value

        if ThisValue ~= nil and IsState(ThisValue) then
            if UsedValues[ThisValue] ~= nil then
                return GetValue(UsedValues[ThisValue])
            end

            UsedValues[ThisValue] = ThisValue

            TroveInstance:Add(ThisValue.Changed:Connect(function()
                CurrentValue = Callback(Use)
                ChangedSignal:Fire("Value", CurrentValue) -- When the state changes, fire the changed signal for computed
            end))
        end

        return GetValue(ThisValue)
    end

    local ActiveComputation; ActiveComputation = setmetatable({
        Destroy = function()
            TroveInstance:Destroy()
        end,
    }, {
        __call = function(_, Object : Instance, Index : string)
            AttachedSignal:Fire(Object)

            TroveInstance:Add(StateManager:AttachStateToObject(Object, {
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
            elseif Index == "AttachedToInstance" then
                return AttachedSignal
            end

            return nil
        end
    })

    return ActiveComputation :: ComputedInstance<any>
end

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