--[[
	lute test .lute/generate-instance-map/tests/dump.test.luau

	Selecting classes (dump.luau) by name, superclass and tags, and collecting the properties a script can set:
	inherited, sorted, without read-only, deprecated, non-scriptable or privileged ones.
]]

const fs = require("@std/fs")
const json = require("@std/json")
const test = require("@std/test")

const dump = require("../dump")

-- Constants --

-- Relative to the repository root, where tests are run from
const FIXTURE = ".lute/generate-instance-map/tests/fixtures/api-dump.json"

-- Functions --

const function loadIndex(): dump.ClassIndex
	const parsed = dump.parse(json.deserialize(fs.readFileToString(FIXTURE)))
	assert(parsed, "fixture should parse")
	return dump.indexClasses(parsed)
end

const function names(properties: { dump.Property }): string
	const list = {}
	for _, property in properties do
		table.insert(list, property.name)
	end
	return table.concat(list, ",")
end

test.suite("dump", function(suite)
	suite:case("rejects JSON without a Classes list", function(assert)
		const parsed, err = dump.parse({ Version = 1 } :: any)
		assert.eq(parsed, nil)
		assert.strContains(err :: string, "Classes")
	end)

	suite:case("selects every class without filters, sorted", function(assert)
		const selected = dump.selectClasses(loadIndex(), {})
		assert.eq(table.concat(selected, ","), "Frame,GuiObject,Instance,TextLabel,Workspace")
	end)

	suite:case("filters by tags, negated or not", function(assert)
		const index = loadIndex()
		const creatable = dump.selectClasses(index, { tags = { { value = "NotCreatable", negate = true } } })
		assert.eq(table.concat(creatable, ","), "Frame,TextLabel")

		const services = dump.selectClasses(index, { tags = { { value = "Service", negate = false } } })
		assert.eq(table.concat(services, ","), "Workspace")
	end)

	suite:case("filters by class and superclass", function(assert)
		const index = loadIndex()
		assert.eq(
			table.concat(dump.selectClasses(index, { classes = { "Frame", "Workspace" } }), ","),
			"Frame,Workspace"
		)
		assert.eq(
			table.concat(dump.selectClasses(index, { superclasses = { "GuiObject" } }), ","),
			"Frame,GuiObject,TextLabel"
		)
	end)

	suite:case("reports unknown class names once", function(assert)
		const unknown = dump.unknownClasses(loadIndex(), { classes = { "Frame", "Nope" }, superclasses = { "Nope" } })
		assert.eq(table.concat(unknown, ","), "Nope")
	end)

	suite:case("lists a class and its ancestors, nearest first", function(assert)
		assert.eq(table.concat(dump.ancestry(loadIndex(), "TextLabel"), ","), "TextLabel,GuiObject,Instance")
	end)

	suite:case("collects writable properties, inherited ones included", function(assert)
		const index = loadIndex()
		assert.eq(
			names(dump.writableProperties(index, "Frame")),
			"Archivable,Name,NextSelectionUp,Parent,Size,Style,Visible"
		)
		-- Hidden but scriptable properties (Font) are kept; ReadOnly, NotScriptable, Deprecated and privileged ones aren't
		assert.eq(
			names(dump.writableProperties(index, "TextLabel")),
			"Archivable,Font,Mystery,Name,NextSelectionUp,Odd Name,Parent,Size,Text,Visible,end"
		)
	end)

	suite:case("prefers a subclass's declaration of a property", function(assert)
		for _, property in dump.writableProperties(loadIndex(), "TextLabel") do
			if property.name == "Size" then
				assert.eq(property.owner, "TextLabel")
				assert.eq(property.valueType.Name, "Vector2")
			end
		end
	end)
end)
