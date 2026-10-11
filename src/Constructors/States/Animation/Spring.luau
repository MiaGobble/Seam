local Spring = {}

-- Constants
local EPSILON = 0.001

-- Imports
local Constructors = script.Parent.Parent.Parent
local Modules = Constructors.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Batch = require(Modules.Batch)
local GetValue = require(Constructors.Utilities.GetValue)
local StateManager = require(Modules.StateManager)
local ValuePacker = require(Modules.ValuePacker)
local Bucket = require(Modules.Bucket)
local Signal = require(Modules.Signal)
local IsValueChanged = require(Modules.IsValueChanged)
local Symbol = require(Modules.Symbol)
local UpdateSignals = require(Modules.UpdateSignals)

Spring.__SEAM_OBJECT = Symbol.new("Spring")
Spring.__SEAM_CAN_BE_SCOPED = true

local function GetPositionAndVelocity(oldPosition : number, oldVelocity : number, target : number, dampening : number, speed : number, timeStarted : number) : (number, number)
	local TimePassed = os.clock() - timeStarted
	local TimeValue = TimePassed * speed
	local DampeningSquared = dampening ^ 2
	local HighSpeedTime = nil
	local Cosine = nil
	local Sine = nil

	if DampeningSquared < 1 then
		-- Under dampened

		HighSpeedTime = (1 - DampeningSquared) ^ 0.5

		local EulersFastTime = math.exp(-dampening * TimeValue) / HighSpeedTime
		Cosine = EulersFastTime * math.cos(HighSpeedTime * TimeValue)
		Sine = EulersFastTime * math.sin(HighSpeedTime * TimeValue)
	elseif DampeningSquared == 1 then
		-- Critically dampened

		HighSpeedTime = 1

		local EulersFastTime = math.exp(-dampening * TimeValue)
		Cosine = EulersFastTime
		Sine = EulersFastTime * TimeValue
	else
		-- Over dampened

		HighSpeedTime = (DampeningSquared - 1) ^ 0.5
		Cosine = math.exp((-dampening + HighSpeedTime) * TimeValue) / (2 * HighSpeedTime) + math.exp((-dampening - HighSpeedTime) * TimeValue) / (2 * HighSpeedTime)
		Sine = math.exp((-dampening + HighSpeedTime) * TimeValue) / (2 * HighSpeedTime) - math.exp((-dampening - HighSpeedTime) * TimeValue) / (2 * HighSpeedTime)
	end

	local Value0 = {
		HighSpeedTime * Cosine + dampening * Sine,
		1 - (HighSpeedTime * Cosine + dampening * Sine),
		Sine / speed,
	}

	local Value1 = {
		-speed * Sine,
		speed * Sine,
		HighSpeedTime * Cosine - dampening * Sine,
	}

	local Position = Value0[1] * oldPosition + Value0[2] * target + Value0[3] * oldVelocity
	local Velocity = Value1[1] * oldPosition + Value1[2] * target + Value1[3] * oldVelocity

	return Position, Velocity
end

local function ConvertValueToUnpackedSprings(value : any)
	local ValueType = typeof(value)
	local UnpackedValue = ValuePacker.UnpackValue(value, ValueType)

	for index, element in UnpackedValue do
		UnpackedValue[index] = {
			StartingPosition = element,
			Velocity = 0,
			StartingTime = os.clock(),
			Target = element,
		}
	end

	return UnpackedValue
end

function Spring.__CALLBACK(_ : Types.ConstructorCompiled, value : Types.BaseState<any> | any, speed : Types.BaseState<any> | number, dampening : Types.BaseState<any> | number) : Types.SpringInstance<any>
	local CurrentTarget = GetValue(value)
	local ValueType = typeof(CurrentTarget)
	local UnpackedSprings = ConvertValueToUnpackedSprings(CurrentTarget)
	local BucketInstance = Bucket.new()
	local AttachedSignal = Signal.new()
	local ChangedSignal = Signal.new()
	local CurrentValue = CurrentTarget
	local LastValue = CurrentTarget
	local IsSleeping = false
	local ActiveValue : Types.ObjectCompiled

	BucketInstance:Add(UpdateSignals.OnFramePreUpdate:Connect(function()
		if IsSleeping then
			return
		end

		local PackedValues = {}
		local CurrentDampening = GetValue(dampening)
		local CurrentSpeed = GetValue(speed)
		local IsSettled = true

		-- Each part of a value is separated into separate springs. For example, a Vector3 is three separate springs.
		for index, thisSpring in UnpackedSprings do
			-- Do the math to get position and velocity of spring
			local Position, Velocity = GetPositionAndVelocity(thisSpring.StartingPosition, thisSpring.Velocity, thisSpring.Target, CurrentDampening, CurrentSpeed, thisSpring.StartingTime)

			-- Snap to value based on epsilon to prevent forever retargeting
			if math.abs(Position) <= EPSILON then
				Position = 0
			elseif math.abs(Position - thisSpring.Target) <= EPSILON then
				Position = thisSpring.Target
			end

			-- Prevent sleeping if a spring is still moving
			if math.abs(Position - thisSpring.Target) > EPSILON or math.abs(Velocity) > EPSILON then
				IsSettled = false
			end

			PackedValues[index] = Position
		end

		-- Ensure springs stay frozen after settled and ready to sleep
		if IsSettled then
			for index, thisSpring in UnpackedSprings do
				thisSpring.StartingPosition = thisSpring.Target
				thisSpring.Velocity = 0
				thisSpring.StartingTime = os.clock()
				PackedValues[index] = thisSpring.Target
			end
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

	local SpringObject : Types.ObjectDecompiled = {
		__SEAM_OBJECT = Symbol.new("Spring"),
		Changed = ChangedSignal,
		AttachedToInstance = AttachedSignal,
	}

	function SpringObject.Destroy()
		UnpackedSprings = nil
		BucketInstance:Destroy()
		BucketInstance = nil
	end

	function SpringObject.__CALLBACK(self : Types.ObjectCompiled, object : any, index : string)
		AttachedSignal:Fire(object)

		BucketInstance:Add(StateManager.AttachStateToObject(object, {
			Value = function()
				Batch.Fire(ChangedSignal, "Value")
				return self.Value
			end,

			PropertyName = index,
		}))

		return ActiveValue
	end

	function SpringObject.__INDEX(_ : Types.ObjectCompiled, index : string)
		if index == "Value" then
			return CurrentValue
		elseif index == "Velocity" then
			local PackedValues = {}

			for thisIndex, thisSpring in UnpackedSprings do
				local _, Velocity = GetPositionAndVelocity(thisSpring.StartingPosition, thisSpring.Velocity, thisSpring.Target, GetValue(dampening), GetValue(speed), thisSpring.StartingTime)

				PackedValues[thisIndex] = Velocity
			end

			return ValuePacker.PackValue(PackedValues, ValueType)
		elseif index == "Speed" then
			return speed
		elseif index == "Dampening" then
			return dampening
		end

		return nil
	end

	function SpringObject.__NEWINDEX(_ : Types.ObjectCompiled, index : string, newValue : any)
		if index == "Target" then
			IsSleeping = false
			CurrentTarget = GetValue(newValue)

			local UnpackedNewValue = ValuePacker.UnpackValue(CurrentTarget, ValueType)

			for thisIndex, thisSpring in UnpackedSprings do
				local Position, Velocity = GetPositionAndVelocity(thisSpring.StartingPosition, thisSpring.Velocity, thisSpring.Target, GetValue(dampening), GetValue(speed), thisSpring.StartingTime)

				thisSpring.StartingPosition = Position
				thisSpring.Velocity = Velocity
				thisSpring.StartingTime = os.clock()
				thisSpring.Target = UnpackedNewValue[thisIndex]
			end
		elseif index == "Value" then
			IsSleeping = false
			local UnpackedNewValue = ValuePacker.UnpackValue(newValue, ValueType)

			for thisIndex, thisSpring in UnpackedSprings do
				local _, Velocity = GetPositionAndVelocity(thisSpring.StartingPosition, thisSpring.Velocity, thisSpring.Target, GetValue(dampening), GetValue(speed), thisSpring.StartingTime)

				thisSpring.StartingPosition = UnpackedNewValue[thisIndex]
				thisSpring.Velocity = Velocity
				thisSpring.StartingTime = os.clock()
			end
		elseif index == "Dampening" then
			IsSleeping = false
			dampening = newValue
		elseif index == "Speed" then
			IsSleeping = false
			speed = newValue
		elseif index == "Velocity" then
			IsSleeping = false
			local UnpackedNewValue = ValuePacker.UnpackValue(newValue, ValueType)

			for thisIndex, thisSpring in UnpackedSprings do
				local Position, _ = GetPositionAndVelocity(thisSpring.StartingPosition, thisSpring.Velocity, thisSpring.Target, GetValue(dampening), GetValue(speed), thisSpring.StartingTime)

				thisSpring.Velocity = UnpackedNewValue[thisIndex]
				thisSpring.StartingPosition = Position
				thisSpring.StartingTime = os.clock()
			end
		end
	end

	ActiveValue = Compiler.CompileObject(SpringObject)

	if typeof(value) == "table" and value.__SEAM_OBJECT then
		value(ActiveValue, "Target")
	end

	return ActiveValue :: Types.SpringInstance<any>
end

return Compiler.CompileConstructor(Spring) :: Types.SpringConstructor<any>
