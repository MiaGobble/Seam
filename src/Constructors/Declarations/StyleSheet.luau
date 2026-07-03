-- Author: iGottic

local StyleSheet = {}

-- Services
local CollectionService = game:GetService("CollectionService")

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Symbol = require(Modules.Symbol)

-- Constants
local API_MESSAGE_NAME = "SEAM_STYLESHEET"

-- Variables
local DeclarationSymbol = Symbol.new("StyleSheet")
local StyleSheetInstanceSymbol = Symbol.new("StyleSheetInstance")
local StyleSheetGroupSymbol = Symbol.new("StyleSheetGroup")
local ActiveStylesheets: { [Instance]: any } = {}

-- Types
export type StyleRule = {
    Selector: string,
    Properties: { [any]: any },
}

export type StyleSheetInstance = {
    Style: (self: StyleSheetInstance, selector: string) -> ({ [any]: any }) -> (),
    Apply: (self: StyleSheetInstance, root: Instance) -> (),
    Unapply: (self: StyleSheetInstance, root: Instance) -> (),
    Destroy: (self: StyleSheetInstance) -> (),
    __SEAM_STYLESHEET_INSTANCE: Symbol.Symbol,
}

export type StyleSheetGroup = {
    __SEAM_INDEX: Symbol.Symbol,
    __SEAM_STYLESHEET_GROUP: Symbol.Symbol,
}

export type StyleSheetDeclaration = ((Object: Instance, ActiveStyleSheet: StyleSheetInstance | StyleSheetGroup | any) -> ()) & {
    new: () -> StyleSheetInstance,
    group: (stylesheets: { [any]: StyleSheetInstance }) -> StyleSheetGroup,
}

local function CapturePropertyLog(instance: Instance, properties: { [any]: any }, log: { [Instance]: { [string]: any } })
    if not log[instance] then
        log[instance] = {}
    end

    for PropertyName in properties do
        if typeof(PropertyName) ~= "string" then
            continue
        end

        if log[instance][PropertyName] == nil then
            log[instance][PropertyName] = (instance :: any)[PropertyName]
        end
    end
end

local function ApplyProperties(instance: Instance, properties: { [any]: any })
    for PropertyName, Value in properties do
        if typeof(PropertyName) == "table" and PropertyName.__SEAM_INDEX then
            PropertyName(instance, Value)
            continue
        end

        if typeof(PropertyName) ~= "string" then
            continue
        end

        local Success, ErrorMessage = pcall(function()
            (instance :: any)[PropertyName] = Value
        end)

        if not Success then
            warn(`[{API_MESSAGE_NAME}] Could not apply '{PropertyName}' on {instance:GetFullName()}: {ErrorMessage}`)
        end
    end
end

local function SelectorMatches(instance: Instance, selector: string): boolean
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

local function ApplyRules(instance: Instance, rules: { StyleRule }, log: { [Instance]: { [string]: any } })
    for _, Rule in rules do
        if SelectorMatches(instance, Rule.Selector) then
            CapturePropertyLog(instance, Rule.Properties, log)
            ApplyProperties(instance, Rule.Properties)
        end
    end
end

local StyleSheetMethods = {}

function StyleSheetMethods:Style(selector: string)
    return function(properties: { [any]: any })
        table.insert(self._rules, {
            Selector = selector,
            Properties = properties,
        })
    end
end

function StyleSheetMethods:Apply(root: Instance)
    local ActiveStyleSheet = ActiveStylesheets[root]
    if ActiveStyleSheet and ActiveStyleSheet ~= self then
        ActiveStyleSheet:Unapply(root)
    end

    ActiveStylesheets[root] = self
    self._logs[root] = {}
    self._connections[root] = {}

    ApplyRules(root, self._rules, self._logs[root])

    for _, Descendant in root:GetDescendants() do
        ApplyRules(Descendant, self._rules, self._logs[root])
    end

    local DescendantAddedConnection = root.DescendantAdded:Connect(function(descendant: Instance)
        ApplyRules(descendant, self._rules, self._logs[root])
    end)

    local DescendantRemovingConnection = root.DescendantRemoving:Connect(function(descendant: Instance)
        if self._logs[root] then
            self._logs[root][descendant] = nil
        end
    end)

    local DestroyingConnection = root.Destroying:Connect(function()
        self:Unapply(root)
    end)

    table.insert(self._connections[root], DescendantAddedConnection)
    table.insert(self._connections[root], DescendantRemovingConnection)
    table.insert(self._connections[root], DestroyingConnection)
end

function StyleSheetMethods:Unapply(root: Instance)
    local PropertyLog = self._logs[root]
    if not PropertyLog then
        return
    end

    for InstanceObject, Properties in PropertyLog do
        for PropertyName, Value in Properties do
            pcall(function()
                (InstanceObject :: any)[PropertyName] = Value
            end)
        end
    end

    for _, Connection in self._connections[root] do
        Connection:Disconnect()
    end

    self._logs[root] = nil
    self._connections[root] = nil
    ActiveStylesheets[root] = nil
end

function StyleSheetMethods:Destroy()
    for root in self._logs do
        self:Unapply(root)
    end

    table.clear(self._rules)
end

local StyleSheetInstanceMeta = {
    __index = function(_, key: string)
        if key == "__SEAM_STYLESHEET_INSTANCE" then
            return StyleSheetInstanceSymbol
        end

        return StyleSheetMethods[key]
    end,

    __call = function(self, object: Instance)
        self:Apply(object)
    end,
}

local function IsStyleSheetInstance(value: any): boolean
    return typeof(value) == "table" and value.__SEAM_STYLESHEET_INSTANCE ~= nil
end

function StyleSheet.new(): StyleSheetInstance
    return setmetatable({
        _rules = {},
        _logs = {},
        _connections = {},
    }, StyleSheetInstanceMeta) :: any
end

function StyleSheet.group(stylesheets: { [any]: StyleSheetInstance }): StyleSheetGroup
    return setmetatable({}, {
        __index = function(_, key: string)
            if key == "__SEAM_INDEX" then
                return StyleSheetGroupSymbol
            elseif key == "__SEAM_STYLESHEET_GROUP" then
                return StyleSheetGroupSymbol
            end

            return nil
        end,

        __call = function(_, instance: Instance, styleSheetKey: any)
            local StyleSheetObject = stylesheets[styleSheetKey]
            if not StyleSheetObject then
                warn(`[{API_MESSAGE_NAME}] No stylesheet found for key '{styleSheetKey}'`)
                return
            end

            StyleSheetObject:Apply(instance)
        end,
    }) :: any
end

function StyleSheet:__call(object: Instance, activeStyleSheet: StyleSheetInstance | StyleSheetGroup | any)
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

        for _, Rule in activeStyleSheet do
            if typeof(Rule) == "table" and typeof(Rule.Selector) == "string" and typeof(Rule.Properties) == "table" then
                InlineStyleSheet:Style(Rule.Selector)(Rule.Properties)
            end
        end

        InlineStyleSheet:Apply(object)
        return
    end

    warn(`[{API_MESSAGE_NAME}] [Seam.StyleSheet] expects Seam.StyleSheet.new() or a rule array`)
end

function StyleSheet:__index(index: string)
    if index == "__SEAM_INDEX" then
        return DeclarationSymbol
    elseif index == "__SEAM_CAN_BE_SCOPED" then
        return false
    end

    return rawget(StyleSheet, index)
end

local Meta = setmetatable({}, StyleSheet)

return Meta :: StyleSheetDeclaration