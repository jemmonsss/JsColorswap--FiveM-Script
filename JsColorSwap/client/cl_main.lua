local isWhitelisted = false
local selectedColorIndex = 0
local isMenuOpen = false
local menuCur = 1

local originalColors = {} -- Store original colors per vehicle entity

-- Full GTA color data table with RGB
local GtaColorList = {
    [0] = {name = "Black", rgb = {0, 0, 0}},
    [1] = {name = "Graphite", rgb = {54, 57, 61}},
    [2] = {name = "Black Steel", rgb = {47, 50, 56}},
    [3] = {name = "Dark Steel", rgb = {64, 69, 75}},
    [4] = {name = "Silver", rgb = {172, 172, 172}},
    [5] = {name = "Blue Silver", rgb = {161, 165, 167}},
    [6] = {name = "Rolled Steel", rgb = {110, 110, 110}},
    [7] = {name = "Shadow Silver", rgb = {96, 99, 102}},
    [8] = {name = "Stone Silver", rgb = {119, 123, 126}},
    [9] = {name = "Midnight Silver", rgb = {69, 74, 78}},
    [10] = {name = "Cast Iron Silver", rgb = {46, 51, 55}},
    [11] = {name = "Red", rgb = {154, 33, 33}},
    [12] = {name = "Torino Red", rgb = {179, 37, 37}},
    [13] = {name = "Formula Red", rgb = {204, 0, 0}},
    [14] = {name = "Lava Red", rgb = {188, 35, 34}},
    [15] = {name = "Blaze Red", rgb = {222, 20, 20}},
    [16] = {name = "Grace Red", rgb = {181, 44, 44}},
    [17] = {name = "Garnet Red", rgb = {120, 25, 24}},
    [18] = {name = "Sunset Red", rgb = {180, 40, 40}},
    [19] = {name = "Cabernet Red", rgb = {146, 17, 21}},
    [20] = {name = "Wine Red", rgb = {110, 15, 20}},
    [21] = {name = "Candy Red", rgb = {196, 15, 15}},
    [22] = {name = "Hot Pink", rgb = {255, 105, 180}},
    [23] = {name = "Pfsiter Pink", rgb = {255, 192, 203}},
    [24] = {name = "Salmon Pink", rgb = {250, 128, 114}},
    [25] = {name = "Sunrise Orange", rgb = {255, 69, 0}},
    [26] = {name = "Orange", rgb = {255, 165, 0}},
    [27] = {name = "Bright Orange", rgb = {255, 140, 0}},
    [28] = {name = "Gold", rgb = {255, 215, 0}},
    [29] = {name = "Bronze", rgb = {205, 127, 50}},
    [30] = {name = "Yellow", rgb = {255, 255, 0}},
    [31] = {name = "Race Yellow", rgb = {255, 236, 139}},
    [32] = {name = "Dew Yellow", rgb = {242, 255, 163}},
    [33] = {name = "Dark Green", rgb = {0, 51, 0}},
    [34] = {name = "Racing Green", rgb = {0, 102, 0}},
    [35] = {name = "Sea Green", rgb = {46, 139, 87}},
    [36] = {name = "Olive Green", rgb = {107, 142, 35}},
    [37] = {name = "Bright Green", rgb = {0, 255, 0}},
    [38] = {name = "Gasoline Green", rgb = {0, 128, 0}},
    [39] = {name = "Lime Green", rgb = {50, 205, 50}},
    [40] = {name = "Midnight Blue", rgb = {0, 0, 51}},
    [41] = {name = "Galaxy Blue", rgb = {25, 25, 112}},
    [42] = {name = "Dark Blue", rgb = {0, 0, 139}},
    [43] = {name = "Saxon Blue", rgb = {70, 130, 180}},
    [44] = {name = "Blue", rgb = {0, 0, 255}},
    [45] = {name = "Mariner Blue", rgb = {3, 54, 73}},
    [46] = {name = "Harbor Blue", rgb = {2, 41, 61}},
    [47] = {name = "Diamond Blue", rgb = {49, 140, 231}},
    [48] = {name = "Surf Blue", rgb = {28, 169, 201}},
    [49] = {name = "Nautical Blue", rgb = {0, 119, 190}},
    [50] = {name = "Ultra Blue", rgb = {0, 102, 255}},
    [51] = {name = "Bright Blue", rgb = {0, 191, 255}},
    [52] = {name = "Purple", rgb = {128, 0, 128}},
    [53] = {name = "Spinnaker Purple", rgb = {75, 0, 130}},
    [54] = {name = "Midnight Purple", rgb = {48, 25, 52}},
    [55] = {name = "Bright Purple", rgb = {191, 64, 191}},
    [56] = {name = "Cream", rgb = {255, 253, 208}},
    [57] = {name = "White", rgb = {255, 255, 255}},
    [58] = {name = "Frost White", rgb = {240, 240, 240}},
    [59] = {name = "Hot Pink", rgb = {255, 105, 180}},
    [60] = {name = "Salmon Pink", rgb = {250, 128, 114}},
    [61] = {name = "Orange", rgb = {255, 165, 0}},
    [62] = {name = "Brushed Steel", rgb = {177, 177, 177}},
    [63] = {name = "Brushed Black Steel", rgb = {55, 55, 55}},
    [64] = {name = "Brushed Aluminum", rgb = {174, 174, 174}},
    [65] = {name = "Chrome", rgb = {230, 230, 230}},
    [66] = {name = "Black Chrome", rgb = {32, 32, 32}},
    [67] = {name = "Matt Black", rgb = {8, 8, 8}},
    [68] = {name = "Matte Gray", rgb = {68, 68, 68}},
    [69] = {name = "Light Gray", rgb = {153, 153, 153}},
    [70] = {name = "Ice White", rgb = {235, 235, 235}},
}

local colorIdxs = {}
for idx in pairs(GtaColorList) do
    table.insert(colorIdxs, idx)
end
table.sort(colorIdxs)

local function notify(txt)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(txt)
    DrawNotification(false, true)
end

local function GetColorRGB(colorIndex)
    local c = GtaColorList[colorIndex]
    if c and c.rgb then
        return c.rgb[1], c.rgb[2], c.rgb[3]
    end
    return 255, 255, 255
end

local function FadeVehicle(veh, fromP, toP)
    local startTime = GetGameTimer()
    local duration = 2500
    local step = 15

    while GetGameTimer() < startTime + duration do
        local now = GetGameTimer()
        local t = (now - startTime) / duration

        local r = math.floor(fromP[1] + (toP[1] - fromP[1]) * t)
        local g = math.floor(fromP[2] + (toP[2] - fromP[2]) * t)
        local b = math.floor(fromP[3] + (toP[3] - fromP[3]) * t)

        SetVehicleCustomPrimaryColour(veh, r, g, b)
        Wait(step)
    end

    SetVehicleCustomPrimaryColour(veh, toP[1], toP[2], toP[3])
end

local function DrawText(x, y, text, scale, r, g, b)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

local function OpenMenu()
    isMenuOpen = true
    menuCur = 1
    Citizen.CreateThread(function()
        while isMenuOpen do
            Citizen.Wait(0)
            DrawRect(0.5, 0.5, 0.5, 0.6, 0, 0, 0, 180)
            DrawText(0.5, 0.28, "Select Vehicle Color", 0.7, 255, 255, 255)

            local startIdx = math.max(1, menuCur - 5)
            local endIdx = math.min(#colorIdxs, startIdx + 10)

            for i = startIdx, endIdx do
                local yPos = 0.33 + (i - startIdx) * 0.04
                local idx = colorIdxs[i]
                local colorName = GtaColorList[idx].name or ("ID: " .. idx)

                if i == menuCur then
                    DrawRect(0.5, yPos + 0.015, 0.4, 0.035, 0, 255, 0, 100)
                    DrawText(0.5, yPos, colorName, 0.5, 0, 255, 0)
                else
                    DrawText(0.5, yPos, colorName, 0.5, 255, 255, 255)
                end
            end

            if IsControlJustPressed(0, 172) then -- UP arrow
                menuCur = menuCur - 1
                if menuCur < 1 then menuCur = #colorIdxs end
            elseif IsControlJustPressed(0, 173) then -- DOWN arrow
                menuCur = menuCur + 1
                if menuCur > #colorIdxs then menuCur = 1 end
            elseif IsControlJustPressed(0, 191) then -- ENTER
                selectedColorIndex = colorIdxs[menuCur]
                notify("Selected color: " .. (GtaColorList[selectedColorIndex].name or "ID " .. selectedColorIndex))
                isMenuOpen = false
            elseif IsControlJustPressed(0, 194) then -- ESC
                isMenuOpen = false
            end
        end
    end)
end

local keybinds = {
    colorfade_menu = "F7",
    colorfade_toggle = "F6",
    colorfade_savecolor = "F8"
}

local function GetKeyMappingDisplayName(command)
    return keybinds[command] or "Unbound"
end

local function GetVehiclePrimaryColourSafe(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return 0 -- default color black
    end
    local success, primaryColour = pcall(function()
        return GetVehiclePrimaryColour(vehicle)
    end)
    if success and primaryColour then
        return primaryColour
    else
        return 0
    end
end

local function GetVehicleSecondaryColourSafe(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return 0
    end
    local success, secondaryColour = pcall(function()
        return GetVehicleSecondaryColour(vehicle)
    end)
    if success and secondaryColour then
        return secondaryColour
    else
        return 0
    end
end

local function GetVehicleExtraColoursSafe(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return 0, 0
    end
    local success, pearlescentColour, wheelColour = pcall(function()
        return GetVehicleExtraColours(vehicle)
    end)
    if success and pearlescentColour then
        return pearlescentColour, wheelColour or 0
    else
        return 0, 0
    end
end

local function SaveOriginalColor()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 or not DoesEntityExist(veh) then
        notify("~r~You must be in a vehicle to save its color.")
        return
    end

    local customR, customG, customB = GetVehicleCustomPrimaryColour(veh)
    local primaryIndex = GetVehiclePrimaryColourSafe(veh)
    local secondaryIndex = GetVehicleSecondaryColourSafe(veh)
    local pearlescentIndex, wheelColor = GetVehicleExtraColoursSafe(veh)

    local hasCustomColor = (customR ~= 0 or customG ~= 0 or customB ~= 0)
    originalColors[veh] = {
        hasCustom = hasCustomColor,
        customColor = {customR, customG, customB},
        primaryIndex = primaryIndex,
        secondaryIndex = secondaryIndex,
        pearlescentIndex = pearlescentIndex,
        wheelColor = wheelColor,
        isFaded = false
    }

    notify("~g~Original color saved!")
end

local function ToggleFade()
    if not isWhitelisted then
        notify("~r~You are not authorized to use ColorFade.")
        return
    end

    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 or not DoesEntityExist(veh) then
        notify("~r~You must be in a vehicle to use this.")
        return
    end

    if originalColors[veh] == nil then
        local saveKey = GetKeyMappingDisplayName("colorfade_savecolor")
        notify(("~y~No original color saved! Press %s to save current color first."):format(saveKey))
        return
    end

    local orig = originalColors[veh]

    if orig.isFaded then
        -- Restore original color
        local fromR, fromG, fromB = GetVehicleCustomPrimaryColour(veh)

        local toR, toG, toB
        if orig.hasCustom then
            toR, toG, toB = table.unpack(orig.customColor)
        else
            toR, toG, toB = GetColorRGB(orig.primaryIndex)
        end

        Citizen.CreateThread(function()
            FadeVehicle(veh, {fromR, fromG, fromB}, {toR, toG, toB})

            if DoesEntityExist(veh) then
                -- Restore original preset colors
                SetVehicleColours(veh, orig.primaryIndex, orig.secondaryIndex)
                SetVehicleExtraColours(veh, orig.pearlescentIndex, orig.wheelColor)

                if orig.hasCustom then
                    SetVehicleCustomPrimaryColour(veh, toR, toG, toB)
                else
                    ClearVehicleCustomPrimaryColour(veh)
                end
            end
        end)

        originalColors[veh].isFaded = false
        notify("~g~Restoring original vehicle color...")

    else
        -- Fade to selected color
        local fromR, fromG, fromB = GetVehicleCustomPrimaryColour(veh)
        local toR, toG, toB = GetColorRGB(selectedColorIndex)

        Citizen.CreateThread(function()
            FadeVehicle(veh, {fromR, fromG, fromB}, {toR, toG, toB})

            if DoesEntityExist(veh) then
                -- Set primary to selected color, keep original secondary
                SetVehicleColours(veh, selectedColorIndex, orig.secondaryIndex)

                -- Remove pearlescent color (set to 0) when fading to a new color
                SetVehicleExtraColours(veh, 0, orig.wheelColor)

                -- Set custom primary color for the visible fade effect
                SetVehicleCustomPrimaryColour(veh, toR, toG, toB)
            end
        end)

        originalColors[veh].isFaded = true
        notify(("~g~Fading to color: %s"):format(GtaColorList[selectedColorIndex].name or selectedColorIndex))
    end
end

-- Events to receive fade commands from server
RegisterNetEvent("colorfade:applyFade", function(netID, toPrimaryColorIndex)
    local veh = NetworkGetEntityFromNetworkId(netID)
    if veh == 0 or not DoesEntityExist(veh) then return end

    local r, g, b = GetVehicleCustomPrimaryColour(veh)
    local fromColor = {r, g, b}
    local r, g, b = GetColorRGB(toPrimaryColorIndex)
    local toColor = {r, g, b}


    FadeVehicle(veh, fromColor, toColor)
end)

RegisterNetEvent("colorfade:applyFadeRGB", function(netID, r, g, b)
    local veh = NetworkGetEntityFromNetworkId(netID)
    if veh == 0 or not DoesEntityExist(veh) then return end

    local fromR, fromG, fromB = GetVehicleCustomPrimaryColour(veh)
    local fromColor = {fromR, fromG, fromB}
    local toColor = {r, g, b}

    FadeVehicle(veh, fromColor, toColor)
end)

RegisterNetEvent("colorfade:whitelistResult", function(allowed)
    isWhitelisted = allowed
    if allowed then
        local menuKey = GetKeyMappingDisplayName("colorfade_menu")
        local toggleKey = GetKeyMappingDisplayName("colorfade_toggle")
        local saveKey = GetKeyMappingDisplayName("colorfade_savecolor")
        notify(("~g~ColorFade authorized! Press %s to open menu, %s to toggle fade, %s to save original color.")
            :format(menuKey, toggleKey, saveKey))
    else
        notify("~r~You are not authorized to use ColorFade.")
    end
end)

-- On resource start, check whitelist from server
CreateThread(function()
    TriggerServerEvent("colorfade:checkWhitelist")
end)

-- Commands & Key mappings
RegisterCommand("colorfade_menu", OpenMenu)
RegisterCommand("colorfade_toggle", ToggleFade)
RegisterCommand("colorfade_savecolor", SaveOriginalColor)

RegisterKeyMapping("colorfade_menu", "Open Vehicle Color Menu", "keyboard", keybinds.colorfade_menu)
RegisterKeyMapping("colorfade_toggle", "Toggle Vehicle Color Fade", "keyboard", keybinds.colorfade_toggle)
RegisterKeyMapping("colorfade_savecolor", "Save Current Vehicle Color as Original", "keyboard", keybinds.colorfade_savecolor)
