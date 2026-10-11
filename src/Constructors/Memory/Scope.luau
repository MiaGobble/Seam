local Scope = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Bucket = require(Modules.Bucket)
local Symbol = require(Modules.Symbol)
local CreateDeepTraceback = require(Modules.CreateDeepTraceback)

-- Variables
local ScopeCompiled : Types.ScopeConstructor

Scope.__SEAM_OBJECT = Symbol.new("Scope")
Scope.__SEAM_CAN_BE_SCOPED = true

function Scope.__CALLBACK(_ : Types.ConstructorCompiled, scopedObjects : {[string] : any})
	-- Scopes have been a headache to get working, since I'm a dumdum

	local IsDestroyed = false
	local ScopeInstance : Types.ObjectCompiled

	if not scopedObjects then
		scopedObjects = {}
	end

	scopedObjects = table.clone(scopedObjects)

	local ScopeObject : Types.ObjectDecompiled = {
		__SEAM_OBJECT = Symbol.new("Scope"),
	}

	function ScopeObject.InnerScope(self : Types.ObjectCompiled, newScopedObjects : {[string] : any}?)
		if IsDestroyed then
			warn(`Attempted to create inner scope but scope is already destroyed: {CreateDeepTraceback()}`)
			return
		end

		-- Default to a blank table
		if newScopedObjects == nil then
			newScopedObjects = {}
		end

		-- Take the current scoped objects and copy them to the new table
		for index, object in self.ScopedObjects do
			newScopedObjects[index] = object
		end

		local NewScope = ScopeCompiled(newScopedObjects) -- Make a new scope
		NewScope.ParentScope = self
		self.Bucket:Add(NewScope) -- Add the new sub-scope to the parent bucket

		return NewScope
	end

	function ScopeObject.AddObject<T>(self : Types.ObjectCompiled, object : T)
		if IsDestroyed then
			warn(`Attempted to add object to scope but scope is already destroyed: {CreateDeepTraceback()}`)
			return
		end

		return self.Bucket:Add(object)
	end

	function ScopeObject.RemoveObject(self : Types.ObjectCompiled, object : any)
		if IsDestroyed then
			warn(`Attempted to remove object from scope but scope is already destroyed: {CreateDeepTraceback()}`)
			return
		end

		self.Bucket:Remove(object)
	end

	function ScopeObject.Destroy(self : Types.ObjectCompiled)
		if IsDestroyed then
			warn(`Attempted to destroy scope but scope is already destroyed: {CreateDeepTraceback()}`)
			return
		end

		IsDestroyed = true
		self.Bucket:Destroy()
		self.Bucket = nil

		local ParentScope = rawget(self, "ParentScope")

		if ParentScope then
			-- When an inner scope is destroyed, remove it from the parent scope
			local ParentBucket = rawget(ParentScope, "Bucket")

			if ParentBucket and not ParentBucket.IsCleaning then
				ParentBucket:Remove(self)
			end

			rawset(self, "ParentScope", nil)
		end
	end

	function ScopeObject.__INDEX(self : Types.ObjectCompiled, key : string)
		if IsDestroyed then
			warn(`Attempted to index a scope with {key} but scope is already destroyed: {CreateDeepTraceback()}`)
			return
		end

		if not key then
			warn(`Attempt to index a scope with nil{"\n"}{CreateDeepTraceback()}`)
			return
		end

		local Object = scopedObjects[key]

		if Object == nil then
			warn(`Attempt to index a scope with {key} when it does not exist in scope{"\n"}{CreateDeepTraceback()}`)
			return nil
		end

		if typeof(Object) ~= "function" and (typeof(Object) ~= "table" or not Object.__SEAM_CAN_BE_SCOPED) then
			if Object.__SEAM_OBJECT or Object.__SEAM_INDEX then
				-- If something from seam has __SEAM_CAN_BE_SCOPED (meaning it can't be scoped) as false,
				-- then we should error what specifically the user tried to use
				error(`{tostring(Object.__SEAM_OBJECT or Object.__SEAM_INDEX)} is not a valid scopable Seam object`)
			else
				-- Idk just error
				error("Object is not a valid scopable Seam object")
			end
		end

		return function(_, ...)
			if not self.Bucket then -- If the bucket instance doesn't exist, the scope is likely destroyed
				warn(`Attempted to use something in scope ({key}) but scope is already destroyed: {CreateDeepTraceback()}`)
				return
			end

			-- Seam things are called as functions, so this is a wrapper
			-- function that puts any created instances into the bucket
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

			-- But yeah, let's add created things to the bucket
			for _, thisValue in Tuple do
				self.Bucket:Add(thisValue)
			end

			-- Unpack the tuple and return it ALLLLLLLL
			return unpack(Tuple)
		end
	end

	ScopeInstance = Compiler.CompileObject(ScopeObject)
	ScopeInstance.ScopedObjects = scopedObjects
	ScopeInstance.Bucket = Bucket.new()
	ScopeInstance.ParentScope = nil

	return ScopeInstance
end

ScopeCompiled = Compiler.CompileConstructor(Scope) :: Types.ScopeConstructor

return ScopeCompiled
