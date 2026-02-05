-- Author: iGottic

local OnAttributeChanged = {}

-- Types
export type OnAttributeChanged = (AttributeName : string) -> (...any) -> RBXScriptConnection

function OnAttributeChanged:__call(AttributeName : string)
    local ActiveConnection : RBXScriptConnection = nil

    local EventBinding = setmetatable({
        Destroy = function()
            if ActiveConnection and ActiveConnection.Connected then
                ActiveConnection:Disconnect()
            end
        end,
    }, {
        __call = function(_, Object : Instance, Callback : (...any?) -> nil)
            if ActiveConnection then
                return
            end

            ActiveConnection = Object:GetAttributeChangedSignal(AttributeName):Connect(Callback)
            
            return ActiveConnection
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