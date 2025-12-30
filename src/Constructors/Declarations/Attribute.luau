-- Author: iGottic

--[=[
    @class Attribute
    @since 0.0.3
]=]

local Attribute = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Symbol = require(Modules.Symbol)

-- Variable
local ClassSymbol = Symbol.new("Attribute")

-- Types Extended
export type Attribute = (AttributeName : string) -> (Object : Instance, AttributeValue : Types.BaseState<any> | any) -> nil

--[=[
    Sets an attribute

    @param AttributeName string -- The name of the event to connect to
]=]

function Attribute:__call(AttributeName : string)
    local EventBinding = setmetatable({}, {
        __call = function(_, Object : Instance, AttributeValue : any)
            if typeof(AttributeValue) == "table" and AttributeValue.__SEAM_OBJECT then
                -- If we are using a state, then let's connect to it
                -- When it changes, update the attribute

                AttributeValue.Changed:Connect(function()
                    Object:SetAttribute(AttributeName, AttributeValue.Value)
                end)

                Object:SetAttribute(AttributeName, AttributeValue.Value)

                return
            end

            -- If we're not using a state, just set the attribute directly
            Object:SetAttribute(AttributeName, AttributeValue)
        end,

        __index = function(_, Index : string)
            if Index == "__SEAM_INDEX" then
                return ClassSymbol
            else
                return nil
            end
        end
    })

    return EventBinding
end

function Attribute:__index(Index : string)
    if Index == "__SEAM_CAN_BE_SCOPED" then
        -- This cannot be scoped
        return false
    else
        return nil
    end
end

local Meta = setmetatable({}, Attribute)

return Meta :: Attribute