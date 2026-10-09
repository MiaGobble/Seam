-- Author: iGottic

-- Services
local DebrisService = game:GetService("Debris")

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Symbol = require(Modules.Symbol)

-- Class
local Lifetime : Types.ConstructorDecompiled = {}

Lifetime.__SEAM_INDEX = Symbol.new("Lifetime")
Lifetime.__SEAM_CAN_BE_SCOPED = false

function Lifetime.__CALLBACK(_: Types.ConstructorCompiled, Object : Instance, CleanupTime : number)
    -- This is really simple, but the reason I use Debris service
    -- over a task.delay() is because it guarantees error-free cleanup

    DebrisService:AddItem(Object, CleanupTime)
end

return Compiler.CompileConstructor(Lifetime) :: Types.Lifetime
