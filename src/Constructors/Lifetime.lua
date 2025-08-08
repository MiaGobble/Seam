-- Author: iGottic

--[=[
    @class Lifetime
    @since 0.0.3
]=]

local Lifetime = {}

-- Types
export type Lifetime = (Object : Instance, CleanupTime : number) -> nil

-- Services
local DebrisService = game:GetService("Debris")

--[=[
    Sets a lifetime for an object
]=]

function Lifetime:__call(Object : Instance, CleanupTime : number)
    DebrisService:AddItem(Object, CleanupTime)
end

function Lifetime:__index(Index : string)
    if Index == "__SEAM_INDEX" then
        return "Lifetime"
    elseif Index == "__SEAM_CAN_BE_SCOPED" then
        return false
    else
        return nil
    end
end

local Meta = setmetatable({}, Lifetime)

return Meta :: Lifetime