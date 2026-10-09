-- Author: iGottic

-- Types
type EventBinding = {Destroy : () -> nil} & typeof(setmetatable({}, {__call = function(_, Object : Instance, AttributeValue : any) end}))

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Symbol = require(Modules.Symbol)
local Compiler = require(Modules.Compiler)

-- Class
local Attribute : Types.ConstructorDecompiled = {}

Attribute.__SEAM_CAN_BE_SCOPED = false

function Attribute.__CALLBACK(self : Types.ConstructorCompiled, AttributeName : string) : EventBinding
    local EventBinding : Types.ObjectDecompiled = {}
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

    EventBinding.__SEAM_INDEX = Symbol.new("Attribute")
    EventBinding.__SEAM_CAN_BE_SCOPED = false

    EventBinding.__CALLBACK = function(self : Types.ObjectCompiled, Object : Instance, AttributeValue : any)
        local PreviousValue = Object:GetAttribute(AttributeName)
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

            return function()
                CleanupObjectConnection(Object)
                Object:SetAttribute(AttributeName, PreviousValue)
            end
        end

        -- If we're not using a state, just set the attribute directly
        Object:SetAttribute(AttributeName, AttributeValue)

        return function()
            Object:SetAttribute(AttributeName, PreviousValue)
        end
    end

    return Compiler.CompileObject(EventBinding) :: EventBinding
end

return Compiler.CompileConstructor(Attribute) :: Types.Attribute