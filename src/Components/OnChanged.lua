-- Author: iGottic

--[=[
    @class OnChanged
    @since 1.0.0
]=]

local OnChanged = {}

--[=[
    Connects to a changed event from an instance.
]=]

function OnChanged:__call(Object : Instance, Callback : (PropertyChanged : string, NewValue : any) -> nil)
    return (Object.Changed :: RBXScriptSignal):Connect(function(PropertyName : string)
        Callback(PropertyName, Object[PropertyName])
    end)
end

function OnChanged:__index(Index : string)
    if Index == "__SPHI_INDEX" then
        return "OnChanged"
    else
        return nil
    end
end

return setmetatable({}, OnChanged)