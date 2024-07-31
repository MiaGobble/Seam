-- Author: iGottic

--[=[
    @class DeclareComponent
    @since 1.0.0
]=]

local DeclareComponent = {}

-- Types
type ComponentConstructor = (HydratedObject : Instance, ...any) -> any
type DeclareComponent = (ComponentName : string, Constructor : ComponentConstructor) -> nil

-- Imports
local Modules = script.Parent.Parent.Modules
local ComponentsManager = require(Modules.ComponentsManager)

--[=[
    Declares a new component

    @param ComponentName string -- The component name
    @param Constructor function -- The constructor function
]=]

function DeclareComponent:__call(ComponentName : string, Constructor : ComponentConstructor)
    ComponentsManager:PushComponent(ComponentName, Constructor)
end

local Meta = setmetatable({}, DeclareComponent)

return Meta :: DeclareComponent