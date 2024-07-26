--[=[
    Handles spring physics for animations.
    @class Spring
]=]

local Spring = {}

-- Types
type Array<Type> = {[number] : Type}
type Dictionary<Type> = {[string] : Type}

export type SupportedType = Vector3 | Vector3int16 | Vector2 | Vector2int16 | number
export type Spring = {
	Impulse : (self : Spring, Amount : number) -> (),

	Position  : SupportedType,
	Velocity  : number,
	Dampen    : number,
	Dampening : number,
	Speed     : number
}

export type Annotation = {
	New : (InitialValue : SupportedType?, Speed : number?, Dampening : number) -> Spring
}

-- Constants
local EULERS_NUMBER = 2.71828

-- Imports
local Dependencies = script.Parent.Parent.Parent.Dependencies
local UniversalMath = require(Dependencies.UniversalMath)
local Add = UniversalMath.Add
local Sub = UniversalMath.Subtract
local Mul = UniversalMath.Multiply
local Div = UniversalMath.Divide
-- The above imports are abbreviated for the sake of saving space.
-- I hate to abbreviate names, but at the same time this seems like a better solution than having to write out the full path every time.

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

function Spring:__call(InitialValue : any, Speed : number, Dampening : number)
    local self = {}

	local Speed = Speed or 15
	local Dampening = Dampening or 0.5
	local Position0 = InitialValue or 0

	local Coordinate1, Coordinate2 = 0 * Position0, 0 * Position0
	local Tick0 = os.clock()

	function self:Impulse(Amount : number)
		local Position, Velocity = GetPositionDerivative(Speed, Dampening, Position0, Coordinate1, Coordinate2, Tick0)

		Tick0, Coordinate1 = os.clock(), Position

		if (Dampening >= 1) then
			Coordinate2 = Coordinate1 + (Velocity + Amount) / Speed
		else
			local High = math.sqrt(1 - Dampening * Dampening)

			Coordinate2 = Dampening / High * Coordinate1 + (Velocity + Amount) / (Speed * High)
		end
	end

	local Metatable = {}

	function Metatable.__index(_, Index : string)
		Index = string.lower(Index)

		if (Index == "position") then
			return GetPositionDerivative(Speed, Dampening, Position0, Coordinate1, Coordinate2, Tick0)

		elseif (Index == "velocity") then
			local _, Velocity = GetPositionDerivative(Speed, Dampening, Position0, Coordinate1, Coordinate2, Tick0)

			return Velocity

		elseif (Index == "dampen") or (Index == "dampening") then
			return Dampening

		elseif (Index == "speed") then
			return Speed
		end
	end

	function Metatable.__newindex(_, Index : string, Value : any?)
		Index = string.lower(Index)

		if (Index == "dampen") or (Index == "dampening") then
			Dampening = Value

		elseif (Index == "speed") then
			Speed = Value

		elseif (Index == "target") then
			local Position, Velocity = GetPositionDerivative(Speed, Dampening, Position0, Coordinate1, Coordinate2, Tick0)

			Tick0, Position0 = os.clock(), Value
			Coordinate1 = Position - Position0

			if (Dampening >= 1) then
				Coordinate2 = Coordinate1 + Velocity / Speed
			else
				local High = math.sqrt(1 - Dampening * Dampening)

				Coordinate2 = Dampening / High * Coordinate1 + Velocity / (Speed * High)
			end
		end
	end

	return setmetatable(self, Metatable)
end

--[=[
    @ignore
]=]

function Spring:__index(Index : string)
    if Index == "__SPHI_OBJECT" then
        return "Spring"
    end
end

return setmetatable({}, Spring)