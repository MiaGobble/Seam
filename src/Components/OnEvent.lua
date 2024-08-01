-- Author: iGottic

--[=[
    @class OnEvent
    @since 1.0.0
]=]

local OnEvent = {}

--[=[
    Connects to an event from an instance.

    @param EventName string -- The name of the event to connect to
]=]

function OnEvent:__call(EventName : string)
    local EventBinding = setmetatable({}, {
        __call = function(self, Object : Instance, Callback : (...any?) -> nil)
            return (Object[EventName] :: RBXScriptSignal):Connect(Callback)
        end,

        __index = function(self, Index : string)
            if Index == "__SEAM_INDEX" then
                return "OnEvent"
            else
                return nil
            end
        end
    })

    return EventBinding
end

return setmetatable({}, OnEvent)