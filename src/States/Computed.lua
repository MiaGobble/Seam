-- Author: iGottic

--[=[
    @class Computed
    @since 1.0.0
]=]

local Computed = {}

-- Types
type ComputedInstance = {
    get : (self : Instance, PropertyName : string) -> any?
}

type ComputedConstructor = (Callback : () -> any?) -> ComputedInstance

-- Imports
local Modules = script.Parent.Parent.Modules
local DependenciesManager = require(Modules.DependenciesManager)
local Janitor = require(Modules.Janitor)

--[=[
    Constructs a Computed instance, which actively computes a value based on a given function.

    @param Callback (self : Instance, PropertyName : string) -> any? -- The function to compute the value
]=]

function Computed:__call(Callback : () -> any?)
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

function Computed:__index(Key : string)
    if Key == "__SEAM_INDEX" then
        return "Computed"
    elseif Key == "__SEAM_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

local Meta = setmetatable({}, Computed)

return Meta :: ComputedConstructor