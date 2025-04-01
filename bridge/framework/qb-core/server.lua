og = og or {}
og.framework = og.framework or {}

local QBCore = exports['qb-core']:GetCoreObject()

og.framework.GetPlayer = function()
    return QBCore.Functions.GetPlayer(source)
end