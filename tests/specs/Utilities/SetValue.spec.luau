return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Seam = context.Seam

	local SetValue = Seam.SetValue
	local Value = Seam.Value

	describe("SetValue", function()
		it("returns the new value when the state is nil", function()
			expect(SetValue(nil, 5)).toBe(5)
		end)

		it("writes states and tables that already have a Value field", function()
			local state = Value(1)
			expect(SetValue(state, 8)).toBe(8)
			expect(state.Value).toBe(8)
			state:Destroy()

			local plain = { Value = 1 }
			expect(SetValue(plain, 9)).toBe(9)
			expect(plain.Value).toBe(9)
		end)

		it("leaves non-state values unchanged", function()
			expect(SetValue(3, 4)).toBe(4)
			expect(SetValue("keep", "next")).toBe("next")
		end)

		it("does not assign through a state whose current value is nil", function()
			local state = Value(nil)
			SetValue(state, 3)
			expect(state.Value).toBeNil()
			state:Destroy()
		end)
	end)
end
