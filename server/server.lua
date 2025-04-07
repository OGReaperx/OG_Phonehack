local Webhooks = require("server.webhook") -- Adjust if you move it
local Bridge = exports.community_bridge:Bridge()

local function HasTargetPhoneItem(src, phoneNumber)
    print(("Checking if player %s has phone with number: %s"):format(src, phoneNumber))

    local compareValue
    if Config.Phone == 'yphone' then
        compareValue = exports.yseries:GetPhoneImeiByPhoneNumber(phoneNumber)
        print("Resolved IMEI for yphone: " .. tostring(compareValue))
    elseif Config.Phone == 'lb' then
        compareValue = phoneNumber
        print("Using phone number directly for lb-phone: " .. tostring(compareValue))
    else
        print("[ERROR] Unsupported phone type in Config.Phone:", Config.Phone)
        return false
    end

    if not compareValue then
        print("[ERROR] Could not resolve value to match against item metadata")
        return false
    end

    -- Check inventory for item with matching metadata
    for _, itemName in pairs(Config.RequiredPhoneItem) do
        local item = Bridge.Inventory.GetItem(src, itemName, {
            [Config.PhoneMetadataKey] = compareValue
        })

        if item then
            print(("✅ Found matching phone item '%s' with %s = %s"):format(itemName, Config.PhoneMetadataKey, compareValue))
            return true
        end
    end

    print("❌ No matching phone item found in inventory.")
    return false
end


lib.callback.register('phoneunlock:unlockPhone', function(source, phoneNumber)
    local src = source
    local playerjobname = Bridge.Framework.GetPlayerJob(src)
    
    if not playerjobname then 
        return 
    end

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

    if lib.table.contains(Config.PoliceJobs, playerjobname) then        
        print("Player is LEO and on duty. Proceeding with unlock...")
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

        local playerfirstname, playerlastname = Bridge.Framework.GetPlayerName(src)
        local name = playerfirstname .. " " .. playerlastname
        local ids = Webhooks.GetIdentifiers(src)
      
        Webhooks.Send(
            "OG_Phonehack",
            ("📱 Officer %s unlocked phone %s\n\n**Steam:** %s\n**Discord:** <@%s>\n**License:** %s\n**FiveM ID:** %s")
                :format(name, phoneNumber, ids.steam, ids.discord, ids.license, ids.fivem),
            Config.WebhookColor,
            Config.WebhookImage,
            "Unlock Log",
            "✅ Phone Unlocked"
        )
        

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
    local playerjobname = Bridge.Framework.GetPlayerJob(src)
    if not playerjobname then return end

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

    if lib.table.contains(Config.PoliceJobs, playerjobname) then        
        print("Player is LEO and on duty. Proceeding with unlock...")
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
            description = "Phone with number " .. phoneNumber .. " was corrupted and factory reset",
            type = 'error',
            duration = 5000
        })

        local playerfirstname, playerlastname = Bridge.Framework.GetPlayerName(src)
        local name = playerfirstname .. " " .. playerlastname
        local ids = Webhooks.GetIdentifiers(src)

        Webhooks.Send(
            "OG_Phonehack",
            ("📱 Officer %s corrupted phone %s\n\n**Steam:** %s\n**Discord:** <@%s>\n**License:** %s\n**FiveM ID:** %s")
                :format(name, phoneNumber, ids.steam, ids.discord, ids.license, ids.fivem),
            Config.WebhookColor_Corrupt,
            Config.WebhookImage,
            "Corruption Log",
            "❌ Phone Corrupted"
        )
    else
        print('Unauthorized attempt to corrupt phone by player' .. src)
    end
end)