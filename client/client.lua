local bl_ui = exports.bl_ui

CreateThread(function()
    for i, comp in ipairs(Config.Computers) do
        local zoneName = 'phone_unlock_zone_' .. i

        local options = {
            {
                name = 'unlockPhone',
                event = 'phoneunlock:openDialog',
                icon = 'fas fa-laptop',
                label = 'Unlock Phone'
            }
        }

        if comp.size then
            og.target.AddBoxZone(zoneName, comp.coords, comp.size, {
                options = options
            })
        else
            og.target.AddSphereZone(zoneName, comp.coords, comp.radius, {
                options = options
            })
        end
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
