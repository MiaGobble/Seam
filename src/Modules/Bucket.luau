local Bucket = {}
Bucket.__index = Bucket

-- Types
export type Bucket = typeof(setmetatable({} :: {
	CleanupQueue : {[any] : (any) -> nil},
	IsCleaning : boolean,
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

local function GetMatchingCleanupCallback(object : any, cleanupMethodName : string?) : ((() -> (nil)) | ((any) -> (nil)))
	local ThisType = typeof(object)

	if ThisType == "function" then
		return object
	elseif ThisType == "thread" then
		return function()
			task.cancel(object)
			return nil
		end
	end

	if CLEANUP_METHOD_NAMES[ThisType] then
		return object[CLEANUP_METHOD_NAMES[ThisType]] :: (any) -> nil
	end

	if ThisType == "table" then
		if cleanupMethodName then
			return object[cleanupMethodName] :: (any) -> nil
		end

		for _, genericCleanupName in TABLE_CLEANUP_METHODS do
			if typeof(object[genericCleanupName]) == "function" then
				return object[genericCleanupName] :: (any) -> nil
			end

			if typeof(object[genericCleanupName:lower()]) == "function" then
				return object[genericCleanupName:lower()] :: (any) -> nil
			end
		end
	end

	error(`No cleanup function found for object: {object}`)
end

local function AssertPromiseValidity(object : any)
	if type(object) ~= "table"
		or typeof(object.getStatus) ~= "function"
		or typeof(object.finally) ~= "function"
		or typeof(object.cancel) ~= "function"
	then
		error(`Expected object ({object}) to be a promise`)
	end
end

function Bucket.new() : Bucket
	local self = setmetatable({}, Bucket) :: Bucket

	self.CleanupQueue = {}
	self.IsCleaning = false

	return self
end

function Bucket.Add(self : Bucket, object : any, cleanupMethodName : string?)
	if self.IsCleaning then
		error("Cannot add an object to bucket during cleanup")
	end

	self.CleanupQueue[object] = GetMatchingCleanupCallback(object, cleanupMethodName)

	return object
end

function Bucket.AddPromise(self : Bucket, object : any)
	if self.IsCleaning then
		error("Cannot add a promise to bucket during cleanup")
	end

	AssertPromiseValidity(object)

	if object:getStatus() == "Started" then
		object:finally(function()
			if self.IsCleaning then
				return
			end

			self.CleanupQueue[object] = nil
		end)

		self:Add(object)
	end

	return object
end

function Bucket.AttachToInstance(self : Bucket, object : Instance)
	if self.IsCleaning then
		error("Can't attach to instance when cleaning")
	elseif not object:IsDescendantOf(game) then
		error("Can't attach to already destroyed instance")
	end

	local Connection = object.Destroying:Once(function()
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

function Bucket.Remove(self : Bucket, object : any)
	if self.IsCleaning then
		error("Can't remove object when cleaning")
	end

	self.CleanupQueue[object] = nil
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

	for object : any, cleanupCallback : (any) -> nil in self.CleanupQueue do
		task.spawn(cleanupCallback, object)
		self.CleanupQueue[object] = nil
	end

	table.clear(self)
end

return Bucket
