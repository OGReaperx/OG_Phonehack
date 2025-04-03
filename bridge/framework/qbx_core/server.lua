og = og or {}
og.framework = og.framework or {}

local qbx_core = exports.qbx_core

og.framework.GetPlayer = function()
    return exports.qbx_core:GetPlayer(source)
end

og.framework.IsLEO = function(player)
    return player.PlayerData.job.type == "leo"
end

og.framework.IsOnDuty = function(player)
    return player.PlayerData.job.onduty
end

og.framework.GetName = function(source)
    local player = qbx_core:GetPlayer(source)
    if not player then return "" end
    return player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
end