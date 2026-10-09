-- Author: iGottic

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Symbol = require(Modules.Symbol)

-- Class
local Tags : Types.ConstructorDecompiled = {}

Tags.__SEAM_INDEX = Symbol.new("Tags")
Tags.__SEAM_CAN_BE_SCOPED = false

function Tags.__CALLBACK(_: Types.ConstructorCompiled, Object : Instance, AddedTags : {string})
    for _, Tag in AddedTags do -- Super simple iteration through strings
        Object:AddTag(Tag)
    end

    return function()
        for _, Tag in AddedTags do
            Object:RemoveTag(Tag)
        end
    end
end

return Compiler.CompileConstructor(Tags) :: Types.Tags
