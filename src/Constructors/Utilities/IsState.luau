-- Author: iGottic

local IsState = {}

-- Types
export type IsState = (CheckedValue : any?) -> boolean

-- Constants
local RECOGNIZED_STATE_SYMBOLS = {"Spring", "Tween", "Computed", "Rendered", "Value"}

function IsState:__call(CheckedValue : any?) : boolean
    if typeof(CheckedValue) ~= "table" then
        return false -- Not a state since it's not a table
    end

    if not CheckedValue.__SEAM_OBJECT then
        return false -- Not a state since it's not from Seam or not a Seam object
    end

    if table.find(RECOGNIZED_STATE_SYMBOLS, tostring(CheckedValue.__SEAM_OBJECT)) then
        return true -- Is a state since the symbol can be coerced into a string from the recognized state symbols table
    end

    return false -- Default to false
end

function IsState:__index(Key : string)
    if Key == "__SEAM_CAN_BE_SCOPED" then
        return false
    end

    return nil
end

local Meta = setmetatable({}, IsState)

return Meta :: IsState