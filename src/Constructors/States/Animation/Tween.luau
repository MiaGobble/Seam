local Tween = {}

-- Constants
local EPSILON = 0.001

-- Services
local TweenService = game:GetService("TweenService")

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

Tween.__SEAM_OBJECT = Symbol.new("Tween")
Tween.__SEAM_CAN_BE_SCOPED = true

local function ConvertValueToUnpackedTweens(value : any)
	local ValueType = typeof(value)
	local UnpackedValue = ValuePacker.UnpackValue(value, ValueType)

	for index, element in UnpackedValue do
		UnpackedValue[index] = {Position0 = element, Position1 = element, Tick0 = os.clock(),}
	end

	return UnpackedValue
end

local function GetTweenPosition(thisTween : any, thisTweenInformation : TweenInfo)
	local Alpha = math.clamp((os.clock() - thisTween.Tick0) / thisTweenInformation.Time, 0, 1)
	local UnitPosition = TweenService:GetValue(Alpha, thisTweenInformation.EasingStyle, thisTweenInformation.EasingDirection)
	local Position = thisTween.Position0 + (thisTween.Position1 - thisTween.Position0) * UnitPosition

	if math.abs(Position) <= EPSILON then
		Position = 0
	elseif math.abs(Position - thisTween.Position0) <= EPSILON then
		Position = thisTween.Position0
	end

	return Position, Alpha
end

function Tween.__CALLBACK(_ : Types.ConstructorCompiled, value : any, tweenInformation : Types.BaseState<any> | TweenInfo) : Types.TweenInstance<any>
	local CurrentTarget = GetValue(value)
	local ValueType = typeof(CurrentTarget)
	local UnpackedTweens = ConvertValueToUnpackedTweens(CurrentTarget)
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
		local CurrentTweenInformation = GetValue(tweenInformation)
		local IsSettled = true

		-- Each part of a value is separated into separate tweens, just like springs. For example, a Vector3 is three separate tweens.
		for index, thisTween in UnpackedTweens do
			local Position, Alpha = GetTweenPosition(thisTween, CurrentTweenInformation)

			-- Snap to value based on epsilon to prevent forever retargeting
			if Alpha < 1 or math.abs(Position - thisTween.Position1) > EPSILON then
				IsSettled = false
			end

			PackedValues[index] = Position
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

	local TweenObject : Types.ObjectDecompiled = {
		__SEAM_OBJECT = Symbol.new("Tween"),
		Changed = ChangedSignal,
		AttachedToInstance = AttachedSignal,
	}

	function TweenObject.Destroy()
		UnpackedTweens = nil
		BucketInstance:Destroy()
		BucketInstance = nil
	end

	function TweenObject.__CALLBACK(self : Types.ObjectCompiled, object : any, index : string)
		AttachedSignal:Fire(object)

		BucketInstance:Add(StateManager.AttachStateToObject(object, {
			Value = function()
				return self.Value
			end,

			PropertyName = index,
		}))

		return ActiveValue
	end

	function TweenObject.__INDEX(_ : Types.ObjectCompiled, index : string)
		if index == "Value" then
			return CurrentValue
		elseif index == "TweenInfo" then
			return tweenInformation
		end

		return nil
	end

	function TweenObject.__NEWINDEX(_ : Types.ObjectCompiled, index : string, newValue : any)
		if index == "Target" then
			IsSleeping = false
			CurrentTarget = GetValue(newValue)
			local CurrentTweenInformation = GetValue(tweenInformation)

			local UnpackedTargetValue = ValuePacker.UnpackValue(CurrentTarget, ValueType)

			for thisIndex, thisTween in UnpackedTweens do
				local CurrentPosition = GetTweenPosition(thisTween, CurrentTweenInformation)
				thisTween.Position0 = CurrentPosition
				thisTween.Position1 = UnpackedTargetValue[thisIndex]
				thisTween.Tick0 = os.clock()
			end
		elseif index == "Value" then
			IsSleeping = false
			local UnpackedValue = ValuePacker.UnpackValue(newValue, ValueType)

			for thisIndex, thisTween in UnpackedTweens do
				thisTween.Position0 = UnpackedValue[thisIndex]
				thisTween.Position1 = UnpackedValue[thisIndex]
				thisTween.Tick0 = os.clock()
			end
		elseif index == "TweenInfo" then
			IsSleeping = false
			tweenInformation = newValue
		end
	end

	ActiveValue = Compiler.CompileObject(TweenObject)

	if typeof(value) == "table" and value.__SEAM_OBJECT then
		value(ActiveValue, "Target")
	end

	return ActiveValue :: Types.TweenInstance<any>
end

return Compiler.CompileConstructor(Tween) :: Types.TweenConstructor<any>
