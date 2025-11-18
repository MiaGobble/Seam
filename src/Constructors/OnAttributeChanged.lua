-- Author: iGottic

--[=[
    @class OnAttributeChanged
    @since 0.0.3
]=]

local OnAttributeChanged = {}

-- Types
export type OnAttributeChanged = (AttributeName : string) -> (...any) -> RBXScriptConnection

--[=[
    Connects to an attribute change from an instance.

    @param AttributeName string -- The name of the event to connect to
]=]

function OnAttributeChanged:__call(AttributeName : string)
    local EventBinding = setmetatable({}, {
        __call = function(self, Object : Instance, Callback : (...any?) -> nil)
            -- I feel like there is something I'm missing, and this might be a disaster
            -- for memory? I'll keep an eye peeled.
            
            return Object:GetAttributeChangedSignal(AttributeName):Connect(Callback)
        end,

        __index = function(self, Index : string)
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
        return false
    else
        return nil
    end
end

local Meta = setmetatable({}, OnAttributeChanged)

return Meta :: OnAttributeChanged