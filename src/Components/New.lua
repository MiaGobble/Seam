--[=[
    Creates a new instance with given properties.

    @class New
]=]

local New = {}

-- Imports
local Dependencies = script.Parent.Parent.Dependencies
local HydrateObject = require(Dependencies.HydrateObject)

--[=[
    Constructs a new instance with given properties.

    @param ClassName string -- The class name of the instance
    @return function -- The function to hydrate the instance properties
]=]

function New:__call(ClassName : string)
    local Object = Instance.new(ClassName)

    return function(Properties : {[string] : any})
        HydrateObject(Object, Properties)
    end
end

--[=[
    @ignore
]=]

function New:__index(Index : string)
    if Index == "__SPHI_IDENTIFIER" then
        return "New"
    else
        return nil
    end
end

return setmetatable({}, New)