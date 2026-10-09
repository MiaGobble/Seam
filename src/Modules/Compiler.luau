local Compiler = {}

-- Imports
local Types = require(script.Parent.Types)

function Compiler.CompileConstructor(constructorDecompiled : Types.ConstructorDecompiled) : Types.ConstructorCompiled
    if not constructorDecompiled.Callback then
        error("Constructor must have a Callback function")
    end

    local BackendIndexes = {}
    local Callback = constructorDecompiled.Callback
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

return Compiler