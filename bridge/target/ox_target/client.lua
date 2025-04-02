og = og or {}
og.target = og.target or {}

og.target.init = function()
    print("[CLIENT INFO] ox_target initializing")
end

local activeTargets = {}

local function convert(options)
    local distance = options.distance
    options = options.options
    for _, v in pairs(options) do
        v.onSelect = v.action
        v.distance = v.distance or distance
        v.name = v.name or v.label
        v.groups = v.job or v.gang
        v.type = nil
        v.action = nil

        v.job = nil
        v.gang = nil
        v.qtarget = true
    end

    return options
end

local function resourceStopped(resource)
    for _, target in pairs(activeTargets) do
        if target.invokingResource == resource then

            if target.options then  
                local optionNames = {}
                for _, option in ipairs(target.options) do
                    optionNames[#optionNames + 1] = option.name
                end
            end

            if target.type == 'zone' then
                exports.ox_target:removeZone(target.id)
                activeTargets[_] = {}

            elseif target.type == 'entity' then
                if DoesEntityExist(target.entity) then 
                    exports.ox_target:removeLocalEntity(target.entity)
                end
                activeTargets[_] = {}

            elseif target.type == 'globalPed' then
                exports.ox_target:removeGlobalPed(optionNames)
                activeTargets[_] = {}
            end
        end
    end
end

AddEventHandler('onResourceStop', function(resource)
    resourceStopped(resource)
end)

og.target.AddBoxZone = function(name, coords, size, parameters)
    local resource = GetInvokingResource()
    local rotation = parameters.rotation
    local id = exports.ox_target:addBoxZone({
        coords = coords,
        size = size,
        rotation = rotation,
        debug = false,
        options = convert(parameters)
    })
    activeTargets[name] = {
        id = id,
        type = 'zone',
        invokingResource = resource
    }
end

og.target.AddSphereZone = function(name, coords, radius, parameters)
    local resource = GetInvokingResource()
    local id = exports.ox_target:addSphereZone({
        coords = coords,
        radius = radius,
        debug = false,
        options = convert(parameters)
    })
    activeTargets[name] = {
        id = id,
        type = 'zone',
        invokingResource = resource
    }
end