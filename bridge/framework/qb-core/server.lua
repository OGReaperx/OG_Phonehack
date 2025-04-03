og = og or {}
og.framework = og.framework or {}

local QBCore = exports['qb-core']:GetCoreObject()

og.framework.GetPlayer = function()
    return QBCore.Functions.GetPlayer(source)
end

og.framework.IsLEO = function(player)
    return player.PlayerData.job.type == "leo"
end

og.framework.IsOnDuty = function(player)
    return player.PlayerData.job.onduty
end

og.framework.GetName = function(source)
    local player = QBCore.Functions.GetPlayer(source)
    if not player then return "" end
    return player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
end