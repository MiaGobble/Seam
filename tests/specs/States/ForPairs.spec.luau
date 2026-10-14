return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Seam = context.Seam

	local ForPairs = Seam.ForPairs
	local Value = Seam.Value

	describe("ForPairs", function()
		it("maps table entries and only recomputes keys that changed", function()
			local source = Value({ a = 1, b = 2 })
			local calls = {}
			local mapped = ForPairs(source, function(_use, index, value)
				calls[index] = (calls[index] or 0) + 1
				return value * 10
			end)

			expect(mapped.Value).toEqual({ a = 10, b = 20 })
			expect(calls).toEqual({ a = 1, b = 1 })

			source.Value = { a = 1, b = 4, c = 3 }
			expect(mapped.Value).toEqual({ a = 10, b = 40, c = 30 })
			expect(calls.a).toBe(1)
			expect(calls.b).toBe(2)
			expect(calls.c).toBe(1)

			source.Value = { a = 1 }
			expect(mapped.Value).toEqual({ a = 10 })
			expect(calls.a).toBe(1)

			mapped:Destroy()
			source:Destroy()
		end)

		it("requires the tracked value to be a table", function()
			local source = Value(1)
			local mapped = ForPairs(source, function()
				return nil
			end)

			expect(function()
				return mapped.Value
			end).toThrow("ForPairs needs a table value")

			mapped:Destroy()
			source:Destroy()
		end)
	end)
end
