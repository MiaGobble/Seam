-- Author: iGottic

--[=[
    @class LockValue
    @since 0.3.3
]=]

local LockValue = {}

-- Imports
local Value = require(script.Parent.Parent.States.Value)

-- Types
export type LockValue = (LockedValue : Value.ValueInstance<any>) -> nil

function LockValue:__call(LockedValue : Value.ValueInstance<any>) : nil
    if typeof(LockedValue) ~= "table" or not LockedValue.__SEAM_OBJECT or tostring(LockedValue.__SEAM_OBJECT) ~= "Value" then
        error("You can only lock a value state")
    end

    LockedValue.__LOCKED = true
end

function LockValue:__index(Key : string)
    if Key == "__SEAM_CAN_BE_SCOPED" then
        return false
    end

    return nil
end

local Meta = setmetatable({}, LockValue)

return Meta :: LockValue