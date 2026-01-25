Config = {}

-- When true, fade actions are broadcast to all clients via the server.
-- When false, the fade is local-only (client-side visual only).
Config.EnableSync = true

-- When true, players must be the driver of the vehicle to use fade.
Config.RequireDriverSeat = true

-- Fade behavior
Config.FadeDurationMs = 2500
Config.FadeStepMs = 15

-- Server-side safety: how long to keep per-vehicle fade state (seconds)
Config.FadeStateTTLSeconds = 10 * 60

-- Menu UI options (no dependencies; DrawRect/DrawText based)
Config.MenuBlur = true
Config.MenuPageSize = 12
Config.MenuAnimationMs = 180

-- Menu categories
Config.MenuEnableCategories = true

-- Menu polish
Config.MenuSounds = true
Config.MenuPulseHighlight = true

-- GTA-style audio (Interaction Menu-ish)
-- If you want to try other sets: "HUD_FRONTEND_MP_SOUNDSET", "DLC_HEIST_HACKING_SNAKE_SOUNDS"
Config.MenuSoundSet = "HUD_FRONTEND_DEFAULT_SOUNDSET"
Config.MenuSoundNav = "NAV_UP_DOWN"
Config.MenuSoundTab = "NAV_LEFT_RIGHT"
Config.MenuSoundSelect = "SELECT"
Config.MenuSoundBack = "BACK"
Config.MenuSoundOpen = "SELECT"
Config.MenuSoundClose = "BACK"

-- If true, hovering a color in the menu will temporarily apply it to your current vehicle.
-- Note: vehicle color changes may replicate if you have network control of the vehicle.
Config.MenuPreviewOnVehicle = false

-- Whitelisted player identifiers
Config.AllowedIdentifiers = {
    "license:733427143ead3ec06f6ac051e369d7f62f8ca90c",
    "license:abcdef1234567890"
}

-- Max GTA vehicle primary color index (from native docs, 160+ colors exist)
Config.MaxVehicleColors = 160