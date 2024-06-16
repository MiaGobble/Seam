-- Authors: Herobrinekd1 (Original), iGottic (Edited)

--[=[
Maid handles connections, instances, and functions to make cleanup easier, preventing memory leaks.

@class Maid
@client
@since 1.0.0
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

--[=[
	@ignore
]=]

function Maid:__index(Value)
	return Maid[Value] or self._Tasks[Value]
end

--[=[
	@ignore
]=]

function Maid:__newindex(Key, Value)
	if self._Tasks[Key] then
		ClearTask(self._Tasks[Key])
		warn(Key .. " was reserved. Clearing task!")
	end
	
	self._Tasks[Key] = Value
end

--[=[
	Constructs a new Maid object.
	
	@return Maid -- The maid object
]=]

function Maid.new()
	local self = setmetatable({}, Maid)

	self._Tasks = {}
	
	return self
end

--[=[
	Adds a task to the Maid object.
	
	@param Task any -- The task to add
	@return number -- The index of the task
]=]

function Maid:GiveTask(Task : any)
	local Index = CountDictionaryEntries(self._Tasks)
	
	self._Tasks[Index] = Task

	return Index
end

--[=[
	Removes a task from the Maid object.
	
	@param Key string -- The index of the task
]=]

function Maid:ClearTask(Key : string)
	local Task = self._Tasks[Key]
	
	if Task then
		ClearTask(Task)
	else
		warn("Couldnt find task with the id " ..Key)
	end
end

--[=[
	Removes all tasks from the Maid object.
]=]

function Maid:ClearTasks()
	for _, Task in self._Tasks do
		ClearTask(Task)
	end
end

--[=[
	Deconstruct the Maid object.
]=]

function Maid:Destroy()
	self:ClearTasks()
	self._Tasks = nil
end

return Maid