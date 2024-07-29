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

-- Services
local RunService = game:GetService("RunService")

-- Imports
local Modules = script.Parent.Parent.Modules
local DependenciesManager = require(Modules.DependenciesManager)

--[=[
    Constructs a Computed instance, which actively computes a value based on a given function.

    @param Callback (self : Instance, PropertyName : string) -> any? -- The function to compute the value
]=]

function Computed:__call(Callback : () -> any?)
    local ActiveComputation; ActiveComputation = setmetatable({}, {
        __call = function(_, Object : Instance, Index : string)
            -- TODO: Optimize this
            -- local Connection = RunService.RenderStepped:Connect(function()
            --     local Value = Callback(Object, Index)

            --     if Value == nil then
            --         warn("Computed value is nil, doing nothing")
            --         return
            --     end

            --     if Object[Index] ~= Value then
            --         Object[Index] = Value
            --     end
            -- end)

            -- if typeof(Object) == "Instance" then -- TODO: Change the way dependencies work
            --     Object.AncestryChanged:Connect(function()
            --         if not Object:IsDescendantOf(game) then
            --             Connection:Disconnect()
            --         end
            --     end)
            -- end

            -- DependenciesManager:AttachStateToObject(Object, {
            --     Value = Callback(Object, Index),
            --     PropertyName = Index
            -- })

            DependenciesManager:AttachStateToObject(Object, {
                Value = Callback,
                PropertyName = Index
            })
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