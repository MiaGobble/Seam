local Tween = {}

-- Services
local TweenService = game:GetService("TweenService")

-- Imports
local Dependencies = script.Parent.Parent.Parent.Dependencies
local Components = script.Parent.Parent
local PackType = require(Dependencies.PackType)
local UnpackType = require(Dependencies.UnpackType)
local Computed = require(Components.Computed)

local function ConvertValueToUnpackedTweens(Value : any)
    local ValueType = typeof(Value)
    local UnpackedValue = UnpackType(Value, ValueType)

    for Index, Element in ipairs(UnpackedValue) do
        UnpackedValue[Index] = {Position0 = Element, Position1 = Element, Tick0 = os.clock()}
    end

    return UnpackedValue
end

local function GetValue(ValueObject)
    if typeof(ValueObject) == "table" and ValueObject.__SPHI_OBJECT then
        return ValueObject.Value
    else
        return ValueObject
    end
end

function Tween:__call(Value : any, TweenInformation : TweenInfo)
    local CurrentTarget = GetValue(Value)
    local ValueType = typeof(CurrentTarget)
    local UnpackedTweens = ConvertValueToUnpackedTweens(CurrentTarget)

    local ActiveValue = setmetatable({}, {
        __index = function(self, Index : string)
            if Index == "__SPHI_OBJECT" then
                return "Tween"
            elseif Index == "Value" then
                local PackedValues = {}

                for Index, Tween in ipairs(UnpackedTweens) do
                    local Alpha = math.clamp((os.clock() - Tween.Tick0) / TweenInformation.Time, 0, 1)
                    local UnitPosition = TweenService:GetValue(Alpha, TweenInformation.EasingStyle, TweenInformation.EasingDirection)
                    local Position = Tween.Position0 + (Tween.Position1 - Tween.Position0) * UnitPosition

                    PackedValues[Index] = Position
                end

                return PackType(PackedValues, ValueType)
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
            end
        end,

        __call = function(self, Object, Index : string)
            return Computed(function()
                return self.Value
            end)(Object, Index)
        end
    })

    if typeof(Value) == "table" and Value.__SPHI_OBJECT then
        Value(ActiveValue, "Target")
    end

    return ActiveValue
end

--[=[
    @ignore
]=]

function Tween:__index(Index : string)
    if Index == "__SPHI_OBJECT" then
        return "Tween"
    else
        return nil
    end
end

return setmetatable({}, Tween)