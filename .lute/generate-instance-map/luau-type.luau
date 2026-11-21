--[[
	Converts API dump value types to Luau type syntax.

	The result has to resolve both in Roblox Studio and in luau-lsp's definition files, which don't always agree on
	names: luau-lsp declares `ContentId` and `ProtectedString`, for example, but those are plain strings at runtime, so
	they're written as `string`. Enums use the `Enum.<Name>` form, which both understand.

	Example:
	```luau
	luauType.fromValueType({ Name = "AutomaticSize", Category = "Enum" }, classIndex) -- "Enum.AutomaticSize"
	luauType.fromValueType({ Name = "int64", Category = "Primitive" }, classIndex) -- "number"
	```
]]

const dump = require("./dump")

-- Constants --
const PRIMITIVES = table.freeze({
	bool = "boolean",
	int = "number",
	int64 = "number",
	float = "number",
	double = "number",
	string = "string",
} :: { [string]: string })

-- Data types that exist under the same name as Luau globals
const DATA_TYPES = table.freeze({
	Axes = true,
	BrickColor = true,
	CFrame = true,
	Color3 = true,
	ColorSequence = true,
	Content = true,
	DateTime = true,
	Faces = true,
	Font = true,
	NumberRange = true,
	NumberSequence = true,
	Path2DControlPoint = true,
	PhysicalProperties = true,
	Ray = true,
	Rect = true,
	Region3 = true,
	Region3int16 = true,
	SecurityCapabilities = true,
	UDim = true,
	UDim2 = true,
	Vector2 = true,
	Vector2int16 = true,
	Vector3 = true,
	Vector3int16 = true,
} :: { [string]: boolean })

-- Data types stored as strings
const STRING_DATA_TYPES = table.freeze({
	BinaryString = true,
	ContentId = true,
	ProtectedString = true,
	SharedString = true,
} :: { [string]: boolean })

-- Written for value types this module doesn't know, so the output still type checks
const FALLBACK = "any"

-- Functions --

--[[
	Returns the Luau type for an API dump value type.

	@param classIndex Used to check that class-typed values name a class the dump knows.
	@return The Luau type, and whether it's a fallback for an unrecognized value type.
]]
const function fromValueType(valueType: dump.ValueType, classIndex: dump.ClassIndex): (string, boolean)
	const name, category = valueType.Name, valueType.Category

	if category == "Primitive" then
		const primitive = PRIMITIVES[name]
		if primitive then
			return primitive, false
		end
	elseif category == "DataType" then
		if DATA_TYPES[name] then
			return name, false
		elseif STRING_DATA_TYPES[name] then
			return "string", false
		end
	elseif category == "Enum" then
		return `Enum.{name}`, false
	elseif category == "Class" then
		if classIndex[name] then
			return name, false
		end
	end

	return FALLBACK, true
end

return table.freeze({
	FALLBACK = FALLBACK,
	fromValueType = fromValueType,
})
