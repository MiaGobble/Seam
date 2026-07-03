-- Author: iGottic

local Resource = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Batch = require(Modules.Batch)
local StateManager = require(Modules.StateManager)
local Trove = require(Modules.Trove)
local Signal = require(Modules.Signal)
local Types = require(Modules.Types)
local Symbol = require(Modules.Symbol)

-- Variables
local ClassSymbol = Symbol.new("Resource")

-- Types Extended
export type ResourceStatus = "Idle" | "Loading" | "Ready" | "Error"

export type ResourceInstance<T> = {
    Changed : RBXScriptSignal,
    Status : ResourceStatus,
    Error : any,
    Refresh : (self : ResourceInstance<T>) -> (),
} & Types.BaseState<T>

export type ResourceConstructor<T> = (Callback : () -> T) -> ResourceInstance<T>

function Resource:__call(Callback : () -> any) : ResourceInstance<any>
    local TroveInstance = Trove.new()
    local ChangedSignal = Signal.new()
    local AttachedSignal = Signal.new()
    local InstanceSymbol = Symbol.new("Resource")
    local CurrentValue = nil
    local CurrentStatus : ResourceStatus = "Idle"
    local CurrentError = nil
    local RequestId = 0

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

    local ActiveResource; ActiveResource = setmetatable({
        Destroy = function()
            TroveInstance:Destroy()
            TroveInstance = nil
        end,
    }, {
        __call = function(This, Object : Instance, Index : string)
            AttachedSignal:Fire(Object)

            TroveInstance:Add(StateManager:AttachStateToObject(Object, {
                Value = function()
                    return This.Value
                end,

                PropertyName = Index,
            }))

            return ActiveResource
        end,

        __index = function(_, Index : string)
            if Index == "__SEAM_OBJECT" then
                return InstanceSymbol
            elseif Index == "Value" then
                return CurrentValue
            elseif Index == "Status" then
                return CurrentStatus
            elseif Index == "Error" then
                return CurrentError
            elseif Index == "Changed" then
                return ChangedSignal
            elseif Index == "AttachedToInstance" then
                return AttachedSignal
            elseif Index == "Refresh" then
                return Refresh
            end

            return nil
        end,

        __newindex = function(_, Index : string, NewValue : any)
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
        end,
    })

    Refresh()

    return ActiveResource :: ResourceInstance<any>
end

function Resource:__index(Index : string)
    if Index == "__SEAM_OBJECT" then
        return ClassSymbol
    elseif Index == "__SEAM_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

local Meta = setmetatable({}, Resource)

return Meta :: ResourceConstructor<any>