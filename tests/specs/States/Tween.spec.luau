return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Seam = context.Seam
	local Enum = context.roblox.Enum

	local Tween = Seam.Tween
	local Value = Seam.Value

	local function linear(time)
		return {
			Time = time,
			EasingStyle = Enum.EasingStyle.Linear,
			EasingDirection = Enum.EasingDirection.Out,
		}
	end

	describe("Tween", function()
		it("interpolates toward the target over the tween duration", function()
			local tween = Tween(0, linear(1))
			expect(tween.Value).toBe(0)
			expect(tween.TweenInfo.Time).toBe(1)

			tween.Target = 10
			context.advance(0.25)
			context.step(0)
			expect(tween.Value).toBeCloseTo(2.5)

			local fires = 0
			tween.Changed:Connect(function()
				fires += 1
			end)

			context.advance(0.75)
			context.step(0)
			expect(tween.Value).toBeCloseTo(10)
			expect(fires).toBe(1)

			context.step(0)
			expect(fires).toBe(1)
			tween:Destroy()
		end)

		it("reads tween info from a state and can snap the current value", function()
			local info = Value(linear(1))
			local tween = Tween(0, info)
			tween.Target = 10

			context.advance(0.25)
			context.step(0)
			expect(tween.Value).toBeCloseTo(2.5)

			info.Value = linear(0.25)
			context.step(0)
			expect(tween.Value).toBeCloseTo(10)

			tween.Value = 4
			context.step(0)
			expect(tween.Value).toBeCloseTo(4)
			tween:Destroy()
			info:Destroy()
		end)

		it("follows a state used as the goal", function()
			local goal = Value(0)
			local tween = Tween(goal, linear(1))

			goal.Value = 8
			context.step(0)
			context.advance(1)
			context.step(0)
			expect(tween.Value).toBeCloseTo(8)

			tween:Destroy()
			goal:Destroy()
		end)
	end)
end
