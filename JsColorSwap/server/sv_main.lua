local fadedVehicles = {}

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
    if not netID or not targetColorIndex then return end
    local src = source

    if fadedVehicles[netID] then
        local orig = fadedVehicles[netID]
        if orig.hasCustom and orig.customColor then
            TriggerClientEvent("colorfade:applyFadeRGB", -1, netID, orig.customColor[1], orig.customColor[2], orig.customColor[3])
        else
            TriggerClientEvent("colorfade:applyFade", -1, netID, orig.primaryIndex or 0)
        end
        fadedVehicles[netID] = nil
    else
        if origData then
            fadedVehicles[netID] = origData
        else
            fadedVehicles[netID] = { primaryIndex = 0, hasCustom = false }
        end
        TriggerClientEvent("colorfade:applyFade", -1, netID, targetColorIndex)
    end
end)

-- Fade toggle by RGB color
RegisterNetEvent("colorfade:requestFadeRGB")
AddEventHandler("colorfade:requestFadeRGB", function(netID, r, g, b, origData)
    if not netID or not r or not g or not b then return end
    local src = source

    if fadedVehicles[netID] then
        local orig = fadedVehicles[netID]
        if orig.hasCustom and orig.customColor then
            TriggerClientEvent("colorfade:applyFadeRGB", -1, netID, orig.customColor[1], orig.customColor[2], orig.customColor[3])
        else
            TriggerClientEvent("colorfade:applyFade", -1, netID, orig.primaryIndex or 0)
        end
        fadedVehicles[netID] = nil
    else
        if origData then
            fadedVehicles[netID] = origData
        else
            fadedVehicles[netID] = { hasCustom = true, customColor = {r, g, b} }
        end
        TriggerClientEvent("colorfade:applyFadeRGB", -1, netID, r, g, b)
    end
end)
