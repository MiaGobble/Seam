local ComponentsManager = {}

-- Variables
local StoredComponents = {}

function ComponentsManager:PushComponent(ComponentName : string, Constructor : (any) -> any)
    StoredComponents[ComponentName] = Constructor
end

function ComponentsManager:RemoveComponent(ComponentName : string)
    StoredComponents[ComponentName] = nil
end

function ComponentsManager:GetComponent(ComponentName : string)
    return StoredComponents[ComponentName]
end

return ComponentsManager