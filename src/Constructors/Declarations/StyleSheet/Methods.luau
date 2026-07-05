-- Author: iGottic
-- note: i seperated the methods in its on file because it was getting big :v

local Methods = {}

-- Services
local CollectionService = game:GetService("CollectionService")

-- Constants
local API_MESSAGE_NAME = "SEAM_STYLESHEET_INSTANCE"

-- Variables
local ActiveStylesheets: { [Instance]: any } = {}

-- Types
type properties = { [any]: any }
type log = { [Instance]: properties }

-- Helpers
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

local function ApplyProperties(instance: Instance, properties: properties)
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

local function ApplyRules(instance: Instance, rules: { StyleRule }, log: log)
    for _, Rule in rules do
        if SelectorMatches(instance, Rule.Selector) then
            CapturePropertyLog(instance, Rule.Properties, log)
            ApplyProperties(instance, Rule.Properties)
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

function Methods:Unapply(root: Instance)
    local PropertyLog = self._logs[root]
    if not PropertyLog then
        return
    end

    local Connections = self._connections[root]

    for InstanceObject, Properties in PropertyLog do
        for PropertyName, Value in Properties do
            pcall(function()
                (InstanceObject :: any)[PropertyName] = Value
            end)
        end
    end

    if Connections then
        for _, Connection in Connections do
            Connection:Disconnect()
        end
    end

    self._logs[root] = nil
    self._connections[root] = nil
    ActiveStylesheets[root] = nil
end

function Methods:Destroy()
    for root in self._logs do
        self:Unapply(root)
    end

    table.clear(self._rules)
end

return Methods