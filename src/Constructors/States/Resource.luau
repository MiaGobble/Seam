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

-- Class
local Resource : Types.ConstructorDecompiled = {}

Resource.__SEAM_OBJECT = Symbol.new("Resource")
Resource.__SEAM_CAN_BE_SCOPED = true

function Resource.__CALLBACK(_: Types.ConstructorCompiled, Callback : () -> any) : Types.ResourceInstance<any>
    local TroveInstance = Trove.new()
    local ChangedSignal = Signal.new()
    local AttachedSignal = Signal.new()
    local CurrentValue = nil
    local CurrentStatus : Types.ResourceStatus = "Idle"
    local CurrentError = nil
    local RequestId = 0
    local ActiveResource : Types.ObjectCompiled

    local function EmitChanged()
        Batch.Fire(ChangedSignal, "Value", CurrentValue)
    end

    local function Refresh()
        RequestId += 1
        local ThisRequestId = RequestId

        CurrentStatus = "Loading"
        CurrentError = nil
        EmitChanged()

        task.spawn(function()
            local Success, Result = pcall(Callback)

            if ThisRequestId ~= RequestId then
                return
            end

            if Success then
                CurrentValue = Result
                CurrentStatus = "Ready"
                CurrentError = nil
            else
                CurrentStatus = "Error"
                CurrentError = Result
            end

            EmitChanged()
        end)
    end

    local ResourceObject : Types.ObjectDecompiled = {
        __SEAM_OBJECT = Symbol.new("Resource"),
        Changed = ChangedSignal,
        AttachedToInstance = AttachedSignal,
        Refresh = Refresh,
    }

    function ResourceObject.Destroy()
        TroveInstance:Destroy()
        TroveInstance = nil
    end

    function ResourceObject.__CALLBACK(This : Types.ObjectCompiled, Object : Instance, Index : string)
        AttachedSignal:Fire(Object)

        TroveInstance:Add(StateManager:AttachStateToObject(Object, {
            Value = function()
                return This.Value
            end,

            PropertyName = Index,
        }))

        return ActiveResource
    end

    function ResourceObject.__INDEX(_: Types.ObjectCompiled, Index : string)
        if Index == "Value" then
            return CurrentValue
        elseif Index == "Status" then
            return CurrentStatus
        elseif Index == "Error" then
            return CurrentError
        end

        return nil
    end

    function ResourceObject.__NEWINDEX(_: Types.ObjectCompiled, Index : string, NewValue : any)
        if Index == "Value" then
            CurrentValue = NewValue
            CurrentStatus = "Ready"
            CurrentError = nil
            EmitChanged()
            return
        elseif Index == "Status" then
            CurrentStatus = NewValue
            EmitChanged()
            return
        elseif Index == "Error" then
            CurrentError = NewValue
            EmitChanged()
            return
        end

        error("Ran into an unexpected error")
    end

    ActiveResource = Compiler.CompileObject(ResourceObject)

    Refresh()

    return ActiveResource :: Types.ResourceInstance<any>
end

return Compiler.CompileConstructor(Resource) :: Types.ResourceConstructor<any>