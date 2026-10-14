local Batch = {}

-- Types
type BatchedArguments = {
	n : number,
	[number] : any,
}

export type Batch = ((callback : (...any) -> ...any, ...any) -> ...any)

-- Variables
local ActiveDepth = 0
local PendingSignals : {[any] : BatchedArguments} = {}
local PendingOrder : {any} = {}

local function FlushPendingSignals()
	for _, changedSignal in PendingOrder do
		local PackedArguments = PendingSignals[changedSignal]

		if PackedArguments ~= nil then
			changedSignal:Fire(table.unpack(PackedArguments, 1, PackedArguments.n))
		end

		PendingSignals[changedSignal] = nil
	end

	table.clear(PendingOrder)
end

-- Beginning a batch does nothing but mark that it's opened
function Batch.Begin()
	ActiveDepth += 1
end

-- Ending a batch closes it. If it's the top batch scope, fire everything.
function Batch.End()
	if ActiveDepth <= 0 then
		error("Seam.Batch.End() called without a matching Begin()")
	end

	ActiveDepth -= 1

	if ActiveDepth == 0 then
		FlushPendingSignals()
	end
end

-- Instead of direcly firing changed signals in Seam, we do it through batch.
-- If there is no active batch, then the signal fires normally.
-- Otherwise, it adds it to pending signals.
function Batch.Fire(changedSignal : any, ... : any)
	if ActiveDepth <= 0 then
		changedSignal:Fire(...)
		return
	end

	if PendingSignals[changedSignal] == nil then
		table.insert(PendingOrder, changedSignal)
	end

	PendingSignals[changedSignal] = table.pack(...)
end

function Batch:__call(callback : (...any) -> ...any, ... : any)
	Batch.Begin()

	local Results = table.pack(pcall(callback, ...))

	Batch.End()

	if not Results[1] then
		error(Results[2], 2)
	end

	return table.unpack(Results, 2, Results.n)
end

function Batch:__index(key : string)
	if key == "__SEAM_CAN_BE_SCOPED" then
		return false
	end

	return rawget(Batch, key)
end

local Meta = setmetatable({}, Batch)

return Meta :: Batch
