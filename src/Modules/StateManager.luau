-- Author: iGottic

local StateManager = {}

-- Imports
local Trove = require(script.Parent.Trove)
local IsValueChanged = require(script.Parent.IsValueChanged)
local GetValue = require(script.Parent.Parent.Constructors.Utilities.GetValue)
local UpdateSignals = require(script.Parent.UpdateSignals)

local function GetObjectType(Object : any) : string
    if typeof(Object) == "Instance" then
        return "Instance"
    elseif typeof(Object) == "table" then
        if Object.__SEAM_OBJECT then
            return "SeamObject"
        end
    end

    return "unknown"
end

function StateManager:AttachStateToObject(Object : any, StateInstance : any)
    local ObjectType = GetObjectType(Object)
    local TroveInstance = Trove.new()

    if ObjectType == "Instance" then
        local LastValue = nil

        TroveInstance:Add(UpdateSignals.OnFrameUpdate:Connect(function()
            local NewValue = StateInstance.Value

            if typeof(NewValue) == "function" then
                NewValue = NewValue()
            end

            if LastValue ~= nil and not IsValueChanged(LastValue, NewValue) then
                return
            end

            Object[StateInstance.PropertyName] = NewValue
            LastValue = NewValue
        end))

        task.defer(function()
            TroveInstance:Add(Object.AncestryChanged:Connect(function()
                if not Object:IsDescendantOf(game) then
                    TroveInstance:Destroy()
                end
            end))
        end)
    elseif ObjectType == "SeamObject" then
        local LastValue = nil

        TroveInstance:Add(UpdateSignals.OnFrameUpdate:Connect(function()
            local NewValue = StateInstance.Value

            if typeof(NewValue) == "function" then
                NewValue = NewValue()
            end

            if LastValue ~= nil and not IsValueChanged(LastValue, NewValue) then
                return
            end

            Object[StateInstance.PropertyName] = NewValue
            LastValue = NewValue
        end))
    else
        error("Attempted to attach non-state to object:\n" .. debug.traceback())
    end

    return TroveInstance
end

return StateManager