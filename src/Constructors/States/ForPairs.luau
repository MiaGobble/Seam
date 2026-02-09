-- Author: iGottic

local ForPairs = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Symbol = require(Modules.Symbol)
local Computed = require(script.Parent.Computed)
local Value = require(script.Parent.Value)

-- Variables
local ClassSymbol = Symbol.new("ForPairs")

-- Types Extended
export type ForPairsInstance<T> = {} & Types.BaseState<T>
export type ForPairsConstructor<T> = (TrackedValue : Value.ValueInstance<any>, Callback : ((Value : Value.ValueInstance<T>) -> any) -> any?) -> ForPairsInstance<T>

function ForPairs:__call(TrackedValue : Value.ValueInstance<any>, Callback : ((Value : Value.ValueInstance<any>) -> any) -> any?)
    local LastValues = {}
    local OutputtedValues = {}

    -- ForPairs is literally just Computed behind the scenes, with the exception that it checks for key differences
    local ActiveComputation = Computed(function(Use)
        local ThisTable = Use(TrackedValue)
        local ThisOuput = {}

        if typeof(ThisTable) ~= "table" then
            error("ForPairs needs a table value to work\n" .. debug.traceback())
        end

        for Index, NewValue in ThisTable do
            if LastValues[Index] ~= NewValue then
                LastValues[Index] = NewValue
                ThisOuput[Index] = Callback(Use, Index, NewValue)
            end
        end

        for Index, LastValue in LastValues do
            if ThisTable[Index] ~= LastValue then
                LastValues[Index] = ThisTable[Index]
                
                if ThisTable[Index] then
                    ThisOuput[Index] = Callback(Use, Index, ThisTable[Index])
                end
            elseif not ThisOuput[Index] then
                ThisOuput[Index] = OutputtedValues[Index]
            end
        end

        OutputtedValues = ThisOuput

        return ThisOuput
    end)

    return ActiveComputation :: ForPairsInstance<any>
end

function ForPairs:__index(Key : string)
    if Key == "__SEAM_INDEX" then
        return ClassSymbol
    elseif Key == "__SEAM_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

local Meta = setmetatable({}, ForPairs)

return Meta :: ForPairsConstructor<any>