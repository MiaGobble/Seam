local function createSignal()
    local connections = {}

    local signal = {}

    function signal:Connect(callback)
        local connection = {
            Connected = true,
        }

        function connection:Disconnect()
            self.Connected = false
        end

        table.insert(connections, {
            callback = callback,
            connection = connection,
        })

        return connection
    end

    function signal:Once(callback)
        local connection
        connection = self:Connect(function(...)
            if connection.Connected then
                connection:Disconnect()
            end

            callback(...)
        end)

        return connection
    end

    function signal:Wait()
        return
    end

    function signal:Fire(...)
        for _, entry in connections do
            if entry.connection.Connected then
                entry.callback(...)
            end
        end
    end

    return signal
end

return createSignal
