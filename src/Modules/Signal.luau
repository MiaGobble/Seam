-- Author: Sleitnick, modified by iGottic

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

function Connection.new(ThisSignal, Callback)
    return setmetatable({
        Signal = ThisSignal,
        Callback = Callback
    }, Connection)
end

function Connection.Disconnect(self)
    self.Signal[self] = nil
end

function Connection.Destroy(self, ...)
    Connection.Disconnect(self, ...)
end

function Signal.new()
    return setmetatable({} :: any, Signal)
end

function Signal.Connect(self, Callback)
    local SelfConnection = Connection.new(self, Callback)
    self[SelfConnection] = true
    
    return SelfConnection
end

function Signal.Once(self, Callback)
    local SelfConnection; SelfConnection = Connection.new(self, function(...)
        SelfConnection.Disconnect(self)
        Callback(...)
    end)
    
    self[SelfConnection] = true
    
    return SelfConnection
end

function Signal.Wait(self)
    local WaitingCoroutine = coroutine.running()
    
    local SelfConnection; SelfConnection = self:Connect(function(...)
        SelfConnection.Disconnect(self)
        task.spawn(WaitingCoroutine, ...)
    end)
    
    return coroutine.yield()
end

function Signal.DisconnectAll(self)
    table.clear(self)
end

function Signal.Fire(self, ...)
    if next(self) then
        for SelfConnection in pairs(self) do
            SelfConnection.Callback(...)
        end
    end
end

return Signal :: {new: () -> Signal<...any>}