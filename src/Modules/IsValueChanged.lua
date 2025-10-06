-- Constants
local EPSILON = 0.001

return function(OldValue : any, NewValue : any) : boolean
    local ValueType = typeof(OldValue)

    if ValueType == "table" then
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
    end

    return OldValue ~= NewValue
end