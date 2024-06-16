-- Authors: Herobrinekd1 (Original), iGottic (Edited)

--[=[
Maid handles connections, instances, and functions to make cleanup easier, preventing memory leaks.

@class Maid
]=]

local Maid = {}

local function ClearTask(Task: any)
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

local function Count(T)
	local Num = 1

	for _, Task in T do
		Num = Num + 1
	end
	return Num
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
		warn("[Maid module line 19]: " ..Key.. " was reserved. Clearing task!")
	end
	
	self._Tasks[Key] = Value
end

--[=[
	Constructs a new Maid object.
	
	@return Maid -- The maid object
]=]

function Maid.new()
	return setmetatable({_Tasks = {}},Maid)
end

function Maid:GiveTask(Task: any)
	
	local Index = Count(self._Tasks)
	
	self._Tasks[Index] = Task
	return Index
end

function Maid:ClearTask(Key: string)
	
	local Task = self._Tasks[Key]
	
	if Task then
		ClearTask(Task)
	else
		warn("[Maid module line 87]: Couldnt find task with the id " ..Key)
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