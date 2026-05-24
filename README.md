# MidasUI

MidasUI is a Roblox Luau UI library for building themed windows, tabs, sections, controls, notifications, and dialogs. V1.5 is a stabilization release: it focuses on predictable public APIs, defensive runtime behavior, documentation, and manual QA coverage.

## Loading

For a bundled release hosted as raw text:

```lua
local MidasUI = loadstring(game:HttpGet("RAW_DIST_URL_HERE"))()
```

For a Roblox project containing the modular `src` hierarchy, require the `Init` ModuleScript:

```lua
local MidasUI = require(path.To.MidasUI.Init)
```

`loadstring` and file-backed config profiles depend on the capabilities available in the runtime where the library is executed. The library returns clear config failure values when file APIs are absent.

## Basic Example

```lua
local MidasUI = loadstring(game:HttpGet("RAW_DIST_URL_HERE"))()

local Window = MidasUI:CreateWindow({
	Title = "Settings",
	Theme = "DarkGold",
})

local Main = Window:CreateTab({ Name = "Main", Icon = "home" })
local General = Main:CreateSection("General")

local Enabled = General:CreateToggle({
	Name = "Enabled",
	Flag = "enabled",
	Default = false,
})

General:CreateButton({
	Name = "Apply",
	Callback = function()
		Enabled:Set(true)
		MidasUI:Notify({ Title = "Settings", Content = "Applied." })
	end,
})
```

The shorter runnable beginner sample is [src/Example.lua](src/Example.lua). The full runtime test surface is [src/Showcase.lua](src/Showcase.lua).

## Features

- Windows with tabs, sections, scrolling, resizing, minimize/restore, and cleanup.
- Button, toggle, slider, dropdown, input, keybind, paragraph, and divider elements.
- Controller APIs for changing existing controls safely.
- Flags, simple dependencies, config profiles, built-in and custom themes.
- Runtime theme switching across normal and transient UI.
- Notifications, info/confirm/input dialogs, and per-element tooltips.
- Opt-in debug diagnostics.

## Documentation

- [API reference](docs/API.md)
- [Controllers and flags](docs/CONTROLLERS.md)
- [Config profiles](docs/CONFIG.md)
- [Themes](docs/THEMES.md)
- [Showcase and manual QA](docs/SHOWCASE.md)
- [Changelog](docs/CHANGELOG.md)

## Known Limitations

- Config storage requires compatible `writefile`, `readfile`, and `isfile` runtime APIs; these are not Roblox Studio standard APIs.
- An anonymous theme supplied directly to `SetTheme({ ... })` is normalized at runtime but cannot be restored by name from a config. Register it first when persistence is needed.
- Keybind elements use their `Flag` as their registry identity; assign a unique flag to each independently triggered keybind.
- QA is primarily manual in a Roblox runtime; static parser checks do not replace in-game interaction testing.
