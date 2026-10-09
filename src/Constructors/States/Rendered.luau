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
local UpdateSignals = require(Modules.UpdateSignals)

-- Class
local Rendered : Types.ConstructorDecompiled = {}

Rendered.__SEAM_INDEX = Symbol.new("Rendered")
Rendered.__SEAM_CAN_BE_SCOPED = true

function Rendered.__CALLBACK(_: Types.ConstructorCompiled, Callback : (number) -> any?)
    -- This is MUCH simpler than computed, since it just force-updates every frame
    local TroveInstance = Trove.new()
    local ChangedSignal = Signal.new()
    local AttachedSignal = Signal.new()
    local CurrentValue = nil
    local IsInitialized = false
    local LastFrame = os.clock()
    local ActiveComputation : Types.ObjectCompiled

    local WrappedCallback = function()
        local DeltaTime = os.clock() - LastFrame
        LastFrame = os.clock()

        return Callback(DeltaTime)
    end

    TroveInstance:Add(UpdateSignals.OnFramePreUpdate:Connect(function()
        CurrentValue = WrappedCallback()
        IsInitialized = true
        Batch.Fire(ChangedSignal, "Value", CurrentValue)
    end))

    local RenderedObject : Types.ObjectDecompiled = {
        __SEAM_OBJECT = Symbol.new("RenderedInstance"),
        Changed = ChangedSignal,
        AttachedToInstance = AttachedSignal,
    }

    function RenderedObject.Destroy()
        TroveInstance:Destroy()
    end

    function RenderedObject.__CALLBACK(This : Types.ObjectCompiled, Object : Instance, Index : string)
        AttachedSignal:Fire(Object)

        TroveInstance:Add(StateManager:AttachStateToObject(Object, {
            Value = function()
                return This.Value
            end,
            PropertyName = Index
        }))

        return ActiveComputation
    end

    function RenderedObject.__INDEX(_: Types.ObjectCompiled, Index : string)
        if Index == "Value" then
            if not IsInitialized then
                CurrentValue = WrappedCallback()
                IsInitialized = true
            end

            return CurrentValue
        end

        return nil
    end

    ActiveComputation = Compiler.CompileObject(RenderedObject)

    return ActiveComputation :: Types.RenderedInstance<any>
end

return Compiler.CompileConstructor(Rendered) :: Types.RenderedConstructor<any>