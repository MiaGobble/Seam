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

    local FakeTable = setmetatable({}, {
        __index = function(self, Index : string)
            return GetAttendedTableValue(Value[Index], ChangedSignal)
        end,

        __newindex = function(self, Index : string, NewValue : any)
            if IsValueChanged(Value[Index], NewValue) then
                Value[Index] = NewValue
                ChangedSignal:Fire("Value")
            end
        end,

        __iter = function(self)
            return pairs(Value)
        end
    })

    return FakeTable
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
                return GetAttendedTableValue(ThisValue, ChangedSignal)
            elseif Index == "ValueRaw" then
                return ThisValue
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
                    ThisValue = table.clone(NewValue)
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

            Object[Index] = ThisValue

            JanitorInstance:Add(DependenciesManager:AttachStateToObject(Object, {
                Value = function()
                    return ThisValue
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