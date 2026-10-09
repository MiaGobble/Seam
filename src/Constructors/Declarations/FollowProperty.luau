-- Author: iGottic

-- Types
type EventBinding = {Destroy : () -> nil} & typeof(setmetatable({}, {__call = function(_, Object : Instance, ValueState : any) end}))

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Symbol = require(Modules.Symbol)

-- Class
local FollowProperty : Types.ConstructorDecompiled = {}

FollowProperty.__SEAM_CAN_BE_SCOPED = false

function FollowProperty.__CALLBACK(_: Types.ConstructorCompiled, PropertyName : string) : EventBinding
    local EventBinding : Types.ObjectDecompiled = {}
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

    EventBinding.__SEAM_INDEX = Symbol.new("FollowProperty")
    EventBinding.__SEAM_CAN_BE_SCOPED = false

    function EventBinding.Destroy(_: EventBinding)
        for Object in ActiveConnections do
            CleanupObjectConnection(Object)
        end
    end

    function EventBinding.__CALLBACK(_: EventBinding, Object : Instance, ValueState : Types.BaseState<any>)
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

        return function()
            CleanupObjectConnection(Object)
        end
    end

    return Compiler.CompileObject(EventBinding) :: EventBinding
end

return Compiler.CompileConstructor(FollowProperty) :: Types.FollowProperty
