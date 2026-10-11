local Symbol = {}

-- Types
export type Symbol = typeof(newproxy(true))

function Symbol.new(name : string)
	local self = newproxy(true)

	getmetatable(self).__tostring = function()
		return name
	end

	return self
end

return Symbol
