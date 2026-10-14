return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Seam = context.Seam

	local Value = Seam.Value
	local Computed = Seam.Computed

	describe("Computed", function()
		it("computes from dependencies and updates when they change", function()
			local width = Value(2)
			local height = Value(3)
			local area = Computed(function(use)
				return use(width) * use(height)
			end)

			expect(area.Value).toBe(6)

			width.Value = 4
			expect(area.Value).toBe(12)

			local fires = 0
			area.Changed:Connect(function()
				fires += 1
			end)
			height.Value = 5
			expect(area.Value).toBe(20)
			expect(fires).toBe(1)

			area:Destroy()
			width:Destroy()
			height:Destroy()
		end)

		it("reads the latest dependency value on first use", function()
			local value = Value(1)
			local doubled = Computed(function(use)
				return use(value) * 2
			end)

			value.Value = 4
			expect(doubled.Value).toBe(8)

			doubled:Destroy()
			value:Destroy()
		end)

		it("propagates through nested computations", function()
			local value = Value(2)
			local plusOne = Computed(function(use)
				return use(value) + 1
			end)
			local doubled = Computed(function(use)
				return use(plusOne) * 2
			end)

			expect(doubled.Value).toBe(6)
			value.Value = 4
			expect(doubled.Value).toBe(10)

			doubled:Destroy()
			plusOne:Destroy()
			value:Destroy()
		end)

		it("drops dependencies that are no longer used", function()
			local choice = Value(true)
			local first = Value(1)
			local second = Value(10)
			local selected = Computed(function(use)
				if use(choice) then
					return use(first)
				end

				return use(second)
			end)

			expect(selected.Value).toBe(1)
			choice.Value = false
			expect(selected.Value).toBe(10)

			first.Value = 5
			expect(selected.Value).toBe(10)

			second.Value = 7
			expect(selected.Value).toBe(7)

			selected:Destroy()
			choice:Destroy()
			first:Destroy()
			second:Destroy()
		end)

		it("passes plain values through use without tracking them", function()
			local computed = Computed(function(use)
				return use(5) + use("ok"):len()
			end)

			expect(computed.Value).toBe(7)
			computed:Destroy()
		end)

		it("does not re-enter while a computation is running", function()
			local value = Value(1)
			local computed = Computed(function(use)
				if use(value) == 1 then
					value.Value = 2
				end

				return use(value)
			end)

			expect(computed.Value).toBe(2)
			computed:Destroy()
			value:Destroy()
		end)
	end)
end
