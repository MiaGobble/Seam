-- Services
local PlayersService = game:GetService("Players")

-- Imports
local Constructors = script.Parent.Parent.Constructors
local New = require(Constructors.New)

-- Variables
local Player = PlayersService.LocalPlayer

return function(Gui : ScreenGui)
	return New(Gui, {
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		Parent = Player.PlayerGui
	})
end