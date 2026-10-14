return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect

	local Symbol = context.requirePath({ "Modules", "Symbol" })

	describe("Symbol", function()
		it("stringifies to its name and does not alias other symbols", function()
			local first = Symbol.new("Value")
			local second = Symbol.new("Value")

			expect(tostring(first)).toBe("Value")
			expect(tostring(second)).toBe("Value")
			expect(first == second).toBe(false)
		end)
	end)
end
