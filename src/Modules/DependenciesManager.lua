local DependenciesManager = {}

local function GetObjectType(Object : any) : string
    if typeof(Object) == "Instance" then
        return "Instance"
    elseif typeof(Object) == "table" then
        if Object.__SPHI_OBJECT then
            return "SphiObject"
        end
    end

    return "unknown"
end

function DependenciesManager:AttachStateToObject(Object : any, StateInstance : any)
    local ObjectType = GetObjectType(Object)

    
end

return DependenciesManager