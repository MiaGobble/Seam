-- Author: iGottic

local UpdateSignals = {}

-- Types
type UpdateSignals = {
    OnFrameUpdate : RBXScriptSignal,
    OnFramePreUpdate : RBXScriptSignal,
}

-- Services
local RunService = game:GetService("RunService")

if RunService:IsClient() then
    UpdateSignals.OnFrameUpdate = RunService.RenderStepped
    UpdateSignals.OnFramePreUpdate = RunService.PreRender
else -- If we're using the server, always use RunService.Heartbeat
    UpdateSignals.OnFrameUpdate = RunService.Heartbeat
    UpdateSignals.OnFramePreUpdate = RunService.Heartbeat
end

return UpdateSignals :: UpdateSignals