-- Author: iGottic

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Symbol = require(Modules.Symbol)

-- Class
local Component : Types.ConstructorDecompiled = {}

function Component.__CALLBACK(_: Types.ConstructorCompiled, ComponentModule : {[any] : any})
    -- This function just validates what we have and turns the module into a class

    if not ComponentModule.Init then
        error("Component requires an Init() method")
    end

    if not ComponentModule.Construct then
        error("Component requires a Construct() method")
    end

    ComponentModule.__index = ComponentModule

    local ComponentObject : Types.ObjectDecompiled = {
        __SEAM_COMPONENT = Symbol.new("Component"),
    }

    function ComponentObject.__CALLBACK(_: Types.ObjectCompiled, ThisScope : Types.ScopeInstance?, Properties : {[string] : any}) : any
        local ClassInstance = setmetatable({}, ComponentModule) -- OOP but only kinda

        ClassInstance:Init(ThisScope, Properties)

        return ClassInstance:Construct(ThisScope, Properties)
    end

    function ComponentObject.__INDEX(_: Types.ObjectCompiled, Index : string)
        return ComponentModule[Index]
    end

    function ComponentObject.__NEWINDEX(_: Types.ObjectCompiled, Index : string, Value : any?)
        ComponentModule[Index] = Value
    end

    return Compiler.CompileObject(ComponentObject) :: (ThisScope : Types.ScopeInstance?, Properties : {[string] : any}) -> any
end

return Compiler.CompileConstructor(Component) :: Types.Component
