local ForPairs = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Symbol = require(Modules.Symbol)
local CreateDeepTraceback = require(Modules.CreateDeepTraceback)
local Computed = require(script.Parent.Computed)

ForPairs.__SEAM_INDEX = Symbol.new("ForPairs")
ForPairs.__SEAM_CAN_BE_SCOPED = true

function ForPairs.__CALLBACK(_ : Types.ConstructorCompiled, trackedValue : Types.ValueInstance<any>, callback : ((value : Types.ValueInstance<any>) -> any) -> any?)
	local LastValues = {}
	local OutputtedValues = {}

	-- ForPairs is literally just Computed behind the scenes, with the exception that it checks for key differences
	local ActiveComputation = Computed(function(use)
		local ThisTable = use(trackedValue)
		local ThisOuput = {}

		if typeof(ThisTable) ~= "table" then
			error(`ForPairs needs a table value to work\n{CreateDeepTraceback()}`)
		end

		for index, newValue in ThisTable do
			if LastValues[index] ~= newValue then
				LastValues[index] = newValue
				ThisOuput[index] = callback(use, index, newValue)
			end
		end

		for index, lastValue in LastValues do
			if ThisTable[index] ~= lastValue then
				LastValues[index] = ThisTable[index]

				if ThisTable[index] then
					ThisOuput[index] = callback(use, index, ThisTable[index])
				end
			elseif not ThisOuput[index] then
				ThisOuput[index] = OutputtedValues[index]
			end
		end

		OutputtedValues = ThisOuput

		return ThisOuput
	end)

	return ActiveComputation :: Types.ForPairsInstance<any>
end

return Compiler.CompileConstructor(ForPairs) :: Types.ForPairsConstructor<any>
