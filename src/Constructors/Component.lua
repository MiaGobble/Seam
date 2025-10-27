-- Author: iGottic

--[=[
    @class Component
    @since 0.3.0
]=]

-- Types
export type Component = ({[any] : any}) -> (Scope.ScopeInstance?, {[string] : any}) -> any

-- Imports
local Scope = require(script.Parent.Scope)

local function Component(ComponentModule : {[any] : any})
    -- This function just validates what we have and turns the module into a class
    
    if not ComponentModule.Init then
        error("Component requires an Init() method")
    end

    if not ComponentModule.Construct then
        error("Component requires a Construct() method")
    end

    ComponentModule.__index = ComponentModule

    return function(ThisScope : Scope.ScopeInstance?, Properties : {[string] : any}) : any
        local ClassInstance = setmetatable({}, ComponentModule) -- OOP but only kinda

        ClassInstance:Init(ThisScope, Properties)

        return ClassInstance:Construct(ThisScope, Properties)
    end
end

return Component :: Component