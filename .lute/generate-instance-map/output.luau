--[[
	Console output for subcommands.

	Subcommands print through an `Output` instead of calling `print` directly, so tests can capture what they print.
	Nothing here exits the process; subcommands return exit codes instead.

	The console writes warnings and errors to stderr with `io.ewrite` and everything else to stdout with `io.write`, so
	redirecting stdout keeps the output and still shows problems in the terminal. Neither is buffered the way `print`
	is, so a message such as the command about to run shows up before that command finishes, and the two streams stay
	in order in a terminal. Needs Lute 1.0.1-nightly.20261119 or newer: older builds have no `io.ewrite`, and block
	forever in `io.write` when stdout is redirected to a file.

	Example:
	```luau
	const out, lines = output.capture()
	out.error("something failed")
	print(lines[1]) -- error: something failed
	```
]]

const io = require("@std/io")
const process = require("@std/process")

const ansi = require("./lib/ansi-format")

-- Types --
export type Output = {
	--- Plain text, e.g. a rendered manifest
	plain: (message: string) -> (),
	info: (message: string) -> (),
	success: (message: string) -> (),
	warn: (message: string) -> (),
	error: (message: string) -> (),
	--- Low-importance detail
	verbose: (message: string) -> (),
}

-- Functions --

const function writeLine(message: string)
	io.write(message, "\n")
end

const function writeErrorLine(message: string)
	io.ewrite(message, "\n")
end

const function colored(color: string, write: (message: string) -> ()): (message: string) -> ()
	-- https://no-color.org
	const noColor = process.env.NO_COLOR
	if noColor and noColor ~= "" then
		return write
	end

	return function(message: string)
		write(ansi.colorForeground(message, color))
	end
end

--[[
	Output that prints to the terminal, with colours unless `NO_COLOR` is set. Warnings and errors go to stderr.
]]
const function console(): Output
	return {
		plain = writeLine,
		info = colored("Cyan", writeLine),
		success = colored("Green", writeLine),
		warn = colored("Yellow", writeErrorLine),
		error = colored("Red", writeErrorLine),
		verbose = colored("Bright Black", writeLine),
	}
end

--[[
	Output that records messages instead of printing them.

	@return The output, and the list it appends `"<level>: <message>"` lines to.
]]
const function capture(): (Output, { string })
	const lines: { string } = {}
	const function recorder(level: string): (message: string) -> ()
		return function(message: string)
			table.insert(lines, `{level}: {message}`)
		end
	end

	-- stylua: ignore
	return {
		plain = recorder("plain"),
		info = recorder("info"),
		success = recorder("success"),
		warn = recorder("warn"),
		error = recorder("error"),
		verbose = recorder("verbose"),
	}, lines
end

return table.freeze({
	console = console,
	capture = capture,
})
