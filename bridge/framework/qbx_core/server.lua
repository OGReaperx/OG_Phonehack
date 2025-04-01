og = og or {}
og.framework = og.framework or {}

og.framework.GetPlayer = function()
    return exports.qbx_core:GetPlayer(source)
end