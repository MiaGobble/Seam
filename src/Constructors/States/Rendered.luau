-- Author: iGottic

local Rendered = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local StateManager = require(Modules.StateManager)
local Trove = require(Modules.Trove)
local Signal = require(Modules.Signal)
local Types = require(Modules.Types)
local Symbol = require(Modules.Symbol)
local UpdateSignals = require(Modules.UpdateSignals)

-- Variables
local ClassSymbol = Symbol.new("Rendered")

-- Types Extended
export type RenderedInstance<T> = {} & Types.BaseState<T>
export type RenderedConstructor<T> = (Callback : (number) -> any?) -> RenderedInstance<T>

function Rendered:__call(Callback : (number) -> any?)
    -- This is MUCH simpler than computed, since it just force-updates every frame
    local TroveInstance = Trove.new()
    local ChangedSignal = Signal.new()
    local AttachedSignal = Signal.new()
    local InstanceSymbol = Symbol.new("RenderedInstance")
    local CurrentValue = nil
    local IsInitialized = false
    local LastFrame = os.clock()

    local WrappedCallback = function()
        local DeltaTime = os.clock() - LastFrame
        LastFrame = os.clock()

        return Callback(DeltaTime)
    end

    TroveInstance:Add(UpdateSignals.OnFramePreUpdate:Connect(function()
        CurrentValue = WrappedCallback()
        IsInitialized = true
        ChangedSignal:Fire("Value", CurrentValue)
    end))

    local ActiveComputation; ActiveComputation = setmetatable({
        Destroy = function()
            TroveInstance:Destroy()
        end
    }, {
        __call = function(This, Object : Instance, Index : string)
            AttachedSignal:Fire(Object)
            
            TroveInstance:Add(StateManager:AttachStateToObject(Object, {
                Value = function()
                    return This.Value
                end,
                PropertyName = Index
            }))

            return ActiveComputation
        end,

        __index = function(_, Index : string)
            if Index == "__SEAM_OBJECT" then
                return InstanceSymbol
            elseif Index == "Value" then
                if not IsInitialized then
                    CurrentValue = WrappedCallback()
                    IsInitialized = true
                end

                return CurrentValue
            elseif Index == "Changed" then
                return ChangedSignal
            elseif Index == "AttachedToInstance" then
                return AttachedSignal
            end

            return nil
        end
    })

    return ActiveComputation :: RenderedInstance<any>
end

function Rendered:__index(Key : string)
    if Key == "__SEAM_INDEX" then
        return ClassSymbol
    elseif Key == "__SEAM_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

local Meta = setmetatable({}, Rendered)

return Meta :: RenderedConstructor<any>