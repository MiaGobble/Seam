local Compiler = {}

-- Constants
local CALLBACK_INDEX = "__CALLBACK"
local INDEX_CALLBACK = "__INDEX"
local NEWINDEX_CALLBACK = "__NEWINDEX"

-- Imports
local Types = require(script.Parent.Types)

local function IsReservedIndex(index : any) : boolean
    return index == CALLBACK_INDEX or index == INDEX_CALLBACK or index == NEWINDEX_CALLBACK
end

function Compiler.CompileConstructor(constructorDecompiled : Types.ConstructorDecompiled) : Types.ConstructorCompiled
    if not constructorDecompiled[CALLBACK_INDEX] then
        error(`Constructor must have a {CALLBACK_INDEX} function`)
    end

    local BackendIndexes = {}
    local Callback = constructorDecompiled[CALLBACK_INDEX]
    local Meta = {}

    for index, value in constructorDecompiled do
        if not IsReservedIndex(index) then
            BackendIndexes[index] = value
        end
    end

    function Meta:__call(...)
        return Callback(self, ...)
    end

    function Meta:__index(index : string)
        if BackendIndexes[index] ~= nil then
            return BackendIndexes[index]
        end

        return nil
    end

    return setmetatable({}, Meta)
end

function Compiler.CompileObject(objectDecompiled : Types.ObjectDecompiled) : Types.ObjectCompiled
    local BackendIndexes = {}
    local Callback = objectDecompiled[CALLBACK_INDEX]
    local IndexCallback = objectDecompiled[INDEX_CALLBACK]
    local NewIndexCallback = objectDecompiled[NEWINDEX_CALLBACK]
    local Meta = {}

    for index, value in objectDecompiled do
        if not IsReservedIndex(index) then
            BackendIndexes[index] = value
        end
    end

    if Callback then
        function Meta:__call(...)
            return Callback(self, ...)
        end
    end

    function Meta:__index(index : string)
        if BackendIndexes[index] ~= nil then
            return BackendIndexes[index]
        end

        if IndexCallback then
            return IndexCallback(self, index)
        end

        return nil
    end

    if NewIndexCallback then
        function Meta:__newindex(index : string, value : any)
            return NewIndexCallback(self, index, value)
        end
    end

    return setmetatable({}, Meta)
end

return Compiler
