# MidasUI V1.5 API

All methods below use colon call syntax. Mutating controller/container methods return the controller or container unless a return value is stated.

## Library

```lua
local Window = MidasUI:CreateWindow(options)
```

`options`: `Title`, `Subtitle`, `Icon`, `Theme`, `Size`, `SaveConfig`, `ConfigFolder`, `ConfigFile`, and `Resizable`. The earlier `Resizeable` spelling remains supported as a compatibility alias.

| Method | Result |
| --- | --- |
| `CreateWindow(options)` | Creates a window. Invalid option tables fall back safely. |
| `SetTheme(nameOrTheme)` | Applies a registered theme name or custom table; returns `valid, appliedName`. Unknown names apply `DarkGold`. |
| `RegisterTheme(name, values)` | Returns `true, name` or `false, error`. |
| `Notify(options)` | Shows a notification and returns a controller with `Close()`. |
| `Dialog(options)` | Shows an `Info`, `Confirm`, or `Input` dialog and returns a controller with `Close()`. |
| `Info(options)` / `Confirm(options)` / `Prompt(options)` | Dialog shortcuts that do not mutate the caller's options table. |
| `GetFlag(flag)` | Returns the current stored flag value. |
| `SetFlag(flag, value, fireCallback?)` | Updates bound elements; returns `true`, or `false` for an invalid flag name. |
| `SaveConfig(profile?)` / `LoadConfig(profile?)` | Returns `success, error?`; omitted profile uses `default`. |
| `DeleteConfig(profile?)` | Deletes a stored profile when supported. |
| `ListConfigs()` | Returns known profile names, or an empty table if unavailable. |
| `SetDebug(enabled)` | Enables or disables diagnostic warnings. Defaults off. |
| `GetDebugState()` | Returns a summary only when debug mode is enabled; otherwise `nil`. |
| `Destroy()` | Destroys windows and transient runtime UI. |

## Window

| Method | Behavior |
| --- | --- |
| `CreateTab(optionsOrName)` | Creates a tab. |
| `SelectTab(tabOrName)` | Selects an existing tab. |
| `Show()` / `Hide()` | Enables or disables the window GUI. |
| `Minimize()` / `Restore()` / `SetMinimized(value)` | Controls compact window state. |
| `SetTitle(text)` / `SetSubtitle(text)` | Changes heading labels. |
| `SetTheme(nameOrTheme)` | A string switches the library theme; a table safely normalizes and applies this window's visuals. Prefer `MidasUI:SetTheme`. |
| `Notify(options)` | Shows a library notification and returns the window for chaining. |
| `Dialog(options)` | Shows and returns a dialog controller. |
| `Close()` / `Destroy()` | Destroys this window and its element controllers. |

Methods are inert after a window is destroyed. Closing a window closes an active dialog and hides its tooltip; library transient resources are fully released after the last window closes.

## Tab And Section

| Object | Methods |
| --- | --- |
| Tab | `CreateSection(name)`, `Show()`, `Hide()`, `Rename(name)`, `RefreshLayout()`, `Destroy()` |
| Section | `CreateButton`, `CreateToggle`, `CreateSlider`, `CreateDropdown`, `CreateInput`, `CreateKeybind`, `CreateParagraph`, `CreateLabel`, `CreateDivider`, `Show()`, `Hide()`, `Rename(name)`, `Set(name)`, `RefreshLayout()`, `RemoveElement(controller)`, `Destroy()` |

## Elements

```lua
section:CreateButton({ Name = "Run", Callback = function() end, Tooltip = "Run action" })
section:CreateToggle({ Name = "Enabled", Flag = "enabled", Default = true, Callback = function(value) end })
section:CreateSlider({ Name = "Volume", Flag = "volume", Min = 0, Max = 100, Increment = 5, Default = 25 })
section:CreateDropdown({ Name = "Mode", Flag = "mode", Options = { "A", "B" }, Default = "A" })
section:CreateInput({ Name = "Name", Flag = "name", Placeholder = "Type...", Default = "" })
section:CreateKeybind({ Name = "Action", Flag = "action_key", Default = Enum.KeyCode.F, Mode = "Toggle" })
section:CreateParagraph({ Text = "Description" })
section:CreateDivider()
```

All elements accept `Tooltip`. Interactive or display elements may accept `DependsOn = { Flag = "...", Value = value, Mode = "Visible" | "Enabled" }`.

## Transient UI

`Notify` options: `Title`, `Content`, `Duration`. Missing values use safe defaults. Up to six active notifications are retained.

`Dialog` options: `Type`, `Title`, `Content`, `ConfirmText`, `CancelText`, `OnConfirm`, `OnCancel`. Input dialogs additionally support `Placeholder` and `Default`; their confirm callback receives entered text.

Callbacks execute protected from the UI flow. When debug mode is enabled, callback failures produce categorized warnings.
