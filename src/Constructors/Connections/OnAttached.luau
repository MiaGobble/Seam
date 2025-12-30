-- Author: iGottic

--[=[
    @class OnAttached
    @since 0.3.3
]=]

local OnAttached = {}

-- Types
export type OnAttached = (Object : any, Callback : (AttachedInstance : Instance) -> nil) -> RBXScriptConnection

--[=[
    Connects to a changed event from an instance.
]=]

function OnAttached:__call(Object : any, Callback : (AttachedInstance : Instance) -> nil)
    return (Object.AttachedToInstance :: RBXScriptSignal):Connect(function(...)
        -- When something changes, call the callback function
        Callback(...)
    end)
end

function OnAttached:__index(Index : string)
    if Index == "__SEAM_INDEX" then
        return "OnAttached"
    elseif Index == "__SEAM_CAN_BE_SCOPED" then
        return false
    else
        return nil
    end
end

local Meta = setmetatable({}, OnAttached)

return Meta :: OnAttached