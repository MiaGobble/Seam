-- Author: iGottic

--[=[
    @class Attribute
    @since 0.0.3
]=]

local Attribute = {}

--[=[
    Sets an attribute

    @param AttributeName string -- The name of the event to connect to
]=]

function Attribute:__call(AttributeName : string)
    local EventBinding = setmetatable({}, {
        __call = function(self, Object : Instance, AttributeValue : any)
            -- Add support for states
            if typeof(AttributeValue) == "table" and AttributeValue.__SEAM_OBJECT then
                AttributeValue.Changed:Connect(function()
                    Object:SetAttribute(AttributeName, AttributeValue.Value)
                end)

                Object:SetAttribute(AttributeName, AttributeValue.Value)

                return
            end

            Object:SetAttribute(AttributeName, AttributeValue)
        end,

        __index = function(self, Index : string)
            if Index == "__SEAM_INDEX" then
                return "Attribute"
            else
                return nil
            end
        end
    })

    return EventBinding
end

function Attribute:__index(Index : string)
    if Index == "__SEAM_CAN_BE_SCOPED" then
        return false
    else
        return nil
    end
end

return setmetatable({}, Attribute)