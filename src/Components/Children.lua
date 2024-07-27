-- Author: iGottic

--[=[
    @class Children
    @since 1.0.0
]=]

local Children = {}

--[=[
    Sets the parent of the given children to the given object. To be used in New()

    @param Object Instance -- The object to parent the children to
    @param Children {[any] : any} -- The children to parent to the object
]=]

function Children:__call(Object : Instance, Children : {[any] : any})
    -- ISSUE: As of right now, you can't use Sphi objects as children.

    for _, Child in Children do
        if typeof(Child) ~= "Instance" then
            error("Invalid child type! Expected Instance, got " .. typeof(Child))
        end

        Child.Parent = Object
    end
end

--[=[
    @ignore
]=]

function Children:__index(Index : string)
    if Index == "__SPHI_INDEX" then
        return "Children"
    else
        return nil
    end
end

return setmetatable({}, Children)