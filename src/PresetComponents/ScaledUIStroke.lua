-- Constants
local BASE_RATIO = Vector2.new(1920, 1080)
local BASE_MAGNITUDE = (BASE_RATIO / BASE_RATIO).Magnitude
local TICK_RATE = 1 / 1

-- Services
local RunService = game:GetService("RunService")

-- -- Imports
-- local States = script.Parent.Parent.States
-- local New = require(States.New)

-- Variables
local Camera = workspace.CurrentCamera
local LastTick = os.clock()
local Strokes = {}

local function Init()
    RunService.RenderStepped:Connect(function()
        if os.clock() - LastTick < TICK_RATE then
            return
        else
            LastTick = os.clock()
        end

        for Object, Thickness in Strokes do
            if not Object:IsDescendantOf(game) then
                Strokes[Object] = nil
                continue
            end

            local Scale = (Camera.ViewportSize / BASE_RATIO).Magnitude / BASE_MAGNITUDE
            Object.Thickness = Thickness * Scale
        end
    end)
end

return function(StrokeObject : UIStroke)
    local OriginalThickness = StrokeObject.Thickness
    Strokes[StrokeObject] = OriginalThickness

    return StrokeObject
end, Init()