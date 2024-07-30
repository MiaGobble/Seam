-- Authors: Herobrinekd1 (Original), iGottic (Edited)

--[=[
@class Maid
@ignore
]=]

local Maid = {}

local function ClearTask(Task : any)
	local Type = typeof(Task)

	print(Type)
	
	if Type == "RBXScriptConnection" then
		Task:Disconnect()
	elseif Type == "table" then
		print(Task)

		if Task.Destroy then
			print("byebye")
			Task:Destroy()
		else
			for Index, Value in Task do
				Task[Index] = nil
				ClearTask(Value)
			end
		end
	elseif Type == "function" then
		Task()
		Task = nil
	elseif Type == "Instance" then
		print("byebyeinstance")
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
	return Maid[Value] or self.CurrentTasks[Value]
end

function Maid:__newindex(Key, Value)
	if self.CurrentTasks[Key] then
		ClearTask(self.CurrentTasks[Key])
		warn(Key .. " was reserved. Clearing task!")
	end
	
	self.CurrentTasks[Key] = Value
end

function Maid.new()
	local self = {}

	self.CurrentTasks = {}
	
	return setmetatable(self, Maid)
end

function Maid:GiveTask(Task : any)
	local Index = CountDictionaryEntries(self.CurrentTasks)
	
	self.CurrentTasks[Index] = Task

	return Index
end

function Maid:ClearTask(Key : string)
	local Task = self.CurrentTasks[Key]
	
	if Task then
		ClearTask(Task)
	else
		warn("Couldnt find task with the id " ..Key)
	end
end

function Maid:ClearTasks()
	if not self.CurrentTasks then
		return
	end

	for _, Task in self.CurrentTasks do
		ClearTask(Task)
	end
end

function Maid:Destroy()
	self:ClearTasks()
	self.CurrentTasks = nil
end

return Maid