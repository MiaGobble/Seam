local DependenciesManager = {}

-- Services
local RunService = game:GetService("RunService")

-- Imports
local Maid = require(script.Parent.Maid)

local function GetObjectType(Object : any) : string
    if typeof(Object) == "Instance" then
        return "Instance"
    elseif typeof(Object) == "table" then
        if Object.__SPHI_OBJECT then
            return "SphiObject"
        end
    end

    return "unknown"
end

function DependenciesManager:AttachStateToObject(Object : any, StateInstance : any)
    local ObjectType = GetObjectType(Object)
    local MaidInstance = Maid.new()

    if ObjectType == "Instance" then
        local LastValue = nil

        MaidInstance:GiveTask(RunService.RenderStepped:Connect(function()
            local NewValue = StateInstance.Value

            if typeof(NewValue) == "function" then
                NewValue = NewValue()
            end

            if LastValue == NewValue then
                return
            end

            Object[StateInstance.PropertyName] = NewValue
            LastValue = NewValue
        end))

        MaidInstance:GiveTask(Object.AncestryChanged:Connect(function()
            if not Object:IsDescendantOf(game) then
                Maid:Destroy()
            end
        end))
    elseif ObjectType == "SphiObject" then
        local LastValue = StateInstance.Value

        MaidInstance:GiveTask(RunService.RenderStepped:Connect(function()
            local NewValue = StateInstance.Value

            if typeof(NewValue) == "function" then
                NewValue = NewValue()
            end

            if LastValue == NewValue then
                return
            end

            Object[StateInstance.PropertyName] = NewValue
            LastValue = NewValue
        end))
    end

    return MaidInstance
end

return DependenciesManager