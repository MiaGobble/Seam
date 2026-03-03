-- Author: iGottic

-- Constants
local DEPTH = 10

return function()
    local Traceback = ""
	
	for Index = 1, DEPTH do
		local ThisTraceback = debug.traceback(nil, Index + 1)
		
		if ThisTraceback:len() == 0 then
			break
		end
		
		Traceback ..= ThisTraceback .. "\n"
	end
	
	return Traceback
end
