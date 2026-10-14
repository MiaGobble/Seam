return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Seam = context.Seam
	local Instance = context.Instance

	local OnAttached = Seam.OnAttached
	local Value = Seam.Value

	describe("OnAttached", function()
		it("fires when a state is attached and can be disconnected", function()
			local state = Value("Panel")
			local folder = Instance.new("Folder")
			local hits = 0
			local connection = OnAttached(state, function(attached)
				hits += 1
				expect(attached).toBe(folder)
			end)

			state(folder, "Name")
			context.step(0)
			expect(hits).toBe(1)
			expect(folder.Name).toBe("Panel")

			state.Value = "Drawer"
			context.step(0)
			expect(folder.Name).toBe("Drawer")

			connection:Disconnect()
			state(folder, "Name")
			expect(hits).toBe(1)
			state:Destroy()
		end)
	end)
end
