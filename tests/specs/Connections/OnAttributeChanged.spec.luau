return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Seam = context.Seam
	local Instance = context.Instance

	local OnAttributeChanged = Seam.OnAttributeChanged

	describe("OnAttributeChanged", function()
		it("runs while the attribute changes and stops after destroy", function()
			local folder = Instance.new("Folder")
			local seen = {}
			local binding = OnAttributeChanged("Role")
			binding(folder, function()
				table.insert(seen, folder:GetAttribute("Role"))
			end)

			context.setAttribute(folder, "Role", "admin")
			expect(seen).toEqual({ "admin" })

			binding:Destroy()
			context.setAttribute(folder, "Role", "guest")
			expect(seen).toEqual({ "admin" })
		end)

		it("replaces the previous callback for the same instance", function()
			local folder = Instance.new("Folder")
			local seen = {}
			local binding = OnAttributeChanged("Role")

			binding(folder, function()
				table.insert(seen, "first")
			end)
			binding(folder, function()
				table.insert(seen, "second")
			end)

			context.setAttribute(folder, "Role", "admin")
			expect(seen).toEqual({ "second" })
			binding:Destroy()
		end)
	end)
end
