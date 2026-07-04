-- Author: iGottic

local FollowProperty = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Symbol = require(Modules.Symbol)

-- Variables
local ClassSymbol = Symbol.new("FollowProperty")

-- Types Extended
export type FollowProperty = (PropertyName : string) -> (Object : Instance, ValueState : Types.BaseState<any>) -> nil

function FollowProperty:__call(PropertyName : string)
    local ActiveConnections = setmetatable({}, {__mode = "k"})

    local function CleanupObjectConnection(Object : Instance)
        local ConnectionBucket = ActiveConnections[Object]

        if ConnectionBucket == nil then
            return
        end

        if ConnectionBucket.PropertyConnection ~= nil and ConnectionBucket.PropertyConnection.Connected then
            ConnectionBucket.PropertyConnection:Disconnect()
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

            local PropertyConnection = Object:GetPropertyChangedSignal(PropertyName):Connect(function()
                if Object[PropertyName] ~= ValueState.Value then
                    ValueState.Value = Object[PropertyName]
                end

                ValueState.Value = Object[PropertyName]
            end)

            local DestroyingConnection = Object.Destroying:Connect(function()
                CleanupObjectConnection(Object)
            end)

            ActiveConnections[Object] = {
                PropertyConnection = PropertyConnection,
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

local Meta = setmetatable({}, FollowProperty)

return Meta :: FollowProperty