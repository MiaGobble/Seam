-- Author: iGottic
-- note: i seperated the methods in its on file because it was getting big :v

local Methods = {}

-- Services
local CollectionService = game:GetService("CollectionService")

-- Imports
local Scope = require(script.Parent.Parent.Parent.Memory.Scope)

-- Constants
local API_MESSAGE_NAME = "SEAM_STYLESHEET_INSTANCE"

-- Variables
local ActiveStylesheets: { [Instance]: any } = {}

-- Types
type properties = { [any]: any }
type log = { [Instance]: properties }

-- Helpers
local function TrackResult(scope: Scope.ScopeInstance, result: any)
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

        for _, Item in result do
            TrackResult(scope, Item)
        end

        return
    end

    scope:AddObject(result)
end

local function CapturePropertyLog(instance: Instance, properties: properties, log: log)
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

local function ApplyProperties(instance: Instance, properties: properties, scope: Scope.ScopeInstance)
    for PropertyName, Value in properties do
        if typeof(PropertyName) == "table" and PropertyName.__SEAM_INDEX then
            TrackResult(scope, PropertyName(instance, Value))
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

local function ApplyRules(instance: Instance, rules: { StyleRule }, log: log, scope: Scope.ScopeInstance)
    for _, Rule in rules do
        if SelectorMatches(instance, Rule.Selector) then
            CapturePropertyLog(instance, Rule.Properties, log)
            ApplyProperties(instance, Rule.Properties, scope)
        end
    end
end

function Methods:Style(selector: string): (properties) -> ()
    return function(properties: properties)
        table.insert(self._rules, {
            Selector = selector,
            Properties = properties,
        })
    end
end

function Methods:Apply(root: Instance)
    local ActiveStyleSheet = ActiveStylesheets[root]
    if ActiveStyleSheet then
        ActiveStyleSheet:Unapply(root)
    end

    ActiveStylesheets[root] = self
    self._logs[root] = {}

    local ApplyScope = Scope({})
    self._scopes[root] = ApplyScope

    ApplyRules(root, self._rules, self._logs[root], ApplyScope)

    for _, Descendant in root:GetDescendants() do
        ApplyRules(Descendant, self._rules, self._logs[root], ApplyScope)
    end

    ApplyScope:AddObject(root.DescendantAdded:Connect(function(descendant: Instance)
        ApplyRules(descendant, self._rules, self._logs[root], ApplyScope)
    end))

    ApplyScope:AddObject(root.DescendantRemoving:Connect(function(descendant: Instance)
        if self._logs[root] then
            self._logs[root][descendant] = nil
        end
    end))

    ApplyScope:AddObject(root.Destroying:Connect(function()
        self:Unapply(root)
    end))
end

function Methods:Unapply(root: Instance)
    local PropertyLog = self._logs[root]
    if not PropertyLog then
        return
    end

    local ApplyScope = self._scopes[root]

    self._logs[root] = nil
    self._scopes[root] = nil
    ActiveStylesheets[root] = nil

    for InstanceObject, Properties in PropertyLog do
        for PropertyName, Value in Properties do
            pcall(function()
                (InstanceObject :: any)[PropertyName] = Value
            end)
        end
    end

    if ApplyScope then
        ApplyScope:Destroy()
    end
end

function Methods:Destroy()
    for root in self._logs do
        self:Unapply(root)
    end

    table.clear(self._rules)
end

return Methods
