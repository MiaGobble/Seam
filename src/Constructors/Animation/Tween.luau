-- Author: iGottic

--[=[
    @class Tween
    @since 0.0.1
]=]

local Tween = {}

-- Constants
local EPSILON = 0.001

-- Services
local TweenService = game:GetService("TweenService")

-- Services
local RunService = game:GetService("RunService")

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local StateManager = require(Modules.StateManager)
local PackType = require(Modules.PackType)
local UnpackType = require(Modules.UnpackType)
local Janitor = require(Modules.Janitor)
local Signal = require(Modules.Signal)
local Types = require(Modules.Types)
local IsValueChanged = require(Modules.IsValueChanged)

-- Types Extended
export type TweenInstance<T> = {
    Target : T
} & Types.BaseState<T>

export type TweenConstructor<T> = (Value : Types.BaseState<T> | any, TweenInformation : TweenInfo) -> TweenInstance<T>

local function ConvertValueToUnpackedTweens(Value : any)
    local ValueType = typeof(Value)
    local UnpackedValue = UnpackType(Value, ValueType)

    for Index, Element in UnpackedValue do
        UnpackedValue[Index] = {Position0 = Element, Position1 = Element, Tick0 = os.clock()}
    end

    return UnpackedValue
end

local function GetValue(ValueObject)
    if typeof(ValueObject) == "table" and ValueObject.__SEAM_OBJECT then
        return ValueObject.Value
    else
        return ValueObject
    end
end

function Tween:__call(Value : any, TweenInformation : TweenInfo) : TweenInstance<any>
    local CurrentTarget = GetValue(Value)
    local ValueType = typeof(CurrentTarget)
    local UnpackedTweens = ConvertValueToUnpackedTweens(CurrentTarget)
    local JanitorInstance = Janitor.new()
    local ChangedSignal = Signal.new()
    local CurrentValue = CurrentTarget
    local LastValue = CurrentTarget

    JanitorInstance:Add(RunService.RenderStepped:Connect(function()
        local PackedValues = {}

        for Index, Tween in UnpackedTweens do
            local Alpha = math.clamp((os.clock() - Tween.Tick0) / TweenInformation.Time, 0, 1)
            local UnitPosition = TweenService:GetValue(Alpha, TweenInformation.EasingStyle, TweenInformation.EasingDirection)
            local Position = Tween.Position0 + (Tween.Position1 - Tween.Position0) * UnitPosition

            if math.abs(Position) <= EPSILON then
				Position = 0
			elseif math.abs(Position - Tween.Position0) <= EPSILON then
				Position = Tween.Position0
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
        Destroy = function(self)
            UnpackedTweens = nil
            JanitorInstance:Destroy()
            JanitorInstance = nil
        end
    }, {
        __index = function(self, Index : string)
            if Index == "__SEAM_OBJECT" then
                return "Tween"
            elseif Index == "Value" then
                return CurrentValue
            elseif Index == "Changed" then
                return ChangedSignal
            end

            return nil
        end,

        __newindex = function(self, Index : string, NewValue : any)
            if Index == "Target" then
                CurrentTarget = GetValue(NewValue)
                
                local UnpackedTargetValue = UnpackType(CurrentTarget, ValueType)

                for Index, Tween in UnpackedTweens do
                    Tween.Position0 = Tween.Position1
                    Tween.Position1 = UnpackedTargetValue[Index]
                    Tween.Tick0 = os.clock()
                end
            elseif Index == "Value" then
                local UnpackedValue = UnpackType(NewValue, ValueType)

                for Index, Tween in UnpackedTweens do
                    Tween.Position0 = UnpackedValue[Index]
                    Tween.Position1 = UnpackedValue[Index]
                    Tween.Tick0 = os.clock()
                end
            elseif Index == "TweenInformation" then
                TweenInformation = NewValue
            end
        end,

        __call = function(self, Object, Index : string)
            JanitorInstance:Add(StateManager:AttachStateToObject(Object, {
                Value = function()
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

    return ActiveValue :: TweenInstance<any>
end

--[=[
    @ignore
]=]

function Tween:__index(Index : string)
    if Index == "__SEAM_OBJECT" then
        return "Tween"
    elseif Index == "__SEAM_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

local Meta = setmetatable({}, Tween)

return Meta :: TweenConstructor<any>