-- Author: iGottic

-- Constants
local EPSILON = 0.001

-- Imports
local Constructors = script.Parent.Parent.Parent
local Modules = Constructors.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Batch = require(Modules.Batch)
local GetValue = require(Constructors.Utilities.GetValue)
local StateManager = require(Modules.StateManager)
local ValuePacker = require(Modules.ValuePacker)
local Trove = require(Modules.Trove)
local Signal = require(Modules.Signal)
local IsValueChanged = require(Modules.IsValueChanged)
local Symbol = require(Modules.Symbol)
local UpdateSignals = require(Modules.UpdateSignals)

-- Class
local Spring : Types.ConstructorDecompiled = {}

Spring.__SEAM_OBJECT = Symbol.new("Spring")
Spring.__SEAM_CAN_BE_SCOPED = true

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
    local UnpackedValue = ValuePacker.UnpackValue(Value, ValueType)

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

function Spring.__CALLBACK(_: Types.ConstructorCompiled, Value : Types.BaseState<any> | any, Speed : Types.BaseState<any> | number, Dampening : Types.BaseState<any> | number) : Types.SpringInstance<any>
    local CurrentTarget = GetValue(Value)
    local ValueType = typeof(CurrentTarget)
    local UnpackedSprings = ConvertValueToUnpackedSprings(CurrentTarget)
    local TroveInstance = Trove.new()
    local AttachedSignal = Signal.new()
    local ChangedSignal = Signal.new()
    local CurrentValue = CurrentTarget
    local LastValue = CurrentTarget
    local IsSleeping = false
    local ActiveValue : Types.ObjectCompiled

    TroveInstance:Add(UpdateSignals.OnFramePreUpdate:Connect(function()
        if IsSleeping then
            return
        end

        local PackedValues = {}
        local CurrentDampening = GetValue(Dampening)
        local CurrentSpeed = GetValue(Speed)
        local IsSettled = true

        for Index, ThisSpring in UnpackedSprings do
            local Position, Velocity = GetPositionAndVelocity(ThisSpring.StartingPosition, ThisSpring.Velocity, ThisSpring.Target, CurrentDampening, CurrentSpeed, ThisSpring.StartingTime)

			if math.abs(Position) <= EPSILON then
				Position = 0
			elseif math.abs(Position - ThisSpring.Target) <= EPSILON then
				Position = ThisSpring.Target
			end

            if math.abs(Position - ThisSpring.Target) > EPSILON or math.abs(Velocity) > EPSILON then
                IsSettled = false
            end

            PackedValues[Index] = Position
        end

        if IsSettled then
            for Index, ThisSpring in UnpackedSprings do
                ThisSpring.StartingPosition = ThisSpring.Target
                ThisSpring.Velocity = 0
                ThisSpring.StartingTime = os.clock()
                PackedValues[Index] = ThisSpring.Target
            end
        end

        CurrentValue = ValuePacker.PackValue(PackedValues, ValueType)

        if IsValueChanged(LastValue, CurrentValue) then
            Batch.Fire(ChangedSignal, "Value")
        end

        LastValue = CurrentValue

        if IsSettled then
            IsSleeping = true
        end
    end))

    local SpringObject : Types.ObjectDecompiled = {
        __SEAM_OBJECT = Symbol.new("Spring"),
        Changed = ChangedSignal,
        AttachedToInstance = AttachedSignal,
    }

    function SpringObject.Destroy()
        UnpackedSprings = nil
        TroveInstance:Destroy()
        TroveInstance = nil
    end

    function SpringObject.__CALLBACK(This : Types.ObjectCompiled, Object : any, Index : string)
        AttachedSignal:Fire(Object)

        TroveInstance:Add(StateManager:AttachStateToObject(Object, {
            Value = function()
                Batch.Fire(ChangedSignal, "Value")
                return This.Value
            end,

            PropertyName = Index
        }))

        return ActiveValue
    end

    function SpringObject.__INDEX(_: Types.ObjectCompiled, Index : string)
        if Index == "Value" then
            return CurrentValue
        elseif Index == "Velocity" then
            local PackedValues = {}

            for ThisIndex, ThisSpring in UnpackedSprings do
                local _, Velocity = GetPositionAndVelocity(ThisSpring.StartingPosition, ThisSpring.Velocity, ThisSpring.Target, GetValue(Dampening), GetValue(Speed), ThisSpring.StartingTime)

                PackedValues[ThisIndex] = Velocity
            end

            return ValuePacker.PackValue(PackedValues, ValueType)
        elseif Index == "Speed" then
            return Speed
        elseif Index == "Dampening" then
            return Dampening
        end

        return nil
    end

    function SpringObject.__NEWINDEX(_: Types.ObjectCompiled, Index : string, NewValue : any)
        if Index == "Target" then
            IsSleeping = false
            CurrentTarget = GetValue(NewValue)

            local UnpackedNewValue = ValuePacker.UnpackValue(CurrentTarget, ValueType)

            for ThisIndex, ThisSpring in UnpackedSprings do
                local Position, Velocity = GetPositionAndVelocity(ThisSpring.StartingPosition, ThisSpring.Velocity, ThisSpring.Target, GetValue(Dampening), GetValue(Speed), ThisSpring.StartingTime)

                ThisSpring.StartingPosition = Position
                ThisSpring.Velocity = Velocity
                ThisSpring.StartingTime = os.clock()
                ThisSpring.Target = UnpackedNewValue[ThisIndex]
            end
        elseif Index == "Value" then
            IsSleeping = false
            local UnpackedNewValue = ValuePacker.UnpackValue(NewValue, ValueType)

            for ThisIndex, ThisSpring in UnpackedSprings do
                local _, Velocity = GetPositionAndVelocity(ThisSpring.StartingPosition, ThisSpring.Velocity, ThisSpring.Target, GetValue(Dampening), GetValue(Speed), ThisSpring.StartingTime)

                ThisSpring.StartingPosition = UnpackedNewValue[ThisIndex]
                ThisSpring.Velocity = Velocity
                ThisSpring.StartingTime = os.clock()
            end
        elseif Index == "Dampening" then
            IsSleeping = false
            Dampening = NewValue
        elseif Index == "Speed" then
            IsSleeping = false
            Speed = NewValue
        elseif Index == "Velocity" then
            IsSleeping = false
            local UnpackedNewValue = ValuePacker.UnpackValue(NewValue, ValueType)

            for ThisIndex, ThisSpring in UnpackedSprings do
                local Position, _ = GetPositionAndVelocity(ThisSpring.StartingPosition, ThisSpring.Velocity, ThisSpring.Target, GetValue(Dampening), GetValue(Speed), ThisSpring.StartingTime)

                ThisSpring.Velocity = UnpackedNewValue[ThisIndex]
                ThisSpring.StartingPosition = Position
                ThisSpring.StartingTime = os.clock()
            end
        end
    end

    ActiveValue = Compiler.CompileObject(SpringObject)

    if typeof(Value) == "table" and Value.__SEAM_OBJECT then
        Value(ActiveValue, "Target")
    end

    return ActiveValue :: Types.SpringInstance<any>
end

return Compiler.CompileConstructor(Spring) :: Types.SpringConstructor<any>