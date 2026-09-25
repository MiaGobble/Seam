-- Author: iGottic

local OnAttributeChanged = {}

-- Types
export type OnAttributeChanged = (AttributeName : string) -> (...any) -> RBXScriptConnection

function OnAttributeChanged:__call(AttributeName : string)
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
            local ExistingConnection = ActiveConnections[Object]
            if ExistingConnection and ExistingConnection.Connected then
                ExistingConnection:Disconnect()
            end

            local Connection = Object:GetAttributeChangedSignal(AttributeName):Connect(Callback)
            ActiveConnections[Object] = Connection

            return Connection
        end,

        __index = function(_, Index : string)
            if Index == "__SEAM_INDEX" then
                return "OnAttributeChanged"
            else
                return nil
            end
        end
    })

    return EventBinding
end

function OnAttributeChanged:__index(Index : string)
    if Index == "__SEAM_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

local Meta = setmetatable({}, OnAttributeChanged)

return Meta :: OnAttributeChanged
