local function HasTargetPhoneItem(src, phoneNumber)
    print(("Checking if player %s has phone with number: %s"):format(src, phoneNumber))

    -- Get the IMEI that belongs to this number
    local imei = exports.yseries:GetPhoneImeiByPhoneNumber(phoneNumber)
    print("Resolved IMEI for phone number " .. phoneNumber .. ": " .. tostring(imei))

    if not imei then
        print("Failed to resolve IMEI for number:", phoneNumber)
        return false
    end

    for _, itemName in pairs(Config.RequiredPhoneItem) do
        print(("Searching for item: %s"):format(itemName))
        local phoneItems = exports.ox_inventory:Search(src, 'slots', itemName)
        print(("Found %d '%s' items"):format(#phoneItems, itemName))

        for i, slot in ipairs(phoneItems) do
            print(("Item %d: slot=%s, metadata=%s"):format(i, slot.slot or "nil", json.encode(slot.metadata or {})))

            if slot.metadata and slot.metadata[Config.PhoneMetadataKey] then
                local itemImei = slot.metadata[Config.PhoneMetadataKey]
                print(("Comparing item IMEI '%s' with target IMEI '%s'"):format(itemImei, imei))

                if itemImei == imei then
                    print("✅ Match found!")
                    return true
                end
            else
                print("No metadata or IMEI found for this item.")
            end
        end
    end

    print("No matching phone found.")
    return false
end

lib.callback.register('phoneunlock:unlockPhone', function(source, phoneNumber)
    local src = source
    local Player = og.framework.GetPlayer(src)
    if not Player then return end

    if not phoneNumber or phoneNumber == "" then
        print("[ERROR] Invalid phone number received for unlocking")
        return false
    end

    if not HasTargetPhoneItem(src, phoneNumber) then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Phone Missing',
            description = "You do not have the required phone to unlock this phone",
            type = 'error',
            duration = 5000
        })
        print('Player does not have the required phone to unlock this phone')
        return false
    end

    if Player and Player.PlayerData.job.type == "leo" and Player.PlayerData.job.onduty then
        if Config.Phone == 'lb' then
            exports["lb-phone"]:ResetSecurity(phoneNumber)
        elseif Config.Phone == 'yphone' then
            local imei = exports.yseries:GetPhoneImeiByPhoneNumber(phoneNumber)
            if not imei then
                print("[ERROR] Could not resolve IMEI for phone number:", phoneNumber)
                return false
            end

            imei = tostring(imei):gsub("^%s*(.-)%s*$", "%1") -- Trim spaces just in case
            print("[DEBUG] Using IMEI for SQL update:", imei)

            -- Log current lock value
            local check = MySQL.query.await("SELECT `lock` FROM yphone_devices WHERE imei = ?", { imei })
            print("[DEBUG] Lock value before update:", json.encode(check))

            -- Perform update
            local updated = MySQL.update.await([[
                UPDATE yphone_devices
                SET `lock` = 0
                WHERE imei = ?
            ]], { imei })

            print("[DEBUG] Rows affected by update:", updated)

            -- Recheck to confirm
            local checkAfter = MySQL.query.await("SELECT `lock` FROM yphone_devices WHERE imei = ?", { imei })
            print("[DEBUG] Lock value after update:", json.encode(checkAfter))

            if updated == 0 then
                print("[WARN] No rows updated! IMEI mismatch or already unlocked?")
            else
                print("[SUCCESS] Phone unlocked: IMEI =", imei)
            end
        end

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Phone Unlocked',
            description = "Phone with number " .. phoneNumber .. " has been successfully unlocked",
            type = 'success',
            duration = 5000
        })

        exports.yseries:SendNotification({
            app = 'email',
            title = 'Phone Unlocked',
            text = 'This phone has been unlocked and is ready to use.',
            timeout = 3000,
            icon = 'https://cdn-icons-png.flaticon.com/128/10125/10125166.png'
        }, 'phoneNumber', phoneNumber)

        return true
    else
        print('Unauthorized attempt to unlock phone by player ' .. src)
    end

    return false
end)

lib.callback.register('phoneunlock:corruptPhone', function(source, phoneNumber)
    local src = source
    local Player = og.framework.GetPlayer(src)
    if not Player then return end

    if not phoneNumber or phoneNumber == "" then
        print("[ERROR] Invalid phone number received for corrupting")
        return
    end

    if not HasTargetPhoneItem(src, phoneNumber) then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Phone Missing',
            description = "You do not have the required phone to corrupt this phone",
            type = 'error',
            duration = 5000
        })
        print('Player does not have the required phone to corrupt this phone')
        return false
    end

    if Player and Player.PlayerData.job.type == "leo" and Player.PlayerData.job.onduty then
        if Config.Phone == 'lb' then
            exports["lb-phone"]:FactoryReset(phoneNumber)
        elseif Config.Phone == 'yphone' then
            local deleted = MySQL.update.await([[
                DELETE FROM yphone_devices
                WHERE imei = (SELECT imei FROM yphone_sim_cards WHERE sim_number = ?) LIMIT 1
            ]], { phoneNumber })

            print("[YSeries Phone] Factory reset completed for number:", phoneNumber)
        end
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