-- Author: iGottic

--[=[
    @class Tags
    @since 0.3.1
]=]

local Tags = {}

-- Types
export type Tags = (Object : Instance, AddedTags : {string}) -> nil

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Symbol = require(Modules.Symbol)

-- Variables
local ClassSymbol = Symbol.new("Tags")

--[=[
    Adds tags to an instance
]=]

function Tags:__call(Object : Instance, AddedTags : {string})
    for _, Tag in AddedTags do -- Super simple iteration through strings
        Object:AddTag(Tag)
    end
end

function Tags:__index(Index : string)
    if Index == "__SEAM_INDEX" then
        return ClassSymbol
    elseif Index == "__SEAM_CAN_BE_SCOPED" then
        return false
    else
        return nil
    end
end

local Meta = setmetatable({}, Tags)

return Meta :: Tags