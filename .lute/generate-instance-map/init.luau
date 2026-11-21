--[[
	Generates a Luau module exporting a 'Classes' type mapping Roblox Instance class names to their respective types,
	and a 'ClassNames' type union of all classes for convenience, using the Roblox-Client-Tracker API dump (requires an
	Internet connection): https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/API-Dump.json

	With --properties it also exports a 'Properties' type mapping each class to the properties a script can set.

	Example:
	```bash
	lute run generate-instance-map -r 0.746 -t '!NotCreatable,!NotReplicated,!Deprecated,!Service' -w 'T | {Value: any} | (...any) -> (...any)' -o src/Modules/InstanceTypeMap.luau
	```

	For more information on usage, run:
	```bash
	lute run generate-instance-map -h
	```

	Module layout:
	* `main.luau`: argument parsing, loading the dump and writing the module.
	* `dump.luau`: API dump shapes, and selecting classes and writable properties.
	* `luau-type.luau`: converting API dump value types to Luau types.
	* `render.luau`: rendering the generated module.
	* `output.luau`, `lib/`: console output, the argument parser and ANSI formatting.
	* `tests/`: run with `lute test .lute/generate-instance-map/tests` from the repository root.
]]

const process = require("@std/process")

const main = require("@self/main")

-- `process.args[1]` is the script path
const args = table.move(process.args, 2, #process.args, 1, {})
process.exit(main.run(args))
