local EventSequence = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Symbol = require(Modules.Symbol)
local Bucket = require(Modules.Bucket)
local UpdateSignals = require(Modules.UpdateSignals)

EventSequence.__SEAM_OBJECT = Symbol.new("EventSequence")
EventSequence.__SEAM_CAN_BE_SCOPED = true

function EventSequence.__CALLBACK(_ : Types.ConstructorCompiled, sequenceKeyframes : {Types.SequenceKeyframe}) : Types.EventSequenceInstance
	local CurrentTime = 0
	local PlayedIndexes = {}
	local EventSequenceInstance : Types.EventSequenceInstance = {} :: Types.EventSequenceInstance
	local PlayingBucket = nil
	local CurrentlyPaused = false

	for index, keyframe in sequenceKeyframes do
		if typeof(index) ~= "number" then
			error("Attmped to pass dictionary for sequence keyframes")
		end

		if typeof(keyframe[1]) ~= "number" then
			error("EventSequenceKeypoint needs a time")
		end

		if typeof(keyframe[2]) ~= "function" then
			error("EventSequenceKeypoint needs callback")
		end
	end

	EventSequenceInstance.Looped = false
	EventSequenceInstance.LoopDelayTime = 0

	function EventSequenceInstance.Play()
		if PlayingBucket then
			EventSequenceInstance.Stop()
		end

		CurrentlyPaused = false
		PlayingBucket = Bucket.new()

		PlayingBucket:Add(UpdateSignals.OnFrameUpdate:Connect(function(delta : number)
			if CurrentlyPaused then
				return
			end

			CurrentTime += delta

			for index, keyframe in sequenceKeyframes do
				if PlayedIndexes[index] then
					continue
				end

				local PreviousTotalTime = 0

				if index > 1 then
					for previousIndex = 1, index - 1 do
						PreviousTotalTime += sequenceKeyframes[previousIndex][1]
					end
				end

				if CurrentTime >= keyframe[1] + PreviousTotalTime then
					PlayedIndexes[index] = true
					task.spawn(keyframe[2])
				end
			end

			if #sequenceKeyframes == #PlayedIndexes then
				if EventSequenceInstance.Looped then
					CurrentTime = -EventSequenceInstance.LoopDelayTime
					table.clear(PlayedIndexes)
				else
					PlayingBucket:Destroy()
				end
			end
		end))

		PlayingBucket:Add(function()
			CurrentTime = 0
			PlayingBucket = nil
			CurrentlyPaused = false
			PlayedIndexes = {}
		end)
	end

	function EventSequenceInstance.Stop()
		if not PlayingBucket then
			return
		end

		PlayingBucket:Destroy()
	end

	function EventSequenceInstance.Pause()
		if not PlayingBucket then
			return
		end

		CurrentlyPaused = true
	end

	function EventSequenceInstance.Resume()
		if not PlayingBucket then
			return
		end

		CurrentlyPaused = false
	end

	return EventSequenceInstance
end

return Compiler.CompileConstructor(EventSequence) :: Types.EventSequence
