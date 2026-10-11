local Inspect = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)

Inspect.__SEAM_CAN_BE_SCOPED = true

function Inspect.__CALLBACK(_ : Types.ConstructorCompiled, object : any, debugName : string)
	if not debugName then
		error("Expected DebugName, got nil")
	end

	return (object.Changed :: RBXScriptSignal):Connect(function(propertyName : string)
		if not propertyName then
			print(`SEAM_{debugName}.Value changed, unknown property that changed`)
			return
		end

		print(`SEAM_{debugName}.Value = {object[propertyName]}`)
	end)
end

return Compiler.CompileConstructor(Inspect) :: Types.Inspect
