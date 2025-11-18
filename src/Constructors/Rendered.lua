-- Author: iGottic

--[=[
    @class Rendered
    @since 0.0.3
]=]

local Rendered = {}

-- Imports
local Modules = script.Parent.Parent.Modules
local StateManager = require(Modules.StateManager)
local Janitor = require(Modules.Janitor)
local Types = require(Modules.Types)

-- Types Extended
export type RenderedInstance<T> = {} & Types.BaseState<T>
export type RenderedConstructor<T> = (Callback : () -> any?) -> RenderedInstance<T>

--[=[
    Constructs a Rendered instance, which actively computes a value based on a given function.

    @param Callback (self : Instance, PropertyName : string) -> any? -- The function to compute the value
]=]

function Rendered:__call(Callback : () -> any?)
    -- This is MUCH simpler than computed, since it just force-updates every frame

    local JanitorInstance = Janitor.new()

    local ActiveComputation; ActiveComputation = setmetatable({
        Destroy = function()
            JanitorInstance:Destroy()
        end
    }, {
        __call = function(_, Object : Instance, Index : string)
            -- Every frame, update the value

            JanitorInstance:Add(StateManager:AttachStateToObject(Object, {
                Value = Callback,
                PropertyName = Index
            }))

            return ActiveComputation
        end,

        __index = function(_, Index : string)
            if Index == "__SEAM_OBJECT" then
                return "RenderedInstance"
            elseif Index == "Value" then
                return Callback()
            end

            return nil
        end
    })

    return ActiveComputation :: RenderedInstance<any>
end

--[=[
    @ignore
]=]

function Rendered:__index(Key : string)
    if Key == "__SEAM_INDEX" then
        return "Rendered"
    elseif Key == "__SEAM_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

local Meta = setmetatable({}, Rendered)

return Meta :: RenderedConstructor<any>