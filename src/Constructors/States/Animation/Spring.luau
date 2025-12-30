-- Author: iGottic

--[=[
    @class Spring
    @since 0.0.1
]=]

local Spring = {}

-- Constants
local EULERS_NUMBER = 2.71828
local EPSILON = 0.001

-- Services
local RunService = game:GetService("RunService")

-- Imports
local Modules = script.Parent.Parent.Parent.Parent.Modules
local StateManager = require(Modules.StateManager)
local PackType = require(Modules.PackType)
local UnpackType = require(Modules.UnpackType)
local Janitor = require(Modules.Janitor)
local Signal = require(Modules.Signal)
local Types = require(Modules.Types)
local IsValueChanged = require(Modules.IsValueChanged)
local Symbol = require(Modules.Symbol)

-- Variables
local ClassSymbol = Symbol.new("Spring")

-- Types Extended
export type SpringInstance<T> = {
    Velocity : T,
    Target : T
} & Types.BaseState<T>

export type SpringConstructor<T> = (Value : Types.BaseState<T> | any, Speed : number, Dampening : number) -> SpringInstance<T>

local function GetPositionDerivative(Speed, Dampening, Position0, Coordinate1, Coordinate2, Tick0)
    -- I copied this spring math from another module I did a long time ago,
    -- so let's hope it doesn't explode.

	local Time = os.clock() - Tick0

	if (Dampening >= 1) then -- When overdamped or critically damped
		local EulersFastTime = math.pow(EULERS_NUMBER, (Speed * Time))

		return ((Coordinate1 + Coordinate2 * Speed * Time) / EulersFastTime + Position0), -- POSITION
			((Coordinate2 * Speed * (1 - Time) - Coordinate1) / EulersFastTime) -- VELOCITY
	else -- When underdamped
		local High = math.sqrt(1 - Dampening ^ 2)

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

    for Index, Element in UnpackedValue do
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

function Spring:__call(Value : Types.BaseState<any>, Speed : number, Dampening : number) : SpringInstance<any>
    local CurrentTarget = GetValue(Value)
    local ValueType = typeof(CurrentTarget)
    local UnpackedSprings = ConvertValueToUnpackedSprings(CurrentTarget)
    local JanitorInstance = Janitor.new()
    local ChangedSignal = Signal.new()
    local CurrentValue = CurrentTarget
    local LastValue = CurrentTarget
    local InstanceSymbol = Symbol.new("Spring")

    JanitorInstance:Add(RunService.PreRender:Connect(function()
        local PackedValues = {}

        for Index, Spring in UnpackedSprings do
            local Position, _ = GetPositionDerivative(Speed, Dampening, Spring.Position0, Spring.Coordinate1, Spring.Coordinate2, Spring.Tick0)

			if math.abs(Position) <= EPSILON then
				Position = 0
			elseif math.abs(Position - Spring.Position0) <= EPSILON then
				Position = Spring.Position0
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
            UnpackedSprings = nil
            JanitorInstance:Destroy()
            JanitorInstance = nil
        end
    }, {
        __index = function(self, Index : string)
            if Index == "__SEAM_OBJECT" then
                return InstanceSymbol
            elseif Index == "Value" then
                return CurrentValue
            elseif Index == "Velocity" then
                local PackedValues = {}

                for Index, Spring in UnpackedSprings do
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

                for Index, Spring in UnpackedSprings do
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

                for Index, Spring in UnpackedSprings do
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
            JanitorInstance:Add(StateManager:AttachStateToObject(Object, {
                Value = function()
                    ChangedSignal:Fire("Value")
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

    return ActiveValue :: SpringInstance<any>
end

--[=[
    @ignore
]=]

function Spring:__index(Index : string)
    if Index == "__SEAM_OBJECT" then
        return ClassSymbol
    elseif Index == "__SEAM_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

local Meta = setmetatable({}, Spring)

return Meta :: SpringConstructor<any>