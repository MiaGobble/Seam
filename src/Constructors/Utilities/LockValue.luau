-- Author: iGottic

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)

-- Class
local LockValue : Types.ConstructorDecompiled = {}

LockValue.__SEAM_CAN_BE_SCOPED = false

function LockValue.__CALLBACK(_: Types.ConstructorCompiled, LockedValue : Types.ValueInstance<any>) : nil
    if typeof(LockedValue) ~= "table" or not LockedValue.__SEAM_OBJECT or tostring(LockedValue.__SEAM_OBJECT) ~= "Value" then
        error("You can only lock a value state")
    end

    LockedValue.__LOCKED = true
end

return Compiler.CompileConstructor(LockValue) :: Types.LockValue