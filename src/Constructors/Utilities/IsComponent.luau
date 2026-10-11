local IsComponent = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)

IsComponent.__SEAM_CAN_BE_SCOPED = false

function IsComponent.__CALLBACK(_ : Types.ConstructorCompiled, checkedValue : any?) : boolean
	if typeof(checkedValue) ~= "table" then
		return false -- Not a component since it's not a table
	end

	if checkedValue.__SEAM_COMPONENT then
		return true -- Is a state since the value has a component symbol
	end

	return false -- Default to false
end

return Compiler.CompileConstructor(IsComponent) :: Types.IsComponent
