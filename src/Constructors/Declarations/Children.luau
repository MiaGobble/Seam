local Children = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Symbol = require(Modules.Symbol)
local Compiler = require(Modules.Compiler)

Children.__SEAM_INDEX = Symbol.new("Children")
Children.__SEAM_CAN_BE_SCOPED = false

local function ApplyChildren(parent : Instance, children : {Types.Child} | Types.Child)
	-- This function just goes through the table and sets the parent of
	-- every thing in there to the determined parent.

	local ChildrenCreated = {}

	if typeof(children) ~= "table" then
		if typeof(children) == "Instance" then
			children = {children}
		else
			error(`Invalid children type! Expected table or instance, got {typeof(children)}`)
		end
	end

	for _, child in children do
		if typeof(child) ~= "Instance" then
			error(`Invalid child type! Expected Instance, got {typeof(child)}`)
		end

		local Success = pcall(function()
			child.Parent = parent
		end)

		if Success then
			table.insert(ChildrenCreated, child)
		end
	end

	return ChildrenCreated
end

local function GetOldChildren(oldChildren : {Instance}, newChildren : {Instance})
	local DifferenceSet = {}

	for _, oldChild in oldChildren do
		if not table.find(newChildren, oldChild) then
			table.insert(DifferenceSet, oldChild)
			continue
		end
	end

	return DifferenceSet
end

function Children.__CALLBACK(self : Types.ConstructorCompiled, object : Instance, children : Types.BaseState<any> | {any}) : {Destroy : () -> nil} | {Instance}
	if typeof(children) == "table" then
		if children.__SEAM_OBJECT and tostring(children.__SEAM_OBJECT) == "ComputedInstance" then
			local ActiveChildren = ApplyChildren(object, children.Value)

			local Connection = children.Changed:Connect(function()
				-- When computed updates, update the children

				local DifferenceSet = GetOldChildren(ActiveChildren, children.Value)

				for _, child in DifferenceSet do
					child:Destroy()
				end

				ActiveChildren = ApplyChildren(object, children.Value)
			end)

			-- Also make sure we clean things up when the parent is destroyed
			local DestroyingConnection = object.Destroying:Connect(function()
				Connection:Disconnect()

				for _, child in ActiveChildren do
					child:Destroy()
				end
			end)

			return {
				Destroy = function()
					if Connection.Connected then
						Connection:Disconnect()
					end

					if DestroyingConnection.Connected then
						DestroyingConnection:Disconnect()
					end

					for _, child in ActiveChildren do
						pcall(function()
							child:Destroy()
						end)
					end

					table.clear(ActiveChildren)
				end,
			}
		end
	end

	-- If it's not a computed instance, just apply the array of children to the parent
	return ApplyChildren(object, children)
end

return Compiler.CompileConstructor(Children) :: Types.Children
