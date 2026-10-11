-- Based on UnpackType and PackType from Elttob

local ValuePacker = {}

-- Types
type UnpackedValue = {[number] : number}

-- Imports
local Oklab = require(script.Oklab) -- We use Oklab color space to make animating colors look more natural

-- Variables
local Converter : {[string] : {Pack : (unpackedValue : UnpackedValue) -> any, Unpack : (value : any) -> UnpackedValue}} = {}

Converter.number = {
	Pack = function(unpackedValue : UnpackedValue)
		return unpackedValue[1]
	end,

	Unpack = function(value : number)
		return {value}
	end,
}

Converter.CFrame = {
	Pack = function(unpackedValue : UnpackedValue)
		return CFrame.new(unpackedValue[1], unpackedValue[2], unpackedValue[3]) *
			CFrame.fromAxisAngle(Vector3.new(unpackedValue[4], unpackedValue[5], unpackedValue[6]).Unit, unpackedValue[7])
	end,

	Unpack = function(value : CFrame)
		local Axis, Angle = value:ToAxisAngle()
		return {value.X, value.Y, value.Z, Axis.X, Axis.Y, Axis.Z, Angle}
	end,
}

Converter.Color3 = {
	Pack = function(unpackedValue : UnpackedValue)
		return Oklab.FromOklab(Vector3.new(unpackedValue[1], unpackedValue[2], unpackedValue[3]), false)
	end,

	Unpack = function(value : Color3)
		local Lab = Oklab.ToOklab(value)
		return {Lab.X, Lab.Y, Lab.Z}
	end,
}

Converter.ColorSequenceKeypoint = {
	Pack = function(unpackedValue : UnpackedValue)
		return ColorSequenceKeypoint.new(unpackedValue[4], Oklab.FromOklab(Vector3.new(unpackedValue[1], unpackedValue[2], unpackedValue[3]), false))
	end,

	Unpack = function(value : ColorSequenceKeypoint)
		local Lab = Oklab.ToOklab(value.Value)
		return {Lab.X, Lab.Y, Lab.Z, value.Time}
	end,
}

Converter.DateTime = {
	Pack = function(unpackedValue : UnpackedValue)
		return DateTime.fromUnixTimestampMillis(unpackedValue[1])
	end,

	Unpack = function(value : DateTime)
		return {value.UnixTimestampMillis}
	end,
}

Converter.NumberRange = {
	Pack = function(unpackedValue : UnpackedValue)
		return NumberRange.new(unpackedValue[1], unpackedValue[2])
	end,

	Unpack = function(value : NumberRange)
		return {value.Min, value.Max}
	end,
}

Converter.NumberSequenceKeypoint = {
	Pack = function(unpackedValue : UnpackedValue)
		return NumberSequenceKeypoint.new(unpackedValue[2], unpackedValue[1], unpackedValue[3])
	end,

	Unpack = function(value : NumberSequenceKeypoint)
		return {value.Value, value.Time, value.Envelope}
	end,
}

Converter.PhysicalProperties = {
	Pack = function(unpackedValue : UnpackedValue)
		return PhysicalProperties.new(unpackedValue[1], unpackedValue[2], unpackedValue[3], unpackedValue[4], unpackedValue[5])
	end,

	Unpack = function(value : PhysicalProperties)
		return {value.Density, value.Friction, value.Elasticity, value.FrictionWeight, value.ElasticityWeight}
	end,
}

Converter.Ray = {
	Pack = function(unpackedValue : UnpackedValue)
		return Ray.new(
			Vector3.new(unpackedValue[1], unpackedValue[2], unpackedValue[3]),
			Vector3.new(unpackedValue[4], unpackedValue[5], unpackedValue[6])
		)
	end,

	Unpack = function(value : Ray)
		return {value.Origin.X, value.Origin.Y, value.Origin.Z, value.Direction.X, value.Direction.Y, value.Direction.Z}
	end,
}

Converter.Rect = {
	Pack = function(unpackedValue : UnpackedValue)
		return Rect.new(unpackedValue[1], unpackedValue[2], unpackedValue[3], unpackedValue[4])
	end,

	Unpack = function(value : Rect)
		return {value.Min.X, value.Min.Y, value.Max.X, value.Max.Y}
	end,
}

Converter.Region3 = {
	Pack = function(unpackedValue : UnpackedValue)
		local Position = Vector3.new(unpackedValue[1], unpackedValue[2], unpackedValue[3])
		local HalfSize = Vector3.new(unpackedValue[4] / 2, unpackedValue[5] / 2, unpackedValue[6] / 2)

		return Region3.new(Position - HalfSize, Position + HalfSize)
	end,

	Unpack = function(value : Region3)
		return {value.CFrame.X, value.CFrame.Y, value.CFrame.Z, value.Size.X, value.Size.Y, value.Size.Z}
	end,
}

Converter.Region3int16 = {
	Pack = function(unpackedValue : UnpackedValue)
		return Region3int16.new(
			Vector3int16.new(unpackedValue[1], unpackedValue[2], unpackedValue[3]),
			Vector3int16.new(unpackedValue[4], unpackedValue[5], unpackedValue[6])
		)
	end,

	Unpack = function(value : Region3int16)
		return {value.Min.X, value.Min.Y, value.Min.Z, value.Max.X, value.Max.Y, value.Max.Z}
	end,
}

Converter.UDim = {
	Pack = function(unpackedValue : UnpackedValue)
		return UDim.new(unpackedValue[1], unpackedValue[2])
	end,

	Unpack = function(value : UDim)
		return {value.Scale, value.Offset}
	end,
}

Converter.UDim2 = {
	Pack = function(unpackedValue : UnpackedValue)
		return UDim2.new(unpackedValue[1], unpackedValue[2], unpackedValue[3], unpackedValue[4])
	end,

	Unpack = function(value : UDim2)
		return {value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset}
	end,
}

Converter.Vector2 = {
	Pack = function(unpackedValue : UnpackedValue)
		return Vector2.new(unpackedValue[1], unpackedValue[2])
	end,

	Unpack = function(value : Vector2)
		return {value.X, value.Y}
	end,
}

Converter.Vector2int16 = {
	Pack = function(unpackedValue : UnpackedValue)
		return Vector2int16.new(unpackedValue[1], unpackedValue[2])
	end,

	Unpack = function(value : Vector2int16)
		return {value.X, value.Y}
	end,
}

Converter.Vector3 = {
	Pack = function(unpackedValue : UnpackedValue)
		return Vector3.new(unpackedValue[1], unpackedValue[2], unpackedValue[3])
	end,

	Unpack = function(value : Vector3)
		return {value.X, value.Y, value.Z}
	end,
}

Converter.Vector3int16 = {
	Pack = function(unpackedValue : UnpackedValue)
		return Vector3int16.new(unpackedValue[1], unpackedValue[2], unpackedValue[3])
	end,

	Unpack = function(value : Vector3int16)
		return {value.X, value.Y, value.Z}
	end,
}

-- Converts a value into a table
function ValuePacker.UnpackValue(value : any, valueType : string) : UnpackedValue
	if Converter[valueType] then
		return Converter[valueType].Unpack(value)
	end

	return {}
end

-- Converts a table into a value
function ValuePacker.PackValue(unpackedValue : UnpackedValue, valueType : string) : any
	if Converter[valueType] then
		return Converter[valueType].Pack(unpackedValue)
	end

	return nil
end

return ValuePacker
