-- Author: iGottic

local Attribute = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Symbol = require(Modules.Symbol)

-- Variable
local ClassSymbol = Symbol.new("Attribute")

-- Types Extended
export type Attribute = (AttributeName : string) -> (Object : Instance, AttributeValue : Types.BaseState<any> | any) -> nil

function Attribute:__call(AttributeName : string)
    local ActiveConnections = setmetatable({}, {__mode = "k"})

    local function CleanupObjectConnection(Object : Instance)
        local ConnectionBucket = ActiveConnections[Object]

        if ConnectionBucket == nil then
            return
        end

        if ConnectionBucket.StateConnection ~= nil and ConnectionBucket.StateConnection.Connected then
            ConnectionBucket.StateConnection:Disconnect()
        end

        if ConnectionBucket.DestroyingConnection ~= nil and ConnectionBucket.DestroyingConnection.Connected then
            ConnectionBucket.DestroyingConnection:Disconnect()
        end

        ActiveConnections[Object] = nil
    end

    local EventBinding = setmetatable({
        Destroy = function()
            for Object in ActiveConnections do
                CleanupObjectConnection(Object)
            end
        end,
    }, {
        __call = function(_, Object : Instance, AttributeValue : any)
            CleanupObjectConnection(Object)

            if typeof(AttributeValue) == "table" and AttributeValue.__SEAM_OBJECT then
                -- If we are using a state, then let's connect to it
                -- When it changes, update the attribute

                local StateConnection = AttributeValue.Changed:Connect(function()
                    Object:SetAttribute(AttributeName, AttributeValue.Value)
                end)

                local DestroyingConnection = Object.Destroying:Connect(function()
                    CleanupObjectConnection(Object)
                end)

                ActiveConnections[Object] = {
                    StateConnection = StateConnection,
                    DestroyingConnection = DestroyingConnection,
                }

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