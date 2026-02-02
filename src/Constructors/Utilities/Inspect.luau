-- Author: iGottic

local Inspect = {}

-- Types
export type Inspect = (Object : any, DebugName : string) -> RBXScriptConnection

function Inspect:__call(Object : any, DebugName : string)
    if not DebugName then
        error("Expected DebugName, got nil")
    end

    return (Object.Changed :: RBXScriptSignal):Connect(function(PropertyName : string)
        if not PropertyName then
            print(`SEAM_INSPECT | {DebugName} | Value changed, unknown property that changed`)
            return
        end

        print(`SEAM_INSPECT | {DebugName} | Value changed to {Object[PropertyName]}`)
    end)
end

function Inspect:__index(Index : string)
    if Index == "__SEAM_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

local Meta = setmetatable({}, Inspect)

return Meta :: Inspect