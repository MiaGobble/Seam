-- Author: iGottic

--[=[
    @class FollowProperty
    @since 0.0.3
]=]

local FollowProperty = {}

-- Imports
local Modules = script.Parent.Parent.Modules
local Types = require(Modules.Types)
local Symbol = require(Modules.Symbol)

-- Variables
local ClassSymbol = Symbol.new("FollowProperty")

-- Types Extended
export type FollowProperty = (PropertyName : string) -> (Object : Instance, ValueState : Types.BaseState<any>) -> nil

--[=[
    @ignore
]=]

function FollowProperty:__call(PropertyName : string)
    return setmetatable({}, {
        __call = function(_, Object : Instance, ValueState : Types.BaseState<any>)
            -- Literally just a simple connection and value update

            Object:GetPropertyChangedSignal(PropertyName):Connect(function()
                if Object[PropertyName] ~= ValueState.Value then
                    ValueState.Value = Object[PropertyName]
                end

                ValueState.Value = Object[PropertyName]
            end)
        end,

        __index = function(_, Index : string)
            if Index == "__SEAM_INDEX" then
                return ClassSymbol
            elseif Index == "__SEAM_CAN_BE_SCOPED" then
                return false
            else
                return nil
            end
        end,
    })
end

local Meta = setmetatable({}, FollowProperty)

return Meta :: FollowProperty