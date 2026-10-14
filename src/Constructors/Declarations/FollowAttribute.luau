local FollowAttribute = {}

-- Types
type EventBinding = {Destroy : () -> nil} & typeof(setmetatable({}, {__call = function(_, object : Instance, valueState : any) end}))

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Symbol = require(Modules.Symbol)

FollowAttribute.__SEAM_CAN_BE_SCOPED = false

function FollowAttribute.__CALLBACK(_ : Types.ConstructorCompiled, attributeName : string) : EventBinding
	local EventBinding : Types.ObjectDecompiled = {}
	local ActiveConnections = setmetatable({}, {__mode = "k"})

	local function CleanupObjectConnection(object : Instance)
		local ConnectionBucket = ActiveConnections[object]

		if ConnectionBucket == nil then
			return
		end

		if ConnectionBucket.AttributeConnection ~= nil and ConnectionBucket.AttributeConnection.Connected then
			ConnectionBucket.AttributeConnection:Disconnect()
		end

		if ConnectionBucket.DestroyingConnection ~= nil and ConnectionBucket.DestroyingConnection.Connected then
			ConnectionBucket.DestroyingConnection:Disconnect()
		end

		ActiveConnections[object] = nil
	end

	EventBinding.__SEAM_INDEX = Symbol.new("FollowAttribute")
	EventBinding.__SEAM_CAN_BE_SCOPED = false

	function EventBinding.Destroy(_ : EventBinding)
		for object in ActiveConnections do
			CleanupObjectConnection(object)
		end
	end

	function EventBinding.__CALLBACK(_ : EventBinding, object : Instance, valueState : Types.BaseState<any>)
		-- Literally just a simple connection and value update
		CleanupObjectConnection(object)

		local AttributeConnection = object:GetAttributeChangedSignal(attributeName):Connect(function()
			if object:GetAttribute(attributeName) ~= valueState.Value then
				valueState.Value = object:GetAttribute(attributeName)
			end

			valueState.Value = object:GetAttribute(attributeName)
		end)

		local DestroyingConnection = object.Destroying:Connect(function()
			CleanupObjectConnection(object)
		end)

		ActiveConnections[object] = {
			AttributeConnection = AttributeConnection,
			DestroyingConnection = DestroyingConnection,
		}

		return function()
			CleanupObjectConnection(object)
		end
	end

	return Compiler.CompileObject(EventBinding) :: EventBinding
end

return Compiler.CompileConstructor(FollowAttribute) :: Types.FollowAttribute
