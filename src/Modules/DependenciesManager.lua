local DependenciesManager = {}

-- Services
local RunService = game:GetService("RunService")

-- Imports
local Janitor = require(script.Parent.Janitor)

local function GetObjectType(Object : any) : string
    if typeof(Object) == "Instance" then
        return "Instance"
    elseif typeof(Object) == "table" then
        if Object.__SEAM_OBJECT then
            return "SphiObject"
        end
    end

    return "unknown"
end

function DependenciesManager:AttachStateToObject(Object : any, StateInstance : any)
    local ObjectType = GetObjectType(Object)
    local JanitorInstance = Janitor.new()

    if ObjectType == "Instance" then
        local LastValue = nil

        JanitorInstance:Add(RunService.RenderStepped:Connect(function()
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

        JanitorInstance:Add(Object.AncestryChanged:Connect(function()
            if not Object:IsDescendantOf(game) then
                JanitorInstance:Destroy()
            end
        end))
    elseif ObjectType == "SphiObject" then
        local LastValue = StateInstance.Value

        JanitorInstance:Add(RunService.RenderStepped:Connect(function()
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

    return JanitorInstance
end

return DependenciesManager