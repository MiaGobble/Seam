return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Seam = context.Seam
	local Instance = context.Instance

	local Component = Seam.Component
	local IsComponent = Seam.IsComponent

	describe("Component", function()
		it("constructs an instance from Init and Construct", function()
			local seenScope = nil
			local Widget = Component({
				Init = function(self, scope, properties)
					seenScope = scope
					self.Text = properties.Text
				end,
				Construct = function(self, _scope, properties)
					local folder = Instance.new("Folder")
					folder.Name = self.Text
					folder:SetAttribute("Extra", properties.Extra)
					return folder
				end,
			})

			expect(IsComponent(Widget)).toBe(true)
			local scope = {}
			local folder = Widget(scope, { Text = "Title", Extra = 2 })
			expect(seenScope).toBe(scope)
			expect(folder.Name).toBe("Title")
			expect(folder:GetAttribute("Extra")).toBe(2)
			expect(Widget.Init).toBeTruthy()
		end)

		it("requires Init and Construct", function()
			expect(function()
				Component({
					Construct = function() end,
				})
			end).toThrow("Init()")

			expect(function()
				Component({
					Init = function() end,
				})
			end).toThrow("Construct()")
		end)
	end)
end
