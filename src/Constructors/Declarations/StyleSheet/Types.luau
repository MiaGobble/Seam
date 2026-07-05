-- note: i seperated the methods in its on file because it was getting big :v

local Modules = script.Parent.Parent.Parent.Parent.Modules
local Symbol = require(Modules.Symbol)

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

return {}