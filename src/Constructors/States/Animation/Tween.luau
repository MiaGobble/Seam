-- Author: iGottic

-- Constants
local EPSILON = 0.001

-- Services
local TweenService = game:GetService("TweenService")

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
local Tween : Types.ConstructorDecompiled = {}

Tween.__SEAM_OBJECT = Symbol.new("Tween")
Tween.__SEAM_CAN_BE_SCOPED = true

local function ConvertValueToUnpackedTweens(Value : any)
    local ValueType = typeof(Value)
    local UnpackedValue = ValuePacker.UnpackValue(Value, ValueType)

    for Index, Element in UnpackedValue do
        UnpackedValue[Index] = {Position0 = Element, Position1 = Element, Tick0 = os.clock()}
    end

    return UnpackedValue
end

local function GetTweenPosition(ThisTween : any, ThisTweenInformation : TweenInfo)
    local Alpha = math.clamp((os.clock() - ThisTween.Tick0) / ThisTweenInformation.Time, 0, 1)
    local UnitPosition = TweenService:GetValue(Alpha, ThisTweenInformation.EasingStyle, ThisTweenInformation.EasingDirection)
    local Position = ThisTween.Position0 + (ThisTween.Position1 - ThisTween.Position0) * UnitPosition

    if math.abs(Position) <= EPSILON then
        Position = 0
    elseif math.abs(Position - ThisTween.Position0) <= EPSILON then
        Position = ThisTween.Position0
    end

    return Position, Alpha
end

function Tween.__CALLBACK(_: Types.ConstructorCompiled, Value : any, TweenInformation : Types.BaseState<any> | TweenInfo) : Types.TweenInstance<any>
    local CurrentTarget = GetValue(Value)
    local ValueType = typeof(CurrentTarget)
    local UnpackedTweens = ConvertValueToUnpackedTweens(CurrentTarget)
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
        local CurrentTweenInformation = GetValue(TweenInformation)
        local IsSettled = true

        for Index, ThisTween in UnpackedTweens do
            local Position, Alpha = GetTweenPosition(ThisTween, CurrentTweenInformation)

            if Alpha < 1 or math.abs(Position - ThisTween.Position1) > EPSILON then
                IsSettled = false
            end

            PackedValues[Index] = Position
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

    local TweenObject : Types.ObjectDecompiled = {
        __SEAM_OBJECT = Symbol.new("Tween"),
        Changed = ChangedSignal,
        AttachedToInstance = AttachedSignal,
    }

    function TweenObject.Destroy()
        UnpackedTweens = nil
        TroveInstance:Destroy()
        TroveInstance = nil
    end

    function TweenObject.__CALLBACK(This : Types.ObjectCompiled, Object : any, Index : string)
        AttachedSignal:Fire(Object)

        TroveInstance:Add(StateManager:AttachStateToObject(Object, {
            Value = function()
                return This.Value
            end,

            PropertyName = Index
        }))

        return ActiveValue
    end

    function TweenObject.__INDEX(_: Types.ObjectCompiled, Index : string)
        if Index == "Value" then
            return CurrentValue
        elseif Index == "TweenInfo" then
            return TweenInformation
        end

        return nil
    end

    function TweenObject.__NEWINDEX(_: Types.ObjectCompiled, Index : string, NewValue : any)
        if Index == "Target" then
            IsSleeping = false
            CurrentTarget = GetValue(NewValue)
            local CurrentTweenInformation = GetValue(TweenInformation)

            local UnpackedTargetValue = ValuePacker.UnpackValue(CurrentTarget, ValueType)

            for ThisIndex, ThisTween in UnpackedTweens do
                local CurrentPosition = GetTweenPosition(ThisTween, CurrentTweenInformation)
                ThisTween.Position0 = CurrentPosition
                ThisTween.Position1 = UnpackedTargetValue[ThisIndex]
                ThisTween.Tick0 = os.clock()
            end
        elseif Index == "Value" then
            IsSleeping = false
            local UnpackedValue = ValuePacker.UnpackValue(NewValue, ValueType)

            for ThisIndex, ThisTween in UnpackedTweens do
                ThisTween.Position0 = UnpackedValue[ThisIndex]
                ThisTween.Position1 = UnpackedValue[ThisIndex]
                ThisTween.Tick0 = os.clock()
            end
        elseif Index == "TweenInfo" then
            IsSleeping = false
            TweenInformation = NewValue
        end
    end

    ActiveValue = Compiler.CompileObject(TweenObject)

    if typeof(Value) == "table" and Value.__SEAM_OBJECT then
        Value(ActiveValue, "Target")
    end

    return ActiveValue :: Types.TweenInstance<any>
end

return Compiler.CompileConstructor(Tween) :: Types.TweenConstructor<any>
