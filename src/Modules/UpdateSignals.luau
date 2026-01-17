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
else
    UpdateSignals.OnFrameUpdate = RunService.Heartbeat
    UpdateSignals.OnFramePreUpdate = RunService.Heartbeat
end

return UpdateSignals :: UpdateSignals