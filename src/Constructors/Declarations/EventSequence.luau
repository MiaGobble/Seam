-- Author: iGottic

--[=[
    @class EventSequence
    @since 0.3.4
]=]

local EventSequence = {}

-- Services
local RunService = game:GetService("RunService")

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Symbol = require(Modules.Symbol)
local Trove = require(Modules.Trove)
local Value = require(script.Parent.Parent.States.Value)

-- Types extended
export type SequenceKeyframe = {
    Time : number,
    ValueSource : Value.ValueInstance<any>?,
    NewValue : any?,
    Callback : () -> nil?,
}

export type EventSequenceInstance = {
    Play : (EventSequenceInstance) -> nil,
    Stop : (EventSequenceInstance) -> nil,
    Pause : (EventSequenceInstance) -> nil,
    Resume : (EventSequenceInstance) -> nil,
}

export type EventSequence = ({SequenceKeyframe}) -> EventSequenceInstance

-- Variables
local ClassSymbol = Symbol.new("EventSequence")

--[=[
    Adds tags to an instance
]=]

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

        if not Keyframe.Time then
            error(`No keyframe time provided for index: {Index}`)
        end

        if Keyframe.ValueSource and Keyframe.NewValue == nil then
            error(`NewValue was not provided in response to ValueSource for index: {Index}`)
        end

        if Keyframe.NewValue ~= nil and not Keyframe.ValueSource then
            error(`ValueSource not provided for NewValue on index: {Index}`)
        end

        if not Keyframe.ValueSource and not Keyframe.Callback and Keyframe.NewValue == nil then
            error(`No event data provided for index: {Index}`)
        end
    end

    function EventSequenceInstance.Play()
        if PlayingTrove then
            EventSequenceInstance.Stop()
        end

        CurrentlyPaused = false
        PlayingTrove = Trove.new()

        PlayingTrove:Add(RunService.RenderStepped:Connect(function(Delta : number)
            if CurrentlyPaused then
                return
            end

            CurrentTime += Delta

            for Index, Keyframe in SequenceKeyframes do
                if PlayedIndexes[Index] then
                    continue
                end

                if CurrentTime >= Keyframe.Time then
                    PlayedIndexes[Index] = true

                    if Keyframe.ValueSource then
                        Keyframe.ValueSource.Value = Keyframe.NewValue
                    end

                    if Keyframe.Callback then
                        task.spawn(Keyframe.Callback)
                    end
                end
            end

            if #SequenceKeyframes == #PlayedIndexes then
                PlayingTrove:Destroy()
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