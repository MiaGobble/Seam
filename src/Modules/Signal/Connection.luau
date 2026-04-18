--[=[
	@within Signal
	@interface SignalConnection
	.Connected boolean
	.Disconnect (SignalConnection) -> ()

	Represents a connection to a signal.
	```lua
	local ConnectionObj = SignalInstance:Connect(function() end)
	print(ConnectionObj.Connected) --> true
	ConnectionObj:Disconnect()
	print(ConnectionObj.Connected) --> false
	```
]=]

local Connection = {}
Connection.__index = Connection

-- Types
export type Connection = {
	Disconnect: (self: Connection) -> (),
	Destroy: (self: Connection) -> (),
	Connected: boolean,
}

function Connection.Disconnect(self : Connection)
	if not self.Connected then
		return
	end

	self.Connected = false

	if self._signal._handlerListHead == self then
		self._signal._handlerListHead = self._next
	else
		local prev = self._signal._handlerListHead

		while prev and prev._next ~= self do
			prev = prev._next
		end

		if prev then
			prev._next = self._next
		end
	end
end

Connection.Destroy = Connection.Disconnect

setmetatable(Connection, {
	__index = function(_tb, key)
		error(("Attempt to get Connection::%s (not a valid member)"):format(tostring(key)), 2)
	end,
	__newindex = function(_tb, key, _value)
		error(("Attempt to set Connection::%s (not a valid member)"):format(tostring(key)), 2)
	end,
})

return Connection