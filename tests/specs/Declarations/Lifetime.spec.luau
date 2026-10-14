return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Seam = context.Seam
	local Instance = context.Instance

	local Lifetime = Seam.Lifetime

	describe("Lifetime", function()
		it("destroys the instance after the given delay", function()
			local root = Instance.new("Folder")
			local folder = Instance.new("Folder")
			folder.Parent = root

			Lifetime(folder, 0)
			expect(folder.Parent).toBe(root)

			context.task.wait()
			context.task.wait()
			expect(folder.Parent).toBeNil()
		end)
	end)
end
