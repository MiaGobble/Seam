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

local FreeRunnerThread = nil

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

	return self
end

function Signal.Wrap<T...>(rbxScriptSignal: RBXScriptSignal): Signal<T...>
	assert(
		typeof(rbxScriptSignal) == "RBXScriptSignal",
		"Argument #1 to Signal.Wrap must be a RBXScriptSignal; got " .. typeof(rbxScriptSignal)
	)

	local signal = Signal.new()
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
	}, Connection)

	if self._HandlerListHead then
		ThisConnection._Next = self._HandlerListHead
		self._HandlerListHead = ThisConnection
	else
		self._HandlerListHead = ThisConnection
	end

	return ThisConnection
end

function Signal.ConnectOnce<T...>(self: Signal<T...>, fn)
	return self:Once(fn)
end

function Signal.Once<T...>(self: Signal<T...>, fn)
	local ThisConnection
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

	local Item = self._HandlerListHead
	while Item do
		table.insert(Items, Item)
		Item = Item._Next
	end

	return Items
end

function Signal.DisconnectAll<T...>(self: Signal<T...>)
	local Item = self._HandlerListHead
	while Item do
		Item.Connected = false
		Item = Item._Next
	end
	self._HandlerListHead = false

	local YieldedThreads = rawget(self, "_YieldedThreads")
	if YieldedThreads then
		for thread in YieldedThreads do
			if coroutine.status(thread :: thread) == "suspended" then -- Doing a typecast to silence a linter error
				warn(debug.traceback(thread, "signal disconnected; yielded thread cancelled", 2))
				task.cancel(thread)
			end
		end
		table.clear(self._YieldedThreads)
	end
end

function Signal.Fire<T...>(self: Signal<T...>, ...)
	local Item = self._HandlerListHead
	while Item do
		if Item.Connected then
			if not FreeRunnerThread then
				FreeRunnerThread = coroutine.create(RunEventHandlerInFreeThread)
			end
			task.spawn(FreeRunnerThread, Item._Fn, ...)
		end
		Item = Item._Next
	end
end

function Signal.FireDeferred<T...>(self: Signal<T...>, ...)
	local Item = self._HandlerListHead
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
	local YieldedThreads = rawget(self, "_YieldedThreads")
	if not YieldedThreads then
		YieldedThreads = {}
		rawset(self, "_YieldedThreads", YieldedThreads)
	end

	local Thread = coroutine.running()
	YieldedThreads[Thread] = true

	self:Once(function(...)
		YieldedThreads[Thread] = nil

		if coroutine.status(Thread) == "suspended" then
			task.spawn(Thread, ...)
		end
	end)

	return coroutine.yield()
end

function Signal.Destroy<T...>(self: Signal<T...>)
	self:DisconnectAll()

	local ProxyHandler = rawget(self, "_ProxyHandler")
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