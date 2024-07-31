-- Author: iGottic

--[=[
    @class DeclareComponent
    @since 1.0.0
]=]

local DeclareComponent = {}

-- Imports
local Modules = script.Parent.Parent.Modules
local ComponentsManager = require(Modules.ComponentsManager)

--[=[

]=]

function DeclareComponent:__call(ComponentName : string, Constructor : (any) -> any)
    ComponentsManager:PushComponent(ComponentName, Constructor)
end

-- --[=[
--     @ignore
-- ]=]

-- function DeclareComponent:__index(Index : string)
--     if Index == "__SPHI_OBJECT" then
--         return "DeclareComponent"
--     else
--         return nil
--     end
-- end

return setmetatable({}, DeclareComponent)