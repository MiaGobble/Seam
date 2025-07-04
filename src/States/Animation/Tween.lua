-- Author: iGottic

--[=[
    @class Tween
    @since 1.0.0
]=]

local Tween = {}

-- Types
type TweenInstance = {
    Value : any,
    Target : any
}

type TweenConstructor = (Value : any, TweenInformation : TweenInfo) -> TweenInstance

-- Constants
local EPSILON = 0.001

-- Services
local TweenService = game:GetService("TweenService")

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local States = script.Parent.Parent
local DependenciesManager = require(Modules.DependenciesManager)
local PackType = require(Modules.PackType)
local UnpackType = require(Modules.UnpackType)
local Computed = require(States.Computed)
local Janitor = require(Modules.Janitor)
local Signal = require(Modules.Signal)

local function ConvertValueToUnpackedTweens(Value : any)
    local ValueType = typeof(Value)
    local UnpackedValue = UnpackType(Value, ValueType)

    for Index, Element in ipairs(UnpackedValue) do
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

function Tween:__call(Value : any, TweenInformation : TweenInfo) : TweenInstance
    local CurrentTarget = GetValue(Value)
    local ValueType = typeof(CurrentTarget)
    local UnpackedTweens = ConvertValueToUnpackedTweens(CurrentTarget)
    local JanitorInstance = Janitor.new()
    local ChangedSignal = Signal.new()

    local ActiveValue; ActiveValue = setmetatable({
        Destroy = function(self)
            UnpackedSprings = nil
            JanitorInstance:Destroy()
            JanitorInstance = nil
        end
    }, {
        __index = function(self, Index : string)
            if Index == "__SEAM_OBJECT" then
                return "Tween"
            elseif Index == "Value" then
                local PackedValues = {}

                for Index, Tween in ipairs(UnpackedTweens) do
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

                ChangedSignal:Fire("Value")

                return PackType(PackedValues, ValueType)
             elseif Index == "Changed" then
                return ChangedSignal
            end

            return nil
        end,

        __newindex = function(self, Index : string, NewValue : any)
            if Index == "Target" then
                CurrentTarget = GetValue(NewValue)
                
                local UnpackedTargetValue = UnpackType(CurrentTarget, ValueType)

                for Index, Tween in ipairs(UnpackedTweens) do
                    Tween.Position0 = Tween.Position1
                    Tween.Position1 = UnpackedTargetValue[Index]
                    Tween.Tick0 = os.clock()
                end
            elseif Index == "Value" then
                local UnpackedValue = UnpackType(NewValue, ValueType)

                for Index, Tween in ipairs(UnpackedTweens) do
                    Tween.Position0 = UnpackedValue[Index]
                    Tween.Position1 = UnpackedValue[Index]
                    Tween.Tick0 = os.clock()
                end
            elseif Index == "TweenInformation" then
                TweenInformation = NewValue
            end
        end,

        __call = function(self, Object, Index : string)
            JanitorInstance:Add(DependenciesManager:AttachStateToObject(Object, {
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

    return ActiveValue :: TweenInstance
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

return Meta :: TweenConstructor