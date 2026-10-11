local OnAttached = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Symbol = require(Modules.Symbol)

OnAttached.__SEAM_INDEX = Symbol.new("OnAttached")
OnAttached.__SEAM_CAN_BE_SCOPED = true

function OnAttached.__CALLBACK(self : Types.ConstructorCompiled, object : any, callback : (attachedInstance : Instance) -> nil)
	return (object.AttachedToInstance :: RBXScriptSignal):Connect(callback)
end

return Compiler.CompileConstructor(OnAttached) :: Types.OnAttached
