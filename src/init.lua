--[=[
    The main framework module for Sphi.
    @class Sphi
]=]

local Sphi = {}

-- Variables
local Components = script.Components

--[=[
    @prop New New
    @within Sphi
]=]

Sphi.New = require(Components.New)
Sphi.new = Sphi.New

return Sphi