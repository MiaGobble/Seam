local SetValue = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)

SetValue.__SEAM_CAN_BE_SCOPED = false

function SetValue.__CALLBACK(_ : Types.ConstructorCompiled, state : any?, newValue : any?) : any?
	if state == nil then
		return newValue
	end

	if typeof(state) == "table" and state.Value ~= nil then
		state.Value = newValue
	end

	return newValue
end

return Compiler.CompileConstructor(SetValue) :: Types.SetValue
