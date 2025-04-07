local bl_ui = exports.bl_ui
local Bridge = exports.community_bridge:Bridge()

local contains = function(tbl, val)
    for _, v in pairs(tbl) do
        if v == val then
            return true
        end
    end
    return false
end

local createZones = function()
    for i, comp in ipairs(Config.Computers) do
        local zoneName = 'phone_unlock_zone_' .. i
        Bridge.Target.RemoveZone(zoneName)
        local options = {
            {
                name = 'unlockPhone',
                icon = 'fas fa-laptop',
                label = 'Unlock Phone',
                action = function()
                    TriggerEvent('phoneunlock:openDialog')
                end,
                canInteract = function()
                    local result = contains(Config.PoliceJobs, Bridge.Framework.GetPlayerJob())
                    return result
                end
            }
        }
        if comp.size then
            Bridge.Target.AddBoxZone(zoneName, comp.coords, comp.size, 0, options)
        else
            Bridge.Target.AddBoxZone(zoneName, comp.coords,vector3(comp.radius,comp.radius,comp.radius), 0, options)
        end
    end
end

RegisterNetEvent('community_bridge:Client:OnPlayerLoaded', function()
createZones()
end)

RegisterNetEvent('community_bridge:Client:OnPlayerUnload', function()
    for i = 1, #Config.Computers do
        local zoneName = 'phone_unlock_zone_' .. i
        Bridge.Target.RemoveZone(zoneName)
        print("RemoveZone OnUnload: "..zoneName)
    end
end)


RegisterNetEvent('phoneunlock:openDialog')
AddEventHandler('phoneunlock:openDialog', function()
    local input = lib.inputDialog('Unlock Phone', {
        {type = 'input', label = 'Enter Phone Number', description = 'Enter the phone number to unlock', icon = 'phone'}
    })

    if not input then 
        print("User cancelled input dialog.")
        return 
    end

    local phoneNumber = input[1]

    if not phoneNumber or phoneNumber:match("^%s*$") then
        lib.notify({
            title = 'Invalid Phone Number',
            description = 'Please enter a valid phone number.',
            type = 'error'
        })
        return
    end

    local success = bl_ui:PrintLock(1, {
        grid = 3,
        duration = 20000,   
        target = 2
    })

    if success then
        print("Decryption successful. Unlocking phone: " .. phoneNumber)

        local unlockSuccess = lib.callback.await('phoneunlock:unlockPhone', false, phoneNumber)

        if unlockSuccess then
            print("Phone successfully unlocked.")
        else
            print("Failed to unlock phone. Unauthorized?")
        end

    else
        print("Decryption failed.")
        lib.notify({
            title = 'Decryption Failed',
            description = 'The decryption process failed. The phone may be corrupted.',
            type = 'error'
        })

        if math.random() <= 0.50 then
            print("Phone corrupted. Performing factory reset.")

            local corruptSuccess = lib.callback.await('phoneunlock:corruptPhone', false, phoneNumber)

            if corruptSuccess then
                print("Phone successfully corrupted.")
            else
                print("Failed to corrupt phone. Unauthorized?")
            end
        else
            print("Decryption unsuccessful.")
        end
    end
end)
