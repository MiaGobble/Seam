--[[
	lute test .lute/generate-instance-map/tests/render.test.luau

	Rendering the generated module (render.luau): the Classes/ClassNames layout existing users rely on, and the
	optional Properties, Property<T> and AncestorClasses exports.
]]

const fs = require("@std/fs")
const json = require("@std/json")
const test = require("@std/test")

const dump = require("../dump")
const render = require("../render")

-- Constants --

-- Relative to the repository root, where tests are run from
const FIXTURE = ".lute/generate-instance-map/tests/fixtures/api-dump.json"

-- Functions --

const function loadIndex(): dump.ClassIndex
	return dump.indexClasses(dump.parse(json.deserialize(fs.readFileToString(FIXTURE))) :: dump.Dump)
end

const function renderModule(overrides: { [string]: any }?): (string, { string })
	const options: any = {
		command = "generate-instance-map -p",
		classNames = { "Frame", "TextLabel" },
		classIndex = loadIndex(),
	}
	for key, value in overrides or {} do
		options[key] = value
	end

	return render.module(options)
end

test.suite("render", function(suite)
	suite:case("quotes every table key", function(assert)
		assert.eq(render.tableKey("Name"), '["Name"]')
		assert.eq(render.tableKey("Odd Name"), '["Odd Name"]')
		assert.eq(render.tableKey("end"), '["end"]')
		assert.eq(render.tableKey('"TODO" Color'), '["\\"TODO\\" Color"]')
	end)

	suite:case("renders Classes and ClassNames without properties", function(assert)
		const source, warnings = renderModule()
		assert.eq(#warnings, 0)
		assert.strContains(source, "generate-instance-map -p")
		assert.strContains(source, 'export type Classes = {\n\t["Frame"]: Frame,\n\t["TextLabel"]: TextLabel,\n}')
		assert.strContains(source, 'export type ClassNames = \n\t| "Frame"\n\t| "TextLabel"\n\nreturn nil')
		assert.eq(string.find(source, "Properties", 1, true), nil)
	end)

	suite:case("renders a string ClassNames for an empty selection", function(assert)
		const source = renderModule({ classNames = {} })
		assert.strContains(source, "export type ClassNames = \nstring")
	end)

	suite:case("renders properties for the classes and their ancestors", function(assert)
		const source = renderModule({ properties = true, propertyWrapper = "T | {Value: any}" })
		assert.strContains(
			source,
			'export type AncestorClasses = {\n\t["GuiObject"]: GuiObject,\n\t["Instance"]: Instance,\n}'
		)
		assert.strContains(source, "export type Property<T> = T | {Value: any}")
		assert.strContains(source, '\t["Frame"]: {\n\t\tread ["Archivable"]: Property<boolean>?,')
		assert.strContains(source, '\t\tread ["Style"]: Property<Enum.FrameStyle>?,')
		assert.strContains(source, '\t\tread ["NextSelectionUp"]: Property<GuiObject>?,')
		assert.strContains(source, '\t\tread ["Odd Name"]: Property<number>?,')
		assert.strContains(source, '\t\tread ["end"]: Property<number>?,')
		assert.strContains(
			source,
			'\t["Instance"]: {\n\t\tread ["Archivable"]: Property<boolean>?,\n\t\tread ["Name"]: Property<string>?,'
		)
		assert.eq(string.find(source, "ContentText", 1, true), nil)
		assert.eq(string.find(source, "DataCost", 1, true), nil)
	end)

	suite:case("defaults the property wrapper to T", function(assert)
		const source = renderModule({ properties = true })
		assert.strContains(source, "export type Property<T> = T\n")
	end)

	suite:case("warns about properties whose type falls back to any", function(assert)
		const source, warnings = renderModule({ properties = true })
		assert.strContains(source, '\t\tread ["Mystery"]: Property<any>?,')
		assert.eq(#warnings, 1)
		assert.strContains(warnings[1], "TextLabel.Mystery has unknown type DataType:Mystery")
	end)
end)
