return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Seam = context.Seam

	local IsState = Seam.IsState
	local Value = Seam.Value
	local Computed = Seam.Computed

	describe("IsState", function()
		it("returns false for non-tables", function()
			expect(IsState(nil)).toBe(false)
			expect(IsState(1)).toBe(false)
			expect(IsState("state")).toBe(false)
		end)

		it("returns false for plain tables", function()
			expect(IsState({})).toBe(false)
			expect(IsState({ Value = 1 })).toBe(false)
		end)

		it("returns true for Seam state objects", function()
			local value = Value(1)
			local computed = Computed(function(use)
				return use(value) + 1
			end)
			local resource = Seam.Resource(function()
				return 1
			end)
			local bezier = Seam.Bezier(0, 0, 1, 2)
			local spring = Seam.Spring(0, 1, 1)
			local tween = Seam.Tween(0, { Time = 1 })
			local rendered = Seam.Rendered(function()
				return 0
			end)
			local pairsState = Seam.ForPairs(Value({ a = 1 }), function(_use, _index, item)
				return item
			end)

			expect(IsState(value)).toBe(true)
			expect(IsState(computed)).toBe(true)
			expect(IsState(resource)).toBe(true)
			expect(IsState(bezier)).toBe(true)
			expect(IsState(spring)).toBe(true)
			expect(IsState(tween)).toBe(true)
			expect(IsState(rendered)).toBe(true)
			expect(IsState(pairsState)).toBe(true)

			pairsState:Destroy()
			rendered:Destroy()
			tween:Destroy()
			spring:Destroy()
			bezier:Destroy()
			resource:Destroy()
			computed:Destroy()
			value:Destroy()
		end)
	end)
end
