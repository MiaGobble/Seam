local Bucket = {}
Bucket.__index = Bucket

-- Types
export type Bucket = typeof(setmetatable({} :: {
	CleanupQueue: {[any]: (any) -> nil},
	IsCleaning: boolean,
}, Bucket))

-- Constants
local TABLE_CLEANUP_METHODS = {
	"Destroy",
	"Disconnect",
	"Cleanup",
	"Clean",
	"Cancel",
}

local CLEANUP_METHOD_NAMES = {
	["Instance"] = "Destroy",
	["RBXScriptConnection"] = "Disconnect",
}

local function GetMatchingCleanupCallback(Object : any, CleanupMethodName : string?): ((() -> (nil)) | ((Object) -> (nil)))
	local ThisType = typeof(Object)

	if ThisType == "function" then
		return Object
	elseif ThisType == "thread" then
		return function()
			task.cancel(Object)
			return nil
		end
	end

	if CLEANUP_METHOD_NAMES[ThisType] then
		return Object[CLEANUP_METHOD_NAMES[ThisType]] :: (Object) -> nil
	end

	if ThisType == "table" then
		if CleanupMethodName then
			return Object[CleanupMethodName] :: (Object) -> nil
		end

		for _, GenericCleanupName in TABLE_CLEANUP_METHODS do
			if typeof(Object[GenericCleanupName]) == "function" then
				return Object[GenericCleanupName] :: (Object) -> nil
			end

			if typeof(Object[GenericCleanupName:lower()]) == "function" then
				return Object[GenericCleanupName:lower()] :: (Object) -> nil
			end
		end
	end

	error(`No cleanup function found for object: {Object}`)
end

local function AssertPromiseValidity(Object : any)
	if type(Object) ~= "table"
		or typeof(Object.getStatus) ~= "function"
		or typeof(Object.finally) ~= "function"
		or typeof(Object.cancel) ~= "function"
	then
		error(`Expected object ({Object}) to be a promise`)
	end
end

function Bucket.new() : Bucket
	local self = setmetatable({}, Bucket) :: Bucket

	self.CleanupQueue = {}
	self.IsCleaning = false

	return self
end

function Bucket.Add(self : Bucket, Object : any, CleanupMethodName : string?)
	if self.IsCleaning then
		error("Cannot add an object to bucket during cleanup")
	end

	self.CleanupQueue[Object] = GetMatchingCleanupCallback(Object, CleanupMethodName)

	return Object
end

function Bucket.AddPromise(self : Bucket, Object : any)
	if self.IsCleaning then
		error("Cannot add a promise to bucket during cleanup")
	end

	AssertPromiseValidity(Object)

	if Object:getStatus() == "Started" then
		Object:finally(function()
			if self.IsCleaning then
				return
			end

			self.CleanupQueue[Object] = nil
		end)

		self:Add(Object)
	end

	return Object
end

function Bucket.AttachToInstance(self : Bucket, Object : Instance)
	if self.IsCleaning then
		error("Can't attach to instance when cleaning")
	elseif not Object:IsDescendantOf(game) then
		error("Can't attach to already destroyed instance")
	end

	local Connection = Object.Destroying:Once(function()
		self:Destroy()
	end)

	self:Add(Connection)

	return Connection
end

function Bucket.Extend(self : Bucket)
	if self.IsCleaning then
		error("Can't extend bucket when cleaning")
	end

	local SubBucket = Bucket.new()

	self:Add(SubBucket)

	return SubBucket
end

function Bucket.Remove(self : Bucket, Object : any)
	if self.IsCleaning then
		error("Can't remove object when cleaning")
	end

	self.CleanupQueue[Object] = nil
end

function Bucket.GetWrappedDestroy(self : Bucket)
	return function()
		self:Destroy()
	end
end

function Bucket.Destroy(self : Bucket)
	if not self.CleanupQueue or self.IsCleaning then
		return
	end
	
	self.IsCleaning = true

	for Object : any, CleanupCallback : (any) -> nil in self.CleanupQueue do
		task.spawn(CleanupCallback, Object)
		self.CleanupQueue[Object] = nil
	end

	table.clear(self)
end

return Bucket
