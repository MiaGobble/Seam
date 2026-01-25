-- Author: iGottic

local Destroyed = {}

-- Types
export type Destroyed = (Object : Instance, Callback : () -> nil) -> nil

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Symbol = require(Modules.Symbol)

-- Variables
local ClassSymbol = Symbol.new("Destroyed")

function Destroyed:__call(Object : Instance, Callback : () -> nil)
    Object.Destroying:Once(Callback)
end

function Destroyed:__index(Index : string)
    if Index == "__SEAM_INDEX" then
        return ClassSymbol
    elseif Index == "__SEAM_CAN_BE_SCOPED" then
        return false
    else
        return nil
    end
end

local Meta = setmetatable({}, Destroyed)

return Meta :: Destroyed