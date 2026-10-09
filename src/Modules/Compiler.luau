local Compiler = {}

-- Constants
local CALLBACK_INDEX = "__CALLBACK"

-- Imports
local Types = require(script.Parent.Types)

function Compiler.CompileConstructor(constructorDecompiled : Types.ConstructorDecompiled) : Types.ConstructorCompiled
    if not constructorDecompiled[CALLBACK_INDEX] then
        error(`Constructor must have a {CALLBACK_INDEX} function`)
    end

    local BackendIndexes = {}
    local Callback = constructorDecompiled[CALLBACK_INDEX]
    local Meta = {}

    for index, value in constructorDecompiled do
        if typeof(index) == "string" and typeof(value) ~= "function" then
            BackendIndexes[index] = value
        end
    end

    function Meta:__call(...)
        return Callback(self, ...)
    end

    function Meta:__index(index : string)
        if BackendIndexes[index] then
            return BackendIndexes[index]
        end

        return nil
    end

    return setmetatable({}, Meta)
end

function Compiler.CompileObject(objectDecompiled : Types.ObjectDecompiled) : Types.ObjectCompiled
    if not objectDecompiled[CALLBACK_INDEX] then
        error(`Object must have a {CALLBACK_INDEX} function`)
    end

    local BackendIndexes = {}
    local Callback = objectDecompiled[CALLBACK_INDEX]
    local Meta = {}

    for index, value in objectDecompiled do
        if index ~= CALLBACK_INDEX then
            BackendIndexes[index] = value
        end
    end

    function Meta:__call(...)
        return Callback(self, ...)
    end

    function Meta:__index(index : string)
        if BackendIndexes[index] then
            return BackendIndexes[index]
        end

        return nil
    end

    return setmetatable({}, Meta)
end

return Compiler