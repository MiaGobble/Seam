-- Author: iGottic

local Tween = {}

-- Constants
local EPSILON = 0.001

-- Services
local TweenService = game:GetService("TweenService")

-- Imports
local Constructors = script.Parent.Parent.Parent
local Modules = Constructors.Parent.Modules
local GetValue = require(Constructors.Utilities.GetValue)
local StateManager = require(Modules.StateManager)
local ValuePacker = require(Modules.ValuePacker)
local Trove = require(Modules.Trove)
local Signal = require(Modules.Signal)
local Types = require(Modules.Types)
local IsValueChanged = require(Modules.IsValueChanged)
local Symbol = require(Modules.Symbol)
local UpdateSignals = require(Modules.UpdateSignals)

-- Variables
local ClassSymbol = Symbol.new("Tween")

-- Types Extended
export type TweenInstance<T> = {
    Target : T
} & Types.BaseState<T>

export type TweenConstructor<T> = (Value : Types.BaseState<T> | any, TweenInformation : Types.BaseState<T> | TweenInfo) -> TweenInstance<T>

local function ConvertValueToUnpackedTweens(Value : any)
    local ValueType = typeof(Value)
    local UnpackedValue = ValuePacker.UnpackValue(Value, ValueType)

    for Index, Element in UnpackedValue do
        UnpackedValue[Index] = {Position0 = Element, Position1 = Element, Tick0 = os.clock()}
    end

    return UnpackedValue
end

function Tween:__call(Value : any, TweenInformation : Types.BaseState<any> | TweenInfo) : TweenInstance<any>
    local CurrentTarget = GetValue(Value)
    local ValueType = typeof(CurrentTarget)
    local UnpackedTweens = ConvertValueToUnpackedTweens(CurrentTarget)
    local TroveInstance = Trove.new()
    local AttachedSignal = Signal.new()
    local ChangedSignal = Signal.new()
    local CurrentValue = CurrentTarget
    local LastValue = CurrentTarget
    local InstanceSymbol = Symbol.new("Tween")

    TroveInstance:Add(UpdateSignals.OnFramePreUpdate:Connect(function()
        local PackedValues = {}
        local CurrentTweenInformation = GetValue(TweenInformation)

        for Index, ThisTween in UnpackedTweens do
            local Alpha = math.clamp((os.clock() - ThisTween.Tick0) / CurrentTweenInformation.Time, 0, 1)
            local UnitPosition = TweenService:GetValue(Alpha, CurrentTweenInformation.EasingStyle, CurrentTweenInformation.EasingDirection)
            local Position = ThisTween.Position0 + (ThisTween.Position1 - ThisTween.Position0) * UnitPosition

            if math.abs(Position) <= EPSILON then
				Position = 0
            elseif math.abs(Position - ThisTween.Position0) <= EPSILON then
				Position = ThisTween.Position0
			end

            PackedValues[Index] = Position
        end

        CurrentValue = ValuePacker.PackValue(PackedValues, ValueType)

        if IsValueChanged(LastValue, CurrentValue) then
            ChangedSignal:Fire("Value")
        end

        LastValue = CurrentValue
    end))

    local ActiveValue; ActiveValue = setmetatable({
        Destroy = function()
            UnpackedTweens = nil
            TroveInstance:Destroy()
            TroveInstance = nil
        end
    }, {
        __index = function(_, Index : string)
            if Index == "__SEAM_OBJECT" then
                return InstanceSymbol
            elseif Index == "Value" then
                return CurrentValue
            elseif Index == "Changed" then
                return ChangedSignal
            elseif Index == "AttachedToInstance" then
                return AttachedSignal
            elseif Index == "TweenInfo" then
                return TweenInformation
            end

            return nil
        end,

        __newindex = function(_, Index : string, NewValue : any)
            if Index == "Target" then
                CurrentTarget = GetValue(NewValue)
                
                local UnpackedTargetValue = ValuePacker.UnpackValue(CurrentTarget, ValueType)

                for ThisIndex, ThisTween in UnpackedTweens do
                    ThisTween.Position0 = ThisTween.Position1
                    ThisTween.Position1 = UnpackedTargetValue[ThisIndex]
                    ThisTween.Tick0 = os.clock()
                end
            elseif Index == "Value" then
                local UnpackedValue = ValuePacker.UnpackValue(NewValue, ValueType)

                for ThisIndex, ThisTween in UnpackedTweens do
                    ThisTween.Position0 = UnpackedValue[ThisIndex]
                    ThisTween.Position1 = UnpackedValue[ThisIndex]
                    ThisTween.Tick0 = os.clock()
                end
            elseif Index == "TweenInfo" then
                TweenInformation = NewValue
            end
        end,

        __call = function(This, Object, Index : string)
            AttachedSignal:Fire(Object)
            
            TroveInstance:Add(StateManager:AttachStateToObject(Object, {
                Value = function()
                    return This.Value
                end,

                PropertyName = Index
            }))

            return ActiveValue
        end
    })

    if typeof(Value) == "table" and Value.__SEAM_OBJECT then
        Value(ActiveValue, "Target")
    end

    return ActiveValue :: TweenInstance<any>
end

function Tween:__index(Index : string)
    if Index == "__SEAM_OBJECT" then
        return ClassSymbol
    elseif Index == "__SEAM_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

local Meta = setmetatable({}, Tween)

return Meta :: TweenConstructor<any>