-- Author: iGottic

--[=[
    @class Scope
    @since 0.0.1
]=]

local Scope = {}

-- Imports
local Modules = script.Parent.Parent.Modules
local Janitor = require(Modules.Janitor)
local Types = require(Modules.Types)
local Computed = require(script.Parent.Computed)
local New = require(script.Parent.New)
local Rendered = require(script.Parent.Rendered)
local Value = require(script.Parent.Value)
local Spring = require(script.Parent.Animation.Spring)
local Tween = require(script.Parent.Animation.Tween)

-- Extended types
export type ScopeInstance = {
    New : (self : ScopeInstance, Class : string | Instance, Properties : {[any] : any}, From : any?) -> Instance,
    Rendered : (self : ScopeInstance, Callback : () -> any?) -> Rendered.RenderedInstance<any>,
    Value : (self : ScopeInstance, InitialValue : any) -> Value.ValueInstance<any>,
    Spring : (self : ScopeInstance, Value : Types.BaseState<any> | any, Speed : number, Dampening : number) -> Spring.SpringInstance<any>,
    Tween : (self : ScopeInstance, Value : Types.BaseState<any> | any, TweenInformation : TweenInfo) -> Tween.TweenInstance<any>,
    Computed : (self : ScopeInstance, Callback : ((Value : Value.ValueInstance<any>) -> any) -> any?) -> Computed.ComputedInstance<any>,

    InnerScope : (self : ScopeInstance, ScopedObjects : {[string] : any}?) -> ScopeInstance,
    AddObject : (self : ScopeInstance, Object : any) -> (),
    RemoveObject : (self : ScopeInstance, Object : any) -> (),
    Destroy : (self : ScopeInstance) -> (),
}

export type ScopeConstructor = (ScopedObjects : {[string] : (...any) -> ...any}) -> ScopeInstance

--[=[
    Constructs a Computed instance, which actively computes a value based on a given function.

    @param Callback (self : Instance, PropertyName : string) -> any? -- The function to compute the value
]=]

local Meta = setmetatable({}, Scope)

function Scope:__call(ScopedObjects : {[string] : any})
    local selfClass = {}
    local selfMeta = {}

    function selfMeta:__index(Key : string)
        local Object = self.ScopedObjects and self.ScopedObjects[Key]

        if not Object then
            return self[Key]
        end
    
        if typeof(Object) ~= "function" and (typeof(Object) ~= "table" or not Object.__SEAM_CAN_BE_SCOPED) then
            if Object.__SEAM_OBJECT or Object.__SEAM_INDEX then
                error((Object.__SEAM_OBJECT or Object.__SEAM_INDEX) .. " is not a valid scopable Seam object")
            else
                error("Object is not a valid scopable Seam object")
            end
        end
    
        return function(self, ...)
            local Tuple = nil

            if typeof(Object) == "function" then
                Tuple = {Object(self, ...)}
            else
                Tuple = {Object(...)}
            end
    
            if #Tuple == 0 then
                return
            end

            for _, Value in ipairs(Tuple) do
                self.Janitor:Add(Value)
            end
    
            return unpack(Tuple)
        end
    end

    function selfClass:InnerScope(NewScopedObjects : {[string] : any}?)
        if NewScopedObjects == nil then
            NewScopedObjects = {}
        end

        for Index, Value in ScopedObjects do
            if NewScopedObjects[Index] then
                continue
            end

            NewScopedObjects[Index] = Value
        end

        local NewScope = Meta(NewScopedObjects)
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