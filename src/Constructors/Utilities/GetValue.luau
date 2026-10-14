local GetValue = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local IsState = require(script.Parent.IsState)

GetValue.__SEAM_CAN_BE_SCOPED = false

function GetValue.__CALLBACK(_ : Types.ConstructorCompiled, state : any?) : any?
	-- Nothing exists? No problem.
	if state == nil then
		return nil
	end

	-- Is it a state? Return the value of that state.
	if IsState(state) then
		return state.Value
	end

	-- Just normal userdata? That's cool too.
	return state
end

return Compiler.CompileConstructor(GetValue) :: Types.GetValue
