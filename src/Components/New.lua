-- Author: iGottic

--[=[
    @class New
    @since 1.0.0
]=]

local New = {}

--[=[
    Constructs a new instance or hydrates an existing one with given properties.

    @param Class string | Instance -- The class name of the instance
    @return ({[any] : any})) -> Instance -- The function to hydrate the instance properties
]=]

function New:__call(Class : string | Instance, Properties : {[any] : any}, From : any?)
    local Object = nil

    if typeof(Class) == "Instance" then
        Object = Class
    elseif typeof(Class) == "string" then
        -- if From then
        --     if From.__SPHI_OBJECT == "From" then
        --         Object = From.Component(unpack(From.Args))
        --     else
        --         error("Invalid From object! Expected From object, got " .. typeof(From))
        --     end
        -- else
        --     Object = Instance.new(Class)
        -- end

        Object = Instance.new(Class)
    else
        error("Invalid class type! Expected string or instance, got " .. typeof(Class))
    end

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

    if From then
        if From.__SPHI_OBJECT == "From" then
            Object = From.Component(Object, unpack(From.Args))
        else
            error("Invalid From object! Expected From object, got " .. typeof(From))
        end
    end

    return Object
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