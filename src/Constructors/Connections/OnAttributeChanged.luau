-- Author: iGottic

-- Types
type EventBinding = {Destroy : () -> nil} & typeof(setmetatable({}, {__call = function(_, Object : Instance, Callback : (...any?) -> nil) end}))

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Symbol = require(Modules.Symbol)

-- Class
local OnAttributeChanged : Types.ConstructorDecompiled = {}

OnAttributeChanged.__SEAM_CAN_BE_SCOPED = true

function OnAttributeChanged.Callback(self : Types.ConstructorCompiled, AttributeName : string)
    local EventBinding : Types.ObjectDecompiled = {}
    local ActiveConnections = setmetatable({}, {__mode = "k"})

    EventBinding.__SEAM_INDEX = Symbol.new("OnAttributeChanged")
    EventBinding.__SEAM_CAN_BE_SCOPED = false

    function EventBinding.Destroy(self : EventBinding)
        for Object, Connection in ActiveConnections do
            if Connection.Connected then
                Connection:Disconnect()
            end

            ActiveConnections[Object] = nil
        end
    end

    function EventBinding.__CALLBACK(self : EventBinding, Object : Instance, Callback : (...any?) -> nil)
        local ExistingConnection = ActiveConnections[Object]

        if ExistingConnection and ExistingConnection.Connected then
            ExistingConnection:Disconnect()
        end

        local Connection = Object:GetAttributeChangedSignal(AttributeName):Connect(Callback)
        ActiveConnections[Object] = Connection
    end

    return Compiler.CompileObject(EventBinding) :: EventBinding
end

return Compiler.CompileConstructor(OnAttributeChanged) :: Types.OnAttributeChanged