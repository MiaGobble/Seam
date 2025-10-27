-- Author: iGottic

--[=[
    @class GetValue
    @since 0.2.2
]=]

local GetValue = {}

-- Types
export type GetValue = (State : any?) -> any?

function GetValue:__call(State : any?) : any?
    -- Nothing exists? No problem.
    if not State then
        return nil
    end

    -- Is it a state? Return the value of that state.
    if typeof(State) == "table" and State.Value then
        local RawValue = State.ValueRaw

        if RawValue ~= nil then
            return RawValue
        end

        return State.Value
    end

    -- Just normal userdata? That's cool too.
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