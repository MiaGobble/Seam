return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Seam = context.Seam

	local Batch = Seam.Batch
	local Value = Seam.Value

	describe("Batch", function()
		it("returns the callback results and flushes each signal once", function()
			local state = Value(1)
			local seen = {}
			state.Changed:Connect(function(_property, value)
				table.insert(seen, value)
			end)

			local first, second = Batch(function(amount)
				state.Value = 2
				state.Value = amount
				return amount + 1, amount + 2
			end, 3)

			expect(first).toBe(4)
			expect(second).toBe(5)
			expect(state.Value).toBe(3)
			expect(seen).toEqual({ 3 })
			state:Destroy()
		end)

		it("waits for the outermost batch before firing", function()
			local state = Value(0)
			local seen = {}
			state.Changed:Connect(function(_property, value)
				table.insert(seen, value)
			end)

			Batch.Begin()
			Batch.Begin()
			state.Value = 1
			Batch.End()
			expect(seen).toEqual({})
			state.Value = 2
			Batch.End()
			expect(seen).toEqual({ 2 })
			state:Destroy()
		end)

		it("closes the batch when the callback throws", function()
			local state = Value(1)
			local seen = {}
			state.Changed:Connect(function(_property, value)
				table.insert(seen, value)
			end)

			expect(function()
				Batch(function()
					state.Value = 6
					error("stopped")
				end)
			end).toThrow("stopped")

			expect(state.Value).toBe(6)
			expect(seen).toEqual({ 6 })

			state.Value = 7
			expect(seen).toEqual({ 6, 7 })
			state:Destroy()
		end)

		it("errors when End is called without Begin", function()
			expect(function()
				Batch.End()
			end).toThrow("without a matching Begin")
		end)
	end)
end
