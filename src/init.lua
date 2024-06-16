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

--[=[
    @prop Children Children
    @within Sphi
]=]

Sphi.Children = require(Components.Children)
Sphi.children = Sphi.Children

return Sphi