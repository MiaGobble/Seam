const process = require("@std/process")
const ansi = require("./ansi-format")

const colorOutput = {}

function colorOutput.info(msg: string): ()
	print(ansi.colorForeground(msg, "Cyan"))
end

function colorOutput.verbose(msg: string)
	print(ansi.colorForeground(msg, "Bright Black"))
end

function colorOutput.warn(msg: string)
	print(ansi.colorForeground(msg, "Yellow"))
end

function colorOutput.fail(msg: string, continueOnFail: boolean?, exitcode: number?): ()
	print(ansi.colorForeground(msg, "Red"))

	if not continueOnFail then
		process.exit(exitcode or 1)
	end
end

function colorOutput.fatal(msg: string, exitcode: number?): ()
	print(ansi.colorForeground(msg, "Red"))
	process.exit(exitcode or 1)
end

return colorOutput