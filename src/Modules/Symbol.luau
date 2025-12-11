-- Author: iGottic

--[[
    @class Symbol
    @since 0.3.2
--]]

local Symbol = {}

function Symbol.new(Name : string)
    local self = newproxy(true)

    getmetatable(self).__tostring = function()
        return Name
    end

    return self
end

return Symbol