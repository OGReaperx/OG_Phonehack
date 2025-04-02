local shared = {}

--- Path correction: We are using 'bridge/', not 'core/bridge/'
local baseBridgePath = GetResourcePath(GetCurrentResourceName()):gsub('//', '/') .. '/bridge/'
local baseLibPath = GetResourcePath(GetCurrentResourceName()):gsub('//', '/') .. '/lib/'

-- Cross-platform inDirectory scanner
local function inDirectory(path, pattern)
    local isWindows = string.match(os.getenv("OS") or "", "Windows")
    local command = ('%s"%s"%s'):format(
        isWindows and 'dir /b ' or 'ls ',
        path:gsub("\\", "/"),
        isWindows and '' or ''
    )

    local results = {}
    local handle = io.popen(command)
    if handle then
        for line in handle:lines() do
            if line:match(pattern) and not line:match("^%s*$") then
                table.insert(results, line)
            end
        end
        handle:close()
    end
    return results
end

-- Util
local function isTableEmpty(tbl)
    if type(tbl) ~= "table" then error("Expected table, got " .. type(tbl)) end
    return next(tbl) == nil
end

-- Gets folders inside each category (framework/target/etc)
shared.populateResources = function()
    local categories = {}

    for _, categoryName in ipairs(inDirectory(baseBridgePath, ".+")) do

        if categoryName ~= "." and categoryName ~= ".." and not categoryName:match("%.lua$") and categoryName ~= "init" and categoryName ~= "shared.lua" then
            local categoryPath = baseBridgePath .. categoryName .. "/"
            categories[categoryName] = {}
    
            for _, resourceName in ipairs(inDirectory(categoryPath, ".+")) do
                if resourceName ~= "." and resourceName ~= ".." then
                    table.insert(categories[categoryName], resourceName)
                end
            end
        end
    end
    return categories
end    

-- Checks which ones are active (started)
shared.checkResources = function()
    local resources = shared.populateResources()
    local activeResources = {}

    for category, list in pairs(resources) do
        activeResources[category] = {}

        for _, resource in ipairs(list) do
            if GetResourceState(resource) == 'started' then
                -- QBCore redirect fallback
                if resource == 'qb-core' and GetResourceState("qbx_core") == "started" then
                    table.insert(activeResources[category], "qbx_core")
                else
                    table.insert(activeResources[category], resource)
                end
                break
            end
        end

        if isTableEmpty(activeResources[category]) then
            table.insert(activeResources[category], "default")
        end
    end

    return activeResources
end

-- Dynamically loads bridge scripts
shared.loadResourceScripts = function()
    local active = shared.checkResources()
    local currentRes = GetCurrentResourceName()

    for category, resourceList in pairs(active) do
        for _, resource in ipairs(resourceList) do
            local path = ("bridge/%s/%s/"):format(category, resource)
            local file = IsDuplicityVersion() and "server.lua" or "client.lua"
            local scriptPath = path .. file

            local code = LoadResourceFile(currentRes, scriptPath)
            if code then
                local fn, err = load(code, ("@@%s/%s"):format(currentRes, scriptPath))
                if fn then
                    pcall(fn)
                else
                    print(("[ERROR] Failed to load %s: %s"):format(scriptPath, err))
                end
            else
                print(("[WARNING] Script not found: %s"):format(scriptPath))
            end
        end
    end
end

-- Module Loader: lib/<module>/client|server.lua
shared.loadModule = function(moduleName)
    local resource = GetCurrentResourceName()
    local context = IsDuplicityVersion() and "server" or "client"
    local modulePath = ("lib/%s/%s.lua"):format(moduleName, context)
    local code = LoadResourceFile(resource, modulePath)

    if code then
        local fn, err = load(code, ("@@%s/%s"):format(resource, modulePath))
        if not fn then error(("Failed to load module '%s': %s"):format(moduleName, err)) end
        return fn()
    end
end

shared.populateModules = function()
    return inDirectory(baseLibPath, ".+")
end

shared.loadModules = function()
    for _, mod in ipairs(shared.populateModules()) do
        shared.loadModule(mod)
    end
end

return shared
