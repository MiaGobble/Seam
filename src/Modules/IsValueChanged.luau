-- Author: iGottic

return function(OldValue : any, NewValue : any) : boolean
    if typeof(OldValue) ~= typeof(NewValue) then
        return true
    end

    return OldValue ~= NewValue
end