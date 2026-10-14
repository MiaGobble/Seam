return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Seam = context.Seam
	local Vector3 = context.roblox.Vector3

	local Spring = Seam.Spring
	local Value = Seam.Value

	describe("Spring", function()
		it("starts at the initial value and moves toward a new target", function()
			local spring = Spring(0, 10, 1)
			expect(spring.Value).toBe(0)
			expect(spring.Velocity).toBeCloseTo(0)
			expect(spring.Speed).toBe(10)
			expect(spring.Dampening).toBe(1)

			context.step(0)
			spring.Target = 10
			context.advance(0.2)
			context.step(0.2)

			expect(spring.Value > 0).toBe(true)
			expect(spring.Value < 10).toBe(true)

			local fires = 0
			spring.Changed:Connect(function(propertyName)
				fires += 1
				expect(propertyName).toBe("Value")
			end)

			context.advance(5)
			context.step(0)
			expect(spring.Value).toBeCloseTo(10)
			expect(fires).toBe(1)

			context.step(0)
			expect(fires).toBe(1)
			expect(spring.Value).toBeCloseTo(10)

			spring.Target = 0
			context.advance(5)
			context.step(0)
			expect(spring.Value).toBeCloseTo(0)
			spring:Destroy()
		end)

		it("reads speed and dampening from states and animates vectors", function()
			local speed = Value(12)
			local dampening = Value(1)
			local spring = Spring(Vector3.new(0, 0, 0), speed, dampening)

			spring.Target = Vector3.new(10, 0, 0)
			spring.Speed = speed
			spring.Dampening = dampening
			context.advance(5)
			context.step(0)

			expect(spring.Value.X).toBeCloseTo(10)
			expect(spring.Value.Y).toBeCloseTo(0)
			expect(spring.Value.Z).toBeCloseTo(0)

			spring.Value = Vector3.new(2, 0, 0)
			context.step(0)
			expect(spring.Value.X).toBeCloseTo(2)

			spring:Destroy()
			speed:Destroy()
			dampening:Destroy()
		end)

		it("follows a state used as the goal", function()
			local goal = Value(0)
			local spring = Spring(goal, 10, 1)

			goal.Value = 10
			context.step(0)
			context.advance(5)
			context.step(0)
			expect(spring.Value).toBeCloseTo(10)

			spring:Destroy()
			goal:Destroy()
		end)
	end)
end
