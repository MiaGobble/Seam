local OnChanged = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Symbol = require(Modules.Symbol)

OnChanged.__SEAM_INDEX = Symbol.new("OnChanged")
OnChanged.__SEAM_CAN_BE_SCOPED = true

function OnChanged.__CALLBACK(self : Types.ConstructorCompiled, object : any, callback : (propertyChanged : string, newValue : any) -> nil) : RBXScriptConnection
	-- Fortunately, states also have a Changed signal, so this works out perfectly
	-- for states as well!

	return (object.Changed :: RBXScriptSignal):Connect(function(propertyName : string)
		callback(propertyName, object[propertyName])
	end)
end

return Compiler.CompileConstructor(OnChanged) :: Types.OnChanged
