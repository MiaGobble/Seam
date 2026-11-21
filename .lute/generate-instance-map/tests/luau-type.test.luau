--[[
	lute test .lute/generate-instance-map/tests/luau-type.test.luau

	Converting API dump value types to Luau types (luau-type.luau), including the fallback for unknown ones.
]]

const test = require("@std/test")

const luauType = require("../luau-type")

-- Constants --
const CLASS_INDEX: any = { Instance = {}, GuiObject = {} }

test.suite("luau-type", function(suite)
	suite:case("maps primitives", function(assert)
		const cases: { [string]: string } =
			{ bool = "boolean", int = "number", int64 = "number", float = "number", string = "string" }
		for name, expected in cases do
			assert.eq(luauType.fromValueType({ Name = name, Category = "Primitive" }, CLASS_INDEX), expected)
		end
	end)

	suite:case("keeps data types and writes string-like ones as string", function(assert)
		assert.eq(luauType.fromValueType({ Name = "UDim2", Category = "DataType" }, CLASS_INDEX), "UDim2")
		assert.eq(luauType.fromValueType({ Name = "ContentId", Category = "DataType" }, CLASS_INDEX), "string")
		assert.eq(luauType.fromValueType({ Name = "ProtectedString", Category = "DataType" }, CLASS_INDEX), "string")
	end)

	suite:case("writes enums as Enum.<Name>", function(assert)
		assert.eq(luauType.fromValueType({ Name = "Font", Category = "Enum" }, CLASS_INDEX), "Enum.Font")
	end)

	suite:case("writes known classes by name", function(assert)
		assert.eq(luauType.fromValueType({ Name = "GuiObject", Category = "Class" }, CLASS_INDEX), "GuiObject")
	end)

	suite:case("falls back for unknown value types", function(assert)
		const cases = {
			{ Name = "Mystery", Category = "DataType" },
			{ Name = "NotInDump", Category = "Class" },
			{ Name = "void", Category = "Primitive" },
			{ Name = "Tuple", Category = "Group" },
		}
		for _, valueType in cases do
			const result, isFallback = luauType.fromValueType(valueType, CLASS_INDEX)
			assert.eq(result, luauType.FALLBACK)
			assert.eq(isFallback, true)
		end
	end)
end)
