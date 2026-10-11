-- Author: iGottic

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)

-- Class
local Inspect : Types.ConstructorDecompiled = {}

Inspect.__SEAM_CAN_BE_SCOPED = true

function Inspect.__CALLBACK(_: Types.ConstructorCompiled, Object : any, DebugName : string)
    if not DebugName then
        error("Expected DebugName, got nil")
    end

    return (Object.Changed :: RBXScriptSignal):Connect(function(PropertyName : string)
        if not PropertyName then
            print(`SEAM_{DebugName}.Value changed, unknown property that changed`)
            return
        end

        print(`SEAM_{DebugName}.Value = {Object[PropertyName]}`)
    end)
end

return Compiler.CompileConstructor(Inspect) :: Types.Inspect