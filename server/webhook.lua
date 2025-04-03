local webhooks = {}

--- Converts hex string, RGB table, or number to Discord decimal color
---@param color string|table|number
---@return number
local function ConvertColor(color)
    if type(color) == "string" then
        local hex = color:gsub("#", "")
        return tonumber(hex, 16) or 16777215
    elseif type(color) == "table" and #color == 3 then
        local r, g, b = table.unpack(color)
        return (r << 16) + (g << 8) + b
    elseif type(color) == "number" then
        return color
    end
    return 16777215 -- Default to white
end

--- Sends a Discord embed
---@param name string – sender name
---@param message string – embed description
---@param color string|table|number – embed color
---@param image string? – optional image/thumbnail URL
---@param footer string? – footer text
---@param title string? – embed title
function webhooks.Send(name, message, color, image, footer, title)
    local embed = {
        title = title or "Notification",
        description = message,
        color = ConvertColor(color),
        footer = {
            text = footer or os.date("%c")
        }
    }

    if image then
        embed.thumbnail = { url = image }
    end

    local data = {
        username = name or "OG_Phonehack",
        embeds = { embed },
        content = nil
    }

    PerformHttpRequest(Config.Webhook, function(err)
        if err and err ~= 204 then
            print("^1[Discord Webhook] Failed to send. Code: " .. tostring(err) .. "^7")
        end
    end, 'POST', json.encode(data), {
        ['Content-Type'] = 'application/json'
    })
end

--- Gets Steam/Discord/License/FiveM ID
---@param src number
---@return table
function webhooks.GetIdentifiers(src)
    local ids = {
        steam = "N/A",
        discord = "N/A",
        license = "N/A",
        fivem = tostring(src),
    }

    for _, id in pairs(GetPlayerIdentifiers(src)) do
        if id:match("steam:") then
            ids.steam = id
        elseif id:match("discord:") then
            ids.discord = id:gsub("discord:", "")
        elseif id:match("license:") then
            ids.license = id
        end
    end

    return ids
end

-- Test command to validate webhook
-- RegisterCommand("testwebhook", function(source)
--     local name = (source == 0 and "Console Tester") or og.framework.GetName(source) or "Unknown"
--     local ids = {
--         steam = "N/A",
--         discord = "N/A",
--         license = "N/A",
--         fivem = tostring(source),
--     }

--     if source ~= 0 then
--         ids = webhooks.GetIdentifiers(source)
--     end

--     webhooks.Send(
--         "OG_Phonehack",
--         ("📲 Test log from %s\n\n**Steam:** %s\n**Discord:** <@%s>\n**License:** %s\n**FiveM ID:** %s")
--             :format(name, ids.steam, ids.discord, ids.license, ids.fivem),
--         Config.WebhookColor,
--         "https://cdn-icons-png.flaticon.com/128/10125/10125166.png",
--         "Test Webhook",
--         "🧪 Webhook Test"
--     )
-- end, false)


return webhooks
