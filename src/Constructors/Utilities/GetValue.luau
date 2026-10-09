-- Author: iGottic

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local IsState = require(script.Parent.IsState)

-- Class
local GetValue : Types.ConstructorDecompiled = {}

GetValue.__SEAM_CAN_BE_SCOPED = false

function GetValue.__CALLBACK(_: Types.ConstructorCompiled, State : any?) : any?
    -- Nothing exists? No problem.
    if State == nil then
        return nil
    end

    -- Is it a state? Return the value of that state.
    if IsState(State) then
        return State.Value
    end

    -- Just normal userdata? That's cool too.
    return State
end

return Compiler.CompileConstructor(GetValue) :: Types.GetValue
