-- Author: iGottic

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Symbol = require(Modules.Symbol)

-- Class
local Destroyed : Types.ConstructorDecompiled = {}

Destroyed.__SEAM_INDEX = Symbol.new("Destroyed")
Destroyed.__SEAM_CAN_BE_SCOPED = false

function Destroyed.__CALLBACK(_: Types.ConstructorCompiled, Object : Instance, Callback : () -> nil)
    Object.Destroying:Once(Callback)
end

return Compiler.CompileConstructor(Destroyed) :: Types.Destroyed
