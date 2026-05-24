# MidasUI

MidasUI is a premium-styled Roblox Luau UI library for themed windows, controls, notifications, and dialogs. V1.8 adds command-palette discovery, indexed navigation, keyboard workflows, and searchable long dropdowns while preserving the stabilized API.

## Get Started

One line loads the bundled library:

```lua
local MidasUI = loadstring(game:HttpGet("RAW_DIST_URL_HERE"))()
```

Then create a window:

```lua
local Window = MidasUI:CreateWindow({ Title = "Settings", Theme = "DarkGold" })
local Main = Window:CreateTab("Main")
local General = Main:CreateSection("General")
General:CreateToggle({ Name = "Enabled", Flag = "enabled" })
```

For a Roblox project containing the modular `src` hierarchy, require the `Init` ModuleScript:

```lua
local MidasUI = require(path.To.MidasUI.Init)
```

`loadstring` and file-backed config profiles depend on the capabilities available in the runtime where the library is executed. The library returns clear config failure values when file APIs are absent.

## What's Included

- Branded crown topbar and optional short startup reveal.
- Windows with tabs, sections, scrolling, animated show/hide, resizing, and complete minimize/restore.
- Optional `Default`, `FarmingDashboard`, and `PowerPanel` layout templates.
- Button, toggle, precision slider, dropdown, input, keybind, paragraph, divider, progress bar, stat card, log panel, callout, and action-row controls.
- `Ctrl+K` command palette with registered actions and indexed navigation across large interfaces.
- Controllers, flags, dependencies, config profiles, runtime themes, dialogs, notifications, tooltips, and opt-in diagnostics.

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

Window:RegisterCommand({
	Title = "Apply",
	Callback = function()
		Enabled:Set(true)
	end,
})
```

The shorter runnable beginner sample is [src/Example.lua](src/Example.lua). The full runtime test surface is [src/Showcase.lua](src/Showcase.lua).

## Documentation

- [Documentation index](docs/README.md)
- [API reference](docs/API.md)
- [Controllers and flags](docs/CONTROLLERS.md)
- [Config profiles](docs/CONFIG.md)
- [Themes](docs/THEMES.md)
- [Templates and workflow layouts](docs/TEMPLATES.md)
- [Commands, search, and navigation](docs/COMMANDS.md)
- [Showcase and manual QA](docs/SHOWCASE.md)
- [Changelog](docs/CHANGELOG.md)

## Known Limitations

- Config storage requires compatible `writefile`, `readfile`, and `isfile` runtime APIs; these are not Roblox Studio standard APIs.
- An anonymous theme supplied directly to `SetTheme({ ... })` is normalized at runtime but cannot be restored by name from a config. Register it first when persistence is needed.
- Keybind elements use their `Flag` as their registry identity; assign a unique flag to each independently triggered keybind.
- Indexed search navigates to controls; it never toggles or invokes a control unless the author registers an explicit command callback.
- QA is primarily manual in a Roblox runtime; static parser checks do not replace in-game interaction testing.
