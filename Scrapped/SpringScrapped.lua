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
local EPSILON = 0.0001

-- Services
local RunService = game:GetService("RunService")

-- Imports
local Dependencies = script.Parent.Parent.Parent.Dependencies
local SpringCoefficients = require(Dependencies.SpringCoefficients)

--[[
local function updateAllSprings()
	local springsToSleep: Set<Spring> = {}
	lastUpdateTime = os.clock()

	for spring in pairs(activeSprings) do
		local posPos, posVel, velPos, velVel = springCoefficients(lastUpdateTime - spring._lastSchedule, spring._currentDamping, spring._currentSpeed)

		local positions = spring._springPositions
		local velocities = spring._springVelocities
		local startDisplacements = spring._startDisplacements
		local startVelocities = spring._startVelocities
		local isMoving = false

		for index, goal in ipairs(spring._springGoals) do
			local oldDisplacement = startDisplacements[index]
			local oldVelocity = startVelocities[index]
			local newDisplacement = oldDisplacement * posPos + oldVelocity * posVel
			local newVelocity = oldDisplacement * velPos + oldVelocity * velVel

			if math.abs(newDisplacement) > EPSILON or math.abs(newVelocity) > EPSILON then
				isMoving = true
			end

			positions[index] = newDisplacement + goal
			velocities[index] = newVelocity
		end

		if not isMoving then
			springsToSleep[spring] = true
		end
	end

	for spring in pairs(activeSprings) do
		spring._currentValue = packType(spring._springPositions, spring._currentType)
		updateAll(spring)
	end

	for spring in pairs(springsToSleep) do
		activeSprings[spring] = nil
	end
end
]]

function Spring:__call(InitialValue : any, Speed : number, Dampening : number)
    local self = {}

	local Speed = Speed or 15
	local Dampening = Dampening or 0.5
	local Position0 = InitialValue or 0

	local Coordinate1, Coordinate2 = Mul(Position0, 0), Mul(Position0, 0)
	local Tick0 = os.clock()

	function self:Impulse(Amount : any)
		-- local Position, Velocity = GetPositionDerivative(Speed, Dampening, Position0, Coordinate1, Coordinate2, Tick0)

		-- Tick0, Coordinate1 = os.clock(), Position

		-- if (Dampening >= 1) then
		-- 	--Coordinate2 = Coordinate1 + (Velocity + Amount) / Speed
		-- 	Coordinate2 = Add(Coordinate1, Div(Add(Velocity, Amount), Speed))
		-- else
		-- 	local High = math.sqrt(1 - Dampening * Dampening)

		-- 	--Coordinate2 = Dampening / High * Coordinate1 + (Velocity + Amount) / (Speed * High)
		-- 	Coordinate2 = Add(Div(Coordinate1, High, Dampening), Div(Add(Velocity, Amount), Speed, High))
		-- end
	end

	local Metatable = {}

	function Metatable.__index(_, Index : string)
		Index = string.lower(Index)

		if Index == "value" then
			Index = "position"
		end

		if (Index == "position") then
			return GetPositionDerivative(Speed, Dampening, Position0, Coordinate1, Coordinate2, Tick0)

		elseif (Index == "velocity") then
			local _, Velocity = GetPositionDerivative(Speed, Dampening, Position0, Coordinate1, Coordinate2, Tick0)

			return Velocity

		elseif (Index == "dampen") or (Index == "dampening") then
			return Dampening

		elseif (Index == "speed") then
			return Speed
		elseif (Index == "__sphi_object") then
			return "Spring"
		else
			error("Invalid index: " .. Index)
		end
	end

	function Metatable.__newindex(_, Index : string, Value : any?)
		Index = string.lower(Index)

		if (Index == "dampen") or (Index == "dampening") then
			Dampening = Value

		elseif (Index == "speed") then
			Speed = Value

		elseif (Index == "target") then

		end
	end

	function Metatable:__call(Object : Instance, Index : string)
		local Connection = RunService.RenderStepped:Connect(function()
			local Value = self.position

			if Value == nil then
				warn("Computed value is nil, doing nothing")
				return
			end

			if Object[Index] ~= Value then
				Object[Index] = Value
			end
		end)

		print(Object)

		task.defer(function()
			Object.AncestryChanged:Connect(function()
				if not Object:IsDescendantOf(game) then
					print("spring disconnect")
					Connection:Disconnect()
				end
			end)
		end)
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