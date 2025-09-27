-- Author: iGottic

--[=[
    @class FollowAttribute
    @since 0.0.3
]=]

local FollowAttribute = {}

-- Imports
local Modules = script.Parent.Parent.Modules
local Types = require(Modules.Types)

-- Types Extended
export type FollowAttribute = (AttributeName : string) -> (Object : Instance, ValueState : Types.BaseState) -> nil

--[=[
    @ignore
]=]

function FollowAttribute:__call(AttributeName : string)
    return setmetatable({}, {
        __call = function(_, Object : Instance, ValueState : Types.BaseState)
            Object:GetAttributeChangedSignal(AttributeName):Connect(function()
                if Object:GetAttribute(AttributeName) ~= ValueState.Value then
                    ValueState.Value = Object:GetAttribute(AttributeName)
                end

                ValueState.Value = Object:GetAttribute(AttributeName)
            end)
        end,

        __index = function(_, Index : string)
            if Index == "__SEAM_INDEX" then
                return "FollowAttribute"
            elseif Index == "__SEAM_CAN_BE_SCOPED" then
                return false
            else
                return nil
            end
        end,
    })
end

local Meta = setmetatable({}, FollowAttribute)

return Meta :: FollowAttribute