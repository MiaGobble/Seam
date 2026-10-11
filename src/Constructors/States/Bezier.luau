local Bezier = {}

-- Imports
local Constructors = script.Parent.Parent
local Modules = Constructors.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Computed = require(script.Parent.Computed)
local Value = require(script.Parent.Value)
local GetValue = require(Constructors.Utilities.GetValue)
local ValuePacker = require(Modules.ValuePacker)
local Bucket = require(Modules.Bucket)
local Signal = require(Modules.Signal)
local Symbol = require(Modules.Symbol)

Bezier.__SEAM_OBJECT = Symbol.new("Bezier")
Bezier.__SEAM_CAN_BE_SCOPED = true

local function ClampAlpha(alphaValue : number) : number
	return math.clamp(alphaValue, 0, 1)
end

local function GetBezierNumber(alphaValue : number, originValue : number, midpointValue : number, targetValue : number) : number
	local InverseAlpha = 1 - alphaValue
	return (InverseAlpha * InverseAlpha * originValue) + (2 * InverseAlpha * alphaValue * midpointValue) + (alphaValue * alphaValue * targetValue)
end

local function GetBezierValue(alphaValue : number, originValue : any, midpointValue : any, targetValue : any, valueType : string) : any
	if valueType == "number" then
		return GetBezierNumber(alphaValue, originValue, midpointValue, targetValue)
	end

	local UnpackedOrigin = ValuePacker.UnpackValue(originValue, valueType)
	local UnpackedMidpoint = ValuePacker.UnpackValue(midpointValue, valueType)
	local UnpackedTarget = ValuePacker.UnpackValue(targetValue, valueType)

	if #UnpackedOrigin == 0 then
		if alphaValue <= 0 then
			return originValue
		elseif alphaValue >= 1 then
			return targetValue
		end

		return midpointValue
	end

	local UnpackedBezier = {}

	for index, originElement in UnpackedOrigin do
		UnpackedBezier[index] = GetBezierNumber(alphaValue, originElement, UnpackedMidpoint[index], UnpackedTarget[index])
	end

	return ValuePacker.PackValue(UnpackedBezier, valueType)
end

function Bezier.__CALLBACK(_ : Types.ConstructorCompiled, alpha : any, origin : any, midpoint : any, target : any) : Types.BezierInstance<any>
	local BucketInstance = Bucket.new()
	local AttachedSignal = Signal.new()
	local AlphaValue = Value(GetValue(alpha))
	local OriginValue = Value(GetValue(origin))
	local MidpointValue = Value(GetValue(midpoint))
	local TargetValue = Value(GetValue(target))
	local ValueType = typeof(OriginValue.Value)
	local ActiveValue : Types.ObjectCompiled

	local function BindInput(source : any, targetState : any)
		if typeof(source) == "table" and source.__SEAM_OBJECT then
			targetState.Value = GetValue(source)

			return source.Changed:Connect(function()
				targetState.Value = GetValue(source)
			end)
		end

		targetState.Value = GetValue(source)
		return nil
	end

	if typeof(AlphaValue.Value) ~= "number" then
		error("Bezier alpha must resolve to a number")
	end

	if typeof(MidpointValue.Value) ~= ValueType or typeof(TargetValue.Value) ~= ValueType then
		error("Bezier origin, midpoint, and target must resolve to the same type")
	end

	local BoundInputConnections = {
		Alpha = BindInput(alpha, AlphaValue),
		Origin = BindInput(origin, OriginValue),
		Midpoint = BindInput(midpoint, MidpointValue),
		Target = BindInput(target, TargetValue),
	}

	local ComputedValue = Computed(function(use)
		local CurrentAlpha = use(AlphaValue)
		local CurrentOrigin = use(OriginValue)
		local CurrentMidpoint = use(MidpointValue)
		local CurrentTarget = use(TargetValue)

		if typeof(CurrentAlpha) ~= "number" then
			error("Bezier alpha must resolve to a number")
		end

		if typeof(CurrentOrigin) ~= ValueType or typeof(CurrentMidpoint) ~= ValueType or typeof(CurrentTarget) ~= ValueType then
			error("Bezier origin, midpoint, and target must resolve to the same type")
		end

		return GetBezierValue(ClampAlpha(CurrentAlpha), CurrentOrigin, CurrentMidpoint, CurrentTarget, ValueType)
	end)

	BucketInstance:Add(AlphaValue)
	BucketInstance:Add(OriginValue)
	BucketInstance:Add(MidpointValue)
	BucketInstance:Add(TargetValue)
	BucketInstance:Add(ComputedValue)
	BucketInstance:Add(ComputedValue.AttachedToInstance:Connect(function(object)
		AttachedSignal:Fire(object)
	end))

	local function RebindInput(key : string, source : any, targetState : any)
		local CurrentConnection = BoundInputConnections[key]

		if CurrentConnection ~= nil then
			if CurrentConnection.Connected then
				CurrentConnection:Disconnect()
			end

			BoundInputConnections[key] = nil
		end

		BoundInputConnections[key] = BindInput(source, targetState)
	end

	local BezierObject : Types.ObjectDecompiled = {
		__SEAM_OBJECT = Symbol.new("Bezier"),
		AttachedToInstance = AttachedSignal,
	}

	function BezierObject.Destroy()
		for _, connection in BoundInputConnections do
			if connection ~= nil and connection.Connected then
				connection:Disconnect()
			end
		end

		table.clear(BoundInputConnections)
		BucketInstance:Destroy()
		BucketInstance = nil
	end

	function BezierObject.__CALLBACK(_ : Types.ObjectCompiled, object : any, index : string)
		ComputedValue(object, index)
		return ActiveValue
	end

	function BezierObject.__INDEX(_ : Types.ObjectCompiled, index : string)
		if index == "Value" then
			return ComputedValue.Value
		elseif index == "Changed" then
			return ComputedValue.Changed
		elseif index == "Origin" then
			return origin
		elseif index == "Midpoint" then
			return midpoint
		elseif index == "Target" then
			return target
		elseif index == "Alpha" then
			return alpha
		end

		return nil
	end

	function BezierObject.__NEWINDEX(_ : Types.ObjectCompiled, index : string, newValue : any)
		if index == "Origin" then
			origin = newValue
			RebindInput("Origin", newValue, OriginValue)
		elseif index == "Midpoint" then
			midpoint = newValue
			RebindInput("Midpoint", newValue, MidpointValue)
		elseif index == "Target" then
			target = newValue
			RebindInput("Target", newValue, TargetValue)
		elseif index == "Alpha" then
			alpha = newValue
			RebindInput("Alpha", newValue, AlphaValue)
		elseif index == "Value" then
			origin = newValue
			midpoint = newValue
			target = newValue
			RebindInput("Origin", newValue, OriginValue)
			RebindInput("Midpoint", newValue, MidpointValue)
			RebindInput("Target", newValue, TargetValue)
		end
	end

	ActiveValue = Compiler.CompileObject(BezierObject)

	return ActiveValue :: Types.BezierInstance<any>
end

return Compiler.CompileConstructor(Bezier) :: Types.BezierConstructor<any>
