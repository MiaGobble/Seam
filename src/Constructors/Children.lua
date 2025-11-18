-- Author: iGottic

--[=[
    @class Children
    @since 0.0.1
]=]

local Children = {}

-- Imports
local Modules = script.Parent.Parent.Modules
local Types = require(Modules.Types)

-- Types Extended
export type Children = (Object : Instance, Children : {Types.Child}) -> nil

--[=[
    Sets the parent of the given children to the given object. To be used in New()

    @param Object Instance -- The object to parent the children to
    @param Children {[any] : any} -- The children to parent to the object
]=]

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

function Children:__call(Object : Instance, Children : Types.BaseState<any> | {any})
    if typeof(Children) ~= "table" then
        -- Children will either be an array or Computed instance, so it must be a table
        error("Invalid children type! Expected table, got " .. typeof(Children))
    end

    if Children.__SEAM_OBJECT == "ComputedInstance" then -- Since 0.1.0, you can use computed as the children
        local ActiveChildren = ApplyChildren(Object, Children.Value)

        local Connection = Children.Changed:Connect(function()
            -- When computed updates, update the children
            
            -- In the future I would like to make this more optimized, since destroying
            -- and reconstructing isn't the best thing in the world.

            for _, Child in ActiveChildren do
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

--[=[
    @ignore
]=]

function Children:__index(Index : string)
    if Index == "__SEAM_INDEX" then
        return "Children"
    elseif Index == "__SEAM_CAN_BE_SCOPED" then
        return false
    else
        return nil
    end
end

local Meta = setmetatable({}, Children)

return Meta :: Children