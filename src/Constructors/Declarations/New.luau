local New = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Symbol = require(Modules.Symbol)
local CreateDeepTraceback = require(Modules.CreateDeepTraceback)
local Children = require(script.Parent.Children)

New.__SEAM_OBJECT = Symbol.new("New")
New.__SEAM_CAN_BE_SCOPED = true

function New.__CALLBACK(_ : Types.ConstructorCompiled, class : string | Instance | (Types.ScopeInstance?, {[any] : any}) -> any, properties : {[any] : any}, thisScope : Types.ScopeInstance?)
	local Object = nil

	if typeof(class) == "Instance" then
		-- Hydration
		Object = class
	elseif typeof(class) == "string" then
		-- Construction
		Object = Instance.new(class)
	elseif typeof(class) == "table" and class.__SEAM_COMPONENT then
		-- Custom component
		Object = nil
	else
		-- Invalid class
		error(`Invalid class type! Expected string or instance, got {typeof(class)}: {CreateDeepTraceback()}`)
	end

	if Object then
		-- Normal construction or hydration
		for index, property in properties do
			if typeof(index) == "table" then
				if index.__SEAM_INDEX then
					-- A seam index is something like Attribute, Children, or Lifetime
					index(Object, property)
				else
					error(`Object hydration recieved invalid index type! Expected Seam object or string, got table ({Object:GetFullName()}); {CreateDeepTraceback()}`)
				end
			elseif typeof(index) == "number" then -- Allows for implicit
				Children(Object, property)
			elseif typeof(property) == "table" then
				if property.__SEAM_OBJECT then
					-- A seam object is something like Computed, Value, or Spring
					property(Object, index)
				else
					error(`Invalid property type! Expected Seam object or string, got table: {CreateDeepTraceback()}`)
				end
			else
				Object[index] = property
			end
		end
	else
		-- Custom component
		Object = class(thisScope, properties)
	end

	return Object
end

return Compiler.CompileConstructor(New) :: Types.NewConstructor
