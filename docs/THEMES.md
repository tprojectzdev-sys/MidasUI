# Themes

MidasUI includes `DarkGold`, `Midnight`, and `BlackWhite`.

```lua
MidasUI:SetTheme("Midnight")
```

Switching the library theme updates existing windows, tabs, sections, elements, notifications, dialogs, and tooltips.

## Theme Shape

Theme values are `Color3` fields:

| Field | Used For |
| --- | --- |
| `Background` | Window/control base backgrounds |
| `Topbar` | Header and hover surfaces |
| `Sidebar` | Navigation background |
| `Card` | Sections, dialogs, notifications |
| `Accent` | Selected controls and highlights |
| `Text` | Primary content |
| `MutedText` | Supporting text |
| `Stroke` | Borders and divider line |
| `Danger` | Destructive/close indicator |

## Registering Custom Themes

```lua
local ok, nameOrError = MidasUI:RegisterTheme("Ocean", {
	Background = Color3.fromRGB(10, 16, 24),
	Accent = Color3.fromRGB(80, 180, 255),
	Text = Color3.fromRGB(240, 245, 255),
})

if ok then
	MidasUI:SetTheme("Ocean")
end
```

Custom registration is deliberately tolerant: omitted fields and fields with invalid types are filled from `DarkGold`. `RegisterTheme` returns success or a useful error for an invalid theme name/table.

You may also call `MidasUI:SetTheme({ Accent = Color3.fromRGB(...) })` for an anonymous normalized theme. Register themes used with config profiles; only registered names can be restored after reload.

## Fallback Behavior

`MidasUI:SetTheme("Missing")` safely applies `DarkGold` and returns `false, "DarkGold"`. It only logs a warning when `MidasUI:SetDebug(true)` has been enabled.
