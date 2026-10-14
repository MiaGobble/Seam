return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Instance = context.Instance
	local Value = context.Seam.Value

	local StateManager = context.requirePath({ "Modules", "StateManager" })

	describe("StateManager", function()
		it("copies a state onto a Seam object when Changed fires", function()
			local source = Value(1)
			local target = Value(0)
			local bucket = StateManager.AttachStateToObject(target, {
				Value = function()
					return source.Value
				end,
				PropertyName = "Value",
				Changed = source.Changed,
			})

			expect(target.Value).toBe(1)
			source.Value = 9
			expect(target.Value).toBe(9)

			bucket:Destroy()
			source.Value = 3
			expect(target.Value).toBe(9)

			source:Destroy()
			target:Destroy()
		end)

		it("updates an instance property from the heartbeat", function()
			local folder = Instance.new("Folder")
			local current = "Panel"
			local reads = 0
			local bucket = StateManager.AttachStateToObject(folder, {
				Value = function()
					reads += 1
					return current
				end,
				PropertyName = "Name",
			})

			expect(folder.Name).toBe("Panel")

			context.step(0)
			local readsAfterRepeat = reads
			expect(folder.Name).toBe("Panel")

			current = "Drawer"
			context.step(0)
			expect(folder.Name).toBe("Drawer")
			expect(reads > readsAfterRepeat).toBe(true)

			bucket:Destroy()
			current = "Ignored"
			context.step(0)
			expect(folder.Name).toBe("Drawer")

			context.task.wait()
			context.task.wait()
		end)

		it("warns and skips a value whose type does not match the property", function()
			local folder = Instance.new("Folder")
			folder.Name = "Folder"
			local bucket = StateManager.AttachStateToObject(folder, {
				Value = function()
					return 1
				end,
				PropertyName = "Name",
			})

			expect(folder.Name).toBe("Folder")
			expect(context.takeWarns()[1]).toContain("expected type")
			bucket:Destroy()
		end)

		it("rejects objects that cannot receive a state", function()
			expect(function()
				StateManager.AttachStateToObject({}, {
					Value = function()
						return 1
					end,
					PropertyName = "Value",
				})
			end).toThrow("Attempted to attach non-state")
		end)
	end)
end
