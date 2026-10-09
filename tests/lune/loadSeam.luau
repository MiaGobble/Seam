local fs = require("@lune/fs")
local luau = require("@lune/luau")
local roblox = require("@lune/roblox")
local task = require("@lune/task")
local createSignal = require("./signal")

export type ModuleNode = {
    name: string,
    kind: "folder" | "module",
    path: string?,
    parent: ModuleNode?,
    children: { [string]: ModuleNode },
    source: string?,
    result: any?,
    loading: boolean?,
    proxy: any?,
}

local function createGame()
    local heartbeat = createSignal()
    local renderStepped = createSignal()
    local preRender = createSignal()
    local loaded = createSignal()

    local runService = {
        Heartbeat = heartbeat,
        RenderStepped = renderStepped,
        PreRender = preRender,
        IsServer = function()
            return true
        end,
        IsClient = function()
            return false
        end,
        BindToRenderStep = function() end,
        UnbindFromRenderStep = function() end,
    }

    local services = {
        RunService = runService,
        CollectionService = {
            HasTag = function()
                return false
            end,
            AddTag = function() end,
            RemoveTag = function() end,
        },
        Debris = {
            AddItem = function() end,
        },
        TweenService = {
            GetValue = function(_, alpha)
                return alpha
            end,
        },
    }

    return {
        GetService = function(_, name: string)
            local service = services[name]
            if not service then
                error(`Unknown service '{name}' in Lune test environment`)
            end
            return service
        end,
        IsLoaded = function()
            return true
        end,
        Loaded = loaded,
    }
end

local function buildTree(directory: string, name: string, parent: ModuleNode?): ModuleNode
    local node: ModuleNode = {
        name = name,
        kind = "folder",
        parent = parent,
        children = {},
    }

    local initPath = `{directory}/init.luau`
    if fs.isFile(initPath) then
        node.kind = "module"
        node.path = initPath
        node.source = fs.readFile(initPath)
    end

    for _, entry in fs.readDir(directory) do
        if entry == "init.luau" then
            continue
        end

        local fullPath = `{directory}/{entry}`
        if fs.isDir(fullPath) then
            node.children[entry] = buildTree(fullPath, entry, node)
        elseif string.sub(entry, -5) == ".luau" then
            local moduleName = string.sub(entry, 1, -6)
            node.children[moduleName] = {
                name = moduleName,
                kind = "module",
                path = fullPath,
                parent = node,
                children = {},
                source = fs.readFile(fullPath),
            }
        end
    end

    return node
end

local function loadPackage(srcDirectory: string)
    local game = createGame()
    local root = buildTree(srcDirectory, "Seam", nil)
    if root.kind ~= "module" then
        error(`Expected {srcDirectory}/init.luau`)
    end

    local proxyToNode: { [any]: ModuleNode } = {}

    local function getProxy(node: ModuleNode): any
        if node.proxy then
            return node.proxy
        end

        local proxy = {}
        node.proxy = proxy
        proxyToNode[proxy] = node

        setmetatable(proxy, {
            __index = function(_, key: string)
                if key == "Name" then
                    return node.name
                elseif key == "Parent" then
                    return if node.parent then getProxy(node.parent) else nil
                elseif key == "WaitForChild" or key == "FindFirstChild" then
                    return function(_, childName: string)
                        local child = node.children[childName]
                        if not child then
                            error(`{node.name} has no child '{childName}'`, 2)
                        end
                        return getProxy(child)
                    end
                elseif key == "GetChildren" then
                    return function()
                        local children = {}
                        for _, child in node.children do
                            table.insert(children, getProxy(child))
                        end
                        return children
                    end
                end

                local child = node.children[key]
                if child then
                    return getProxy(child)
                end

                return nil
            end,
            __tostring = function()
                return node.path or node.name
            end,
        })

        return proxy
    end

    local function requireModule(node: ModuleNode): any
        if node.kind ~= "module" then
            error(`Cannot require folder '{node.name}'`)
        end

        if node.result ~= nil then
            return if node.result == true then nil else node.result
        end

        if node.loading then
            error(`Circular require while loading {node.path}`)
        end

        node.loading = true

        local scriptProxy = getProxy(node)
        local environment = {
            game = game,
            script = scriptProxy,
            Instance = roblox.Instance,
            task = task,
            typeof = typeof,
            print = print,
            warn = warn,
            error = error,
            assert = assert,
            pcall = pcall,
            xpcall = xpcall,
            pairs = pairs,
            ipairs = ipairs,
            next = next,
            select = select,
            unpack = unpack,
            table = table,
            string = string,
            math = math,
            bit32 = bit32,
            buffer = buffer,
            utf8 = utf8,
            os = os,
            coroutine = coroutine,
            debug = debug,
            newproxy = newproxy,
            setmetatable = setmetatable,
            getmetatable = getmetatable,
            rawget = rawget,
            rawset = rawset,
            rawequal = rawequal,
            rawlen = rawlen,
            tonumber = tonumber,
            tostring = tostring,
            type = type,
            require = function(target: any)
                if typeof(target) == "string" then
                    error(`String requires are not supported from Seam modules (got '{target}')`)
                end

                local targetNode = proxyToNode[target]
                if not targetNode then
                    error("Invalid require target in Lune Seam loader")
                end

                return requireModule(targetNode)
            end,
        }

        local chunk = luau.load(node.source :: string, {
            debugName = node.path,
            environment = environment,
        })

        local result = chunk()
        -- Roblox ModuleScripts may return nil; cache a sentinel so we don't reload.
        node.result = if result == nil then true else result
        node.loading = false

        return result
    end

    local function requirePath(pathSegments: { string }): any
        local node = root
        for _, segment in pathSegments do
            node = node.children[segment]
            if not node then
                error(`Unknown module path segment '{segment}'`)
            end
        end
        return requireModule(node)
    end

    return {
        Seam = requireModule(root),
        requirePath = requirePath,
    }
end

return loadPackage
