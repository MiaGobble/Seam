-- Author: iGottic

local Bezier = {}

-- Imports
local Constructors = script.Parent.Parent
local Modules = Constructors.Parent.Modules
local Batch = require(Modules.Batch)
local GetValue = require(Constructors.Utilities.GetValue)
local StateManager = require(Modules.StateManager)
local ValuePacker = require(Modules.ValuePacker)
local Trove = require(Modules.Trove)
local Signal = require(Modules.Signal)
local IsValueChanged = require(Modules.IsValueChanged)
local Symbol = require(Modules.Symbol)
local UpdateSignals = require(Modules.UpdateSignals)

-- Variables
local ClassSymbol = Symbol.new("Bezier")

-- Types Extended
type BaseState<T> = {
    Value : T,
}

export type BezierInstance<T> = {
    Origin : any,
    Midpoint : any,
    Target : any,
    Alpha : any,
} & BaseState<T>

export type BezierConstructor<T> = (
    Alpha : any,
    Origin : any,
    Midpoint : any,
    Target : any
) -> BezierInstance<T>

local function ClampAlpha(AlphaValue : number) : number
    return math.clamp(AlphaValue, 0, 1)
end

local function GetBezierNumber(AlphaValue : number, OriginValue : number, MidpointValue : number, TargetValue : number) : number
    local InverseAlpha = 1 - AlphaValue
    return (InverseAlpha * InverseAlpha * OriginValue) + (2 * InverseAlpha * AlphaValue * MidpointValue) + (AlphaValue * AlphaValue * TargetValue)
end

local function GetBezierValue(AlphaValue : number, OriginValue : any, MidpointValue : any, TargetValue : any, ValueType : string) : any
    if ValueType == "number" then
        return GetBezierNumber(AlphaValue, OriginValue, MidpointValue, TargetValue)
    end

    local UnpackedOrigin = ValuePacker.UnpackValue(OriginValue, ValueType)
    local UnpackedMidpoint = ValuePacker.UnpackValue(MidpointValue, ValueType)
    local UnpackedTarget = ValuePacker.UnpackValue(TargetValue, ValueType)

    if #UnpackedOrigin == 0 then
        if AlphaValue <= 0 then
            return OriginValue
        elseif AlphaValue >= 1 then
            return TargetValue
        end

        return MidpointValue
    end

    local UnpackedBezier = {}

    for Index, OriginElement in UnpackedOrigin do
        UnpackedBezier[Index] = GetBezierNumber(AlphaValue, OriginElement, UnpackedMidpoint[Index], UnpackedTarget[Index])
    end

    return ValuePacker.PackValue(UnpackedBezier, ValueType)
end

function Bezier:__call(Alpha : any, Origin : any, Midpoint : any, Target : any) : BezierInstance<any>
    local CurrentOrigin = GetValue(Origin)
    local CurrentMidpoint = GetValue(Midpoint)
    local CurrentTarget = GetValue(Target)
    local CurrentAlpha = GetValue(Alpha)
    local ValueType = typeof(CurrentOrigin)
    local TroveInstance = Trove.new()
    local AttachedSignal = Signal.new()
    local ChangedSignal = Signal.new()
    local CurrentValue = nil
    local LastValue = nil
    local InstanceSymbol = Symbol.new("Bezier")
    local IsSleeping = false

    if typeof(CurrentAlpha) ~= "number" then
        error("Bezier alpha must resolve to a number")
    end

    if typeof(CurrentMidpoint) ~= ValueType or typeof(CurrentTarget) ~= ValueType then
        error("Bezier origin, midpoint, and target must resolve to the same type")
    end

    TroveInstance:Add(UpdateSignals.OnFramePreUpdate:Connect(function()
        if IsSleeping then
            return
        end

        CurrentOrigin = GetValue(Origin)
        CurrentMidpoint = GetValue(Midpoint)
        CurrentTarget = GetValue(Target)
        CurrentAlpha = GetValue(Alpha)

        if typeof(CurrentAlpha) ~= "number" then
            error("Bezier alpha must resolve to a number")
        end

        if typeof(CurrentOrigin) ~= ValueType or typeof(CurrentMidpoint) ~= ValueType or typeof(CurrentTarget) ~= ValueType then
            error("Bezier origin, midpoint, and target must resolve to the same type")
        end

        CurrentValue = GetBezierValue(ClampAlpha(CurrentAlpha), CurrentOrigin, CurrentMidpoint, CurrentTarget, ValueType)

        if IsValueChanged(LastValue, CurrentValue) then
            Batch.Fire(ChangedSignal, "Value")
        end

        LastValue = CurrentValue
        IsSleeping = true
    end))

    local ActiveValue; ActiveValue = setmetatable({
        Destroy = function()
            TroveInstance:Destroy()
            TroveInstance = nil
        end
    }, {
        __index = function(_, Index : string)
            if Index == "__SEAM_OBJECT" then
                return InstanceSymbol
            elseif Index == "Value" then
                if CurrentValue == nil then
                    CurrentValue = GetBezierValue(ClampAlpha(CurrentAlpha), CurrentOrigin, CurrentMidpoint, CurrentTarget, ValueType)
                    LastValue = CurrentValue
                end

                return CurrentValue
            elseif Index == "Changed" then
                return ChangedSignal
            elseif Index == "AttachedToInstance" then
                return AttachedSignal
            elseif Index == "Origin" then
                return Origin
            elseif Index == "Midpoint" then
                return Midpoint
            elseif Index == "Target" then
                return Target
            elseif Index == "Alpha" then
                return Alpha
            end

            return nil
        end,

        __newindex = function(_, Index : string, NewValue : any)
            if Index == "Origin" then
                IsSleeping = false
                Origin = NewValue
            elseif Index == "Midpoint" then
                IsSleeping = false
                Midpoint = NewValue
            elseif Index == "Target" then
                IsSleeping = false
                Target = NewValue
            elseif Index == "Alpha" then
                IsSleeping = false
                Alpha = NewValue
            elseif Index == "Value" then
                IsSleeping = false
                CurrentValue = NewValue
                Origin = NewValue
                Midpoint = NewValue
                Target = NewValue
            end
        end,

        __call = function(This, Object, Index : string)
            AttachedSignal:Fire(Object)

            TroveInstance:Add(StateManager:AttachStateToObject(Object, {
                Value = function()
                    return This.Value
                end,

                PropertyName = Index,
            }))

            return ActiveValue
        end,
    })

    if typeof(Alpha) == "table" and Alpha.__SEAM_OBJECT then
        Alpha(ActiveValue, "Alpha")
    end

    if typeof(Origin) == "table" and Origin.__SEAM_OBJECT then
        Origin(ActiveValue, "Origin")
    end

    if typeof(Midpoint) == "table" and Midpoint.__SEAM_OBJECT then
        Midpoint(ActiveValue, "Midpoint")
    end

    if typeof(Target) == "table" and Target.__SEAM_OBJECT then
        Target(ActiveValue, "Target")
    end

    return ActiveValue :: BezierInstance<any>
end

function Bezier:__index(Index : string)
    if Index == "__SEAM_OBJECT" then
        return ClassSymbol
    elseif Index == "__SEAM_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

local Meta = setmetatable({}, Bezier)

return Meta :: BezierConstructor<any>