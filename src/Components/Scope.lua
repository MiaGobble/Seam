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

function Scope:__call(ScopedObjects)
    local selfClass = {}
    local selfMeta = {}

    function selfMeta:__index(Key : string)
        local Object = self.ScopedObjects and self.ScopedObjects[Key]

        if not Object then
            return self[Key]
        end
    
        if typeof(Object) ~= "table" then
            error("Object is not a valid Sphi object")
            return
        end
    
        return function(self, ...)
            local Tuple = {Object(...)}
    
            if #Tuple == 0 then
                return
            end

            for Index, Value in ipairs(Tuple) do
                self.Janitor:Add(Value)
            end
    
            return unpack(Tuple)
        end
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

local Meta = setmetatable({}, Scope)

return Meta :: ScopeConstructor