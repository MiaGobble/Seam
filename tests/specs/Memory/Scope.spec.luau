return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Seam = context.Seam
	local Instance = context.Instance

	local Scope = Seam.Scope
	local Value = Seam.Value
	local Computed = Seam.Computed
	local New = Seam.New
	local Component = Seam.Component

	describe("Scope", function()
		it("constructs scoped values and destroys them with the scope", function()
			local destroyed = 0
			local scope = Scope({
				Value = Value,
				Computed = Computed,
				Track = function()
					return {
						Destroy = function()
							destroyed += 1
						end,
					}
				end,
			})

			local amount = scope:Value(2)
			local doubled = scope:Computed(function(use)
				return use(amount) + 1
			end)
			scope:Track()

			expect(doubled.Value).toBe(3)
			amount.Value = 5
			expect(doubled.Value).toBe(6)

			scope:Destroy()
			expect(destroyed).toBe(1)

			local warns = context.takeWarns()
			expect(#warns > 0).toBe(false)
			scope:Destroy()
			expect(context.takeWarns()[#context.takeWarns()]).toContain("already destroyed")
		end)

		it("passes the scope to plain functions and to New", function()
			local seen = nil
			local Widget = Component({
				Init = function(self, scope, properties)
					self.Scope = scope
					self.Text = properties.Text
				end,
				Construct = function(self)
					local folder = Instance.new("Folder")
					folder.Name = self.Text
					return folder
				end,
			})

			local scope = Scope({
				New = New,
				Mark = function(innerScope)
					seen = innerScope
				end,
			})

			scope:Mark()
			expect(seen).toBe(scope)

			local folder = scope:New(Widget, { Text = "Panel" })
			expect(folder.Name).toBe("Panel")

			local root = Instance.new("Folder")
			folder.Parent = root
			scope:Destroy()
			expect(folder.Parent).toBeNil()
		end)

		it("nests inner scopes and can forget an object before cleanup", function()
			local hits = 0
			local function marker()
				return function()
					hits += 1
				end
			end

			local scope = Scope({
				Marker = marker,
			})
			local inner = scope:InnerScope()
			local kept = marker()
			local removed = marker()

			inner:Marker()
			scope:AddObject(kept)
			scope:AddObject(removed)
			scope:RemoveObject(removed)
			inner:Destroy()
			expect(hits).toBe(1)

			scope:Destroy()
			expect(hits).toBe(2)
			removed()
			expect(hits).toBe(3)
		end)

		it("rejects objects that cannot be scoped", function()
			local scope = Scope({
				Children = Seam.Children,
				Batch = Seam.Batch,
			})

			expect(function()
				return scope.Children
			end).toThrow("not a valid scopable Seam object")

			expect(function()
				return scope.Batch
			end).toThrow("not a valid scopable Seam object")

			scope:Destroy()
			expect(scope.Value).toBeNil()
			expect(context.takeWarns()[1]).toContain("already destroyed")
		end)
	end)
end
