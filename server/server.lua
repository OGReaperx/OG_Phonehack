lib.callback.register('phoneunlock:unlockPhone', function(source, phoneNumber)
    local src = source
    local Player = exports['qbx_core']:GetPlayer(src)
    
    if not phoneNumber or phoneNumber == "" then
        print("[ERROR] Invalid phone number received for unlocking")
        return
    end

    if Player and Player.PlayerData.job.type == "leo" and Player.PlayerData.job.onduty then
        exports["lb-phone"]:ResetSecurity(phoneNumber)

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Phone Unlocked',
            description = "Phone with number " .. phoneNumber .. " has been successfully unlocked",
            type = 'success',
            duration = 5000
        })
    else
        print('Unauthorized attempt to unlock phone by player' .. src)
    end
end)

lib.callback.register('phoneunlock:corruptPhone', function(source, phoneNumber)
    local src = source
    local Player = exports['qbx_core']:GetPlayer(src)

    if not phoneNumber or phoneNumber == "" then
        print("[ERROR] Invalid phone number received for corrupting")
        return
    end

    if Player and Player.PlayerData.job.type == "leo" and Player.PlayerData.job.onduty then
        exports["lb-phone"]:FactoryReset(phoneNumber)

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Phone Corrupted',
            description = "Phone with number " .. phoneNumber .. " is being successfully factory reset",
            type = 'error',
            duration = 5000
        })
    else
        print('Unauthorized attempt to corrupt phone by player' .. src)
    end
end)