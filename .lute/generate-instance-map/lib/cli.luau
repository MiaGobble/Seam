--[[
	lute/batteries/cli.luau
	https://github.com/luau-lang/lute/blob/primary/batteries/cli.luau

	MIT License

	Copyright (c) 2024–2025 Roblox Corporation

	Permission is hereby granted, free of charge, to any person obtaining a copy of
	this software and associated documentation files (the "Software"), to deal in
	the Software without restriction, including without limitation the rights to
	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
	of the Software, and to permit persons to whom the Software is furnished to do
	so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.

	Modified to add API docstrings.

	```luau
	const cli = require("./cli")

	const p = cli.parser()
	p:add("verbose", "flag", { aliases = { "v" } })
	p:add("out", "option", { aliases = { "o" }, default = "a.out" })
	p:add("input", "positional", { required = true })

	const build = p:subcommand("build", { help = "Build things" })
	build:add("release", "flag")

	p:parse({ "-v", "main.luau", "-o", "x" })
	print(p:get("input"), p:get("out"), p:has("verbose")) -- main.luau x true
	print(p:usage("mytool")) -- Usage: mytool <command> <input> [options]
	```
]]

const cli = {}
cli.__index = cli

type ArgKind = "positional" | "flag" | "option" | "variadic"
type ArgOptions = {
	help: string?,
	aliases: { string }?,
	default: string?,
	required: boolean?,
	hidden: boolean?,
}

type ArgData = {
	name: string,
	kind: ArgKind,
	options: ArgOptions,
}

type CommandOptions = {
	help: string?,
	aliases: { string }?,
	hidden: boolean?,
}

type CommandData = {
	name: string,
	parser: Parser,
	options: CommandOptions,
}

type ParseResult = {
	values: { [string]: string? },
	flags: { [string]: boolean },
	variadics: { string },
	fwdArgs: { string },
}

type ParserData = {
	arguments: { [number]: ArgData },
	positional: { [number]: ArgData },
	variadicArg: ArgData?,
	commands: { [number]: CommandData },
	selectedCommand: CommandData?,
	parsed: ParseResult,
}

type ParserInterface = typeof(cli)

--[[
	A command-line argument parser.

	Create one with `cli.parser()`, declare arguments with `:add()` and
	subcommands with `:subcommand()`, then call `:parse()` and read the results
	with `:get()`, `:has()`, `:variadics()`, `:forwarded()` and `:selected()`.
]]
export type Parser = setmetatable<ParserData, ParserInterface>

--[[
	Creates a new, empty parser.

	@return A parser with no arguments or subcommands declared.
]]
function cli.parser(): Parser
	const self = {
		arguments = {},
		positional = {},
		variadicArg = nil :: ArgData?,
		commands = {},
		selectedCommand = nil :: CommandData?,
		parsed = { values = {}, flags = {}, variadics = {}, fwdArgs = {} },
	}

	return setmetatable(self, cli)
end

--[[
	Returns whether an argument or command answers to `name`, either as its own name or as one of its aliases.
]]
const function isNamed(entry: ArgData | CommandData, name: string): boolean
	const aliases = entry.options.aliases or {}

	return entry.name == name or table.find(aliases, name) ~= nil
end

const function findArgument(self: Parser, name: string): ArgData?
	for _, argument in self.arguments do
		if isNamed(argument, name) then
			return argument
		end
	end

	return nil
end

const function findCommand(self: Parser, name: string): CommandData?
	for _, command in self.commands do
		if isNamed(command, name) then
			return command
		end
	end

	return nil
end

--[[
	Declares an argument on the parser.

	Kinds:
	- "positional": a bare value, matched in declaration order.
	- "flag": a boolean switch, passed as `--name` or `-n`.
	- "option": a flag that takes the next argument as its value (`--name value`).
	- "variadic": collects all remaining bare values. A parser may have only one.

	Options:
	- help: description shown by `:help()`.
	- aliases: alternate names. Single-character aliases can be used as `-n`
	  and combined, e.g. `-abc`.
	- default: value used by `:get()` if none was given (values only, not flags).
	- required: `:parse()` asserts if the argument is missing.
	- hidden: omit from `:usage()` and `:help()`.

	Asserts if the name or any alias duplicates an existing argument, or if a
	second variadic argument is added.

	@param name The argument's canonical name, also the key used by `:get()` and `:has()`.
	@param kind The argument kind.
	@param options Optional settings for the argument.
]]
function cli.add(self: Parser, name: string, kind: ArgKind, options: ArgOptions?): ()
	const resolved: ArgOptions = options or { aliases = {}, required = false }

	-- lookups return the first match, so a repeated name or alias would be unreachable
	assert(findArgument(self, name) == nil, "Duplicate argument name: " .. name)

	const aliases = resolved.aliases or {}
	for index, alias in aliases do
		const repeated = alias == name or table.find(aliases, alias) ~= index or findArgument(self, alias) ~= nil
		assert(not repeated, "Duplicate argument alias: " .. alias)
	end

	-- a second variadic would replace the first, leaving it registered but unreachable
	assert(kind ~= "variadic" or self.variadicArg == nil, "A parser can only have one variadic argument: " .. name)

	const argument: ArgData = {
		name = name,
		kind = kind,
		options = resolved,
	}

	table.insert(self.arguments, argument)
	if kind == "positional" then
		table.insert(self.positional, argument)
	elseif kind == "variadic" then
		self.variadicArg = argument
	end
end

--[[
	Declares a subcommand and returns the parser that handles its arguments.

	Parsing stops at the subcommand's name and the remaining arguments are
	passed to the returned parser, so arguments declared on this (parent)
	parser must come before the subcommand on the command line.

	Options:
	- help: description shown by `:help()`.
	- aliases: alternate names that select the subcommand.
	- hidden: omit from `:usage()` and `:help()`.

	Asserts if the name or any alias duplicates an existing subcommand.

	@param name The subcommand name.
	@param options Optional settings for the subcommand.
	@return The subcommand's own parser, which can have its own arguments and subcommands.
]]
function cli.subcommand(self: Parser, name: string, options: CommandOptions?): Parser
	const resolved: CommandOptions = options or { aliases = {} }

	assert(findCommand(self, name) == nil, "Duplicate command name: " .. name)

	const aliases = resolved.aliases or {}
	for index, alias in aliases do
		const repeated = alias == name or table.find(aliases, alias) ~= index or findCommand(self, alias) ~= nil
		assert(not repeated, "Duplicate command alias: " .. alias)
	end

	const parser = cli.parser()

	table.insert(self.commands, {
		name = name,
		parser = parser,
		options = resolved,
	})

	return parser
end

--[[
	Parses a list of command-line arguments and stores the results on the parser.

	Bare words are matched in this order: subcommand, positional, variadic,
	then forwarded. A bare `--` stops parsing and forwards everything after it.
	Once a subcommand is selected, it parses the rest of the arguments.

	After parsing, required arguments are checked and defaults are applied.
	Errors are raised with `assert` for: unknown arguments, an option missing
	its value, a missing required argument, and an unknown command (only when
	the parser has subcommands but no positional or variadic arguments).

	@param args The arguments to parse, without the program name.
]]
function cli.parse(self: Parser, args: { string }): ()
	local i = 0
	local pos_index = 1

	while i < #args do
		i += 1

		const arg = args[i]

		-- if the argument is exactly "--", we pass everything along
		if arg == "--" then
			table.move(args, i + 1, #args, #self.parsed.fwdArgs + 1, self.parsed.fwdArgs)
			break
		end

		-- if the argument starts with two dashes, we're parsing either a flag or an option
		if string.sub(arg, 1, 2) == "--" then
			const name = string.sub(arg, 3)
			const argument = findArgument(self, name)

			assert(argument, "Unknown argument: " .. name)

			if argument.kind == "option" then
				-- advance past the argument
				i += 1

				assert(i <= #args, "Missing value for argument: " .. argument.name)
				self.parsed.values[argument.name] = args[i]
			else
				self.parsed.flags[argument.name] = true
			end

			continue
		end

		-- if the argument starts with a single dash, we're parsing a flag
		if string.sub(arg, 1, 1) == "-" then
			const flags = string.sub(arg, 2)

			for j = 1, #flags do
				const name = string.sub(flags, j, j)
				const argument = findArgument(self, name)

				assert(argument, "Unknown argument: " .. name)

				if argument.kind == "option" then
					i += 1
					assert(i <= #args, "Missing value for argument: " .. argument.name)
					self.parsed.values[argument.name] = args[i]
				else
					self.parsed.flags[argument.name] = true
				end
			end

			continue
		end

		-- if the argument names a subcommand, that subcommand takes over the rest of the arguments
		const command = findCommand(self, arg)
		if command then
			self.selectedCommand = command
			command.parser:parse(table.move(args, i + 1, #args, 1, {}))
			break
		end

		-- if we have positional arguments left, we can take this argument as one
		if pos_index <= #self.positional then
			self.parsed.values[self.positional[pos_index].name] = arg
			pos_index += 1
			continue
		end

		-- if we have a variadic argument, we can take this argument as part of it
		if self.variadicArg then
			table.insert(self.parsed.variadics, arg)
			continue
		end

		-- a parser that declares subcommands but no positional or variadic has nothing else
		-- this argument could have meant, so report a mistyped command the way unknown flags
		-- are reported instead of quietly forwarding it. parsers that do declare one keep
		-- forwarding, since there an unrecognized word is not necessarily a command at all
		const absorbs = #self.positional > 0 or self.variadicArg ~= nil
		assert(#self.commands == 0 or absorbs, "Unknown command: " .. arg)

		-- otherwise, the argument is forwarded on
		table.insert(self.parsed.fwdArgs, arg)
	end

	-- check that all required arguments are present, and set any default values as needed
	const selected = self.selectedCommand
	const ordering = if selected then ` (it has to be given before the '{selected.name}' command)` else ""

	for _, argument in self.arguments do
		if argument.options.required then
			if argument.kind == "variadic" then
				assert(#self.parsed.variadics > 0, "Missing required variadic argument: " .. argument.name .. ordering)
			else
				assert(self.parsed.values[argument.name], "Missing required argument: " .. argument.name .. ordering)
			end
		end

		if self.parsed.values[argument.name] == nil and argument.options.default then
			self.parsed.values[argument.name] = argument.options.default
		end
	end
end

--[[
	Returns the value of a positional argument or option.

	@param name The argument's canonical name (aliases are not accepted).
	@return The value given on the command line, the default if one was set, or nil.
]]
function cli.get(self: Parser, name: string): string?
	return self.parsed.values[name]
end

--[[
	Returns whether a flag was passed.

	@param name The flag's canonical name (aliases are not accepted).
	@return true if the flag was present, false otherwise.
]]
function cli.has(self: Parser, name: string): boolean
	return self.parsed.flags[name] ~= nil
end

--[[
	Returns the values collected by the variadic argument.

	@return The variadic values in the order given, or an empty table if there were none.
]]
function cli.variadics(self: Parser): { string }
	return self.parsed.variadics
end

--[[
	Returns arguments that were passed through rather than parsed: everything
	after a bare `--`, plus any bare words no argument or subcommand claimed.

	@return The forwarded arguments in the order given.
]]
function cli.forwarded(self: Parser): { string }?
	return self.parsed.fwdArgs
end

--[[
	Returns the subcommand chosen during parsing.

	@return The subcommand's name and its parser, or nil, nil if none was selected.
]]
function cli.selected(self: Parser): (string?, Parser?)
	const command = self.selectedCommand
	if not command then
		return nil, nil
	end

	return command.name, command.parser
end

--[[
	Builds a one-line usage string, e.g. `Usage: tool <command> <input> [options]`.

	Shows `<command>` if any visible subcommands exist, then positionals
	(`<name>` if required, `[name]` if optional), `[options]` if any visible
	flags or options exist, then the variadic argument (`<name...>` or
	`[name...]`). Hidden entries are omitted.

	@param name The program or command name to show in the usage line.
	@return The usage string.
]]
function cli.usage(self: Parser, name: string): string
	const parts = { `Usage: {name}` }

	-- subcommands are matched before positionals in parse, so they are listed in that order
	for _, command in self.commands do
		if not command.options.hidden then
			table.insert(parts, "<command>")
			break
		end
	end

	for _, arg in self.positional do
		if not arg.options.hidden then
			if arg.options.required then
				table.insert(parts, `<{arg.name}>`)
			else
				table.insert(parts, `[{arg.name}]`)
			end
		end
	end

	for _, arg in self.arguments do
		if not arg.options.hidden and arg.kind ~= "positional" and arg.kind ~= "variadic" then
			table.insert(parts, "[options]")
			break
		end
	end

	if self.variadicArg and not self.variadicArg.options.hidden then
		const v = self.variadicArg
		if v.options.required then
			table.insert(parts, `<{v.name}...>`)
		else
			table.insert(parts, `[{v.name}...]`)
		end
	end

	return table.concat(parts, " ")
end

const function label(argument: ArgData): string
	if argument.kind == "positional" or argument.kind == "variadic" then
		const name = if argument.kind == "variadic" then `{argument.name}...` else argument.name
		return if argument.options.required then `<{name}>` else `[{name}]`
	end

	const aliasStr = table.concat(argument.options.aliases or {}, ", ")
	return `--{argument.name}{if #aliasStr > 0 then ` (-{aliasStr})` else ""}`
end

const function commandLabel(command: CommandData): string
	const aliasStr = table.concat(command.options.aliases or {}, ", ")
	return `{command.name}{if #aliasStr > 0 then ` ({aliasStr})` else ""}`
end

--[[
	Builds multi-line help text listing visible subcommands under "Commands:"
	and visible arguments under "Options:".

	Arguments are shown as `--name (-alias)` for flags and options, and as
	`<name>` / `[name]` for positionals and variadics. Required arguments are
	marked "(required)". Hidden entries are omitted.

	@param formatter Optional function applied to each line, e.g. to add colors.
	@return The help text.
]]
function cli.help(self: Parser, formatter: ((s: string) -> string)?): string
	const fmt = formatter or function(s)
		return s
	end

	const lines: { string } = {}

	local hasCommands = false
	for _, command in self.commands do
		if command.options.hidden then
			continue
		end

		if not hasCommands then
			table.insert(lines, fmt("Commands:"))
			hasCommands = true
		end

		table.insert(lines, fmt(`  {commandLabel(command)} - {command.options.help or ""}`))
	end

	if hasCommands then
		table.insert(lines, "")
	end

	table.insert(lines, fmt("Options:"))
	for _, argument in self.arguments do
		if argument.options.hidden then
			continue
		end

		const reqStr = if argument.options.required then "(required) " else ""
		table.insert(lines, fmt(`  {label(argument)} - {reqStr}{argument.options.help or ""}`))
	end

	return table.concat(lines, "\n")
end

return table.freeze(cli)
