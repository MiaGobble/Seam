-- Author: iGottic

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Trove = require(Modules.Trove)
local Symbol = require(Modules.Symbol)
local CreateDeepTraceback = require(Modules.CreateDeepTraceback)

-- Class
local Scope : Types.ConstructorDecompiled = {}
local ScopeCompiled : Types.ScopeConstructor

Scope.__SEAM_OBJECT = Symbol.new("Scope")
Scope.__SEAM_CAN_BE_SCOPED = true

function Scope.__CALLBACK(_: Types.ConstructorCompiled, ScopedObjects : {[string] : any})
    -- Scopes have been a headache to get working, since I'm a dumdum

    local IsDestroyed = false
    local ScopeInstance : Types.ObjectCompiled

    if not ScopedObjects then
        ScopedObjects = {}
    end

    ScopedObjects = table.clone(ScopedObjects)

    local ScopeObject : Types.ObjectDecompiled = {
        __SEAM_OBJECT = Symbol.new("Scope"),
    }

    function ScopeObject.InnerScope(self : Types.ObjectCompiled, NewScopedObjects : {[string] : any}?)
        if IsDestroyed then
            warn(`Attempted to create inner scope but scope is already destroyed: {CreateDeepTraceback()}`)
            return
        end

        -- Default to a blank table
        if NewScopedObjects == nil then
            NewScopedObjects = {}
        end

        -- Take the current scoped objects and copy them to the new table
        for Index, Object in self.ScopedObjects do
            NewScopedObjects[Index] = Object
        end

        local NewScope = ScopeCompiled(NewScopedObjects) -- Make a new scope
        NewScope.ParentScope = self
        self.Trove:Add(NewScope) -- Add the new sub-scope to the parent trove

        return NewScope
    end

    function ScopeObject.AddObject<T>(self : Types.ObjectCompiled, Object : T)
        if IsDestroyed then
            warn(`Attempted to add object to scope but scope is already destroyed: {CreateDeepTraceback()}`)
            return
        end

        return self.Trove:Add(Object)
    end

    function ScopeObject.RemoveObject(self : Types.ObjectCompiled, Object : any)
        if IsDestroyed then
            warn(`Attempted to remove object from scope but scope is already destroyed: {CreateDeepTraceback()}`)
            return
        end

        self.Trove:Remove(Object)
    end

    function ScopeObject.Destroy(self : Types.ObjectCompiled)
        if IsDestroyed then
            warn(`Attempted to destroy scope but scope is already destroyed: {CreateDeepTraceback()}`)
            return
        end

        IsDestroyed = true
        self.Trove:Destroy()
        self.Trove = nil

        local ParentScope = rawget(self, "ParentScope")

        if ParentScope then
            local ParentTrove = rawget(ParentScope, "Trove")
            if ParentTrove and not ParentTrove._cleaning then
                ParentTrove:Pop(self)
            end
            rawset(self, "ParentScope", nil)
        end
    end

    function ScopeObject.__INDEX(self : Types.ObjectCompiled, Key : string)
        if IsDestroyed then
            warn(`Attempted to index a scope with {Key} but scope is already destroyed: {CreateDeepTraceback()}`)
            return
        end

        if not Key then
            warn(`Attempt to index a scope with nil{"\n"}{CreateDeepTraceback()}`)
            return
        end

        local Object = ScopedObjects[Key]

        if Object == nil then
            warn(`Attempt to index a scope with {Key} when it does not exist in scope{"\n"}{CreateDeepTraceback()}`)
            return nil
        end

        if typeof(Object) ~= "function" and (typeof(Object) ~= "table" or not Object.__SEAM_CAN_BE_SCOPED) then
            if Object.__SEAM_OBJECT or Object.__SEAM_INDEX then
                -- If something from seam has __SEAM_CAN_BE_SCOPED (meaning it can't be scoped) as false,
                -- then we should error what specifically the user tried to use
                error(tostring(Object.__SEAM_OBJECT or Object.__SEAM_INDEX) .. " is not a valid scopable Seam object")
            else
                -- Idk just error
                error("Object is not a valid scopable Seam object")
            end
        end

        return function(_, ...)
            if not self.Trove then -- If the trove instance doesn't exist, the scope is likely destroyed
                warn(`Attempted to use something in scope ({Key}) but scope is already destroyed: {CreateDeepTraceback()}`)
                return
            end

            -- Seam things are called as functions, so this is a wrapper
            -- function that puts any created instances into the trove
            local Tuple = nil

            if typeof(Object) == "function" then
                -- If it's a non-Seam function, let's pass the scope as the first parameter,
                -- then pass in everything else
                Tuple = {Object(self, ...)}
            elseif Object.__SEAM_OBJECT and tostring(Object.__SEAM_OBJECT) == "New" then
                -- For New specifically, we want to actually put scope at the end. In the
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

            -- But yeah, let's add created things to the trove
            for _, ThisValue in Tuple do
                self.Trove:Add(ThisValue)
            end

            -- Unpack the tuple and return it ALLLLLLLL
            return unpack(Tuple)
        end
    end

    ScopeInstance = Compiler.CompileObject(ScopeObject)
    ScopeInstance.ScopedObjects = ScopedObjects
    ScopeInstance.Trove = Trove.new()
    ScopeInstance.ParentScope = nil

    return ScopeInstance
end

ScopeCompiled = Compiler.CompileConstructor(Scope) :: Types.ScopeConstructor

return ScopeCompiled
