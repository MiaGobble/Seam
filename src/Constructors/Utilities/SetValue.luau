-- Author: iGottic

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)

-- Class
local SetValue : Types.ConstructorDecompiled = {}

SetValue.__SEAM_CAN_BE_SCOPED = false

function SetValue.__CALLBACK(_: Types.ConstructorCompiled, State : any?, NewValue : any?) : any?
    if State == nil then
        return NewValue
    end

    if typeof(State) == "table" and State.Value ~= nil then
        State.Value = NewValue
    end

    return NewValue
end

return Compiler.CompileConstructor(SetValue) :: Types.SetValue
