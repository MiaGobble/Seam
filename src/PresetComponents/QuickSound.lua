-- Services
local SoundService = game:GetService("SoundService")

-- Imports
local States = script.Parent.Parent.States
local New = require(States.New)

return function(Sound : Sound)
    New(Sound, {
        Parent = SoundService,
        PlayOnRemove = true,
    }):Destroy()
end