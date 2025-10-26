-- Author: iGottic

--[=[
    @class New
    @since 0.0.1
]=]

local New = {}

-- Types
export type NewConstructor = (Class : string | Instance, Properties : {[any] : any}) -> Instance

-- Imports
local Scope = require(script.Parent.Scope)

--[=[
    Constructs a new instance or hydrates an existing one with given properties.

    @param Class string | Instance -- The class name of the instance
    @return ({[any] : any})) -> Instance -- The function to hydrate the instance properties
]=]

function New:__call(Class : string | Instance | (Scope.ScopeInstance?, {[any] : any}) -> any, Properties : {[any] : any}, ThisScope : Scope.ScopeInstance?)
    local Object = nil

    if typeof(Class) == "Instance" then
        Object = Class
    elseif typeof(Class) == "string" then
        Object = Instance.new(Class)
    elseif typeof(Class) == "function" then
        Object = nil -- Setting it to nil declares it's custom
    else
        error("Invalid class type! Expected string or instance, got " .. typeof(Class))
    end

    if Object then
        -- Normal construction or hydration

        for Index, Property in Properties do
            if typeof(Index) == "table" then
                if Index.__SEAM_INDEX then
                    Index(Object, Property)
                else
                    error(`Object hydration recieved invalid index type! Expected Seam object or string, got table ({Object:GetFullName()})`)
                end
            elseif typeof(Property) == "table" then
                if Property.__SEAM_OBJECT then
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
        return "New"
    elseif Index == "__SEAM_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

local Meta = setmetatable({}, New)

return Meta :: NewConstructor