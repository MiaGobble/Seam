-- Author: iGottic

--[=[
    @class DependenciesManager
    @since 0.0.1
]=]

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

--[=[
    Attaches a state instance to a given object, updating the object's property on each render step.
    
    @param Object any -- The object to attach the state to
    @param StateInstance any -- The state instance containing the value and property name
    @return Janitor -- A Janitor instance managing the connections
]=]

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