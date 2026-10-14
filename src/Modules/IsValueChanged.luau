return function(oldValue : any, newValue : any) : boolean
	if typeof(oldValue) ~= typeof(newValue) then
		return true
	end

	return oldValue ~= newValue
end
