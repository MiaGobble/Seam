-- Author: iGottic

--[=[
    @class HydrateObject
    @ignore
]=]

local HydrateObject = {}

function HydrateObject:__call(Object : Instance, Properties : {[any] : any})
    for Index, Property in Properties do
        if typeof(Index) == "table" then
             if Index.__SPHI_INDEX then
                Index(Object, Property)
             else
                error(`Object hydration recieved invalid index type! Expected Sphi object or string, got table ({Object:GetFullName()})`)
             end
        elseif typeof(Property) == "table" then
            if Property.__SPHI_OBJECT then
                Property(Object, Index)
            else
                error("Invalid property type! Expected Sphi object or string, got table")
            end
        else
            Object[Index] = Property
        end
    end

    return Object
end

return setmetatable({}, HydrateObject)