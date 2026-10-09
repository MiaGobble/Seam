-- Author: iGottic

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)

-- Constants
local RECOGNIZED_STATE_SYMBOLS = {"Spring", "Tween", "Bezier", "Resource", "ComputedInstance", "RenderedInstance", "Value"}

-- Class
local IsState : Types.ConstructorDecompiled = {}

IsState.__SEAM_CAN_BE_SCOPED = false

function IsState.__CALLBACK(_: Types.ConstructorCompiled, CheckedValue : any?) : boolean
    if typeof(CheckedValue) ~= "table" then
        return false -- Not a state since it's not a table
    end

    if not CheckedValue.__SEAM_OBJECT then
        return false -- Not a state since it's not from Seam or not a Seam object
    end

    if table.find(RECOGNIZED_STATE_SYMBOLS, tostring(CheckedValue.__SEAM_OBJECT)) then
        return true -- Is a state since the symbol can be coerced into a string from the recognized state symbols table
    end

    return false -- Default to false
end

return Compiler.CompileConstructor(IsState) :: Types.IsState