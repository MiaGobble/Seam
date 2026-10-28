local IsState = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)

local RECOGNIZED_STATE_SYMBOLS = {
	Spring = true,
	Tween = true,
	Bezier = true,
	Resource = true,
	ComputedInstance = true,
	RenderedInstance = true,
	Value = true,
}

IsState.__SEAM_CAN_BE_SCOPED = false

function IsState.__CALLBACK(_ : Types.ConstructorCompiled, checkedValue : any?) : boolean
	if typeof(checkedValue) ~= "table" then
		return false
	end

	if checkedValue.__SEAM_IS_STATE then
		return true
	end

	if not checkedValue.__SEAM_OBJECT then
		return false
	end

	if RECOGNIZED_STATE_SYMBOLS[tostring(checkedValue.__SEAM_OBJECT)] then
		return true
	end

	return false
end

return Compiler.CompileConstructor(IsState) :: Types.IsState
