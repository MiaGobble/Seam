-- Author: iGottic

local Value = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local StateManager = require(Modules.StateManager)
local Trove = require(Modules.Trove)
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

function Value:__call(ThisValue : any)
    local TroveInstance = Trove.new()
    local ChangedSignal = Signal.new()
    local AttachedSignal = Signal.new()
    local InstanceSymbol = Symbol.new("Value")
    local IsLocked = false
    local ValueType = if ThisValue ~= nil then typeof(ThisValue) else nil

    if ValueType == "table" then
        -- Seam values clone tables before using them
        ThisValue = table.clone(ThisValue)
    end

    --[[
        local This = Value(...)
        This.Value = x OR x = This.Value
        This.Changed -> As rbxscriptsignal
    --]]

    local ActiveValue; ActiveValue = setmetatable({
        Destroy = function(_)
            TroveInstance:Destroy()
        end
    }, {
        __index = function(_, Index : string)
            if Index == "__SEAM_OBJECT" then
                return InstanceSymbol
            elseif Index == "Value" then
                return ThisValue
            elseif Index == "Changed" then
                return ChangedSignal
            elseif Index == "AttachedToInstance" then
                return AttachedSignal
            end

            return nil
        end,

        __newindex = function(_, Index : string, NewValue : any)
            if Index == "Value" then
                if IsLocked then
                    error("Attempt to modify value when locked.")
                end

                if ValueType ~= nil then
                    if NewValue ~= nil and typeof(NewValue) ~= ValueType then
                        error("Invalid value type! Expected " .. ValueType .. ", got " .. typeof(NewValue))
                    end
                elseif NewValue ~= nil then
                    ValueType = typeof(NewValue)
                end

                if not IsValueChanged(ThisValue, NewValue) then
                    return
                end

                ThisValue = NewValue

                -- Make sure to fire the changed signal for other states
                ChangedSignal:Fire("Value", ThisValue)
                return
            elseif Index == "__LOCKED" then
                if NewValue == true then
                    IsLocked = true
                    ActiveValue:Destroy()
                    return
                else
                    error("Can not unlock values.")
                end
            elseif Index == "__SEAM_OBJECT" then
                return InstanceSymbol
            else
                error("Ran into an unexpected error")
            end
        end,

        __call = function(_, Object, Index : string)
            if not Object then
                return
            end

            if not Index then
                return
            end

            if typeof(ThisValue) == "table" and ThisValue ~= nil then
                Object[Index] = table.clone(ThisValue)
            else
                Object[Index] = ThisValue
            end

            AttachedSignal:Fire(Object)

            TroveInstance:Add(StateManager:AttachStateToObject(Object, {
                Value = function()
                    if typeof(ThisValue) == "table" and ThisValue ~= nil then
                        return table.clone(ThisValue)
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