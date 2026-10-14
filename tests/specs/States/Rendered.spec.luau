return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Seam = context.Seam

	local Rendered = Seam.Rendered

	describe("Rendered", function()
		it("runs once on read and again on each frame with the elapsed time", function()
			local samples = {}
			local rendered = Rendered(function(deltaTime)
				table.insert(samples, deltaTime)
				return #samples
			end)

			expect(rendered.Value).toBe(1)
			expect(samples[1]).toBe(0)

			context.advance(0.25)
			context.step(0.25)
			expect(samples[2]).toBeCloseTo(0.25)
			expect(rendered.Value).toBe(2)

			rendered:Destroy()
			context.advance(0.25)
			context.step(0.25)
			expect(#samples).toBe(2)
		end)
	end)
end
