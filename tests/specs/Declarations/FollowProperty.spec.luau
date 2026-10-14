return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Seam = context.Seam
	local Instance = context.Instance

	local FollowProperty = Seam.FollowProperty
	local Value = Seam.Value

	describe("FollowProperty", function()
		it("writes property changes into a state", function()
			local folder = Instance.new("Folder")
			local name = Value(folder.Name)
			local binding = FollowProperty("Name")
			local disconnect = binding(folder, name)

			context.changeProperty(folder, "Name", "Panel")
			expect(name.Value).toBe("Panel")

			disconnect()
			context.changeProperty(folder, "Name", "Later")
			expect(name.Value).toBe("Panel")
			name:Destroy()
		end)

		it("stops every object when the binding is destroyed", function()
			local folder = Instance.new("Folder")
			local name = Value("Folder")
			local binding = FollowProperty("Name")
			binding(folder, name)
			binding:Destroy()

			context.changeProperty(folder, "Name", "Gone")
			expect(name.Value).toBe("Folder")
			name:Destroy()
		end)
	end)
end
