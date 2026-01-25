local fadedVehicles = {}

local function nowSeconds()
    return os.time()
end

local function clamp255(n)
    n = tonumber(n) or 0
    n = math.floor(n)
    if n < 0 then return 0 end
    if n > 255 then return 255 end
    return n
end

local function isValidColorIndex(idx)
    idx = tonumber(idx)
    if not idx then return false end
    idx = math.floor(idx)
    return idx >= 0 and idx <= (Config.MaxVehicleColors or 160)
end

local function sanitizeColorIndex(idx)
    idx = tonumber(idx)
    if not idx then return 0 end
    idx = math.floor(idx)
    if idx < 0 then return 0 end
    local maxIdx = (Config.MaxVehicleColors or 160)
    if idx > maxIdx then return maxIdx end
    return idx
end

local function sanitizeOrigData(origData)
    local safeOrig = {
        primaryIndex = 0,
        secondaryIndex = 0,
        pearlescentIndex = 0,
        wheelColor = 0,
        hasCustom = false,
        customColor = nil,
        ts = nowSeconds()
    }

    if type(origData) ~= "table" then
        return safeOrig
    end

    safeOrig.primaryIndex = sanitizeColorIndex(origData.primaryIndex)
    safeOrig.secondaryIndex = sanitizeColorIndex(origData.secondaryIndex)
    safeOrig.pearlescentIndex = sanitizeColorIndex(origData.pearlescentIndex)
    safeOrig.wheelColor = sanitizeColorIndex(origData.wheelColor)

    if origData.hasCustom == true and type(origData.customColor) == "table" then
        safeOrig.hasCustom = true
        safeOrig.customColor = {
            clamp255(origData.customColor[1]),
            clamp255(origData.customColor[2]),
            clamp255(origData.customColor[3])
        }
    end

    return safeOrig
end

local function getPlayerVehicleNetIdIfAuthorized(src)
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return nil, "no_ped" end

    local veh = GetVehiclePedIsIn(ped, false)
    if not veh or veh == 0 then return nil, "no_vehicle" end

    if Config.RequireDriverSeat then
        local driver = GetPedInVehicleSeat(veh, -1)
        if driver ~= ped then
            return nil, "not_driver"
        end
    end

    local netId = NetworkGetNetworkIdFromEntity(veh)
    if not netId or netId == 0 then return nil, "no_netid" end
    return netId
end

local function IsPlayerWhitelisted(src)
    local playerIdentifiers = GetPlayerIdentifiers(src)
    for _, id in ipairs(playerIdentifiers) do
        for _, allowedId in ipairs(Config.AllowedIdentifiers) do
            if id == allowedId then
                return true
            end
        end
    end
    return false
end

RegisterNetEvent("colorfade:checkWhitelist")
AddEventHandler("colorfade:checkWhitelist", function()
    local src = source
    local allowed = IsPlayerWhitelisted(src)
    TriggerClientEvent("colorfade:whitelistResult", src, allowed)
end)

-- Fade toggle by primary color index
RegisterNetEvent("colorfade:requestFade")
AddEventHandler("colorfade:requestFade", function(netID, targetColorIndex, origData)
    local src = source

    if not IsPlayerWhitelisted(src) then
        return
    end

    local playerVehNetId, reason = getPlayerVehicleNetIdIfAuthorized(src)
    if not playerVehNetId then
        return
    end

    netID = tonumber(netID)
    if not netID or math.floor(netID) ~= playerVehNetId then
        return
    end

    if not isValidColorIndex(targetColorIndex) then
        return
    end
    targetColorIndex = math.floor(tonumber(targetColorIndex))

    if fadedVehicles[netID] then
        local orig = fadedVehicles[netID]
        TriggerClientEvent("colorfade:applyState", -1, netID, {
            fadeTo = {
                type = orig.hasCustom and orig.customColor and "rgb" or "index",
                r = orig.customColor and orig.customColor[1] or nil,
                g = orig.customColor and orig.customColor[2] or nil,
                b = orig.customColor and orig.customColor[3] or nil,
                value = orig.primaryIndex
            },
            apply = {
                primaryIndex = orig.primaryIndex,
                secondaryIndex = orig.secondaryIndex,
                pearlescentIndex = orig.pearlescentIndex,
                wheelColor = orig.wheelColor,
                hasCustom = orig.hasCustom,
                customColor = orig.customColor
            }
        })
        fadedVehicles[netID] = nil
    else
        local safeOrig = sanitizeOrigData(origData)
        fadedVehicles[netID] = safeOrig

        -- Fade to chosen primary index but keep original secondary + wheel; drop pearlescent during fade.
        TriggerClientEvent("colorfade:applyState", -1, netID, {
            fadeTo = { type = "index", value = targetColorIndex },
            apply = {
                primaryIndex = targetColorIndex,
                secondaryIndex = safeOrig.secondaryIndex,
                pearlescentIndex = 0,
                wheelColor = safeOrig.wheelColor,
                hasCustom = false,
                customColor = nil
            }
        })
    end
end)

-- Fade toggle by RGB color
RegisterNetEvent("colorfade:requestFadeRGB")
AddEventHandler("colorfade:requestFadeRGB", function(netID, r, g, b, origData)
    local src = source

    if not IsPlayerWhitelisted(src) then
        return
    end

    local playerVehNetId = getPlayerVehicleNetIdIfAuthorized(src)
    if not playerVehNetId then
        return
    end

    netID = tonumber(netID)
    if not netID or math.floor(netID) ~= playerVehNetId then
        return
    end

    r, g, b = clamp255(r), clamp255(g), clamp255(b)

    if fadedVehicles[netID] then
        local orig = fadedVehicles[netID]
        TriggerClientEvent("colorfade:applyState", -1, netID, {
            fadeTo = {
                type = orig.hasCustom and orig.customColor and "rgb" or "index",
                r = orig.customColor and orig.customColor[1] or nil,
                g = orig.customColor and orig.customColor[2] or nil,
                b = orig.customColor and orig.customColor[3] or nil,
                value = orig.primaryIndex
            },
            apply = {
                primaryIndex = orig.primaryIndex,
                secondaryIndex = orig.secondaryIndex,
                pearlescentIndex = orig.pearlescentIndex,
                wheelColor = orig.wheelColor,
                hasCustom = orig.hasCustom,
                customColor = orig.customColor
            }
        })
        fadedVehicles[netID] = nil
    else
        local safeOrig = sanitizeOrigData(origData)
        fadedVehicles[netID] = safeOrig

        TriggerClientEvent("colorfade:applyState", -1, netID, {
            fadeTo = { type = "rgb", r = r, g = g, b = b },
            apply = {
                -- Keep indices, but use custom primary for the visible fade.
                primaryIndex = safeOrig.primaryIndex,
                secondaryIndex = safeOrig.secondaryIndex,
                pearlescentIndex = 0,
                wheelColor = safeOrig.wheelColor,
                hasCustom = true,
                customColor = { r, g, b }
            }
        })
    end
end)

CreateThread(function()
    while true do
        Wait(30 * 1000)
        local ttl = Config.FadeStateTTLSeconds or 600
        local cutoff = nowSeconds() - ttl
        for netId, data in pairs(fadedVehicles) do
            if type(data) ~= "table" or type(data.ts) ~= "number" or data.ts < cutoff then
                fadedVehicles[netId] = nil
            end
        end
    end
end)
