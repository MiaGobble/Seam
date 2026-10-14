local LockValue = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)

LockValue.__SEAM_CAN_BE_SCOPED = false

function LockValue.__CALLBACK(_ : Types.ConstructorCompiled, lockedValue : Types.ValueInstance<any>) : nil
	if typeof(lockedValue) ~= "table" or not lockedValue.__SEAM_OBJECT or tostring(lockedValue.__SEAM_OBJECT) ~= "Value" then
		error("You can only lock a value state")
	end

	lockedValue.__LOCKED = true
end

return Compiler.CompileConstructor(LockValue) :: Types.LockValue
