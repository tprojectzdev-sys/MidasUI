# Controllers And Flags

Every `Create...` element method returns a controller. Store controllers when code must update an element later; direct Roblox Instance access is not required.

## Common Lifecycle Methods

All element controllers support:

| Method | Purpose |
| --- | --- |
| `Show()` / `Hide()` / `SetVisible(boolean)` | Changes layout visibility safely. |
| `SetTheme(themeTable)` | Used by runtime theme propagation. |
| `Refresh()` | Reapplies current controller state and visuals. |
| `Destroy()` | Disconnects events, unregisters dependencies and flags where applicable, and destroys the element. |

All controllers accept later method calls after `Destroy()` without attempting to manipulate destroyed instances.

Elements with enabled state support `SetEnabled(boolean)`, `Enable()`, and `Disable()`: Button, Toggle, Slider, Dropdown, Input, Keybind, Paragraph, and Divider.

## Per-Controller Methods

| Controller | Value and additional methods |
| --- | --- |
| Button | `SetText(text)`, `SetCallback(function)` |
| Toggle | `GetValue()`, `Set(value, fireCallback?)`, `SetValue(value, fireCallback?)`, `SetText`, `SetCallback` |
| Slider | `GetValue()`, `Set`, `SetValue`, `SetRange(min, max, increment?)`, `SetText`, `SetCallback` |
| Dropdown | `GetValue()`, `Set`, `SetValue`, `SetOptions(options, default?)`, `SetExpanded(boolean)`, `SetText`, `SetCallback` |
| Input | `GetValue()`, `Set`, `SetValue`, `SetPlaceholder`, `SetText`, `SetCallback` |
| Keybind | `GetValue()`, `Set`, `SetValue`, `StartListening()`, `StopListening()`, `SetText`, `SetCallback` |
| Paragraph | `GetValue()`, `Set(text)`, `SetValue(text)`, `SetText(text)` |
| Divider | `Set(boolean)` and `SetValue(boolean)` are visibility aliases. |

## Flags

A `Flag` binds runtime value state to an element:

```lua
local Speed = section:CreateSlider({ Flag = "speed", Min = 0, Max = 100, Default = 30 })
MidasUI:SetFlag("speed", 70)
print(MidasUI:GetFlag("speed")) -- 70
```

V1.5 validates values through the first live controller bound to a flag. Sliders clamp and snap numeric values, dropdowns reject values absent from `Options`, toggles reject non-booleans, and keybinds reject invalid key values. Elements sharing a compatible flag receive the normalized value and update their visuals.

Do not bind unlike value types to the same flag. For example, a toggle and slider cannot meaningfully share one value. Keybind flags should be unique because each flag identifies one triggered action.

## Keybind Behavior

`Mode = "Toggle"` invokes `Callback(keyCode)` once for each completed key press.

`Mode = "Hold"` invokes `Callback(true, keyCode)` on press and `Callback(false, keyCode)` on release. Disabling, rebinding, or destroying an active hold binding sends the release callback.

Keybind triggering is blocked while a Roblox `TextBox` is focused. Select the keybind button to listen for a new binding; `Escape` cancels and `Backspace` clears it.

## Dependencies

```lua
section:CreateButton({
	Name = "Advanced",
	DependsOn = { Flag = "enabled", Value = true, Mode = "Enabled" },
})
```

`Visible` hides and restores layout space. `Enabled` disables controls when they implement enabled state and otherwise falls back to visibility. Dependencies re-evaluate after `SetFlag` and config load, and are removed when their element is destroyed.
