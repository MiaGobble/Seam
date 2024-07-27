local Spring = {}

-- Imports
local Dependencies = script.Parent.Parent.Parent.Dependencies
local PackType = require(Dependencies.PackType)
local UnpackType = require(Dependencies.UnpackType)
local SpringCoefficients = require(Dependencies.SpringCoefficients)

-- local posPos, posVel, velPos, velVel = springCoefficients(lastUpdateTime - spring._lastSchedule, spring._currentDamping, spring._currentSpeed)

-- 		local positions = spring._springPositions
-- 		local velocities = spring._springVelocities
-- 		local startDisplacements = spring._startDisplacements
-- 		local startVelocities = spring._startVelocities
-- 		local isMoving = false

-- 		for index, goal in ipairs(spring._springGoals) do
-- 			local oldDisplacement = startDisplacements[index]
-- 			local oldVelocity = startVelocities[index]
-- 			local newDisplacement = oldDisplacement * posPos + oldVelocity * posVel
-- 			local newVelocity = oldDisplacement * velPos + oldVelocity * velVel

-- 			if math.abs(newDisplacement) > EPSILON or math.abs(newVelocity) > EPSILON then
-- 				isMoving = true
-- 			end

-- 			positions[index] = newDisplacement + goal
-- 			velocities[index] = newVelocity
-- 		end

-- 		if not isMoving then
-- 			springsToSleep[spring] = true
-- 		end

local function GetValue(ValueObject)
    if typeof(ValueObject) == "table" and ValueObject.__SPHI_OBJECT then
        return ValueObject.Value
    else
        return ValueObject
    end
end

function Spring:__call(Value : any, Speed : number, Dampening : number)
    local ValuePosition = {Position = GetValue(Value)}
    local OldPosition = table.clone(ValuePosition)
    local InitTime = os.clock()
    local ValueType = typeof(ValuePosition.Position)
    local ValueVelocities = table.create(#UnpackType(ValuePosition.Position, ValueType), 0)

    local ActiveValue = setmetatable({}, {
        __index = function(self, Index : string)
            if Index == "__SPHI_OBJECT" then
                return "Spring"
            elseif Index == "Value" then
                local PositionCoefficient, PositionDxCoefficient, VelocityCoefficient, AccelerationCoefficient = SpringCoefficients(os.clock() - InitTime, Dampening, Speed)
                local UnpackedOldPosition = UnpackType(OldPosition.Position, ValueType)
                local OldVelocities = table.clone(ValueVelocities)
                local NewUnpackedPosition = table.create(#UnpackedOldPosition, 0)
                local NewVelocities = table.create(#OldVelocities, 0)

                for Index, Goal in ipairs(UnpackedOldPosition) do
                    local OldDisplacement = UnpackedOldPosition[Index]
                    local OldVelocity = OldVelocities[Index]
                    local NewDisplacement = OldDisplacement * PositionCoefficient + OldVelocity * PositionDxCoefficient
                    local NewVelocity = OldDisplacement * VelocityCoefficient + OldVelocity * AccelerationCoefficient

                    NewUnpackedPosition[Index] = NewDisplacement + Goal
                    NewVelocities[Index] = NewVelocity
                end

                ValuePosition.Position = PackType(NewUnpackedPosition, ValueType)
                ValueVelocities = NewVelocities

                return ValuePosition.Position
            end
        end,

        __newindex = function(self, Index : string, NewValue : any)
            if Index == "Target" then
                print("new target", NewValue)
                OldPosition = table.clone(ValuePosition)
                ValuePosition.Position = GetValue(NewValue)
                ValueVelocities = table.create(#UnpackType(ValuePosition.Position, ValueType), 0)
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