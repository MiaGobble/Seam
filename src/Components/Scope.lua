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
    
        if typeof(Object) ~= "table" then
            error("Object is not a valid Seam object")
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

return Meta :: ScopeConstructor