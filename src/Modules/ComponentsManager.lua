-- Author: iGottic

--[=[
    @class ComponentsManager
    @since 0.0.1
]=]

local ComponentsManager = {}

-- Variables
local StoredComponents = {}

--[=[
    Declares a component on the backend

    @return ComponentsManager -- The ComponentsManager instance
]=]

function ComponentsManager:PushComponent(ComponentName : string, Constructor : (any) -> any)
    StoredComponents[ComponentName] = Constructor
end

--[=[
    Removes a component from the backend

    @return ComponentsManager -- The ComponentsManager instance
]=]

function ComponentsManager:RemoveComponent(ComponentName : string)
    StoredComponents[ComponentName] = nil
end

--[=[
    Gets a component from the backend

    @return any? -- The component constructor, or nil if it doesn't exist
]=]

function ComponentsManager:GetComponent(ComponentName : string)
    return StoredComponents[ComponentName]
end

return ComponentsManager