local shared = require("bridge.shared")

if not og then og = {} end
local cachedActiveResources = shared.checkResources()
local cachedModules = shared.populateModules()

print("[Phonehack bridge] Loaded Bridges:")
for category, list in pairs(cachedActiveResources) do
    for _, resourceName in ipairs(list) do
        print(("  → %s: %s"):format(category, resourceName))
    end
end

CreateThread(function()
    shared.loadModules()
    shared.loadResourceScripts()
    TriggerEvent(GetCurrentResourceName()..':Server:onResourceStart')
end)

lib.callback.register("og_template:server:requestActiveResources", function(source)
    return cachedActiveResources, cachedModules
end)
