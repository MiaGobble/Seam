-- Constants
local EPSILON = 0.001

-- Imports
local Modules = script.Parent
local UnpackType = require(Modules.UnpackType)

return function(OldValue : any, NewValue : any) : boolean
    local ValueType = typeof(OldValue)

    if ValueType == "boolean" then
        return OldValue ~= NewValue
    end

    local OldUnpackedValue = UnpackType(OldValue, ValueType)
    local NewUnpackedValue = UnpackType(NewValue, ValueType)

    if #OldUnpackedValue ~= #NewUnpackedValue then
        return true
    end

    for Index, Element in OldUnpackedValue do
        if typeof(Element) == "number" then
            if math.abs(Element - NewUnpackedValue[Index]) > EPSILON then
                return true
            end
        else
            if Element ~= NewUnpackedValue[Index] then
                return true
            end
        end
    end

    return false
end