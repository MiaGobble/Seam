-- Author: iGottic

--[=[
    @class Spring
    @since 1.0.0
]=]

local Spring = {}

-- Types
type SpringInstance = {
    Value : any,
    Velocity : any,
    Target : any
}

type SpringConstructor = (Value : any, Speed : number, Dampening : number) -> SpringInstance

-- Constants
local EULERS_NUMBER = 2.71828
local EPSILON = 0.001

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local States = script.Parent.Parent
local DependenciesManager = require(Modules.DependenciesManager)
local PackType = require(Modules.PackType)
local UnpackType = require(Modules.UnpackType)
local Computed = require(States.Computed)
local Janitor = require(Modules.Janitor)
local Signal = require(Modules.Signal)

local function GetPositionDerivative(Speed, Dampening, Position0, Coordinate1, Coordinate2, Tick0)
	local Time = os.clock() - Tick0

	if (Dampening >= 1) then
		local EulersFastTime = math.pow(EULERS_NUMBER, (Speed * Time))

		return ((Coordinate1 + Coordinate2 * Speed * Time) / EulersFastTime + Position0), -- POSITION
			((Coordinate2 * Speed * (1 - Time) - Coordinate1) / EulersFastTime) -- VELOCITY
	else
		local High = math.sqrt(1 - Dampening * Dampening)

		local HighSpeedTime = Speed * High * Time
		local DampenedSpeedTime = math.pow(EULERS_NUMBER, Speed * Dampening * Time)
		local SineHighSpeedTime, CosineHighSpeedTime = math.sin(HighSpeedTime), math.cos(HighSpeedTime)

		return ((Coordinate1 * CosineHighSpeedTime + Coordinate2 * SineHighSpeedTime) / DampenedSpeedTime + Position0),  -- POSITION
			(Speed * ((High * Coordinate2 - Dampening * Coordinate1) * CosineHighSpeedTime - (High * Coordinate1 + Dampening * Coordinate1) * SineHighSpeedTime) / DampenedSpeedTime) -- VELOCITY
	end
end

local function ConvertValueToUnpackedSprings(Value : any)
    local ValueType = typeof(Value)
    local UnpackedValue = UnpackType(Value, ValueType)

    for Index, Element in ipairs(UnpackedValue) do
        UnpackedValue[Index] = {Position0 = Element, Coordinate1 = 0, Coordinate2 = 0, Velocity = 0, Tick0 = os.clock()}
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

function Spring:__call(Value : any, Speed : number, Dampening : number) : SpringInstance
    local CurrentTarget = GetValue(Value)
    local ValueType = typeof(CurrentTarget)
    local UnpackedSprings = ConvertValueToUnpackedSprings(CurrentTarget)
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
                return "Spring"
            elseif Index == "Value" then
                local PackedValues = {}

                for Index, Spring in ipairs(UnpackedSprings) do
                    local Position, _ = GetPositionDerivative(Speed, Dampening, Spring.Position0, Spring.Coordinate1, Spring.Coordinate2, Spring.Tick0)

					if math.abs(Position) <= EPSILON then
						Position = 0
					elseif math.abs(Position - Spring.Position0) <= EPSILON then
						Position = Spring.Position0
					end

                    PackedValues[Index] = Position
                end

                ChangedSignal:Fire("Value")

                return PackType(PackedValues, ValueType)
            elseif Index == "Velocity" then
                local PackedValues = {}

                for Index, Spring in ipairs(UnpackedSprings) do
                    local _, Velocity = GetPositionDerivative(Speed, Dampening, Spring.Position0, Spring.Coordinate1, Spring.Coordinate2, Spring.Tick0)

                    PackedValues[Index] = Velocity
                end

                return PackType(PackedValues, ValueType)
            elseif Index == "Changed" then
                return ChangedSignal
            end

            return nil
        end,

        __newindex = function(self, Index : string, NewValue : any)
            if Index == "Target" then
                CurrentTarget = GetValue(NewValue)

                local UnpackedNewValue = UnpackType(CurrentTarget, ValueType)

                for Index, Spring in ipairs(UnpackedSprings) do
                    local Position, Velocity = GetPositionDerivative(Speed, Dampening, Spring.Position0, Spring.Coordinate1, Spring.Coordinate2, Spring.Tick0)

                    Spring.Tick0, Spring.Position0 = os.clock(), UnpackedNewValue[Index]
                    Spring.Coordinate1 = Position - Spring.Position0

                    if (Dampening >= 1) then
                        Spring.Coordinate2 = Spring.Coordinate1 + Velocity / Speed
                    else
                        local High = math.sqrt(1 - Dampening * Dampening)

                        Spring.Coordinate2 = Dampening / High * Spring.Coordinate1 + Velocity / (Speed * High)
                    end
                end
            elseif Index == "Value" then
                local UnpackedNewValue = UnpackType(NewValue, ValueType)

                for Index, Spring in ipairs(UnpackedSprings) do
                    --Spring.Position0 = UnpackedNewValue[Index]
					Spring.Coordinate1, Spring.Coordinate2, Spring.Velocity = UnpackedNewValue[Index] - Spring.Position0, 0, 0
                    Spring.Tick0 = os.clock()
                end
            elseif Index == "Dampening" then
                Dampening = NewValue
            elseif Index == "Speed" then
                Speed = NewValue
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

    return ActiveValue :: SpringInstance
end

--[=[
    @ignore
]=]

function Spring:__index(Index : string)
    if Index == "__SEAM_OBJECT" then
        return "Spring"
    elseif Index == "__SEAM_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

local Meta = setmetatable({}, Spring)

return Meta :: SpringConstructor