-- Author: iGottic

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Symbol = require(Modules.Symbol)
local Compiler = require(Modules.Compiler)

-- Class
local Children : Types.ConstructorDecompiled = {}

Children.__SEAM_INDEX = Symbol.new("Children")
Children.__SEAM_CAN_BE_SCOPED = false

local function ApplyChildren(Parent : Instance, Children : {Types.Child} | Types.Child)
    -- This function just goes through the table and sets the parent of
    -- every thing in there to the determined parent.

    local ChildrenCreated = {}

    if typeof(Children) ~= "table" then
        if typeof(Children) == "Instance" then
            Children = {Children}
        else
            error("Invalid children type! Expected table or instance, got " .. typeof(Children))
        end
    end

    for _, Child in Children do
        if typeof(Child) ~= "Instance" then
            error("Invalid child type! Expected Instance, got " .. typeof(Child))
        end

        local Success = pcall(function()
            Child.Parent = Parent
        end)

        if Success then
            table.insert(ChildrenCreated, Child)
        end
    end

    return ChildrenCreated
end

local function GetOldChildren(OldChildren : {Instance}, NewChildren : {Instance})
    local DifferenceSet = {}

    for _, OldChild in OldChildren do
        if not table.find(NewChildren, OldChild) then
            table.insert(DifferenceSet, OldChild)
            continue
        end
    end

    return DifferenceSet
end

function Children.__CALLBACK(self : Types.ConstructorCompiled, Object : Instance, Children : Types.BaseState<any> | {any}) : {Destroy : () -> nil} | {Instance}
    if typeof(Children) == "table" then
        if Children.__SEAM_OBJECT and tostring(Children.__SEAM_OBJECT) == "ComputedInstance" then
            local ActiveChildren = ApplyChildren(Object, Children.Value)

            local Connection = Children.Changed:Connect(function()
                -- When computed updates, update the children
                
                local DifferenceSet = GetOldChildren(ActiveChildren, Children.Value)

                for _, Child in DifferenceSet do
                    Child:Destroy()
                end

                ActiveChildren = ApplyChildren(Object, Children.Value)
            end)

            -- Also make sure we clean things up when the parent is destroyed
            local DestroyingConnection = Object.Destroying:Connect(function()
                Connection:Disconnect()

                for _, Child in ActiveChildren do
                    Child:Destroy()
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

                    for _, Child in ActiveChildren do
                        pcall(function()
                            Child:Destroy()
                        end)
                    end

                    table.clear(ActiveChildren)
                end,
            }
        end
    end
    
    -- If it's not a computed instance, just apply the array of children to the parent
    return ApplyChildren(Object, Children)
end

return Compiler.CompileConstructor(Children) :: Types.Children