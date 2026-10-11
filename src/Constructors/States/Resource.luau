local Resource = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Batch = require(Modules.Batch)
local StateManager = require(Modules.StateManager)
local Bucket = require(Modules.Bucket)
local Signal = require(Modules.Signal)
local Symbol = require(Modules.Symbol)

Resource.__SEAM_OBJECT = Symbol.new("Resource")
Resource.__SEAM_CAN_BE_SCOPED = true

function Resource.__CALLBACK(_ : Types.ConstructorCompiled, callback : () -> any) : Types.ResourceInstance<any>
	local BucketInstance = Bucket.new()
	local ChangedSignal = Signal.new()
	local AttachedSignal = Signal.new()
	local CurrentValue = nil
	local CurrentStatus : Types.ResourceStatus = "Idle"
	local CurrentError = nil
	local RequestId = 0
	local ActiveResource : Types.ObjectCompiled

	local function EmitChanged()
		Batch.Fire(ChangedSignal, "Value", CurrentValue)
	end

	local function Refresh()
		RequestId += 1
		local ThisRequestId = RequestId

		CurrentStatus = "Loading"
		CurrentError = nil
		EmitChanged()

		task.spawn(function()
			local Success, Result = pcall(callback)

			if ThisRequestId ~= RequestId then
				return
			end

			if Success then
				CurrentValue = Result
				CurrentStatus = "Ready"
				CurrentError = nil
			else
				CurrentStatus = "Error"
				CurrentError = Result
			end

			EmitChanged()
		end)
	end

	local ResourceObject : Types.ObjectDecompiled = {
		__SEAM_OBJECT = Symbol.new("Resource"),
		Changed = ChangedSignal,
		AttachedToInstance = AttachedSignal,
		Refresh = Refresh,
	}

	function ResourceObject.Destroy()
		BucketInstance:Destroy()
		BucketInstance = nil
	end

	function ResourceObject.__CALLBACK(self : Types.ObjectCompiled, object : Instance, index : string)
		AttachedSignal:Fire(object)

		BucketInstance:Add(StateManager.AttachStateToObject(object, {
			Value = function()
				return self.Value
			end,

			PropertyName = index,
		}))

		return ActiveResource
	end

	function ResourceObject.__INDEX(_ : Types.ObjectCompiled, index : string)
		if index == "Value" then
			return CurrentValue
		elseif index == "Status" then
			return CurrentStatus
		elseif index == "Error" then
			return CurrentError
		end

		return nil
	end

	function ResourceObject.__NEWINDEX(_ : Types.ObjectCompiled, index : string, newValue : any)
		if index == "Value" then
			CurrentValue = newValue
			CurrentStatus = "Ready"
			CurrentError = nil
			EmitChanged()
			return
		elseif index == "Status" then
			CurrentStatus = newValue
			EmitChanged()
			return
		elseif index == "Error" then
			CurrentError = newValue
			EmitChanged()
			return
		end

		error("Ran into an unexpected error")
	end

	ActiveResource = Compiler.CompileObject(ResourceObject)

	Refresh()

	return ActiveResource :: Types.ResourceInstance<any>
end

return Compiler.CompileConstructor(Resource) :: Types.ResourceConstructor<any>
