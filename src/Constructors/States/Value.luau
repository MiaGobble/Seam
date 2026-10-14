local Value = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Batch = require(Modules.Batch)
local StateManager = require(Modules.StateManager)
local Bucket = require(Modules.Bucket)
local Signal = require(Modules.Signal)
local IsValueChanged = require(Modules.IsValueChanged)
local Symbol = require(Modules.Symbol)

Value.__SEAM_INDEX = Symbol.new("Value")
Value.__SEAM_CAN_BE_SCOPED = true

function Value.__CALLBACK(_ : Types.ConstructorCompiled, thisValue : any)
	local BucketInstance = Bucket.new()
	local ChangedSignal = Signal.new()
	local AttachedSignal = Signal.new()
	local IsLocked = false
	local ValueType = if thisValue ~= nil then typeof(thisValue) else nil
	local ActiveValue : Types.ObjectCompiled

	if ValueType == "table" then
		-- Seam values clone tables before using them
		thisValue = table.clone(thisValue)
	end

	local function CloneTableToPath(path : {any}?)
		if typeof(thisValue) ~= "table" then
			error("TableInsert, TableRemove, and TableSet can only be used when Value is a table")
		end

		local SafePath = if path ~= nil then path else {}

		if typeof(SafePath) ~= "table" then
			error("Path must be a table of keys")
		end

		local OldRoot = thisValue
		local NewRoot = table.clone(OldRoot)
		local OldCursor = OldRoot
		local NewCursor = NewRoot

		for _, thisKey in SafePath do
			local OldNext = OldCursor[thisKey]

			if typeof(OldNext) ~= "table" then
				error("Path points to a non-table value")
			end

			local NewNext = table.clone(OldNext)
			NewCursor[thisKey] = NewNext
			OldCursor = OldNext
			NewCursor = NewNext
		end

		return NewRoot, NewCursor
	end

	local function CloneTableToParentPath(path : {any})
		if typeof(thisValue) ~= "table" then
			error("TableSet with a path can only be used when Value is a table")
		end

		if #path == 0 then
			error("Path must contain at least one key")
		end

		local OldRoot = thisValue
		local NewRoot = table.clone(OldRoot)
		local OldCursor = OldRoot
		local NewCursor = NewRoot

		for thisIndex = 1, #path - 1 do
			local ThisKey = path[thisIndex]
			local OldNext = OldCursor[ThisKey]

			if typeof(OldNext) ~= "table" then
				error("Path points to a non-table value")
			end

			local NewNext = table.clone(OldNext)
			NewCursor[ThisKey] = NewNext
			OldCursor = OldNext
			NewCursor = NewNext
		end

		return NewRoot, OldCursor, NewCursor, path[#path]
	end

	--[[
		local This = Value(...)
		This.Value = x OR x = This.Value
		This.Changed -> As rbxscriptsignal
	--]]

	local ValueObject : Types.ObjectDecompiled = {
		__SEAM_OBJECT = Symbol.new("Value"),
		Changed = ChangedSignal,
		AttachedToInstance = AttachedSignal,
	}

	function ValueObject.Destroy()
		BucketInstance:Destroy()
	end

	function ValueObject.TableInsert(_ : Types.ObjectCompiled, insertedValue : any, path : {any}?)
		local NewRoot, TargetTable = CloneTableToPath(path)

		table.insert(TargetTable, insertedValue)

		ActiveValue.Value = NewRoot
	end

	function ValueObject.TableRemove(_ : Types.ObjectCompiled, removedValueIndex : number, path : {any}?)
		if typeof(removedValueIndex) ~= "number" then
			error("RemovedValueIndex must be a number")
		end

		local NewRoot, TargetTable = CloneTableToPath(path)

		table.remove(TargetTable, removedValueIndex)

		ActiveValue.Value = NewRoot
	end

	function ValueObject.TableSet(_ : Types.ObjectCompiled, newTargetValue : any, path : {any}?)
		local SafePath = if path ~= nil then path else {}

		if typeof(SafePath) ~= "table" then
			error("Path must be a table of keys")
		end

		if #SafePath == 0 then
			ActiveValue.Value = newTargetValue
			return
		end

		local NewRoot, _, NewParent, LastKey = CloneTableToParentPath(SafePath)
		NewParent[LastKey] = newTargetValue
		ActiveValue.Value = NewRoot
	end

	function ValueObject.__CALLBACK(_ : Types.ObjectCompiled, object : any, index : string)
		if not object then
			return
		end

		if not index then
			return
		end

		if typeof(thisValue) == "table" and thisValue ~= nil then
			object[index] = table.clone(thisValue)
		else
			object[index] = thisValue
		end

		AttachedSignal:Fire(object)

		BucketInstance:Add(StateManager.AttachStateToObject(object, {
			Value = function()
				if typeof(thisValue) == "table" and thisValue ~= nil then
					return table.clone(thisValue)
				else
					return thisValue
				end
			end,

			PropertyName = index,
		}))
	end

	function ValueObject.__INDEX(_ : Types.ObjectCompiled, index : string)
		if index == "Value" then
			return thisValue
		end

		return nil
	end

	function ValueObject.__NEWINDEX(_ : Types.ObjectCompiled, index : string, newValue : any)
		if index == "Value" then
			if IsLocked then
				error("Attempt to modify value when locked.")
			end

			if ValueType ~= nil then
				if newValue ~= nil and typeof(newValue) ~= ValueType then
					error(`Invalid value type! Expected {ValueType}, got {typeof(newValue)}`)
				end
			elseif newValue ~= nil then
				ValueType = typeof(newValue)
			end

			if not IsValueChanged(thisValue, newValue) then
				return
			end

			thisValue = newValue

			-- Make sure to fire the changed signal for other states
			Batch.Fire(ChangedSignal, "Value", thisValue)
			return
		elseif index == "__LOCKED" then
			if newValue == true then
				IsLocked = true
				ActiveValue:Destroy()
				return
			else
				error("Can not unlock values.")
			end
		else
			error("Ran into an unexpected error")
		end
	end

	ActiveValue = Compiler.CompileObject(ValueObject)

	return ActiveValue :: Types.ValueInstance<any>
end

return Compiler.CompileConstructor(Value) :: Types.ValueConstructor<any>
