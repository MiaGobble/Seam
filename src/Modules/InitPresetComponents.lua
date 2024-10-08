-- Imports
local States = script.Parent.Parent.States
local DeclareComponent = require(States.DeclareComponent)

-- Variables
local PresetComponents = script.Parent.Parent.PresetComponents

return function()
    for _, ComponentModule in ipairs(PresetComponents:GetChildren()) do
        DeclareComponent(ComponentModule.Name, require(ComponentModule))
    end
end