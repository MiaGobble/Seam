-- Author: Unknown, modified by iGottic

--[=[
    @class Signal
    @since 0.0.1
]=]

local Signal = {}
Signal.__index = Signal

local Connection = {}
Connection.__index = Connection

-- Types
type Connection = {
    Disconnect: (self: any) -> ()
}

export type Signal<T...> = {
    Fire: (self: any, T...) -> (),
    Connect: (self: any, Fn: (T...) -> ()) -> Connection,
    Once: (self: any, Fn: (T...) -> ()) -> Connection,
    Wait: (self: any) -> T...,
    DisconnectAll: (self: any) -> ()
}

--[=[
    Creates a new connection object.
    
    @param Signal Signal -- The signal to connect to
    @param Callback function -- The callback function to call when the signal fires
    @return Connection -- The connection object
]=]

function Connection.new(Signal, Callback)
    return setmetatable({
        Signal = Signal,
        Callback = Callback
    }, Connection)
end

--[=[
    Disconnects the connection from the signal.
    
    @return nil
]=]

function Connection:Disconnect()
    self.Signal[self] = nil
end

--[=[
    Creates a new signal object.
    
    @return Signal -- The signal object
]=]

function Signal.new()
    return setmetatable({} :: any, Signal)
end

--[=[
    Connects a callback function to the signal.
    
    @param Callback function -- The callback function to call when the signal fires
    @return Connection -- The connection object
]=]

function Signal:Connect(Callback)
    local SelfConnection = Connection.new(self, Callback)
    self[SelfConnection] = true
    
    return SelfConnection
end

--[=[
    Connects a callback function to the signal that will only be called once.
    
    @param Callback function -- The callback function to call when the signal fires
    @return Connection -- The connection object
]=]

function Signal:Once(Callback)
    local SelfConnection; SelfConnection = Connection.new(self, function(...)
        SelfConnection:Disconnect()
        Callback(...)
    end)
    
    self[SelfConnection] = true
    
    return SelfConnection
end

--[=[
    Waits for the signal to fire and returns the arguments passed to it.
    
    @return T... -- The arguments passed to the signal
]=]

function Signal:Wait()
    local WaitingCoroutine = coroutine.running()
    
    local SelfConnection; SelfConnection = self:Connect(function(...)
        SelfConnection:Disconnect()
        task.spawn(WaitingCoroutine, ...)
    end)
    
    return coroutine.yield()
end

--[=[
    Disconnects all connections from the signal.
    
    @return nil
]=]

function Signal:DisconnectAll()
    table.clear(self)
end

--[=[
    Fires the signal with the given arguments.
    
    @param ... any -- The arguments to pass to the signal
    @return nil
]=]

function Signal:Fire(...)
    if next(self) then
        for SelfConnection in pairs(self) do
            SelfConnection.Callback(...)
        end
    end
end

return Signal :: {new: () -> Signal<...any>}