-- Author: iGottic

local OnChanged = {}

-- Types
export type OnChanged = (Object : any, Callback : (PropertyChanged : string, NewValue : any) -> nil) -> RBXScriptConnection

function OnChanged:__call(Object : any, Callback : (PropertyChanged : string, NewValue : any) -> nil)
    -- Fortunately, states also have a Changed signal, so this works out perfectly 
    -- for states as well!

    return (Object.Changed :: RBXScriptSignal):Connect(function(PropertyName : string)
        -- When something changes, call the callback function
        Callback(PropertyName, Object[PropertyName])
    end)
end

function OnChanged:__index(Index : string)
    if Index == "__SEAM_INDEX" then
        return "OnChanged"
    elseif Index == "__SEAM_CAN_BE_SCOPED" then
        return false
    else
        return nil
    end
end

local Meta = setmetatable({}, OnChanged)

return Meta :: OnChanged