-- Author: iGottic

--[=[
    @class SetValue
    @since 0.3.1
]=]

local SetValue = {}

-- Types
export type SetValue = (State : any?, NewValue : any?) -> any?

function SetValue:__call(State : any?, NewValue : any?) : any?
    if State == nil then
        return NewValue
    end

    if typeof(State) == "table" and State.Value ~= nil then
        State.Value = NewValue
    end

    return NewValue
end

function SetValue:__index(Key : string)
    if Key == "__SEAM_CAN_BE_SCOPED" then
        return false
    end

    return nil
end

local Meta = setmetatable({}, SetValue)

return Meta :: SetValue