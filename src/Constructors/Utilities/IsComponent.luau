-- Author: iGottic

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)

-- Class
local IsComponent : Types.ConstructorDecompiled = {}

IsComponent.__SEAM_CAN_BE_SCOPED = false

function IsComponent.__CALLBACK(_: Types.ConstructorCompiled, CheckedValue : any?) : boolean
    if typeof(CheckedValue) ~= "table" then
        return false -- Not a component since it's not a table
    end

    if CheckedValue.__SEAM_COMPONENT then
        return true -- Is a state since the value has a component symbol
    end

    return false -- Default to false
end

return Compiler.CompileConstructor(IsComponent) :: Types.IsComponent