local Computed = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Batch = require(Modules.Batch)
local StateManager = require(Modules.StateManager)
local Bucket = require(Modules.Bucket)
local Signal = require(Modules.Signal)
local Symbol = require(Modules.Symbol)
local IsValueChanged = require(Modules.IsValueChanged)
local GetValue = require(script.Parent.Parent.Utilities.GetValue)
local IsState = require(script.Parent.Parent.Utilities.IsState)

local COMPUTED_INDEX_SYMBOL = Symbol.new("Computed")
local COMPUTED_OBJECT_SYMBOL = Symbol.new("ComputedInstance")

Computed.__SEAM_INDEX = COMPUTED_INDEX_SYMBOL
Computed.__SEAM_CAN_BE_SCOPED = true

function Computed.__CALLBACK(_ : Types.ConstructorCompiled, callback : ((value : Types.ValueInstance<any>) -> any) -> any?)
	-- Manages reactive computation, dependency tracking, and cached evaluation
	local BucketInstance = Bucket.new()
	local ChangedSignal = Signal.new()
	local DependencyConnections : {[any] : RBXScriptConnection} = {}
	local CurrentValue = nil
	local IsInitialized = false
	local AttachedSignal = Signal.new()
	local IsRecomputing = false
	local RecomputeAndFireChanged
	local ActiveComputation : Types.ObjectCompiled

	local function CleanupDependencyConnections()
		for _, connection in DependencyConnections do
			if connection.Connected then
				connection:Disconnect()
			end
		end

		table.clear(DependencyConnections)
	end

	local function RecomputeCore()
		if IsRecomputing then
			return
		end

		IsRecomputing = true

		local SeenDependencies : {[any] : boolean} = {}

		local function Use(thisValue : Types.ValueInstance<any>)
			-- Is Use connecting to a state? If not, just get the value

			if thisValue ~= nil and IsState(thisValue) then
				SeenDependencies[thisValue] = true

				if DependencyConnections[thisValue] == nil then
					DependencyConnections[thisValue] = thisValue.Changed:Connect(function()
						RecomputeAndFireChanged()
					end)
				end
			end

			return GetValue(thisValue)
		end

		local Success, Result = pcall(callback, Use)
		IsRecomputing = false

		if not Success then
			error(Result, 2)
		end

		CurrentValue = Result
		IsInitialized = true

		for dependency, connection in DependencyConnections do
			if not SeenDependencies[dependency] then
				if connection.Connected then
					connection:Disconnect()
				end

				DependencyConnections[dependency] = nil
			end
		end
	end

	RecomputeAndFireChanged = function()
		local OldValue = CurrentValue
		RecomputeCore()
		if IsValueChanged(OldValue, CurrentValue) then
			Batch.Fire(ChangedSignal, "Value", CurrentValue)
		end
	end

	local function RecomputeSilently()
		RecomputeCore()
	end

	local ComputationObject : Types.ObjectDecompiled = {
		__SEAM_OBJECT = COMPUTED_OBJECT_SYMBOL,
		__SEAM_IS_STATE = true,
	}

	function ComputationObject.Destroy()
		CleanupDependencyConnections()
		BucketInstance:Destroy()
	end

	function ComputationObject.__CALLBACK(_ : Types.ObjectCompiled, object : Instance, index : string)
		AttachedSignal:Fire(object)

		local AttachedBucket = StateManager.AttachStateToObject(object, {
			Value = function()
				-- We don't want to re-calculate the computed when the states haven't changed,
				-- so let's just force-calculate only when it's first checked

				if not IsInitialized then
					RecomputeSilently()
				end

				return CurrentValue
			end,

			PropertyName = index,
			Changed = ChangedSignal,
		})

		BucketInstance:Add(AttachedBucket)

		return AttachedBucket
	end

	function ComputationObject.__INDEX(_ : Types.ObjectCompiled, index : string)
		if index == "Value" then
			-- Same as above, let's not re-calculate

			if not IsInitialized then
				RecomputeSilently()
			end

			return CurrentValue
		elseif index == "Changed" then
			-- We need to connect the Use() functions here to track changes

			if not IsInitialized then
				RecomputeSilently()
			end

			return ChangedSignal
		elseif index == "AttachedToInstance" then
			return AttachedSignal
		end

		return nil
	end

	ActiveComputation = Compiler.CompileObject(ComputationObject)

	return ActiveComputation :: Types.ComputedInstance<any>
end

return Compiler.CompileConstructor(Computed) :: Types.ComputedConstructor<any>
