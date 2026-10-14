return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Seam = context.Seam
	local Instance = context.Instance

	local OnEvent = Seam.OnEvent

	describe("OnEvent", function()
		it("connects a callback and replaces an older connection", function()
			local button = Instance.new("TextButton")
			local hits = {}
			local binding = OnEvent("MouseButton1Click")

			binding(button, function(input)
				table.insert(hits, input)
			end)
			local connection = binding(button, function(input)
				table.insert(hits, `second:{input}`)
			end)

			context.fireEvent(button, "MouseButton1Click", "click")
			expect(hits).toEqual({ "second:click" })

			connection:Disconnect()
			context.fireEvent(button, "MouseButton1Click", "again")
			expect(hits).toEqual({ "second:click" })

			binding(button, function()
				table.insert(hits, "third")
			end)
			binding:Destroy()
			context.fireEvent(button, "MouseButton1Click", "after")
			expect(hits).toEqual({ "second:click" })
		end)
	end)
end
