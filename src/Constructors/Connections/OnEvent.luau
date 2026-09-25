-- Author: iGottic

local OnEvent = {}

-- Types
export type OnEvent = (EventName : string) -> (...any) -> RBXScriptConnection

function OnEvent:__call(EventName : string)
    local ActiveConnections = setmetatable({}, {__mode = "k"})

    local EventBinding = setmetatable({
        Destroy = function()
            for Object, Connection in ActiveConnections do
                if Connection.Connected then
                    Connection:Disconnect()
                end

                ActiveConnections[Object] = nil
            end
        end,
    }, {
        __call = function(_, Object : Instance, Callback : (...any?) -> nil)
            -- So for example, if we do OnEvent "Activated", EventName will equal "Activated"

            local ExistingConnection = ActiveConnections[Object]
            if ExistingConnection and ExistingConnection.Connected then
                ExistingConnection:Disconnect()
            end

            local Connection = (Object[EventName] :: RBXScriptSignal):Connect(Callback)
            ActiveConnections[Object] = Connection

            return Connection
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
        return true
    else
        return nil
    end
end

local Meta = setmetatable({}, OnEvent)

return Meta :: OnEvent
