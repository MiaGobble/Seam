-- Helpers --

const function esc(text: string): (string)
	return "\x1b[" .. text
end

const function escClosed(text: string, terminator: string?): (string)
	terminator = if terminator then "\x1b[" .. terminator else "\x1b[0m"

	return "\x1b[" .. text .. terminator
end

const function rgb3(text: string, r: number, g: number, b: number): (string)
	return `{r // 1};{g // 1};{b // 1}m{text}`
end

const function isIntInRange(n: number, min: number, max: number): (boolean)
	return n >= min and n <= max and n // 1 == n
end

-- Module --
const AnsiFormat = {}

-- Coloring
const FG_COLOR_NAME_MAP = {
	Black = "30m",
	Red = "31m",
	Green = "32m",
	Yellow = "33m",
	Blue = "34m",
	Magenta = "35m",
	Cyan = "36m",
	White = "37m",
	Default = "39m",
	["Bright Black"] = "90m",
	["Bright Red"] = "91m",
	["Bright Green"] = "92m",
	["Bright Yellow"] = "93m",
	["Bright Blue"] = "94m",
	["Bright Magenta"] = "95m",
	["Bright Cyan"] = "96m",
	["Bright White"] = "97m",
}

const BG_COLOR_NAME_MAP = {
	Black = "40m",
	Red = "41m",
	Green = "42m",
	Yellow = "43m",
	Blue = "44m",
	Magenta = "45m",
	Cyan = "46m",
	White = "47m",
	Default = "49m",
	["Bright Black"] = "100m",
	["Bright Red"] = "101m",
	["Bright Green"] = "102m",
	["Bright Yellow"] = "103m",
	["Bright Blue"] = "104m",
	["Bright Magenta"] = "105m",
	["Bright Cyan"] = "106m",
	["Bright White"] = "107m",
}

const function resolveColor(color: string | number, map: typeof(FG_COLOR_NAME_MAP) | typeof(BG_COLOR_NAME_MAP), min: number, max: number)
	const colorType = typeof(color)
	local resolvedColor: string
	if colorType == "string" then
		resolvedColor = map[color] or map.Default
	elseif colorType == "number" then
		color = color :: number
		if isIntInRange(color, min, max) then
			resolvedColor = color .. "m"
		else
			resolvedColor = map.Default
		end
	else
		resolvedColor = map.Default
	end

	return resolvedColor
end

function AnsiFormat.colorForeground(text: string, color: keyof<typeof(FG_COLOR_NAME_MAP)> | string | number): (string)
	return escClosed(resolveColor(color, FG_COLOR_NAME_MAP, 30, 37) .. text, "39m")
end

function AnsiFormat.colorBackground(text: string, color: keyof<typeof(BG_COLOR_NAME_MAP)> | string | number): (string)
	return escClosed(resolveColor(color, BG_COLOR_NAME_MAP, 40, 47) .. text, "49m")
end

const function resolveColor256(color: number): (string)
	return if isIntInRange(color, 0, 255)
		then color .. "m"
		else "7m"
end

function AnsiFormat.colorForeground256(text: string, color: number): (string)
	return escClosed("38;5;" .. resolveColor256(color) .. text, "39m")
end

function AnsiFormat.colorBackground256(text: string, color: number): (string)
	return escClosed("48;5;" .. resolveColor256(color) .. text, "49m")
end

function AnsiFormat.colorForegroundRGB(text: string, r: number, g: number, b: number): (string)
	return escClosed("38;2;" .. rgb3(text, r, g, b), "39m")
end

function AnsiFormat.colorBackgroundRGB(text: string, r: number, g: number, b: number): (string)
	return escClosed("48;2;" .. rgb3(text, r, g, b), "49m")
end

-- Other SGR

function AnsiFormat.bold(text: string): (string)
	return escClosed("1m" .. text, "22m")
end

function AnsiFormat.faint(text: string): (string)
	return escClosed("2m" .. text, "22m")
end

function AnsiFormat.italic(text: string): (string)
	return escClosed("3m" .. text, "23m")
end

function AnsiFormat.underline(text: string): (string)
	return escClosed("4m" .. text, "24m")
end

-- Rarely supported.
--[[
function AnsiFormat.slowBlink(text: string): (string)
	return escClosed("5m" .. text, "25m")
end

function AnsiFormat.rapidBlink(text: string): (string)
	return escClosed("6m" .. text, "25m")
end
]]

function AnsiFormat.reverseColor(text: string): (string)
	return escClosed("7m" .. text, "27m")
end

function AnsiFormat.conceal(text: string): (string)
	return escClosed("8m" .. text, "28m")
end

function AnsiFormat.strike(text: string): (string)
	return escClosed("9m" .. text, "29m")
end

function AnsiFormat.altFont(font: number, text: string): (string)
	const resolvedFont = if isIntInRange(font, 11, 19)
		then font .. "m"
		else "10m"

	return escClosed(resolvedFont .. text, "10m")
end

function AnsiFormat.doubleUnderline(text: string): (string)
	return escClosed("21m" .. text, "24m")
end

-- Rarely supported
--[[
function AnsiFormat.frame(text: string): (string)
	return escClosed("51m" .. text, "54m")
end

function AnsiFormat.encircle(text: string): (string)
	return escClosed("52m" .. text, "54m")
end
]]

function AnsiFormat.overline(text: string): (string)
	return escClosed("53m" .. text, "55m")
end

-- CSI commands

function AnsiFormat.cursorUp(n: number?): (string)
	return esc((n or 1) .. "A")
end

function AnsiFormat.cursorDown(n: number?): (string)
	return esc((n or 1) .. "B")
end

function AnsiFormat.cursorForward(n: number?): (string)
	return esc((n or 1) .. "C")
end

function AnsiFormat.cursorBack(n: number?): (string)
	return esc((n or 1) .. "D")
end

function AnsiFormat.cursorNextLine(n: number?): (string)
	return esc((n or 1) .. "E")
end

function AnsiFormat.cursorPrevLine(n: number?): (string)
	return esc((n or 1) .. "F")
end

function AnsiFormat.cursorHorizontalAbs(n: number?): (string)
	return esc((n or 1) .. "G")
end

function AnsiFormat.cursorPosition(row: number?, column: number?): (string)
	return esc(`{row or 1};{column or 1}H`)
end

function AnsiFormat.cursorPositionXY(x: number?, y: number?): (string)
	return esc(`{y or 1};{x or 1}H`)
end

const ERASE_MAP = {
	["FromCursor"] = 0,
	["ToCursor"] = 1,
	["All"] = 2
}

function AnsiFormat.eraseDisplay(n: number | keyof<typeof(ERASE_MAP)>?): (string)
	const nType = typeof(n)
	local resolvedN: string
	if nType == "string" then
		resolvedN = ERASE_MAP[n] or "0"
	elseif nType == "number" then
		if isIntInRange(n :: number, 0, 3) then
			resolvedN = tostring(n)
		end
	else
		resolvedN = "0"
	end

	return esc(resolvedN .. "J")
end

function AnsiFormat.eraseLine(n: number | keyof<typeof(ERASE_MAP)>?): (string)
	const nType = typeof(n)
	local resolvedN: string
	if nType == "string" then
		resolvedN = ERASE_MAP[n] or "0"
	elseif nType == "number" then
		if isIntInRange(n :: number, 0, 2) then
			resolvedN = tostring(n)
		else
			resolvedN = "0"
		end
	else
		resolvedN = "0"
	end

	return esc(resolvedN .. "K")
end

function AnsiFormat.scrollUp(n: number?): (string)
	return esc((n or 1) .. "S")
end

function AnsiFormat.scrollDown(n: number?): (string)
	return esc((n or 1) .. "T")
end

return AnsiFormat