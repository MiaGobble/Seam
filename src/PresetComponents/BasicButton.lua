-- Imports
local States = script.Parent.Parent.States
local New = require(States.New)
local OnEvent = require(States.OnEvent)
local Computed = require(States.Computed)
local Tween = require(States.Animation.Tween)

return function(ButtonObject : GuiButton)
    local State = "Idle"
    local ColorPropertyName = ButtonObject:IsA("ImageButton") and "ImageColor3" or "TextColor3"

    local H, S, V = Color3.toHSV(ButtonObject[ColorPropertyName] :: Color3)

    return New(ButtonObject, {
        AutoButtonColor = false,

        [ColorPropertyName] = Tween(Computed(function()
            if State == "Idle" then
                return Color3.fromHSV(H, S, V)
            elseif State == "Hover" then
                return Color3.fromHSV(H, S, V * 0.9)
            elseif State == "Press" then
                return Color3.fromHSV(H, S, V * 0.75)
            end

            error("Invalid state: " .. State)
        end), TweenInfo.new(0.1)),

        [OnEvent "MouseButton1Down"] = function()
            State = "Press"
        end,
        
        [OnEvent "MouseButton1Up"] = function()
            State = "Idle"
        end,
        
        [OnEvent "MouseEnter"] = function()
            State = "Hover"
        end,
        
        [OnEvent "MouseLeave"] = function()
            State = "Idle"
        end,
    })
end