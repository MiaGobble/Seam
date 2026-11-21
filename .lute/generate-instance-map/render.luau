--[[
	Renders the generated Luau module.

	The module always exports `Classes`, mapping class names to their types, and `ClassNames`, a union of the names.

	With `properties` set it also exports `Properties`, mapping class names to a table of the properties a script can
	set on them (inherited ones included), for the selected classes and their ancestors, and `AncestorClasses`, mapping
	those ancestors' names to their types. Each property's type is wrapped in the exported `Property<T>` alias,
	`propertyWrapper` or `T` by default, and made optional and read-only, so that a table literal setting some of them
	checks against it. Precomputing this here saves type functions from walking the class hierarchy on every use.

	Each class gets its full table, rather than intersecting tables shared with its ancestors: that would make the
	module smaller and faster to check against, but type errors would then name the whole intersection instead of the
	expected type of the property.

	Example:
	```luau
	const source, warnings = render.module({
		command = "generate-instance-map -p",
		classNames = { "Frame" },
		classIndex = classIndex,
		properties = true,
	})
	```
]]

const dump = require("./dump")
const luauType = require("./luau-type")

-- Types --
export type Options = {
	--- The command line that generated the module, recorded in its header
	command: string,
	classNames: { string },
	classIndex: dump.ClassIndex,
	properties: boolean?,
	--- A Luau type in terms of `T`, the property's type
	propertyWrapper: string?,
}

-- Functions --

--[[
	Returns `name` as a table type key. Keys are always quoted, so names that aren't identifiers (with spaces, or
	reserved words like `end`) need no special case.
]]
const function tableKey(name: string): string
	return `[{string.format("%q", name)}]`
end

const function header(command: string): string
	return `--[[\z
		\n\tThis file was auto-generated using generate-instance-map:\z
		\n\t{command}\z
		\n\t\z
		\n\tDo not manually edit!\z
		\n]]\n`
end

const function propertyLine(property: dump.Property, indent: string, options: Options, warnings: { string }): string
	const valueType, isFallback = luauType.fromValueType(property.valueType, options.classIndex)
	if isFallback then
		const shown = `{property.valueType.Category}:{property.valueType.Name}`
		table.insert(warnings, `{property.owner}.{property.name} has unknown type {shown}, using {valueType}`)
	end

	return `{indent}read {tableKey(property.name)}: Property<{valueType}>?,`
end

--[[
	Returns the ancestors of the selected classes that aren't selected themselves, sorted by name.
]]
const function ancestorClasses(options: Options): { string }
	const selected: { [string]: true } = {}
	for _, className in options.classNames do
		selected[className] = true
	end

	const ancestors: { string } = {}
	const seen: { [string]: true } = {}
	for _, className in options.classNames do
		for _, ancestor in dump.ancestry(options.classIndex, className) do
			if not selected[ancestor] and not seen[ancestor] then
				seen[ancestor] = true
				table.insert(ancestors, ancestor)
			end
		end
	end

	table.sort(ancestors)
	return ancestors
end

const function renderProperties(options: Options, lines: { string }, warnings: { string })
	const ancestors = ancestorClasses(options)

	table.insert(lines, "")
	table.insert(lines, "-- Superclasses of the classes in 'Classes', which 'Properties' also has entries for")
	table.insert(lines, "export type AncestorClasses = {")
	for _, className in ancestors do
		table.insert(lines, `\t["{className}"]: {className},`)
	end
	table.insert(lines, "}")

	table.insert(lines, "")
	table.insert(lines, "-- Wraps the type of each property in 'Properties'")
	table.insert(lines, `export type Property<T> = {options.propertyWrapper or "T"}`)
	table.insert(lines, "")

	const classNames = table.clone(options.classNames)
	table.move(ancestors, 1, #ancestors, #classNames + 1, classNames)
	table.sort(classNames)

	table.insert(lines, "export type Properties = {")
	for _, className in classNames do
		table.insert(lines, `\t["{className}"]: \{`)
		for _, property in dump.writableProperties(options.classIndex, className) do
			table.insert(lines, propertyLine(property, "\t\t", options, warnings))
		end
		table.insert(lines, "\t},")
	end
	table.insert(lines, "}")
end

--[[
	Renders the module source.

	@return The source, and warnings about properties whose types fell back to `any`.
]]
const function module(options: Options): (string, { string })
	const lines = { header(options.command), "export type Classes = {" }
	const warnings: { string } = {}

	for _, className in options.classNames do
		table.insert(lines, `\t["{className}"]: {className},`)
	end

	table.insert(lines, "}\n")
	table.insert(lines, "export type ClassNames = ")

	for _, className in options.classNames do
		table.insert(lines, `\t| "{className}"`)
	end

	-- Failsafe to prevent a syntax error
	if not options.classNames[1] then
		table.insert(lines, "string")
	end

	if options.properties then
		renderProperties(options, lines, warnings)
	end

	table.insert(lines, "\nreturn nil")

	return table.concat(lines, "\n"), warnings
end

return table.freeze({
	tableKey = tableKey,
	module = module,
})
