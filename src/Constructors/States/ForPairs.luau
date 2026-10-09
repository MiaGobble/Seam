-- Author: iGottic

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Symbol = require(Modules.Symbol)
local CreateDeepTraceback = require(Modules.CreateDeepTraceback)
local Computed = require(script.Parent.Computed)

-- Class
local ForPairs : Types.ConstructorDecompiled = {}

ForPairs.__SEAM_INDEX = Symbol.new("ForPairs")
ForPairs.__SEAM_CAN_BE_SCOPED = true

function ForPairs.__CALLBACK(_: Types.ConstructorCompiled, TrackedValue : Types.ValueInstance<any>, Callback : ((Value : Types.ValueInstance<any>) -> any) -> any?)
    local LastValues = {}
    local OutputtedValues = {}

    -- ForPairs is literally just Computed behind the scenes, with the exception that it checks for key differences
    local ActiveComputation = Computed(function(Use)
        local ThisTable = Use(TrackedValue)
        local ThisOuput = {}

        if typeof(ThisTable) ~= "table" then
            error("ForPairs needs a table value to work\n" .. CreateDeepTraceback())
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

    return ActiveComputation :: Types.ForPairsInstance<any>
end

return Compiler.CompileConstructor(ForPairs) :: Types.ForPairsConstructor<any>
