return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Seam = context.Seam

	local LockValue = Seam.LockValue
	local Value = Seam.Value

	describe("LockValue", function()
		it("rejects anything other than a Value state", function()
			expect(function()
				LockValue(nil)
			end).toThrow("You can only lock a value state")

			expect(function()
				LockValue(Seam.Computed(function()
					return 1
				end))
			end).toThrow("You can only lock a value state")
		end)

		it("freezes a value and still allows reads", function()
			local state = Value("open")
			LockValue(state)

			expect(state.Value).toBe("open")
			expect(function()
				state.Value = "closed"
			end).toThrow("Attempt to modify value when locked.")
			expect(state.Value).toBe("open")
		end)

		it("cannot be unlocked", function()
			local state = Value(1)
			LockValue(state)

			expect(function()
				state.__LOCKED = false
			end).toThrow("Can not unlock values.")
		end)
	end)
end
