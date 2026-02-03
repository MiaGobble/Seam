-- Author: iGottic

local GetValue = {}

-- Types
export type GetValue = (State : any?) -> any?

-- Imports
local IsState = require(script.Parent.IsState)

function GetValue:__call(State : any?) : any?
    -- Nothing exists? No problem.
    if State == nil then
        return nil
    end

    -- Is it a state? Return the value of that state.
    if IsState(State) then
        if tostring(State.__SEAM_OBJECT) == "Value" then
            return State.ValueRaw
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