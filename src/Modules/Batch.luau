-- Author: iGottic

local Batch = {}

-- Types
type BatchedArguments = {
    n: number,
    [number]: any,
}

export type Batch = ((Callback: (...any) -> ...any, ...any) -> ...any)

-- Variables
local ActiveDepth = 0
local PendingSignals: {[any]: BatchedArguments} = {}
local PendingOrder: {any} = {}

local function FlushPendingSignals()
    for _, ChangedSignal in PendingOrder do
        local PackedArguments = PendingSignals[ChangedSignal]

        if PackedArguments ~= nil then
            ChangedSignal:Fire(table.unpack(PackedArguments, 1, PackedArguments.n))
        end

        PendingSignals[ChangedSignal] = nil
    end

    table.clear(PendingOrder)
end

function Batch.Begin()
    ActiveDepth += 1
end

function Batch.End()
    if ActiveDepth <= 0 then
        error("Seam.Batch.End() called without a matching Begin()")
    end

    ActiveDepth -= 1

    if ActiveDepth == 0 then
        FlushPendingSignals()
    end
end

function Batch.Fire(ChangedSignal: any, ...: any)
    if ActiveDepth <= 0 then
        ChangedSignal:Fire(...)
        return
    end

    if PendingSignals[ChangedSignal] == nil then
        table.insert(PendingOrder, ChangedSignal)
    end

    PendingSignals[ChangedSignal] = table.pack(...)
end

function Batch:__call(Callback: (...any) -> ...any, ...: any)
    Batch.Begin()

    local Results = table.pack(pcall(Callback, ...))

    Batch.End()

    if not Results[1] then
        error(Results[2], 2)
    end

    return table.unpack(Results, 2, Results.n)
end

function Batch:__index(Key: string)
    if Key == "__SEAM_CAN_BE_SCOPED" then
        return false
    end

    return rawget(Batch, Key)
end

local Meta = setmetatable({}, Batch)

return Meta :: Batch