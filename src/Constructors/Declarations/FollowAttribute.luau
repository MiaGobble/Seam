-- Author: iGottic

local FollowAttribute = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Symbol = require(Modules.Symbol)

-- Variables
local ClassSymbol = Symbol.new("FollowAttribute")

-- Types Extended
export type FollowAttribute = (AttributeName : string) -> (Object : Instance, ValueState : Types.BaseState<any>) -> nil

function FollowAttribute:__call(AttributeName : string)
    local ActiveConnections = setmetatable({}, {__mode = "k"})

    local function CleanupObjectConnection(Object : Instance)
        local ConnectionBucket = ActiveConnections[Object]

        if ConnectionBucket == nil then
            return
        end

        if ConnectionBucket.AttributeConnection ~= nil and ConnectionBucket.AttributeConnection.Connected then
            ConnectionBucket.AttributeConnection:Disconnect()
        end

        if ConnectionBucket.DestroyingConnection ~= nil and ConnectionBucket.DestroyingConnection.Connected then
            ConnectionBucket.DestroyingConnection:Disconnect()
        end

        ActiveConnections[Object] = nil
    end

    return setmetatable({
        Destroy = function()
            for Object in ActiveConnections do
                CleanupObjectConnection(Object)
            end
        end,
    }, {
        __call = function(_, Object : Instance, ValueState : Types.BaseState<any>)
            -- Literally just a simple connection and value update
            CleanupObjectConnection(Object)
            
            local AttributeConnection = Object:GetAttributeChangedSignal(AttributeName):Connect(function()
                if Object:GetAttribute(AttributeName) ~= ValueState.Value then
                    ValueState.Value = Object:GetAttribute(AttributeName)
                end

                ValueState.Value = Object:GetAttribute(AttributeName)
            end)

            local DestroyingConnection = Object.Destroying:Connect(function()
                CleanupObjectConnection(Object)
            end)

            ActiveConnections[Object] = {
                AttributeConnection = AttributeConnection,
                DestroyingConnection = DestroyingConnection,
            }
        end,

        __index = function(_, Index : string)
            if Index == "__SEAM_INDEX" then
                return ClassSymbol
            elseif Index == "__SEAM_CAN_BE_SCOPED" then
                return false
            else
                return nil
            end
        end,
    })
end

local Meta = setmetatable({}, FollowAttribute)

return Meta :: FollowAttribute