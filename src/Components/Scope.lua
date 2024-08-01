-- Author: iGottic

--[=[
    @class Scope
    @since 1.0.0
]=]

local Scope = {}

-- Types
type ScopeInstance = {
    ScopedObjects : {[string] : (...any) -> ...any},
}

type ScopeConstructor = (ScopedObjects : {[string] : (...any) -> ...any}) -> ScopeInstance

-- Imports
local Modules = script.Parent.Parent.Modules
local Janitor = require(Modules.Janitor)

--[=[
    Constructs a Computed instance, which actively computes a value based on a given function.

    @param Callback (self : Instance, PropertyName : string) -> any? -- The function to compute the value
]=]

local Meta = setmetatable({}, Scope)

function Scope:__call(ScopedObjects)
    local selfClass = {}
    local selfMeta = {}

    function selfMeta:__index(Key : string)
        local Object = self.ScopedObjects and self.ScopedObjects[Key]

        if not Object then
            return self[Key]
        end
    
        if typeof(Object) ~= "table" or not Object.__SEAM_CAN_BE_SCOPED then
            if Object.__SEAM_OBJECT or Object.__SEAM_INDEX then
                error((Object.__SEAM_OBJECT or Object.__SEAM_INDEX) .. " is not a valid scopable Seam object")
            else
                error("Object is not a valid scopable Seam object")
            end
            
            return
        end
    
        return function(self, ...)
            local Tuple = {Object(...)}
    
            if #Tuple == 0 then
                return
            end

            for _, Value in ipairs(Tuple) do
                self.Janitor:Add(Value)
            end
    
            return unpack(Tuple)
        end
    end

    function selfClass:InnerScope()
        local NewScope = Meta(ScopedObjects)
        self.Janitor:Add(NewScope)
        return NewScope
    end

    function selfClass:AddObject(Object : any)
        self.Janitor:Add(Object)
    end

    function selfClass:RemoveObject(Object : any)
        Object:Destroy()
        self.Janitor[Object] = nil
    end

    function selfClass:Destroy()
        self.Janitor:Destroy()
        self.Janitor = nil
    end

    local Object = setmetatable(selfClass, selfMeta)

    Object.ScopedObjects = ScopedObjects
    Object.Janitor = Janitor.new()

    return Object
end

function Scope:__index(Key : string)
    if Key == "__SEAM_OBJECT" then
        return "Scope"
    elseif Key == "__SEAM_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

return Meta :: ScopeConstructor