-- Author: iGottic

--[=[
    @class MakeSignal
    @since 0.3.3
]=]

local MakeSignal = {}

-- Imports
local Signal = require(script.Parent.Parent.Parent.Modules.Signal)

-- Types extended
export type MakeSignal = () -> Signal.Signal<>

function MakeSignal:__call() : Signal.Signal<>
    return Signal.new()
end

function MakeSignal:__index(Key : string)
    if Key == "__SEAM_CAN_BE_SCOPED" then
        return false
    end

    return nil
end

local Meta = setmetatable({}, MakeSignal)

return Meta :: MakeSignal