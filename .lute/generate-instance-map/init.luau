--[[
	Generates a Luau module exporting a 'Classes' type mapping Roblox Instance class names to their
	respective types using the Roblox-Client-Tracker API Dump (requires an Internet connection):
	https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/API-Dump.json

	Example:
		```bash
		lute run generate-instance-map -t "!NotCreatable,!NotReplicated,!Deprecated" -s GuiBase,UIBase
		```

	For more information on usage, run:
		```bash
		lute run generate-instance-map -h
		```
]]

const tableext = require("@std/tableext")
const process = require("@std/process")
const path = require("@std/path")
const json = require("@std/json")
const net = require("@std/net")
const fs = require("@std/fs")
const io = require("@std/io")

const ansi = require("@self/ansi-format")
const color_output = require("@self/color-output")

const DUMP_URL = "https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/API-Dump.json"

-- API Dump Shapes --
type ClassInfo = {
	Name: string,
	Superclass: string,
	Members: unknown,
	Tags: {string}?
}

type Dump = {
	Classes: {ClassInfo}
}

-- Helpers --

const function unhandled(a: never): ()
	color_output.fatal(`Unrecognized argument: {a}`, 2)
end

const function fetchRemoteJson(url: string): (json.Array | json.Object | json.Value)
	const response = net.request(url)
	const body = response.body
	if not response.ok then
		color_output.fatal(`Failed to fetch because HTTP {response.status} ({body})`)
	end

	return json.deserialize(body)
end

-- CLI --
const HELP_MESSAGE =  `\z
	{ansi.colorForeground("generate-instance-map", "Bright Green")}\z
	\n\z
	\nGenerates a Luau module exporting a 'Classes' type mapping Roblox Instance class names to their\z
	\nrespective types using the Roblox-Client-Tracker API Dump (requires an Internet connection):\z
	\n{ansi.underline(ansi.colorForeground("https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/API-Dump.json", "Blue"))}\z
	\n\z
	\nUsage: {ansi.colorForeground("lute [run] generate-instance-map [options...]", "Cyan")}\z
	\n\z
	\nOptions:\z
	\n    -h, --help                          Display this help message and exit.\z
	\n    -o, --output                        Where to output the Instance map. Omit to use stdout.\z
	\n    -c, --class <Name[,Name...]>        Only include these classes.\z
	\n    -s, --superclass <Name[,Name...]>   Only include these classes and their subclasses.\z
	\n    -t, --tags <Tag[,Tag...]>           Filter classes with these tags (prefix ! to negate).\z
	\n    -v, --verbose                       Verbose debug message output.\z
`

type CLIOptions = {
	help: true?,
	output: path.Pathlike?,
	classes: {string}?,
	superclasses: {string}?,
	tags: {{value: string, negate: boolean}}?,
	verbose: true?,
}

type CLIArguments =
	| "-h" | "--help"
	| "-o" | "--output"
	| "-c" | "--class"
	| "-s" | "--superclass"
	| "-t" | "--tags"
	| "-v" | "--verbose"

const function parseArgs(args: { CLIArguments | string }): (CLIOptions)
	const function splitComma(value: string): ({string})
		return string.split(value, ",")
	end

	const opts: CLIOptions = {}

	const numArgs = #args
	local i = 2 -- start at 2, index 1 is script
	while i <= numArgs do
		const arg = args[i] :: CLIArguments
		if arg == "-h" or arg == "--help" then
			opts.help = true
		elseif arg == "-o" or arg == "--output" then
			i += 1

			opts.output = args[i]
		elseif arg == "-c" or arg == "--class" then
			i += 1

			opts.classes = splitComma(args[i])
		elseif arg == "-s" or arg == "--superclass" then
			i += 1

			opts.superclasses = splitComma(args[i])
		elseif arg == "-t" or arg == "--tags" then
			i += 1

			const rawTags = splitComma(args[i])
			const tags: {{value: string, negate: boolean}} = {}

			for n, tag in rawTags do
				const negate = string.sub(tag, 1, 1) == "!"

				tags[n] = {
					value = if negate then string.sub(tag, 2) else tag,
					negate = negate
				}
			end

			opts.tags = tags
		elseif arg == "-v" or arg == "--verbose" then
			opts.verbose = true
		else
			unhandled(arg)
		end

		i += 1
	end

	return opts
end

-- Arguments --
const opts = parseArgs(process.args)
const output = opts.output
const inclClassSet = opts.classes and tableext.toSet(opts.classes)
const inclSuperclassSet = opts.superclasses and tableext.toSet(opts.superclasses)
const tags = opts.tags
const verbose = opts.verbose

if opts.help then
	print(HELP_MESSAGE)
	process.exit(0)
end

if verbose then color_output.verbose(`Fetching API dump from {DUMP_URL}`) end

const dump = fetchRemoteJson(DUMP_URL) :: Dump
if type(dump) ~= "table" or type(dump.Classes) ~= "table" then
	color_output.fatal(`Unexpected API dump format:\n{dump}`)
	return
end

-- Map of every class in the dump
const classMap: { [string]: ClassInfo } = {}
for _, class in dump.Classes do
	classMap[class.Name] = class
end

-- Warn about classes that don't exist
for _, set in {inclClassSet, inclSuperclassSet} do
	for name in set do
		if not classMap[name] then
			color_output.warn(`Unknown class '{name}' (not in dump)`)
		end
	end
end

const function isSubClassIncluded(class: string): (boolean)
	assert(inclSuperclassSet, "isSubClassIncluded can only be used when superclasses is defined")

	const classInfo = classMap[class]
	local node: ClassInfo? = classInfo
	while node do
		const name = node.Name
		if inclSuperclassSet[name] then
			if verbose then color_output.verbose(`{class} is subclass of {name}`) end
			return true
		end
		node = classMap[node.Superclass]
	end

	return false
end

const function isIncluded(className: string): boolean
	const classIncluded = if inclClassSet
			then inclClassSet[className] ~= nil
		elseif inclSuperclassSet
			then isSubClassIncluded(className)
		else true -- No class filter specified, include every class

	if not classIncluded then return false end

	if tags then
		const classInfo = classMap[className]
		const classTags = classInfo.Tags or {}

		for _, tag in tags do
			const hasTag = table.find(classTags, tag.value) ~= nil
			if hasTag == tag.negate then
				return false
			end
		end
	end
	
	return true
end

const includedClassNames: {string} = {}
for className in classMap do
	if isIncluded(className) then
		table.insert(includedClassNames, className)	
	end
end

table.sort(includedClassNames)

-- Generate Module --
const lines = {
	"-- This file was auto-generated by generate-instance-map.",
	"-- Do not manually edit!\n",
	"export type Classes = {"
}

for _, className in includedClassNames do
	table.insert(lines, `\t["{className}"]: {className},`)
end

table.insert(lines, "}\n\nreturn nil")

const src = table.concat(lines, "\n")

if output then
	if verbose then color_output.verbose(`Writing module to {output}`) end
	fs.writeStringToFile(output, src)
else
	-- We use io.write instead of print, as the latter always sends to stdout
	-- rather than default output file (which the user can change)
	io.write(src)
end