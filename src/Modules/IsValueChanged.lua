-- Constants
local EPSILON = 0.001

-- Imports
local Modules = script.Parent
local UnpackType = require(Modules.UnpackType)

return function(OldValue : any, NewValue : any) : boolean
    local ValueType = typeof(OldValue)

    if ValueType == "boolean" then
        return OldValue ~= NewValue
    elseif ValueType == "table" then
        for Index, Element in OldValue do
            if not NewValue[Index] then
                return true
            elseif typeof(Element) == "number" then
                return math.abs(Element - NewValue[Index]) > EPSILON
            elseif typeof(Element) == "boolean" then
                if Element ~= NewValue[Index] then
                    return true
                end
            else
                return true
            end
        end

        for Index, _ in NewValue do
            if not OldValue[Index] then
                return true
            end
        end
    else
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
            elseif typeof(Element) == "boolean" then
                if Element ~= NewUnpackedValue[Index] then
                    return true
                end
            else
                return true
            end
        end
    end

    return false
end