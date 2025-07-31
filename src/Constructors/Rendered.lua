-- Author: iGottic

--[=[
    @class Rendered
    @since 0.0.3
]=]

local Rendered = {}

-- Types
type ComputedInstance = {
    get : (self : Instance, PropertyName : string) -> any?
}

-- Imports
local Modules = script.Parent.Parent.Modules
local DependenciesManager = require(Modules.DependenciesManager)
local Janitor = require(Modules.Janitor)

-- Types Extended
type ComputedConstructor = (Callback : () -> any?) -> ComputedInstance

--[=[
    Constructs a Rendered instance, which actively computes a value based on a given function.

    @param Callback (self : Instance, PropertyName : string) -> any? -- The function to compute the value
]=]

function Rendered:__call(Callback : () -> any?)
    local JanitorInstance = Janitor.new()

    local ActiveComputation; ActiveComputation = setmetatable({
        Destroy = function()
            JanitorInstance:Destroy()
        end
    }, {
        __call = function(_, Object : Instance, Index : string)
            JanitorInstance:Add(DependenciesManager:AttachStateToObject(Object, {
                Value = Callback,
                PropertyName = Index
            }))

            return ActiveComputation
        end,

        __index = function(_, Index : string)
            if Index == "__SEAM_OBJECT" then
                return "ComputedInstance"
            elseif Index == "Value" then
                return Callback()
            end

            return nil
        end
    })

    return ActiveComputation :: ComputedInstance
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

return Meta :: ComputedConstructor