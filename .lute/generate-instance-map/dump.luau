--[[
	Reads the Roblox API dump and selects the classes and properties to generate types for.

	The dump comes from Roblox-Client-Tracker (https://github.com/MaximumADHD/Roblox-Client-Tracker). Only the fields
	this tool reads are typed below.

	Example:
	```luau
	const index = dump.indexClasses(dump.parse(json))
	const classNames = dump.selectClasses(index, { tags = { { value = "Service", negate = true } } })
	const properties = dump.writableProperties(index, "Frame")
	```
]]

const json = require("@std/json")

-- Types --
export type ValueType = {
	Name: string,
	Category: string,
}

export type MemberInfo = {
	MemberType: string,
	Name: string,
	ValueType: ValueType?,
	--- Properties use the table form, other members may use a single string
	Security: (string | { Read: string, Write: string })?,
	Tags: { string }?,
}

export type ClassInfo = {
	Name: string,
	Superclass: string,
	Members: { MemberInfo },
	Tags: { string }?,
}

export type Dump = {
	Classes: { ClassInfo },
}

export type ClassIndex = { [string]: ClassInfo }

export type TagFilter = {
	value: string,
	--- Whether classes with this tag are excluded instead of required
	negate: boolean,
}

export type ClassFilter = {
	--- Only these classes
	classes: { string }?,
	--- Only these classes and their subclasses
	superclasses: { string }?,
	tags: { TagFilter }?,
}

export type Property = {
	name: string,
	valueType: ValueType,
	--- The class that declares the property, which may be an ancestor of the class it was collected for
	owner: string,
}

-- Constants --

-- Properties with any of these tags can't be set from a script
const EXCLUDED_PROPERTY_TAGS = { "ReadOnly", "NotScriptable", "Deprecated" }

-- Functions --

const function hasTag(tags: { string }?, tag: string): boolean
	return tags ~= nil and table.find(tags, tag) ~= nil
end

const function setFrom(list: { string }): { [string]: true }
	const set: { [string]: true } = {}
	for _, value in list do
		set[value] = true
	end

	return set
end

--[[
	Checks that decoded JSON has the shape of an API dump.

	@return The dump, or nil and an error message.
]]
const function parse(decoded: json.Value): (Dump?, string?)
	if type(decoded) ~= "table" or type((decoded :: any).Classes) ~= "table" then
		return nil, "the API dump has no 'Classes' list"
	end

	return decoded :: any, nil
end

--[[
	Maps each class name in the dump to its class.
]]
const function indexClasses(dump: Dump): ClassIndex
	const index: ClassIndex = {}
	for _, class in dump.Classes do
		index[class.Name] = class
	end

	return index
end

--[[
	Returns whether `className` is one of `superclasses` or inherits from one of them.
]]
const function inheritsFromAny(index: ClassIndex, className: string, superclasses: { [string]: true }): boolean
	local node: ClassInfo? = index[className]
	while node do
		if superclasses[node.Name] then
			return true
		end
		node = index[node.Superclass]
	end

	return false
end

--[[
	Returns the names given in `filter.classes` and `filter.superclasses` that aren't in the dump.
]]
const function unknownClasses(index: ClassIndex, filter: ClassFilter): { string }
	const unknown: { string } = {}
	for _, list in { filter.classes or {}, filter.superclasses or {} } do
		for _, name in list do
			if not index[name] and not table.find(unknown, name) then
				table.insert(unknown, name)
			end
		end
	end

	return unknown
end

--[[
	Selects the classes that pass `filter`, sorted by name.

	A class passes when it's listed in `filter.classes`, or inherits from one of `filter.superclasses` (when neither is
	given, every class does), and it matches every tag filter.
]]
const function selectClasses(index: ClassIndex, filter: ClassFilter): { string }
	const classSet = if filter.classes then setFrom(filter.classes) else nil
	const superclassSet = if filter.superclasses then setFrom(filter.superclasses) else nil

	const selected: { string } = {}
	for className, class in index do
		const listed = (classSet and classSet[className])
			or (superclassSet and inheritsFromAny(index, className, superclassSet))
			or (classSet == nil and superclassSet == nil)
		if not listed then
			continue
		end

		local tagsMatch = true
		for _, tag in filter.tags or {} do
			if hasTag(class.Tags, tag.value) == tag.negate then
				tagsMatch = false
				break
			end
		end

		if tagsMatch then
			table.insert(selected, className)
		end
	end

	table.sort(selected)
	return selected
end

--[[
	Returns whether a script running at the default security level can set the property.
]]
const function isWritable(member: MemberInfo): boolean
	if member.MemberType ~= "Property" or member.ValueType == nil then
		return false
	end

	for _, tag in EXCLUDED_PROPERTY_TAGS do
		if hasTag(member.Tags, tag) then
			return false
		end
	end

	const security = member.Security
	if type(security) == "table" then
		return security.Read == "None" and security.Write == "None"
	end

	return security == nil or security == "None"
end

--[[
	Returns `className` followed by its ancestors, nearest first.
]]
const function ancestry(index: ClassIndex, className: string): { string }
	const chain: { string } = {}
	local node: ClassInfo? = index[className]
	while node do
		table.insert(chain, node.Name)
		node = index[node.Superclass]
	end

	return chain
end

--[[
	Collects the properties of `className` that a script can set, including inherited ones, sorted by name.

	A property declared again by a subclass is listed once, with the subclass's declaration.
]]
const function writableProperties(index: ClassIndex, className: string): { Property }
	const properties: { Property } = {}
	const seen: { [string]: true } = {}

	local node: ClassInfo? = index[className]
	while node do
		for _, member in node.Members do
			if not seen[member.Name] and isWritable(member) then
				seen[member.Name] = true
				table.insert(properties, {
					name = member.Name,
					valueType = member.ValueType :: ValueType,
					owner = node.Name,
				})
			end
		end
		node = index[node.Superclass]
	end

	table.sort(properties, function(a: Property, b: Property)
		return a.name < b.name
	end)

	return properties
end

return table.freeze({
	parse = parse,
	indexClasses = indexClasses,
	unknownClasses = unknownClasses,
	selectClasses = selectClasses,
	isWritable = isWritable,
	ancestry = ancestry,
	writableProperties = writableProperties,
})
