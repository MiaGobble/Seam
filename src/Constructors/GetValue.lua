-- Author: iGottic

--[=[
    @class GetValue
    @since 0.2.2
]=]

local GetValue = {}

-- Types
export type GetValue = (State : any?) -> any?

--[=[
    Used within New, this function is used to hydrate an existing component with given properties.

    @param ComponentName string -- The name of the component to hydrate
    @param ... any -- The optional arguments to pass to the component constructor
]=]

function GetValue:__call(State : any?)
    if not State then
        return nil
    end

    if typeof(State) == "table" and State.Value then
        return State.Value
    end

    return State
end

function GetValue:__index(Key : string)
    if Key == "__SEAM_CAN_BE_SCOPED" then
        return false
    end

    return nil
end

local Meta = setmetatable({}, GetValue)

return Meta :: GetValue