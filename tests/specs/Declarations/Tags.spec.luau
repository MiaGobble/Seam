return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Seam = context.Seam
	local Instance = context.Instance

	local Tags = Seam.Tags

	describe("Tags", function()
		it("adds tags and removes them from the returned cleanup", function()
			local folder = Instance.new("Folder")
			local removeTags = Tags(folder, { "Primary", "Visible" })

			expect(folder:HasTag("Primary")).toBe(true)
			expect(folder:HasTag("Visible")).toBe(true)

			removeTags()
			expect(folder:HasTag("Primary")).toBe(false)
			expect(folder:HasTag("Visible")).toBe(false)
		end)
	end)
end
