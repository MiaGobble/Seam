local Spring = {}

-- Constants
local EULERS_NUMBER = 2.71828

-- Imports
local Dependencies = script.Parent.Parent.Parent.Dependencies
local PackType = require(Dependencies.PackType)
local UnpackType = require(Dependencies.UnpackType)

local function GetPositionDerivative(Speed, Dampening, Position0, Coordinate1, Coordinate2, Tick0)
	-- This returns position and instantaneous velocity
	-- The first derivative of position is velocity

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
        UnpackedValue[Index] = {Position0 = Element, Coordinate1 = Element, Coordinate2 = Element, Velocity = 0, Tick0 = os.clock()}
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

function Spring:__call(Value : any, Speed : number, Dampening : number)
    local CurrentTarget = GetValue(Value)
    local ValueType = typeof(CurrentTarget)
    local UnpackedSprings = ConvertValueToUnpackedSprings(CurrentTarget)

    local ActiveValue = setmetatable({}, {
        __index = function(self, Index : string)
            if Index == "__SPHI_OBJECT" then
                return "Spring"
            elseif Index == "Value" then
                local PackedValues = {}

                for Index, Spring in ipairs(UnpackedSprings) do
                    local Position, Velocity = GetPositionDerivative(Speed, Dampening, Spring.Position0, Spring.Coordinate1, Spring.Coordinate2, Spring.Tick0)

                    PackedValues[Index] = Position
                end

                return PackType(PackedValues, ValueType)
            end
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
            end
        end,

        __call = function(self, Object, Index : string)
            
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

function Spring:__index(Index : string)
    if Index == "__SPHI_OBJECT" then
        return "Spring"
    else
        return nil
    end
end

return setmetatable({}, Spring)