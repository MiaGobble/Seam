-- Author: iGottic

--[=[
    @class Value
    @since 0.0.1
]=]

local Value = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local StateManager = require(Modules.StateManager)
local Janitor = require(Modules.Janitor)
local Signal = require(Modules.Signal)
local Types = require(Modules.Types)
local IsValueChanged = require(Modules.IsValueChanged)
local Symbol = require(Modules.Symbol)

-- Variables
local ClassSymbol = Symbol.new("Value")

-- Types Extended
export type ValueInstance<T> = {
    Changed : RBXScriptSignal,
} & Types.BaseState<T>

export type ValueConstructor<T> = (Value : T) -> ValueInstance<T>

local function GetAttendedTableValue(ThisValue : any, ChangedSignal : Signal.Signal<string>)
    if typeof(ThisValue) ~= "table" then
        -- If not a table, don't bother running this function
        return ThisValue
    end

    -- We're pretty much making a proxy table so that we know when things change.
    -- This is kinna hacky and weird, but hey, it works. I'll find a better
    -- solution in the future.

    local FakeTable = {}
    
    local function CorrectFakeTable()
        -- table.insert doesn't trigger metamethods for optimization reasons
        -- so we need to manually correct the table before any reading/writing
        local LowestIndexForInsert = 1

        for Index, This in pairs(FakeTable) do
            if Index == LowestIndexForInsert then
                LowestIndexForInsert += 1
                table.insert(ThisValue, This)
            else
                ThisValue[Index] = This
            end

            FakeTable[Index] = nil
        end
    end


    local Proxy = setmetatable(FakeTable, {
        __index = function(_, Index : string)
            CorrectFakeTable() -- Before anything, the fake table should be fixed

            return GetAttendedTableValue(ThisValue[Index], ChangedSignal)
        end,

        __newindex = function(_, Index : string, NewValue : any)
            if IsValueChanged(ThisValue[Index], NewValue) then
                -- If the value changed, correct the table, update the
                -- value, and finally fire the changed signal

                CorrectFakeTable()
                ThisValue[Index] = NewValue
                ChangedSignal:Fire("Value")
            end
        end,

        __iter = function(_)
            CorrectFakeTable() -- You can't iterate properly unless this is called first

            return pairs(ThisValue)
        end,

        __len = function(_)
            CorrectFakeTable() -- Same as __iter, you can't get length without correction

            return #ThisValue
        end,
    })

    return Proxy
end

local function DeepCopyTable(This : {[any] : any})
    -- Copy copy copy
    local NewTable = {}

    for Index, ThisValue in This do
        if typeof(ThisValue) == "table" and not ThisValue.__SEAM_INDEX and not ThisValue.__SEAM_OBJECT then
            NewTable[Index] = DeepCopyTable(ThisValue)
        else
            NewTable[Index] = ThisValue
        end
    end

    return NewTable
end

--[=[
    Creates a new value object. Enforces type checking based on initial value type.

    @param Value any -- The initial value
    @return {Value : any} -- The value object
]=]

function Value:__call(ThisValue : any)
    local JanitorInstance = Janitor.new()
    local ChangedSignal = Signal.new()
    local AttachedSignal = Signal.new()
    local InstanceSymbol = Symbol.new("Value")
    local IsLocked = false

    if typeof(ThisValue) == "table" then
        -- Seam values clone tables before using them
        ThisValue = table.clone(ThisValue)
    end

    -- Make a proxy table if it's a table, otherwise it's just a value
    ThisValue = GetAttendedTableValue(ThisValue, ChangedSignal)

    --[[
        local This = Value(...)
        This.Value = x OR x = This.Value
        This.Changed -> As rbxscriptsignal
    --]]

    local ActiveValue; ActiveValue = setmetatable({
        Destroy = function(_)
            JanitorInstance:Destroy()
        end
    }, {
        __index = function(_, Index : string)
            if Index == "__SEAM_OBJECT" then
                return InstanceSymbol
            elseif Index == "Value" then
                return ThisValue
            elseif Index == "ValueRaw" then
                -- Use ValueRaw if Value ever has issues!

                if typeof(ThisValue) == "table" then
                    return DeepCopyTable(ThisValue)
                else
                    return ThisValue
                end
            elseif Index == "Changed" then
                return ChangedSignal
            elseif Index == "AttachedToInstance" then
                return AttachedSignal
            end

            return nil
        end,

        __newindex = function(_, Index : string, NewValue : any)
            if Index == "Value" and typeof(NewValue) == typeof(ThisValue) then
                if IsLocked then
                    error("Attempt to modify value when locked.")
                end

                if typeof(NewValue) == "table" then
                    -- Is the value a table? If so, update each table value individually

                    for SubIndex, _ in ThisValue do
                        if NewValue[SubIndex] == nil then
                            ThisValue[SubIndex] = nil
                        end
                    end

                    for SubIndex, SubValue in NewValue do
                        ThisValue[SubIndex] = SubValue
                    end
                else
                    -- If the value isn't a table, update it normally

                    if not IsValueChanged(ThisValue, NewValue) then
                        return
                    end

                    ThisValue = NewValue
                end

                -- Make sure to fire the changed signal for other states
                ChangedSignal:Fire("Value", ThisValue)
            elseif Index == "__LOCKED" then
                if NewValue == true then
                    IsLocked = true
                    ActiveValue:Destroy()
                else
                    error("Can not unlock values.")
                end
            else
                error("Invalid value type! Expected " .. typeof(ThisValue) .. ", got " .. typeof(NewValue))
            end
        end,

        __call = function(_, Object, Index : string)
            if not Object then
                return
            end

            if not Index then
                return
            end

            if typeof(ThisValue) == "table" then
                Object[Index] = DeepCopyTable(ThisValue)
            else
                Object[Index] = ThisValue
            end

            AttachedSignal:Fire(Object)

            JanitorInstance:Add(StateManager:AttachStateToObject(Object, {
                Value = function()
                    if typeof(ThisValue) == "table" then
                        return DeepCopyTable(ThisValue)
                    else
                        return ThisValue
                    end
                end,
                
                PropertyName = Index
            }))
        end
    })

    return ActiveValue :: ValueInstance<any>
end

--[=[
    @ignore
]=]

function Value:__index(Index : string)
    if Index == "__SEAM_INDEX" then
        return ClassSymbol
    elseif Index == "__SEAM_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

local Meta = setmetatable({}, Value)

return Meta :: ValueConstructor<any>