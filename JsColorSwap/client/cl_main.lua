local isWhitelisted = false
local selectedColorIndex = 0

local keybinds = {
    colorfade_menu = "F7",
    colorfade_toggle = "F6",
    colorfade_savecolor = "F8"
}

local function GetKeyMappingDisplayName(command)
    return keybinds[command] or "Unbound"
end

local originalColors = {} -- Store original colors per vehicle key
local activeFadeTokens = {}
local pendingFadeRequests = {}

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
    return 0, 0, 0
end

local function GetColorName(colorIndex)
    local c = GtaColorList[colorIndex]
    return (c and c.name) or ("ID " .. tostring(colorIndex))
end

local function clamp255(n)
    n = tonumber(n) or 0
    n = math.floor(n)
    if n < 0 then return 0 end
    if n > 255 then return 255 end
    return n
end

local function lerp(a, b, t)
    return a + ((b - a) * t)
end

local function smoothStep(t)
    if t < 0 then return 0 end
    if t > 1 then return 1 end
    return t * t * (3 - (2 * t))
end

local function clampColorIndex(idx)
    idx = tonumber(idx) or 0
    idx = math.floor(idx)
    local maxIdx = (Config and Config.MaxVehicleColors) or 160
    if idx < 0 then idx = 0 end
    if idx > maxIdx then idx = maxIdx end
    return idx
end

local function normalizeMenuColorIndex(idx, fallback)
    idx = clampColorIndex(idx)
    if GtaColorList[idx] then
        return idx
    end

    fallback = clampColorIndex(fallback or selectedColorIndex or 0)
    if GtaColorList[fallback] then
        return fallback
    end

    return colorIdxs[1] or 0
end

local function GetColorRGBOrFallback(colorIndex, fallbackR, fallbackG, fallbackB)
    local c = GtaColorList[colorIndex]
    if c and c.rgb then
        return c.rgb[1], c.rgb[2], c.rgb[3]
    end
    return fallbackR or 0, fallbackG or 0, fallbackB or 0
end

local function GetVehiclePrimaryColourSafe(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return 0 -- default color black
    end
    local success, primaryColour = pcall(function()
        local primary = GetVehicleColours(vehicle)
        return primary
    end)
    if success and primaryColour ~= nil then
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
        local _, secondary = GetVehicleColours(vehicle)
        return secondary
    end)
    if success and secondaryColour ~= nil then
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

local function GetVehicleColoursSafe(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return 0, 0
    end
    local ok, p, s = pcall(function()
        return GetVehicleColours(vehicle)
    end)
    if ok and p ~= nil then
        return p or 0, s or 0
    end
    return 0, 0
end

local function MakeVehicleEntityKey(vehicle)
    return ("entity:%d"):format(vehicle or 0)
end

local function MakeVehicleNetKey(netId)
    return ("net:%d"):format(netId or 0)
end

local function EnsureVehicleNetId(vehicle, timeoutMs)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return nil
    end

    local timeoutAt = GetGameTimer() + (timeoutMs or 0)

    repeat
        if not NetworkGetEntityIsNetworked(vehicle) then
            NetworkRegisterEntityAsNetworked(vehicle)
        end

        if NetworkGetEntityIsNetworked(vehicle) then
            local netId = NetworkGetNetworkIdFromEntity(vehicle)
            if netId and netId ~= 0 then
                return netId
            end
        end

        if GetGameTimer() >= timeoutAt then
            break
        end

        Wait(0)
    until false

    return nil
end

local function GetExistingVehicleNetId(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return nil
    end
    if not NetworkGetEntityIsNetworked(vehicle) then
        return nil
    end
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if netId and netId ~= 0 then
        return netId
    end
    return nil
end

local function GetVehicleStateKey(vehicle, netId)
    if netId then
        return MakeVehicleNetKey(netId)
    end

    local existingNetId = GetExistingVehicleNetId(vehicle)
    if existingNetId then
        return MakeVehicleNetKey(existingNetId), existingNetId
    end

    return MakeVehicleEntityKey(vehicle), nil
end

local function CaptureOriginalColor(vehicle, key, netId, targetColorIndex)
    local hasCustomColor = GetIsVehiclePrimaryColourCustom(vehicle)
    local customR, customG, customB = GetVehicleCustomPrimaryColour(vehicle)
    local primaryIndex = GetVehiclePrimaryColourSafe(vehicle)
    local secondaryIndex = GetVehicleSecondaryColourSafe(vehicle)
    local pearlescentIndex, wheelColor = GetVehicleExtraColoursSafe(vehicle)

    return {
        key = key,
        entity = vehicle,
        netId = netId,
        ts = GetGameTimer(),
        hasCustom = hasCustomColor,
        customColor = {customR, customG, customB},
        primaryIndex = primaryIndex,
        secondaryIndex = secondaryIndex,
        pearlescentIndex = pearlescentIndex,
        wheelColor = wheelColor,
        targetColorIndex = normalizeMenuColorIndex(targetColorIndex, selectedColorIndex),
        isFaded = false
    }
end

local function GetSavedOriginalColor(vehicle, netId)
    local key = GetVehicleStateKey(vehicle, netId)
    local entityKey = MakeVehicleEntityKey(vehicle)
    local saved = originalColors[key]

    if not saved and key ~= entityKey then
        saved = originalColors[entityKey]
        if saved then
            originalColors[key] = saved
            originalColors[entityKey] = nil
        end
    end

    if saved then
        saved.key = key
        saved.entity = vehicle
        saved.netId = netId or saved.netId
        saved.ts = GetGameTimer()
    end

    return saved, key
end

local function SetSavedVehicleTargetColor(vehicle, colorIndex)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return
    end

    local netId = GetExistingVehicleNetId(vehicle)
    local saved, key = GetSavedOriginalColor(vehicle, netId)
    if not saved then
        saved = CaptureOriginalColor(vehicle, key, netId, colorIndex)
        originalColors[key] = saved
    end

    saved.targetColorIndex = normalizeMenuColorIndex(colorIndex)
    saved.ts = GetGameTimer()
end

local function EnsureEntityControl(entity, timeoutMs)
    if entity == 0 or not DoesEntityExist(entity) then
        return false
    end
    if NetworkHasControlOfEntity(entity) then
        return true
    end
    local timeoutAt = GetGameTimer() + (timeoutMs or 500)
    NetworkRequestControlOfEntity(entity)
    while not NetworkHasControlOfEntity(entity) and GetGameTimer() < timeoutAt do
        Wait(0)
        NetworkRequestControlOfEntity(entity)
    end
    return NetworkHasControlOfEntity(entity)
end

local function GetVisiblePrimaryRGB(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return 255, 255, 255
    end

    if GetIsVehiclePrimaryColourCustom(vehicle) then
        local r, g, b = GetVehicleCustomPrimaryColour(vehicle)
        return r, g, b
    end

    local primaryIdx = GetVehiclePrimaryColourSafe(vehicle)
    return GetColorRGB(primaryIdx)
end

local function CaptureVehicleNeonState(veh)
    if (Config and Config.FadeNeonGlow) == false then
        return nil
    end

    local okColor, r, g, b = pcall(function()
        return GetVehicleNeonLightsColour(veh)
    end)
    if not okColor then
        return nil
    end

    local state = {
        color = { r or 255, g or 255, b or 255 },
        enabled = {}
    }

    for i = 0, 3 do
        local okEnabled, enabled = pcall(function()
            return IsVehicleNeonLightEnabled(veh, i)
        end)
        state.enabled[i] = okEnabled and enabled == true
    end

    return state
end

local function SetFadeNeon(veh, r, g, b)
    if (Config and Config.FadeNeonGlow) == false then
        return
    end

    pcall(function()
        for i = 0, 3 do
            SetVehicleNeonLightEnabled(veh, i, true)
        end
        SetVehicleNeonLightsColour(veh, clamp255(r), clamp255(g), clamp255(b))
    end)
end

local function RestoreVehicleNeonState(veh, state)
    if not state or veh == 0 or not DoesEntityExist(veh) then
        return
    end

    pcall(function()
        for i = 0, 3 do
            SetVehicleNeonLightEnabled(veh, i, state.enabled[i] == true)
        end
        SetVehicleNeonLightsColour(veh, state.color[1] or 255, state.color[2] or 255, state.color[3] or 255)
    end)
end

local function GetCyberpunkFadeRGB(fromP, toP, t, now, startTime)
    local eased = smoothStep(t)
    local r = lerp(fromP[1], toP[1], eased)
    local g = lerp(fromP[2], toP[2], eased)
    local b = lerp(fromP[3], toP[3], eased)

    if (Config and Config.FadeCyberpunkStyle) == false then
        return clamp255(r), clamp255(g), clamp255(b)
    end

    local elapsed = now - startTime
    local envelope = math.sin(t * math.pi)
    local pulse = ((math.sin(elapsed / 70) + 1) * 0.5) ^ 2
    local glitch = ((math.floor(elapsed / 115) % 6) == 0) and 0.35 or 0
    local amount = ((Config and Config.FadePulseStrength) or 0.28) * envelope * (pulse + glitch)

    if amount > 0 then
        local useCyan = (math.floor(elapsed / 180) % 2) == 0
        local accentR = useCyan and 0 or 255
        local accentG = useCyan and 245 or 20
        local accentB = useCyan and 255 or 210

        accentR = lerp(toP[1], accentR, 0.55)
        accentG = lerp(toP[2], accentG, 0.55)
        accentB = lerp(toP[3], accentB, 0.55)

        r = lerp(r, accentR, amount)
        g = lerp(g, accentG, amount)
        b = lerp(b, accentB, amount)
    end

    return clamp255(r), clamp255(g), clamp255(b)
end

local function FadeVehicle(veh, fromP, toP)
    local fadeKey = GetVehicleStateKey(veh)
    activeFadeTokens[fadeKey] = (activeFadeTokens[fadeKey] or 0) + 1
    local token = activeFadeTokens[fadeKey]

    local startTime = GetGameTimer()
    local duration = (Config and Config.FadeDurationMs) or 2500
    local step = (Config and Config.FadeStepMs) or 15
    local neonState = CaptureVehicleNeonState(veh)

    while GetGameTimer() < startTime + duration do
        if activeFadeTokens[fadeKey] ~= token then
            return false
        end
        if veh == 0 or not DoesEntityExist(veh) then
            return false
        end
        local now = GetGameTimer()
        local t = (now - startTime) / duration

        local r, g, b = GetCyberpunkFadeRGB(fromP, toP, t, now, startTime)

        SetVehicleCustomPrimaryColour(veh, r, g, b)
        SetFadeNeon(veh, r, g, b)
        Wait(step)
    end

    if activeFadeTokens[fadeKey] ~= token then
        return false
    end

    SetVehicleCustomPrimaryColour(veh, toP[1], toP[2], toP[3])
    Wait(120)
    if activeFadeTokens[fadeKey] ~= token then
        return false
    end

    RestoreVehicleNeonState(veh, neonState)
    activeFadeTokens[fadeKey] = nil
    return true
end

local function ApplyVehiclePaintState(veh, primaryIdx, secondaryIdx, pearlescentIdx, wheelIdx, hasCustom, customColor)
    if veh == 0 or not DoesEntityExist(veh) then
        return
    end

    primaryIdx = clampColorIndex(primaryIdx or 0)
    secondaryIdx = clampColorIndex(secondaryIdx or 0)
    pearlescentIdx = clampColorIndex(pearlescentIdx or 0)
    wheelIdx = clampColorIndex(wheelIdx or 0)

    if hasCustom and type(customColor) == "table" then
        SetVehicleColours(veh, primaryIdx, secondaryIdx)
        SetVehicleExtraColours(veh, pearlescentIdx, wheelIdx)
        SetVehicleCustomPrimaryColour(veh, customColor[1] or 0, customColor[2] or 0, customColor[3] or 0)
    else
        ClearVehicleCustomPrimaryColour(veh)
        SetVehicleColours(veh, primaryIdx, secondaryIdx)
        SetVehicleExtraColours(veh, pearlescentIdx, wheelIdx)
        ClearVehicleCustomPrimaryColour(veh)
    end
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

local function DrawTextLeft(x, y, text, scale, r, g, b, font)
    SetTextFont(font or 0)
    SetTextProportional(1)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(false)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

local function DrawTextRight(x, y, text, scale, r, g, b, font)
    SetTextFont(font or 0)
    SetTextProportional(1)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextWrap(0.0, x)
    SetTextRightJustify(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

local function playMenuSound(soundName)
    if (Config and Config.MenuSounds) == false then
        return
    end
    local soundSet = (Config and Config.MenuSoundSet) or "HUD_FRONTEND_DEFAULT_SOUNDSET"
    if not soundName or soundName == "" then
        return
    end
    PlaySoundFrontend(-1, soundName, soundSet, true)
end

local menuControls = {
    fast = { 21 }, -- SHIFT
    up = { 172, 188, 241 },
    down = { 173, 187, 242 },
    catPrev = { 44, 174, 189, 205 },
    catNext = { 38, 175, 190, 206 },
    select = { 176, 191, 201 },
    back = { 177, 194, 202 }
}

local menuControlGroups = { 0, 2 }

local menuControlBlocklist = {
    21, 38, 44,
    172, 173, 174, 175, 176, 177,
    187, 188, 189, 190, 191, 194,
    201, 202, 205, 206, 241, 242
}

local function disableMenuControls()
    for _, group in ipairs(menuControlGroups) do
        for _, control in ipairs(menuControlBlocklist) do
            DisableControlAction(group, control, true)
        end
    end
end

local function isAnyMenuControlPressed(controls)
    for _, group in ipairs(menuControlGroups) do
        for _, control in ipairs(controls) do
            if IsControlPressed(group, control) or IsDisabledControlPressed(group, control) then
                return true
            end
        end
    end
    return false
end

local function isAnyMenuControlJustPressed(controls)
    for _, group in ipairs(menuControlGroups) do
        for _, control in ipairs(controls) do
            if IsControlJustPressed(group, control) or IsDisabledControlJustPressed(group, control) then
                return true
            end
        end
    end
    return false
end

local menuState = {
    open = false,
    cur = 1,
    top = 1,
    pageSize = 12,
    lastHoverIdx = nil,
    previewRestore = nil,
    blurApplied = false,
    animStart = 0,
    animDir = 1,
    anim = 0,
    closing = false,
    category = 1
}

local function easeOutCubic(t)
    if t < 0 then return 0 end
    if t > 1 then return 1 end
    local inv = 1 - t
    return 1 - (inv * inv * inv)
end

local function colorCategoryName(name)
    name = (name or ""):lower()
    if name:find("black") then return "Black" end
    if name:find("white") or name:find("frost") or name:find("ice") or name:find("cream") then return "White" end
    if name:find("silver") or name:find("steel") or name:find("chrome") or name:find("gray") or name:find("graphite") then return "Metal" end
    if name:find("gold") or name:find("bronze") then return "Gold" end
    if name:find("red") or name:find("garnet") or name:find("wine") or name:find("cabernet") then return "Red" end
    if name:find("pink") then return "Pink" end
    if name:find("orange") then return "Orange" end
    if name:find("yellow") then return "Yellow" end
    if name:find("green") or name:find("olive") or name:find("lime") then return "Green" end
    if name:find("blue") or name:find("navy") then return "Blue" end
    if name:find("purple") then return "Purple" end
    return "Other"
end

local function buildMenuCategories()
    local buckets = {
        { name = "All", indices = {} },
        { name = "Red", indices = {} },
        { name = "Pink", indices = {} },
        { name = "Orange", indices = {} },
        { name = "Yellow", indices = {} },
        { name = "Green", indices = {} },
        { name = "Blue", indices = {} },
        { name = "Purple", indices = {} },
        { name = "White", indices = {} },
        { name = "Black", indices = {} },
        { name = "Metal", indices = {} },
        { name = "Gold", indices = {} },
        { name = "Other", indices = {} }
    }

    local byName = {}
    for i, cat in ipairs(buckets) do
        byName[cat.name] = i
    end

    for _, idx in ipairs(colorIdxs) do
        table.insert(buckets[1].indices, idx)
        local entry = GtaColorList[idx]
        local catName = colorCategoryName(entry and entry.name)
        local bucketIdx = byName[catName] or byName.Other
        table.insert(buckets[bucketIdx].indices, idx)
    end

    -- Strip empty categories (except All)
    local out = { buckets[1] }
    for i = 2, #buckets do
        if #buckets[i].indices > 0 then
            table.insert(out, buckets[i])
        end
    end
    return out
end

local function applyMenuBlur(enable)
    if not (Config and Config.MenuBlur) then
        return
    end

    if enable and not menuState.blurApplied then
        SetTimecycleModifier("hud_def_blur")
        SetTimecycleModifierStrength(1.0)
        menuState.blurApplied = true
    elseif (not enable) and menuState.blurApplied then
        ClearTimecycleModifier()
        menuState.blurApplied = false
    end
end

local function captureVehiclePreviewRestore(veh)
    if veh == 0 or not DoesEntityExist(veh) then
        return nil
    end

    local restore = {
        hasCustom = GetIsVehiclePrimaryColourCustom(veh),
        custom = { GetVehicleCustomPrimaryColour(veh) },
        primaryIdx = GetVehiclePrimaryColourSafe(veh),
        secondaryIdx = GetVehicleSecondaryColourSafe(veh)
    }
    return restore
end

local function restoreVehiclePreview(veh, restore)
    if not restore or veh == 0 or not DoesEntityExist(veh) then
        return
    end

    SetVehicleColours(veh, restore.primaryIdx or 0, restore.secondaryIdx or 0)
    if restore.hasCustom then
        SetVehicleCustomPrimaryColour(veh, restore.custom[1] or 0, restore.custom[2] or 0, restore.custom[3] or 0)
    else
        ClearVehicleCustomPrimaryColour(veh)
    end
end

local function previewVehicleColorIfEnabled(veh, colorIndex)
    if not (Config and Config.MenuPreviewOnVehicle) then
        return
    end
    if veh == 0 or not DoesEntityExist(veh) then
        return
    end
    local r, g, b = GetColorRGB(colorIndex)
    SetVehicleCustomPrimaryColour(veh, r, g, b)
end

local function OpenMenu()
    if not isWhitelisted then
        notify("~r~You are not authorized to use ColorFade.")
        return
    end
    if menuState.open then
        return
    end

    menuState.open = true
    menuState.closing = false
    menuState.cur = 1
    menuState.top = 1
    menuState.pageSize = (Config and Config.MenuPageSize) or 12
    menuState.lastHoverIdx = nil
    menuState.previewRestore = nil
    menuState.category = 1
    menuState.animStart = GetGameTimer()
    menuState.animDir = 1
    menuState.anim = 0

    applyMenuBlur(true)

    playMenuSound((Config and Config.MenuSoundOpen) or "SELECT")

    local categories = buildMenuCategories()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= 0 and DoesEntityExist(veh) then
        local saved = GetSavedOriginalColor(veh, GetExistingVehicleNetId(veh))
        if saved and saved.targetColorIndex then
            selectedColorIndex = normalizeMenuColorIndex(saved.targetColorIndex)
            local allColors = categories[1] and categories[1].indices or {}
            for i, colorIndex in ipairs(allColors) do
                if colorIndex == selectedColorIndex then
                    menuState.cur = i
                    menuState.top = math.max(1, i - math.floor(menuState.pageSize / 2))
                    break
                end
            end
        end
    end

    Citizen.CreateThread(function()
        while menuState.open do
            Citizen.Wait(0)

            local animMs = (Config and Config.MenuAnimationMs) or 180
            local t = (GetGameTimer() - (menuState.animStart or 0)) / animMs
            local eased = easeOutCubic(t)
            if menuState.animDir == 1 then
                menuState.anim = eased
            else
                menuState.anim = 1 - eased
                if menuState.anim <= 0.01 then
                    menuState.open = false
                    break
                end
            end

            local ped = PlayerPedId()
            local veh = GetVehiclePedIsIn(ped, false)

            -- Capture restore state once (for optional preview-on-vehicle)
            if (Config and Config.MenuPreviewOnVehicle) and menuState.previewRestore == nil and veh ~= 0 and DoesEntityExist(veh) then
                menuState.previewRestore = captureVehiclePreviewRestore(veh)
            end

            disableMenuControls()

            -- Inputs (support both keyboard and GTA frontend controls)
            local inputsLocked = menuState.closing == true
            local accel = isAnyMenuControlPressed(menuControls.fast)
            local step = accel and 10 or 1

            local up = (not inputsLocked) and isAnyMenuControlJustPressed(menuControls.up)
            local down = (not inputsLocked) and isAnyMenuControlJustPressed(menuControls.down)
            local catPrev = (not inputsLocked) and isAnyMenuControlJustPressed(menuControls.catPrev)
            local catNext = (not inputsLocked) and isAnyMenuControlJustPressed(menuControls.catNext)
            local select = (not inputsLocked) and isAnyMenuControlJustPressed(menuControls.select)
            local back = (not inputsLocked) and isAnyMenuControlJustPressed(menuControls.back)

            local enableCats = (Config and Config.MenuEnableCategories) ~= false
            local activeCategory = categories[menuState.category] or categories[1]
            local activeList = activeCategory.indices
            local total = #activeList
            if total < 1 then
                menuState.cur = 1
                menuState.top = 1
            else
                if menuState.cur < 1 then menuState.cur = 1 end
                if menuState.cur > total then menuState.cur = total end
            end

            if enableCats and (catPrev or catNext) then
                playMenuSound((Config and Config.MenuSoundTab) or "NAV_LEFT_RIGHT")
                local oldSelected = activeList[menuState.cur]
                if catPrev then
                    menuState.category = menuState.category - 1
                    if menuState.category < 1 then menuState.category = #categories end
                else
                    menuState.category = menuState.category + 1
                    if menuState.category > #categories then menuState.category = 1 end
                end
                activeCategory = categories[menuState.category] or categories[1]
                activeList = activeCategory.indices
                total = #activeList
                menuState.top = 1

                -- Keep selection close when switching categories
                menuState.cur = 1
                if oldSelected and total > 0 then
                    for i = 1, total do
                        if activeList[i] == oldSelected then
                            menuState.cur = i
                            break
                        end
                    end
                end
            elseif up and total > 0 then
                playMenuSound((Config and Config.MenuSoundNav) or "NAV_UP_DOWN")
                menuState.cur = menuState.cur - step
                if menuState.cur < 1 then
                    menuState.cur = total
                    menuState.top = math.max(1, total - menuState.pageSize + 1)
                end
            elseif down and total > 0 then
                playMenuSound((Config and Config.MenuSoundNav) or "NAV_UP_DOWN")
                menuState.cur = menuState.cur + step
                if menuState.cur > total then
                    menuState.cur = 1
                    menuState.top = 1
                end
            elseif select then
                playMenuSound((Config and Config.MenuSoundSelect) or "SELECT")
                if total > 0 then
                    selectedColorIndex = normalizeMenuColorIndex(activeList[menuState.cur])
                    SetSavedVehicleTargetColor(veh, selectedColorIndex)
                    notify("~g~Selected: " .. GetColorName(selectedColorIndex))
                end
                menuState.closing = true
                menuState.animStart = GetGameTimer()
                menuState.animDir = -1
            elseif back then
                playMenuSound((Config and Config.MenuSoundBack) or "BACK")
                menuState.closing = true
                menuState.animStart = GetGameTimer()
                menuState.animDir = -1
            end

            -- Scroll window
            if total > 0 then
                if menuState.cur < menuState.top then
                    menuState.top = menuState.cur
                elseif menuState.cur > (menuState.top + menuState.pageSize - 1) then
                    menuState.top = menuState.cur - menuState.pageSize + 1
                end
            else
                menuState.top = 1
            end

            -- Layout
            local panelX = 0.5
            local baseY = 0.52
            local panelW, panelH = 0.62, 0.62
            local headerH = 0.08
            local footerH = 0.06
            local listW = 0.34
            local infoW = panelW - listW - 0.04

            local anim = menuState.anim or 1
            local panelY = baseY + ((1 - anim) * 0.06)
            local alphaBg = math.floor(190 * anim)
            local alphaHeader = math.floor(220 * anim)
            local alphaFooter = math.floor(220 * anim)

            -- Background
            DrawRect(panelX, panelY, panelW, panelH, 0, 0, 0, alphaBg)
            -- Header bar (slightly blue-ish like GTA)
            DrawRect(panelX, panelY - (panelH / 2) + (headerH / 2), panelW, headerH, 15, 25, 40, alphaHeader)
            DrawTextLeft(panelX - (panelW / 2) + 0.02, panelY - (panelH / 2) + 0.02, "COLORFADE", 0.55, 255, 255, 255, 4)
            DrawTextRight(panelX + (panelW / 2) - 0.02, panelY - (panelH / 2) + 0.02, ("%d / %d"):format(menuState.cur, math.max(1, total)), 0.45, 200, 200, 200, 0)
            DrawTextLeft(panelX - (panelW / 2) + 0.02, panelY - (panelH / 2) + 0.055, "Vehicle Primary Color", 0.35, 200, 200, 200, 0)

            -- Category tabs
            if enableCats and #categories > 1 then
                local tabY = panelY - (panelH / 2) + headerH + 0.006
                local tabH = 0.028
                local totalTabs = #categories
                local tabW = (panelW - 0.04) / totalTabs
                for i = 1, totalTabs do
                    local tabX = (panelX - (panelW / 2) + 0.02) + ((i - 0.5) * tabW)
                    if i == menuState.category then
                        DrawRect(tabX, tabY + (tabH / 2), tabW - 0.004, tabH, 40, 120, 200, math.floor(170 * anim))
                        DrawText(tabX, tabY + 0.004, categories[i].name, 0.30, 255, 255, 255)
                    else
                        DrawRect(tabX, tabY + (tabH / 2), tabW - 0.004, tabH, 255, 255, 255, math.floor(18 * anim))
                        DrawText(tabX, tabY + 0.004, categories[i].name, 0.30, 200, 200, 200)
                    end
                end
            end

            -- Footer help
            DrawRect(panelX, panelY + (panelH / 2) - (footerH / 2), panelW, footerH, 0, 0, 0, alphaFooter)
            local legend = "~INPUT_FRONTEND_UP~/~INPUT_FRONTEND_DOWN~ Navigate"
            if enableCats and #categories > 1 then
                legend = legend .. "   ~INPUT_FRONTEND_LB~/~INPUT_FRONTEND_RB~ Category"
            else
                legend = legend .. "   Q/E Category"
            end
            legend = legend .. "   ~INPUT_FRONTEND_ACCEPT~ Select   ~INPUT_FRONTEND_CANCEL~ Back   (Hold SHIFT to scroll fast)"
            DrawTextLeft(panelX - (panelW / 2) + 0.02, panelY + (panelH / 2) - 0.045, legend, 0.33, 220, 220, 220, 0)

            -- List panel
            local listX = panelX - (panelW / 2) + (listW / 2) + 0.02
            local listY = panelY
            local listH = panelH - headerH - footerH - 0.03
            DrawRect(listX, listY + 0.02, listW, listH, 0, 0, 0, 120)

            -- Visible rows
            local startIdx = menuState.top
            local endIdx = math.min(total, startIdx + menuState.pageSize - 1)
            local rowH = listH / menuState.pageSize

            if total < 1 then
                DrawText(listX, listY, "No colors", 0.45, 200, 200, 200)
            end

            for i = startIdx, endIdx do
                local row = (i - startIdx)
                local y = (listY - (listH / 2)) + 0.04 + (row * rowH)

                local colorIndex = activeList[i]
                local colorName = GtaColorList[colorIndex].name or ("ID: " .. colorIndex)

                if i == menuState.cur then
                    local baseA = 160
                    if (Config and Config.MenuPulseHighlight) ~= false then
                        local pulse = (math.sin(GetGameTimer() / 180) + 1) * 0.5
                        baseA = 130 + math.floor(pulse * 70)
                    end
                    DrawRect(listX, y + (rowH / 2), listW - 0.02, rowH * 0.9, 40, 120, 200, math.floor(baseA * anim))
                    DrawTextLeft(listX - (listW / 2) + 0.02, y + 0.005, colorName, 0.40, 255, 255, 255, 0)
                else
                    DrawTextLeft(listX - (listW / 2) + 0.02, y + 0.005, colorName, 0.40, 220, 220, 220, 0)
                end
            end

            -- Scrollbar
            if total > menuState.pageSize then
                local sbX = listX + (listW / 2) - 0.008
                local sbY = listY + 0.02
                DrawRect(sbX, sbY, 0.006, listH, 255, 255, 255, 25)
                local ratio = menuState.pageSize / total
                local thumbH = math.max(0.03, listH * ratio)
                local posRatio = (menuState.top - 1) / math.max(1, (total - menuState.pageSize))
                local thumbCenterY = (sbY - (listH / 2)) + (thumbH / 2) + (posRatio * (listH - thumbH))
                DrawRect(sbX, thumbCenterY, 0.006, thumbH, 180, 180, 180, 180)
            end

            -- Info panel (preview swatch + details)
            local infoX = panelX + (panelW / 2) - (infoW / 2) - 0.02
            local infoY = panelY + 0.02
            DrawRect(infoX, infoY, infoW, listH, 0, 0, 0, 120)

            local hoverColorIndex = activeList[menuState.cur] or activeList[1] or 0
            local r, g, b = GetColorRGB(hoverColorIndex)
            DrawRect(infoX, (infoY - (listH / 2)) + 0.12, infoW - 0.06, 0.12, r, g, b, 220)
            DrawRect(infoX, (infoY - (listH / 2)) + 0.12, infoW - 0.06, 0.12, 255, 255, 255, 30)

            DrawTextLeft(infoX - (infoW / 2) + 0.03, (infoY - (listH / 2)) + 0.20, "Preview", 0.42, 255, 255, 255, 0)
            DrawTextLeft(infoX - (infoW / 2) + 0.03, (infoY - (listH / 2)) + 0.24,
                ("Name: %s"):format(GtaColorList[hoverColorIndex].name or "Unknown"), 0.36, 220, 220, 220, 0)
            DrawTextLeft(infoX - (infoW / 2) + 0.03, (infoY - (listH / 2)) + 0.275,
                ("Index: %d"):format(hoverColorIndex), 0.36, 220, 220, 220, 0)
            DrawTextLeft(infoX - (infoW / 2) + 0.03, (infoY - (listH / 2)) + 0.31,
                ("RGB: %d, %d, %d"):format(r, g, b), 0.36, 220, 220, 220, 0)

            if Config and Config.MenuPreviewOnVehicle then
                DrawTextLeft(infoX - (infoW / 2) + 0.03, (infoY - (listH / 2)) + 0.36,
                    "Vehicle preview: ON", 0.36, 150, 220, 150, 0)
            else
                DrawTextLeft(infoX - (infoW / 2) + 0.03, (infoY - (listH / 2)) + 0.36,
                    "Vehicle preview: OFF", 0.36, 220, 180, 120, 0)
            end

            local toggleKey = GetKeyMappingDisplayName("colorfade_toggle")
            local saveKey = GetKeyMappingDisplayName("colorfade_savecolor")
            DrawTextLeft(infoX - (infoW / 2) + 0.03, (infoY - (listH / 2)) + 0.42,
                ("Tip: Press %s to toggle fade"):format(toggleKey), 0.34, 200, 200, 200, 0)
            DrawTextLeft(infoX - (infoW / 2) + 0.03, (infoY - (listH / 2)) + 0.455,
                ("Tip: Press %s to save original"):format(saveKey), 0.34, 200, 200, 200, 0)

            -- Optional vehicle preview-on-hover
            if menuState.lastHoverIdx ~= hoverColorIndex then
                menuState.lastHoverIdx = hoverColorIndex
                if veh ~= 0 and DoesEntityExist(veh) then
                    previewVehicleColorIfEnabled(veh, hoverColorIndex)
                end
            end
        end

        -- Close cleanup
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)
        if veh ~= 0 and DoesEntityExist(veh) then
            restoreVehiclePreview(veh, menuState.previewRestore)
        end

        playMenuSound((Config and Config.MenuSoundClose) or "BACK")

        applyMenuBlur(false)
    end)
end

local function SaveOriginalColor()
    if not isWhitelisted then
        notify("~r~You are not authorized to use ColorFade.")
        return
    end

    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 or not DoesEntityExist(veh) then
        notify("~r~You must be in a vehicle to save its color.")
        return
    end

    if Config and Config.RequireDriverSeat then
        if GetPedInVehicleSeat(veh, -1) ~= ped then
            notify("~r~You must be the driver to use this.")
            return
        end
    end

    local netId = nil
    if Config and Config.EnableSync then
        netId = EnsureVehicleNetId(veh, 1500)
        if not netId then
            notify("~y~Vehicle is still getting ready. Try again in a moment.")
            return
        end
    end

    local existing, key = GetSavedOriginalColor(veh, netId)
    local targetColorIndex = normalizeMenuColorIndex(existing and existing.targetColorIndex or selectedColorIndex)
    originalColors[key] = CaptureOriginalColor(veh, key, netId, targetColorIndex)

    notify(("~g~Original saved for this vehicle. Fade color: %s"):format(GetColorName(targetColorIndex)))
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

    if Config and Config.RequireDriverSeat then
        if GetPedInVehicleSeat(veh, -1) ~= ped then
            notify("~r~You must be the driver to use this.")
            return
        end
    end

    selectedColorIndex = normalizeMenuColorIndex(selectedColorIndex)

    local syncEnabled = Config and Config.EnableSync
    local netId = nil

    if syncEnabled then
        netId = EnsureVehicleNetId(veh, 2000)
        if not netId then
            notify("~y~Vehicle is still getting ready. Try again in a moment.")
            return
        end

        if not EnsureEntityControl(veh, 1000) then
            notify("~y~Vehicle control is still getting ready. Try again in a moment.")
            return
        end

        if pendingFadeRequests[netId] then
            notify("~y~Fade is already starting for this vehicle.")
            return
        end
    end

    local orig, vehicleKey = GetSavedOriginalColor(veh, netId)
    if not orig then
        orig = CaptureOriginalColor(veh, vehicleKey, netId, selectedColorIndex)
        originalColors[vehicleKey] = orig
    end

    if not orig.targetColorIndex then
        orig.targetColorIndex = normalizeMenuColorIndex(selectedColorIndex)
    end

    local targetColorIndex = normalizeMenuColorIndex(orig.targetColorIndex, selectedColorIndex)
    orig.targetColorIndex = targetColorIndex
    selectedColorIndex = targetColorIndex

    if syncEnabled then
        -- Server tracks toggle state per netId and broadcasts fade.
        pendingFadeRequests[netId] = {
            key = vehicleKey,
            targetColorIndex = targetColorIndex,
            ts = GetGameTimer()
        }

        TriggerServerEvent("colorfade:requestFade", netId, targetColorIndex, {
            hasCustom = orig.hasCustom,
            customColor = orig.customColor,
            primaryIndex = orig.primaryIndex,
            secondaryIndex = orig.secondaryIndex,
            pearlescentIndex = orig.pearlescentIndex,
            wheelColor = orig.wheelColor
        })

        return
    end

    if orig.isFaded then
        -- Restore original color
        local fromR, fromG, fromB = GetVisiblePrimaryRGB(veh)

        local toR, toG, toB
        if orig.hasCustom then
            toR, toG, toB = table.unpack(orig.customColor)
        else
            toR, toG, toB = GetColorRGBOrFallback(orig.primaryIndex, fromR, fromG, fromB)
        end

        Citizen.CreateThread(function()
            if not FadeVehicle(veh, {fromR, fromG, fromB}, {toR, toG, toB}) then
                return
            end

            if DoesEntityExist(veh) then
                -- Restore original preset colors
                ApplyVehiclePaintState(veh, orig.primaryIndex, orig.secondaryIndex, orig.pearlescentIndex, orig.wheelColor,
                    orig.hasCustom, orig.hasCustom and { toR, toG, toB } or nil)
            end
        end)

        orig.isFaded = false
        notify("~g~Restoring original vehicle color...")

    else
        -- Fade to selected color
        local fromR, fromG, fromB = GetVisiblePrimaryRGB(veh)
        local toR, toG, toB = GetColorRGBOrFallback(targetColorIndex, fromR, fromG, fromB)

        Citizen.CreateThread(function()
            if not FadeVehicle(veh, {fromR, fromG, fromB}, {toR, toG, toB}) then
                return
            end

            if DoesEntityExist(veh) then
                -- Set primary to selected color, keep original secondary
                ApplyVehiclePaintState(veh, targetColorIndex, orig.secondaryIndex, 0, orig.wheelColor, false, nil)
            end
        end)

        orig.isFaded = true
        notify(("~g~Fading to color: %s"):format(GetColorName(targetColorIndex)))
    end
end

RegisterNetEvent("colorfade:requestResult", function(ok, netID, isFaded, reason, targetColorIndex)
    netID = tonumber(netID) or 0
    if reason == "" then
        reason = nil
    end
    if targetColorIndex == -1 then
        targetColorIndex = nil
    end

    local pending = pendingFadeRequests[netID]
    if pending then
        pendingFadeRequests[netID] = nil
    end

    if not ok then
        local message = "~r~Unable to fade this vehicle."
        if reason == "not_ready" or reason == "no_vehicle" or reason == "no_netid" then
            message = "~y~Vehicle is still getting ready. Try again in a moment."
        elseif reason == "not_driver" then
            message = "~r~You must be the driver to use this."
        elseif reason == "not_authorized" then
            message = "~r~You are not authorized to use ColorFade."
        end
        notify(message)
        return
    end

    local key = pending and pending.key or MakeVehicleNetKey(netID)
    local orig = originalColors[key]
    if orig then
        orig.isFaded = isFaded == true
        orig.targetColorIndex = normalizeMenuColorIndex(targetColorIndex or orig.targetColorIndex)
        orig.ts = GetGameTimer()
    end

    if isFaded then
        notify(("~g~Fading to color: %s"):format(GetColorName(targetColorIndex or (pending and pending.targetColorIndex) or selectedColorIndex)))
    else
        notify("~g~Restoring original vehicle color...")
    end
end)

RegisterNetEvent("colorfade:applyState", function(netID, state)
    if type(state) ~= "table" then return end

    local veh = NetworkGetEntityFromNetworkId(netID)
    if veh == 0 or not DoesEntityExist(veh) then return end

    Citizen.CreateThread(function()
        EnsureEntityControl(veh, 1500)

        local fromR, fromG, fromB = GetVisiblePrimaryRGB(veh)

        local toR, toG, toB = fromR, fromG, fromB
        if type(state.fadeTo) == "table" then
            if state.fadeTo.type == "rgb" then
                toR = tonumber(state.fadeTo.r) or toR
                toG = tonumber(state.fadeTo.g) or toG
                toB = tonumber(state.fadeTo.b) or toB
            elseif state.fadeTo.type == "index" then
                local idx = clampColorIndex(state.fadeTo.value)
                toR, toG, toB = GetColorRGBOrFallback(idx, fromR, fromG, fromB)
            end
        end

        if not FadeVehicle(veh, { fromR, fromG, fromB }, { toR, toG, toB }) then
            return
        end
        if veh == 0 or not DoesEntityExist(veh) then return end

        local apply = type(state.apply) == "table" and state.apply or {}
        local primaryIdx = clampColorIndex(apply.primaryIndex or 0)
        local secondaryIdx = clampColorIndex(apply.secondaryIndex or 0)
        local pearlIdx = clampColorIndex(apply.pearlescentIndex or 0)
        local wheelIdx = clampColorIndex(apply.wheelColor or 0)

        if apply.hasCustom and type(apply.customColor) == "table" then
            local r = tonumber(apply.customColor[1]) or toR
            local g = tonumber(apply.customColor[2]) or toG
            local b = tonumber(apply.customColor[3]) or toB
            ApplyVehiclePaintState(veh, primaryIdx, secondaryIdx, pearlIdx, wheelIdx, true, { r, g, b })
        else
            ApplyVehiclePaintState(veh, primaryIdx, secondaryIdx, pearlIdx, wheelIdx, false, nil)
        end
    end)
end)

-- Events to receive fade commands from server
RegisterNetEvent("colorfade:applyFade", function(netID, toPrimaryColorIndex)
    local veh = NetworkGetEntityFromNetworkId(netID)
    if veh == 0 or not DoesEntityExist(veh) then return end

    toPrimaryColorIndex = normalizeMenuColorIndex(toPrimaryColorIndex)

    Citizen.CreateThread(function()
        local fromR, fromG, fromB = GetVisiblePrimaryRGB(veh)
        local toR, toG, toB = GetColorRGBOrFallback(toPrimaryColorIndex, fromR, fromG, fromB)
        if not FadeVehicle(veh, {fromR, fromG, fromB}, {toR, toG, toB}) then
            return
        end

        if DoesEntityExist(veh) then
            local _, secondaryIdx = GetVehicleColoursSafe(veh)
            ApplyVehiclePaintState(veh, toPrimaryColorIndex, secondaryIdx, 0, 0, false, nil)
        end
    end)
end)

RegisterNetEvent("colorfade:applyFadeRGB", function(netID, r, g, b)
    local veh = NetworkGetEntityFromNetworkId(netID)
    if veh == 0 or not DoesEntityExist(veh) then return end

    Citizen.CreateThread(function()
        local fromR, fromG, fromB = GetVisiblePrimaryRGB(veh)
        if not FadeVehicle(veh, {fromR, fromG, fromB}, {r, g, b}) then
            return
        end

        if DoesEntityExist(veh) then
            SetVehicleCustomPrimaryColour(veh, r, g, b)
        end
    end)
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

CreateThread(function()
    while true do
        Wait(30 * 1000)
        local now = GetGameTimer()
        local ttlMs = ((Config and Config.FadeStateTTLSeconds) or 600) * 1000

        for key, data in pairs(originalColors) do
            if type(data) ~= "table" then
                originalColors[key] = nil
            elseif data.netId then
                local veh = NetworkGetEntityFromNetworkId(data.netId)
                if veh ~= 0 and DoesEntityExist(veh) then
                    data.entity = veh
                    data.missingSince = nil
                else
                    data.missingSince = data.missingSince or now
                    if now - data.missingSince > ttlMs then
                        originalColors[key] = nil
                    end
                end
            elseif data.entity == 0 or not DoesEntityExist(data.entity) then
                originalColors[key] = nil
            end
        end

        for netId, pending in pairs(pendingFadeRequests) do
            if type(pending) ~= "table" or not pending.ts or now - pending.ts > 10000 then
                pendingFadeRequests[netId] = nil
            end
        end
    end
end)
