# Commands, Search, And Navigation

V1.8 adds a global command palette for interfaces that outgrow manual tab browsing. Press `Ctrl+K` after creating a window, or call `MidasUI:OpenCommandPalette()`.

## Register Actions

```lua
local command = Window:RegisterCommand({
	Id = "open_settings",
	Title = "Navigate: Settings",
	Description = "Open configuration controls.",
	Category = "Navigate",
	Keywords = { "options", "preferences" },
	Callback = function()
		Window:SelectTab("Settings")
	end,
})
```

Use `Window:RegisterCommand` for actions owned by a window; they are removed when that window is destroyed. `MidasUI:RegisterCommand` also accepts `Owner = controller` for explicit lifecycle ownership.

```lua
command:Run()
command:Unregister()
MidasUI:UnregisterCommand("open_settings")
```

Command callbacks run through the same protected callback path as elements. Invalid registration is ignored and is reported when debug mode is enabled. Set `CloseOnRun = false` only when an action intentionally leaves the palette open.

## Discovery And Navigation

Windows, visible tabs, visible sections, and visible elements are indexed automatically. Palette searches combine registered commands with navigation matches; discovery results reveal or scroll to their target and expand a matching enabled dropdown. They do not toggle flags or invoke buttons.

```lua
local results = MidasUI:Search("profile")
if results[1] then
	results[1]:Run()
end

MidasUI:NavigateTo(SettingsSection)
MidasUI:OpenCommandPalette({ Query = "runtime theme" })
```

Use an explicit command for any state-changing action:

```lua
Window:RegisterCommand({
	Title = "Theme: Apply Midnight",
	Category = "Theme",
	Callback = function()
		MidasUI:SetTheme("Midnight")
	end,
})
```

Hidden dependency controls are excluded while unavailable and become discoverable again when visible. Destroyed controllers and owner-scoped commands are removed safely.

## Keyboard Basics

| Input | Behavior |
| --- | --- |
| `Ctrl+K` | Toggle command palette when a normal text input is not focused |
| `Up` / `Down` | Move through palette or searchable-dropdown results |
| `Enter` | Run the selected command/result or confirm a dialog |
| `Escape` | Close the active palette, expanded dropdown, or dialog |

Dialogs have modal priority: showing a dialog closes the palette and places the dialog above all windows. Existing registered keybind actions do not receive the palette hotkey, and normal keybind dispatch pauses while a palette, dialog, focused text box, or expanded dropdown owns keyboard input.

## Searchable Dropdowns

Dropdowns containing eight or more options gain filtering automatically. Configure it explicitly when needed:

```lua
Section:CreateDropdown({
	Name = "Region",
	Flag = "region",
	Options = longOptionList,
	Searchable = true,
	MaxVisibleOptions = 6,
})
```

`Searchable = false` suppresses automatic filtering. `SearchThreshold = 12` changes the automatic threshold. Filtering is presentation-only: selecting a visible result still follows normal flag/controller/config behavior, no-result filtering is shown explicitly, and filter state resets on close. Expanded dropdowns render in a viewport-aware layer rather than stretching or clipping their section; clicking outside dismisses the layer.

## Workflow Patterns

For `FarmingDashboard`, register commands for display-only workflow actions such as jump to status, start/pause/reset a demo view, clear a log panel, or open a confirmation dialog.

For `PowerPanel`, register commands that reveal compact groups, expand a long option dropdown, open keybind settings, or explicitly toggle a sample setting. Organize titles with prefixes such as `Navigate:`, `Dashboard:`, `Power Panel:`, and `Theme:` so large result lists remain scannable.

## Diagnostics

With `MidasUI:SetDebug(true)`, `MidasUI:GetDebugState()` exposes `CommandCount`, `SearchItemCount`, `KeybindCount`, `WindowCount`, `HasOpenCommandPalette`, `HasExpandedDropdown`, `ActiveOverlay`, and a `PublicAPIs` command-method availability table. Debug remains off by default.
