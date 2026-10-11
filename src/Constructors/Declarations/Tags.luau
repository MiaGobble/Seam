local Tags = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Symbol = require(Modules.Symbol)

Tags.__SEAM_INDEX = Symbol.new("Tags")
Tags.__SEAM_CAN_BE_SCOPED = false

function Tags.__CALLBACK(_ : Types.ConstructorCompiled, object : Instance, addedTags : {string})
	for _, tag in addedTags do -- Super simple iteration through strings
		object:AddTag(tag)
	end

	return function()
		for _, tag in addedTags do
			object:RemoveTag(tag)
		end
	end
end

return Compiler.CompileConstructor(Tags) :: Types.Tags
