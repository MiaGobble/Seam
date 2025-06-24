-- Imports
local Constructors = script.Parent.Parent.Constructors
local New = require(Constructors.New)
local OnEvent = require(Constructors.OnEvent)
local Computed = require(Constructors.Computed)
local Value = require(Constructors.Value)
local Tween = require(Constructors.Animation.Tween)

return function(ButtonObject : GuiButton)
    local State = Value("Idle")
    local ColorPropertyName = ButtonObject:IsA("ImageButton") and "ImageColor3" or "TextColor3"

    local H, S, V = Color3.toHSV(ButtonObject[ColorPropertyName] :: Color3)

    return New(ButtonObject, {
        AutoButtonColor = false,

        [ColorPropertyName] = Tween(Computed(function(Use)
            local State = Use(State)
            
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
            State.Value = "Press"
        end,
        
        [OnEvent "MouseButton1Up"] = function()
            State.Value = "Idle"
        end,
        
        [OnEvent "MouseEnter"] = function()
            State.Value = "Hover"
        end,
        
        [OnEvent "MouseLeave"] = function()
            State.Value = "Idle"
        end,
    })
end