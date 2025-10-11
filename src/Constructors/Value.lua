-- Author: iGottic

--[=[
    @class Value
    @since 0.0.1
]=]

local Value = {}

-- Imports
local Modules = script.Parent.Parent.Modules
local DependenciesManager = require(Modules.DependenciesManager)
local Janitor = require(Modules.Janitor)
local Signal = require(Modules.Signal)
local Types = require(Modules.Types)
local IsValueChanged = require(Modules.IsValueChanged)

-- Types Extended
export type ValueInstance<T> = {
    Changed : RBXScriptSignal,
} & Types.BaseState<T>

export type ValueConstructor<T> = (Value : T) -> ValueInstance<T>

local function GetAttendedTableValue(Value : any, ChangedSignal : Signal.Signal<string>)
    if typeof(Value) ~= "table" then
        return Value
    end

    local FakeTable = {}

    -- table.insert doesn't trigger metamethods for optimization reasons
    -- so we need to manually correct the table before any reading/writing
    local function CorrectFakeTable()
        local LowestIndexForInsert = 1

        for Index, This in pairs(FakeTable) do
            if Index == LowestIndexForInsert then
                LowestIndexForInsert += 1
                table.insert(Value, This)
            else
                Value[Index] = This
            end

            FakeTable[Index] = nil
        end
    end


    local Proxy = setmetatable(FakeTable, {
        __index = function(self, Index : string)
            CorrectFakeTable()

            return GetAttendedTableValue(Value[Index], ChangedSignal)
        end,

        __newindex = function(self, Index : string, NewValue : any)
            if IsValueChanged(Value[Index], NewValue) then
                CorrectFakeTable()
                Value[Index] = NewValue
                ChangedSignal:Fire("Value")
            end
        end,

        __iter = function(self)
            CorrectFakeTable()

            return pairs(Value)
        end,

        __len = function(self)
            CorrectFakeTable()

            return #Value
        end,
    })

    return Proxy
end

local function DeepCopyTable(This : {[any] : any})
    local NewTable = {}

    for Index, Value in This do
        if typeof(Value) == "table" and not Value.__SEAM_INDEX and not Value.__SEAM_OBJECT then
            NewTable[Index] = DeepCopyTable(Value)
        else
            NewTable[Index] = Value
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

    if typeof(ThisValue) == "table" then
        ThisValue = table.clone(ThisValue)
    end

    ThisValue = GetAttendedTableValue(ThisValue, ChangedSignal)

    --[[
        local This = Value(...)
        This.Value = x OR x = This.Value
        This.Changed -> As rbxscriptsignal
    --]]

    local ActiveValue = setmetatable({
        Destroy = function(self)
            JanitorInstance:Destroy()
        end
    }, {
        __index = function(self, Index : string)
            if Index == "__SEAM_OBJECT" then
                return "Value"
            elseif Index == "Value" then
                return ThisValue
            elseif Index == "ValueRaw" then
                if typeof(ThisValue) == "table" then
                    return DeepCopyTable(ThisValue)
                else
                    return ThisValue
                end
            elseif Index == "Changed" then
                return ChangedSignal
            end

            return nil
        end,

        __newindex = function(self, Index : string, NewValue : any)
            if Index == "Value" and typeof(NewValue) == typeof(ThisValue) then
                if not IsValueChanged(ThisValue, NewValue) then
                    return
                end

                if typeof(NewValue) == "table" then
                    for Index, Value in ThisValue do
                        if NewValue[Index] == nil then
                            ThisValue[Index] = nil
                        end
                    end

                    for Index, Value in NewValue do
                        ThisValue[Index] = Value
                    end
                else
                    ThisValue = NewValue
                end

                ChangedSignal:Fire("Value")
            else
                error("Invalid value type! Expected " .. typeof(ThisValue) .. ", got " .. typeof(NewValue))
            end
        end,

        __call = function(self, Object, Index : string)
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

            JanitorInstance:Add(DependenciesManager:AttachStateToObject(Object, {
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
        return "Value"
    elseif Index == "__SEAM_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

local Meta = setmetatable({}, Value)

return Meta :: ValueConstructor<any>