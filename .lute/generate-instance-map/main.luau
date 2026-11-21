--[[
	generate-instance-map's command-line entry: parses arguments, loads the API dump and writes the module.

	`run` returns an exit code instead of exiting, so tests can drive the whole tool.
]]

const fs = require("@std/fs")
const json = require("@std/json")
const net = require("@std/net")

const ansi = require("./lib/ansi-format")
const cli = require("./lib/cli")
const dump = require("./dump")
const output = require("./output")
const render = require("./render")

-- Types --
export type Deps = {
	out: output.Output,
	fetch: (url: string, headers: { [string]: string }?) -> (string?, string?),
	readFile: (path: string) -> string,
	writeFile: (path: string, contents: string) -> (),
}

-- Constants --
const TOOL_NAME = "generate-instance-map"
const TRACKER_REPO = "MaximumADHD/Roblox-Client-Tracker"
const DUMP_URL = `https://raw.githubusercontent.com/{TRACKER_REPO}/roblox/API-Dump.json`
const GITHUB_HEADERS: { [string]: string } = {
	["User-Agent"] = TOOL_NAME,
	["Accept"] = "application/vnd.github+json",
}
const FAILURE = 1
const USAGE_ERROR = 2

const DESCRIPTION = `Generates a Luau module exporting a 'Classes' type mapping Roblox Instance class names to their\n\z
	respective types, and a 'ClassNames' union of the names, from the Roblox-Client-Tracker API dump (requires an\n\z
	Internet connection unless --dump is given):\n\z
	{DUMP_URL}\n\z
	\n\z
	The tracker's latest dump can be ahead of the Roblox Studio release, and types it adds would be unknown to\n\z
	Studio. Use --roblox-version to generate from the dump of the version you target.`

-- Characters that never need quoting in POSIX shells (sh, bash, zsh)
const SAFE_PATTERN = "^[%w@%%_+=:,./-]+$"

-- Functions --

const function defaultDeps(): Deps
	return {
		out = output.console(),
		fetch = function(url: string, headers: { [string]: string }?): (string?, string?)
			const response = net.request(url, { headers = headers })
			if not response.ok then
				return nil, `HTTP {response.status} ({response.body})`
			end

			return response.body, nil
		end,
		readFile = fs.readFileToString,
		writeFile = fs.writeStringToFile,
	}
end

const function buildParser(): cli.Parser
	const parser = cli.parser()
	parser:add("help", "flag", { aliases = { "h" }, help = "Display this help message and exit." })
	parser:add("output", "option", { aliases = { "o" }, help = "Where to write the module. Omit to use stdout." })
	parser:add("class", "option", { aliases = { "c" }, help = "Only include these classes (Name[,Name...])." })
	parser:add("superclass", "option", {
		aliases = { "s" },
		help = "Only include these classes and their subclasses (Name[,Name...]).",
	})
	parser:add("tags", "option", {
		aliases = { "t" },
		help = "Filter classes with these tags (Tag[,Tag...], prefix ! to negate).",
	})
	parser:add("properties", "flag", {
		aliases = { "p" },
		help = "Also export a 'Properties' type mapping each class name to a table of the properties a script can set.",
	})
	parser:add("property-wrapper", "option", {
		aliases = { "w" },
		help = "Wrap each property's type in this Luau type, written in terms of 'T'. Implies --properties.",
	})
	parser:add("roblox-version", "option", {
		aliases = { "r" },
		help = "Fetch the API dump of this Roblox version (e.g. 0.746 or 0.746.0.7461269) instead of the latest.",
	})
	parser:add(
		"dump",
		"option",
		{ aliases = { "d" }, help = "Read the API dump from this file instead of fetching it." }
	)
	parser:add("verbose", "flag", { aliases = { "v" }, help = "Verbose debug message output." })

	return parser
end

const function help(parser: cli.Parser): string
	return table.concat({
		ansi.colorForeground(TOOL_NAME, "Bright Green"),
		"",
		DESCRIPTION,
		"",
		parser:usage(`lute [run] {TOOL_NAME}`),
		"",
		parser:help(),
	}, "\n")
end

const function splitComma(value: string?): { string }?
	if value == nil then
		return nil
	end

	const parts: { string } = {}
	for part in string.gmatch(value, "[^,]+") do
		table.insert(parts, part)
	end

	return parts
end

const function parseTags(value: string?): { dump.TagFilter }?
	const rawTags = splitComma(value)
	if rawTags == nil then
		return nil
	end

	const tags: { dump.TagFilter } = {}
	for _, tag in rawTags do
		const negate = string.sub(tag, 1, 1) == "!"
		table.insert(tags, { value = if negate then string.sub(tag, 2) else tag, negate = negate })
	end

	return tags
end

const function quoteArg(arg: string): string
	if arg == "" then
		return "''"
	elseif string.match(arg, SAFE_PATTERN) then
		return arg
	end

	-- Wrap in single quotes; turn each embedded ' into '\''
	return "'" .. string.gsub(arg, "'", "'\\''") .. "'"
end

--[[
	Formats the command line as it would be typed into a POSIX shell, for the generated module's header.
]]
const function formatCommand(args: { string }): string
	const parts = { TOOL_NAME }
	for _, arg in args do
		table.insert(parts, quoteArg(arg))
	end

	return table.concat(parts, " ")
end

--[[
	Finds the URL of the API dump for a Roblox version, or for the newest version starting with `version`.

	@return The URL and the full version, or nil and an error message.
]]
const function resolveVersionedDumpUrl(version: string, deps: Deps): (string?, string?)
	if not string.match(version, "^%d+[%d.]*$") then
		return nil, `'{version}' isn't a Roblox version (expected e.g. 0.746 or 0.746.0.7461269)`
	end

	-- The tracker commits each Roblox version's API dump as "<version> (JSON)"
	const searchUrl = `https://api.github.com/search/commits?q=repo:{TRACKER_REPO}+%22{version}%22+%22(JSON)%22`
	const body, fetchError = deps.fetch(searchUrl, GITHUB_HEADERS)
	if not body then
		return nil, `Failed to search the tracker's commits for version {version}: {fetchError}`
	end

	const ok, decoded = pcall(json.deserialize, body)
	const items: any = if ok and type(decoded) == "table" then (decoded :: any).items else nil
	if type(items) ~= "table" then
		return nil, `Unexpected response when searching for version {version}`
	end

	-- A prefix like "0.746" can match several builds; take the newest
	local bestSha, bestVersion, bestDate = nil :: string?, nil :: string?, ""
	for _, item in items do
		const commit = if type(item) == "table" then item.commit else nil
		const message = if type(commit) == "table" then commit.message else nil
		const sha = if type(item) == "table" then item.sha else nil
		if type(message) ~= "string" or type(sha) ~= "string" then
			continue
		end

		const matched = string.match(message, "^([%d.]+) %(JSON%)$")
		if matched == nil or (matched ~= version and string.sub(matched, 1, #version + 1) ~= `{version}.`) then
			continue
		end

		const committer = commit.committer
		const date = if type(committer) == "table" and type(committer.date) == "string" then committer.date else ""
		if bestSha == nil or date > bestDate then
			bestSha, bestVersion, bestDate = sha, matched, date
		end
	end

	if bestSha == nil then
		return nil, `No API dump found for Roblox version {version}`
	end

	return `https://raw.githubusercontent.com/{TRACKER_REPO}/{bestSha}/API-Dump.json`, bestVersion
end

--[[
	Loads and checks the API dump: from `path` when given, otherwise from the network, for `version` when given.
]]
const function loadDump(path: string?, version: string?, deps: Deps, verbose: boolean): (dump.Dump?, string?)
	local body: string
	if path then
		if verbose then
			deps.out.verbose(`Reading API dump from {path}`)
		end

		const ok, result = pcall(deps.readFile, path)
		if not ok then
			return nil, `Failed to read the API dump from {path}: {result}`
		end
		body = result
	else
		local url = DUMP_URL
		if version then
			const versionedUrl, resolved = resolveVersionedDumpUrl(version, deps)
			if not versionedUrl then
				return nil, resolved
			end
			url = versionedUrl

			if verbose then
				deps.out.verbose(`Using the API dump of Roblox {resolved}`)
			end
		end

		if verbose then
			deps.out.verbose(`Fetching API dump from {url}`)
		end

		const fetched, err = deps.fetch(url)
		if not fetched then
			return nil, `Failed to fetch the API dump: {err}`
		end
		body = fetched
	end

	const ok, decoded = pcall(json.deserialize, body)
	if not ok then
		return nil, `The API dump isn't valid JSON: {decoded}`
	end

	const parsed, err = dump.parse(decoded)
	if not parsed then
		return nil, `Unexpected API dump format: {err}`
	end

	return parsed, nil
end

--[[
	Runs the tool.

	@param args The command-line arguments, without the program name.
	@param overrides Replacements for the default dependencies, for tests.
	@return The exit code.
]]
const function run(args: { string }, overrides: Deps?): number
	const deps = overrides or defaultDeps()
	const parser = buildParser()

	const parsed, parseError = pcall(parser.parse, parser, args)
	if not parsed then
		deps.out.error(`{parseError}`)
		deps.out.plain(parser:usage(`lute [run] {TOOL_NAME}`))
		return USAGE_ERROR
	end

	if parser:has("help") then
		deps.out.plain(help(parser))
		return 0
	end

	const verbose = parser:has("verbose")
	const propertyWrapper = parser:get("property-wrapper")
	const filter: dump.ClassFilter = {
		classes = splitComma(parser:get("class")),
		superclasses = splitComma(parser:get("superclass")),
		tags = parseTags(parser:get("tags")),
	}

	const dumpPath, robloxVersion = parser:get("dump"), parser:get("roblox-version")
	if dumpPath and robloxVersion then
		deps.out.error("--dump and --roblox-version can't be used together")
		return USAGE_ERROR
	end

	const apiDump, loadError = loadDump(dumpPath, robloxVersion, deps, verbose)
	if not apiDump then
		deps.out.error(loadError :: string)
		return FAILURE
	end

	const classIndex = dump.indexClasses(apiDump)
	for _, name in dump.unknownClasses(classIndex, filter) do
		deps.out.warn(`Unknown class '{name}' (not in dump)`)
	end

	const classNames = dump.selectClasses(classIndex, filter)
	const source, warnings = render.module({
		command = formatCommand(args),
		classNames = classNames,
		classIndex = classIndex,
		properties = parser:has("properties") or propertyWrapper ~= nil,
		propertyWrapper = propertyWrapper,
	})

	for _, warning in warnings do
		deps.out.warn(warning)
	end

	const outputPath = parser:get("output")
	if outputPath then
		if verbose then
			deps.out.verbose(`Writing module with {#classNames} classes to {outputPath}`)
		end

		const ok, err = pcall(deps.writeFile, outputPath, source)
		if not ok then
			deps.out.error(`Failed to write {outputPath}: {err}`)
			return FAILURE
		end
	else
		deps.out.plain(source)
	end

	return 0
end

return table.freeze({
	TOOL_NAME = TOOL_NAME,
	DUMP_URL = DUMP_URL,
	formatCommand = formatCommand,
	run = run,
})
