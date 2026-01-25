--!strict

local RunService = game:GetService("RunService")

export type Trove = {
	Extend: (self: Trove) -> Trove,
	Clone: <T>(self: Trove, instance: T & Instance) -> T,
	Construct: <T, A...>(self: Trove, class: Constructable<T, A...>, A...) -> T,
	Connect: (
		self: Trove,
		signal: SignalLike | SignalLikeMetatable | RBXScriptSignal,
		fn: (...any) -> ...any
	) -> ConnectionLike | ConnectionLikeMetatable,
	BindToRenderStep: (self: Trove, name: string, priority: number, fn: (dt: number) -> ()) -> (),
	AddPromise: <T>(self: Trove, promise: (T & PromiseLike) | (T & PromiseLikeMetatable)) -> T,
	Add: <T>(self: Trove, object: T & Trackable, cleanupMethod: string?) -> T,
	Remove: <T>(self: Trove, object: T & Trackable) -> boolean,
	Pop: <T>(self: Trove, object: T & Trackable) -> boolean,
	Clean: (self: Trove) -> (),
	WrapClean: (self: Trove) -> () -> (),
	AttachToInstance: (self: Trove, instance: Instance) -> RBXScriptConnection,
	Destroy: (self: Trove) -> (),
}

type TroveInternal = Trove & {
	_objects: { any },
	_cleaning: boolean,
	_findAndRemoveFromObjects: (self: TroveInternal, object: any, cleanup: boolean) -> boolean,
	_cleanupObject: (self: TroveInternal, object: any, cleanupMethod: string?) -> (),
}

export type Trackable =
	| Instance
	| RBXScriptConnection
	| ConnectionLike
	| ConnectionLikeMetatable
	| PromiseLike
	| PromiseLikeMetatable
	| thread
	| ((...any) -> ...any)
	| Destroyable
	| DestroyableMetatable
	| DestroyableLowercase
	| DestroyableLowercaseMetatable
	| Disconnectable
	| DisconectableMetatable
	| DisconnectableLowercase
	| DisconnectableLowercaseMetatable
	| SignalLike
	| SignalLikeMetatable

type ConnectionLike = {
	Connected: boolean,
	Disconnect: (self: ConnectionLike) -> (),
}

type ConnectionLikeMetatable = typeof(setmetatable(
	{},
	{} :: { Connected: boolean, Disconnect: (self: ConnectionLikeMetatable) -> () }
))

type SignalLike = {
	Connect: (self: SignalLike, callback: (...any) -> ...any) -> ConnectionLike | ConnectionLikeMetatable,
	Once: (self: SignalLike, callback: (...any) -> ...any) -> ConnectionLike | ConnectionLikeMetatable,
}

type SignalLikeMetatable = typeof(setmetatable(
	{},
	{} :: {
		Connect: (self: SignalLikeMetatable, callback: (...any) -> ...any) -> ConnectionLike | ConnectionLikeMetatable,
		Once: (self: SignalLikeMetatable, callback: (...any) -> ...any) -> ConnectionLike | ConnectionLikeMetatable,
	}
))

type PromiseLike = {
	getStatus: (self: PromiseLike) -> string,
	finally: (self: PromiseLike, callback: (...any) -> ...any) -> PromiseLike | PromiseLikeMetatable,
	cancel: (self: PromiseLike) -> (),
}

type PromiseLikeMetatable = typeof(setmetatable(
	{},
	{} :: {
		getStatus: (self: any) -> string,
		finally: (self: PromiseLikeMetatable, callback: (...any) -> ...any) -> PromiseLike | PromiseLikeMetatable,
		cancel: (self: PromiseLikeMetatable) -> (),
	}
))

type Constructable<T, A...> = { new: (A...) -> T } | (A...) -> T

type Destroyable = {
	Destroy: (self: Destroyable) -> (),
}

type DestroyableMetatable = typeof(setmetatable({}, {} :: { Destroy: (self: DestroyableMetatable) -> () }))

type DestroyableLowercase = {
	destroy: (self: DestroyableLowercase) -> (),
}

type DestroyableLowercaseMetatable = typeof(setmetatable(
	{},
	{} :: { destroy: (self: DestroyableLowercaseMetatable) -> () }
))

type Disconnectable = {
	Disconnect: (self: Disconnectable) -> (),
}

type DisconectableMetatable = typeof(setmetatable({}, {} :: { Disconnect: (self: DisconectableMetatable) -> () }))

type DisconnectableLowercase = {
	disconnect: (self: DisconnectableLowercase) -> (),
}

type DisconnectableLowercaseMetatable = typeof(setmetatable(
	{},
	{} :: { disconnect: (self: DisconnectableLowercaseMetatable) -> () }
))

local FN_MARKER = newproxy()
local THREAD_MARKER = newproxy()
local GENERIC_OBJECT_CLEANUP_METHODS = table.freeze({ "Destroy", "Disconnect", "destroy", "disconnect" })

local function getObjectCleanupFunction(object: any, cleanupMethod: string?)
	local t = typeof(object)

	if t == "function" then
		return FN_MARKER
	elseif t == "thread" then
		return THREAD_MARKER
	end

	if cleanupMethod then
		return cleanupMethod
	end

	if t == "Instance" then
		return "Destroy"
	elseif t == "RBXScriptConnection" then
		return "Disconnect"
	elseif t == "table" then
		for _, genericCleanupMethod in GENERIC_OBJECT_CLEANUP_METHODS do
			if typeof(object[genericCleanupMethod]) == "function" then
				return genericCleanupMethod
			end
		end
	end

	error(`failed to get cleanup function for object {t}: {object}`, 3)
end

local function assertPromiseLike(object: any)
	if
		typeof(object) ~= "table"
		or typeof(object.getStatus) ~= "function"
		or typeof(object.finally) ~= "function"
		or typeof(object.cancel) ~= "function"
	then
		error("did not receive a promise as an argument", 3)
	end
end

local function assertSignalLike(object: any)
	if
		typeof(object) ~= "RBXScriptSignal"
		and (typeof(object) ~= "table" or typeof(object.Connect) ~= "function" or typeof(object.Once) ~= "function")
	then
		error("did not receive a signal as an argument", 3)
	end
end

local Trove = {}
Trove.__index = Trove

function Trove.new(): Trove
	local self = setmetatable({}, Trove)

	self._objects = {}
	self._cleaning = false

	return (self :: any) :: Trove
end

function Trove.Add(self: TroveInternal, object: Trackable, cleanupMethod: string?): any
	if self._cleaning then
		error("cannot call trove:Add() while cleaning", 2)
	end

	local cleanup = getObjectCleanupFunction(object, cleanupMethod)
	table.insert(self._objects, { object, cleanup })

	return object
end

function Trove.Clone(self: TroveInternal, instance: Instance): Instance
	if self._cleaning then
		error("cannot call trove:Clone() while cleaning", 2)
	end

	return self:Add(instance:Clone())
end

function Trove.Construct<T, A...>(self: TroveInternal, class: Constructable<T, A...>, ...: A...)
	if self._cleaning then
		error("Cannot call trove:Construct() while cleaning", 2)
	end

	local object = nil
	local t = type(class)
	if t == "table" then
		object = (class :: any).new(...)
	elseif t == "function" then
		object = (class :: any)(...)
	end

	return self:Add(object)
end

function Trove.Connect(
	self: TroveInternal,
	signal: SignalLike | SignalLikeMetatable | RBXScriptSignal,
	fn: (...any) -> ...any
)
	if self._cleaning then
		error("Cannot call trove:Connect() while cleaning", 2)
	end
	assertSignalLike(signal)

	local confirmedSignal = signal :: SignalLike

	return self:Add(confirmedSignal:Connect(fn))
end

function Trove.Once(
	self: TroveInternal,
	signal: SignalLike | SignalLikeMetatable | RBXScriptSignal,
	fn: (...any) -> ...any
)
	if self._cleaning then
		error("Cannot call trove:Connect() while cleaning", 2)
	end
	assertSignalLike(signal)

	local confirmedSignal = signal :: SignalLike

	local conn
	conn = confirmedSignal:Once(function(...)
		fn(...)
		self:Pop(conn)
	end)

	return self:Add(conn)
end

function Trove.BindToRenderStep(self: TroveInternal, name: string, priority: number, fn: (dt: number) -> ())
	if self._cleaning then
		error("cannot call trove:BindToRenderStep() while cleaning", 2)
	end

	RunService:BindToRenderStep(name, priority, fn)

	self:Add(function()
		RunService:UnbindFromRenderStep(name)
	end)
end

function Trove.AddPromise(self: TroveInternal, promise: PromiseLike | PromiseLikeMetatable)
	if self._cleaning then
		error("cannot call trove:AddPromise() while cleaning", 2)
	end
	assertPromiseLike(promise)
	local confirmedPromise = promise :: PromiseLike

	if confirmedPromise:getStatus() == "Started" then
		confirmedPromise:finally(function()
			if self._cleaning then
				return
			end
			self:_findAndRemoveFromObjects(confirmedPromise, false)
		end)

		self:Add(confirmedPromise, "cancel")
	end

	return confirmedPromise
end

function Trove.Remove(self: TroveInternal, object: Trackable): boolean
	if self._cleaning then
		error("cannot call trove:Remove() while cleaning", 2)
	end

	return self:_findAndRemoveFromObjects(object, true)
end

function Trove.Pop(self: TroveInternal, object: Trackable): boolean
	if self._cleaning then
		error("cannot call trove:Pop() while cleaning", 2)
	end

	return self:_findAndRemoveFromObjects(object, false)
end

function Trove.Extend(self: TroveInternal)
	if self._cleaning then
		error("cannot call trove:Extend() while cleaning", 2)
	end

	return self:Construct(Trove)
end

function Trove.Clean(self: TroveInternal)
	if self._cleaning then
		return
	end

	self._cleaning = true

	for _, obj in self._objects do
		self:_cleanupObject(obj[1], obj[2])
	end

	table.clear(self._objects)
	self._cleaning = false
end

function Trove.WrapClean(self: TroveInternal)
	return function()
		self:Clean()
	end
end

function Trove._findAndRemoveFromObjects(self: TroveInternal, object: any, cleanup: boolean): boolean
	local objects = self._objects

	for i, obj in objects do
		if obj[1] == object then
			local n = #objects
			objects[i] = objects[n]
			objects[n] = nil

			if cleanup then
				self:_cleanupObject(obj[1], obj[2])
			end

			return true
		end
	end

	return false
end

function Trove._cleanupObject(_self: TroveInternal, object: any, cleanupMethod: string?)
	if cleanupMethod == FN_MARKER then
		task.spawn(object)
	elseif cleanupMethod == THREAD_MARKER then
		pcall(task.cancel, object)
	else
		object[cleanupMethod](object)
	end
end

function Trove.AttachToInstance(self: TroveInternal, instance: Instance)
	if self._cleaning then
		error("cannot call trove:AttachToInstance() while cleaning", 2)
	elseif not instance:IsDescendantOf(game) then
		error("instance is not a descendant of the game hierarchy", 2)
	end

	return self:Connect(instance.Destroying, function()
		self:Destroy()
	end)
end

function Trove.Destroy(self: TroveInternal)
	self:Clean()
end

return {
	new = Trove.new,
}