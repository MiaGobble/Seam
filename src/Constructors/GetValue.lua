-- Author: iGottic

--[=[
    @class GetValue
    @since 0.2.2
]=]

local GetValue = {}

-- Types
export type GetValue = (State : any?) -> any?

function GetValue:__call(State : any?) : any?
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