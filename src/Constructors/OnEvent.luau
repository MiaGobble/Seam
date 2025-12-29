-- Author: iGottic

--[=[
    @class OnEvent
    @since 0.0.1
]=]

local OnEvent = {}

-- Types
export type OnEvent = (EventName : string) -> (...any) -> RBXScriptConnection

--[=[
    Connects to an event from an instance.

    @param EventName string -- The name of the event to connect to
]=]

function OnEvent:__call(EventName : string)
    local EventBinding = setmetatable({}, {
        __call = function(_, Object : Instance, Callback : (...any?) -> nil)
            -- So for example, if we do OnEvent "Activated", EventName will equal "Activated"
            return (Object[EventName] :: RBXScriptSignal):Connect(Callback)
        end,

        __index = function(_, Index : string)
            if Index == "__SEAM_INDEX" then
                return "OnEvent"
            else
                return nil
            end
        end
    })

    return EventBinding
end

function OnEvent:__index(Index : string)
    if Index == "__SEAM_CAN_BE_SCOPED" then
        return false
    else
        return nil
    end
end

local Meta = setmetatable({}, OnEvent)

return Meta :: OnEvent