local Component = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Symbol = require(Modules.Symbol)

function Component.__CALLBACK(_ : Types.ConstructorCompiled, componentModule : {[any] : any})
	-- This function just validates what we have and turns the module into a class

	if not componentModule.Init then
		error("Component requires an Init() method")
	end

	if not componentModule.Construct then
		error("Component requires a Construct() method")
	end

	componentModule.__index = componentModule

	local ComponentObject : Types.ObjectDecompiled = {
		__SEAM_COMPONENT = Symbol.new("Component"),
	}

	function ComponentObject.__CALLBACK(_ : Types.ObjectCompiled, thisScope : Types.ScopeInstance?, properties : {[string] : any}) : any
		local ClassInstance = setmetatable({}, componentModule) -- OOP but only kinda

		ClassInstance:Init(thisScope, properties)

		return ClassInstance:Construct(thisScope, properties)
	end

	function ComponentObject.__INDEX(_ : Types.ObjectCompiled, index : string)
		return componentModule[index]
	end

	function ComponentObject.__NEWINDEX(_ : Types.ObjectCompiled, index : string, value : any?)
		componentModule[index] = value
	end

	return Compiler.CompileObject(ComponentObject) :: (thisScope : Types.ScopeInstance?, properties : {[string] : any}) -> any
end

return Compiler.CompileConstructor(Component) :: Types.Component
