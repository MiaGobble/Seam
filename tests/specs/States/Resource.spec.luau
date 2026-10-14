return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Seam = context.Seam

	local Resource = Seam.Resource

	describe("Resource", function()
		it("resolves a synchronous loader as Ready", function()
			local loads = 0
			local resource = Resource(function()
				loads += 1
				return "map"
			end)

			expect(resource.Status).toBe("Ready")
			expect(resource.Value).toBe("map")
			expect(resource.Error).toBeNil()
			expect(loads).toBe(1)

			local fires = 0
			resource.Changed:Connect(function()
				fires += 1
			end)
			resource:Refresh()
			expect(loads).toBe(2)
			expect(resource.Value).toBe("map")
			expect(fires).toBe(2)
			resource:Destroy()
		end)

		it("records loader errors", function()
			local resource = Resource(function()
				error("missing file")
			end)

			expect(resource.Status).toBe("Error")
			expect(tostring(resource.Error)).toContain("missing file")
			expect(resource.Value).toBeNil()
			resource:Destroy()
		end)

		it("ignores a loader that finishes after a newer refresh", function()
			local release = false
			local calls = 0
			local resource = Resource(function()
				calls += 1
				local id = calls
				while not release do
					context.task.wait()
				end

				return id
			end)

			expect(resource.Status).toBe("Loading")
			resource:Refresh()
			expect(calls).toBe(2)

			release = true
			for _ = 1, 10 do
				if resource.Status == "Ready" then
					break
				end

				context.task.wait()
			end

			expect(resource.Status).toBe("Ready")
			expect(resource.Value).toBe(2)
			resource:Destroy()
		end)

		it("accepts direct Value, Status, and Error writes", function()
			local resource = Resource(function()
				return 1
			end)

			resource.Status = "Idle"
			resource.Error = "held"
			expect(resource.Status).toBe("Idle")
			expect(resource.Error).toBe("held")

			resource.Value = 5
			expect(resource.Value).toBe(5)
			expect(resource.Status).toBe("Ready")
			expect(resource.Error).toBeNil()
			resource:Destroy()
		end)
	end)
end
