-- Author: iGottic

--[=[
    @class Computed
    @since 1.0.0
]=]

local Computed = {}

-- Services
local RunService = game:GetService("RunService")

--[=[
    Constructs a Computed instance, which actively computes a value based on a given function.

    @param Callback (self : Instance, PropertyName : string) -> any? -- The function to compute the value
]=]

function Computed:__call(Callback : (self : Instance, PropertyName : string) -> any?)
    local ActiveComputation = setmetatable({}, {
        __call = function(_, Object : Instance, Index : string)
            local Connection = RunService.RenderStepped:Connect(function() -- Surprisingly enough, this is a fairly efficient way to update computed values on a large scale
                local Value = Callback(Object, Index)

                if Value == nil then
                    warn("Computed value is nil, doing nothing")
                    return
                end

                if Object[Index] ~= Value then
                    Object[Index] = Value
                end
            end)

            Object.AncestryChanged:Connect(function()
                if not Object:IsDescendantOf(game) then
                    Connection:Disconnect()
                end
            end)
        end,

        __index = function(_, Index : string)
            if Index == "__SPHI_OBJECT" then
                return "Computed"
            elseif Index == "get" then
                return Callback
            end
        end
    })

    return ActiveComputation
end

return setmetatable({}, Computed)