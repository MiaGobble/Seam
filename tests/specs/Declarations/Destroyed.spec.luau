return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Seam = context.Seam
	local Instance = context.Instance

	local Destroyed = Seam.Destroyed

	describe("Destroyed", function()
		it("runs the callback once when the instance is destroyed", function()
			local folder = Instance.new("Folder")
			local hits = 0
			Destroyed(folder, function()
				hits += 1
			end)

			context.destroyInstance(folder)
			expect(hits).toBe(1)
		end)
	end)
end
