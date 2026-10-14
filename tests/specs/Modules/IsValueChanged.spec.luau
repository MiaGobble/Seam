return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect

	local IsValueChanged = context.requirePath({ "Modules", "IsValueChanged" })

	describe("IsValueChanged", function()
		it("treats different types and different values as changes", function()
			expect(IsValueChanged(1, 1)).toBe(false)
			expect(IsValueChanged(1, 2)).toBe(true)
			expect(IsValueChanged(1, "1")).toBe(true)
			expect(IsValueChanged(nil, nil)).toBe(false)
			expect(IsValueChanged(false, true)).toBe(true)

			local same = {}
			expect(IsValueChanged(same, same)).toBe(false)
			expect(IsValueChanged({ a = 1 }, { a = 1 })).toBe(true)
		end)
	end)
end
