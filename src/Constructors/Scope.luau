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
local Reaction = require(script.Parent.Reaction)
local Rendered = require(script.Parent.Rendered)
local Value = require(script.Parent.Value)
local Spring = require(script.Parent.Animation.Spring)
local Tween = require(script.Parent.Animation.Tween)

-- Extended types
export type ScopeInstance = {
    Create : (self : ScopeInstance, Class : string | Instance | {[string] : any?}, Properties : {[any] : any}, From : any?) -> Instance,
    Rendered : (self : ScopeInstance, Callback : () -> any?) -> Rendered.RenderedInstance<any>,
    Value : (self : ScopeInstance, InitialValue : any) -> Value.ValueInstance<any>,
    Spring : (self : ScopeInstance, Value : Types.BaseState<any> | any, Speed : number, Dampening : number) -> Spring.SpringInstance<any>,
    Tween : (self : ScopeInstance, Value : Types.BaseState<any> | any, TweenInformation : TweenInfo) -> Tween.TweenInstance<any>,
    Reaction : (self : ScopeInstance, Callback : ((Value : Value.ValueInstance<any>) -> any) -> any?) -> Reaction.ReactionInstance<any>,

    InnerScope : (self : ScopeInstance, ScopedObjects : {[string] : any}?) -> ScopeInstance,
    AddObject : (self : ScopeInstance, Object : any) -> (),
    RemoveObject : (self : ScopeInstance, Object : any) -> (),
    Destroy : (self : ScopeInstance) -> (),
}

export type ScopeConstructor = (ScopedObjects : {[string] : (...any) -> ...any}) -> ScopeInstance

--[=[
    Constructs a Reaction instance, which actively computes a value based on a given function.

    @param Callback (self : Instance, PropertyName : string) -> any? -- The function to compute the value
]=]

local Meta = setmetatable({}, Scope)

function Scope:__call(ScopedObjects : {[string] : any})
    -- Scopes have been a headache to get working, since I'm a dumdum

    local selfClass = {}
    local selfMeta = {}

    function selfMeta:__index(Key : string)
        if Key == "__SEAM_OBJECT" then
            -- Some things check if something is a seam object, so
            -- this is the first thing we should try to return
            return "Scope"
        end

        local Object = self.ScopedObjects and self.ScopedObjects[Key]

        if Object == nil then
            -- If something doesn't exist in the scope, return nil
            return nil
        end
    
        if typeof(Object) ~= "function" and (typeof(Object) ~= "table" or not Object.__SEAM_CAN_BE_SCOPED) then
            if Object.__SEAM_OBJECT or Object.__SEAM_INDEX then
                -- If something from seam has __SEAM_CAN_BE_SCOPED (meaning it can't be scoped) as false,
                -- then we should error what specifically the user tried to use
                error((Object.__SEAM_OBJECT or Object.__SEAM_INDEX) .. " is not a valid scopable Seam object")
            else
                -- Idk just error
                error("Object is not a valid scopable Seam object")
            end
        end
    
        return function(_, ...)
            -- Seam things are called as functions, so this is a wrapper
            -- function that puts any created instances into the janitor
            local Tuple = nil

            if typeof(Object) == "function" then
                -- If it's a non-Seam function, let's pass the scope as the first parameter,
                -- then pass in everything else
                Tuple = {Object(self, ...)}
            elseif Object.__SEAM_OBJECT == "Create" then
                -- For Create specifically, we want to actually put scope at the end. In the
                -- future, if seam requires scopes, this will change
                local Args = {...}
                table.insert(Args, self)
                Tuple = {Object(unpack(Args))}
            else
                -- Right now, scope is not passed in to most seam objects
                Tuple = {Object(...)}
            end
    
            -- If nothing returns, don't bother running the rest of the code
            if #Tuple == 0 then
                return
            end

            -- But yeah, let's add created things to the janitor
            for _, Value in Tuple do
                self.Janitor:Add(Value)
            end
    
            -- Unpack the tuple and return it ALLLLLLLL
            return unpack(Tuple)
        end
    end

    function selfClass:InnerScope(NewScopedObjects : {[string] : any}?)
        -- Default to a blank table
        if NewScopedObjects == nil then
            NewScopedObjects = {}
        end

        -- Take the current scoped objects and copy them to the new table
        for Index, Value in self.ScopedObjects do
            NewScopedObjects[Index] = Value
        end

        local NewScope = Meta(NewScopedObjects) -- Make a new scope
        self.Janitor:Add(NewScope) -- Add the new sub-scope to the parent janitor

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