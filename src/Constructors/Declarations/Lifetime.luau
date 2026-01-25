-- Author: iGottic

local Lifetime = {}

-- Types
export type Lifetime = (Object : Instance, CleanupTime : number) -> nil

-- Services
local DebrisService = game:GetService("Debris")

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Symbol = require(Modules.Symbol)

-- Variables
local ClassSymbol = Symbol.new("Lifetime")

function Lifetime:__call(Object : Instance, CleanupTime : number)
    -- This is really simple, but the reason I use Debris service
    -- over a task.delay() is because it guarantees error-free cleanup

    DebrisService:AddItem(Object, CleanupTime)
end

function Lifetime:__index(Index : string)
    if Index == "__SEAM_INDEX" then
        return ClassSymbol
    elseif Index == "__SEAM_CAN_BE_SCOPED" then
        return false
    else
        return nil
    end
end

local Meta = setmetatable({}, Lifetime)

return Meta :: Lifetime