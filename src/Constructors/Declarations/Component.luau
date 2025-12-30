-- Author: iGottic

--[=[
    @class Component
    @since 0.3.0
]=]

-- Imports
local Scope = require(script.Parent.Parent.Memory.Scope)
local Symbol = require(script.Parent.Parent.Parent.Modules.Symbol)

-- Types extended
export type Component = ({[any] : any}) -> (Scope.ScopeInstance?, {[string] : any}) -> any

local function Component(ComponentModule : {[any] : any})
    -- This function just validates what we have and turns the module into a class
    
    if not ComponentModule.Init then
        error("Component requires an Init() method")
    end

    if not ComponentModule.Construct then
        error("Component requires a Construct() method")
    end

    ComponentModule.__index = ComponentModule

    -- ThisScope : Scope.ScopeInstance?, Properties : {[string] : any}

    local ComponentSymbol = Symbol.new("Component")

    local Meta = setmetatable({}, {
        __call = function(_, ThisScope : Scope.ScopeInstance?, Properties : {[string] : any}) : any
            local ClassInstance = setmetatable({}, ComponentModule) -- OOP but only kinda

            ClassInstance:Init(ThisScope, Properties)

            return ClassInstance:Construct(ThisScope, Properties)
        end,

        __index = function(_, Index : string)
            if Index == "__SEAM_COMPONENT" then
                return ComponentSymbol
            end

            return ComponentModule[Index]
        end,

        __newindex = function(_, Index : string, Value : any?)
            ComponentModule[Index] = Value
        end
    })

    return Meta :: (ThisScope : Scope.ScopeInstance?, Properties : {[string] : any}) -> any
end

return Component :: Component