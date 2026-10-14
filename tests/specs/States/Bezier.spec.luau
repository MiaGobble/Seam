return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Seam = context.Seam
	local Vector3 = context.roblox.Vector3

	local Bezier = Seam.Bezier
	local Value = Seam.Value

	describe("Bezier", function()
		it("evaluates a quadratic curve and clamps alpha", function()
			local curve = Bezier(0.5, 0, 100, 0)
			expect(curve.Value).toBe(50)
			expect(curve.Alpha).toBe(0.5)
			expect(curve.Origin).toBe(0)
			expect(curve.Midpoint).toBe(100)
			expect(curve.Target).toBe(0)

			local atStart = Bezier(-2, 3, 9, 12)
			local atEnd = Bezier(4, 3, 9, 12)
			expect(atStart.Value).toBe(3)
			expect(atEnd.Value).toBe(12)

			curve:Destroy()
			atStart:Destroy()
			atEnd:Destroy()
		end)

		it("follows state inputs and can be rebound", function()
			local alpha = Value(0)
			local origin = Value(0)
			local curve = Bezier(alpha, origin, 10, 20)

			expect(curve.Value).toBe(0)
			expect(curve.Alpha).toBe(alpha)

			alpha.Value = 1
			expect(curve.Value).toBe(20)

			local nextAlpha = Value(0)
			curve.Alpha = nextAlpha
			curve.Origin = 5
			expect(curve.Alpha).toBe(nextAlpha)
			expect(curve.Value).toBe(5)

			curve.Value = 7
			expect(curve.Value).toBe(7)

			curve:Destroy()
			nextAlpha:Destroy()
			origin:Destroy()
			alpha:Destroy()
		end)

		it("interpolates Vector3 components", function()
			local curve = Bezier(0.5, Vector3.new(0, 0, 0), Vector3.new(0, 10, 0), Vector3.new(0, 0, 0))
			local value = curve.Value

			expect(value.X).toBeCloseTo(0)
			expect(value.Y).toBeCloseTo(5)
			expect(value.Z).toBeCloseTo(0)
			curve:Destroy()
		end)

		it("rejects alpha or points that do not share a type", function()
			expect(function()
				Bezier("fast", 0, 1, 2)
			end).toThrow("Bezier alpha must resolve to a number")

			expect(function()
				Bezier(0, 0, "mid", 2)
			end).toThrow("must resolve to the same type")
		end)
	end)
end
