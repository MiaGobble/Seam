return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect

	local Signal = context.requirePath({ "Modules", "Signal" })

	describe("Signal", function()
		it("fires connected handlers in reverse connection order", function()
			local signal = Signal.new()
			local order = {}

			signal:Connect(function(value)
				table.insert(order, value + 1)
			end)
			local second = signal:Connect(function(value)
				table.insert(order, value + 2)
			end)
			signal:Once(function(value)
				table.insert(order, value + 3)
			end)

			expect(Signal.Is(signal)).toBe(true)
			expect(Signal.Is({})).toBe(false)
			expect(#signal:GetConnections()).toBe(3)

			signal:Fire(10)
			expect(order).toEqual({ 13, 12, 11 })

			second:Disconnect()
			signal:Fire(10)
			expect(order).toEqual({ 13, 12, 11, 11 })
			expect(#signal:GetConnections()).toBe(1)

			signal:Destroy()
			signal:Fire(10)
			expect(#order).toBe(4)
		end)

		it("waits for the next fire and can defer handlers", function()
			local signal = Signal.new()
			local waited = nil
			context.task.spawn(function()
				waited = signal:Wait()
			end)

			signal:Fire("ready")
			expect(waited).toBe("ready")

			local deferred = nil
			signal:FireDeferred("later")
			expect(deferred).toBeNil()
			signal:Connect(function(value)
				deferred = value
			end)
			signal:FireDeferred("later")
			expect(deferred).toBeNil()
			context.task.wait()
			expect(deferred).toBe("later")
			signal:Destroy()
		end)

		it("cancels waiting threads on disconnect and rejects invalid use", function()
			local signal = Signal.new()
			local thread = context.task.spawn(function()
				signal:Wait()
			end)

			signal:DisconnectAll()
			expect(coroutine.status(thread)).toBe("dead")

			expect(function()
				Signal.Wrap({})
			end).toThrow("RBXScriptSignal")

			expect(function()
				return Signal.Missing
			end).toThrow("not a valid member")
		end)
	end)
end
