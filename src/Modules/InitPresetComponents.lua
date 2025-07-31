-- Author: iGottic

--[=[
    @class InitPresetComponents
    @since 0.0.1
]=]

-- Imports
local Constructors = script.Parent.Parent.Constructors
local DeclareComponent = require(Constructors.DeclareComponent)

-- Variables
local PresetComponents = script.Parent.Parent.PresetComponents

--[=[
    Initializes all preset components by declaring them in the ComponentsManager.
    This function should be called once at the start of the application to ensure all components are registered.
]=]

return function()
    for _, ComponentModule in PresetComponents:GetChildren() do
        DeclareComponent(ComponentModule.Name, require(ComponentModule))
    end
end