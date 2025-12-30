-- Author: iGottic

--[=[
    @class MakeSymbol
    @since 0.3.3
]=]

local MakeSymbol = {}

-- Imports
local Symbol = require(script.Parent.Parent.Parent.Modules.Symbol)

-- Types extended
export type MakeSymbol = (Value : string) -> Symbol.Symbol

function MakeSymbol:__call(Value : string) : Symbol.Symbol
    if typeof(Value) ~= "string" then
        error("Symbol must be created with string, other types are not accepted. Got type: " .. typeof(Value))
    end

    return Symbol.new(Value)
end

function MakeSymbol:__index(Key : string)
    if Key == "__SEAM_CAN_BE_SCOPED" then
        return false
    end

    return nil
end

local Meta = setmetatable({}, MakeSymbol)

return Meta :: MakeSymbol