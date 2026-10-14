return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Seam = context.Seam
	local Instance = context.Instance

	local Attribute = Seam.Attribute
	local Value = Seam.Value

	describe("Attribute", function()
		it("sets a constant attribute and can restore the previous one", function()
			local folder = Instance.new("Folder")
			folder:SetAttribute("Role", "old")

			local restore = Attribute("Role")(folder, "admin")
			expect(folder:GetAttribute("Role")).toBe("admin")

			restore()
			expect(folder:GetAttribute("Role")).toBe("old")
		end)

		it("follows a state until the binding or instance is destroyed", function()
			local folder = Instance.new("Folder")
			local role = Value("admin")
			local binding = Attribute("Role")
			local restore = binding(folder, role)

			expect(folder:GetAttribute("Role")).toBe("admin")
			role.Value = "mod"
			expect(folder:GetAttribute("Role")).toBe("mod")

			restore()
			role.Value = "guest"
			expect(folder:GetAttribute("Role")).toBeNil()

			binding(folder, role)
			context.destroyInstance(folder)
			role.Value = "again"
			role:Destroy()
		end)
	end)
end
