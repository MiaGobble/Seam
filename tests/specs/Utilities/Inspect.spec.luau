return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Seam = context.Seam

	local Inspect = Seam.Inspect
	local Value = Seam.Value

	describe("Inspect", function()
		it("requires a debug name", function()
			expect(function()
				Inspect(Value(1), nil)
			end).toThrow("Expected DebugName, got nil")
		end)

		it("prints the new value and stops after disconnect", function()
			local state = Value(1)
			local connection = Inspect(state, "Health")

			state.Value = 4

			local prints = context.takePrints()
			expect(prints[#prints]).toContain("SEAM_Health.Value = 4")

			connection:Disconnect()
			state.Value = 9

			local later = context.takePrints()
			expect(#later).toBe(#prints)
			state:Destroy()
		end)
	end)
end
