local Connection = {}
Connection.__index = Connection

-- Types
export type Connection = {
	Disconnect : (self : Connection) -> (),
	Destroy : (self : Connection) -> (),
	Connected : boolean,
}

function Connection.Disconnect(self : Connection)
	if not self.Connected then
		return
	end

	self.Connected = false

	if (self :: any)._Signal._HandlerListHead == self then
		self._Signal._HandlerListHead = (self :: any)._Next
	else
		local Prev = self._Signal._HandlerListHead

		while Prev and Prev._Next ~= self do
			Prev = Prev._Next
		end

		if Prev then
			Prev._Next = (self :: any)._Next
		end
	end
end

Connection.Destroy = Connection.Disconnect

setmetatable(Connection, {
	__index = function(_tb, key)
		error(`Attempt to get Connection::{key} (not a valid member)`, 2)
	end,
	__newindex = function(_tb, key, _value)
		error(`Attempt to set Connection::{key} (not a valid member)`, 2)
	end,
})

return Connection
