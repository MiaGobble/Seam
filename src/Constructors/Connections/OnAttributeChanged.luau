local OnAttributeChanged = {}

-- Types
type EventBinding = {Destroy : () -> nil,} & typeof(setmetatable({}, {__call = function(_, object : Instance, callback : (...any?) -> nil) end,}))

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Symbol = require(Modules.Symbol)

OnAttributeChanged.__SEAM_CAN_BE_SCOPED = true

function OnAttributeChanged.__CALLBACK(self : Types.ConstructorCompiled, attributeName : string)
	local EventBinding : Types.ObjectDecompiled = {}
	local ActiveConnections = setmetatable({}, {__mode = "k",})

	EventBinding.__SEAM_INDEX = Symbol.new("OnAttributeChanged")
	EventBinding.__SEAM_CAN_BE_SCOPED = false

	function EventBinding.Destroy(self : EventBinding)
		for object, connection in ActiveConnections do
			if connection.Connected then
				connection:Disconnect()
			end

			ActiveConnections[object] = nil
		end
	end

	function EventBinding.__CALLBACK(self : EventBinding, object : Instance, callback : (...any?) -> nil)
		local ExistingConnection = ActiveConnections[object]

		if ExistingConnection and ExistingConnection.Connected then
			ExistingConnection:Disconnect()
		end

		local Connection = object:GetAttributeChangedSignal(attributeName):Connect(callback)
		ActiveConnections[object] = Connection
	end

	return Compiler.CompileObject(EventBinding) :: EventBinding
end

return Compiler.CompileConstructor(OnAttributeChanged) :: Types.OnAttributeChanged
