return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect

	local CreateDeepTraceback = context.requirePath({ "Modules", "CreateDeepTraceback" })

	describe("CreateDeepTraceback", function()
		it("returns a traceback string", function()
			local traceback = CreateDeepTraceback()
			expect(typeof(traceback)).toBe("string")
			expect(#traceback > 0).toBe(true)
		end)
	end)
end
