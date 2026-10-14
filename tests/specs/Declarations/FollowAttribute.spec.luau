return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Seam = context.Seam
	local Instance = context.Instance

	local FollowAttribute = Seam.FollowAttribute
	local Value = Seam.Value

	describe("FollowAttribute", function()
		it("writes attribute changes into a state", function()
			local folder = Instance.new("Folder")
			local role = Value(nil)
			local disconnect = FollowAttribute("Role")(folder, role)

			context.setAttribute(folder, "Role", "admin")
			expect(role.Value).toBe("admin")

			disconnect()
			context.setAttribute(folder, "Role", "guest")
			expect(role.Value).toBe("admin")
			role:Destroy()
		end)

		it("disconnects when the instance is destroying", function()
			local folder = Instance.new("Folder")
			local role = Value("old")
			FollowAttribute("Role")(folder, role)

			context.fireEvent(folder, "Destroying")
			context.setAttribute(folder, "Role", "guest")
			expect(role.Value).toBe("old")
			role:Destroy()
		end)
	end)
end
