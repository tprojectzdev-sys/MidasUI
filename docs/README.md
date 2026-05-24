# MidasUI Documentation

MidasUI is a Roblox Luau interface library with a dark premium theme, compact crown branding, controllers, profiles, transient UI, command discovery, and optional workflow-oriented layout presets.

## Load In One Line

```lua
local MidasUI = loadstring(game:HttpGet("RAW_DIST_URL_HERE"))()
```

## First Window

```lua
local Window = MidasUI:CreateWindow({
	Title = "My Panel",
	Theme = "DarkGold",
})

local Main = Window:CreateTab("Main")
local General = Main:CreateSection("General")
General:CreateButton({ Name = "Run", Callback = function() end })
```

The startup crest animation is enabled by default. Pass `Intro = false` when immediate presentation is preferable.

## What's Included

- Window, tab, and section composition
- Default, dashboard, and dense power-panel window templates
- Standard controls plus ProgressBar, StatCard, LogPanel, Callout, and ActionRow
- Controller and flag/dependency binding
- Precision sliders and Toggle/Hold keybinds
- Runtime themes, custom themes, notifications, dialogs, and tooltips
- Command registry, `Ctrl+K` palette, indexed control navigation, and searchable long dropdowns
- Optional config profiles and debug diagnostics
- `Showcase.lua` manual runtime verification suite

## Where To Go Next

| Need | Read |
| --- | --- |
| Every method and option | [API.md](API.md) |
| Store controls and update them later | [CONTROLLERS.md](CONTROLLERS.md) |
| Save and load profiles | [CONFIG.md](CONFIG.md) |
| Switch or create themes | [THEMES.md](THEMES.md) |
| Choose dashboard or dense layouts | [TEMPLATES.md](TEMPLATES.md) |
| Add searchable actions and keyboard navigation | [COMMANDS.md](COMMANDS.md) |
| Run visual/manual QA | [SHOWCASE.md](SHOWCASE.md) |
| Version history | [CHANGELOG.md](CHANGELOG.md) |
