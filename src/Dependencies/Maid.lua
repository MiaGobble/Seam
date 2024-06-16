-- Authors: Herobrinekd1 (Original), iGottic (Edited)

--[=[
@class Maid
@ignore
]=]

local Maid = {}

local function ClearTask(Task : any)
	local Type = typeof(Task)
	
	if Type == "RBXScriptConnection" then
		Task:Disconnect()
	elseif Type == "function" then
		Task()
		Task = nil
	elseif Type == "Instance" then
		Task:Destroy()
	end
end

local function CountDictionaryEntries(Dictionary : {[string] : any})
	local Count = 1

	for _, Task in Dictionary do
		Count += 1
	end

	return Count
end

function Maid:__index(Value)
	return Maid[Value] or self._Tasks[Value]
end

function Maid:__newindex(Key, Value)
	if self._Tasks[Key] then
		ClearTask(self._Tasks[Key])
		warn(Key .. " was reserved. Clearing task!")
	end
	
	self._Tasks[Key] = Value
end

function Maid.new()
	local self = setmetatable({}, Maid)

	self._Tasks = {}
	
	return self
end

function Maid:GiveTask(Task : any)
	local Index = CountDictionaryEntries(self._Tasks)
	
	self._Tasks[Index] = Task

	return Index
end

function Maid:ClearTask(Key : string)
	local Task = self._Tasks[Key]
	
	if Task then
		ClearTask(Task)
	else
		warn("Couldnt find task with the id " ..Key)
	end
end

function Maid:ClearTasks()
	for _, Task in self._Tasks do
		ClearTask(Task)
	end
end

function Maid:Destroy()
	self:ClearTasks()
	self._Tasks = nil
end

return Maid