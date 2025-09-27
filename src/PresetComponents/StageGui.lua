-- Services
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local PlayersService = game:GetService("Players")

-- Imports
local Seam = require(ReplicatedFirst.Seam)
local New = Seam.New

-- Variables
local Player = PlayersService.LocalPlayer

return function(Gui : ScreenGui)
	return New(Gui, {
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		Parent = Player.PlayerGui
	})
end