return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Seam = context.Seam
	local Instance = context.Instance

	local Children = Seam.Children
	local Value = Seam.Value
	local Computed = Seam.Computed

	describe("Children", function()
		it("parents a list or a single instance", function()
			local parent = Instance.new("Folder")
			local first = Instance.new("Part")
			local second = Instance.new("Part")

			local created = Children(parent, { first, second })
			expect(first.Parent).toBe(parent)
			expect(second.Parent).toBe(parent)
			expect(#created).toBe(2)

			local alone = Instance.new("Part")
			Children(parent, alone)
			expect(alone.Parent).toBe(parent)
		end)

		it("replaces computed children and cleans them up", function()
			local parent = Instance.new("Folder")
			local first = Instance.new("Part")
			local items = Value({ first })
			local children = Computed(function(use)
				return use(items)
			end)

			local handle = Children(parent, children)
			expect(first.Parent).toBe(parent)

			local second = Instance.new("Part")
			items.Value = { second }
			expect(second.Parent).toBe(parent)
			expect(first.Parent).toBeNil()

			handle.Destroy()
			local third = Instance.new("Part")
			items.Value = { third }
			expect(third.Parent).toBeNil()

			children:Destroy()
			items:Destroy()
		end)

		it("destroys active computed children when the parent is destroyed", function()
			local parent = Instance.new("Folder")
			local child = Instance.new("Part")
			local items = Value({ child })
			local children = Computed(function(use)
				return use(items)
			end)

			Children(parent, children)
			context.destroyInstance(parent)
			expect(child.Parent).toBeNil()

			children:Destroy()
			items:Destroy()
		end)

		it("rejects values that are not instances", function()
			local parent = Instance.new("Folder")

			expect(function()
				Children(parent, 1)
			end).toThrow("Invalid children type!")

			expect(function()
				Children(parent, { "child" })
			end).toThrow("Invalid child type!")
		end)
	end)
end
