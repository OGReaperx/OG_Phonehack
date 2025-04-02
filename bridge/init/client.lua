if not og then og = {} end

CreateThread(function()
    local resources, modules = lib.callback.await("og_template:server:requestActiveResources", false)

    if resources then
        for category, resourceList in pairs(resources) do
            for _, resourceName in ipairs(resourceList) do
                if resourceName then
                    local baseDir = "bridge/" .. category .. "/" .. resourceName .. "/"
                    local clientScript = baseDir .. "client.lua"
                    local resourceFile = LoadResourceFile(GetCurrentResourceName(), clientScript)

                    if not resourceFile then
                        print(("^3[OG WARNING]^7 Missing bridge file at path '%s'"):format(clientScript))
                    else
                        local ld, err = load(resourceFile, ('@@%s/%s'):format(GetCurrentResourceName(), clientScript))
                        if not ld or err then
                            error(err)
                        end
                        ld()
                    end
                end
            end
        end
    end

    if modules then 
        for _, resourceName in ipairs(modules) do
            local baseDir = "lib/"
            local clientScript = baseDir .. resourceName .. "/client.lua"
            local resourceFile = LoadResourceFile(GetCurrentResourceName(), clientScript)

            if resourceFile then
                local ld, err = load(resourceFile, ('@@%s/%s'):format(GetCurrentResourceName(), clientScript))
                if not ld or err then
                    error(err)
                end
                ld()
            end
        end
    end

    -- Ready
    TriggerEvent(GetCurrentResourceName()..':Client:onResourceStart')
end)
