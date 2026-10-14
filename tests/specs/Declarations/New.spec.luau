return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Seam = context.Seam
	local Instance = context.Instance

	local New = Seam.New
	local Children = Seam.Children
	local Value = Seam.Value
	local Attribute = Seam.Attribute
	local Tags = Seam.Tags
	local Component = Seam.Component

	describe("New", function()
		it("constructs an instance and assigns properties", function()
			local name = Value("Panel")
			local child = Instance.new("Part")
			local folder = New("Folder", {
				Name = name,
				[Children] = { child },
				[Attribute("Role")] = "admin",
				[Tags] = { "Widget" },
			})

			expect(folder.ClassName).toBe("Folder")
			expect(folder.Name).toBe("Panel")
			expect(child.Parent).toBe(folder)
			expect(folder:GetAttribute("Role")).toBe("admin")
			expect(folder:HasTag("Widget")).toBe(true)

			name.Value = "Drawer"
			context.step(0)
			expect(folder.Name).toBe("Drawer")

			name:Destroy()
		end)

		it("parents numeric children and hydrates an existing instance", function()
			local child = Instance.new("Folder")
			local parent = New("Folder", { child })
			expect(child.Parent).toBe(parent)

			local existing = Instance.new("Folder")
			local hydrated = New(existing, { Name = "Hydrated" })
			expect(hydrated).toBe(existing)
			expect(hydrated.Name).toBe("Hydrated")
		end)

		it("constructs custom components", function()
			local Widget = Component({
				Init = function(self, _scope, properties)
					self.Text = properties.Text
				end,
				Construct = function(self)
					local folder = Instance.new("Folder")
					folder.Name = self.Text
					return folder
				end,
			})

			local folder = New(Widget, { Text = "Hello" })
			expect(folder.Name).toBe("Hello")
		end)

		it("rejects invalid classes, indexes, and property values", function()
			expect(function()
				New(1, {})
			end).toThrow("Invalid class type!")

			expect(function()
				New("Folder", { Name = {} })
			end).toThrow("Invalid property type!")

			expect(function()
				New("Folder", { [{}] = 1 })
			end).toThrow("invalid index type")
		end)

		it("warns when a state type does not match the property", function()
			local amount = Value(1)
			New("Folder", { Name = amount })

			expect(context.takeWarns()[1]).toContain("expected type")
			amount:Destroy()
		end)
	end)
end
