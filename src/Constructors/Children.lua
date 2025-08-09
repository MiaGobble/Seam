-- Author: iGottic

--[=[
    @class Children
    @since 0.0.1
]=]

local Children = {}

-- Types
export type Children = (Object : Instance, Children : {[any] : any}) -> nil

--[=[
    Sets the parent of the given children to the given object. To be used in New()

    @param Object Instance -- The object to parent the children to
    @param Children {[any] : any} -- The children to parent to the object
]=]

local function ApplyChildren(Parent : Instance, Children : {[any] : any})
    local ChildrenCreated = {}

    if typeof(Children) ~= "table" then
        error("Invalid children type! Expected table, got " .. typeof(Children))
    end

    for _, Child in Children do
        if typeof(Child) ~= "Instance" then
            error("Invalid child type! Expected Instance, got " .. typeof(Child))
        end

        Child.Parent = Parent
        table.insert(ChildrenCreated, Child)
    end

    return ChildrenCreated
end

function Children:__call(Object : Instance, Children : {[any] : any})
    if typeof(Children) ~= "table" then
        error("Invalid children type! Expected table, got " .. typeof(Children))
    end

    if Children.__SEAM_OBJECT == "ComputedInstance" then -- Since 0.0.4, you can use computed as the children
        local ActiveChildren = ApplyChildren(Object, Children.Value)

        local Connection = Children.Changed:Connect(function()
            for _, Child in ActiveChildren do
                Child:Destroy()
            end

            ActiveChildren = ApplyChildren(Object, Children.Value)
        end)

        Object.Destroying:Connect(function()
            Connection:Disconnect()

            for _, Child in ActiveChildren do
                Child:Destroy()
            end
        end)

        return
    end

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