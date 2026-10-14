local Destroyed = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Symbol = require(Modules.Symbol)

Destroyed.__SEAM_INDEX = Symbol.new("Destroyed")
Destroyed.__SEAM_CAN_BE_SCOPED = false

function Destroyed.__CALLBACK(_ : Types.ConstructorCompiled, object : Instance, callback : () -> nil)
	object.Destroying:Once(callback)
end

return Compiler.CompileConstructor(Destroyed) :: Types.Destroyed
