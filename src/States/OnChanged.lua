-- Author: iGottic

--[=[
    @class OnChanged
    @since 0.0.1
]=]

local OnChanged = {}

-- Types
type OnChanged = (Object : any, Callback : (PropertyChanged : string, NewValue : any) -> nil) -> RBXScriptConnection

--[=[
    Connects to a changed event from an instance.
]=]

function OnChanged:__call(Object : any, Callback : (PropertyChanged : string, NewValue : any) -> nil)
    return (Object.Changed :: RBXScriptSignal):Connect(function(PropertyName : string)
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