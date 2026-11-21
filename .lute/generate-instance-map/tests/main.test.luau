--[[
	lute test .lute/generate-instance-map/tests/main.test.luau

	The command-line entry (main.luau): help, usage errors and exit codes, reading the dump from a file or the
	network, and resolving --roblox-version through the tracker's commits. Network and file access are faked.
]]

const fs = require("@std/fs")
const json = require("@std/json")
const test = require("@std/test")

const main = require("../main")
const output = require("../output")

-- Constants --

-- Relative to the repository root, where tests are run from (cwd)
const FIXTURE = ".lute/generate-instance-map/tests/fixtures/api-dump.json"

-- Types --
type Run = {
	code: number,
	text: string,
	written: { [string]: string },
	requested: { string },
}

-- Functions --

--[[
	Runs the tool with fake dependencies. `responses` maps URL prefixes to response bodies; unmatched URLs fail.
]]
const function run(args: { string }, responses: { [string]: string }?): Run
	const out, lines = output.capture()
	const written: { [string]: string } = {}
	const requested: { string } = {}
	const code = main.run(args, {
		out = out,
		fetch = function(url: string): (string?, string?)
			table.insert(requested, url)
			for prefix, body in responses or {} do
				if string.sub(url, 1, #prefix) == prefix then
					return body, nil
				end
			end
			return nil, "HTTP 404 (not found)"
		end,
		readFile = fs.readFileToString,
		writeFile = function(path: string, contents: string)
			written[path] = contents
		end,
	})

	return { code = code, text = table.concat(lines, "\n"), written = written, requested = requested }
end

const function commitSearch(items: { { sha: string, message: string, date: string } }): string
	const encoded = {}
	for _, item in items do
		table.insert(encoded, { sha = item.sha, commit = { message = item.message, committer = { date = item.date } } })
	end
	return json.serialize({ items = encoded } :: any)
end

test.suite("main", function(suite)
	suite:case("prints help", function(assert)
		for _, args in { { "--help" }, { "-h" } } do
			const result = run(args)
			assert.eq(result.code, 0)
			assert.strContains(result.text, "Usage: lute [run] generate-instance-map [options]")
			assert.strContains(result.text, "--roblox-version (-r)")
		end
	end)

	suite:case("reports unknown arguments as usage errors", function(assert)
		const result = run({ "--nope" })
		assert.eq(result.code, 2)
		assert.strContains(result.text, "Unknown argument: nope")
	end)

	suite:case("rejects --dump with --roblox-version", function(assert)
		const result = run({ "-d", FIXTURE, "-r", "0.746" })
		assert.eq(result.code, 2)
		assert.strContains(result.text, "can't be used together")
	end)

	suite:case("writes the module from a dump file, recording the command", function(assert)
		const result = run({ "-d", FIXTURE, "-t", "!NotCreatable", "-o", "out.luau" })
		assert.eq(result.code, 0)
		const source = result.written["out.luau"]
		assert.strContains(source, `generate-instance-map -d {FIXTURE} -t '!NotCreatable' -o out.luau`)
		assert.strContains(source, '\t["Frame"]: Frame,')
		assert.eq(string.find(source, "Workspace", 1, true), nil)
	end)

	suite:case("prints the module without --output", function(assert)
		const result = run({ "-d", FIXTURE, "-c", "Frame", "-w", "T | {Value: any}" })
		assert.eq(result.code, 0)
		assert.strContains(result.text, "plain: --[[")
		assert.strContains(result.text, "export type Property<T> = T | {Value: any}")
	end)

	suite:case("warns about unknown classes and fallback types", function(assert)
		const result = run({ "-d", FIXTURE, "-c", "TextLabel,Nope", "-p" })
		assert.eq(result.code, 0)
		assert.strContains(result.text, "warn: Unknown class 'Nope' (not in dump)")
		assert.strContains(result.text, "warn: TextLabel.Mystery has unknown type DataType:Mystery, using any")
	end)

	suite:case("fails when the dump can't be read or parsed", function(assert)
		assert.eq(run({ "-d", "missing.json" }).code, 1)

		const notJson = run({}, { [main.DUMP_URL] = "<html>" })
		assert.eq(notJson.code, 1)
		assert.strContains(notJson.text, "isn't valid JSON")

		const offline = run({})
		assert.eq(offline.code, 1)
		assert.strContains(offline.text, "Failed to fetch the API dump: HTTP 404")
	end)

	suite:case("fetches the latest dump by default", function(assert)
		const result = run({ "-c", "Frame" }, { [main.DUMP_URL] = fs.readFileToString(FIXTURE) })
		assert.eq(result.code, 0)
		assert.eq(result.requested[1], main.DUMP_URL)
	end)

	suite:case("resolves --roblox-version to the newest matching build", function(assert)
		const search = commitSearch({
			{ sha = "aaa", message = "0.746.0.7450001 (JSON)", date = "2026-11-01T00:00:00Z" },
			{ sha = "bbb", message = "0.746.0.7461269 (JSON)", date = "2026-11-10T00:00:00Z" },
			{ sha = "ccc", message = "0.7460.0.1 (JSON)", date = "2026-11-20T00:00:00Z" },
			{ sha = "ddd", message = "0.746.0.7461269 (CSV)", date = "2026-11-21T00:00:00Z" },
		})
		const result = run({ "-r", "0.746", "-v", "-c", "Frame" }, {
			["https://api.github.com/search/commits"] = search,
			["https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/bbb/"] = fs.readFileToString(FIXTURE),
		})
		assert.eq(result.code, 0)
		assert.strContains(result.text, "Using the API dump of Roblox 0.746.0.7461269")
		assert.strContains(result.requested[2], "/bbb/API-Dump.json")
	end)

	suite:case("fails for versions that aren't found or aren't versions", function(assert)
		const missing = run({ "-r", "0.999" }, { ["https://api.github.com/"] = commitSearch({}) })
		assert.eq(missing.code, 1)
		assert.strContains(missing.text, "No API dump found for Roblox version 0.999")

		const invalid = run({ "-r", "latest" })
		assert.eq(invalid.code, 1)
		assert.strContains(invalid.text, "isn't a Roblox version")
		assert.eq(#invalid.requested, 0)
	end)
end)
