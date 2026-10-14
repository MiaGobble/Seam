--[[
	Lune's Instance reflection does not include several signals Seam uses.
	These polyfills back those signals with the test signal, and the helpers
	below fire them when a spec mutates an instance.
]]

local roblox = require("@lune/roblox")
local createSignal = require("./signal")

local bags = setmetatable({}, { __mode = "k" })

local function bagFor(instance)
	local bag = bags[instance]
	if bag == nil then
		bag = {}
		bags[instance] = bag
	end

	return bag
end

local function signalFor(instance, name)
	local bag = bagFor(instance)
	local signal = bag[name]
	if signal == nil then
		signal = createSignal()
		bag[name] = signal
	end

	return signal
end

local EVENT_NAMES = {
	"Destroying",
	"AncestryChanged",
	"DescendantAdded",
	"DescendantRemoving",
	"Changed",
	"AttributeChanged",
	"ChildAdded",
	"ChildRemoved",
	"MouseButton1Click",
	"Activated",
}

for _, eventName in EVENT_NAMES do
	roblox.implementProperty("Instance", eventName, function(instance)
		return signalFor(instance, `event:{eventName}`)
	end)
end

roblox.implementMethod("Instance", "GetPropertyChangedSignal", function(instance, propertyName)
	return signalFor(instance, `prop:{propertyName}`)
end)

roblox.implementMethod("Instance", "GetAttributeChangedSignal", function(instance, attributeName)
	return signalFor(instance, `attr:{attributeName}`)
end)

local function concat(parts)
	local text = {}
	for index, value in parts do
		text[index] = tostring(value)
	end

	return table.concat(text, "\t")
end

return {
	signalFor = signalFor,
	changeProperty = function(instance, propertyName, value)
		instance[propertyName] = value
		signalFor(instance, `prop:{propertyName}`):Fire()
		signalFor(instance, "event:Changed"):Fire(propertyName)
	end,
	setAttribute = function(instance, attributeName, value)
		instance:SetAttribute(attributeName, value)
		signalFor(instance, `attr:{attributeName}`):Fire()
		signalFor(instance, "event:AttributeChanged"):Fire(attributeName)
	end,
	destroyInstance = function(instance)
		signalFor(instance, "event:Destroying"):Fire()
		instance:Destroy()
	end,
	fireEvent = function(instance, eventName, ...)
		signalFor(instance, `event:{eventName}`):Fire(...)
	end,
	concat = concat,
}
