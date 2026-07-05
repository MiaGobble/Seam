-- Author: iGottic

local StyleSheet = {}

-- Imports
local Modules = script.Parent.Parent.Parent.Modules
local Methods = require(script.Methods)
local Types = require(script.Types)
local Symbol = require(Modules.Symbol)

-- Constants
local API_MESSAGE_NAME = "SEAM_STYLESHEET"

-- Variables
local DeclarationSymbol = Symbol.new("StyleSheet")
local StyleSheetInstanceSymbol = Symbol.new("StyleSheetInstance")
local StyleSheetGroupSymbol = Symbol.new("StyleSheetGroup")

-- Types extended
export type StyleRule = Types.StyleRule
export type StyleSheetDeclaration = Types.StyleSheetDeclaration
export type StyleSheetGroup = Types.StyleSheetGroup
export type StyleSheetInstance = Types.StyleSheetInstance

local StyleSheetInstanceMeta = {
    __index = function(_, key: string)
        if key == "__SEAM_STYLESHEET_INSTANCE" then
            return StyleSheetInstanceSymbol
        end

        return Methods[key]
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

        for _, Rule in pairs(activeStyleSheet) do
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