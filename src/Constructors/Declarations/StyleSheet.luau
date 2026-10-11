local StyleSheet = {}

-- Types
type Properties = {[any] : any}
type Log = {[Instance] : Properties}

-- Constants
local API_MESSAGE_NAME = "SEAM_STYLESHEET"
local API_MESSAGE_NAME_INSTANCE = "SEAM_STYLESHEET_INSTANCE"

-- Services
local CollectionService = game:GetService("CollectionService")

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Types = require(Modules.Types)
local Compiler = require(Modules.Compiler)
local Symbol = require(Modules.Symbol)
local Scope = require(script.Parent.Parent.Memory.Scope)

-- Variables
local StyleSheetInstanceSymbol = Symbol.new("StyleSheetInstance")
local StyleSheetGroupSymbol = Symbol.new("StyleSheetGroup")
local ActiveStylesheets : {[Instance] : Types.StyleSheetInstance} = {}

StyleSheet.__SEAM_INDEX = Symbol.new("StyleSheet")
StyleSheet.__SEAM_CAN_BE_SCOPED = false

local function TrackResult(scope : Types.ScopeInstance, result : any)
	if result == nil then
		return
	end

	if typeof(result) == "Instance" then
		scope:AddObject(function()
			pcall(function()
				result:Destroy()
			end)
		end)

		return
	end

	if typeof(result) == "table" then
		if typeof(result.Destroy) == "function"
			or typeof(result.Disconnect) == "function"
			or typeof(result.destroy) == "function"
			or typeof(result.disconnect) == "function"
			or result.__SEAM_OBJECT
		then
			scope:AddObject(result)
			return
		end

		for _, item in result do
			TrackResult(scope, item)
		end

		return
	end

	scope:AddObject(result)
end

local function CapturePropertyLog(instance : Instance, properties : Properties, propertyLog : Log)
	if not propertyLog[instance] then
		propertyLog[instance] = {}
	end

	for propertyName in properties do
		if typeof(propertyName) ~= "string" then
			continue
		end

		if propertyLog[instance][propertyName] == nil then
			propertyLog[instance][propertyName] = (instance :: any)[propertyName]
		end
	end
end

local function ApplyProperties(instance : Instance, properties : Properties, scope : Types.ScopeInstance)
	for propertyName, value in properties do
		if typeof(propertyName) == "table" and propertyName.__SEAM_INDEX then
			TrackResult(scope, propertyName(instance, value))
			continue
		end

		if typeof(propertyName) ~= "string" then
			continue
		end

		local Success, ErrorMessage = pcall(function()
			(instance :: any)[propertyName] = value
		end)

		if not Success then
			warn(`[{API_MESSAGE_NAME_INSTANCE}] Could not apply '{propertyName}' on {instance:GetFullName()}: {ErrorMessage}`)
		end
	end
end

local function SelectorMatches(instance : Instance, selector : string) : boolean
	local Prefix = selector:sub(1, 1)
	local Suffix = selector:sub(-1)

	if Prefix == "@" then
		return instance.Name == selector:sub(2)
	elseif Prefix == "#" then
		return CollectionService:HasTag(instance, selector:sub(2))
	elseif Prefix == "$" then
		local Word = selector:sub(2)
		return instance.Name:sub(1, #Word) == Word
	elseif Suffix == "$" then
		local Word = selector:sub(1, -2)
		return instance.Name:sub(-#Word) == Word
	else
		return instance.ClassName == selector
	end
end

local function ApplyRules(instance : Instance, rules : {Types.StyleRule}, propertyLog : Log, scope : Types.ScopeInstance)
	for _, rule in rules do
		if SelectorMatches(instance, rule.Selector) then
			CapturePropertyLog(instance, rule.Properties, propertyLog)
			ApplyProperties(instance, rule.Properties, scope)
		end
	end
end

local function IsStyleSheetInstance(value : any) : boolean
	return typeof(value) == "table" and value.__SEAM_STYLESHEET_INSTANCE ~= nil
end

function StyleSheet.new() : Types.StyleSheetInstance
	local Rules : {Types.StyleRule} = {}
	local Logs : {[Instance] : Log} = {}
	local Scopes : {[Instance] : Types.ScopeInstance} = {}
	local StyleSheetObject : Types.ObjectDecompiled = {}

	StyleSheetObject.__SEAM_STYLESHEET_INSTANCE = StyleSheetInstanceSymbol

	function StyleSheetObject.Style(_ : Types.StyleSheetInstance, selector : string) : (Properties) -> ()
		return function(properties : Properties)
			table.insert(Rules, {
				Selector = selector,
				Properties = properties,
			})
		end
	end

	function StyleSheetObject.Apply(self : Types.StyleSheetInstance, root : Instance)
		local ActiveStyleSheet = ActiveStylesheets[root]
		if ActiveStyleSheet then
			ActiveStyleSheet:Unapply(root)
		end

		ActiveStylesheets[root] = self
		Logs[root] = {}

		local ApplyScope = Scope({})
		Scopes[root] = ApplyScope

		ApplyRules(root, Rules, Logs[root], ApplyScope)

		for _, descendant in root:GetDescendants() do
			ApplyRules(descendant, Rules, Logs[root], ApplyScope)
		end

		ApplyScope:AddObject(root.DescendantAdded:Connect(function(descendant : Instance)
			ApplyRules(descendant, Rules, Logs[root], ApplyScope)
		end))

		ApplyScope:AddObject(root.DescendantRemoving:Connect(function(descendant : Instance)
			if Logs[root] then
				Logs[root][descendant] = nil
			end
		end))

		ApplyScope:AddObject(root.Destroying:Connect(function()
			self:Unapply(root)
		end))
	end

	function StyleSheetObject.Unapply(_ : Types.StyleSheetInstance, root : Instance)
		local PropertyLog = Logs[root]
		if not PropertyLog then
			return
		end

		local ApplyScope = Scopes[root]

		Logs[root] = nil
		Scopes[root] = nil
		ActiveStylesheets[root] = nil

		for instanceObject, properties in PropertyLog do
			for propertyName, value in properties do
				pcall(function()
					(instanceObject :: any)[propertyName] = value
				end)
			end
		end

		if ApplyScope then
			ApplyScope:Destroy()
		end
	end

	function StyleSheetObject.Destroy(self : Types.StyleSheetInstance)
		for root in Logs do
			self:Unapply(root)
		end

		table.clear(Rules)
	end

	function StyleSheetObject.__CALLBACK(self : Types.StyleSheetInstance, object : Instance)
		self:Apply(object)
	end

	return Compiler.CompileObject(StyleSheetObject) :: Types.StyleSheetInstance
end

function StyleSheet.group(stylesheets : {[any] : Types.StyleSheetInstance}) : Types.StyleSheetGroup
	local StyleSheetGroupObject : Types.ObjectDecompiled = {}

	StyleSheetGroupObject.__SEAM_INDEX = StyleSheetGroupSymbol
	StyleSheetGroupObject.__SEAM_STYLESHEET_GROUP = StyleSheetGroupSymbol

	function StyleSheetGroupObject.__CALLBACK(_ : Types.StyleSheetGroup, instance : Instance, styleSheetKey : any)
		local StyleSheetObject = stylesheets[styleSheetKey]
		if not StyleSheetObject then
			warn(`[{API_MESSAGE_NAME}] No stylesheet found for key '{styleSheetKey}'`)
			return
		end

		StyleSheetObject:Apply(instance)
	end

	return Compiler.CompileObject(StyleSheetGroupObject) :: Types.StyleSheetGroup
end

function StyleSheet.__CALLBACK(_ : Types.ConstructorCompiled, object : Instance, activeStyleSheet : Types.StyleSheetInstance | Types.StyleSheetGroup | any)
	if IsStyleSheetInstance(activeStyleSheet) then
		activeStyleSheet:Apply(object)
		return
	end

	if typeof(activeStyleSheet) == "table" and activeStyleSheet.__SEAM_STYLESHEET_GROUP then
		warn(`[{API_MESSAGE_NAME}] StyleSheet groups require an explicit key. Use [Seam.StyleSheet.group(...)] = key`)
		return
	end

	if typeof(activeStyleSheet) == "table" and activeStyleSheet.__SEAM_STYLESHEET_INSTANCE == nil and #activeStyleSheet > 0 then
		local InlineStyleSheet = StyleSheet.new()

		for _, rule in pairs(activeStyleSheet) do
			if typeof(rule) == "table" and typeof(rule.Selector) == "string" and typeof(rule.Properties) == "table" then
				InlineStyleSheet:Style(rule.Selector)(rule.Properties)
			end
		end

		InlineStyleSheet:Apply(object)
		return
	end

	warn(`[{API_MESSAGE_NAME}] [Seam.StyleSheet] expects Seam.StyleSheet.new() or a rule array`)
end

return Compiler.CompileConstructor(StyleSheet) :: Types.StyleSheet
