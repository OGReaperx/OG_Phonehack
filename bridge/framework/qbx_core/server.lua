og = og or {}
og.framework = og.framework or {}

og.framework.GetPlayer = function()
    return exports.qbx_core:GetPlayer(source)
end

og.framework.IsLEO = function(player)
    return player.PlayerData.job.type == "leo"
end

og.framework.IsOnDuty = function(player)
    return player.PlayerData.job.onduty
end