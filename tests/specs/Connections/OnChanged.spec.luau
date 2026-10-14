return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Seam = context.Seam
	local Instance = context.Instance

	local OnChanged = Seam.OnChanged
	local Value = Seam.Value

	describe("OnChanged", function()
		it("reports state changes", function()
			local state = Value(1)
			local seen = {}
			local connection = OnChanged(state, function(propertyName, value)
				table.insert(seen, { propertyName, value })
			end)

			state.Value = 4
			expect(seen).toEqual({ { "Value", 4 } })

			connection:Disconnect()
			state.Value = 5
			expect(#seen).toBe(1)
			state:Destroy()
		end)

		it("reports instance property changes", function()
			local folder = Instance.new("Folder")
			local seen = nil
			OnChanged(folder, function(propertyName, value)
				seen = { propertyName, value }
			end)

			context.changeProperty(folder, "Name", "Panel")
			expect(seen).toEqual({ "Name", "Panel" })
		end)
	end)
end
