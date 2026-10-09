-- Author: iGottic

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Symbol = require(Modules.Symbol)
local CreateDeepTraceback = require(Modules.CreateDeepTraceback)
local Children = require(script.Parent.Children)

-- Class
local New : Types.ConstructorDecompiled = {}

New.__SEAM_OBJECT = Symbol.new("New")
New.__SEAM_CAN_BE_SCOPED = true

function New.__CALLBACK(_: Types.ConstructorCompiled, Class : string | Instance | (Types.ScopeInstance?, {[any] : any}) -> any, Properties : {[any] : any}, ThisScope : Types.ScopeInstance?)
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
                    -- A seam index is something like Attribute, Children, or Lifetime
                    Index(Object, Property)
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

return Compiler.CompileConstructor(New) :: Types.NewConstructor
