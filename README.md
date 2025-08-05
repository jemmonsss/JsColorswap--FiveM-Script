# JsColorswap |FiveM Script

This script provides a smooth, customizable vehicle color fading system for FiveM servers. Authorized players can open a color selection menu, pick a GTA color, and toggle a fade effect that transitions their vehicle's color smoothly between its original color and the selected color.

## Features

- **Whitelist-based access control** to restrict usage to authorized players.
- **Interactive in-game menu** to browse and select from the full list of GTA vehicle colors.
- **Smooth color fade animations** using linear interpolation of RGB values.
- **Save and restore original vehicle colors**, including custom RGB colors and preset colors.
- **Configurable keybinds** for opening the menu, toggling fade, and saving colors.
- **Network synchronization** to keep vehicle color fades consistent for all players.
- Safe native function calls to avoid crashes.
- User notifications for clear feedback.

## Default Controls

- `F7` - Open the vehicle color selection menu.
- `F6` - Toggle vehicle color fade effect.
- `F8` - Save the current vehicle color as the original color.

## Installation

1. Add the script to your FiveM resource folder.
2. Configure `Config.AllowedIdentifiers` with your server's authorized player license identifiers.
3. Start the resource in your server config.

## Configuration

- Whitelisted player identifiers in `Config.AllowedIdentifiers`.
- Default keybinds can be customized in `keybinds` table or `Config`.

## Usage

- Enter a vehicle and press `F8` to save its current color.
- Press `F7` to open the color selection menu and pick a color.
- Press `F6` to toggle the color fade between the original and selected color.

---

This script was made to mess with my friend in a private server im not too sure how well it will work nor how laggy it is (Even tho its worked fine for me so far just want to make a disclamer incase lol) 

