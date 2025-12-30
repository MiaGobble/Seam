-- Author: iGottic

--[=[
    @class IsComponent
    @since 0.3.3
]=]

local IsComponent = {}

-- Types
export type IsComponent = (CheckedValue : any?) -> boolean

function IsComponent:__call(CheckedValue : any?) : boolean
    if typeof(CheckedValue) ~= "table" then
        return false -- Not a component since it's not a table
    end

    if CheckedValue.__SEAM_COMPONENT then
        return true -- Is a state since the value has a component symbol
    end

    return false -- Default to false
end

function IsComponent:__index(Key : string)
    if Key == "__SEAM_CAN_BE_SCOPED" then
        return false
    end

    return nil
end

local Meta = setmetatable({}, IsComponent)

return Meta :: IsComponent