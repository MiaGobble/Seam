local StateManager = {}

-- Types
type StateInstance = {
	Value : () -> any?,
	PropertyName : string,
}

-- Imports
local Bucket = require(script.Parent.Bucket)
local IsValueChanged = require(script.Parent.IsValueChanged)
local UpdateSignals = require(script.Parent.UpdateSignals)
local CreateDeepTraceback = require(script.Parent.CreateDeepTraceback)

local function GetObjectType(object : any) : string
	if typeof(object) == "Instance" then
		return "Instance"
	elseif typeof(object) == "table" then
		if object.__SEAM_OBJECT then
			return "SeamObject"
		end
	end

	return "unknown"
end

-- This function is a bit weird but it's a lot of stuff to essentially just progate changes from one thing to another
function StateManager.AttachStateToObject(object : any, stateInstance : StateInstance)
	local ObjectType = GetObjectType(object)
	local BucketInstance = Bucket.new()
	local UpdateFunction = nil
	local ChangedSignal = nil

	if ObjectType == "Instance" then
		-- Propogate state value to a instance

		local LastValue = nil

		UpdateFunction = function()
			local NewValue = stateInstance.Value

			if typeof(NewValue) == "function" then
				NewValue = NewValue()
			end

			if LastValue ~= nil and not IsValueChanged(LastValue, NewValue) then
				return
			end

			if typeof(object[stateInstance.PropertyName]) ~= typeof(NewValue) then
				warn(`{object:GetFullName()} expected type {typeof(object[stateInstance.PropertyName])} for attached state value, got a value of type {typeof(NewValue)}{"\n"}{CreateDeepTraceback()}`)
				return
			end

			object[stateInstance.PropertyName] = NewValue
			LastValue = NewValue
		end

		task.defer(function()
			if BucketInstance.CleanupQueue == nil or BucketInstance.IsCleaning then
				return
			end

			BucketInstance:Add(object.AncestryChanged:Connect(function()
				if not object:IsDescendantOf(game) then
					BucketInstance:Destroy()
				end
			end))
		end)
	elseif ObjectType == "SeamObject" then
		-- Propogate state value to a Seam state

		local LastValue = nil

		UpdateFunction = function()
			local NewValue = stateInstance.Value

			if typeof(NewValue) == "function" then
				NewValue = NewValue()
			end

			if LastValue ~= nil and not IsValueChanged(LastValue, NewValue) then
				return
			end

			object[stateInstance.PropertyName] = NewValue
			LastValue = NewValue
		end
	else
		error(`Attempted to attach non-state to object:\n{CreateDeepTraceback()}`)
	end

	ChangedSignal = stateInstance.Changed

	-- Prefer a changed signal when updating
	if ChangedSignal ~= nil then
		BucketInstance:Add(ChangedSignal:Connect(UpdateFunction))
	else
		BucketInstance:Add(UpdateSignals.OnFrameUpdate:Connect(UpdateFunction))
	end

	-- Immediately apply current state to object
	task.spawn(UpdateFunction)

	return BucketInstance
end

return StateManager
