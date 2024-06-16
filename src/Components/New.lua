-- Author: iGottic

--[=[
    @class New
    @since 1.0.0
]=]

local New = {}

-- Imports
local Dependencies = script.Parent.Parent.Dependencies
local HydrateObject = require(Dependencies.HydrateObject)

--[=[
    Constructs a new instance or hydrates an existing one with given properties.

    @param Class string | Instance -- The class name of the instance
    @return ({[any] : any})) -> Instance -- The function to hydrate the instance properties
]=]

function New:__call(Class : string | Instance)
    if typeof(Class) == "Instance" then
        return function(Properties : {[any] : any})
            return HydrateObject(Class, Properties)
        end
    else
        local Object = Instance.new(Class)

        return function(Properties : {[any] : any})
            return HydrateObject(Object, Properties)
        end
    end
end

--[=[
    @ignore
]=]

function New:__index(Index : string)
    if Index == "__SPHI_OBJECT" then
        return "New"
    else
        return nil
    end
end

return setmetatable({}, New)