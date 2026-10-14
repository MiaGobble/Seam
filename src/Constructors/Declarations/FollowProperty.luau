local FollowProperty = {}

-- Types
type EventBinding = {Destroy : () -> nil} & typeof(setmetatable({}, {__call = function(_, object : Instance, valueState : any) end}))

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Symbol = require(Modules.Symbol)

FollowProperty.__SEAM_CAN_BE_SCOPED = false

function FollowProperty.__CALLBACK(_ : Types.ConstructorCompiled, propertyName : string) : EventBinding
	local EventBinding : Types.ObjectDecompiled = {}
	local ActiveConnections = setmetatable({}, {__mode = "k"})

	local function CleanupObjectConnection(object : Instance)
		local ConnectionBucket = ActiveConnections[object]

		if ConnectionBucket == nil then
			return
		end

		if ConnectionBucket.PropertyConnection ~= nil and ConnectionBucket.PropertyConnection.Connected then
			ConnectionBucket.PropertyConnection:Disconnect()
		end

		if ConnectionBucket.DestroyingConnection ~= nil and ConnectionBucket.DestroyingConnection.Connected then
			ConnectionBucket.DestroyingConnection:Disconnect()
		end

		ActiveConnections[object] = nil
	end

	EventBinding.__SEAM_INDEX = Symbol.new("FollowProperty")
	EventBinding.__SEAM_CAN_BE_SCOPED = false

	function EventBinding.Destroy(_ : EventBinding)
		for object in ActiveConnections do
			CleanupObjectConnection(object)
		end
	end

	function EventBinding.__CALLBACK(_ : EventBinding, object : Instance, valueState : Types.BaseState<any>)
		-- Literally just a simple connection and value update
		CleanupObjectConnection(object)

		local PropertyConnection = object:GetPropertyChangedSignal(propertyName):Connect(function()
			if object[propertyName] ~= valueState.Value then
				valueState.Value = object[propertyName]
			end

			valueState.Value = object[propertyName]
		end)

		local DestroyingConnection = object.Destroying:Connect(function()
			CleanupObjectConnection(object)
		end)

		ActiveConnections[object] = {
			PropertyConnection = PropertyConnection,
			DestroyingConnection = DestroyingConnection,
		}

		return function()
			CleanupObjectConnection(object)
		end
	end

	return Compiler.CompileObject(EventBinding) :: EventBinding
end

return Compiler.CompileConstructor(FollowProperty) :: Types.FollowProperty
