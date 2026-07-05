-- Author: iGottic

local New = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Symbol = require(Modules.Symbol)
local CreateDeepTraceback = require(Modules.CreateDeepTraceback)
local Scope = require(script.Parent.Parent.Memory.Scope)
local Children = require(script.Parent.Children)

-- Types extended
export type NewConstructor = (Class : string | Instance | (Scope.ScopeInstance?, {[any] : any}) -> any, Properties : {[any] : any}) -> Instance

-- Variables
local ClassSymbol = Symbol.new("New")

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
        error(`Invalid class type! Expected string or instance, got {typeof(Class)}: {CreateDeepTraceback()}`)
    end

    if Object then
        -- Normal construction or hydration
        for Index, Property in Properties do
            if typeof(Index) == "table" then
                if Index.__SEAM_INDEX then
                    -- A seam index is something like Attribute, Children, Stylesheet, or Lifetime
                    task.defer(function()
                        Index(Object, Property)
                    end)
                else
                    error(`Object hydration recieved invalid index type! Expected Seam object or string, got table ({Object:GetFullName()}); {CreateDeepTraceback()}`)
                end
            elseif typeof(Index) == "number" then -- Allows for implicit
                Children(Object, Property)
            elseif typeof(Property) == "table" then
                if Property.__SEAM_OBJECT then
                    -- A seam object is something like Computed, Value, or Spring
                    Property(Object, Index)
                else
                    error(`Invalid property type! Expected Seam object or string, got table: {CreateDeepTraceback()}`)
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