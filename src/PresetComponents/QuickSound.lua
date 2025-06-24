-- Services
local SoundService = game:GetService("SoundService")

-- Imports
local Constructors = script.Parent.Parent.Constructors
local New = require(Constructors.New)

return function(Sound : Sound)
    New(Sound, {
        Parent = SoundService,
        PlayOnRemove = true,
    }):Destroy()
end