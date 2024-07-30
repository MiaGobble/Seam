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
local Maid = require(Modules.Maid)

--[=[
    Constructs a Computed instance, which actively computes a value based on a given function.

    @param Callback (self : Instance, PropertyName : string) -> any? -- The function to compute the value
]=]

function Computed:__call(Callback : () -> any?)
    local MaidInstance = Maid.new()

    local ActiveComputation; ActiveComputation = setmetatable({
        Destroy = function(self)
            MaidInstance:Destroy()
            MaidInstance = nil
        end
    }, {
        __call = function(_, Object : Instance, Index : string)
            MaidInstance:GiveTask(MaidInstance[DependenciesManager:AttachStateToObject(Object, {
                Value = Callback,
                PropertyName = Index
            })])
        end,

        __index = function(_, Index : string)
            if Index == "__SPHI_OBJECT" then
                return "Computed"
            elseif Index == "Value" then
                return Callback()
            end

            return nil
        end
    })

    return ActiveComputation :: ComputedInstance
end

local Meta = setmetatable({}, Computed)

return Meta :: ComputedConstructor