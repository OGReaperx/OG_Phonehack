og = og or {}
og.framework = og.framework or {}

local ESX = exports.es_extended:getSharedObject()

og.framework.GetPlayer = function()
    return ESX.GetPlayerFromId(source)
end

og.framework.IsLEO = function(player)
    return player and player.job and player.job.name == 'police' -- or any other LEO jobs
end

og.framework.IsOnDuty = function(player)
    return true
end

og.framework.GetName = function(source)
    local player = ESX.GetPlayerFromId(source)
    if not player then return "" end
    return player.getName()
end