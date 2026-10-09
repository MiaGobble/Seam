-- Author: iGottic

local OnAttached = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)

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
        return true
    else
        return nil
    end
end

local Meta = setmetatable({}, OnAttached)

return Meta :: Types.OnAttached