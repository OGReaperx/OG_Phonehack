og = og or {}
og.framework = og.framework or {}

local ESX = exports.es_extended:getSharedObject()

og.framework.GetPlayer = function()
    return ESX.GetPlayerFromId(source)
end