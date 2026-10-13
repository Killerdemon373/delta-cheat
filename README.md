# Delta Scripts

Collection of Roblox Lua utilities and UI helpers for Delta executor.

## Scripts

| File | Description |
|------|-------------|
| `Speed_Library.lua` | Full UI library (tabs, sections, toggles, etc.) |
| `Speed_Extras.lua` | Keybinds, config save/load, color picker, search |
| `trade_strength.lua` | Trade Strength helper |
| `muscle_legends.lua` | Muscle Legends helper |
| `delta_cheat.lua` | Universal tools |
| `afk.lua` | Anti-idle / stay online |

## How to use

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Killerdemon373/delta-cheat/main/SCRIPT_NAME.lua"))()
```

Replace `SCRIPT_NAME` with the file you want.

## UI Library

```lua
local Speed_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Killerdemon373/delta-cheat/main/Speed_Library.lua"))()
local Window = Speed_Library:CreateWindow({Title = "My Script", Description = "v1"})
```

## Notes

- For educational and personal use
- Works with Delta executor
