return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Instance = context.Instance

	local Bucket = context.requirePath({ "Modules", "Bucket" })

	describe("Bucket", function()
		it("cleans functions, instances, threads, and named methods", function()
			local bucket = Bucket.new()
			local hits = 0
			local root = Instance.new("Folder")
			local child = Instance.new("Part")
			child.Parent = root

			bucket:Add(function()
				hits += 1
			end)
			bucket:Add({
				wipe = function()
					hits += 1
				end,
			}, "wipe")
			bucket:Add(child)

			local thread = context.task.spawn(function()
				context.task.wait(30)
			end)
			bucket:Add(thread)
			bucket:Destroy()

			expect(hits).toBe(2)
			expect(child.Parent).toBeNil()
			expect(coroutine.status(thread)).toBe("dead")
			bucket:Destroy()
		end)

		it("removes objects, extends into a child bucket, and wraps destroy", function()
			local bucket = Bucket.new()
			local hits = 0
			local removed = function()
				hits += 1
			end

			bucket:Add(removed)
			bucket:Remove(removed)

			local child = bucket:Extend()
			child:Add(function()
				hits += 1
			end)

			bucket:GetWrappedDestroy()()
			expect(hits).toBe(1)
			removed()
			expect(hits).toBe(2)
		end)

		it("rejects new work while cleaning and validates promises", function()
			local bucket = Bucket.new()
			local message = nil
			bucket:Add(function()
				local ok, err = pcall(function()
					bucket:Add(function() end)
				end)
				if not ok then
					message = tostring(err)
				end
			end)
			bucket:Destroy()
			expect(message).toContain("during cleanup")

			local fresh = Bucket.new()
			expect(function()
				fresh:Add({})
			end).toThrow("No cleanup function")
			expect(function()
				fresh:AddPromise({})
			end).toThrow("promise")

			local cancelled = false
			local settled = {
				getStatus = function()
					return "Resolved"
				end,
				finally = function() end,
				cancel = function()
					cancelled = true
				end,
			}
			fresh:AddPromise(settled)

			local finallyCallback = nil
			local started = {
				getStatus = function()
					return "Started"
				end,
				finally = function(_self, callback)
					finallyCallback = callback
				end,
				cancel = function()
					cancelled = true
				end,
			}
			fresh:AddPromise(started)
			finallyCallback()
			fresh:Destroy()
			expect(cancelled).toBe(false)

			local live = Bucket.new()
			local didCancel = false
			live:AddPromise({
				getStatus = function()
					return "Started"
				end,
				finally = function() end,
				cancel = function()
					didCancel = true
				end,
			})
			live:Destroy()
			expect(didCancel).toBe(true)
		end)
	end)
end
