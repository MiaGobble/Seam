-- Author: iGottic

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Symbol = require(Modules.Symbol)

-- Class
local OnChanged : Types.ConstructorDecompiled = {}

OnChanged.__SEAM_INDEX = Symbol.new("OnChanged")
OnChanged.__SEAM_CAN_BE_SCOPED = true

function OnChanged.__CALLBACK(self : Types.ConstructorCompiled, Object : any, Callback : (PropertyChanged : string, NewValue : any) -> nil) : RBXScriptConnection
    -- Fortunately, states also have a Changed signal, so this works out perfectly 
    -- for states as well!

    return (Object.Changed :: RBXScriptSignal):Connect(function(PropertyName : string)
        Callback(PropertyName, Object[PropertyName])
    end)
end

return Compiler.CompileConstructor(OnChanged) :: Types.OnChanged