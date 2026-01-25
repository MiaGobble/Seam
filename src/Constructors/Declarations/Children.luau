-- Author: iGottic

local Children = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Symbol = require(Modules.Symbol)

-- Variables
local ClassSymbol = Symbol.new("Children")

-- Types Extended
export type Children = (Object : Instance, Children : {Types.Child}) -> nil

local function ApplyChildren(Parent : Instance, Children : {Types.Child})
    -- This function just goes through the table and sets the parent of
    -- every thing in there to the determined parent.

    local ChildrenCreated = {}

    if typeof(Children) ~= "table" then
        error("Invalid children type! Expected table, got " .. typeof(Children))
    end

    for _, Child in Children do
        if typeof(Child) ~= "Instance" then
            error("Invalid child type! Expected Instance, got " .. typeof(Child))
        end

        local Success = pcall(function()
            Child.Parent = Parent
        end)

        if Success then
            table.insert(ChildrenCreated, Child)
        end
    end

    return ChildrenCreated
end

local function GetOldChildren(OldChildren : {Instance}, NewChildren : {Instance})
    local DifferenceSet = {}

    for _, OldChild in OldChildren do
        if not table.find(NewChildren, OldChild) then
            table.insert(DifferenceSet, OldChild)
            continue
        end
    end

    return DifferenceSet
end

function Children:__call(Object : Instance, Children : Types.BaseState<any> | {any})
    if typeof(Children) ~= "table" then
        -- Children will either be an array or Computed instance, so it must be a table
        error("Invalid children type! Expected table, got " .. typeof(Children))
    end

    if Children.__SEAM_OBJECT and tostring(Children.__SEAM_OBJECT) == "ComputedInstance" then -- Since 0.1.0, you can use computed as the children
        local ActiveChildren = ApplyChildren(Object, Children.Value)

        local Connection = Children.Changed:Connect(function()
            -- When computed updates, update the children
            
            local DifferenceSet = GetOldChildren(ActiveChildren, Children.Value)

            for _, Child in DifferenceSet do
                Child:Destroy()
            end

            ActiveChildren = ApplyChildren(Object, Children.Value)
        end)

        -- Also make sure we clean things up when the parent is destroyed
        Object.Destroying:Connect(function()
            Connection:Disconnect()

            for _, Child in ActiveChildren do
                Child:Destroy()
            end
        end)

        return
    end

    -- If it's not a computed instance, just apply the array of children to the parent
    ApplyChildren(Object, Children)
end

function Children:__index(Index : string)
    if Index == "__SEAM_INDEX" then
        return ClassSymbol
    elseif Index == "__SEAM_CAN_BE_SCOPED" then
        return false
    else
        return nil
    end
end

local Meta = setmetatable({}, Children)

return Meta :: Children