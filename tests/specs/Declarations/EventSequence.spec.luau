return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Seam = context.Seam

	local EventSequence = Seam.EventSequence

	describe("EventSequence", function()
		it("plays keyframes in order and can pause, resume, restart, and stop", function()
			local hits = {}
			local sequence = EventSequence({
				{
					0.2,
					function()
						table.insert(hits, "first")
					end,
				},
				{
					0.2,
					function()
						table.insert(hits, "second")
					end,
				},
			})

			sequence:Pause()
			sequence:Resume()
			sequence:Stop()
			expect(hits).toEqual({})

			sequence:Play()
			sequence:Pause()
			context.step(1)
			expect(hits).toEqual({})

			sequence:Resume()
			context.step(0.2)
			expect(hits).toEqual({ "first" })
			context.step(0.2)
			expect(hits).toEqual({ "first", "second" })

			sequence:Play()
			context.step(0.4)
			expect(hits).toEqual({ "first", "second", "first", "second" })

			local count = #hits
			sequence:Stop()
			context.step(1)
			expect(#hits).toBe(count)
		end)

		it("loops after the delay", function()
			local hits = 0
			local sequence = EventSequence({
				{
					0,
					function()
						hits += 1
					end,
				},
			})
			sequence.Looped = true
			sequence.LoopDelayTime = 0.5

			sequence:Play()
			context.step(0)
			expect(hits).toBe(1)

			context.step(0.4)
			expect(hits).toBe(1)

			context.step(0.2)
			expect(hits).toBe(2)
			sequence:Stop()
		end)

		it("rejects malformed keyframes", function()
			expect(function()
				EventSequence({
					now = { 0, function() end },
				})
			end).toThrow("dictionary")

			expect(function()
				EventSequence({
					{ "0", function() end },
				})
			end).toThrow("needs a time")

			expect(function()
				EventSequence({
					{ 0, "go" },
				})
			end).toThrow("needs callback")
		end)
	end)
end
