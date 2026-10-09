-- Author: iGottic

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Symbol = require(Modules.Symbol)
local Trove = require(Modules.Trove)
local UpdateSignals = require(Modules.UpdateSignals)

-- Class
local EventSequence : Types.ConstructorDecompiled = {}

EventSequence.__SEAM_OBJECT = Symbol.new("EventSequence")
EventSequence.__SEAM_CAN_BE_SCOPED = true

function EventSequence.__CALLBACK(_: Types.ConstructorCompiled, SequenceKeyframes : {Types.SequenceKeyframe}) : Types.EventSequenceInstance
    local CurrentTime = 0
    local PlayedIndexes = {}
    local EventSequenceInstance : Types.EventSequenceInstance = {} :: Types.EventSequenceInstance
    local PlayingTrove = nil
    local CurrentlyPaused = false

    for Index, Keyframe in SequenceKeyframes do
        if typeof(Index) ~= "number" then
            error("Attmped to pass dictionary for sequence keyframes")
        end

        if typeof(Keyframe[1]) ~= "number" then
            error("EventSequenceKeypoint needs a time")
        end

        if typeof(Keyframe[2]) ~= "function" then
            error("EventSequenceKeypoint needs callback")
        end
    end

    EventSequenceInstance.Looped = false
    EventSequenceInstance.LoopDelayTime = 0

    function EventSequenceInstance.Play()
        if PlayingTrove then
            EventSequenceInstance.Stop()
        end

        CurrentlyPaused = false
        PlayingTrove = Trove.new()

        PlayingTrove:Add(UpdateSignals.OnFrameUpdate:Connect(function(Delta : number)
            if CurrentlyPaused then
                return
            end

            CurrentTime += Delta

            for Index, Keyframe in SequenceKeyframes do
                if PlayedIndexes[Index] then
                    continue
                end

                local PreviousTotalTime = 0

                if Index > 1 then
                    for PreviousIndex = 1, Index - 1 do
                        PreviousTotalTime += SequenceKeyframes[PreviousIndex][1]
                    end
                end

                if CurrentTime >= Keyframe[1] + PreviousTotalTime then
                    PlayedIndexes[Index] = true
                    task.spawn(Keyframe[2])
                end
            end

            if #SequenceKeyframes == #PlayedIndexes then
                if EventSequenceInstance.Looped then
                    CurrentTime = -EventSequenceInstance.LoopDelayTime
                    table.clear(PlayedIndexes)
                else
                    PlayingTrove:Destroy()
                end
            end
        end))

        PlayingTrove:Add(function()
            CurrentTime = 0
            PlayingTrove = nil
            CurrentlyPaused = false
            PlayedIndexes = {}
        end)
    end

    function EventSequenceInstance.Stop()
        if not PlayingTrove then
            return
        end

        PlayingTrove:Destroy()
    end

    function EventSequenceInstance.Pause()
        if not PlayingTrove then
            return
        end

        CurrentlyPaused = true
    end

    function EventSequenceInstance.Resume()
        if not PlayingTrove then
            return
        end

        CurrentlyPaused = false
    end

    return EventSequenceInstance
end

return Compiler.CompileConstructor(EventSequence) :: Types.EventSequence