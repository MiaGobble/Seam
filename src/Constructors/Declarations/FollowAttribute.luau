-- Author: iGottic

-- Types
type EventBinding = {Destroy : () -> nil} & typeof(setmetatable({}, {__call = function(_, Object : Instance, ValueState : any) end}))

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Symbol = require(Modules.Symbol)

-- Class
local FollowAttribute : Types.ConstructorDecompiled = {}

FollowAttribute.__SEAM_CAN_BE_SCOPED = false

function FollowAttribute.__CALLBACK(_: Types.ConstructorCompiled, AttributeName : string) : EventBinding
    local EventBinding : Types.ObjectDecompiled = {}
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

    EventBinding.__SEAM_INDEX = Symbol.new("FollowAttribute")
    EventBinding.__SEAM_CAN_BE_SCOPED = false

    function EventBinding.Destroy(_: EventBinding)
        for Object in ActiveConnections do
            CleanupObjectConnection(Object)
        end
    end

    function EventBinding.__CALLBACK(_: EventBinding, Object : Instance, ValueState : Types.BaseState<any>)
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

        return function()
            CleanupObjectConnection(Object)
        end
    end

    return Compiler.CompileObject(EventBinding) :: EventBinding
end

return Compiler.CompileConstructor(FollowAttribute) :: Types.FollowAttribute