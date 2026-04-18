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

	if self._Signal._HandlerListHead == self then
		self._Signal._HandlerListHead = self._Next
	else
		local prev = self._Signal._HandlerListHead

		while prev and prev._Next ~= self do
			prev = prev._Next
		end

		if prev then
			prev._Next = self._Next
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