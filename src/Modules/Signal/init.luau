-- Authors:
-- stravant - July 31st, 2021 - Created the file.     
-- sleitnick - August 3rd, 2021 - Modified for Knit. 
-- iGottic - April 18th, 2026 - Modified for Praxis.

local Signal = {}
Signal.__index = Signal

-- Imports
local Connection = require(script.Connection)

-- Types extended
export type Connection = Connection.Connection

export type Signal<T...> = {
	Fire: (self: Signal<T...>, T...) -> (),
	FireDeferred: (self: Signal<T...>, T...) -> (),
	Connect: (self: Signal<T...>, fn: (T...) -> ()) -> Connection,
	Once: (self: Signal<T...>, fn: (T...) -> ()) -> Connection,
	DisconnectAll: (self: Signal<T...>) -> (),
	GetConnections: (self: Signal<T...>) -> { Connection },
	Destroy: (self: Signal<T...>) -> (),
	Wait: (self: Signal<T...>) -> T...,
}

local FreeRunnerThread: thread? = nil

local function AcquireRunnerThreadAndCallEventHandler(fn, ...)
	local AcquiredRunnerThread = FreeRunnerThread
	FreeRunnerThread = nil
	fn(...)
	-- The handler finished running, this runner thread is free again.
	FreeRunnerThread = AcquiredRunnerThread
end

local function RunEventHandlerInFreeThread(...)
	AcquireRunnerThreadAndCallEventHandler(...)

	while true do
		AcquireRunnerThreadAndCallEventHandler(coroutine.yield())
	end
end

function Signal.new<T...>(): Signal<T...>
	local self = setmetatable({
		_HandlerListHead = false,
		_ProxyHandler = nil,
		_YieldedThreads = nil,
	}, Signal)

	return self :: any
end

function Signal.Wrap<T...>(rbxScriptSignal: RBXScriptSignal): Signal<T...>
	assert(
		typeof(rbxScriptSignal) == "RBXScriptSignal",
		"Argument #1 to Signal.Wrap must be a RBXScriptSignal; got " .. typeof(rbxScriptSignal)
	)

	local signal = Signal.new() :: any
	signal._ProxyHandler = rbxScriptSignal:Connect(function(...)
		signal:Fire(...)
	end)

	return signal
end

function Signal.Is(obj: any): boolean
	return type(obj) == "table" and getmetatable(obj) == Signal
end

function Signal.Connect<T...>(self: Signal<T...>, fn)
	local ThisConnection = setmetatable({
		Connected = true,
		_Signal = self,
		_Fn = fn,
		_Next = false,
	}, Connection) :: any

	if (self :: any)._HandlerListHead then
		ThisConnection._Next = self._HandlerListHead;
		(self :: any)._HandlerListHead = ThisConnection
	else
		(self :: any)._HandlerListHead = ThisConnection
	end

	return ThisConnection
end

function Signal.ConnectOnce<T...>(self: Signal<T...>, fn)
	return self:Once(fn)
end

function Signal.Once<T...>(self: Signal<T...>, fn)
	local ThisConnection: Connection
	local Done = false

	ThisConnection = self:Connect(function(...)
		if Done then
			return
		end

		Done = true
		ThisConnection:Disconnect()
		fn(...)
	end)

	return ThisConnection
end

function Signal.GetConnections<T...>(self: Signal<T...>)
	local Items = {}

	local Item = (self :: any)._HandlerListHead
	while Item do
		table.insert(Items, Item)
		Item = Item._Next
	end

	return Items
end

function Signal.DisconnectAll<T...>(self: Signal<T...>)
	local Item = (self :: any)._HandlerListHead
	while Item do
		Item.Connected = false
		Item = Item._Next
	end
	(self :: any)._HandlerListHead = false

	local YieldedThreads = rawget(self :: any, "_YieldedThreads") :: {[thread]: unknown}?
	if YieldedThreads then
		for thread in YieldedThreads do
			if coroutine.status(thread) == "suspended" then
				warn(debug.traceback(thread, "signal disconnected; yielded thread cancelled", 2))
				task.cancel(thread)
			end
		end
		table.clear((self :: any)._YieldedThreads)
	end
end

function Signal.Fire<T...>(self: Signal<T...>, ...)
	local Item = (self :: any)._HandlerListHead
	while Item do
		if Item.Connected then
			-- Fix: We must check the status of the cached thread before attempting to reuse it, as it could have been
			-- closed externally, and that would break dispatch.
			if not FreeRunnerThread or coroutine.status(FreeRunnerThread :: thread) ~= "suspended" then
				FreeRunnerThread = coroutine.create(RunEventHandlerInFreeThread)
			end
			task.spawn(FreeRunnerThread :: thread, Item._Fn, ...)
		end
		Item = Item._Next
	end
end

function Signal.FireDeferred<T...>(self: Signal<T...>, ...)
	local Item = (self :: any)._HandlerListHead
	while Item do
		local Conn = Item
		task.defer(function(...)
			if Conn.Connected then
				Conn._Fn(...)
			end
		end, ...)
		Item = Item._Next
	end
end

function Signal.Wait<T...>(self: Signal<T...>)
	local YieldedThreads = rawget(self :: any, "_YieldedThreads") :: {[thread]: unknown}?
	if not YieldedThreads then
		YieldedThreads = {} :: {[thread]: unknown}?
		rawset(self :: any, "_YieldedThreads", YieldedThreads)
	end

	local _: typeof(assert(YieldedThreads))
	local Thread = coroutine.running()
	YieldedThreads[Thread] = true

	self:Once(function(...)
		local _: typeof(assert(YieldedThreads))
		YieldedThreads[Thread] = nil

		if coroutine.status(Thread) == "suspended" then
			task.spawn(Thread, ...)
		end
	end)

	return coroutine.yield()
end

function Signal.Destroy<T...>(self: Signal<T...>)
	self:DisconnectAll()

	local ProxyHandler = rawget(self :: any, "_ProxyHandler")
	if ProxyHandler then
		ProxyHandler:Disconnect()
	end
end

-- Make signal strict
setmetatable(Signal, {
	__index = function(_tb, key)
		error(("Attempt to get Signal::%s (not a valid member)"):format(tostring(key)), 2)
	end,
	__newindex = function(_tb, key, _value)
		error(("Attempt to set Signal::%s (not a valid member)"):format(tostring(key)), 2)
	end,
})

return Signal
