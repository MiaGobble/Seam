-- Author: iGottic

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Symbol = require(Modules.Symbol)

-- Class
local OnAttached : Types.ConstructorDecompiled = {}

OnAttached.__SEAM_INDEX = Symbol.new("OnAttached")
OnAttached.__SEAM_CAN_BE_SCOPED = true

function OnAttached.Callback(self : Types.ConstructorCompiled, Object : any, Callback : (AttachedInstance : Instance) -> nil)
    return (Object.AttachedToInstance :: RBXScriptSignal):Connect(Callback)
end

return Compiler.CompileConstructor(OnAttached) :: Types.OnAttached