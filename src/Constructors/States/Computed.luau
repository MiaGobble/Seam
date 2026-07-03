-- Author: iGottic

local Computed = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Batch = require(Modules.Batch)
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
    local DependencyConnections : {[any] : RBXScriptConnection} = {}
    local CurrentValue = nil
    local IsInitialized = false
    local AttachedSignal = Signal.new()
    local InstanceSymbol = Symbol.new("ComputedInstance")
    local IsRecomputing = false
    local RecomputeAndFireChanged

    local function CleanupDependencyConnections()
        for _, Connection in DependencyConnections do
            if Connection.Connected then
                Connection:Disconnect()
            end
        end

        table.clear(DependencyConnections)
    end

    local function RecomputeCore()
        if IsRecomputing then
            return
        end

        IsRecomputing = true

        local SeenDependencies : {[any] : boolean} = {}

        local function Use(ThisValue : Value.ValueInstance<any>)
            -- Is Use connecting to a state? If not, just get the value

            if ThisValue ~= nil and IsState(ThisValue) then
                SeenDependencies[ThisValue] = true

                if DependencyConnections[ThisValue] == nil then
                    DependencyConnections[ThisValue] = ThisValue.Changed:Connect(function()
                        RecomputeAndFireChanged()
                    end)
                end
            end

            return GetValue(ThisValue)
        end

        CurrentValue = Callback(Use)
        IsInitialized = true

        for Dependency, Connection in DependencyConnections do
            if not SeenDependencies[Dependency] then
                if Connection.Connected then
                    Connection:Disconnect()
                end

                DependencyConnections[Dependency] = nil
            end
        end

        IsRecomputing = false
    end

    RecomputeAndFireChanged = function()
        RecomputeCore()
        Batch.Fire(ChangedSignal, "Value", CurrentValue)
    end

    local function RecomputeSilently()
        RecomputeCore()
    end

    local ActiveComputation; ActiveComputation = setmetatable({
        Destroy = function()
            CleanupDependencyConnections()
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
                        RecomputeSilently()
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
                    RecomputeSilently()
                end

                return CurrentValue
            elseif Index == "Changed" then
                -- We need to connect the Use() functions here to track changes

                if not IsInitialized then
                    RecomputeSilently()
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