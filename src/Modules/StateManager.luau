-- Author: iGottic

local StateManager = {}

-- Types
type StateInstance = {
    Value : () -> any?,
    PropertyName : string,
}

-- Imports
local Trove = require(script.Parent.Trove)
local IsValueChanged = require(script.Parent.IsValueChanged)
local UpdateSignals = require(script.Parent.UpdateSignals)
local CreateDeepTraceback = require(script.Parent.CreateDeepTraceback)

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

-- This function is a bit weird but it's a lot of stuff to essentially just progate changes from one thing to another
function StateManager.AttachStateToObject(Object : any, StateInstance : StateInstance)
    local ObjectType = GetObjectType(Object)
    local TroveInstance = Trove.new()
    local UpdateFunction = nil
    local ChangedSignal = nil

    if ObjectType == "Instance" then
        -- Propogate state value to a instance

        local LastValue = nil

        UpdateFunction = function()
            local NewValue = StateInstance.Value

            if typeof(NewValue) == "function" then
                NewValue = NewValue()
            end

            if LastValue ~= nil and not IsValueChanged(LastValue, NewValue) then
                return
            end

            if typeof(Object[StateInstance.PropertyName]) ~= typeof(NewValue) then
                warn(`{Object:GetFullName()} expected type {typeof(Object[StateInstance.PropertyName])} for attached state value, got a value of type {typeof(NewValue)}{"\n"}{CreateDeepTraceback()}`)
                return
            end

            Object[StateInstance.PropertyName] = NewValue
            LastValue = NewValue
        end

        task.defer(function()
            TroveInstance:Add(Object.AncestryChanged:Connect(function()
                if not Object:IsDescendantOf(game) then
                    TroveInstance:Destroy()
                end
            end))
        end)
    elseif ObjectType == "SeamObject" then
        -- Propogate state value to a Seam state

        local LastValue = nil

        UpdateFunction = function()
            local NewValue = StateInstance.Value

            if typeof(NewValue) == "function" then
                NewValue = NewValue()
            end

            if LastValue ~= nil and not IsValueChanged(LastValue, NewValue) then
                return
            end

            Object[StateInstance.PropertyName] = NewValue
            LastValue = NewValue
        end
    else
        error("Attempted to attach non-state to object:\n" .. CreateDeepTraceback())
    end

    ChangedSignal = StateInstance.Changed

    -- Prefer a changed signal when updating
    if ChangedSignal ~= nil then
        TroveInstance:Add(ChangedSignal:Connect(UpdateFunction))
    else
        TroveInstance:Add(UpdateSignals.OnFrameUpdate:Connect(UpdateFunction))
    end

    -- Immediately apply current state to object
    task.spawn(UpdateFunction)

    return TroveInstance
end

return StateManager