-- Author: iGottic

local EventSequence = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Symbol = require(Modules.Symbol)
local Trove = require(Modules.Trove)
local UpdateSignals = require(Modules.UpdateSignals)

-- Types extended
export type SequenceKeyframe = {number | () -> nil}

export type EventSequenceInstance = {
    Play : (EventSequenceInstance) -> nil,
    Stop : (EventSequenceInstance) -> nil,
    Pause : (EventSequenceInstance) -> nil,
    Resume : (EventSequenceInstance) -> nil,
    Looped : boolean,
}

export type EventSequence = ({SequenceKeyframe}) -> EventSequenceInstance

-- Variables
local ClassSymbol = Symbol.new("EventSequence")

function EventSequence:__call(SequenceKeyframes : {SequenceKeyframe}) : EventSequenceInstance
    local CurrentTime = 0
    local PlayedIndexes = {}
    local EventSequenceInstance : EventSequenceInstance = {}
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

                if CurrentTime >= Keyframe[1] then
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

function EventSequence:__index(Index : string)
    if Index == "__SEAM_OBJECT" then
        return ClassSymbol
    elseif Index == "__SEAM_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

local Meta = setmetatable({}, EventSequence)

return Meta :: EventSequence