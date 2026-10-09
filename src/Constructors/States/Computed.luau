-- Author: iGottic

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Batch = require(Modules.Batch)
local StateManager = require(Modules.StateManager)
local Trove = require(Modules.Trove)
local Signal = require(Modules.Signal)
local Symbol = require(Modules.Symbol)
local GetValue = require(script.Parent.Parent.Utilities.GetValue)
local IsState = require(script.Parent.Parent.Utilities.IsState)

-- Class
local Computed : Types.ConstructorDecompiled = {}

Computed.__SEAM_INDEX = Symbol.new("Computed")
Computed.__SEAM_CAN_BE_SCOPED = true

function Computed.__CALLBACK(_: Types.ConstructorCompiled, Callback : ((Value : Types.ValueInstance<any>) -> any) -> any?)
    -- This shit has caused me so much pain
    local TroveInstance = Trove.new()
    local ChangedSignal = Signal.new()
    local DependencyConnections : {[any] : RBXScriptConnection} = {}
    local CurrentValue = nil
    local IsInitialized = false
    local AttachedSignal = Signal.new()
    local IsRecomputing = false
    local RecomputeAndFireChanged
    local ActiveComputation : Types.ObjectCompiled

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

        local function Use(ThisValue : Types.ValueInstance<any>)
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

    local ComputationObject : Types.ObjectDecompiled = {
        __SEAM_OBJECT = Symbol.new("ComputedInstance"),
    }

    function ComputationObject.Destroy()
        CleanupDependencyConnections()
        TroveInstance:Destroy()
    end

    function ComputationObject.__CALLBACK(_: Types.ObjectCompiled, Object : Instance, Index : string)
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
    end

    function ComputationObject.__INDEX(_: Types.ObjectCompiled, Index : string)
        if Index == "Value" then
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

    ActiveComputation = Compiler.CompileObject(ComputationObject)

    return ActiveComputation :: Types.ComputedInstance<any>
end

return Compiler.CompileConstructor(Computed) :: Types.ComputedConstructor<any>