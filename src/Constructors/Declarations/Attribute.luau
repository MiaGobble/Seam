local Attribute = {}

-- Types
type EventBinding = {Destroy : () -> nil} & typeof(setmetatable({}, {__call = function(_, object : Instance, attributeValue : any) end}))

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Symbol = require(Modules.Symbol)
local Compiler = require(Modules.Compiler)

Attribute.__SEAM_CAN_BE_SCOPED = false

function Attribute.__CALLBACK(self : Types.ConstructorCompiled, attributeName : string) : EventBinding
	local EventBinding : Types.ObjectDecompiled = {}
	local ActiveConnections = setmetatable({}, {__mode = "k"})

	local function CleanupObjectConnection(object : Instance)
		local ConnectionBucket = ActiveConnections[object]

		if ConnectionBucket == nil then
			return
		end

		if ConnectionBucket.StateConnection ~= nil and ConnectionBucket.StateConnection.Connected then
			ConnectionBucket.StateConnection:Disconnect()
		end

		if ConnectionBucket.DestroyingConnection ~= nil and ConnectionBucket.DestroyingConnection.Connected then
			ConnectionBucket.DestroyingConnection:Disconnect()
		end

		ActiveConnections[object] = nil
	end

	EventBinding.__SEAM_INDEX = Symbol.new("Attribute")
	EventBinding.__SEAM_CAN_BE_SCOPED = false

	EventBinding.Destroy = function(self : Types.ObjectCompiled)
		for object in ActiveConnections do
			CleanupObjectConnection(object)
		end
	end

	EventBinding.__CALLBACK = function(self : Types.ObjectCompiled, object : Instance, attributeValue : any)
		local PreviousValue = object:GetAttribute(attributeName)
		CleanupObjectConnection(object)

		if typeof(attributeValue) == "table" and attributeValue.__SEAM_OBJECT then
			-- If we are using a state, then let's connect to it
			-- When it changes, update the attribute

			local StateConnection = attributeValue.Changed:Connect(function()
				object:SetAttribute(attributeName, attributeValue.Value)
			end)

			local DestroyingConnection = object.Destroying:Connect(function()
				CleanupObjectConnection(object)
			end)

			ActiveConnections[object] = {
				StateConnection = StateConnection,
				DestroyingConnection = DestroyingConnection,
			}

			object:SetAttribute(attributeName, attributeValue.Value)

			return function()
				CleanupObjectConnection(object)
				object:SetAttribute(attributeName, PreviousValue)
			end
		end

		-- If we're not using a state, just set the attribute directly
		object:SetAttribute(attributeName, attributeValue)

		return function()
			object:SetAttribute(attributeName, PreviousValue)
		end
	end

	return Compiler.CompileObject(EventBinding) :: EventBinding
end

return Compiler.CompileConstructor(Attribute) :: Types.Attribute
