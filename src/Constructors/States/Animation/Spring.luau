-- Author: iGottic

local Spring = {}

-- Constants
local EPSILON = 0.001

-- Imports
local Constructors = script.Parent.Parent.Parent
local Modules = Constructors.Parent.Modules
local GetValue = require(Constructors.Utilities.GetValue)
local StateManager = require(Modules.StateManager)
local PackType = require(Modules.PackType)
local UnpackType = require(Modules.UnpackType)
local Trove = require(Modules.Trove)
local Signal = require(Modules.Signal)
local Types = require(Modules.Types)
local IsValueChanged = require(Modules.IsValueChanged)
local Symbol = require(Modules.Symbol)
local UpdateSignals = require(Modules.UpdateSignals)

-- Variables
local ClassSymbol = Symbol.new("Spring")

-- Types Extended
export type SpringInstance<T> = {
    Velocity : T,
    Target : T
} & Types.BaseState<T>

export type SpringConstructor<T> = (Value : Types.BaseState<T> | any, Speed : Types.BaseState<any> | number, Dampening : Types.BaseState<any> | number) -> SpringInstance<T>

local function GetPositionAndVelocity(OldPosition : number, OldVelocity : number, Target : number, Dampening : number, Speed : number, TimeStarted : number) : (number, number)
    local TimePassed = os.clock() - TimeStarted
    local TimeValue = TimePassed * Speed
    local DampeningSquared = Dampening ^ 2
    local HighSpeedTime = nil
    local Cosine = nil
    local Sine = nil

    if DampeningSquared < 1 then
        -- Under dampened

        HighSpeedTime = (1 - DampeningSquared) ^ 0.5

        local EulersFastTime = math.exp(-Dampening * TimeValue) / HighSpeedTime
        Cosine = EulersFastTime * math.cos(HighSpeedTime * TimeValue)
        Sine = EulersFastTime * math.sin(HighSpeedTime * TimeValue)
    elseif DampeningSquared == 1 then
        -- Critically dampened

        HighSpeedTime = 1

        local EulersFastTime = math.exp(-Dampening * TimeValue)
        Cosine = EulersFastTime
        Sine = EulersFastTime * TimeValue
    else
        -- Over dampened

        HighSpeedTime = (DampeningSquared - 1) ^ 0.5
        Cosine = math.exp((-Dampening + HighSpeedTime) * TimeValue) / (2 * HighSpeedTime) + math.exp((-Dampening - HighSpeedTime) * TimeValue) / (2 * HighSpeedTime)
        Sine = math.exp((-Dampening + HighSpeedTime) * TimeValue) / (2 * HighSpeedTime) - math.exp((-Dampening - HighSpeedTime) * TimeValue) / (2 * HighSpeedTime)
    end

    local Value0 = {
        HighSpeedTime * Cosine + Dampening * Sine,
        1 - (HighSpeedTime * Cosine + Dampening * Sine),
        Sine / Speed,
    }

    local Value1 = {
        -Speed * Sine,
        Speed * Sine,
        HighSpeedTime * Cosine - Dampening * Sine,
    }

    local Position = Value0[1] * OldPosition + Value0[2] * Target + Value0[3] * OldVelocity
    local Velocity = Value1[1] * OldPosition + Value1[2] * Target + Value1[3] * OldVelocity

    return Position, Velocity
end

local function ConvertValueToUnpackedSprings(Value : any)
    local ValueType = typeof(Value)
    local UnpackedValue = UnpackType(Value, ValueType)

    for Index, Element in UnpackedValue do
        UnpackedValue[Index] = {
            StartingPosition = Element,
            Velocity = 0,
            StartingTime = os.clock(),
            Target = Element,
        }
    end

    return UnpackedValue
end

function Spring:__call(Value : Types.BaseState<any> | any, Speed : Types.BaseState<any> | number, Dampening : Types.BaseState<any> | number) : SpringInstance<any>
    local CurrentTarget = GetValue(Value)
    local ValueType = typeof(CurrentTarget)
    local UnpackedSprings = ConvertValueToUnpackedSprings(CurrentTarget)
    local TroveInstance = Trove.new()
    local AttachedSignal = Signal.new()
    local ChangedSignal = Signal.new()
    local CurrentValue = CurrentTarget
    local LastValue = CurrentTarget
    local InstanceSymbol = Symbol.new("Spring")

    TroveInstance:Add(UpdateSignals.OnFramePreUpdate:Connect(function()
        local PackedValues = {}

        for Index, Spring in UnpackedSprings do
            local Position, _ = GetPositionAndVelocity(Spring.StartingPosition, Spring.Velocity, Spring.Target, GetValue(Dampening), GetValue(Speed), Spring.StartingTime)

			if math.abs(Position) <= EPSILON then
				Position = 0
			elseif math.abs(Position - Spring.Target) <= EPSILON then
				Position = Spring.Target
			end

            PackedValues[Index] = Position
        end

        CurrentValue = PackType(PackedValues, ValueType)

        if IsValueChanged(LastValue, CurrentValue) then
            ChangedSignal:Fire("Value")
        end

        LastValue = CurrentValue
    end))

    local ActiveValue; ActiveValue = setmetatable({
        Destroy = function()
            UnpackedSprings = nil
            TroveInstance:Destroy()
            TroveInstance = nil
        end
    }, {
        __index = function(_, Index : string)
            if Index == "__SEAM_OBJECT" then
                return InstanceSymbol
            elseif Index == "Value" then
                return CurrentValue
            elseif Index == "Velocity" then
                local PackedValues = {}

                for Index, Spring in UnpackedSprings do
                    local _, Velocity = GetPositionAndVelocity(Spring.StartingPosition, Spring.Velocity, Spring.Target, GetValue(Dampening), GetValue(Speed), Spring.StartingTime)

                    PackedValues[Index] = Velocity
                end

                return PackType(PackedValues, ValueType)
            elseif Index == "Changed" then
                return ChangedSignal
            elseif Index == "AttachedToInstance" then
                return AttachedSignal
            elseif Index == "Speed" then
                return Speed
            elseif Index == "Dampening" then
                return Dampening
            end

            return nil
        end,

        __newindex = function(self, Index : string, NewValue : any)
            if Index == "Target" then
                CurrentTarget = GetValue(NewValue)

                local UnpackedNewValue = UnpackType(CurrentTarget, ValueType)

                for Index, Spring in UnpackedSprings do
                    local Position, Velocity = GetPositionAndVelocity(Spring.StartingPosition, Spring.Velocity, Spring.Target, GetValue(Dampening), GetValue(Speed), Spring.StartingTime)

                    Spring.StartingPosition = Position
                    Spring.Velocity = Velocity
                    Spring.StartingTime = os.clock()
                    Spring.Target = UnpackedNewValue[Index]
                end
            elseif Index == "Value" then
                local UnpackedNewValue = UnpackType(NewValue, ValueType)

                for Index, Spring in UnpackedSprings do
                    local _, Velocity = GetPositionAndVelocity(Spring.StartingPosition, Spring.Velocity, Spring.Target, GetValue(Dampening), GetValue(Speed), Spring.StartingTime)

                    Spring.StartingPosition = UnpackedNewValue[Index]
                    Spring.Velocity = Velocity
                    Spring.StartingTime = os.clock()
                end
            elseif Index == "Dampening" then
                Dampening = NewValue
            elseif Index == "Speed" then
                Speed = NewValue
            elseif Index == "Velocity" then
                local UnpackedNewValue = UnpackType(NewValue, ValueType)

                for Index, Spring in UnpackedSprings do
                    local Position, _ = GetPositionAndVelocity(Spring.StartingPosition, Spring.Velocity, Spring.Target, GetValue(Dampening), GetValue(Speed), Spring.StartingTime)

                    Spring.Velocity = UnpackedNewValue[Index]
                    Spring.StartingPosition = Position
                    Spring.StartingTime = os.clock()
                end
            end
        end,

        __call = function(self, Object, Index : string)
            AttachedSignal:Fire(Object)
            
            TroveInstance:Add(StateManager:AttachStateToObject(Object, {
                Value = function()
                    ChangedSignal:Fire("Value")
                    return self.Value
                end,

                PropertyName = Index
            }))

            return ActiveValue
        end
    })

    if typeof(Value) == "table" and Value.__SEAM_OBJECT then
        Value(ActiveValue, "Target")
    end

    return ActiveValue :: SpringInstance<any>
end

function Spring:__index(Index : string)
    if Index == "__SEAM_OBJECT" then
        return ClassSymbol
    elseif Index == "__SEAM_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

local Meta = setmetatable({}, Spring)

return Meta :: SpringConstructor<any>