return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Seam = context.Seam

	describe("Seam", function()
		it("exports every public feature", function()
			local expectedList = {
				"Attribute",
				"Batch",
				"Bezier",
				"Children",
				"Component",
				"Computed",
				"Destroyed",
				"EventSequence",
				"FollowAttribute",
				"FollowProperty",
				"ForPairs",
				"GetValue",
				"Inspect",
				"IsComponent",
				"IsState",
				"Lifetime",
				"LockValue",
				"New",
				"OnAttached",
				"OnAttributeChanged",
				"OnChanged",
				"OnEvent",
				"Rendered",
				"Resource",
				"Scope",
				"SetValue",
				"Spring",
				"StyleSheet",
				"Tags",
				"Tween",
				"Value",
			}

			local expected = {}
			for _, key in expectedList do
				expected[key] = true
				expect(Seam[key]).toBeTruthy()
			end

			for key in Seam do
				expect(expected[key]).toBe(true)
			end

			expect(typeof(Seam.StyleSheet.new)).toBe("function")
			expect(typeof(Seam.StyleSheet.group)).toBe("function")
			expect(typeof(Seam.Batch.Begin)).toBe("function")
			expect(typeof(Seam.Batch.End)).toBe("function")
			expect(typeof(Seam.Batch.Fire)).toBe("function")
		end)
	end)
end
