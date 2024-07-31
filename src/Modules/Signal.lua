--!strict

local signal = {}
signal.__index = signal

local connection = {}
connection.__index = connection

function connection.new(signal, callback)
	return setmetatable({
		signal = signal,
		callback = callback
	}, connection)
end

function connection.Disconnect(self)
	self.signal[self] = nil
end

function signal.new()
	return setmetatable({} :: any, signal)
end

function signal.Connect(self, callback)
	local selfConnection = connection.new(self, callback)
	self[selfConnection] = true
	
	return selfConnection
end

function signal.Once(self, callback)
	local selfConnection; selfConnection = connection.new(self, function(...)
		selfConnection:Disconnect()
		callback(...)
	end)
	
	self[selfConnection] = true
	
	return selfConnection
end

function signal.Wait(self)
	local waitingCoroutine = coroutine.running()
	
	local selfConnection; selfConnection = self:Connect(function(...)
		selfConnection:Disconnect()
		task.spawn(waitingCoroutine, ...)
	end)
	
	return coroutine.yield()
end

function signal.DisconnectAll(self)
	table.clear(self)
end

function signal.Fire(self, ...)
	if next(self) then
		for selfConnection in pairs(self) do
			selfConnection.callback(...)
		end
	end
end

type connection = {
	Disconnect: (self: any) -> ()
}

export type signal<T...> = {
	Fire: (self: any, T...) -> (),
	Connect: (self: any, FN: (T...) -> ()) -> connection,
	Once: (self: any, FN: (T...) -> ()) -> connection,
	Wait: (self: any) -> T...,
	DisconnectAll: (self: any) -> ()
}


return signal :: {new: () -> signal<...any>}