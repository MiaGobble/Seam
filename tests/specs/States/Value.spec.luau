return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Seam = context.Seam

	local Value = Seam.Value

	describe("Value", function()
		it("stores the initial value and notifies listeners when it changes", function()
			local state = Value(1)
			local propertyName = nil
			local newValue = nil
			local fires = 0

			state.Changed:Connect(function(property, value)
				fires += 1
				propertyName = property
				newValue = value
			end)

			expect(state.Value).toBe(1)
			state.Value = 1
			expect(fires).toBe(0)

			state.Value = 4
			expect(state.Value).toBe(4)
			expect(fires).toBe(1)
			expect(propertyName).toBe("Value")
			expect(newValue).toBe(4)

			state.Value = nil
			expect(state.Value).toBeNil()
			state:Destroy()
		end)

		it("rejects a value of a different type", function()
			local state = Value(1)

			expect(function()
				state.Value = "nope"
			end).toThrow("Invalid value type!")

			expect(state.Value).toBe(1)
			state:Destroy()
		end)

		it("learns a type from the first non-nil assignment", function()
			local state = Value(nil)
			state.Value = "ready"
			expect(state.Value).toBe("ready")

			expect(function()
				state.Value = 1
			end).toThrow("Invalid value type!")

			state:Destroy()
		end)

		it("clones table values and updates them immutably", function()
			local original = {
				counts = { a = 1 },
				items = { "red" },
			}
			local state = Value(original)

			original.counts.a = 9
			expect(state.Value.counts.a).toBe(9)

			local beforeInsert = state.Value
			state:TableInsert("blue", { "items" })
			expect(#beforeInsert.items).toBe(1)
			expect(state.Value.items[2]).toBe("blue")

			local beforeSet = state.Value
			state:TableSet(2, { "counts", "a" })
			expect(beforeSet.counts.a).toBe(9)
			expect(state.Value.counts.a).toBe(2)

			local beforeRemove = state.Value
			state:TableRemove(1, { "items" })
			expect(beforeRemove.items[1]).toBe("red")
			expect(state.Value.items[1]).toBe("blue")

			state:TableSet({ reset = true })
			expect(state.Value.reset).toBe(true)
			state:Destroy()
		end)

		it("rejects table edits that do not point at a table", function()
			local state = Value(1)
			expect(function()
				state:TableInsert("x")
			end).toThrow("can only be used when Value is a table")

			local tableState = Value({ a = 1 })
			expect(function()
				tableState:TableSet(2, "a")
			end).toThrow("Path must be a table of keys")
			expect(function()
				tableState:TableSet(2, { "missing", "child" })
			end).toThrow("Path points to a non-table value")
			expect(function()
				tableState:TableRemove("first")
			end).toThrow("RemovedValueIndex must be a number")

			state:Destroy()
			tableState:Destroy()
		end)
	end)
end
