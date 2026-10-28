local Rendered = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Batch = require(Modules.Batch)
local StateManager = require(Modules.StateManager)
local Bucket = require(Modules.Bucket)
local Signal = require(Modules.Signal)
local Symbol = require(Modules.Symbol)
local UpdateSignals = require(Modules.UpdateSignals)

local RENDERED_INDEX_SYMBOL = Symbol.new("Rendered")
local RENDERED_OBJECT_SYMBOL = Symbol.new("RenderedInstance")

Rendered.__SEAM_INDEX = RENDERED_INDEX_SYMBOL
Rendered.__SEAM_CAN_BE_SCOPED = true

function Rendered.__CALLBACK(_ : Types.ConstructorCompiled, callback : (number) -> any?)
	-- This is MUCH simpler than computed, since it just force-updates every frame
	local BucketInstance = Bucket.new()
	local ChangedSignal = Signal.new()
	local AttachedSignal = Signal.new()
	local CurrentValue = nil
	local IsInitialized = false
	local LastFrame = os.clock()
	local ActiveComputation : Types.ObjectCompiled

	local WrappedCallback = function()
		local DeltaTime = os.clock() - LastFrame
		LastFrame = os.clock()

		return callback(DeltaTime)
	end

	BucketInstance:Add(UpdateSignals.OnFramePreUpdate:Connect(function()
		CurrentValue = WrappedCallback()
		IsInitialized = true
		Batch.Fire(ChangedSignal, "Value", CurrentValue)
	end))

	local RenderedObject : Types.ObjectDecompiled = {
		__SEAM_OBJECT = RENDERED_OBJECT_SYMBOL,
		__SEAM_IS_STATE = true,
		Changed = ChangedSignal,
		AttachedToInstance = AttachedSignal,
	}

	function RenderedObject.Destroy()
		BucketInstance:Destroy()
	end

	function RenderedObject.__CALLBACK(self : Types.ObjectCompiled, object : Instance, index : string)
		AttachedSignal:Fire(object)

		local AttachedBucket = StateManager.AttachStateToObject(object, {
			Value = function()
				return self.Value
			end,
			PropertyName = index,
			Changed = ChangedSignal,
		})

		BucketInstance:Add(AttachedBucket)

		return AttachedBucket
	end

	function RenderedObject.__INDEX(_ : Types.ObjectCompiled, index : string)
		if index == "Value" then
			if not IsInitialized then
				CurrentValue = WrappedCallback()
				IsInitialized = true
			end

			return CurrentValue
		end

		return nil
	end

	ActiveComputation = Compiler.CompileObject(RenderedObject)

	return ActiveComputation :: Types.RenderedInstance<any>
end

return Compiler.CompileConstructor(Rendered) :: Types.RenderedConstructor<any>
