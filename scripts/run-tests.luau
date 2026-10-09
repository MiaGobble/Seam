--[[
    Lune entrypoint for Seam unit tests.

    Usage:
        lune run scripts/run-tests.luau
]]

local fs = require("@lune/fs")
local luau = require("@lune/luau")
local process = require("@lune/process")
local roblox = require("@lune/roblox")

local JestGlobals = require("../tests/lune/JestGlobals")
local loadPackage = require("../tests/lune/loadSeam")

local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect

local root = process.cwd
local package = loadPackage(`{root}/src`)

local function loadSpecs(directory: string)
    for _, entry in fs.readDir(directory) do
        local fullPath = `{directory}/{entry}`
        if fs.isDir(fullPath) then
            loadSpecs(fullPath)
        elseif string.sub(entry, -10) == ".spec.luau" then
            local chunk = luau.load(fs.readFile(fullPath), {
                debugName = fullPath,
            })
            local exported = chunk()
            if typeof(exported) == "function" then
                exported({
                    describe = describe,
                    it = it,
                    expect = expect,
                    Seam = package.Seam,
                    Compiler = package.requirePath({ "Modules", "Compiler" }),
                    Instance = roblox.Instance,
                })
            end
        end
    end
end

loadSpecs(`{root}/tests/specs`)

JestGlobals.run()
