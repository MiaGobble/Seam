-- Author: iGottic
-- Based on UnpackType and PackType from Elttob

local ValuePacker = {}

-- Types
type UnpackedValue = {[number]: number}

-- Imports
local Oklab = require(script.Oklab) -- We use Oklab color space to make animating colors look more natural

-- Variables
local Converter : {[string] : {Pack : (UnpackedValue : UnpackedValue) -> any, Unpack : (Value : any) -> UnpackedValue}} = {}

Converter.number = {
	Pack = function(UnpackedValue : UnpackedValue)
		return UnpackedValue[1]
	end,

	Unpack = function(Value : number)
		return {Value}
	end,
}

Converter.CFrame = {
	Pack = function(UnpackedValue : UnpackedValue)
		return CFrame.new(UnpackedValue[1], UnpackedValue[2], UnpackedValue[3]) *
			CFrame.fromAxisAngle(Vector3.new(UnpackedValue[4], UnpackedValue[5], UnpackedValue[6]).Unit, UnpackedValue[7])
	end,

	Unpack = function(Value : CFrame)
		local Axis, Angle = Value:ToAxisAngle()
		return {Value.X, Value.Y, Value.Z, Axis.X, Axis.Y, Axis.Z, Angle}
	end,
}

Converter.Color3 = {
	Pack = function(UnpackedValue : UnpackedValue)
		return Oklab.from(Vector3.new(UnpackedValue[1], UnpackedValue[2], UnpackedValue[3]), false)
	end,

	Unpack = function(Value : Color3)
		local Lab = Oklab.to(Value)
		return {Lab.X, Lab.Y, Lab.Z}
	end,
}

Converter.ColorSequenceKeypoint = {
	Pack = function(UnpackedValue : UnpackedValue)
		return ColorSequenceKeypoint.new(UnpackedValue[4], Oklab.from(Vector3.new(UnpackedValue[1], UnpackedValue[2], UnpackedValue[3]), false))
	end,

	Unpack = function(Value : ColorSequenceKeypoint)
		local Lab = Oklab.to(Value.Value)
		return {Lab.X, Lab.Y, Lab.Z, Value.Time}
	end,
}

Converter.DateTime = {
	Pack = function(UnpackedValue : UnpackedValue)
		return DateTime.fromUnixTimestampMillis(UnpackedValue[1])
	end,

	Unpack = function(Value : DateTime)
		return {Value.UnixTimestampMillis}
	end,
}

Converter.NumberRange = {
	Pack = function(UnpackedValue : UnpackedValue)
		return NumberRange.new(UnpackedValue[1], UnpackedValue[2])
	end,

	Unpack = function(Value : NumberRange)
		return {Value.Min, Value.Max}
	end,
}

Converter.NumberSequenceKeypoint = {
	Pack = function(UnpackedValue : UnpackedValue)
		return NumberSequenceKeypoint.new(UnpackedValue[2], UnpackedValue[1], UnpackedValue[3])
	end,

	Unpack = function(Value : NumberSequenceKeypoint)
		return {Value.Value, Value.Time, Value.Envelope}
	end,
}

Converter.PhysicalProperties = {
	Pack = function(UnpackedValue : UnpackedValue)
		return PhysicalProperties.new(UnpackedValue[1], UnpackedValue[2], UnpackedValue[3], UnpackedValue[4], UnpackedValue[5])
	end,

	Unpack = function(Value : PhysicalProperties)
		return {Value.Density, Value.Friction, Value.Elasticity, Value.FrictionWeight, Value.ElasticityWeight}
	end,
}

Converter.Ray = {
	Pack = function(UnpackedValue : UnpackedValue)
		return Ray.new(
			Vector3.new(UnpackedValue[1], UnpackedValue[2], UnpackedValue[3]),
			Vector3.new(UnpackedValue[4], UnpackedValue[5], UnpackedValue[6])
		)
	end,

	Unpack = function(Value : Ray)
		return {Value.Origin.X, Value.Origin.Y, Value.Origin.Z, Value.Direction.X, Value.Direction.Y, Value.Direction.Z}
	end,
}

Converter.Rect = {
	Pack = function(UnpackedValue : UnpackedValue)
		return Rect.new(UnpackedValue[1], UnpackedValue[2], UnpackedValue[3], UnpackedValue[4])
	end,

	Unpack = function(Value : Rect)
		return {Value.Min.X, Value.Min.Y, Value.Max.X, Value.Max.Y}
	end,
}

Converter.Region3 = {
	Pack = function(UnpackedValue : UnpackedValue)
		local Position = Vector3.new(UnpackedValue[1], UnpackedValue[2], UnpackedValue[3])
		local HalfSize = Vector3.new(UnpackedValue[4] / 2, UnpackedValue[5] / 2, UnpackedValue[6] / 2)

		return Region3.new(Position - HalfSize, Position + HalfSize)
	end,

	Unpack = function(Value : Region3)
		return {Value.CFrame.X, Value.CFrame.Y, Value.CFrame.Z, Value.Size.X, Value.Size.Y, Value.Size.Z}
	end,
}

Converter.Region3int16 = {
	Pack = function(UnpackedValue : UnpackedValue)
		return Region3int16.new(
			Vector3int16.new(UnpackedValue[1], UnpackedValue[2], UnpackedValue[3]),
			Vector3int16.new(UnpackedValue[4], UnpackedValue[5], UnpackedValue[6])
		)
	end,

	Unpack = function(Value : Region3int16)
		return {Value.Min.X, Value.Min.Y, Value.Min.Z, Value.Max.X, Value.Max.Y, Value.Max.Z}
	end,
}

Converter.UDim = {
	Pack = function(UnpackedValue : UnpackedValue)
		return UDim.new(UnpackedValue[1], UnpackedValue[2])
	end,

	Unpack = function(Value : UDim)
		return {Value.Scale, Value.Offset}
	end,
}

Converter.UDim2 = {
	Pack = function(UnpackedValue : UnpackedValue)
		return UDim2.new(UnpackedValue[1], UnpackedValue[2], UnpackedValue[3], UnpackedValue[4])
	end,

	Unpack = function(Value : UDim2)
		return {Value.X.Scale, Value.X.Offset, Value.Y.Scale, Value.Y.Offset}
	end,
}

Converter.Vector2 = {
	Pack = function(UnpackedValue : UnpackedValue)
		return Vector2.new(UnpackedValue[1], UnpackedValue[2])
	end,

	Unpack = function(Value : Vector2)
		return {Value.X, Value.Y}
	end,
}

Converter.Vector2int16 = {
	Pack = function(UnpackedValue : UnpackedValue)
		return Vector2int16.new(UnpackedValue[1], UnpackedValue[2])
	end,

	Unpack = function(Value : Vector2int16)
		return {Value.X, Value.Y}
	end,
}

Converter.Vector3 = {
	Pack = function(UnpackedValue : UnpackedValue)
		return Vector3.new(UnpackedValue[1], UnpackedValue[2], UnpackedValue[3])
	end,

	Unpack = function(Value : Vector3)
		return {Value.X, Value.Y, Value.Z}
	end,
}

Converter.Vector3int16 = {
	Pack = function(UnpackedValue : UnpackedValue)
		return Vector3int16.new(UnpackedValue[1], UnpackedValue[2], UnpackedValue[3])
	end,

	Unpack = function(Value : Vector3int16)
		return {Value.X, Value.Y, Value.Z}
	end,
}

-- Converts a value into a table
function ValuePacker.UnpackValue(Value : any, ValueType : string) : UnpackedValue
	if Converter[ValueType] then
		return Converter[ValueType].Unpack(Value)
	end

	return {}
end

-- Converts a table into a value
function ValuePacker.PackValue(UnpackedValue : UnpackedValue, ValueType : string) : any
	if Converter[ValueType] then
		return Converter[ValueType].Pack(UnpackedValue)
	end

	return nil
end

return ValuePacker