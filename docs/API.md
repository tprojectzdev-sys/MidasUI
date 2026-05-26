# MidasUI V1.9 API

All methods below use colon call syntax. Mutating controller/container methods return the controller or container unless a return value is stated.

## Library

```lua
local Window = MidasUI:CreateWindow(options)
```

`options`: `Title`, `Subtitle`, `Icon`, `Theme`, `Template`, `Size`, `SaveConfig`, `ConfigFolder`, `ConfigFile`, `Resizable`, `Animations`, `Intro`, `ToggleKey`, and `Launcher`. Templates are optional: `Default`, `FarmingDashboard`, or `PowerPanel`; `Preset` is an alias for `Template`. The earlier `Resizeable` and `StartupAnimation` spellings remain supported aliases. `Intro = false` or `Animations = false` skips the startup reveal.

| Method | Result |
| --- | --- |
| `CreateWindow(options)` | Creates a window. Invalid option tables fall back safely. |
| `SetTheme(nameOrTheme)` | Applies a registered theme name or custom table; returns `valid, appliedName`. Unknown names apply `DarkGold`. |
| `RegisterTheme(name, values)` | Returns `true, name` or `false, error`. |
| `RegisterIcon(name, definition)` / `RegisterIcons(map)` | Registers a custom glyph, image asset id, or sprite definition for icon-capable controls. Invalid definitions return `false` safely. |
| `OnThemeChanged(callback)` | Subscribes to applied theme changes and returns a controller with `Disconnect()`; callback receives `appliedName, theme, valid`. |
| `GetTemplate(nameOrTable)` | Returns `normalizedTemplate, appliedName, valid`; invalid names fall back to `Default`. |
| `RegisterCommand(options)` | Registers a searchable action and returns a controller with `Run()` and `Unregister()`, or `nil` for invalid options. |
| `UnregisterCommand(idOrController)` | Removes a registered action; returns whether it existed. |
| `RunCommand(idOrController)` | Safely executes a registered action; returns whether it existed and could run. |
| `Search(query, options?)` | Returns command and indexed UI matches. Results expose `Run()` for navigation/action execution. |
| `SearchCommands(query)` | Returns command matches only. |
| `NavigateTo(controller)` | Reveals an indexed window/tab/section/control without activating its value/action. |
| `OpenCommandPalette(options?)` / `CloseCommandPalette()` / `ToggleCommandPalette(options?)` | Controls the global palette; `options.Query` seeds its search input. |
| `SetCommandPaletteShortcut(value)` / `ClearCommandPaletteShortcut()` | Replaces or disables the default `Ctrl+K` palette shortcut. Returns `success, displayOrError`. |
| `SetMenuToggleKey(value)` / `ClearMenuToggleKey()` | Defines or disables the active-window hide/show shortcut. Returns `success, displayOrError`. |
| `Notify(options)` | Shows a notification and returns a controller with `Close()`. |
| `Dialog(options)` | Shows an `Info`, `Confirm`, or `Input` dialog and returns a controller with `Close()`. |
| `Info(options)` / `Confirm(options)` / `Prompt(options)` | Dialog shortcuts that do not mutate the caller's options table. |
| `GetFlag(flag)` | Returns the current stored flag value. |
| `SetFlag(flag, value, fireCallback?)` | Updates bound elements; returns `true`, or `false` for an invalid flag name. |
| `SaveConfig(profile?)` / `LoadConfig(profile?)` | Returns `success, error?`; omitted profile uses `default`. |
| `DeleteConfig(profile?)` | Deletes a stored profile when supported. |
| `ListConfigs()` | Returns known profile names, or an empty table if unavailable. |
| `SetDebug(enabled)` | Enables or disables diagnostic warnings. Defaults off. |
| `GetDebugState()` | Returns a summary only when debug mode is enabled; includes command/search/keybind/window counts, overlay state, and command API availability. |
| `GetRuntimeReport()` | Returns runtime counts, overlay state, shortcut state, and API availability without printing. |
| `RunSelfTest()` / `PrintRuntimeReport()` | Returns validation checks for public/component/command/shortcut surfaces; printing occurs only when debug mode is enabled. |
| `DestroyAllWindows()` / `IsLoaded()` | Destroys current-instance windows for reuse; reports whether a live window remains. |
| `Unload()` | Alias for full `Destroy()` cleanup. |
| `Destroy()` | Destroys windows, transient UI, and owned listeners; delayed transient calls remain inert until `CreateWindow` explicitly reuses the library. |

## Window

| Method | Behavior |
| --- | --- |
| `CreateTab(optionsOrName)` | Creates a tab. |
| `SelectTab(tabOrName)` | Selects an existing tab. |
| `Show()` / `Hide()` | Reveals or hides the window with the configured motion behavior. |
| `Minimize()` / `Restore()` / `SetMinimized(value)` | Controls the fully collapsed topbar state and restored size. |
| `ToggleVisibility()` / `SetToggleKey(value)` / `ClearToggleKey()` | Controls the window with an owned framework shortcut. |
| `SetLauncherEnabled(enabled, options?)` | Enables or disables the optional hidden/minimized floating crown launcher. |
| `SetTitle(text)` / `SetSubtitle(text)` | Changes heading labels. |
| `SetTheme(nameOrTheme)` | A string switches the library theme; a table safely normalizes and applies this window's visuals. Prefer `MidasUI:SetTheme`. |
| `Notify(options)` | Shows a library notification and returns the window for chaining. |
| `Dialog(options)` | Shows and returns a dialog controller. |
| `RegisterCommand(options)` | Registers a command owned by this window; it is removed on window destruction. |
| `OpenCommandPalette(options?)` | Opens the global palette while this window remains live. |
| `Close()` / `Destroy()` | Destroys this window and its element controllers. |

Methods are inert after a window is destroyed. Closing a window closes an active dialog and hides its tooltip; library transient resources are fully released after the last window closes.

## Tab And Section

| Object | Methods |
| --- | --- |
| Tab | `CreateSection(nameOrOptions)`, `Show()`, `Hide()`, `Rename(name)`, `RefreshLayout()`, `Destroy()` |
| Section | `CreateButton`, `CreateToggle`, `CreateSlider`, `CreateDropdown`, `CreateInput`, `CreateKeybind`, `CreateParagraph`, `CreateLabel`, `CreateDivider`, `CreateProgressBar`, `CreateStatCard`, `CreateStatusCard`, `CreateLogPanel`, `CreateCallout`, `CreateActionRow`, `Show()`, `Hide()`, `Rename(name)`, `Set(name)`, `RefreshLayout()`, `RemoveElement(controller)`, `Destroy()` |

`CreateSection({ Name = "Settings", Compact = true })` opts one section into dense control sizing. `PowerPanel` enables it by default.

`CreateStatCard` is the canonical status-card constructor. `CreateStatusCard` is a supported compatibility alias to the same component; `CreateProgressBar`, `CreateLogPanel`, and `CreateCallout` are public Section constructors.

## Elements

```lua
section:CreateButton({ Name = "Run", Callback = function() end, Tooltip = "Run action" })
section:CreateToggle({ Name = "Enabled", Flag = "enabled", Default = true, Callback = function(value) end })
section:CreateSlider({ Name = "Volume", Flag = "volume", Min = 0, Max = 100, Increment = 1, Default = 25 })
section:CreateDropdown({ Name = "Mode", Flag = "mode", Options = { "A", "B" }, Default = "A", Searchable = true })
section:CreateInput({ Name = "Name", Flag = "name", Placeholder = "Type...", Default = "" })
section:CreateKeybind({ Name = "Action", Flag = "action_key", Default = Enum.KeyCode.F, Mode = "Toggle" })
section:CreateParagraph({ Text = "Description" })
section:CreateDivider()
section:CreateProgressBar({ Name = "Progress", Flag = "progress", Value = 35, Status = "Running" })
section:CreateStatCard({ Name = "Current Task", Value = "Idle" }) -- CreateStatusCard is an alias
section:CreateLogPanel({ Name = "Recent Events", MaxLines = 20 })
section:CreateCallout({ Title = "Notice", Content = "Review before applying.", Type = "Warning" })
section:CreateActionRow({ Actions = { { Name = "Start", Style = "Success", Callback = function() end } } })
```

All elements accept `Tooltip`. Interactive or display elements may accept `DependsOn = { Flag = "...", Value = value, Mode = "Visible" | "Enabled" }`.

Sliders default to `Increment = 1`. Set `Increment = 5` only for intentional coarse stepping. Decimal `Min`, `Max`, and `Increment` values are supported; display precision follows the configured increment/range precision, and drag, controller, `SetFlag`, and loaded-config updates use the same snapping and clamping.

Dropdowns accept `Icon`, `Searchable = true|false` (or `Search`) and `SearchThreshold`. When no explicit search setting is supplied, lists with at least eight options add a filter input automatically. Expanded lists use a viewport-aware animated popup layer, close when the user clicks outside, and do not resize their containing section. Search preserves existing flag/controller/config behavior.

## Transient UI

`Notify` options: `Title`, `Content`, `Icon`, `Duration`. Missing values use safe defaults. Up to six active notifications are retained; each has a progress rail and a safe `Close()` exit.

`Dialog` options: `Type`, `Title`, `Content`, `Icon`, `ConfirmText`, `CancelText`, `OnConfirm`, `OnCancel`, and additive `Danger = true` / `Variant = "Danger"` styling. Input dialogs additionally support `Placeholder` and `Default`; their confirm callback receives entered text.

The palette is beneath dialogs and above windows; opening a dialog closes the palette. `Ctrl+K` is the configurable default palette shortcut. Normal framework shortcuts and registered keybind dispatch are suppressed while ordinary text entry, a dialog, or an expanded dropdown owns keyboard input. Palette/dropdown results use arrow keys and `Enter`; `Escape` closes the active palette, dropdown, or dialog. Focused palette, input, dropdown-search, keybind-capture, and prompt fields use visible accent focus feedback.

Callbacks execute protected from the UI flow. When debug mode is enabled, callback failures produce categorized warnings.

Buttons, tabs, dropdowns, status cards, callouts, notifications, dialogs, and window branding accept named icons where their options expose `Icon`. See [POLISH.md](POLISH.md) for custom icon and motion examples.

## Runtime Verification

```lua
MidasUI:SetDebug(true)
local report = MidasUI:RunSelfTest()
print(report.Passed, report.ShortcutCount, report.CommandPaletteShortcut)
MidasUI:PrintRuntimeReport()
```

`GetRuntimeReport()` and `RunSelfTest()` are explicitly invoked and do not run automatically for library users. See [SHORTCUTS.md](SHORTCUTS.md) for shortcut formats, launcher behavior, and unload guidance.
