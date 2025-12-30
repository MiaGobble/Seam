-- Author: iGottic

--[=[
    @class New
    @since 0.0.1
]=]

local New = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Symbol = require(Modules.Symbol)
local Scope = require(script.Parent.Parent.Memory.Scope)

-- Types extended
export type NewConstructor = (Class : string | Instance | (Scope.ScopeInstance?, {[any] : any}) -> any, Properties : {[any] : any}) -> Instance

-- Variables
local ClassSymbol = Symbol.new("New")

--[=[
    Constructs a new instance or hydrates an existing one with given properties.

    @param Class string | Instance -- The class name of the instance
    @return ({[any] : any})) -> Instance -- The function to hydrate the instance properties
]=]

function New:__call(Class : string | Instance | (Scope.ScopeInstance?, {[any] : any}) -> any, Properties : {[any] : any}, ThisScope : Scope.ScopeInstance?)
    local Object = nil

    if typeof(Class) == "Instance" then
        -- Hydration
        Object = Class
    elseif typeof(Class) == "string" then
        -- Construction
        Object = Instance.new(Class)
    elseif typeof(Class) == "table" and Class.__SEAM_COMPONENT then
        -- Custom component
        Object = nil
    else
        -- Invalid class
        error("Invalid class type! Expected string or instance, got " .. typeof(Class))
    end

    if Object then
        -- Normal construction or hydration
        for Index, Property in Properties do
            if typeof(Index) == "table" then
                if Index.__SEAM_INDEX then
                    -- A seam index is something like Attribute, Children, or Lifetime
                    Index(Object, Property)
                else
                    error(`Object hydration recieved invalid index type! Expected Seam object or string, got table ({Object:GetFullName()})`)
                end
            elseif typeof(Property) == "table" then
                if Property.__SEAM_OBJECT then
                    -- A seam object is something like Computed, Value, or Spring
                    Property(Object, Index)
                else
                    error("Invalid property type! Expected Seam object or string, got table")
                end
            else
                Object[Index] = Property
            end
        end
    else
        -- Custom component
        Object = Class(ThisScope, Properties)
    end

    return Object
end

--[=[
    @ignore
]=]

function New:__index(Index : string)
    if Index == "__SEAM_OBJECT" then
        return ClassSymbol
    elseif Index == "__SEAM_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

local Meta = setmetatable({}, New)

return Meta :: NewConstructor